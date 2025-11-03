import 'package:flutter/material.dart';

class OrganismPlaceholder extends StatelessWidget {
  const OrganismPlaceholder({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
