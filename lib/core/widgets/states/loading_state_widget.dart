import 'package:flutter/material.dart';

class SkeletonList extends StatelessWidget {
  final int itemCount;
  const SkeletonList.cards({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          itemCount,
          (index) => Container(
            height: 100,
            margin: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
