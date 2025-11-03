import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/features/catalog/catalog_page.dart';
import 'package:travelmate/features/home/home_page.dart';
import 'package:travelmate/features/journal/journal_page.dart';
import 'package:travelmate/features/plan/plan_page.dart';
import 'package:travelmate/features/profile/profile_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellDestination {
  const _ShellDestination({
    required this.icon,
    required this.labelKey,
    required this.child,
  });

  final IconData icon;
  final String labelKey;
  final Widget child;
}

class _ShellPageState extends State<ShellPage> {
  static const List<_ShellDestination> _destinations = <_ShellDestination>[
    _ShellDestination(
      icon: Icons.explore_rounded,
      labelKey: 'navExplore',
      child: HomePage(key: const PageStorageKey<String>('tab_explore')),
    ),
    _ShellDestination(
      icon: Icons.route_rounded,
      labelKey: 'navPlan',
      child: PlanPage(key: const PageStorageKey<String>('tab_plan')),
    ),
    _ShellDestination(
      icon: IconlyBold.image,
      labelKey: 'navJournal',
      child: JournalPage(key: const PageStorageKey<String>('tab_journal')),
    ),
    _ShellDestination(
      icon: Icons.store_mall_directory_rounded,
      labelKey: 'navCatalog',
      child: CatalogPage(key: const PageStorageKey<String>('tab_catalog')),
    ),
    _ShellDestination(
      icon: Icons.person_rounded,
      labelKey: 'navProfile',
      child: ProfilePage(key: const PageStorageKey<String>('tab_profile')),
    ),
  ];

  final PageStorageBucket _bucket = PageStorageBucket();
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final clamped = widget.initialIndex.clamp(0, _destinations.length - 1);
    _currentIndex = clamped is int ? clamped : clamped.toInt();
  }

  void _handleDestinationSelected(int index) {
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _openSearch() {
    Navigator.of(context).pushNamed('/search');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final accent = theme.extension<AccentGradientTheme>();
    final colors = accent?.colors ??
        <Color>[theme.colorScheme.primary, theme.colorScheme.secondary];
    final isWide = MediaQuery.of(context).size.width >= 900;

    final destinations = _destinations
        .map(
          (destination) => NavigationDestination(
            icon: Icon(destination.icon),
            label: localizations.translate(destination.labelKey),
          ),
        )
        .toList(growable: false);

    final content = PageStorage(
      bucket: _bucket,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _destinations
              .map((destination) => destination.child)
              .toList(growable: false),
        ),
      ),
    );

    if (isWide) {
      return Scaffold(
        extendBody: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Row(
          children: [
            _buildNavigationRail(destinations, colors, theme, localizations),
            Expanded(child: content),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(theme, localizations),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    }

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: content,
      bottomNavigationBar:
          _buildBottomNavigationBar(destinations, colors, theme, localizations),
      floatingActionButton: _buildFloatingActionButton(theme, localizations),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget? _buildFloatingActionButton(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    if (_currentIndex != 0) {
      return null;
    }
    return FloatingActionButton.extended(
      heroTag: 'fab_search',
      onPressed: _openSearch,
      label: Text(localizations.translate('homeSearchTooltip')),
      icon: const Icon(Icons.search),
    );
  }

  Widget _buildBottomNavigationBar(
    List<NavigationDestination> destinations,
    List<Color> colors,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final indicatorColor = colors.first.withOpacity(0.22);
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        indicatorColor: indicatorColor,
        backgroundColor: theme.colorScheme.surface.withOpacity(0.9),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          final base = theme.textTheme.labelSmall;
          if (states.contains(WidgetState.selected)) {
            return base?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            );
          }
          return base?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          );
        }),
      ),
      child: NavigationBar(
        height: 74,
        destinations: destinations,
        selectedIndex: _currentIndex,
        onDestinationSelected: _handleDestinationSelected,
      ),
    );
  }

  Widget _buildNavigationRail(
    List<NavigationDestination> destinations,
    List<Color> colors,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Container(
      width: 94,
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            colors.first.withOpacity(0.72),
            colors.last.withOpacity(0.68),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.18),
            offset: const Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      child: NavigationRail(
        selectedIndex: _currentIndex,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Colors.transparent,
        elevation: 0,
        groupAlignment: -0.2,
        onDestinationSelected: _handleDestinationSelected,
        selectedIconTheme: IconThemeData(
          color: theme.colorScheme.onPrimary,
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          color: theme.colorScheme.onPrimary.withOpacity(0.68),
          size: 24,
        ),
        selectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimary.withOpacity(0.72),
        ),
        destinations: destinations
            .map(
              (destination) => NavigationRailDestination(
                icon: destination.icon,
                selectedIcon: destination.icon,
                label: Text(destination.label),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
