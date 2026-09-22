import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/data/models/product.dart';
import '../../core/state/cart_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';

class ProductScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProductScreen({super.key, required this.slug});

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  late String _size;

  @override
  void initState() {
    super.initState();
    _size = kSizes[2];
  }

  @override
  void didUpdateWidget(covariant ProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _size = kSizes[2];
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = productBySlug(widget.slug);
    final wide = isWideScreen(context);
    final related = kProducts.where((p) => p.slug != product.slug).toList();

    final viewer = SizedBox(
      height: wide ? 520 : 340,
      child: SneakerViewer(
        glbAsset: product.glbAsset,
        interactive: true,
        showDragHint: true,
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EyebrowText(product.category),
        const SizedBox(height: 12),
        DisplayHeading(
          product.name,
          color: AppColors.foreground,
          fontSize: responsiveDisplaySize(context, max: wide ? 60 : 40),
        ),
        const SizedBox(height: 16),
        Text(
          product.copy,
          style: GoogleFonts.archivo(
            fontSize: 15,
            height: 1.6,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: GoogleFonts.archivo(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 28),
        const EyebrowText('Size (US)'),
        const SizedBox(height: 12),
        SizeSelector(
          sizes: kSizes,
          selected: _size,
          onSelected: (s) => setState(() => _size = s),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .add(
                      slug: product.slug,
                      name: product.name,
                      size: _size,
                      price: product.price,
                      isCustom: false,
                      colors: product.colors,
                      glbAsset: product.glbAsset,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} · US $_size added to bag'),
                  ),
                );
              },
              child: const Text('Add to bag'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/customize?base=${product.slug}'),
              child: const Text('Customize this pair'),
            ),
          ],
        ),
        const SizedBox(height: 40),
        const Divider(),
        const SizedBox(height: 24),
        _SpecRow(label: 'Drop', value: '8mm heel-to-toe'),
        _SpecRow(label: 'Upper', value: 'Engineered knit + synthetic overlays'),
        _SpecRow(label: 'Shipping', value: 'Free, built to order in 5-7 days'),
        _SpecRow(label: 'Returns', value: '30-day returns on unworn pairs'),
      ],
    );

    return ScreenScroll(
      child: PageContainer(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 56 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => context.go('/shop'),
              child: Text(
                '← Back to shop',
                style: GoogleFonts.archivo(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
            const SizedBox(height: 24),
            wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: viewer),
                      const SizedBox(width: 56),
                      Expanded(flex: 5, child: details),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [viewer, const SizedBox(height: 32), details],
                  ),
            const SizedBox(height: 72),
            const EyebrowText('More pairs'),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = wide ? 3 : (constraints.maxWidth > 560 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: related.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final p = related[index];
                    return ProductCard(
                      product: p,
                      onTap: () => context.go('/product/${p.slug}'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.archivo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.archivo(
                fontSize: 13,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
