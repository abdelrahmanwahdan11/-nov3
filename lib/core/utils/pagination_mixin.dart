import 'package:flutter/material.dart';

mixin PaginationMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  bool hasMore = true;
  int page = 1;

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

  Future<void> loadInitial();
  Future<void> loadMore(int nextPage);

  Future<void> refresh() async {
    page = 1;
    hasMore = true;
    await loadInitial();
  }

  void _onScroll() {
    if (!scrollController.hasClients || isLoadingMore || !hasMore) {
      return;
    }
    final threshold = scrollController.position.maxScrollExtent * 0.8;
    if (scrollController.position.pixels > threshold) {
      _requestNextPage();
    }
  }

  Future<void> _requestNextPage() async {
    if (isLoadingMore || !hasMore) {
      return;
    }
    setState(() {
      isLoadingMore = true;
    });
    final nextPage = page + 1;
    await loadMore(nextPage);
    setState(() {
      page = nextPage;
      isLoadingMore = false;
    });
  }
}
