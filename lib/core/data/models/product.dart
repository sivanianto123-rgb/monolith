import 'package:flutter/material.dart';

import 'part_colors.dart';

/// Sizes offered across the whole catalog and the configurator.
const List<String> kSizes = ['6', '7', '8', '9', '10', '11', '12', '13'];

/// Flat price for any custom-built pair from the configurator.
const double kCustomPrice = 260.00;

@immutable
class Product {
  final String slug;
  final String name;
  final String subtitle;
  final double price;
  final String category;
  final PartColors colors;
  final String copy;
  final String glbAsset;
  final String previewImage;

  const Product({
    required this.slug,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.colors,
    required this.copy,
    required this.glbAsset,
    required this.previewImage,
  });
}

const List<Product> kProducts = [
  Product(
    slug: 'aurum-one',
    name: 'Aurum One',
    subtitle: 'Gold on black',
    price: 245.00,
    category: 'Running',
    colors: PartColors(
      upper: Color(0xFF1A1A1A),
      sole: Color(0xFF0A0A0A),
      stripe: Color(0xFFC8A24A),
      laces: Color(0xFF1A1A1A),
      toe: Color(0xFF1A1A1A),
    ),
    copy: 'A blacked-out runner struck with gold hardware. Sculpted, weighted, impossible to ignore.',
    glbAsset: 'assets/models/gold.glb',
    previewImage: 'assets/images/comet_surge_trainer.png',
  ),
  Product(
    slug: 'tide-knit',
    name: 'Tide Knit',
    subtitle: 'Blue everyday',
    price: 199.00,
    category: 'Lifestyle',
    colors: PartColors(
      upper: Color(0xFF2F7F7A),
      sole: Color(0xFFF5F5F5),
      stripe: Color(0xFF1A1A1A),
      laces: Color(0xFFF5F5F5),
      toe: Color(0xFF2F7F7A),
    ),
    copy: 'A breathable blue knit over a bright slab sole. The pair that carries the whole week.',
    glbAsset: 'assets/models/blue.glb',
    previewImage: 'assets/images/comet_glide_knit.png',
  ),
  Product(
    slug: 'ember-court',
    name: 'Ember Court',
    subtitle: 'Red charcoal court',
    price: 225.00,
    category: 'Court',
    colors: PartColors(
      upper: Color(0xFF8A2323),
      sole: Color(0xFF0A0A0A),
      stripe: Color(0xFF4A4A4A),
      laces: Color(0xFF0A0A0A),
      toe: Color(0xFF8A2323),
    ),
    copy: 'Deep red against charcoal. A court silhouette with heat in it.',
    glbAsset: 'assets/models/red.glb',
    previewImage: 'assets/images/comet_drift_low.png',
  ),
];

Product productBySlug(String slug) =>
    kProducts.firstWhere((p) => p.slug == slug, orElse: () => kProducts.first);

const List<String> kShopCategories = ['All', 'Running', 'Lifestyle', 'Court'];
