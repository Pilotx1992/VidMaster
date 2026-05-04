import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../di.dart';

class EqualizerScreen extends ConsumerWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equalizer = ref.watch(androidEqualizerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Equalizer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<AndroidEqualizerParameters>(
        future: equalizer.parameters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Equalizer not supported on this device', style: TextStyle(color: Colors.white70)));
          }

          final params = snapshot.data!;
          return StreamBuilder<bool>(
            stream: equalizer.enabledStream,
            initialData: false,
            builder: (context, enabledSnapshot) {
              final isEnabled = enabledSnapshot.data ?? false;

              return Column(
                children: [
                  _buildHeader(isEnabled, equalizer),
                  const SizedBox(height: 24),
                  _buildBands(params, equalizer, isEnabled),
                  const SizedBox(height: 32),
                  const Spacer(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isEnabled, AndroidEqualizer equalizer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Master Switch',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: isEnabled,
            onChanged: (val) => equalizer.setEnabled(val),
            activeThumbColor: const Color(0xFFF9A825),
          ),
        ],
      ),
    );
  }

  Widget _buildBands(AndroidEqualizerParameters params, AndroidEqualizer equalizer, bool isEnabled) {
    return Container(
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: params.bands.map((band) {
          return StreamBuilder<double>(
            stream: band.gainStream,
            initialData: 0.0,
            builder: (context, snapshot) {
              final gain = snapshot.data ?? 0.0;
              return _EqualizerSlider(
                label: _formatFrequency(band.centerFrequency),
                value: gain,
                min: params.minDecibels,
                max: params.maxDecibels,
                isEnabled: isEnabled,
                onChanged: (val) => band.setGain(val),
              );
            },
          );
        }).toList(),
      ),
    );
  }


  String _formatFrequency(double hz) {
    if (hz < 1000) return '${hz.toInt()}Hz';
    return '${(hz / 1000).toStringAsFixed(1)}kHz';
  }
}

class _EqualizerSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final bool isEnabled;
  final ValueChanged<double> onChanged;

  const _EqualizerSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: isEnabled ? const Color(0xFFF9A825) : Colors.white24,
                inactiveTrackColor: Colors.white10,
                thumbColor: isEnabled ? Colors.white : Colors.white24,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: isEnabled ? onChanged : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? Colors.white70 : Colors.white24,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
