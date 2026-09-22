import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';

/// Numbered spec block ("01 / 02 / 03") — a huge faint number, a bold
/// title, and a small description. Used on the home page's
/// "Made to order / One palette / Carbon foam" section.
class NumberedSpec extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const NumberedSpec({
    super.key,
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: GoogleFonts.archivo(
            fontSize: 72,
            fontWeight: FontWeight.w800,
            height: 1,
            color: AppColors.foreground.withValues(alpha: 0.08),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.archivo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
