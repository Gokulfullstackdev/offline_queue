// lib/features/data/models/note_model.dart
class NoteModel {
  final int? id; // Make id nullable
  final String title;
  final String content;
  final DateTime createdAt;
  final int isSynced;

  NoteModel({
    this.id, // Now nullable
    required this.title,
    required this.content,
    required this.createdAt,
    required this.isSynced,
  });

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  // Create from SQLite Map with null safety
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      createdAt: _parseDateSafely(map['createdAt']),
      isSynced: map['isSynced'] as int? ?? 0,
    );
  }

  // Safe date parsing
  static DateTime _parseDateSafely(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    try {
      return DateTime.parse(dateValue.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // Create a copy with updated fields
  NoteModel copyWith({
    int? id,
    String? title,
    String? content,
    DateTime? createdAt,
    int? isSynced,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}