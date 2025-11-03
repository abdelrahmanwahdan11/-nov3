import 'package:flutter/material.dart';

enum JournalViewMode { timeline, story }

class JournalMoment {
  const JournalMoment({
    required this.id,
    required this.title,
    required this.time,
    required this.description,
    this.imageUrls = const <String>[],
  });

  final String id;
  final String title;
  final String time;
  final String description;
  final List<String> imageUrls;

  JournalMoment copyWith({
    String? id,
    String? title,
    String? time,
    String? description,
    List<String>? imageUrls,
  }) {
    return JournalMoment(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'time': time,
      'description': description,
      'imageUrls': imageUrls,
    };
  }

  factory JournalMoment.fromJson(Map<String, dynamic> json) {
    final images = json['imageUrls'];
    return JournalMoment(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrls: images is List
          ? images
              .map((dynamic value) => value?.toString())
              .whereType<String>()
              .toList()
          : <String>[],
    );
  }
}

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.moments,
    this.notes,
    this.isSaved = false,
    this.isLiked = false,
  });

  final String id;
  final String title;
  final String location;
  final DateTime date;
  final List<JournalMoment> moments;
  final String? notes;
  final bool isSaved;
  final bool isLiked;

  String? get coverImage {
    for (final moment in moments) {
      if (moment.imageUrls.isNotEmpty) {
        return moment.imageUrls.first;
      }
    }
    return null;
  }

  JournalEntry copyWith({
    String? id,
    String? title,
    String? location,
    DateTime? date,
    List<JournalMoment>? moments,
    String? notes,
    bool? isSaved,
    bool? isLiked,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      date: date ?? this.date,
      moments: moments ?? this.moments,
      notes: notes ?? this.notes,
      isSaved: isSaved ?? this.isSaved,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'location': location,
      'date': date.toIso8601String(),
      'moments': moments.map((moment) => moment.toJson()).toList(),
      'notes': notes,
      'isSaved': isSaved,
      'isLiked': isLiked,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final rawMoments = json['moments'];
    return JournalEntry(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      moments: rawMoments is List
          ? rawMoments
              .map((dynamic item) => item is Map<String, dynamic>
                  ? JournalMoment.fromJson(item)
                  : JournalMoment.fromJson(
                      (item as Map).map(
                        (key, value) => MapEntry(key.toString(), value),
                      ),
                    ))
              .toList()
          : <JournalMoment>[],
      notes: json['notes']?.toString(),
      isSaved: json['isSaved'] == true,
      isLiked: json['isLiked'] == true,
    );
  }
}
