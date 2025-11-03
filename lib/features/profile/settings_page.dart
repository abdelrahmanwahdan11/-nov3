import 'package:flutter/material.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/widgets/molecules/primary_color_picker.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('settingsTitle')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            localizations.translate('themeSettings'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(localizations.translate('lightTheme')),
                icon: const Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(localizations.translate('darkTheme')),
                icon: const Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(localizations.translate('systemTheme')),
                icon: const Icon(Icons.auto_mode_outlined),
              ),
            ],
            selected: {controller.themeMode},
            onSelectionChanged: (modes) {
              controller.updateThemeMode(modes.first);
            },
          ),
          const SizedBox(height: 24),
          Text(
            localizations.translate('primaryColor'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(localizations.translate('primaryColor')),
            trailing: CircleAvatar(
              backgroundColor: controller.primaryColor,
              radius: 18,
            ),
            onTap: () async {
              final color = await showPrimaryColorPickerDialog(
                context: context,
                initialColor: controller.primaryColor,
              );
              if (color != null) {
                await controller.updatePrimaryColor(color);
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            localizations.translate('language'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          DropdownButton<Locale>(
            value: controller.locale,
            onChanged: (value) {
              if (value != null) {
                controller.updateLocale(value);
              }
            },
            items: AppLocalizations.supportedLocales
                .map(
                  (locale) => DropdownMenuItem(
                    value: locale,
                    child: Text(
                      localizations.translate(
                        locale.languageCode == 'ar' ? 'arabic' : 'english',
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
