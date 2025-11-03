import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/features/home/explore_mock_data.dart';
import 'package:travelmate/features/journal/journal_models.dart';
import 'package:travelmate/features/place/models/explore_place.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  AppController? _controller;
  List<ExplorePlace> _savedPlaces = <ExplorePlace>[];
  List<JournalEntry> _savedTrips = <JournalEntry>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppControllerScope.of(context);
    if (!identical(_controller, controller)) {
      _controller?.removeListener(_handleControllerChanged);
      _controller = controller;
      _controller?.addListener(_handleControllerChanged);
    }
    _syncSavedContent();
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }
    _syncSavedContent();
  }

  Future<void> _syncSavedContent() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final savedPlaceIds = controller.savedPlaceIds;
    final places = ExploreMockData.places
        .where((place) => savedPlaceIds.contains(place.id))
        .toList()
      ..sort((a, b) => a.title.compareTo(b.title));
    final rawEntries = controller.prefsService.loadJournalEntries();
    final trips = rawEntries
        .map(JournalEntry.fromJson)
        .where((entry) => entry.isSaved)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) {
      return;
    }
    setState(() {
      _savedPlaces = places;
      _savedTrips = trips;
    });
  }

  Future<void> _removeSavedTrip(String id) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    final entries = controller.prefsService
        .loadJournalEntries()
        .map(JournalEntry.fromJson)
        .toList();
    final index = entries.indexWhere((entry) => entry.id == id);
    if (index == -1) {
      return;
    }
    entries[index] = entries[index].copyWith(isSaved: false);
    await controller.prefsService
        .saveJournalEntries(entries.map((entry) => entry.toJson()).toList());
    await _syncSavedContent();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('profileTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            tooltip: localizations.translate('profileOpenSettings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _syncSavedContent,
        child: ListView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + media.padding.bottom),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            _buildHeader(theme, localizations),
            const SizedBox(height: 24),
            _buildPreferencesCard(theme, localizations),
            const SizedBox(height: 24),
            _buildSavedPlaces(theme, localizations),
            const SizedBox(height: 24),
            _buildSavedTrips(theme, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations localizations) {
    final controller = _controller;
    final isGuest = controller?.isGuest ?? false;
    final greetingKey =
        isGuest ? 'profileGreetingGuest' : 'profileGreeting';
    final subtitleKey =
        isGuest ? 'profileGuestSubtitle' : 'profileSubtitle';
    final primaryColor = controller?.primaryColor ?? theme.colorScheme.primary;
    final placesCount = localizations
        .translate('profilePlacesCount')
        .replaceAll('{count}', _savedPlaces.length.toString());
    final tripsCount = localizations
        .translate('profileTripsCount')
        .replaceAll('{count}', _savedTrips.length.toString());

    return GlassSurface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: primaryColor.withOpacity(0.18),
                child: Icon(
                  Icons.person,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate(greetingKey),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.translate(subtitleKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _CountChip(icon: IconlyLight.location, label: placesCount),
              _CountChip(icon: Icons.menu_book_outlined, label: tripsCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final controller = _controller;
    final languageLabel = _languageLabel(localizations);
    final themeLabel = _themeLabel(localizations);
    final accentColor = controller?.primaryColor ?? theme.colorScheme.primary;
    final colorLabel = _colorHex(accentColor);

    return GlassSurface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            theme,
            IconlyLight.setting,
            localizations.translate('profilePreferencesTitle'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PreferenceBadge(
                icon: Icons.translate,
                label:
                    localizations.translate('profilePreferenceLanguageLabel'),
                value: languageLabel,
              ),
              _PreferenceBadge(
                icon: Icons.brightness_4_outlined,
                label:
                    localizations.translate('profilePreferenceThemeLabel'),
                value: themeLabel,
              ),
              _PreferenceBadge(
                icon: Icons.palette_outlined,
                label:
                    localizations.translate('profilePreferenceColorLabel'),
                value: colorLabel,
                trailing: CircleAvatar(
                  radius: 10,
                  backgroundColor: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
            icon: const Icon(Icons.tune),
            label: Text(localizations.translate('profileEditPreferences')),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaces(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return GlassSurface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            theme,
            IconlyLight.location,
            localizations.translate('profileSavedPlacesTitle'),
          ),
          const SizedBox(height: 16),
          if (_savedPlaces.isEmpty)
            _buildEmptyState(
              theme,
              localizations.translate('profileSavedPlacesEmpty'),
              Icons.travel_explore_outlined,
            )
          else ...[
            for (final place in _savedPlaces)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      place.imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    place.title,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${localizations.translate(_categoryKey(place.category))} · ${place.location}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: localizations.translate('profileRemoveSaved'),
                    icon: const Icon(Icons.bookmark_remove_outlined),
                    onPressed: () =>
                        _controller?.setPlaceSaved(place.id, false),
                  ),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/place', arguments: place),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/home'),
            icon: const Icon(Icons.travel_explore_outlined),
            label: Text(localizations.translate('profileManagePlaces')),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTrips(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return GlassSurface(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(
            theme,
            Icons.menu_book_outlined,
            localizations.translate('profileSavedTripsTitle'),
          ),
          const SizedBox(height: 16),
          if (_savedTrips.isEmpty)
            _buildEmptyState(
              theme,
              localizations.translate('profileSavedTripsEmpty'),
              Icons.calendar_today_outlined,
            )
          else ...[
            for (final trip in _savedTrips)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _buildTripLeading(trip),
                  title: Text(
                    trip.title,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    _tripSubtitle(context, localizations, trip),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: localizations.translate('profileRemoveSaved'),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeSavedTrip(trip.id),
                  ),
                  onTap: () => Navigator.of(context).pushNamed('/journal'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
          TextButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/journal'),
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(localizations.translate('profileManageTrips')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    String message,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 36,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTripLeading(JournalEntry entry) {
    final cover = entry.coverImage;
    if (cover == null) {
      return CircleAvatar(
        radius: 30,
        backgroundColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.12),
        child: Icon(
          Icons.photo_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        cover,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      ),
    );
  }

  String _tripSubtitle(
    BuildContext context,
    AppLocalizations localizations,
    JournalEntry entry,
  ) {
    final material = MaterialLocalizations.of(context);
    final date = material.formatMediumDate(entry.date);
    final moments = localizations
        .translate('profileMomentsCount')
        .replaceAll('{count}', entry.moments.length.toString());
    return '$date · ${entry.location}\n$moments';
  }

  Widget _sectionHeading(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: theme.textTheme.titleLarge),
      ],
    );
  }

  String _languageLabel(AppLocalizations localizations) {
    final code = _controller?.locale.languageCode ?? 'ar';
    return localizations
        .translate(code == 'ar' ? 'arabic' : 'english');
  }

  String _themeLabel(AppLocalizations localizations) {
    final mode = _controller?.themeMode ?? ThemeMode.system;
    switch (mode) {
      case ThemeMode.light:
        return localizations.translate('lightTheme');
      case ThemeMode.dark:
        return localizations.translate('darkTheme');
      case ThemeMode.system:
      default:
        return localizations.translate('systemTheme');
    }
  }

  String _colorHex(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2).toUpperCase()}';
  }

  String _categoryKey(String category) {
    switch (category) {
      case 'Hidden Gem':
        return 'categoryHiddenGem';
      case 'Food & Café':
        return 'categoryFoodCafe';
      case 'Must-See':
      default:
        return 'categoryMustSee';
    }
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      radius: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _PreferenceBadge extends StatelessWidget {
  const _PreferenceBadge({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      radius: 18,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}
