import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/data/models/part_colors.dart';
import '../../core/data/models/product.dart';
import '../../core/state/auth_provider.dart';
import '../../core/state/cart_provider.dart';
import '../../core/state/customizer_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/widgets/widgets.dart';
import '../shell/screen_scroll.dart';

class CustomizeScreen extends ConsumerStatefulWidget {
  final String? baseSlug;

  const CustomizeScreen({super.key, this.baseSlug});

  @override
  ConsumerState<CustomizeScreen> createState() => _CustomizeScreenState();
}

class _CustomizeScreenState extends ConsumerState<CustomizeScreen> {
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: ref.read(customizerProvider).designName,
    );
    if (widget.baseSlug != null) {
      final base = productBySlug(widget.baseSlug!);
      final current = ref.read(customizerProvider).base;
      if (current.slug != base.slug) {
        // Riverpod forbids modifying a provider's state synchronously
        // during a widget lifecycle method (build/initState/dispose/etc) —
        // "Customize this pair" landing here with a `?base=` query param
        // triggered exactly that by calling resetTo() straight from
        // initState. Deferring it to a post-frame callback runs it once
        // the current build is safely finished.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ref.read(customizerProvider.notifier).resetTo(base);
          _nameController.text = ref.read(customizerProvider).designName;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveDesign(String? uid) async {
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save your designs.')),
      );
      return;
    }
    final state = ref.read(customizerProvider);
    setState(() => _saving = true);
    try {
      await ref
          .read(firestoreServiceProvider)
          .saveDesign(
            uid: uid,
            name: state.designName.isEmpty ? 'My Monolith' : state.designName,
            modelSlug: state.base.slug,
            colors: state.colors,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Design saved.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save design: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWideScreen(context);
    final state = ref.watch(customizerProvider);
    final notifier = ref.read(customizerProvider.notifier);
    final user = ref.watch(authStateProvider).valueOrNull;

    final viewer = SizedBox(
      height: wide ? 560 : 340,
      child: SneakerViewer(
        glbAsset: state.nearestGlbAsset,
        interactive: true,
        showDragHint: true,
      ),
    );

    final controls = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EyebrowText('1 · Choose a panel'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final part in SneakerPart.values)
              _PartChip(
                part: part,
                color: state.colors[part],
                selected: state.selectedPart == part,
                onTap: () => notifier.selectPart(part),
              ),
          ],
        ),
        const SizedBox(height: 32),
        const EyebrowText('2 · Choose a shade'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final swatch in configuratorSwatches)
              _ShadeSwatch(
                swatch: swatch,
                selected:
                    state.colors[state.selectedPart].toARGB32() ==
                    swatch.color.toARGB32(),
                onTap: () => notifier.applyShade(swatch.color),
              ),
          ],
        ),
        const SizedBox(height: 32),
        const EyebrowText('3 · Size (US)'),
        const SizedBox(height: 12),
        SizeSelector(
          sizes: kSizes,
          selected: state.size,
          onSelected: notifier.selectSize,
        ),
        const SizedBox(height: 32),
        const EyebrowText("4 · Name it"),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          onChanged: notifier.setDesignName,
          decoration: const InputDecoration(hintText: 'My Monolith'),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () {
                ref
                    .read(cartProvider.notifier)
                    .add(
                      slug: state.base.slug,
                      name: state.designName.isEmpty
                          ? 'My Monolith'
                          : state.designName,
                      size: state.size,
                      price: kCustomPrice,
                      isCustom: true,
                      colors: state.colors,
                      glbAsset: state.nearestGlbAsset,
                      customName: state.designName,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${state.designName} · US ${state.size} added to bag',
                    ),
                  ),
                );
              },
              child: Text('Add to bag · \$${kCustomPrice.toStringAsFixed(2)}'),
            ),
            OutlinedButton(
              onPressed: _saving ? null : () => _saveDesign(user?.uid),
              child: const Text('Save design'),
            ),
          ],
        ),
      ],
    );

    return ScreenScroll(
      child: PageContainer(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: wide ? 56 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EyebrowText('Configurator'),
            const SizedBox(height: 12),
            DisplayHeading(
              'Build your own',
              color: AppColors.foreground,
              fontSize: responsiveDisplaySize(context, max: wide ? 64 : 40),
            ),
            const SizedBox(height: 40),
            wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: viewer),
                      const SizedBox(width: 56),
                      Expanded(flex: 5, child: controls),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [viewer, const SizedBox(height: 32), controls],
                  ),
          ],
        ),
      ),
    );
  }
}

class _PartChip extends StatelessWidget {
  final SneakerPart part;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PartChip({
    required this.part,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorDot(color: color, size: 12),
            const SizedBox(width: 8),
            Text(
              part.label,
              style: GoogleFonts.archivo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.primaryForeground
                    : AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShadeSwatch extends StatelessWidget {
  final ConfiguratorSwatch swatch;
  final bool selected;
  final VoidCallback onTap;

  const _ShadeSwatch({
    required this.swatch,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: swatch.name,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: swatch.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? AppColors.foreground : AppColors.border,
              width: selected ? 2.5 : 1,
            ),
          ),
        ),
      ),
    );
  }
}
