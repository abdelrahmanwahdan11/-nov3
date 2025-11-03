import 'package:flutter/material.dart';

import 'package:travelmate/core/widgets/atoms/feature_scaffold.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScaffold(translationKey: 'searchTitle');
  }
}
