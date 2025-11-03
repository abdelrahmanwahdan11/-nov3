import 'package:flutter/widgets.dart';

mixin ImagePrefetchMixin<T extends StatefulWidget> on State<T> {
  final Set<String> _prefetchedUrls = <String>{};
  final List<String> _queuedUrls = <String>[];
  bool _prefetchScheduled = false;

  @protected
  void prefetchImages(Iterable<String> urls) {
    if (!mounted) {
      return;
    }
    for (final url in urls) {
      if (url.isEmpty) {
        continue;
      }
      if (_prefetchedUrls.contains(url) || _queuedUrls.contains(url)) {
        continue;
      }
      _queuedUrls.add(url);
    }
    if (_queuedUrls.isEmpty || _prefetchScheduled) {
      return;
    }
    _prefetchScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _queuedUrls.clear();
        _prefetchScheduled = false;
        return;
      }
      final pending = List<String>.from(_queuedUrls);
      _queuedUrls.clear();
      for (final url in pending) {
        precacheImage(NetworkImage(url), context);
        _prefetchedUrls.add(url);
      }
      _prefetchScheduled = false;
    });
  }

  @protected
  void resetPrefetchedImages({Iterable<String>? keep}) {
    _prefetchedUrls
      ..clear()
      ..addAll(keep ?? const <String>[]);
  }
}
