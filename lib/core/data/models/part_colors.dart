import 'package:flutter/material.dart';

/// The five configurable parts of a sneaker.
enum SneakerPart { upper, sole, stripe, laces, toe }

extension SneakerPartLabel on SneakerPart {
  String get label => switch (this) {
    SneakerPart.upper => 'Upper',
    SneakerPart.sole => 'Sole',
    SneakerPart.stripe => 'Stripes',
    SneakerPart.laces => 'Laces',
    SneakerPart.toe => 'Toe box',
  };
}

/// The per-part color scheme of a sneaker (stock or customized).
@immutable
class PartColors {
  final Color upper;
  final Color sole;
  final Color stripe;
  final Color laces;
  final Color toe;

  const PartColors({
    required this.upper,
    required this.sole,
    required this.stripe,
    required this.laces,
    required this.toe,
  });

  Color operator [](SneakerPart part) => switch (part) {
    SneakerPart.upper => upper,
    SneakerPart.sole => sole,
    SneakerPart.stripe => stripe,
    SneakerPart.laces => laces,
    SneakerPart.toe => toe,
  };

  PartColors copyWith({SneakerPart? part, Color? color}) {
    if (part == null || color == null) return this;
    return PartColors(
      upper: part == SneakerPart.upper ? color : upper,
      sole: part == SneakerPart.sole ? color : sole,
      stripe: part == SneakerPart.stripe ? color : stripe,
      laces: part == SneakerPart.laces ? color : laces,
      toe: part == SneakerPart.toe ? color : toe,
    );
  }

  List<Color> get asList => [upper, sole, stripe, laces, toe];

  Map<String, int> toJson() => {
    'upper': upper.toARGB32(),
    'sole': sole.toARGB32(),
    'stripe': stripe.toARGB32(),
    'laces': laces.toARGB32(),
    'toe': toe.toARGB32(),
  };

  factory PartColors.fromJson(Map<String, dynamic> json) => PartColors(
    upper: Color(json['upper'] as int),
    sole: Color(json['sole'] as int),
    stripe: Color(json['stripe'] as int),
    laces: Color(json['laces'] as int),
    toe: Color(json['toe'] as int),
  );
}
