import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Full-bleed dark section (near-black background, off-white text) used for
/// the marquee ticker, dark promo sections, and the footer.
class InkPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const InkPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.inkBackground,
      padding: padding,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: AppColors.inkForeground),
        child: child,
      ),
    );
  }
}
