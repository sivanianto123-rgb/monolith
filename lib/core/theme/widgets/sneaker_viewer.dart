import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../app_colors.dart';
import '../app_theme.dart';

/// The shared 3D sneaker viewer used across Home, Shop, Product, Customize,
/// About and cart-line thumbnails.
///
/// [interactive] toggles camera-controls + drag-to-rotate, matching the
/// spec: hero/product/customize/about are interactive, grid/thumbnail
/// previews are static. Static previews get a slow auto-rotate instead so
/// they still read as alive without inviting a drag gesture.
class SneakerViewer extends StatelessWidget {
  final String glbAsset;
  final bool interactive;
  final bool showDragHint;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  const SneakerViewer({
    super.key,
    required this.glbAsset,
    this.interactive = false,
    this.showDragHint = false,
    this.backgroundColor = AppColors.secondary,
    this.borderRadius = const BorderRadius.all(Radius.circular(kRadiusLg)),
  });

  @override
  Widget build(BuildContext context) {
    final viewer = ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: backgroundColor,
        child: ModelViewer(
          key: ValueKey(glbAsset),
          backgroundColor: backgroundColor,
          src: glbAsset,
          alt: 'A Monolith sneaker in 3D',
          cameraControls: interactive,
          disableZoom: !interactive,
          disableTap: !interactive,
          disablePan: !interactive,
          autoRotate: !interactive,
          autoRotateDelay: 0,
          rotationPerSecond: '18deg',
          interactionPrompt: InteractionPrompt.none,
        ),
      ),
    );

    if (!showDragHint) return viewer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: viewer),
        const SizedBox(height: 12),
        Text(
          'DRAG TO ROTATE',
          style: GoogleFonts.archivo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.32 * 11,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
