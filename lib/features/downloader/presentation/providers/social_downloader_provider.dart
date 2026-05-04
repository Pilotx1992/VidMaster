import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di.dart';
import '../../domain/entities/social_downloader_state.dart';
import 'social_downloader_notifier.dart';

final socialDownloaderProvider =
    StateNotifierProvider<SocialDownloaderNotifier, SocialDownloaderState>((ref) {
  final extractUseCase = ref.watch(extractMetadataUseCaseProvider);
  final downloadUseCase = ref.watch(startDownloadUseCaseProvider);

  return SocialDownloaderNotifier(
    extractUseCase:  extractUseCase,
    downloadUseCase: downloadUseCase,
  );
});
