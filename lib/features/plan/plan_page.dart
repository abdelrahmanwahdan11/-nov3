import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/prefs/prefs_service.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/features/plan/plan_models.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final TextEditingController _destinationController = TextEditingController();
  final Set<int> _selectedWeekdays = <int>{};
  final Set<String> _selectedStyles = <String>{};
  RangeValues _budgetRange = const RangeValues(600, 2200);

  PrefsService? _prefsService;

  @override
  void initState() {
    super.initState();
    _destinationController.addListener(_onDestinationChanged);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await PrefsService.getInstance();
    final savedDestination = prefs.loadPlanDestination();
    final savedWeekdays = prefs.loadPlanWeekdays();
    final savedBudget = prefs.loadPlanBudgetRange();
    final savedStyles = prefs.loadPlanStyles();

    if (!mounted) {
      return;
    }

    setState(() {
      _prefsService = prefs;
      if (savedDestination != null) {
        _destinationController.text = savedDestination;
      }
      _selectedWeekdays
        ..clear()
        ..addAll(savedWeekdays);
      _selectedStyles
        ..clear()
        ..addAll(savedStyles);
      _budgetRange = savedBudget;
    });
  }

  void _onDestinationChanged() {
    final text = _destinationController.text.trim();
    final prefs = _prefsService;
    if (prefs == null) {
      return;
    }
    prefs.savePlanDestination(text.isEmpty ? null : _destinationController.text);
  }

  @override
  void dispose() {
    _destinationController.removeListener(_onDestinationChanged);
    _destinationController.dispose();
    super.dispose();
  }

  void _toggleWeekday(int value) {
    setState(() {
      if (_selectedWeekdays.contains(value)) {
        _selectedWeekdays.remove(value);
      } else {
        _selectedWeekdays.add(value);
      }
    });
    _prefsService?.savePlanWeekdays(_selectedWeekdays.toList()..sort());
  }

  void _toggleStyle(String id) {
    setState(() {
      if (_selectedStyles.contains(id)) {
        _selectedStyles.remove(id);
      } else {
        _selectedStyles.add(id);
      }
    });
    _prefsService?.savePlanStyles(_selectedStyles.toList()..sort());
  }

  Future<void> _handleGenerate() async {
    final localizations = AppLocalizations.of(context);
    final destination = _destinationController.text.trim();

    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate('planDestinationRequired')),
        ),
      );
      return;
    }

    final itinerary = _buildItinerary(localizations, destination);
    final args = TravelPlanSummaryArgs(
      destination: destination,
      selectedWeekdayIndexes: _selectedWeekdays.toList()..sort(),
      budgetRange: _budgetRange,
      selectedStyleIds: _selectedStyles.toList()..sort(),
      activities: itinerary,
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamed('/plan/summary', arguments: args);
  }

  List<PlanItineraryEntry> _buildItinerary(
    AppLocalizations localizations,
    String destination,
  ) {
    final focusDestination = destination.isEmpty
        ? localizations.translate('planFallbackDestination')
        : destination;

    final entries = <PlanItineraryEntry>[
      PlanItineraryEntry(
        time: '09:00',
        title: localizations
            .translate('planItineraryMorningTitle')
            .replaceAll('{destination}', focusDestination),
        description: localizations
            .translate('planItineraryMorningDescription')
            .replaceAll('{destination}', focusDestination),
      ),
      PlanItineraryEntry(
        time: '12:30',
        title: localizations
            .translate('planItineraryMiddayTitle')
            .replaceAll('{destination}', focusDestination),
        description: localizations
            .translate('planItineraryMiddayDescription')
            .replaceAll('{destination}', focusDestination),
      ),
      PlanItineraryEntry(
        time: '19:30',
        title: localizations
            .translate('planItineraryEveningTitle')
            .replaceAll('{destination}', focusDestination),
        description: localizations
            .translate('planItineraryEveningDescription')
            .replaceAll('{destination}', focusDestination),
      ),
    ];

    final styleTimes = ['15:00', '16:30', '18:00', '20:30'];
    final sortedStyles = _selectedStyles.toList()..sort();

    for (var index = 0; index < sortedStyles.length; index++) {
      final styleId = sortedStyles[index];
      final option = _findStyleOption(styleId);
      if (option == null) {
        continue;
      }
      entries.add(
        PlanItineraryEntry(
          time: styleTimes[index % styleTimes.length],
          title: localizations
              .translate(option.itineraryTitleKey)
              .replaceAll('{destination}', focusDestination),
          description: localizations
              .translate(option.itineraryDescriptionKey)
              .replaceAll('{destination}', focusDestination),
        ),
      );
    }

    return entries;
  }

  PlanStyleOption? _findStyleOption(String id) {
    for (final option in planStyleOptions) {
      if (option.id == id) {
        return option;
      }
    }
    return null;
  }

  String _formatBudgetValue(double value) {
    return value.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('planTitle')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            GlassSurface(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('planDestinationLabel'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: localizations.translate('planDestinationHint'),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassSurface(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('planDaysLabel'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: planWeekdayOptions.map((option) {
                      final isSelected = _selectedWeekdays.contains(option.value);
                      return ChoiceChip(
                        label: Text(localizations.translate(option.shortKey)),
                        selected: isSelected,
                        shape: const CircleBorder(),
                        onSelected: (_) => _toggleWeekday(option.value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassSurface(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('planBudgetLabel'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_formatBudgetValue(_budgetRange.start)} - ${_formatBudgetValue(_budgetRange.end)}',
                    style: theme.textTheme.titleMedium,
                  ),
                  RangeSlider(
                    values: _budgetRange,
                    min: 200,
                    max: 5000,
                    divisions: 48,
                    labels: RangeLabels(
                      _formatBudgetValue(_budgetRange.start),
                      _formatBudgetValue(_budgetRange.end),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _budgetRange = values;
                      });
                    },
                    onChangeEnd: (values) {
                      _prefsService?.savePlanBudgetRange(values);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GlassSurface(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('planTravelStyleLabel'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: planStyleOptions.map((option) {
                      final isSelected = _selectedStyles.contains(option.id);
                      return FilterChip(
                        label: Text(localizations.translate(option.translationKey)),
                        avatar: Icon(option.icon, size: 18),
                        selected: isSelected,
                        onSelected: (_) => _toggleStyle(option.id),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleGenerate,
                icon: const Icon(Icons.auto_awesome),
                label: Text(localizations.translate('planGenerateRoute')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
