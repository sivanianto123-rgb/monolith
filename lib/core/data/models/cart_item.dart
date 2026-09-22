import 'package:flutter/foundation.dart';

import 'part_colors.dart';

@immutable
class CartItem {
  final String id;
  final String slug;
  final String name;
  final String size;
  final double price;
  final bool isCustom;
  final PartColors colors;
  final String? customName;
  final String glbAsset;
  final int quantity;

  const CartItem({
    required this.id,
    required this.slug,
    required this.name,
    required this.size,
    required this.price,
    required this.isCustom,
    required this.colors,
    required this.glbAsset,
    this.customName,
    this.quantity = 1,
  });

  /// Cart identity key: slug + size + (custom ? colors : "stock").
  static String keyFor({
    required String slug,
    required String size,
    required bool isCustom,
    PartColors? colors,
  }) {
    final variant = isCustom ? 'custom:${colors!.toJson()}' : 'stock';
    return '$slug|$size|$variant';
  }

  String get key =>
      keyFor(slug: slug, size: size, isCustom: isCustom, colors: colors);

  double get lineTotal => price * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
    id: id,
    slug: slug,
    name: name,
    size: size,
    price: price,
    isCustom: isCustom,
    colors: colors,
    glbAsset: glbAsset,
    customName: customName,
    quantity: quantity ?? this.quantity,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'size': size,
    'price': price,
    'isCustom': isCustom,
    'colors': colors.toJson(),
    'customName': customName,
    'glbAsset': glbAsset,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] as String,
    slug: json['slug'] as String,
    name: json['name'] as String,
    size: json['size'] as String,
    price: (json['price'] as num).toDouble(),
    isCustom: json['isCustom'] as bool,
    colors: PartColors.fromJson(json['colors'] as Map<String, dynamic>),
    customName: json['customName'] as String?,
    glbAsset: json['glbAsset'] as String,
    quantity: json['quantity'] as int? ?? 1,
  );
}
