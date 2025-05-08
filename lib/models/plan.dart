class PlanEntry {
  final DateTime date;
  final String title;
  final String description;

  PlanEntry({
    required this.date,
    required this.title,
    required this.description,
  });

  factory PlanEntry.fromFormattedString(String line) {
    // Example line: 2025-05-08 | Chest & Triceps | Bench press, Incline dumbbell...
    final parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length != 3) throw FormatException("Invalid format");

    return PlanEntry(
      date: DateTime.parse(parts[0]),
      title: parts[1],
      description: parts[2],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'title': title,
        'description': description,
      };

  factory PlanEntry.fromJson(Map<String, dynamic> json) => PlanEntry(
        date: DateTime.parse(json['date']),
        title: json['title'],
        description: json['description'],
      );
}
