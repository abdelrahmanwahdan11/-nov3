import 'package:flutter/material.dart';

class AnimatedGradientCard extends StatefulWidget {
  const AnimatedGradientCard({
    super.key,
    required this.colors,
    required this.child,
    this.height,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.all(24),
  });

  final List<Color> colors;
  final Widget child;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  State<AnimatedGradientCard> createState() => _AnimatedGradientCardState();
}

class _AnimatedGradientCardState extends State<AnimatedGradientCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _interpolatedColors(double t) {
    final base = widget.colors.isNotEmpty
        ? widget.colors
        : <Color>[Colors.teal, Colors.blueAccent];
    if (base.length == 1) {
      return base;
    }
    final result = <Color>[];
    for (var i = 0; i < base.length; i++) {
      final from = base[i];
      final to = base[(i + 1) % base.length];
      var progress = t + (i / base.length);
      while (progress > 1) {
        progress -= 1;
      }
      result.add(Color.lerp(from, to, progress) ?? from);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = Curves.easeInOut.transform(_controller.value);
        final colors = _interpolatedColors(value);
        final alignment = Alignment(
          (value * 2) - 1,
          (value * 1.4) - 0.7,
        );
        return Container(
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: alignment,
              end: -alignment,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.last.withOpacity(0.18),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
