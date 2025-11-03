import 'package:flutter/material.dart';

import 'package:travelmate/core/widgets/atoms/feature_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureScaffold(translationKey: 'profileTitle');
  }
}
