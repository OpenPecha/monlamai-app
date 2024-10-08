class Favorite {
  final String id;
  final String sourceText;
  final String targetText;
  final String sourceLang;
  final String targetLang;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.sourceText,
    required this.targetText,
    required this.sourceLang,
    required this.targetLang,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceText': sourceText,
      'targetText': targetText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      id: map['id'],
      sourceText: map['sourceText'],
      targetText: map['targetText'],
      sourceLang: map['sourceLang'],
      targetLang: map['targetLang'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
