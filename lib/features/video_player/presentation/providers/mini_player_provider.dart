import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/video_file.dart';

enum MiniPlayerStatus {
  hidden,
  mini,
  expanded,
}

class MiniPlayerState {
  final MiniPlayerStatus status;
  final VideoFile? video;

  const MiniPlayerState({
    this.status = MiniPlayerStatus.hidden,
    this.video,
  });

  bool get isVisible => status != MiniPlayerStatus.hidden;
  bool get isExpanded => status == MiniPlayerStatus.expanded;

  MiniPlayerState copyWith({
    MiniPlayerStatus? status,
    VideoFile? video,
  }) {
    return MiniPlayerState(
      status: status ?? this.status,
      video: video ?? this.video,
    );
  }
}

class MiniPlayerNotifier extends StateNotifier<MiniPlayerState> {
  MiniPlayerNotifier() : super(const MiniPlayerState());

  void show(VideoFile video) {
    state = state.copyWith(
      status: MiniPlayerStatus.mini,
      video: video,
    );
  }

  void expand() {
    state = state.copyWith(status: MiniPlayerStatus.expanded);
  }

  void collapse() {
    state = state.copyWith(status: MiniPlayerStatus.mini);
  }

  void hide() {
    state = const MiniPlayerState();
  }
}

final miniPlayerProvider =
    StateNotifierProvider<MiniPlayerNotifier, MiniPlayerState>(
        (ref) => MiniPlayerNotifier());
