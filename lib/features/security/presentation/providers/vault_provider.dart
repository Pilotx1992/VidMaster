import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failures.dart';
import '../../../../di.dart';
import '../../domain/entities/encrypted_file_metadata.dart';
import '../../domain/repositories/vault_repository.dart';

class VaultState {
  final List<EncryptedFileMetadata> items;
  final bool isLoading;
  final String? errorMessage;
  final double? operationProgress;
  final String? activeOperationId; // Id of the file being encrypted/decrypted

  VaultState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.operationProgress,
    this.activeOperationId,
  });

  VaultState copyWith({
    List<EncryptedFileMetadata>? items,
    bool? isLoading,
    String? errorMessage,
    double? operationProgress,
    String? activeOperationId,
  }) {
    return VaultState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      operationProgress: operationProgress,
      activeOperationId: activeOperationId,
    );
  }
}

class VaultNotifier extends StateNotifier<VaultState> {
  final VaultRepository _repository;

  VaultNotifier(this._repository) : super(VaultState()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getVaultItems();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        items: items,
      ),
    );
  }

  Future<void> addToVault(String sourcePath, String pin) async {
    state = state.copyWith(isLoading: true, activeOperationId: sourcePath);
    
    // Listen for progress
    _repository.encryptionProgress(sourcePath).listen((progressResult) {
      progressResult.fold(
        (_) => null,
        (progress) => state = state.copyWith(operationProgress: progress),
      );
    });

    final result = await _repository.encryptAndMoveToVault(
      sourceFilePath: sourcePath,
      userPin: pin,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
        operationProgress: null,
        activeOperationId: null,
      ),
      (metadata) {
        state = state.copyWith(
          isLoading: false,
          items: [metadata, ...state.items],
          operationProgress: null,
          activeOperationId: null,
        );
      },
    );
  }

  Future<void> restoreFromVault(EncryptedFileMetadata metadata, String pin) async {
    state = state.copyWith(isLoading: true, activeOperationId: metadata.id);

    // Listen for progress
    _repository.decryptionProgress(metadata.encFileName).listen((progressResult) {
      progressResult.fold(
        (_) => null,
        (progress) => state = state.copyWith(operationProgress: progress),
      );
    });

    final result = await _repository.decryptAndRestoreFromVault(
      metadata: metadata,
      userPin: pin,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
        operationProgress: null,
        activeOperationId: null,
      ),
      (_) {
        state = state.copyWith(
          isLoading: false,
          items: state.items.where((i) => i.id != metadata.id).toList(),
          operationProgress: null,
          activeOperationId: null,
        );
      },
    );
  }

  Future<void> deleteFromVault(String metadataId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.permanentlyDeleteFromVault(metadataId);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: _mapFailureToMessage(failure),
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        items: state.items.where((i) => i.id != metadataId).toList(),
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>((ref) {
  final repository = ref.watch(vaultRepositoryProvider);
  return VaultNotifier(repository);
});
