import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('loginTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: localizations.translate('email'),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: localizations.translate('password'),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: Text(localizations.translate('loginTitle')),
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/auth/forgot'),
              child: Text(localizations.translate('forgotPasswordTitle')),
            ),
            const Spacer(),
            Text(
              localizations.translate('registerTitle'),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/auth/register'),
              child: Text(localizations.translate('registerTitle')),
            ),
          ],
        ),
      ),
    );
  }
}
