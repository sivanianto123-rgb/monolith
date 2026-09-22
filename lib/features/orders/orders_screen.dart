import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/data/models/product.dart';
import '../../core/data/models/saved_design.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/firestore_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final wide = isWideScreen(context);

    return ScreenScroll(
      child: PageContainer(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 56 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowText('Account'),
            const SizedBox(height: 12),
            DisplayHeading(
              'Your orders',
              color: AppColors.foreground,
              fontSize: responsiveDisplaySize(context, max: wide ? 64 : 40),
            ),
            const SizedBox(height: 40),
            if (user == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Column(
                    children: [
                      Text(
                        'Sign in to see your orders',
                        style: GoogleFonts.archivo(
                          fontSize: 16,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => context.go('/auth'),
                        child: const Text('Sign in'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _OrdersList(uid: user.uid),
              const SizedBox(height: 56),
              const EyebrowText('Saved designs'),
              const SizedBox(height: 16),
              _SavedDesignsList(uid: user.uid),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  final String uid;

  const _OrdersList({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider(uid));

    return ordersAsync.when(
      loading: () => const _LoadingPanel(),
      error: (error, _) =>
          _EmptyPanel(message: 'Could not load orders: $error'),
      data: (orders) {
        if (orders.isEmpty) {
          return const _EmptyPanel(
            message: 'No orders yet — pairs you buy will show up here with tracking and status.',
          );
        }
        return Column(
          children: [
            for (final order in orders) ...[
              _OrderCard(order: order),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderRecord order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('MMM d, y').format(order.createdAt);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id.substring(0, order.id.length.clamp(0, 8))}',
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
              ),
              Text(
                '\$${order.totalDollars.toStringAsFixed(2)}',
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$dateLabel · ${order.status[0].toUpperCase()}${order.status.substring(1)}',
            style: GoogleFonts.archivo(
              fontSize: 12,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} · US ${item.size} × ${item.quantity}',
                      style: GoogleFonts.archivo(
                        fontSize: 13,
                        color: AppColors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${item.lineTotalDollars.toStringAsFixed(2)}',
                    style: GoogleFonts.archivo(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SavedDesignsList extends ConsumerWidget {
  final String uid;

  const _SavedDesignsList({required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final designsAsync = ref.watch(savedDesignsStreamProvider(uid));

    return designsAsync.when(
      loading: () => const _LoadingPanel(),
      error: (error, _) =>
          _EmptyPanel(message: 'Could not load saved designs: $error'),
      data: (designs) {
        if (designs.isEmpty) {
          return const _EmptyPanel(
            message: 'No saved designs yet — build something in the configurator and save it to see it here.',
          );
        }
        return Column(
          children: [
            for (final design in designs) ...[
              _SavedDesignCard(design: design),
              const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }
}

class _SavedDesignCard extends StatelessWidget {
  final SavedDesign design;

  const _SavedDesignCard({required this.design});

  @override
  Widget build(BuildContext context) {
    final base = productBySlug(design.modelSlug);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  design.name,
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Base: ${base.name}',
                  style: GoogleFonts.archivo(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              for (final color in design.colors.asList)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ColorDot(color: color, size: 16),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: SizedBox(
        height: 2,
        child: LinearProgressIndicator(
          color: AppColors.foreground,
          backgroundColor: AppColors.border,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String message;

  const _EmptyPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Text(
        message,
        style: GoogleFonts.archivo(
          fontSize: 14,
          height: 1.6,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }
}
