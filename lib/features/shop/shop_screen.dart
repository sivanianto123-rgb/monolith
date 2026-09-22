import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/models/product.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    final products = _category == 'All'
        ? kProducts
        : kProducts.where((p) => p.category == _category).toList();

    return ScreenScroll(
      child: PageContainer(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 72 : 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowText('Collection'),
            const SizedBox(height: 12),
            DisplayHeading(
              'All sneakers',
              color: AppColors.foreground,
              fontSize: responsiveDisplaySize(context, max: wide ? 72 : 44),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final category in kShopCategories)
                  PillFilterChip(
                    label: category,
                    selected: category == _category,
                    onTap: () => setState(() => _category = category),
                  ),
              ],
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = wide ? 3 : (constraints.maxWidth > 560 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
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
    );
  }
}
