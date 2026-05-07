import 'package:flutter/material.dart';

class PlayerLoadingOverlay extends StatelessWidget {
  const PlayerLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: ColoredBox(
        color: Color(0x33000000),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFF9A825)),
        ),
      ),
    );
  }
}
