import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Premium music-note icon backed by `assets/music icon.svg`.
///
/// The SVG declares `fill="currentColor"` so its colour is overridden via a
/// [ColorFilter] — that lets the nav-bar pass `selected ? accent : muted`
/// and have the icon respect the active theme.
///
/// The [filled] / [strokeWidth] parameters are preserved for source
/// compatibility with the previous CustomPainter implementation but are now
/// no-ops: the asset is a single fixed glyph and does not have a stroked
/// variant.
class CustomMusicNoteIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool filled;
  final double strokeWidth;

  const CustomMusicNoteIcon({
    super.key,
    this.color,
    this.size = 24,
    this.filled = false,
    this.strokeWidth = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    final tint = color ?? IconTheme.of(context).color ?? Colors.white70;
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/music icon.svg',
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      ),
    );
  }
}
