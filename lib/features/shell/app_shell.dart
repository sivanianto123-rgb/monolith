import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'header.dart';

/// Persistent shell around every screen: sticky/pinned header, then the
/// screen's own scrollable content (each screen owns its scroll view and
/// appends the footer via [ScreenScroll]).
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const Header(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
