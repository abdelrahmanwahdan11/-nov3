import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ValueNotifier<bool> _isPasswordObscured = ValueNotifier<bool>(true);

  final RegExp _emailRegex =
      RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
  final RegExp _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isPasswordObscured.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final localizations = AppLocalizations.of(context);
    final controller = AppControllerScope.of(context);
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      await controller.setGuestMode(false);
      await controller.setHasOnboarded(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.translate('welcomeBack'))),
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Future<void> _continueAsGuest() async {
    final localizations = AppLocalizations.of(context);
    final controller = AppControllerScope.of(context);
    await controller.setGuestMode(true);
    await controller.setHasOnboarded(true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations.translate('guestWelcome'))),
    );
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (route) => false);
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

  String? _validatePassword(String? value) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return localizations.translate('passwordRequired');
    }
    if (!_passwordRegex.hasMatch(value)) {
      return localizations.translate('passwordInvalid');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final direction = Directionality.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('loginTitle')),
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
                  localizations.translate('welcomeBack'),
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: localizations.translate('email'),
                    prefixIcon: const Icon(IconlyLight.message),
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: _isPasswordObscured,
                  builder: (context, obscure, _) {
                    return TextFormField(
                      controller: _passwordController,
                      obscureText: obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: localizations.translate('password'),
                        prefixIcon: const Icon(IconlyLight.lock),
                        suffixIcon: IconButton(
                          onPressed: () => _isPasswordObscured.value = !obscure,
                          icon: Icon(
                            obscure ? IconlyLight.show : IconlyLight.hide,
                          ),
                          tooltip: localizations.translate(
                            obscure ? 'showPassword' : 'hidePassword',
                          ),
                        ),
                      ),
                      validator: _validatePassword,
                    );
                  },
                ),
                Align(
                  alignment: direction == TextDirection.rtl
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/auth/forgot'),
                    child: Text(
                      localizations.translate('forgotPasswordTitle'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () => _submit(),
                  icon: const Icon(IconlyBold.login),
                  label: Text(localizations.translate('loginAction')),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _continueAsGuest(),
                  icon: const Icon(IconlyLight.profile),
                  label: Text(localizations.translate('guestLogin')),
                ),
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor.withOpacity(0.4)),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(localizations.translate('dontHaveAccount')),
                    TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/auth/register'),
                      child: Text(
                        localizations.translate('registerAction'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
