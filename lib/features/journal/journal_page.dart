import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import 'package:travelmate/core/localization/app_localizations.dart';
import 'package:travelmate/core/prefs/prefs_service.dart';
import 'package:travelmate/core/theme/theme.dart';
import 'package:travelmate/core/utils/image_prefetch_mixin.dart';
import 'package:travelmate/core/utils/skeleton.dart';
import 'package:travelmate/features/journal/journal_models.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage>
    with ImagePrefetchMixin<JournalPage> {
  late final ValueNotifier<JournalViewMode> _modeNotifier;
  late final ValueNotifier<List<JournalEntry>> _entriesNotifier;
  late final PageController _storyController;

  PrefsService? _prefsService;
  bool _isLoading = true;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _modeNotifier = ValueNotifier<JournalViewMode>(JournalViewMode.timeline);
    _entriesNotifier = ValueNotifier<List<JournalEntry>>(<JournalEntry>[]);
    _storyController = PageController(viewportFraction: 0.86);
    _loadEntries();
  }

  @override
  void dispose() {
    _modeNotifier.dispose();
    _entriesNotifier.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final generation = ++_loadGeneration;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    } else {
      _isLoading = true;
    }
    resetPrefetchedImages();

    final prefs = await PrefsService.getInstance();
    if (!mounted || generation != _loadGeneration) {
      return;
    }

    final stored = prefs.loadJournalEntries();
    List<JournalEntry> entries;

    if (stored.isEmpty) {
      final localizations = AppLocalizations.of(context);
      entries = _seedEntries(localizations);
      await prefs.saveJournalEntries(
        entries.map((entry) => entry.toJson()).toList(),
      );
    } else {
      entries = stored
          .map((data) => JournalEntry.fromJson(data))
          .where((entry) => entry.moments.isNotEmpty)
          .toList();
    }

    if (!mounted || generation != _loadGeneration) {
      return;
    }

    setState(() {
      _prefsService = prefs;
      _isLoading = false;
    });
    _setEntries(entries);
  }

  void _setEntries(List<JournalEntry> entries) {
    _entriesNotifier.value = entries;
    prefetchImages(entries.expand(
      (entry) => entry.moments.expand((moment) => moment.imageUrls),
    ));
  }

  List<JournalEntry> _seedEntries(AppLocalizations localizations) {
    return <JournalEntry>[
      JournalEntry(
        id: 'atlas_trail',
        title: localizations.translate('journalSeedAtlasTitle'),
        location: localizations.translate('journalSeedAtlasLocation'),
        date: DateTime.now().subtract(const Duration(days: 2)),
        notes: localizations.translate('journalSeedAtlasNotes'),
        moments: <JournalMoment>[
          JournalMoment(
            id: 'atlas_sunrise',
            title: localizations.translate('journalSeedAtlasMomentSunriseTitle'),
            time: '07:10',
            description:
                localizations.translate('journalSeedAtlasMomentSunriseDesc'),
            imageUrls: const <String>[
              'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429',
            ],
          ),
          JournalMoment(
            id: 'atlas_midday',
            title: localizations.translate('journalSeedAtlasMomentMiddayTitle'),
            time: '12:45',
            description:
                localizations.translate('journalSeedAtlasMomentMiddayDesc'),
            imageUrls: const <String>[
              'https://images.unsplash.com/photo-1469474968028-56623f02e42e',
              'https://images.unsplash.com/photo-1500534623283-312aade485b7',
            ],
          ),
        ],
        isSaved: true,
      ),
      JournalEntry(
        id: 'coastal_diary',
        title: localizations.translate('journalSeedCoastTitle'),
        location: localizations.translate('journalSeedCoastLocation'),
        date: DateTime.now().subtract(const Duration(days: 12)),
        notes: localizations.translate('journalSeedCoastNotes'),
        moments: <JournalMoment>[
          JournalMoment(
            id: 'coast_brunch',
            title: localizations.translate('journalSeedCoastMomentBrunchTitle'),
            time: '10:30',
            description:
                localizations.translate('journalSeedCoastMomentBrunchDesc'),
            imageUrls: const <String>[
              'https://images.unsplash.com/photo-1525182008055-f88b95ff7980',
            ],
          ),
          JournalMoment(
            id: 'coast_sunset',
            title: localizations.translate('journalSeedCoastMomentSunsetTitle'),
            time: '18:55',
            description:
                localizations.translate('journalSeedCoastMomentSunsetDesc'),
            imageUrls: const <String>[
              'https://images.unsplash.com/photo-1493558103817-58b2924bce98',
              'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
            ],
          ),
        ],
      ),
    ];
  }

  Future<void> _persistEntries(List<JournalEntry> entries) async {
    final prefs = _prefsService;
    if (prefs == null) {
      return;
    }
    await prefs.saveJournalEntries(entries.map((e) => e.toJson()).toList());
  }

  void _replaceEntry(JournalEntry entry) {
    final updated = _entriesNotifier.value.map((current) {
      if (current.id == entry.id) {
        return entry;
      }
      return current;
    }).toList();
    _setEntries(updated);
    _persistEntries(updated);
  }

  void _removeEntry(String id) {
    final updated =
        _entriesNotifier.value.where((entry) => entry.id != id).toList();
    _setEntries(updated);
    _persistEntries(updated);
  }

  Future<void> _toggleSaved(JournalEntry entry) async {
    _replaceEntry(entry.copyWith(isSaved: !entry.isSaved));
  }

  Future<void> _toggleLiked(JournalEntry entry) async {
    _replaceEntry(entry.copyWith(isLiked: !entry.isLiked));
  }

  Future<void> _shareEntry(BuildContext context, JournalEntry entry) async {
    final localizations = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          localizations
              .translate('journalShareMessage')
              .replaceAll('{title}', entry.title),
        ),
      ),
    );
  }

  Future<void> _promptAddPhoto(
    BuildContext context,
    JournalEntry entry,
    JournalMoment moment,
  ) async {
    final localizations = AppLocalizations.of(context);
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.translate('journalAddPhotoTitle')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: localizations.translate('journalAddPhotoHint'),
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  return;
                }
                Navigator.of(dialogContext).pop(value);
              },
              child: Text(localizations.translate('apply')),
            ),
          ],
        );
      },
    );

    if (url == null || url.isEmpty) {
      return;
    }

    final updatedMoment = moment.copyWith(
      imageUrls: <String>[...moment.imageUrls, url],
    );
    final updatedEntry = entry.copyWith(
      moments: entry.moments.map((current) {
        if (current.id == moment.id) {
          return updatedMoment;
        }
        return current;
      }).toList(),
    );
    _replaceEntry(updatedEntry);
  }

  Future<void> _removePhoto(
    BuildContext context,
    JournalEntry entry,
    JournalMoment moment,
    String url,
  ) async {
    final localizations = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.translate('journalRemovePhotoTitle')),
          content: Text(localizations.translate('journalRemovePhotoBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(localizations.translate('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(localizations.translate('journalRemovePhotoConfirm')),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    final updatedMoment = moment.copyWith(
      imageUrls:
          moment.imageUrls.where((currentUrl) => currentUrl != url).toList(),
    );
    final updatedEntry = entry.copyWith(
      moments: entry.moments.map((current) {
        if (current.id == moment.id) {
          return updatedMoment;
        }
        return current;
      }).toList(),
    );
    _replaceEntry(updatedEntry);
  }

  Future<void> _showCreateEntrySheet() async {
    final localizations = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final highlightController = TextEditingController();
    final timeController = TextEditingController(text: '09:00');
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    final entry = await showModalBottomSheet<JournalEntry>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              final localizations = AppLocalizations.of(context);
              final materialLocalizations = MaterialLocalizations.of(context);
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        localizations.translate('journalAddTripTitle'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText:
                              localizations.translate('journalTitleField'),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localizations
                                .translate('journalFieldRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText:
                              localizations.translate('journalLocationField'),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localizations
                                .translate('journalFieldRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today_rounded),
                        title: Text(localizations.translate('journalDateLabel')),
                        subtitle: Text(
                          materialLocalizations.formatMediumDate(selectedDate),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2015),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setSheetState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.translate('journalMomentSectionTitle'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: highlightController,
                        decoration: InputDecoration(
                          labelText: localizations
                              .translate('journalMomentTitleField'),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return localizations
                                .translate('journalFieldRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: timeController,
                        decoration: InputDecoration(
                          labelText:
                              localizations.translate('journalMomentTimeField'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: localizations
                              .translate('journalMomentDescriptionField'),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: imageController,
                        decoration: InputDecoration(
                          labelText:
                              localizations.translate('journalImageUrlField'),
                        ),
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          final moment = JournalMoment(
                            id: 'moment_${DateTime.now().microsecondsSinceEpoch}',
                            title: highlightController.text.trim(),
                            time: timeController.text.trim(),
                            description: descriptionController.text.trim(),
                            imageUrls: imageController.text.trim().isEmpty
                                ? <String>[]
                                : <String>[imageController.text.trim()],
                          );
                          Navigator.of(context).pop(
                            JournalEntry(
                              id: 'entry_${DateTime.now().microsecondsSinceEpoch}',
                              title: titleController.text.trim(),
                              location: locationController.text.trim(),
                              date: selectedDate,
                              notes: descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                              moments: <JournalMoment>[moment],
                              isSaved: true,
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label:
                            Text(localizations.translate('journalCreateTrip')),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );

  if (entry == null) {
    return;
  }

  final updated = <JournalEntry>[entry, ..._entriesNotifier.value];
    _setEntries(updated);
    await _persistEntries(updated);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('journalTitle')),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ValueListenableBuilder<JournalViewMode>(
              valueListenable: _modeNotifier,
              builder: (context, mode, _) {
                return SegmentedButton<JournalViewMode>(
                  segments: <ButtonSegment<JournalViewMode>>[
                    ButtonSegment<JournalViewMode>(
                      value: JournalViewMode.timeline,
                      icon: const Icon(Icons.timeline),
                      label: Text(
                        localizations.translate('journalTimeline'),
                      ),
                    ),
                    ButtonSegment<JournalViewMode>(
                      value: JournalViewMode.story,
                      icon: const Icon(Icons.collections_bookmark_outlined),
                      label: Text(
                        localizations.translate('journalStoryMode'),
                      ),
                    ),
                  ],
                  selected: <JournalViewMode>{mode},
                  onSelectionChanged: (selection) {
                    final target = selection.first;
                    _modeNotifier.value = target;
                    if (target == JournalViewMode.story) {
                      _storyController.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? SkeletonList.vertical(
              itemCount: 4,
              height: 180,
              borderRadius: 28,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ValueListenableBuilder<List<JournalEntry>>(
                valueListenable: _entriesNotifier,
                builder: (context, entries, _) {
                  return ValueListenableBuilder<JournalViewMode>(
                    valueListenable: _modeNotifier,
                    builder: (context, mode, __) {
                      if (entries.isEmpty) {
                        return Center(
                          child: GlassSurface(
                            padding: const EdgeInsets.all(32),
                            child: Text(
                              localizations.translate('journalEmptyState'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        );
                      }
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: mode == JournalViewMode.timeline
                            ? _TimelineList(
                                key: const ValueKey('timeline'),
                                entries: entries,
                                onToggleSaved: _toggleSaved,
                                onToggleLiked: _toggleLiked,
                                onShare: _shareEntry,
                                onAddPhoto: _promptAddPhoto,
                                onRemovePhoto: _removePhoto,
                                entriesNotifier: _entriesNotifier,
                              )
                            : _StoryModeView(
                                key: const ValueKey('story'),
                                controller: _storyController,
                                entries: entries,
                                entriesNotifier: _entriesNotifier,
                                onToggleSaved: _toggleSaved,
                                onToggleLiked: _toggleLiked,
                                onShare: _shareEntry,
                                onAddPhoto: _promptAddPhoto,
                                onRemovePhoto: _removePhoto,
                                onRemoveEntry: _removeEntry,
                              ),
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateEntrySheet,
        icon: const Icon(Icons.add),
        label: Text(localizations.translate('journalAddEntry')),
      ),
    );
  }
}

class _TimelineList extends StatelessWidget {
  const _TimelineList({
    super.key,
    required this.entries,
    required this.onToggleSaved,
    required this.onToggleLiked,
    required this.onShare,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.entriesNotifier,
  });

  final List<JournalEntry> entries;
  final Future<void> Function(JournalEntry entry) onToggleSaved;
  final Future<void> Function(JournalEntry entry) onToggleLiked;
  final Future<void> Function(BuildContext context, JournalEntry entry) onShare;
  final Future<void> Function(
    BuildContext context,
    JournalEntry entry,
    JournalMoment moment,
  ) onAddPhoto;
  final Future<void> Function(
    BuildContext context,
    JournalEntry entry,
    JournalMoment moment,
    String url,
  ) onRemovePhoto;
  final ValueListenable<List<JournalEntry>> entriesNotifier;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final heroTag = 'journal_${entry.id}_cover';
        return OpenContainer<void>(
          transitionType: ContainerTransitionType.fadeThrough,
          openBuilder: (context, _) => JournalEntryDetailView(
            entryId: entry.id,
            heroTag: heroTag,
            entriesListenable: entriesNotifier,
            onToggleSaved: onToggleSaved,
            onToggleLiked: onToggleLiked,
            onShare: onShare,
            onAddPhoto: onAddPhoto,
            onRemovePhoto: onRemovePhoto,
          ),
          closedElevation: 0,
          openElevation: 0,
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          closedBuilder: (context, openContainer) {
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: openContainer,
                borderRadius: BorderRadius.circular(28),
                child: GlassSurface(
                  radius: 28,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.title,
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  entry.location,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  MaterialLocalizations.of(context)
                                      .formatMediumDate(entry.date),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _JournalActions(
                                entry: entry,
                                onToggleSaved: onToggleSaved,
                                onToggleLiked: onToggleLiked,
                                onShare: onShare,
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (entry.coverImage != null) ...[
                        const SizedBox(height: 16),
                        Hero(
                          tag: heroTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                entry.coverImage!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) {
                                    return child;
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, _, __) {
                                  return _ImagePlaceholder(
                                    label: localizations
                                        .translate('journalImageFallback'),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          entry.notes!,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                      const SizedBox(height: 20),
                      ..._buildMoments(
                        context,
                        entry,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildMoments(
    BuildContext context,
    JournalEntry entry,
  ) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final children = <Widget>[];
    for (var index = 0; index < entry.moments.length; index++) {
      final moment = entry.moments[index];
      final isLast = index == entry.moments.length - 1;
      children.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (moment.time.isNotEmpty)
                        Text(
                          moment.time,
                          style: theme.textTheme.labelLarge,
                        ),
                      if (moment.time.isNotEmpty) const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          moment.title,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  if (moment.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      moment.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (moment.imageUrls.isNotEmpty)
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: moment.imageUrls.map((url) {
                        return _RemovableImage(
                          url: url,
                          onRemove: () => onRemovePhoto(
                            context,
                            entry,
                            moment,
                            url,
                          ),
                          fallbackLabel: localizations
                              .translate('journalImageFallback'),
                        );
                      }).toList(),
                    ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => onAddPhoto(context, entry, moment),
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(
                        localizations.translate('journalAddPhotoButton'),
                      ),
                    ),
                  ),
                  if (!isLast) const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return children;
  }
}

class _StoryModeView extends StatelessWidget {
  const _StoryModeView({
    super.key,
    required this.controller,
    required this.entries,
    required this.entriesNotifier,
    required this.onToggleSaved,
    required this.onToggleLiked,
    required this.onShare,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.onRemoveEntry,
  });

  final PageController controller;
  final List<JournalEntry> entries;
  final ValueListenable<List<JournalEntry>> entriesNotifier;
  final Future<void> Function(JournalEntry entry) onToggleSaved;
  final Future<void> Function(JournalEntry entry) onToggleLiked;
  final Future<void> Function(BuildContext context, JournalEntry entry) onShare;
  final Future<void> Function(
    BuildContext context,
    JournalEntry entry,
    JournalMoment moment,
  ) onAddPhoto;
  final Future<void> Function(
    BuildContext context,
    JournalEntry entry,
    JournalMoment moment,
    String url,
  ) onRemovePhoto;
  final void Function(String id) onRemoveEntry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return PageView.builder(
      controller: controller,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final heroTag = 'journal_${entry.id}_cover';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: OpenContainer<void>(
            transitionType: ContainerTransitionType.fadeThrough,
            openBuilder: (context, _) => JournalEntryDetailView(
              entryId: entry.id,
              heroTag: heroTag,
              entriesListenable: entriesNotifier,
              onToggleSaved: onToggleSaved,
              onToggleLiked: onToggleLiked,
              onShare: onShare,
              onAddPhoto: onAddPhoto,
              onRemovePhoto: onRemovePhoto,
            ),
            closedElevation: 0,
            openElevation: 0,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            closedBuilder: (context, openContainer) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onLongPress: () => _showRemoveDialog(
                    context,
                    entry,
                    onRemoveEntry,
                    localizations,
                  ),
                  onTap: openContainer,
                  borderRadius: BorderRadius.circular(32),
                  child: GlassSurface(
                    radius: 32,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: heroTag,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: entry.coverImage != null
                                  ? Image.network(
                                      entry.coverImage!,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder: (context, _, __) {
                                        return _ImagePlaceholder(
                                          label: localizations
                                              .translate('journalImageFallback'),
                                        );
                                      },
                                    )
                                  : _ImagePlaceholder(
                                      label: localizations
                                          .translate('journalNoImage'),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.location,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                        const SizedBox(height: 16),
                        _JournalActions(
                          entry: entry,
                          onToggleSaved: onToggleSaved,
                          onToggleLiked: onToggleLiked,
                          onShare: onShare,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.translate('journalStoryHint'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showRemoveDialog(
    BuildContext context,
    JournalEntry entry,
    void Function(String id) onRemoveEntry,
    AppLocalizations localizations,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(localizations.translate('journalRemoveEntryTitle')),
          content: Text(localizations.translate('journalRemoveEntryBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(localizations.translate('cancel')),
            ),
            FilledButton(
              onPressed: () {
                onRemoveEntry(entry.id);
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                localizations.translate('journalRemoveEntryConfirm'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _JournalActions extends StatelessWidget {
  const _JournalActions({
    required this.entry,
    required this.onToggleSaved,
    required this.onToggleLiked,
    required this.onShare,
  });

  final JournalEntry entry;
  final Future<void> Function(JournalEntry entry) onToggleSaved;
  final Future<void> Function(JournalEntry entry) onToggleLiked;
  final Future<void> Function(BuildContext context, JournalEntry entry) onShare;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      children: [
        FilledButton.tonalIcon(
          onPressed: () => onToggleSaved(entry),
          icon: Icon(
            entry.isSaved ? Icons.bookmark : Icons.bookmark_border,
          ),
          label: Text(
            localizations.translate(entry.isSaved
                ? 'journalActionSaved'
                : 'journalActionSave'),
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: () => onToggleLiked(entry),
          icon: Icon(entry.isLiked ? Icons.favorite : Icons.favorite_border),
          label: Text(
            localizations.translate(entry.isLiked
                ? 'journalActionLiked'
                : 'journalActionLike'),
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: () => onShare(context, entry),
          icon: const Icon(Icons.ios_share),
          label: Text(localizations.translate('journalActionShare')),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _RemovableImage extends StatelessWidget {
  const _RemovableImage({
    required this.url,
    required this.onRemove,
    required this.fallbackLabel,
  });

  final String url;
  final VoidCallback onRemove;
  final String fallbackLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 120,
            height: 90,
            child: Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) {
                  return child;
                }
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, _, __) {
                return _ImagePlaceholder(label: fallbackLabel);
              },
            ),
          ),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceTint.withOpacity(0.8),
              padding: EdgeInsets.zero,
              minimumSize: const Size(32, 32),
            ),
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
          ),
        ),
      ],
    );
  }
}

class JournalEntryDetailView extends StatelessWidget {
  const JournalEntryDetailView({
    super.key,
    required this.entryId,
    required this.heroTag,
    required this.entriesListenable,
    required this.onToggleSaved,
    required this.onToggleLiked,
    required this.onShare,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  final String entryId;
  final String heroTag;
  final ValueListenable<List<JournalEntry>> entriesListenable;
  final Future<void> Function(JournalEntry entry) onToggleSaved;
  final Future<void> Function(JournalEntry entry) onToggleLiked;
  final Future<void> Function(BuildContext context, JournalEntry entry) onShare;
  final Future<void> Function(
    BuildContext context,
    JournalEntry entry,
    JournalMoment moment,
  ) onAddPhoto;
  final Future<void> Function(
    BuildContext context,
    JournalEntry entry,
    JournalMoment moment,
    String url,
  ) onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<JournalEntry>>(
      valueListenable: entriesListenable,
      builder: (context, entries, _) {
        final entry = entries.firstWhere(
          (element) => element.id == entryId,
          orElse: () => JournalEntry(
            id: entryId,
            title: '',
            location: '',
            date: DateTime.now(),
            moments: const <JournalMoment>[],
          ),
        );

        final localizations = AppLocalizations.of(context);
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(entry.title.isEmpty
                ? localizations.translate('journalTitle')
                : entry.title),
            actions: [
              IconButton(
                onPressed: () => onShare(context, entry),
                icon: const Icon(Icons.ios_share),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              Hero(
                tag: heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: entry.coverImage != null
                        ? Image.network(
                            entry.coverImage!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) {
                                return child;
                              }
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder: (context, _, __) {
                              return _ImagePlaceholder(
                                label: localizations
                                    .translate('journalImageFallback'),
                              );
                            },
                          )
                        : _ImagePlaceholder(
                            label:
                                localizations.translate('journalNoImage'),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(entry.title, style: theme.textTheme.displaySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.location,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _JournalActions(
                entry: entry,
                onToggleSaved: onToggleSaved,
                onToggleLiked: onToggleLiked,
                onShare: onShare,
              ),
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(entry.notes!, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 24),
              Text(
                localizations.translate('journalTimeline'),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...entry.moments.map((moment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GlassSurface(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (moment.time.isNotEmpty)
                              Text(
                                moment.time,
                                style: theme.textTheme.labelLarge,
                              ),
                            if (moment.time.isNotEmpty)
                              const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                moment.title,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        if (moment.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            moment.description,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                        if (moment.imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: moment.imageUrls.map((url) {
                              return _RemovableImage(
                                url: url,
                                onRemove: () => onRemovePhoto(
                                  context,
                                  entry,
                                  moment,
                                  url,
                                ),
                                fallbackLabel: localizations
                                    .translate('journalImageFallback'),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton.icon(
                            onPressed: () => onAddPhoto(
                              context,
                              entry,
                              moment,
                            ),
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: Text(
                              localizations
                                  .translate('journalAddPhotoButton'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
