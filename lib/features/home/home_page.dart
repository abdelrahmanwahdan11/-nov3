import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/core/utils/pagination_mixin.dart';
import 'package:travelmate/core/utils/skeleton.dart';
import 'package:travelmate/features/place/models/explore_place.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PaginationMixin<HomePage> {
  static const _categories = <String>['Must-See', 'Hidden Gem', 'Food & Café'];

  static const List<ExplorePlace> _mockPlaces = [
    ExplorePlace(
      id: 'aurora-cliffs',
      title: 'Aurora Cliffs',
      subtitle: 'Sun-drenched canyon lookout',
      description:
          'Hike the sandstone ridge for a sunrise panorama over ancient rock formations and hidden valleys.',
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'AlUla, Saudi Arabia',
      distanceText: '3.2 km',
      rating: 4.9,
      tags: ['hero', 'ai'],
    ),
    ExplorePlace(
      id: 'floating-garden',
      title: 'Floating Garden',
      subtitle: 'Glass observatory above the oasis',
      description:
          'Ride the sky elevator to a suspended botanical garden with curated exhibits and soft ambient music.',
      imageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Riyadh, Saudi Arabia',
      distanceText: '8.5 km',
      rating: 4.8,
      tags: ['ai'],
    ),
    ExplorePlace(
      id: 'midnight-souk',
      title: 'Midnight Souk',
      subtitle: 'Lantern-lit artisan market',
      description:
          'Discover handwoven textiles, oud fragrances, and street performances after dusk in a tucked-away market.',
      imageUrl:
          'https://images.unsplash.com/photo-1520357456838-1d93c1f0840d?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Jeddah, Saudi Arabia',
      distanceText: '2.1 km',
      rating: 4.7,
      tags: ['hidden'],
    ),
    ExplorePlace(
      id: 'whispering-dunes',
      title: 'Whispering Dunes',
      subtitle: 'Soundscape desert trek',
      description:
          'Guided evening walk where shifting dunes create natural melodies amplified by gentle desert winds.',
      imageUrl:
          'https://images.unsplash.com/photo-1500530855697-5fce5f43d0d2?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Empty Quarter, Saudi Arabia',
      distanceText: '42 km',
      rating: 4.6,
      tags: ['hidden', 'ai'],
    ),
    ExplorePlace(
      id: 'artisan-roastery',
      title: 'Artisan Roastery',
      subtitle: 'Slow-brew micro café',
      description:
          'Sip experimental blends crafted with single-origin beans while learning roasting techniques from baristas.',
      imageUrl:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1200&q=80',
      category: 'Food & Café',
      location: 'Diriyah, Saudi Arabia',
      distanceText: '5.4 km',
      rating: 4.5,
      tags: ['ai'],
    ),
    ExplorePlace(
      id: 'sky-terrace',
      title: 'Sky Terrace',
      subtitle: 'City skyline sunset deck',
      description:
          'Chill on a terraced rooftop with live oud sessions as the city lights flicker to life beneath you.',
      imageUrl:
          'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Khobar, Saudi Arabia',
      distanceText: '11 km',
      rating: 4.4,
    ),
    ExplorePlace(
      id: 'cinnamon-harbor',
      title: 'Cinnamon Harbor',
      subtitle: 'Floating spice kitchen',
      description:
          'Taste aromatic stews simmering on dhow boats while storytellers share seafaring tales.',
      imageUrl:
          'https://images.unsplash.com/photo-1466978913421-dad2ebd01d17?auto=format&fit=crop&w=1200&q=80',
      category: 'Food & Café',
      location: 'Al Bahah, Saudi Arabia',
      distanceText: '18 km',
      rating: 4.3,
    ),
    ExplorePlace(
      id: 'emerald-oasis',
      title: 'Emerald Oasis',
      subtitle: 'Hidden canyon lagoon',
      description:
          'Swim beneath natural waterfalls surrounded by palm groves and luminous limestone walls.',
      imageUrl:
          'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Najran, Saudi Arabia',
      distanceText: '65 km',
      rating: 4.8,
      tags: ['ai'],
    ),
    ExplorePlace(
      id: 'desert-library',
      title: 'Desert Library',
      subtitle: 'Nomadic pop-up book lounge',
      description:
          'Borrow limited-edition travelogues in a linen tent with mint tea service and ambient oud playlists.',
      imageUrl:
          'https://images.unsplash.com/photo-1477346611705-65d1883cee1e?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Hail, Saudi Arabia',
      distanceText: '24 km',
      rating: 4.6,
      tags: ['hidden'],
    ),
    ExplorePlace(
      id: 'lagoon-market',
      title: 'Lagoon Market',
      subtitle: 'Waterfront tasting trail',
      description:
          'Sample chef-led tasting menus as you stroll beside mirrored waters lit with floating lanterns.',
      imageUrl:
          'https://images.unsplash.com/photo-1498654200943-1088dd4438ae?auto=format&fit=crop&w=1200&q=80',
      category: 'Food & Café',
      location: 'Jazan, Saudi Arabia',
      distanceText: '14 km',
      rating: 4.2,
    ),
    ExplorePlace(
      id: 'crystal-cavern',
      title: 'Crystal Cavern',
      subtitle: 'Glowworm-lit underground lake',
      description:
          'Kayak silently through a cavern where bioluminescent crystals reflect on still waters.',
      imageUrl:
          'https://images.unsplash.com/photo-1464820453369-31d2c0b651af?auto=format&fit=crop&w=1200&q=80',
      category: 'Hidden Gem',
      location: 'Tabuk, Saudi Arabia',
      distanceText: '71 km',
      rating: 4.9,
      tags: ['hidden', 'ai'],
    ),
    ExplorePlace(
      id: 'luminous-steps',
      title: 'Luminous Steps',
      subtitle: 'Night-lit mountain trail',
      description:
          'Follow illuminated pathways up the ridge for stargazing pods and interactive constellation stories.',
      imageUrl:
          'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1200&q=80',
      category: 'Must-See',
      location: 'Abha, Saudi Arabia',
      distanceText: '33 km',
      rating: 4.7,
      tags: ['ai'],
    ),
  ];

  final List<ExplorePlace> _visiblePlaces = <ExplorePlace>[];
  String _selectedCategory = _categories.first;
  bool _isInitialLoading = true;

  @override
  int get pageSize => 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitial();
    });
  }

  List<ExplorePlace> get _filteredPlaces => _mockPlaces
      .where((place) => place.category == _selectedCategory)
      .toList();

  List<ExplorePlace> get _aiRoutePlaces =>
      _mockPlaces.where((place) => place.isAiCurated).toList();

  List<ExplorePlace> get _hiddenGemPlaces =>
      _mockPlaces.where((place) => place.category == 'Hidden Gem').toList();

  ExplorePlace? get _heroPlace {
    return _visiblePlaces.isNotEmpty
        ? _visiblePlaces.firstWhere(
            (place) => place.isHero,
            orElse: () => _visiblePlaces.first,
          )
        : null;
  }

  @override
  Future<void> loadInitial() async {
    setState(() {
      _isInitialLoading = true;
    });
    final filtered = _filteredPlaces;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    setState(() {
      _visiblePlaces
        ..clear()
        ..addAll(filtered.take(pageSize));
      hasMore = filtered.length > pageSize;
      page = 1;
      _isInitialLoading = false;
    });
  }

  @override
  Future<void> loadMore(int nextPage) async {
    final filtered = _filteredPlaces;
    final start = (nextPage - 1) * pageSize;
    if (start >= filtered.length) {
      if (mounted) {
        setState(() {
          hasMore = false;
        });
      }
      return;
    }
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    final end = math.min(start + pageSize, filtered.length);
    setState(() {
      _visiblePlaces.addAll(filtered.sublist(start, end));
      hasMore = end < filtered.length;
    });
  }

  Future<void> _handleRefresh() {
    return refresh();
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) {
      return;
    }
    setState(() {
      _selectedCategory = category;
    });
    refresh();
  }

  Future<void> _openSearch(AppLocalizations localizations) async {
    final result = await showSearch<ExplorePlace?>(
      context: context,
      delegate: ExploreSearchDelegate(
        localizations: localizations,
        places: _mockPlaces,
      ),
    );
    if (result != null) {
      _openPlace(result);
    }
  }

  void _openPlace(ExplorePlace place) {
    Navigator.of(context).pushNamed('/place', arguments: place);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final heroPlace = _heroPlace;
    final remainingPlaces = heroPlace == null
        ? _visiblePlaces
        : _visiblePlaces.where((p) => p != heroPlace).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('homeTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(localizations),
            tooltip: localizations.translate('homeSearchTooltip'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(theme, localizations),
                    const SizedBox(height: 16),
                    _buildCategoryChips(theme, localizations),
                    const SizedBox(height: 24),
                    if (_isInitialLoading)
                      const Skeleton(height: 220, borderRadius: 28)
                    else if (heroPlace != null)
                      _buildHeroCard(heroPlace, theme, localizations),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      localizations.translate('sectionAiRoute'),
                      theme,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _isInitialLoading
                          ? _buildHorizontalSkeletons()
                          : _buildAiRouteCarousel(theme, localizations),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionHeader(
                      localizations.translate('sectionHiddenGems'),
                      theme,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: _isInitialLoading
                          ? _buildHorizontalSkeletons()
                          : _buildHiddenGemsFlip(theme, localizations),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            if (_isInitialLoading)
              _buildLoadingList()
            else if (remainingPlaces.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassSurface(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      localizations.translate('homeEmptyCategory'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
              )
            else
              _buildPlacesList(remainingPlaces, theme, localizations),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () => _openSearch(localizations),
      child: GlassSurface(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.search, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizations.translate('homeSearchHint'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            Icon(Icons.tune, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ThemeData theme, AppLocalizations localizations) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(localizations.translate(_categoryKey(category))),
            selected: isSelected,
            onSelected: (_) => _onCategorySelected(category),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _categories.length,
      ),
    );
  }

  Widget _buildHeroCard(
    ExplorePlace place,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return GestureDetector(
      onTap: () => _openPlace(place),
      child: Hero(
        tag: place.id,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  place.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildBadge(
                          localizations.translate(_categoryKey(place.category)),
                          theme,
                        ),
                        _buildBadge(place.distanceText, theme),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      place.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, ThemeData theme) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      radius: 12,
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge,
    );
  }

  Widget _buildAiRouteCarousel(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final places = _aiRoutePlaces;
    if (places.isEmpty) {
      return Center(
        child: Text(localizations.translate('homeNoResults')),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final place = places[index];
        return SizedBox(
          width: 220,
          child: GlassSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      place.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  place.title,
                  style: theme.textTheme.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  place.subtitle,
                  style: theme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _openPlace(place),
                  child: Text(localizations.translate('homeViewPlace')),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: places.length,
    );
  }

  Widget _buildHiddenGemsFlip(
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    final gems = _hiddenGemPlaces;
    if (gems.isEmpty) {
      return Center(
        child: Text(localizations.translate('homeNoResults')),
      );
    }
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        final place = gems[index];
        return SizedBox(
          width: 200,
          child: FlipCard(
            direction: FlipDirection.HORIZONTAL,
            front: GlassSurface(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        place.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    place.title,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.location,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            back: GlassSurface(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('homeHiddenGemInsight'),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      place.description,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: TextButton(
                      onPressed: () => _openPlace(place),
                      child: Text(localizations.translate('homeViewPlace')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: gems.length,
    );
    }

  Widget _buildPlacesList(
    List<ExplorePlace> places,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= places.length) {
            return _buildLoadMoreIndicator();
          }
          final place = places[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _openPlace(place),
              child: GlassSurface(
                radius: 24,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Hero(
                      tag: place.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          place.imageUrl,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.title,
                            style: theme.textTheme.bodyLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place.subtitle,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.place,
                                  size: 18,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${place.location} · ${place.distanceText}',
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(Icons.star, color: theme.colorScheme.primary),
                        Text(place.rating.toStringAsFixed(1)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: places.length + (isLoadingMore ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadingList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Skeleton(height: 120, borderRadius: 24),
          );
        },
        childCount: 4,
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!hasMore && !isLoadingMore) {
      return const SizedBox.shrink();
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildHorizontalSkeletons() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return const Skeleton(width: 200, height: 200, borderRadius: 24);
      },
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemCount: 3,
    );
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

class ExploreSearchDelegate extends SearchDelegate<ExplorePlace?> {
  ExploreSearchDelegate({
    required this.localizations,
    required this.places,
  }) : super(searchFieldLabel: localizations.translate('homeSearchHint'));

  final AppLocalizations localizations;
  final List<ExplorePlace> places;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResultList(_filterPlaces());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildResultList(places.take(5).toList());
    }
    return _buildResultList(_filterPlaces());
  }

  List<ExplorePlace> _filterPlaces() {
    final lowerQuery = query.toLowerCase();
    return places.where((place) {
      return place.title.toLowerCase().contains(lowerQuery) ||
          place.subtitle.toLowerCase().contains(lowerQuery) ||
          place.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Widget _buildResultList(List<ExplorePlace> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(localizations.translate('homeNoResults')),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      itemBuilder: (context, index) {
        final place = results[index];
        return ListTile(
          onTap: () => close(context, place),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              place.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(place.title),
          subtitle: Text(
            '${place.location} · ${localizations.translate(_categoryKey(place.category))}',
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: results.length,
    );
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
