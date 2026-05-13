import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Sort icon backed by `assets/sort By.svg`.
///
/// The SVG declares `fill="currentColor"` so it can be tinted from the current
/// theme through [ColorFilter].
class CustomSortArrowsIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const CustomSortArrowsIcon({
    super.key,
    this.size = 22.0,
    required this.color,
    this.strokeWidth = 2.2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/sort By.svg',
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}
