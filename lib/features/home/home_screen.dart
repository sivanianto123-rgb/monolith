import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/data/models/product.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    final hero = kProducts.first;
    final featured = kProducts;

    return ScreenScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageContainer(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: wide ? 72 : 40,
            ),
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 6, child: _HeroCopy()),
                      const SizedBox(width: 48),
                      Expanded(
                        flex: 5,
                        child: SizedBox(
                          height: 460,
                          child: SneakerViewer(
                            glbAsset: hero.glbAsset,
                            interactive: true,
                            showDragHint: true,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HeroCopy(),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 320,
                        child: SneakerViewer(
                          glbAsset: hero.glbAsset,
                          interactive: true,
                          showDragHint: true,
                        ),
                      ),
                    ],
                  ),
          ),
          InkPanel(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Marquee(
              text: '3D CONFIGURATOR  —  FREE SHIPPING  —  MADE TO ORDER  —  CARBON FOAM  —  ',
              fontSize: 15,
            ),
          ),
          PageContainer(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: wide ? 96 : 56,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EyebrowText('Collection'),
                const SizedBox(height: 12),
                DisplayHeading(
                  'Featured — the core three',
                  color: AppColors.foreground,
                  fontSize: wide ? 44 : 30,
                ),
                const SizedBox(height: 40),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = wide
                        ? 3
                        : (constraints.maxWidth > 560 ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: featured.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 24,
                        crossAxisSpacing: 24,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final product = featured[index];
                        return SectionReveal(
                          index: index,
                          child: ProductCard(
                            product: product,
                            onTap: () => context.go('/product/${product.slug}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          InkPanel(
            padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: _PromoCopy()),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 5,
                            child: SizedBox(
                              height: 380,
                              child: SneakerViewer(
                                glbAsset: kProducts[1].glbAsset,
                                interactive: true,
                                backgroundColor: AppColors.inkBackground,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _PromoCopy(),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 280,
                            child: SneakerViewer(
                              glbAsset: kProducts[1].glbAsset,
                              interactive: true,
                              backgroundColor: AppColors.inkBackground,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          PageContainer(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: wide ? 96 : 56,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = wide ? 3 : 1;
                final specs = const [
                  NumberedSpec(
                    number: '01',
                    title: 'Made to order',
                    description: 'Every pair is built after you check out — nothing sits in a warehouse waiting to go out of style.',
                  ),
                  NumberedSpec(
                    number: '02',
                    title: 'One palette',
                    description: 'Six shades, black to white. Recolor every panel and it will still feel like one coherent object.',
                  ),
                  NumberedSpec(
                    number: '03',
                    title: 'Carbon foam',
                    description: 'A lightweight carbon-infused midsole tuned the same way regardless of which silhouette you pick.',
                  ),
                ];
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: columns,
                  mainAxisSpacing: 40,
                  crossAxisSpacing: 40,
                  childAspectRatio: columns == 3 ? 0.95 : 2.2,
                  children: [
                    for (var i = 0; i < specs.length; i++)
                      SectionReveal(index: i, child: specs[i]),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowText('Made to order · 2026 series'),
        const SizedBox(height: 16),
        DisplayHeading(
          'Build your own silhouette',
          color: AppColors.foreground,
          fontSize: responsiveDisplaySize(context, max: wide ? 88 : 52),
        ),
        const SizedBox(height: 24),
        Text(
          'Six shapes. One palette: black to white. Spin the shoe, recolor every panel, and we build the pair you designed.',
          style: GoogleFonts.archivo(
            fontSize: 16,
            height: 1.6,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () => context.go('/customize'),
              child: const Text('Open configurator'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/shop'),
              child: const Text('Shop the drop'),
            ),
          ],
        ),
      ],
    );
  }
}

class _PromoCopy extends StatelessWidget {
  const _PromoCopy();

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowText(
          'Configurator',
          color: AppColors.inkForeground.withValues(alpha: 0.55),
        ),
        const SizedBox(height: 16),
        DisplayHeading(
          'Every panel, your call',
          color: AppColors.inkForeground,
          fontSize: responsiveDisplaySize(context, max: wide ? 56 : 36),
        ),
        const SizedBox(height: 20),
        Text(
          'Upper, sole, stripes, laces, toe box — pick a panel, drop in a shade, and watch the whole shoe respond.',
          style: GoogleFonts.archivo(
            fontSize: 15,
            height: 1.6,
            color: AppColors.inkForeground.withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 28),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.inkForeground,
            foregroundColor: AppColors.inkBackground,
          ),
          onPressed: () => context.go('/customize'),
          child: const Text('Start building'),
        ),
      ],
    );
  }
}
