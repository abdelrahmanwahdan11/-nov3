import 'package:flutter/material.dart';

class PlanStyleOption {
  const PlanStyleOption({
    required this.id,
    required this.translationKey,
    required this.itineraryTitleKey,
    required this.itineraryDescriptionKey,
    required this.icon,
  });

  final String id;
  final String translationKey;
  final String itineraryTitleKey;
  final String itineraryDescriptionKey;
  final IconData icon;
}

class PlanWeekdayOption {
  const PlanWeekdayOption({
    required this.value,
    required this.shortKey,
    required this.fullKey,
  });

  final int value;
  final String shortKey;
  final String fullKey;
}

const List<PlanStyleOption> planStyleOptions = [
  PlanStyleOption(
    id: 'adventure',
    translationKey: 'planStyleAdventure',
    itineraryTitleKey: 'planItineraryAdventureTitle',
    itineraryDescriptionKey: 'planItineraryAdventureDescription',
    icon: Icons.terrain,
  ),
  PlanStyleOption(
    id: 'solo',
    translationKey: 'planStyleSolo',
    itineraryTitleKey: 'planItinerarySoloTitle',
    itineraryDescriptionKey: 'planItinerarySoloDescription',
    icon: Icons.person_outline,
  ),
  PlanStyleOption(
    id: 'road_trip',
    translationKey: 'planStyleRoadTrip',
    itineraryTitleKey: 'planItineraryRoadTitle',
    itineraryDescriptionKey: 'planItineraryRoadDescription',
    icon: Icons.route,
  ),
  PlanStyleOption(
    id: 'family',
    translationKey: 'planStyleFamily',
    itineraryTitleKey: 'planItineraryFamilyTitle',
    itineraryDescriptionKey: 'planItineraryFamilyDescription',
    icon: Icons.family_restroom,
  ),
];

const List<PlanWeekdayOption> planWeekdayOptions = [
  PlanWeekdayOption(
    value: DateTime.monday,
    shortKey: 'weekdayMonShort',
    fullKey: 'weekdayMonFull',
  ),
  PlanWeekdayOption(
    value: DateTime.tuesday,
    shortKey: 'weekdayTueShort',
    fullKey: 'weekdayTueFull',
  ),
  PlanWeekdayOption(
    value: DateTime.wednesday,
    shortKey: 'weekdayWedShort',
    fullKey: 'weekdayWedFull',
  ),
  PlanWeekdayOption(
    value: DateTime.thursday,
    shortKey: 'weekdayThuShort',
    fullKey: 'weekdayThuFull',
  ),
  PlanWeekdayOption(
    value: DateTime.friday,
    shortKey: 'weekdayFriShort',
    fullKey: 'weekdayFriFull',
  ),
  PlanWeekdayOption(
    value: DateTime.saturday,
    shortKey: 'weekdaySatShort',
    fullKey: 'weekdaySatFull',
  ),
  PlanWeekdayOption(
    value: DateTime.sunday,
    shortKey: 'weekdaySunShort',
    fullKey: 'weekdaySunFull',
  ),
];

class PlanItineraryEntry {
  const PlanItineraryEntry({
    required this.time,
    required this.title,
    required this.description,
  });

  final String time;
  final String title;
  final String description;
}

class TravelPlanSummaryArgs {
  const TravelPlanSummaryArgs({
    required this.destination,
    required this.selectedWeekdayIndexes,
    required this.budgetRange,
    required this.selectedStyleIds,
    required this.activities,
  });

  final String destination;
  final List<int> selectedWeekdayIndexes;
  final RangeValues budgetRange;
  final List<String> selectedStyleIds;
  final List<PlanItineraryEntry> activities;
}
