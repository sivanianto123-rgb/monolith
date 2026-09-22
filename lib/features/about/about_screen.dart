import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/data/models/product.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _paragraphs = [
    'Monolith started as an argument: that a sneaker doesn\'t need six competing colors to look finished. Strip the noise out and the shape does the talking.',
    'Every silhouette we make ships in one grayscale palette, black to white, so the only decision that matters is which panel gets which shade — not which trend is on sale this season.',
    'We build each pair after you check out. No warehouse of unsold sizes, no dead stock. Just your build, made once, made for you.',
  ];

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    final viewer = SizedBox(
      height: wide ? 520 : 340,
      child: SneakerViewer(
        glbAsset: kProducts.first.glbAsset,
        interactive: true,
        showDragHint: true,
      ),
    );

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final paragraph in _paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              paragraph,
              style: GoogleFonts.archivo(
                fontSize: 15,
                height: 1.7,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
      ],
    );

    return ScreenScroll(
      child: PageContainer(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 72 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowText('Studio'),
            const SizedBox(height: 16),
            DisplayHeading(
              'We removed the color so the shape could speak',
              color: AppColors.foreground,
              fontSize: responsiveDisplaySize(context, max: wide ? 72 : 40),
            ),
            const SizedBox(height: 48),
            wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: copy),
                      const SizedBox(width: 56),
                      Expanded(flex: 5, child: viewer),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [copy, const SizedBox(height: 32), viewer],
                  ),
          ],
        ),
      ),
    );
  }
}
