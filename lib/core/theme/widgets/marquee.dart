import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';

/// A horizontally looping marquee band, used for the ink-panel ticker
/// ("3D CONFIGURATOR — FREE SHIPPING — ...") and the giant faint footer
/// wordmark loop.
class Marquee extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final Duration duration;
  final double letterSpacing;
  final EdgeInsetsGeometry padding;
  final int repeatCount;

  const Marquee({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.color = AppColors.inkForeground,
    this.duration = const Duration(seconds: 18),
    this.letterSpacing = 0.02,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.repeatCount = 8,
  });

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.archivo(
      fontSize: widget.fontSize,
      fontWeight: widget.fontWeight,
      color: widget.color,
      letterSpacing: widget.letterSpacing * widget.fontSize,
    );
    final item = Padding(
      padding: widget.padding,
      child: Text(widget.text, style: style, softWrap: false),
    );

    // Lay out `repeatCount` copies in a Row given unbounded width (via
    // OverflowBox), then slide the whole row left by exactly one copy's
    // width (1 / repeatCount, as a fraction of the row's own size) on a
    // repeating loop — the moment one copy scrolls fully offscreen an
    // identical copy is already in its place, so the loop reads seamless.
    return ClipRect(
      child: SizedBox(
        height: widget.fontSize * 1.7,
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: Offset(-1 / widget.repeatCount, 0),
            ).animate(_controller),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.repeatCount, (_) => item),
            ),
          ),
        ),
      ),
    );
  }
}
