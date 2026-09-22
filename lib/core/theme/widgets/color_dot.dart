import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Small circular color swatch — used next to configurator panel buttons
/// and in the saved-designs list.
class ColorDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool selected;

  const ColorDot({
    super.key,
    required this.color,
    this.size = 14,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.foreground : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
    );
  }
}
