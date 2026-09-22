import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Huge uppercase display headline — weight 800, tight negative tracking,
/// line-height ~0.88. Used for the poster-scale headings across the app.
class DisplayHeading extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final TextAlign? textAlign;

  const DisplayHeading(
    this.text, {
    super.key,
    required this.color,
    this.fontSize = 64,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: GoogleFonts.archivo(
        fontWeight: FontWeight.w800,
        fontSize: fontSize,
        height: 0.88,
        letterSpacing: -0.045 * fontSize,
        color: color,
      ),
    );
  }
}

/// Picks a responsive display size roughly matching the source's
/// 5xl-8xl breakpoint scale.
double responsiveDisplaySize(BuildContext context, {double max = 96}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 480) return max * 0.42;
  if (width < 768) return max * 0.55;
  if (width < 1100) return max * 0.72;
  return max;
}
