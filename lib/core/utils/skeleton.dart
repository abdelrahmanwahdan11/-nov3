import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height, this.borderRadius = 12});

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                colorScheme.surfaceVariant.withOpacity(0.2 + 0.2 * t),
                colorScheme.surfaceVariant.withOpacity(0.4 + 0.2 * t),
              ],
            ),
          ),
        );
      },
    );
  }
}
