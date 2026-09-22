import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';

/// Small-caps label used above every section/screen heading
/// (e.g. "COLLECTION", "CONFIGURATOR", "1 · CHOOSE A PANEL").
class EyebrowText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;

  const EyebrowText(this.text, {super.key, this.color, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: GoogleFonts.archivo(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.32 * 11,
        color: color ?? AppColors.mutedForeground,
      ),
    );
  }
}
