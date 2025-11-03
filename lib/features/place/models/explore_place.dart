import 'package:flutter/foundation.dart';

@immutable
class ExplorePlace {
  const ExplorePlace({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.location,
    required this.distanceText,
    required this.rating,
    this.tags = const <String>[],
  });

  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String category;
  final String location;
  final String distanceText;
  final double rating;
  final List<String> tags;

  bool get isAiCurated => tags.contains('ai');

  bool get isHiddenGem => tags.contains('hidden');

  bool get isHero => tags.contains('hero');
}
