import 'package:flutter/material.dart';

mixin PaginationMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  bool hasMore = true;
  int page = 1;

  int _loadGeneration = 0;

  int get pageSize => 20;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  @protected
  int startNewLoadCycle() {
    _loadGeneration += 1;
    return _loadGeneration;
  }

  @protected
  int get currentLoadGeneration => _loadGeneration;

  @protected
  bool isActiveGeneration(int generation) => generation == _loadGeneration;

  @protected
  Future<void> loadInitial({required int generation});

  @protected
  Future<void> loadMore({required int nextPage, required int generation});

  Future<void> refresh() async {
    final generation = startNewLoadCycle();
    if (mounted) {
      setState(() {
        page = 1;
        hasMore = true;
        isLoadingMore = false;
      });
    } else {
      page = 1;
      hasMore = true;
      isLoadingMore = false;
    }
    await loadInitial(generation: generation);
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoadingMore || !hasMore) {
      return;
    }
    final position = scrollController.position;
    final triggerOffset =
        position.maxScrollExtent - (position.viewportDimension * 0.5);
    if (position.pixels >= triggerOffset) {
      _requestNextPage();
    }
  }

  Future<void> _requestNextPage() async {
    if (isLoadingMore || !hasMore) {
      return;
    }
    if (mounted) {
      setState(() {
        isLoadingMore = true;
      });
    } else {
      isLoadingMore = true;
    }
    final nextPage = page + 1;
    final generation = _loadGeneration;
    await loadMore(nextPage: nextPage, generation: generation);
    if (!mounted || !isActiveGeneration(generation)) {
      isLoadingMore = false;
      return;
    }
    setState(() {
      page = nextPage;
      isLoadingMore = false;
    });
  }

  Widget buildPaginationFooter(
    BuildContext context, {
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(vertical: 24),
  }) {
    final resolved = padding.resolve(Directionality.of(context));
    final spacerHeight = resolved.top + resolved.bottom;
    return SliverToBoxAdapter(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isLoadingMore
            ? Padding(
                key: const ValueKey('pagination_loader'),
                padding: padding,
                child: const Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              )
            : SizedBox(
                key: const ValueKey('pagination_spacer'),
                height: spacerHeight > 0 ? spacerHeight : 12,
              ),
      ),
    );
  }
}
