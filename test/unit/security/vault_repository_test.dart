import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vidmaster/core/error/failures.dart';
import 'package:vidmaster/features/security/data/datasources/auth_local_data_source.dart';
import 'package:vidmaster/features/security/data/datasources/file_encryption_data_source.dart';
import 'package:vidmaster/features/security/data/datasources/vault_metadata_data_source.dart';
import 'package:vidmaster/features/security/data/repositories/vault_repository_impl.dart';
import 'package:vidmaster/features/security/domain/entities/encrypted_file_metadata.dart';

class MockFileEncryptionDataSource extends Mock implements FileEncryptionDataSource {}
class MockVaultMetadataDataSource extends Mock implements VaultMetadataDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}


void main() {
  late VaultRepositoryImpl repository;
  late MockFileEncryptionDataSource mockEncryptionDS;
  late MockVaultMetadataDataSource mockMetadataDS;
  late MockAuthLocalDataSource mockAuthDS;
  setUp(() {
    mockEncryptionDS = MockFileEncryptionDataSource();
    mockMetadataDS = MockVaultMetadataDataSource();
    mockAuthDS = MockAuthLocalDataSource();

    repository = VaultRepositoryImpl(
      encryptionDataSource: mockEncryptionDS,
      metadataDataSource: mockMetadataDS,
      authDataSource: mockAuthDS,
    );
  });

  group('authenticateUser', () {
    const tPin = '1234';

    test('should return Right(true) when PIN is valid', () async {
      // arrange
      when(() => mockAuthDS.isLockedOut()).thenAnswer((_) async => false);
      when(() => mockAuthDS.verifyPin(tPin)).thenAnswer((_) async => true);
      when(() => mockAuthDS.resetFailedAttempts()).thenAnswer((_) async => {});

      // act
      final result = await repository.authenticateUser(tPin);

      // assert
      expect(result, const Right(true));
      verify(() => mockAuthDS.verifyPin(tPin)).called(1);
      verify(() => mockAuthDS.resetFailedAttempts()).called(1);
    });

    test('should return Left(AuthenticationFailure) when PIN is invalid', () async {
      // arrange
      when(() => mockAuthDS.isLockedOut()).thenAnswer((_) async => false);
      when(() => mockAuthDS.verifyPin(tPin)).thenAnswer((_) async => false);
      when(() => mockAuthDS.incrementFailedAttempts()).thenAnswer((_) async => 1);

      // act
      final result = await repository.authenticateUser(tPin);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<AuthenticationFailure>());
          expect((failure as AuthenticationFailure).attemptsRemaining, 4);
        },
        (_) => fail('Should have returned a Failure'),
      );
      verify(() => mockAuthDS.incrementFailedAttempts()).called(1);
    });

    test('should return Left(VaultLockedFailure) when user is locked out', () async {
      // arrange
      final lockUntil = DateTime.now().add(const Duration(minutes: 15));
      when(() => mockAuthDS.isLockedOut()).thenAnswer((_) async => true);
      when(() => mockAuthDS.getLockoutUntil()).thenAnswer((_) async => lockUntil);

      // act
      final result = await repository.authenticateUser(tPin);

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<VaultLockedFailure>()),
        (_) => fail('Should have returned a Failure'),
      );
    });
  });

  group('getVaultItems', () {
    test('should return metadata list from data source', () async {
      // arrange
      final tMetadata = [
        EncryptedFileMetadata(
          id: '1',
          originalFileName: 'test.mp4',
          mimeType: 'video/mp4',
          originalFileSizeBytes: 100,
          encFileName: '1.enc',
          wrappedKey: [],
          iv: [],
          pbkdf2Salt: [],
          encryptedAt: DateTime.now(),
          originalFilePath: '/path/test.mp4',
        )
      ];
      when(() => mockMetadataDS.getAllMetadata()).thenReturn(tMetadata);

      // act
      final result = await repository.getVaultItems();

      // assert
      expect(result, Right(tMetadata));
      verify(() => mockMetadataDS.getAllMetadata()).called(1);
    });
  });

  group('lockVault', () {
    test('should set _isUnlocked to false', () async {
      // act
      await repository.lockVault();
      final result = await repository.isVaultUnlocked();

      // assert
      expect(result, const Right(false));
    });
  });
}
