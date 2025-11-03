import 'package:flutter/material.dart';

enum SearchScope { places, food, events, cars }

extension SearchScopeX on SearchScope {
  String get localizationKey {
    switch (this) {
      case SearchScope.places:
        return 'searchScopePlaces';
      case SearchScope.food:
        return 'searchScopeFood';
      case SearchScope.events:
        return 'searchScopeEvents';
      case SearchScope.cars:
        return 'searchScopeCars';
    }
  }

  IconData get icon {
    switch (this) {
      case SearchScope.places:
        return Icons.landscape_rounded;
      case SearchScope.food:
        return Icons.restaurant_rounded;
      case SearchScope.events:
        return Icons.event_rounded;
      case SearchScope.cars:
        return Icons.directions_car_filled_rounded;
    }
  }
}

enum SearchSort { newest, nearest, highestRated, lowestPrice }

extension SearchSortX on SearchSort {
  String get localizationKey {
    switch (this) {
      case SearchSort.newest:
        return 'searchSortNewest';
      case SearchSort.nearest:
        return 'searchSortNearest';
      case SearchSort.highestRated:
        return 'searchSortHighestRated';
      case SearchSort.lowestPrice:
        return 'searchSortLowestPrice';
    }
  }
}

@immutable
class SearchEntry {
  const SearchEntry({
    required this.id,
    required this.scope,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.category,
    required this.rating,
    required this.price,
    required this.distanceKm,
    required this.addedAt,
    this.tags = const <String>[],
  });

  final String id;
  final SearchScope scope;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String location;
  final String category;
  final double rating;
  final double price;
  final double distanceKm;
  final DateTime addedAt;
  final List<String> tags;

  bool matchesQuery(String query) {
    final normalized = query.toLowerCase();
    return title.toLowerCase().contains(normalized) ||
        subtitle.toLowerCase().contains(normalized) ||
        description.toLowerCase().contains(normalized) ||
        location.toLowerCase().contains(normalized) ||
        category.toLowerCase().contains(normalized) ||
        tags.any((tag) => tag.toLowerCase().contains(normalized));
  }
}

@immutable
class SearchFilters {
  const SearchFilters({
    this.priceRange = const RangeValues(80, 1200),
    this.maxDistance = 120,
    this.minRating = 0,
    this.scopes = const <SearchScope>[
      SearchScope.places,
      SearchScope.food,
      SearchScope.events,
      SearchScope.cars,
    ],
    this.sort = SearchSort.newest,
  });

  final RangeValues priceRange;
  final double maxDistance;
  final double minRating;
  final List<SearchScope> scopes;
  final SearchSort sort;

  bool get showsAllScopes => scopes.length == SearchScope.values.length;

  SearchFilters copyWith({
    RangeValues? priceRange,
    double? maxDistance,
    double? minRating,
    List<SearchScope>? scopes,
    SearchSort? sort,
  }) {
    return SearchFilters(
      priceRange: priceRange ?? this.priceRange,
      maxDistance: maxDistance ?? this.maxDistance,
      minRating: minRating ?? this.minRating,
      scopes: scopes ?? this.scopes,
      sort: sort ?? this.sort,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'priceStart': priceRange.start,
      'priceEnd': priceRange.end,
      'maxDistance': maxDistance,
      'minRating': minRating,
      'scopes': scopes.map((scope) => scope.name).toList(),
      'sort': sort.name,
    };
  }

  factory SearchFilters.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const SearchFilters();
    }
    final start = (map['priceStart'] as num?)?.toDouble() ?? 80;
    final end = (map['priceEnd'] as num?)?.toDouble() ?? 1200;
    final maxDistance = (map['maxDistance'] as num?)?.toDouble() ?? 120;
    final minRating = (map['minRating'] as num?)?.toDouble() ?? 0;
    final scopesData = map['scopes'];
    List<SearchScope> scopes;
    if (scopesData is List) {
      scopes = scopesData
          .map((value) => SearchScope.values.firstWhere(
                (scope) => scope.name == value,
                orElse: () => SearchScope.places,
              ))
          .toSet()
          .toList();
    } else {
      scopes = const <SearchScope>[
        SearchScope.places,
        SearchScope.food,
        SearchScope.events,
        SearchScope.cars,
      ];
    }
    if (scopes.isEmpty) {
      scopes = const <SearchScope>[
        SearchScope.places,
        SearchScope.food,
        SearchScope.events,
        SearchScope.cars,
      ];
    }
    final sortName = map['sort'] as String?;
    final sort = SearchSort.values.firstWhere(
      (value) => value.name == sortName,
      orElse: () => SearchSort.newest,
    );
    return SearchFilters(
      priceRange: RangeValues(start, end),
      maxDistance: maxDistance,
      minRating: minRating,
      scopes: scopes,
      sort: sort,
    );
  }
}
