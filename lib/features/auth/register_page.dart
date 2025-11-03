import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ValueNotifier<bool> _passwordObscured = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _confirmObscured = ValueNotifier<bool>(true);

  final RegExp _emailRegex =
      RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$');
  final RegExp _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
  final RegExp _nameRegex = RegExp(r'^[\p{L} ]+$', unicode: true);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordObscured.dispose();
    _confirmObscured.dispose();
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
        SnackBar(content: Text(localizations.translate('accountCreated'))),
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  String? _validateName(String? value) {
    final localizations = AppLocalizations.of(context);
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return localizations.translate('nameRequired');
    }
    if (!_nameRegex.hasMatch(text)) {
      return localizations.translate('nameInvalid');
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    final localizations = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return localizations.translate('confirmPasswordRequired');
    }
    if (value != _passwordController.text) {
      return localizations.translate('passwordsDoNotMatch');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('registerTitle')),
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
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: localizations.translate('name'),
                    prefixIcon: const Icon(IconlyBold.profile),
                  ),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
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
                  valueListenable: _passwordObscured,
                  builder: (context, obscure, _) {
                    return TextFormField(
                      controller: _passwordController,
                      obscureText: obscure,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: localizations.translate('password'),
                        prefixIcon: const Icon(IconlyLight.lock),
                        suffixIcon: IconButton(
                          onPressed: () => _passwordObscured.value = !obscure,
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
                const SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: _confirmObscured,
                  builder: (context, obscure, _) {
                    return TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: localizations.translate('confirmPassword'),
                        prefixIcon: const Icon(IconlyLight.lock),
                        suffixIcon: IconButton(
                          onPressed: () => _confirmObscured.value = !obscure,
                          icon: Icon(
                            obscure ? IconlyLight.show : IconlyLight.hide,
                          ),
                          tooltip: localizations.translate(
                            obscure ? 'showPassword' : 'hidePassword',
                          ),
                        ),
                      ),
                      validator: _validateConfirmPassword,
                    );
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _submit(),
                  icon: const Icon(IconlyBold.profile),
                  label: Text(localizations.translate('registerAction')),
                ),
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor.withOpacity(0.4)),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(localizations.translate('haveAccount')),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed('/auth/login'),
                      child: Text(
                        localizations.translate('loginAction'),
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
