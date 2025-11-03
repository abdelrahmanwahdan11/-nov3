import 'package:flutter/material.dart';

import 'package:travelmate/core/widgets/atoms/feature_scaffold.dart';

class PlacePage extends StatelessWidget {
  const PlacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScaffold(translationKey: 'placeTitle');
  }
}
