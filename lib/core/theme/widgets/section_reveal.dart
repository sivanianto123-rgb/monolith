import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Fade + slide-up reveal used as sections/grid items scroll into view.
/// Wrap grid items with an increasing [index] to get the ~0.05-0.08s stagger.
class SectionReveal extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration stagger;
  final Duration duration;

  const SectionReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.stagger = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<SectionReveal> createState() => _SectionRevealState();
}

class _SectionRevealState extends State<SectionReveal> {
  bool _visible = false;
  bool _armed = false;
  final Key _detectorKey = UniqueKey();

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_armed || !mounted) return;
    if (info.visibleFraction > 0.1) {
      _armed = true;
      Future.delayed(widget.stagger * widget.index, () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _detectorKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 0.08),
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
