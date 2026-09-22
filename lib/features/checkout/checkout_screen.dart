import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/data/models/cart_item.dart';
import '../../core/data/models/shipping_info.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/cart_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';
import 'razorpay_style_sheet.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController(text: '1 Silhouette Way');
  final _cityController = TextEditingController(text: 'Portland');
  final _postalController = TextEditingController(text: '97201');
  final _countryController = TextEditingController(text: 'United States');

  bool _paying = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _openPaymentSheet(List<CartItem> items, double total) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      context.go('/auth?from=/checkout');
      return;
    }

    // The sheet handles its own fake "Processing..." delay and only
    // resolves `true` once that completes — the real order placement
    // below happens after it closes, not while it's open.
    final paid = await showRazorpayStyleCheckout(context, amount: total);
    if (paid != true) return;
    if (!mounted) return;
    await _pay(items, user.uid);
  }

  Future<void> _pay(List<CartItem> items, String uid) async {
    setState(() => _paying = true);
    try {
      final shipping = ShippingInfo(
        fullName: _nameController.text,
        email: _emailController.text,
        address: _addressController.text,
        city: _cityController.text,
        postalCode: _postalController.text,
        country: _countryController.text,
      );
      await ref
          .read(firestoreServiceProvider)
          .placeOrder(uid: uid, items: items, shipping: shipping);
      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Order placed — demo payment, no money moved. It would ship in 5-7 days.',
          ),
        ),
      );
      context.go('/orders');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Payment failed: $error')));
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final wide = isWideScreen(context);

    if (items.isEmpty) {
      return ScreenScroll(
        child: PageContainer(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: wide ? 56 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const EyebrowText('Checkout'),
              const SizedBox(height: 40),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Column(
                    children: [
                      Text(
                        'Your bag is empty.',
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
              ),
            ],
          ),
        ),
      );
    }

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowText('Shipping'),
        const SizedBox(height: 16),
        _Field(label: 'Full name', controller: _nameController),
        _Field(label: 'Email', controller: _emailController),
        _Field(label: 'Address', controller: _addressController),
        Row(
          children: [
            Expanded(
              child: _Field(label: 'City', controller: _cityController),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Field(
                label: 'Postal code',
                controller: _postalController,
              ),
            ),
          ],
        ),
        _Field(label: 'Country', controller: _countryController),
        const SizedBox(height: 32),
        const EyebrowText('Payment · demo mode'),
        const SizedBox(height: 8),
        Text(
          'No real card is charged. Payment opens a mock checkout sheet.',
          style: GoogleFonts.archivo(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _paying
                ? null
                : () => _openPaymentSheet(items, subtotal),
            child: Text('Pay \$${subtotal.toStringAsFixed(2)}'),
          ),
        ),
      ],
    );

    final summary = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(kRadiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order summary',
            style: GoogleFonts.archivo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} × ${item.quantity}',
                      style: GoogleFonts.archivo(
                        fontSize: 13,
                        color: AppColors.foreground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${item.lineTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.archivo(
                      fontSize: 13,
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: GoogleFonts.archivo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return ScreenScroll(
      child: PageContainer(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 56 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowText('Checkout'),
            const SizedBox(height: 12),
            DisplayHeading(
              'Checkout',
              color: AppColors.foreground,
              fontSize: responsiveDisplaySize(context, max: wide ? 56 : 36),
            ),
            const SizedBox(height: 40),
            wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: form),
                      const SizedBox(width: 48),
                      Expanded(flex: 4, child: summary),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [form, const SizedBox(height: 32), summary],
                  ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _Field({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
