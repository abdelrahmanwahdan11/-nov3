import 'package:flutter/material.dart';

class RefreshableList<T> extends StatelessWidget {
  const RefreshableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.controller,
    this.padding = const EdgeInsets.all(16),
  });

  final List<T> items;
  final IndexedWidgetBuilder itemBuilder;
  final RefreshCallback onRefresh;
  final ScrollController? controller;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
