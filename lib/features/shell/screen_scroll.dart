import 'package:flutter/material.dart';

import 'footer.dart';

/// Wraps a screen's content in the page-level scroll view and appends the
/// footer at the end, so every screen scrolls independently under the
/// pinned header (the routed page itself must own its scrolling — it can't
/// live inside a scroll view built at the shell/Navigator level).
class ScreenScroll extends StatelessWidget {
  final Widget child;

  const ScreenScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [child, const Footer()],
      ),
    );
  }
}
