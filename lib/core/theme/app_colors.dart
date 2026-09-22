import 'package:flutter/material.dart';

/// Monochrome design tokens pulled from the original React/Tailwind source.
class AppColors {
  AppColors._();

  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF1F1F1F);
  static const primary = Color(0xFF1F1F1F);
  static const primaryForeground = Color(0xFFFCFCFC);
  static const secondary = Color(0xFFF2F2F2);
  static const mutedForeground = Color(0xFF858585);
  static const accent = Color(0xFFEDEDED);
  static const border = Color(0xFFE3E3E3);
  static const destructive = Color(0xFFC4342A);

  static const inkBackground = Color(0xFF1C1C1C);
  static const inkForeground = Color(0xFFFCFCFC);
  static Color inkForegroundMuted({double opacity = 0.6}) =>
      inkForeground.withValues(alpha: opacity);
}

/// The six grayscale configurator swatches.
class ConfiguratorSwatch {
  final String name;
  final Color color;
  const ConfiguratorSwatch(this.name, this.color);
}

const List<ConfiguratorSwatch> configuratorSwatches = [
  ConfiguratorSwatch('Pure White', Color(0xFFF5F5F5)),
  ConfiguratorSwatch('Bone', Color(0xFFDDD8D0)),
  ConfiguratorSwatch('Concrete', Color(0xFF9A9A9A)),
  ConfiguratorSwatch('Graphite', Color(0xFF4A4A4A)),
  ConfiguratorSwatch('Onyx', Color(0xFF1A1A1A)),
  ConfiguratorSwatch('Void', Color(0xFF0A0A0A)),
];
