class Quote {
  final String id;
  final String text;
  final String author;
  final String language;
  final List<String> categories;
  bool isFavorite;
  final bool isSpeaking;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.language,
    this.categories = const [],
    this.isFavorite = false,
    this.isSpeaking = false,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    var categoriesData = json['categories'];
    List<String> categoriesList = [];

    if (categoriesData != null) {
      if (categoriesData is List) {
        categoriesList = categoriesData.map((item) => item.toString()).toList();
      }
    }

    return Quote(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      categories: categoriesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'language': language,
      'categories': categories,
    };
  }
}
