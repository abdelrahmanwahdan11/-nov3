import 'dart:ui';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

import 'package:travelmate/core/controllers/app_controller.dart';
import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/features/place/models/explore_place.dart';

class PlacePage extends StatefulWidget {
  const PlacePage({super.key});

  @override
  State<PlacePage> createState() => _PlacePageState();
}

class _PlacePageState extends State<PlacePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  bool _isFavorite = false;
  bool _isFollowing = false;
  AppController? _controller;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AppControllerScope.of(context);
    if (!identical(_controller, controller)) {
      _controller?.removeListener(_handleControllerChanged);
      _controller = controller;
      _controller?.addListener(_handleControllerChanged);
    }
    _syncFavoriteState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  void _handleControllerChanged() {
    if (!mounted) {
      return;
    }
    _syncFavoriteState();
  }

  void _syncFavoriteState() {
    final controller = _controller;
    final place = ModalRoute.of(context)?.settings.arguments as ExplorePlace?;
    if (controller == null || place == null) {
      return;
    }
    final isSaved = controller.isPlaceSaved(place.id);
    if (_isFavorite != isSaved) {
      setState(() {
        _isFavorite = isSaved;
      });
    }
  }

  Future<void> _toggleFavorite(ExplorePlace place) async {
    final controller = _controller;
    final target = !_isFavorite;
    setState(() {
      _isFavorite = target;
    });
    if (controller != null) {
      await controller.setPlaceSaved(place.id, target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final place = ModalRoute.of(context)?.settings.arguments as ExplorePlace?;
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (place == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.translate('placeTitle')),
        ),
        body: Center(
          child: GlassSurface(
            padding: const EdgeInsets.all(24),
            child: Text(
              localizations.translate('homeNoResults'),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      );
    }

    final media = MediaQuery.of(context);
    final expandedHeight = media.size.height * 0.7;
    final reviews = _buildReviews(localizations);
    final reviewSummary =
        '${reviews.length} ${localizations.translate('placeReviewsSuffix')}';
    final fadeAmount = (_scrollOffset / 180).clamp(0.0, 1.0);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: expandedHeight,
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: theme.colorScheme.onSurface,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: fadeAmount,
              child: Text(place.title),
            ),
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final delta =
                    (expandedHeight - kToolbarHeight).clamp(1.0, double.infinity);
                final t = ((height - kToolbarHeight) / delta).clamp(0.0, 1.0);
                final parallax = (expandedHeight - height) * 0.3;
                final blurSigma = lerpDouble(0, 10, 1 - t) ?? 0;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: place.id,
                      child: Transform.translate(
                        offset: Offset(0, parallax),
                        child: Image.network(
                          place.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25 * (1 - t)),
                            Colors.black.withOpacity(0.6 - (0.4 * t)),
                          ],
                        ),
                      ),
                    ),
                    ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: blurSigma,
                          sigmaY: blurSigma,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 32 + media.padding.bottom,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: t,
                        child: GlassSurface(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                place.title,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                place.subtitle,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    place.rating.toStringAsFixed(1),
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    reviewSummary,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1 - (fadeAmount * 0.35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _isFollowing = !_isFollowing;
                              });
                            },
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) => FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                              child: Text(
                                _isFollowing
                                    ? localizations.translate('placeFollowing')
                                    : localizations.translate('placeFollow'),
                                key: ValueKey<bool>(_isFollowing),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _toggleFavorite(place),
                          child: AnimatedScale(
                            scale: _isFavorite ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.elasticOut,
                            child: GlassSurface(
                              padding: const EdgeInsets.all(14),
                              radius: 20,
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildDetailChip(
                          theme,
                          Icons.place,
                          '${place.location} · ${place.distanceText}',
                        ),
                        _buildDetailChip(
                          theme,
                          Icons.category,
                          localizations.translate(_categoryKey(place.category)),
                        ),
                        _buildDetailChip(
                          theme,
                          Icons.map,
                          '${localizations.translate('placeAverageRatingLabel')} ${place.rating.toStringAsFixed(1)}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      localizations.translate('placeAbout'),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      place.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      localizations.translate('placeQuickTipsTitle'),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    FlipCard(
                      speed: 400,
                      front: GlassSurface(
                        padding: const EdgeInsets.all(24),
                        radius: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('placeQuickTipsFront'),
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.translate('placeQuickTipsHint'),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      back: GlassSurface(
                        padding: const EdgeInsets.all(24),
                        radius: 24,
                        child: Text(
                          localizations.translate('placeQuickTipsBack'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      localizations.translate('placeReviewsTitle'),
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...reviews.map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassSurface(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: theme.colorScheme.primary
                                        .withOpacity(0.15),
                                    child: Text(
                                      review.initials,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          review.name,
                                          style: theme.textTheme.titleMedium,
                                        ),
                                        Text(
                                          review.date,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        review.rating.toStringAsFixed(1),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                review.content,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: media.padding.bottom + 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_PlaceReview> _buildReviews(AppLocalizations localizations) {
    return [
      _PlaceReview(
        name: localizations.translate('placeReview1Name'),
        date: localizations.translate('placeReview1Date'),
        content: localizations.translate('placeReview1Content'),
        rating: 4.8,
      ),
      _PlaceReview(
        name: localizations.translate('placeReview2Name'),
        date: localizations.translate('placeReview2Date'),
        content: localizations.translate('placeReview2Content'),
        rating: 4.6,
      ),
      _PlaceReview(
        name: localizations.translate('placeReview3Name'),
        date: localizations.translate('placeReview3Date'),
        content: localizations.translate('placeReview3Content'),
        rating: 5.0,
      ),
    ];
  }

  Widget _buildDetailChip(ThemeData theme, IconData icon, String label) {
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      radius: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
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

class _PlaceReview {
  const _PlaceReview({
    required this.name,
    required this.date,
    required this.content,
    required this.rating,
  });

  final String name;
  final String date;
  final String content;
  final double rating;

  String get initials {
    final sanitized = name.trim();
    if (sanitized.isEmpty) {
      return '';
    }
    final parts = sanitized.split(RegExp(r'\s+'));
    String firstLetter(String value) {
      final iterator = value.runes.iterator;
      if (iterator.moveNext()) {
        return String.fromCharCode(iterator.current);
      }
      return '';
    }

    String firstTwoLetters(String value) {
      final iterator = value.runes.iterator;
      final buffer = StringBuffer();
      var count = 0;
      while (iterator.moveNext() && count < 2) {
        buffer.writeCharCode(iterator.current);
        count++;
      }
      return buffer.toString();
    }

    if (parts.length == 1) {
      final word = parts.first;
      return firstTwoLetters(word).toUpperCase();
    }

    final first = firstLetter(parts.first);
    final last = firstLetter(parts.last);
    return '$first$last'.toUpperCase();
  }
}
