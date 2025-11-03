import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'package:travelmate/core/localization/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final RegExp _emailRegex =
      RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final localizations = AppLocalizations.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.translate('resetLinkSent'))),
      );
    }
  }

  String? _validateEmail(String? value) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return localizations.translate('emailRequired');
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return localizations.translate('emailInvalid');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('forgotPasswordTitle')),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: theme.colorScheme.surface.withOpacity(0.6),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  localizations.translate('forgotPasswordDescription'),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: localizations.translate('email'),
                    prefixIcon: const Icon(IconlyLight.message),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(IconlyBold.message),
                  label: Text(localizations.translate('sendResetLink')),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
