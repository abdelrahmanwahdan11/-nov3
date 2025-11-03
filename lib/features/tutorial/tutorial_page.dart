import 'package:flutter/material.dart';

import 'package:travelmate/core/widgets/atoms/feature_scaffold.dart';

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScaffold(translationKey: 'tutorialTitle');
  }
}
