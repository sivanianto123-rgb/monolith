import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/part_colors.dart';
import '../data/models/product.dart';

class CustomizerState {
  final Product base;
  final SneakerPart selectedPart;
  final PartColors colors;
  final String size;
  final String designName;

  const CustomizerState({
    required this.base,
    required this.selectedPart,
    required this.colors,
    required this.size,
    required this.designName,
  });

  CustomizerState copyWith({
    Product? base,
    SneakerPart? selectedPart,
    PartColors? colors,
    String? size,
    String? designName,
  }) {
    return CustomizerState(
      base: base ?? this.base,
      selectedPart: selectedPart ?? this.selectedPart,
      colors: colors ?? this.colors,
      size: size ?? this.size,
      designName: designName ?? this.designName,
    );
  }

  /// The GLB rendered by the 3D viewer for the current build.
  ///
  /// The source models a single procedural mesh and recolors its materials
  /// live per panel. Each of our three .glb assets, however, bakes its
  /// colorway into ONE fixed material with no separable per-part slots (see
  /// notes at the call site) — so live per-panel recoloring isn't possible
  /// on this asset. As the simplification, we instead swap to whichever of
  /// the three base GLBs has the closest overall color to the current build
  /// (its 5 part colors averaged) every time a shade changes.
  String get nearestGlbAsset {
    Color avg(PartColors c) {
      final list = c.asList;
      final r = list.map((e) => e.r).reduce((a, b) => a + b) / list.length;
      final g = list.map((e) => e.g).reduce((a, b) => a + b) / list.length;
      final b = list.map((e) => e.b).reduce((a, b) => a + b) / list.length;
      return Color.from(alpha: 1, red: r, green: g, blue: b);
    }

    double distance(Color a, Color b) {
      final dr = a.r - b.r;
      final dg = a.g - b.g;
      final db = a.b - b.b;
      return dr * dr + dg * dg + db * db;
    }

    final target = avg(colors);
    var best = kProducts.first;
    var bestDist = double.infinity;
    for (final product in kProducts) {
      final dist = distance(target, avg(product.colors));
      if (dist < bestDist) {
        bestDist = dist;
        best = product;
      }
    }
    return best.glbAsset;
  }
}

class CustomizerNotifier extends StateNotifier<CustomizerState> {
  CustomizerNotifier(Product base)
    : super(
        CustomizerState(
          base: base,
          selectedPart: SneakerPart.upper,
          colors: base.colors,
          size: kSizes[2],
          designName: 'My Monolith',
        ),
      );

  void selectPart(SneakerPart part) {
    state = state.copyWith(selectedPart: part);
  }

  void applyShade(Color color) {
    state = state.copyWith(
      colors: state.colors.copyWith(part: state.selectedPart, color: color),
    );
  }

  void selectSize(String size) {
    state = state.copyWith(size: size);
  }

  void setDesignName(String name) {
    state = state.copyWith(designName: name);
  }

  void resetTo(Product base) {
    state = CustomizerState(
      base: base,
      selectedPart: SneakerPart.upper,
      colors: base.colors,
      size: kSizes[2],
      designName: 'My Monolith',
    );
  }
}

final customizerProvider =
    StateNotifierProvider<CustomizerNotifier, CustomizerState>((ref) {
      return CustomizerNotifier(kProducts.first);
    });
