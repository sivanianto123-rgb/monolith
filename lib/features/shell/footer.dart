import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/widgets/widgets.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 760;

    return InkPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Marquee(
            text: 'MONOLITH — BUILD YOUR OWN — ',
            fontSize: 72,
            fontWeight: FontWeight.w800,
            color: AppColors.inkForeground.withValues(alpha: 0.15),
            duration: const Duration(seconds: 26),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _BrandColumn(),
                      SizedBox(height: 32),
                      _LinkColumn(
                        title: 'Shop',
                        links: [
                          ('All sneakers', '/shop'),
                          ('Configurator', '/customize'),
                          ('Your bag', '/cart'),
                        ],
                      ),
                      SizedBox(height: 32),
                      _LinkColumn(
                        title: 'Account',
                        links: [
                          ('Sign in', '/auth'),
                          ('Your orders', '/orders'),
                        ],
                      ),
                      SizedBox(height: 32),
                      _LinkColumn(
                        title: 'Company',
                        links: [('Studio', '/about')],
                      ),
                    ],
                  )
                : const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _BrandColumn()),
                      Expanded(
                        child: _LinkColumn(
                          title: 'Shop',
                          links: [
                            ('All sneakers', '/shop'),
                            ('Configurator', '/customize'),
                            ('Your bag', '/cart'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _LinkColumn(
                          title: 'Account',
                          links: [
                            ('Sign in', '/auth'),
                            ('Your orders', '/orders'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _LinkColumn(
                          title: 'Company',
                          links: [('Studio', '/about')],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.inkForeground.withValues(alpha: 0.12),
                ),
              ),
            ),
            child: Text(
              '© ${DateTime.now().year} Monolith. All rights reserved.',
              style: GoogleFonts.archivo(
                fontSize: 12,
                color: AppColors.inkForeground.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandColumn extends StatelessWidget {
  const _BrandColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monolith',
          style: GoogleFonts.archivo(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.inkForeground,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 260,
          child: Text(
            'A monochrome, made-to-order sneaker studio. Six shapes, one palette, built to your call.',
            style: GoogleFonts.archivo(
              fontSize: 13,
              height: 1.6,
              color: AppColors.inkForeground.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkColumn extends StatelessWidget {
  final String title;
  final List<(String, String)> links;

  const _LinkColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowText(
          title,
          color: AppColors.inkForeground.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => context.go(link.$2),
              child: Text(
                link.$1,
                style: GoogleFonts.archivo(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkForeground.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
