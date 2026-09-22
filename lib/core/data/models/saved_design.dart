import 'package:flutter/foundation.dart';

import 'part_colors.dart';
import 'shipping_info.dart';

/// Mirrors a `users/{uid}/savedDesigns/{designId}` document.
@immutable
class SavedDesign {
  final String id;
  final String name;
  final String modelSlug;
  final PartColors colors;
  final DateTime createdAt;

  const SavedDesign({
    required this.id,
    required this.name,
    required this.modelSlug,
    required this.colors,
    required this.createdAt,
  });
}

/// One line item inside an `orders/{orderId}` document's `items` array.
@immutable
class OrderLineItem {
  final String slug;
  final String name;
  final String size;
  final int quantity;
  final int priceCents;
  final bool custom;
  final PartColors colors;

  const OrderLineItem({
    required this.slug,
    required this.name,
    required this.size,
    required this.quantity,
    required this.priceCents,
    required this.custom,
    required this.colors,
  });

  double get priceDollars => priceCents / 100;
  double get lineTotalDollars => priceDollars * quantity;

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'name': name,
    'size': size,
    'qty': quantity,
    'priceCents': priceCents,
    'custom': custom,
    'colors': colors.toJson(),
  };

  factory OrderLineItem.fromJson(Map<String, dynamic> json) => OrderLineItem(
    slug: json['slug'] as String,
    name: json['name'] as String,
    size: json['size'] as String,
    quantity: json['qty'] as int,
    priceCents: json['priceCents'] as int,
    custom: json['custom'] as bool? ?? false,
    colors: PartColors.fromJson(
      Map<String, dynamic>.from(json['colors'] as Map),
    ),
  );
}

/// Mirrors a `users/{uid}/orders/{orderId}` document.
@immutable
class OrderRecord {
  final String id;
  final DateTime createdAt;
  final String status;
  final int totalCents;
  final ShippingInfo shipping;
  final List<OrderLineItem> items;

  const OrderRecord({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.totalCents,
    required this.shipping,
    required this.items,
  });

  double get totalDollars => totalCents / 100;
}
