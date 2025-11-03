import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';
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
          GlassSurface(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(IconlyLight.setting, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      localizations.translate('settingsAppearanceSection'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.translate('settingsThemeDescription'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(localizations.translate('systemTheme')),
                      icon: const Icon(Icons.auto_mode_outlined),
                    ),
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
                  ],
                  selected: {controller.themeMode},
                  onSelectionChanged: (modes) {
                    controller.updateThemeMode(modes.first);
                  },
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () async {
                    final color = await showPrimaryColorPickerDialog(
                      context: context,
                      initialColor: controller.primaryColor,
                    );
                    if (color != null) {
                      await controller.updatePrimaryColor(color);
                    }
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                localizations.translate('primaryColor'),
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localizations.translate(
                                  'settingsPrimaryColorDescription',
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: controller.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassSurface(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language_outlined,
                        color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      localizations.translate('settingsLanguageSection'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  localizations.translate('settingsLanguageDescription'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    value: controller.locale,
                    borderRadius: BorderRadius.circular(16),
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateLocale(value);
                      }
                    },
                    items: AppLocalizations.supportedLocales
                        .map(
                          (locale) => DropdownMenuItem(
                            value: locale,
                            child: Row(
                              children: [
                                Icon(
                                  locale.languageCode == 'ar'
                                      ? Icons.translate
                                      : Icons.language,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  localizations.translate(
                                    locale.languageCode == 'ar'
                                        ? 'arabic'
                                        : 'english',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
