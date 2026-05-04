import 'dart:io';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

import 'dart:ui';
import 'package:flutter_chrome_cast/flutter_chrome_cast.dart';

import '../../domain/entities/audio_track_entity.dart';
import '../providers/music_player_provider.dart';
import '../providers/music_library_provider.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  final AudioTrackEntity track;
  final List<AudioTrackEntity> queue;
  final int queueIndex;

  const NowPlayingScreen({
    required this.track,
    required this.queue,
    required this.queueIndex,
    super.key,
  });

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(musicPlayerProvider.notifier).playTrack(
            widget.track,
            queue: widget.queue,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(musicPlayerProvider);
    final notifier = ref.read(musicPlayerProvider.notifier);
    final track = state.currentTrack ?? widget.track;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const _CastButton(),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Dynamic Blurred Background ──
          Positioned.fill(
            child: track.albumArtPath != null
                ? Image.file(
                    File(track.albumArtPath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1C2B3A), Color(0xFF0D1B2A)],
                      ),
                    ),
                  ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),
          // ── Foreground Content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // ── Album Art ────────────────────────────────────────────
                  _AlbumArt(track: track),

                  const Spacer(flex: 1),

                  // ── Track Info ────────────────────────────────────────────
                  Text(
                    track.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${track.artist} — ${track.album}',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // ── Seek Bar ─────────────────────────────────────────────
                  _SeekBar(state: state, notifier: notifier),

                  const SizedBox(height: 28),

                  // ── Controls ─────────────────────────────────────────────
                  _PlaybackControls(state: state, notifier: notifier),

                  const SizedBox(height: 24),

                  // ── Extra Controls ───────────────────────────────────────
                  _ExtraControls(state: state, notifier: notifier),

                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Album Art ──────────────────────────────────────────────────────────────

class _AlbumArt extends StatelessWidget {
  final AudioTrackEntity track;
  const _AlbumArt({required this.track});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: track.albumArtPath != null
            ? Image.file(
                File(track.albumArtPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(context),
              )
            : _placeholder(context),
      ),
    );
  }

  Widget _placeholder(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5), size: 100),
        ),
      );
}

// ── Seek Bar ───────────────────────────────────────────────────────────────

class _SeekBar extends StatelessWidget {
  final MusicPlayerState state;
  final MusicPlayerNotifier notifier;
  const _SeekBar({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: const Color(0xFFF9A825),
            inactiveTrackColor: Colors.white24,
            thumbColor: const Color(0xFFF9A825),
          ),
          child: Slider(
            value: state.progressFraction,
            onChanged: (v) {
              final ms = (v * state.duration.inMilliseconds).toInt();
              notifier.seekTo(Duration(milliseconds: ms));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(state.position),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                _format(state.duration),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }
}

// ── Playback Controls ──────────────────────────────────────────────────────

class _PlaybackControls extends StatelessWidget {
  final MusicPlayerState state;
  final MusicPlayerNotifier notifier;
  const _PlaybackControls({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          icon: Icon(
            Icons.shuffle,
            color: state.shuffleMode == ShuffleMode.on
                ? const Color(0xFFF9A825)
                : Colors.white54,
          ),
          onPressed: notifier.toggleShuffle,
        ),

        const SizedBox(width: 8),

        // Previous
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          onPressed: state.hasPrevious ? notifier.previous : null,
        ),

        const SizedBox(width: 8),

        // Play/Pause
        GestureDetector(
          onTap: notifier.playPause,
          child: Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF9A825),
            ),
            child: Icon(
              state.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: 36,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Next
        IconButton(
          iconSize: 36,
          icon: const Icon(Icons.skip_next, color: Colors.white),
          onPressed: state.hasNext ? notifier.next : null,
        ),

        const SizedBox(width: 8),

        // Repeat
        IconButton(
          icon: Icon(
            state.repeatMode == RepeatMode.repeatOne
                ? Icons.repeat_one
                : Icons.repeat,
            color: state.repeatMode != RepeatMode.off
                ? const Color(0xFFF9A825)
                : Colors.white54,
          ),
          onPressed: notifier.cycleRepeat,
        ),
      ],
    );
  }
}

// ── Extra Controls ─────────────────────────────────────────────────────────

class _ExtraControls extends ConsumerWidget {
  final MusicPlayerState state;
  final MusicPlayerNotifier notifier;
  const _ExtraControls({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(musicLibraryProvider);
    final trackId = state.currentTrack?.id;
    final isFavorite = trackId != null && libraryState.tracks.any((t) => t.id == trackId && t.isFavourite);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Favorite
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? const Color(0xFFF9A825) : Colors.white54,
          ),
          onPressed: () {
            if (trackId != null) {
              ref.read(musicLibraryProvider.notifier).toggleFavorite(trackId);
            }
          },
        ),

        // Sleep Timer
        IconButton(
          icon: Icon(
            Icons.bedtime_outlined,
            color: state.hasSleepTimer ? const Color(0xFFF9A825) : Colors.white54,
          ),
          onPressed: () => _showSleepTimerSheet(context),
        ),

        IconButton(
          icon: const Icon(Icons.equalizer, color: Colors.white),
          onPressed: () => context.push(AppRoutes.equalizer),
        ),

        // Queue
        IconButton(
          icon: const Icon(Icons.queue_music, color: Colors.white54),
          onPressed: () => _showQueueSheet(context),
        ),
      ],
    );
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsetsDirectional.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Up Next',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: state.queue.length,
                itemBuilder: (context, index) {
                  final track = state.queue[index];
                  final isCurrent = index == state.currentIndex;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: isCurrent
                        ? Icon(Icons.volume_up, color: Theme.of(context).colorScheme.primary)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                    title: Text(
                      track.title,
                      style: TextStyle(
                        color: isCurrent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      track.artist,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      track.formattedDuration,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    onTap: () {
                      notifier.playTrack(track, queue: state.queue);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2B3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sleep Timer',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[15, 30, 45, 60, 90].map(
              (minutes) => ListTile(
                title: Text('$minutes minutes',
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  notifier.setSleepTimer(Duration(minutes: minutes));
                  Navigator.pop(context);
                },
              ),
            ),
            if (state.hasSleepTimer)
              ListTile(
                title: const Text('Cancel timer',
                    style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  notifier.cancelSleepTimer();
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Chromecast Support ─────────────────────────────────────────────────────

class _CastButton extends StatelessWidget {
  const _CastButton();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GoogleCastSession?>(
      stream: GoogleCastSessionManager.instance.currentSessionStream,
      builder: (context, snapshot) {
        final isConnected = GoogleCastSessionManager.instance.connectionState ==
            GoogleCastConnectState.connected;

        return IconButton(
          icon: Icon(
            isConnected ? Icons.cast_connected : Icons.cast,
            color: isConnected ? const Color(0xFFF9A825) : Colors.white,
          ),
          onPressed: () => _showCastDialog(context),
        );
      },
    );
  }

  void _showCastDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2B3A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _CastDevicePicker(),
    );
  }
}

class _CastDevicePicker extends ConsumerWidget {
  const _CastDevicePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cast to Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (GoogleCastSessionManager.instance.connectionState ==
                  GoogleCastConnectState.connected)
                TextButton(
                  onPressed: () {
                    GoogleCastSessionManager.instance
                        .endSessionAndStopCasting();
                    Navigator.pop(context);
                  },
                  child: const Text('Disconnect',
                      style: TextStyle(color: Colors.redAccent)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<GoogleCastDevice>>(
            stream: GoogleCastDiscoveryManager.instance.devicesStream,
            builder: (context, snapshot) {
              final devices = snapshot.data ?? [];
              if (devices.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: Color(0xFFF9A825)),
                      SizedBox(height: 16),
                      Text('Searching for devices...',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  return ListTile(
                    leading: const Icon(Icons.cast, color: Colors.white70),
                    title: Text(device.friendlyName,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(device.modelName ?? 'Cast Device',
                        style: const TextStyle(color: Colors.white54)),
                    onTap: () => _handleCast(context, ref, device),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleCast(
      BuildContext context, WidgetRef ref, GoogleCastDevice device) async {
    try {
      await GoogleCastSessionManager.instance.startSessionWithDevice(device);

      final playerState = ref.read(musicPlayerProvider);
      final track = playerState.currentTrack;

      if (track != null) {
        final mediaInfo = GoogleCastMediaInformation(
          contentId: track.filePath,
          streamType: CastMediaStreamType.buffered,
          contentUrl: Uri.parse(track.filePath),
          contentType: 'audio/mpeg',
          metadata: GoogleCastMusicMediaMetadata(
            title: track.title,
            artist: track.artist,
            albumName: track.album,
            images: [
              if (track.albumArtPath != null)
                GoogleCastImage(
                  url: Uri.parse(track.albumArtPath!),
                ),
            ],
          ),
        );

        await GoogleCastRemoteMediaClient.instance.loadMedia(
          mediaInfo,
          autoPlay: true,
        );
      }

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cast: $e')),
        );
      }
    }
  }
}
