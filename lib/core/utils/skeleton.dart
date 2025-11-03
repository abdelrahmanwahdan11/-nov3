import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colorScheme.surfaceVariant.withOpacity(0.18 + 0.18 * t),
                colorScheme.surfaceVariant.withOpacity(0.32 + 0.18 * t),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList._({
    super.key,
    required this.itemCount,
    required this.axis,
    required this.padding,
    required this.gap,
    required this.sliver,
    required this.itemBuilder,
    this.crossAxisExtent,
  });

  factory SkeletonList.vertical({
    Key? key,
    int itemCount = 4,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    double gap = 16,
    double height = 120,
    double borderRadius = 20,
    bool sliver = false,
    IndexedWidgetBuilder? builder,
  }) {
    return SkeletonList._(
      key: key,
      itemCount: itemCount,
      axis: Axis.vertical,
      padding: padding,
      gap: gap,
      sliver: sliver,
      itemBuilder: builder ??
          (_, __) => Skeleton(
                height: height,
                borderRadius: borderRadius,
              ),
      crossAxisExtent: height,
    );
  }

  factory SkeletonList.horizontal({
    Key? key,
    int itemCount = 3,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    double gap = 16,
    double width = 200,
    double height = 200,
    double borderRadius = 24,
    bool sliver = false,
    IndexedWidgetBuilder? builder,
  }) {
    return SkeletonList._(
      key: key,
      itemCount: itemCount,
      axis: Axis.horizontal,
      padding: padding,
      gap: gap,
      sliver: sliver,
      itemBuilder: builder ??
          (_, __) => Skeleton(
                width: width,
                height: height,
                borderRadius: borderRadius,
              ),
      crossAxisExtent: height,
    );
  }

  final int itemCount;
  final Axis axis;
  final EdgeInsetsGeometry padding;
  final double gap;
  final bool sliver;
  final IndexedWidgetBuilder itemBuilder;
  final double? crossAxisExtent;

  @override
  Widget build(BuildContext context) {
    if (sliver) {
      if (axis == Axis.horizontal) {
        return SliverPadding(
          padding: padding,
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: crossAxisExtent ?? 200,
              child: _buildListView(context),
            ),
          ),
        );
      }
      return SliverPadding(
        padding: padding,
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == itemCount - 1 ? 0 : gap,
                ),
                child: itemBuilder(context, index),
              );
            },
            childCount: itemCount,
          ),
        ),
      );
    }
    return _buildListView(context);
  }

  Widget _buildListView(BuildContext context) {
    return ListView.separated(
      scrollDirection: axis,
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemBuilder: itemBuilder,
      separatorBuilder: (_, __) => axis == Axis.vertical
          ? SizedBox(height: gap)
          : SizedBox(width: gap),
      itemCount: itemCount,
    );
  }
}
