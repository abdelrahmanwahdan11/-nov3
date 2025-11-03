import 'package:flutter/material.dart';

/// Animates list items with a staggered slide and fade entrance.
class StaggeredSlideFade extends StatefulWidget {
  const StaggeredSlideFade({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 420),
    this.offset = const Offset(0, 0.12),
  });

  /// The zero-based position of the item inside the animated list.
  final int index;

  /// Delay applied before starting the animation for each index.
  final Duration delay;

  /// The animation duration for the slide and fade.
  final Duration duration;

  /// The slide offset that is animated to [Offset.zero].
  final Offset offset;

  final Widget child;

  @override
  State<StaggeredSlideFade> createState() => _StaggeredSlideFadeState();
}

class _StaggeredSlideFadeState extends State<StaggeredSlideFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: widget.offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }
      await Future<void>.delayed(widget.delay * widget.index);
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
