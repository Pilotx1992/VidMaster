import 'package:flutter/material.dart';
import 'package:vidmaster/core/theme/app_theme.dart';

class PlayerLoadingOverlay extends StatelessWidget {
  const PlayerLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppTheme.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
