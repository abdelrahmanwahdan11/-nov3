import 'dart:math';

import 'package:travelmate/features/home/explore_mock_data.dart';
import 'package:travelmate/features/place/models/explore_place.dart';

import 'search_models.dart';

class SearchRepository {
  const SearchRepository._();

  static final List<SearchEntry> _entries = _buildEntries();

  static List<SearchEntry> get entries => List<SearchEntry>.unmodifiable(_entries);

  static List<SearchEntry> search({
    required String query,
    required SearchFilters filters,
  }) {
    final normalized = query.trim().toLowerCase();
    Iterable<SearchEntry> results = _entries.where(
      (entry) => filters.scopes.contains(entry.scope),
    );
    results = results.where((entry) {
      return entry.price >= filters.priceRange.start &&
          entry.price <= filters.priceRange.end &&
          entry.distanceKm <= filters.maxDistance &&
          entry.rating >= filters.minRating;
    });
    if (normalized.isNotEmpty) {
      results = results.where((entry) => entry.matchesQuery(normalized));
    }
    final sorted = List<SearchEntry>.from(results);
    sorted.sort((a, b) {
      switch (filters.sort) {
        case SearchSort.newest:
          return b.addedAt.compareTo(a.addedAt);
        case SearchSort.nearest:
          return a.distanceKm.compareTo(b.distanceKm);
        case SearchSort.highestRated:
          return b.rating.compareTo(a.rating);
        case SearchSort.lowestPrice:
          return a.price.compareTo(b.price);
      }
    });
    return sorted;
  }

  static List<SearchEntry> suggestions({
    required String query,
    required SearchFilters filters,
    int limit = 6,
  }) {
    if (query.isEmpty) {
      return search(query: '', filters: filters).take(limit).toList();
    }
    return search(query: query, filters: filters).take(limit).toList();
  }

  static Map<SearchScope, List<SearchEntry>> groupByScope(List<SearchEntry> items) {
    final map = <SearchScope, List<SearchEntry>>{};
    for (final scope in SearchScope.values) {
      map[scope] = <SearchEntry>[];
    }
    for (final entry in items) {
      map[entry.scope]!.add(entry);
    }
    map.removeWhere((_, value) => value.isEmpty);
    return map;
  }

  static List<SearchEntry> _buildEntries() {
    final now = DateTime.now();
    final random = Random(42);
    final entries = <SearchEntry>[];

    double _parseDistance(ExplorePlace place) {
      final value = double.tryParse(place.distanceText.split(' ').first);
      return value ?? 12;
    }

    double _generatePrice(ExplorePlace place) {
      final base = place.category == 'Food & Café' ? 65 : 140;
      return (base + _parseDistance(place) * random.nextDouble() * 8)
          .clamp(40, 1600);
    }

    for (var i = 0; i < ExploreMockData.places.length; i++) {
      final place = ExploreMockData.places[i];
      final scope = place.category == 'Food & Café'
          ? SearchScope.food
          : SearchScope.places;
      entries.add(
        SearchEntry(
          id: place.id,
          scope: scope,
          title: place.title,
          subtitle: place.subtitle,
          description: place.description,
          imageUrl: place.imageUrl,
          location: place.location,
          category: place.category,
          rating: place.rating,
          price: double.parse(_generatePrice(place).toStringAsFixed(2)),
          distanceKm: double.parse(_parseDistance(place).toStringAsFixed(1)),
          addedAt: now.subtract(Duration(days: i)),
          tags: place.tags,
        ),
      );
    }

    entries.addAll(_eventEntries(now));
    entries.addAll(_carEntries(now));
    return entries;
  }

  static List<SearchEntry> _eventEntries(DateTime now) {
    return [
      SearchEntry(
        id: 'dune-festival',
        scope: SearchScope.events,
        title: 'Dune Echo Festival',
        subtitle: 'Immersive light and sound in the dunes',
        description:
            'A multi-night art experience featuring projection mapping, live oud, and culinary pop-ups under the stars.',
        imageUrl:
            'https://images.unsplash.com/photo-1500530855697-0e4ef6c1dc18?auto=format&fit=crop&w=1200&q=80',
        location: 'AlUla, Saudi Arabia',
        category: 'Festival',
        rating: 4.8,
        price: 320,
        distanceKm: 24,
        addedAt: now.subtract(const Duration(days: 2)),
        tags: const ['festival', 'music', 'art'],
      ),
      SearchEntry(
        id: 'oasis-wellness-days',
        scope: SearchScope.events,
        title: 'Oasis Wellness Days',
        subtitle: 'Mindful retreats in palm groves',
        description:
            'Guided breathwork, sunrise yoga, and sound baths hosted in a serene palm grove with local healers.',
        imageUrl:
            'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=1200&q=80',
        location: 'Al Ahsa, Saudi Arabia',
        category: 'Retreat',
        rating: 4.6,
        price: 280,
        distanceKm: 18,
        addedAt: now.subtract(const Duration(days: 6)),
        tags: const ['wellness', 'mindful'],
      ),
      SearchEntry(
        id: 'midnight-rally',
        scope: SearchScope.events,
        title: 'Midnight Desert Rally',
        subtitle: 'Night drive adventure with star mapping',
        description:
            'Join guided night drives across rolling dunes, with astrophotography workshops and live astronomy sessions.',
        imageUrl:
            'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=80',
        location: 'Riyadh, Saudi Arabia',
        category: 'Adventure',
        rating: 4.7,
        price: 450,
        distanceKm: 42,
        addedAt: now.subtract(const Duration(days: 4)),
        tags: const ['adventure', 'drive'],
      ),
    ];
  }

  static List<SearchEntry> _carEntries(DateTime now) {
    return [
      SearchEntry(
        id: 'falcon-xr',
        scope: SearchScope.cars,
        title: 'Falcon XR Desert Edition',
        subtitle: 'Electric 4x4 with adaptive suspension',
        description:
            'Limited-run Falcon XR with glass cockpit, 600km range, adaptive dune suspension, and smart caravan mode.',
        imageUrl:
            'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80',
        location: 'Jeddah Showroom',
        category: 'Electric',
        rating: 4.9,
        price: 186000,
        distanceKm: 12,
        addedAt: now.subtract(const Duration(days: 1)),
        tags: const ['ev', '4x4', 'luxury'],
      ),
      SearchEntry(
        id: 'sahara-cruiser',
        scope: SearchScope.cars,
        title: 'Sahara Cruiser Elite',
        subtitle: 'Twin-motor hybrid for roadtrips',
        description:
            'Hybrid SUV with panoramic roof, self-parking trailer assist, and AI route planning for cross-country journeys.',
        imageUrl:
            'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=1200&q=80',
        location: 'Riyadh Flagship',
        category: 'Hybrid',
        rating: 4.7,
        price: 158000,
        distanceKm: 6,
        addedAt: now.subtract(const Duration(days: 3)),
        tags: const ['hybrid', 'family'],
      ),
      SearchEntry(
        id: 'dune-runner',
        scope: SearchScope.cars,
        title: 'Dune Runner RZ',
        subtitle: 'Performance buggy for sand lovers',
        description:
            'Lightweight carbon frame buggy with 0-100 in 4.1s, kinetic seats, and AR trail heads-up display.',
        imageUrl:
            'https://images.unsplash.com/photo-1549923746-c502d488b3ea?auto=format&fit=crop&w=1200&q=80',
        location: 'Dhahran Experience Center',
        category: 'Performance',
        rating: 4.6,
        price: 92000,
        distanceKm: 28,
        addedAt: now.subtract(const Duration(days: 5)),
        tags: const ['performance', 'offroad'],
      ),
    ];
  }
}
