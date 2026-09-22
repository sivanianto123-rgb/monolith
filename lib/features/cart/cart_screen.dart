import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/data/models/cart_item.dart';
import '../../core/state/cart_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final wide = isWideScreen(context);

    return ScreenScroll(
      child: PageContainer(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 56 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowText('Bag'),
            const SizedBox(height: 12),
            DisplayHeading(
              'Your bag',
              color: AppColors.foreground,
              fontSize: responsiveDisplaySize(context, max: wide ? 64 : 40),
            ),
            const SizedBox(height: 40),
            if (items.isEmpty)
              const _EmptyState()
            else
              wide
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _LineItemList(items: items)),
                          const SizedBox(width: 48),
                          Expanded(flex: 3, child: _SummaryCard(items: items)),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LineItemList(items: items),
                        const SizedBox(height: 32),
                        _SummaryCard(items: items),
                      ],
                    ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Text(
              'Nothing in here yet.',
              style: GoogleFonts.archivo(
                fontSize: 16,
                color: AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/shop'),
              child: const Text('Start shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineItemList extends ConsumerWidget {
  final List<CartItem> items;

  const _LineItemList({required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            _LineItemTile(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _LineItemTile extends ConsumerWidget {
  final CartItem item;

  const _LineItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: SneakerViewer(
              glbAsset: item.glbAsset,
              borderRadius: BorderRadius.circular(kRadiusSm),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'US ${item.size} · ${item.isCustom ? 'Custom build' : 'Stock colourway'}',
                  style: GoogleFonts.archivo(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.id, item.quantity - 1),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.archivo(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.id, item.quantity + 1),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () =>
                          ref.read(cartProvider.notifier).remove(item.id),
                      child: Text(
                        'Remove',
                        style: GoogleFonts.archivo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.destructive,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${item.lineTotal.toStringAsFixed(2)}',
            style: GoogleFonts.archivo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(border: Border.all(color: AppColors.border)),
        child: Icon(icon, size: 14, color: AppColors.foreground),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<CartItem> items;

  const _SummaryCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(label: 'Items', value: '$itemCount'),
          const SizedBox(height: 10),
          const _SummaryRow(label: 'Shipping', value: 'Free'),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${subtotal.toStringAsFixed(2)}',
            emphasize: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/checkout'),
            child: const Text('Checkout'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.archivo(
      fontSize: emphasize ? 16 : 13,
      fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
      color: emphasize ? AppColors.foreground : AppColors.mutedForeground,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style.copyWith(color: AppColors.foreground)),
      ],
    );
  }
}
