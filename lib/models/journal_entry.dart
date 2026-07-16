class GratitudeEntry {
  GratitudeEntry({
    required this.id,
    required this.date,
    required this.items,
    this.isPublic = false,
  });

  final String id;
  final DateTime date;
  final List<String> items;
  final bool isPublic;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'items': items,
    'isPublic': isPublic,
  };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) => GratitudeEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    items: (json['items'] as List).map((e) => e as String).toList(),
    isPublic: json['isPublic'] as bool? ?? false,
  );
}

class ReflectionEntry {
  ReflectionEntry({
    required this.id,
    required this.date,
    required this.meaningful,
    required this.proud,
    required this.improve,
  });

  final String id;
  final DateTime date;
  final String meaningful;
  final String proud;
  final String improve;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'meaningful': meaningful,
    'proud': proud,
    'improve': improve,
  };

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) =>
      ReflectionEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        meaningful: json['meaningful'] as String,
        proud: json['proud'] as String,
        improve: json['improve'] as String,
      );
}

class MoodEntry {
  MoodEntry({required this.date, required this.before, this.after});

  final DateTime date;
  final int before;
  int? after;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'before': before,
    'after': after,
  };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
    date: DateTime.parse(json['date'] as String),
    before: json['before'] as int,
    after: json['after'] as int?,
  );
}
