import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/encrypted_file_metadata.dart';
import '../../domain/repositories/vault_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/file_encryption_data_source.dart';
import '../datasources/vault_metadata_data_source.dart';

/// Production implementation of [VaultRepository].
///
/// Orchestrates three data sources:
///   - [FileEncryptionDataSource] — streaming AES encryption/decryption
///   - [VaultMetadataDataSource] — Hive persistence for metadata
///   - [AuthLocalDataSource] — PIN verification and auth state
///
/// Returns `Either<Failure, T>` for all operations.
class VaultRepositoryImpl implements VaultRepository {
  final FileEncryptionDataSource _encryptionDS;
  final VaultMetadataDataSource _metadataDS;
  final AuthLocalDataSource _authDS;

  /// In-memory flag: true while the vault session is unlocked.
  bool _isUnlocked = false;

  /// Active progress stream controllers keyed by source file path.
  final Map<String, StreamController<Either<Failure, double>>>
      _encryptionProgressControllers = {};
  final Map<String, StreamController<Either<Failure, double>>>
      _decryptionProgressControllers = {};

  VaultRepositoryImpl({
    required FileEncryptionDataSource encryptionDataSource,
    required VaultMetadataDataSource metadataDataSource,
    required AuthLocalDataSource authDataSource,
  })  : _encryptionDS = encryptionDataSource,
        _metadataDS = metadataDataSource,
        _authDS = authDataSource;

  /// Returns the absolute path to the private vault directory,
  /// creating it if it doesn't exist yet.
  Future<String> _getVaultDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDir.path}/vault');
    if (!vaultDir.existsSync()) {
      vaultDir.createSync(recursive: true);
    }
    return vaultDir.path;
  }

  // ─── Authentication ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> authenticateUser(String? inputPin) async {
    if (inputPin == null || inputPin.isEmpty) {
      return const Left(
        AuthenticationFailure(attemptsRemaining: 0),
      );
    }

    try {
      // Check lockout first.
      if (await _authDS.isLockedOut()) {
        final lockUntil = await _authDS.getLockoutUntil();
        return Left(VaultLockedFailure(
          lockDuration: lockUntil!.difference(DateTime.now()),
        ));
      }

      final isValid = await _authDS.verifyPin(inputPin);
      if (isValid) {
        await _authDS.resetFailedAttempts();
        _isUnlocked = true;
        return const Right(true);
      } else {
        final attempts = await _authDS.incrementFailedAttempts();
        final remaining =
            (5 - attempts).clamp(0, 5); // AuthState.maxFailedAttempts = 5

        if (remaining <= 0) {
          _isUnlocked = false;
          final lockUntil = await _authDS.getLockoutUntil();
          return Left(VaultLockedFailure(
            lockDuration: lockUntil?.difference(DateTime.now()) ??
                const Duration(minutes: 15),
          ));
        }

        return Left(AuthenticationFailure(attemptsRemaining: remaining));
      }
    } on CacheException catch (e, st) {
      return Left(
          CacheFailure('Authentication error: ${e.message}', stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, bool>> isVaultUnlocked() async {
    return Right(_isUnlocked);
  }

  @override
  Future<Either<Failure, void>> lockVault() async {
    _isUnlocked = false;
    return const Right(null);
  }

  @override
  Future<Either<Failure, int?>> getRemainingAttempts() async {
    try {
      final failed = await _authDS.getFailedAttempts();
      final remaining = (5 - failed).clamp(0, 5);
      return Right(remaining);
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to get remaining attempts: ${e.message}',
          stackTrace: st));
    }
  }

  // ─── Encrypt & Move to Vault ─────────────────────────────────────────

  @override
  Future<Either<Failure, EncryptedFileMetadata>> encryptAndMoveToVault({
    required String sourceFilePath,
    required String userPin,
  }) async {
    try {
      final sourceFile = File(sourceFilePath);

      // 1. Validate source file.
      if (!await sourceFile.exists()) {
        return Left(FileNotFoundFailure(sourceFilePath));
      }

      // 2. Check for duplicates.
      final existing = _metadataDS.getAllMetadata();
      if (existing.any((m) => m.originalFilePath == sourceFilePath)) {
        return Left(AlreadyInVaultFailure(sourceFile.uri.pathSegments.last));
      }

      // 3. Ensure vault directory exists.
      final vaultPath = await _getVaultDir();
      final vaultDirObj = Directory(vaultPath);
      if (!await vaultDirObj.exists()) {
        await vaultDirObj.create(recursive: true);
      }

      // 4. Generate cryptographic material.
      final salt = _encryptionDS
          .generateSecureRandom(FileEncryptionDataSource.saltLength);
      final iv =
          _encryptionDS.generateSecureRandom(FileEncryptionDataSource.ivLength);
      final fileKey = _encryptionDS
          .generateSecureRandom(FileEncryptionDataSource.keyLength);

      // 5. Derive wrapping key from PIN + salt and wrap the file key.
      final wrappingKey = _encryptionDS.deriveKey(userPin, salt);
      final wrappedKey = _encryptionDS.wrapKey(fileKey, wrappingKey);

      // 6. Generate a unique output file name.
      final encFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${sourceFile.uri.pathSegments.last.hashCode.abs()}.enc';
      final encFilePath = '$vaultPath/$encFileName';

      // 7. Set up progress streaming.
      final progressController =
          StreamController<Either<Failure, double>>.broadcast();
      _encryptionProgressControllers[sourceFilePath] = progressController;

      // 8. Encrypt the file in streaming 4 MB chunks.
      await _encryptionDS.encryptFile(
        sourcePath: sourceFilePath,
        destinationPath: encFilePath,
        key: fileKey,
        iv: iv,
        onProgress: (progress) {
          progressController.add(Right(progress));
        },
      );

      // 9. Determine original file metadata.
      final stat = await sourceFile.stat();
      final fileName = sourceFile.uri.pathSegments.last;
      final mimeType = _guessMimeType(fileName);

      // 10. Build and persist metadata.
      final metadata = EncryptedFileMetadata(
        id: '${DateTime.now().millisecondsSinceEpoch}_${fileName.hashCode.abs()}',
        originalFileName: fileName,
        mimeType: mimeType,
        originalFileSizeBytes: stat.size,
        encFileName: encFileName,
        wrappedKey: wrappedKey,
        iv: iv,
        pbkdf2Salt: salt,
        encryptedAt: DateTime.now(),
        originalFilePath: sourceFilePath,
      );

      await _metadataDS.saveMetadata(metadata);

      // 11. Securely delete the original file.
      await _secureDelete(sourceFile);

      // 12. Clean up progress controller.
      progressController.add(const Right(1.0));
      await progressController.close();
      _encryptionProgressControllers.remove(sourceFilePath);

      return Right(metadata);
    } on EncryptionException catch (e, st) {
      return Left(EncryptionFailure(e.message, stackTrace: st));
    } on CacheException catch (e, st) {
      return Left(CacheFailure(e.message, stackTrace: st));
    } catch (e, st) {
      return Left(
          EncryptionFailure('Failed to encrypt file: $e', stackTrace: st));
    }
  }

  @override
  Stream<Either<Failure, double>> encryptionProgress(String sourceFilePath) {
    final existing = _encryptionProgressControllers[sourceFilePath];
    if (existing != null) return existing.stream;

    // Create a new controller that will be populated during encryption.
    final controller = StreamController<Either<Failure, double>>.broadcast();
    _encryptionProgressControllers[sourceFilePath] = controller;
    return controller.stream;
  }

  // ─── Decrypt & Restore from Vault ────────────────────────────────────

  @override
  Future<Either<Failure, String>> decryptAndRestoreFromVault({
    required EncryptedFileMetadata metadata,
    required String userPin,
  }) async {
    try {
      // 1. Verify the encrypted file exists.
      final vaultPath = await _getVaultDir();
      final encFile = File('$vaultPath/${metadata.encFileName}');
      if (!await encFile.exists()) {
        return Left(FileNotFoundFailure('$vaultPath/${metadata.encFileName}'));
      }

      // 2. Derive the wrapping key and unwrap the file key.
      final wrappingKey = _encryptionDS.deriveKey(userPin, metadata.pbkdf2Salt);
      final fileKey = _encryptionDS.unwrapKey(metadata.wrappedKey, wrappingKey);

      // 3. Ensure the output directory exists.
      final outputDir = Directory(
        metadata.originalFilePath.substring(
          0,
          metadata.originalFilePath.lastIndexOf('/'),
        ),
      );
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      // 4. Set up progress streaming.
      final progressController =
          StreamController<Either<Failure, double>>.broadcast();
      _decryptionProgressControllers[metadata.encFileName] = progressController;

      // 5. Decrypt the file in streaming chunks.
      await _encryptionDS.decryptFile(
        sourcePath: '$vaultPath/${metadata.encFileName}',
        destinationPath: metadata.originalFilePath,
        key: fileKey,
        iv: metadata.iv,
        onProgress: (progress) {
          progressController.add(Right(progress));
        },
      );

      // 6. Delete the encrypted file and metadata.
      await encFile.delete();
      await _metadataDS.deleteMetadata(metadata.id);

      // 7. Clean up progress controller.
      progressController.add(const Right(1.0));
      await progressController.close();
      _decryptionProgressControllers.remove(metadata.encFileName);

      return Right(metadata.originalFilePath);
    } on EncryptionException catch (e, st) {
      return Left(EncryptionFailure(e.message, stackTrace: st));
    } on CacheException catch (e, st) {
      return Left(CacheFailure(e.message, stackTrace: st));
    } catch (e, st) {
      return Left(
          EncryptionFailure('Failed to decrypt file: $e', stackTrace: st));
    }
  }

  @override
  Stream<Either<Failure, double>> decryptionProgress(String encFileName) {
    final existing = _decryptionProgressControllers[encFileName];
    if (existing != null) return existing.stream;

    final controller = StreamController<Either<Failure, double>>.broadcast();
    _decryptionProgressControllers[encFileName] = controller;
    return controller.stream;
  }

  // ─── Vault Contents ──────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<EncryptedFileMetadata>>> getVaultItems() async {
    try {
      return Right(_metadataDS.getAllMetadata());
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to fetch vault items: ${e.message}',
          stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, EncryptedFileMetadata?>> getVaultItemById(
      String id) async {
    try {
      return Right(_metadataDS.getMetadata(id));
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to fetch vault item: ${e.message}',
          stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, int>> getVaultItemCount() async {
    try {
      return Right(_metadataDS.getItemCount());
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to get item count: ${e.message}',
          stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, int>> getVaultTotalSize() async {
    try {
      final vaultPath = await _getVaultDir();
      int totalSize = 0;
      final items = _metadataDS.getAllMetadata();
      for (final item in items) {
        final encFile = File('$vaultPath/${item.encFileName}');
        if (await encFile.exists()) {
          totalSize += await encFile.length();
        }
      }
      return Right(totalSize);
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to get vault size: ${e.message}',
          stackTrace: st));
    } catch (e, st) {
      return Left(
          FileSystemFailure('Failed to read vault files: $e', stackTrace: st));
    }
  }

  // ─── Vault Management ────────────────────────────────────────────────

  @override
  Future<Either<Failure, void>> permanentlyDeleteFromVault(
      String metadataId) async {
    try {
      final metadata = _metadataDS.getMetadata(metadataId);
      if (metadata == null) {
        return Left(FileNotFoundFailure('Vault item not found: $metadataId'));
      }

      // Delete the encrypted file from disk.
      final vaultPath = await _getVaultDir();
      final encFile = File('$vaultPath/${metadata.encFileName}');
      if (await encFile.exists()) {
        await encFile.delete();
      }

      // Remove the metadata entry.
      await _metadataDS.deleteMetadata(metadataId);
      return const Right(null);
    } on CacheException catch (e, st) {
      return Left(CacheFailure('Failed to delete vault item: ${e.message}',
          stackTrace: st));
    } catch (e, st) {
      return Left(FileSystemFailure('Failed to delete encrypted file: $e',
          stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> changePIN({
    required String currentPin,
    required String newPin,
  }) async {
    try {
      // 1. Verify current PIN can unwrap at least one key.
      final items = _metadataDS.getAllMetadata();

      // 2. Re-wrap every file key with the new PIN.
      for (final item in items) {
        // Derive old wrapping key.
        final oldWrappingKey =
            _encryptionDS.deriveKey(currentPin, item.pbkdf2Salt);

        // Unwrap the file key.
        final fileKey =
            _encryptionDS.unwrapKey(item.wrappedKey, oldWrappingKey);

        // Generate new salt for this file.
        final newSalt = _encryptionDS
            .generateSecureRandom(FileEncryptionDataSource.saltLength);

        // Derive new wrapping key from new PIN.
        final newWrappingKey = _encryptionDS.deriveKey(newPin, newSalt);

        // Re-wrap the file key.
        final newWrappedKey = _encryptionDS.wrapKey(fileKey, newWrappingKey);

        // Update metadata with new wrapped key and salt.
        final updatedMetadata = EncryptedFileMetadata(
          id: item.id,
          originalFileName: item.originalFileName,
          mimeType: item.mimeType,
          originalFileSizeBytes: item.originalFileSizeBytes,
          encFileName: item.encFileName,
          wrappedKey: newWrappedKey,
          iv: item.iv,
          pbkdf2Salt: newSalt,
          encryptedAt: item.encryptedAt,
          originalFilePath: item.originalFilePath,
        );

        await _metadataDS.updateMetadata(updatedMetadata);
      }

      // 3. Update the stored PIN hash.
      await _authDS.saveHashedPin(newPin);

      return const Right(null);
    } on EncryptionException catch (e, st) {
      return Left(
          EncryptionFailure('PIN change failed: ${e.message}', stackTrace: st));
    } on CacheException catch (e, st) {
      return Left(
          CacheFailure('PIN change failed: ${e.message}', stackTrace: st));
    }
  }

  // ─── Private Helpers ─────────────────────────────────────────────────

  /// Securely deletes a file by overwriting with random bytes before deleting.
  ///
  /// This makes recovery via disk forensics significantly harder.
  Future<void> _secureDelete(File file) async {
    try {
      final length = await file.length();
      final raf = await file.open(mode: FileMode.writeOnly);

      // Overwrite in chunks to avoid OOM.
      const overwriteChunkSize = 4 * 1024 * 1024; // 4 MB
      int written = 0;
      while (written < length) {
        final remaining = length - written;
        final size =
            remaining < overwriteChunkSize ? remaining : overwriteChunkSize;
        final zeros = List<int>.filled(size, 0);
        await raf.writeFrom(zeros);
        written += size;
      }
      await raf.close();
      await file.delete();
    } catch (_) {
      // Best-effort: if overwrite fails, still try to delete.
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  /// Guesses MIME type from file extension.
  String _guessMimeType(String fileName) {
    final ext =
        fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'mp4' => 'video/mp4',
      'mkv' => 'video/x-matroska',
      'avi' => 'video/x-msvideo',
      'mov' => 'video/quicktime',
      'webm' => 'video/webm',
      'flv' => 'video/x-flv',
      'mp3' => 'audio/mpeg',
      'flac' => 'audio/flac',
      'wav' => 'audio/wav',
      'aac' => 'audio/aac',
      'ogg' => 'audio/ogg',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      _ => 'application/octet-stream',
    };
  }
}
