import 'dart:convert';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String cuisine;
  final String category;
  final String dietaryTags;
  final String keywords;
  final int cookTime;
  final int servings;
  final String ingredients;
  final String instructions;
  final DateTime createdAt;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    this.cuisine = 'General',
    this.category = 'Dinner',
    this.dietaryTags = '',
    this.keywords = '',
    this.cookTime = 30,
    this.servings = 2,
    required this.ingredients,
    required this.instructions,
    required this.createdAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cuisine': cuisine,
      'category': category,
      'dietaryTags': dietaryTags,
      'keywords': keywords,
      'cookTime': cookTime,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      cuisine: map['cuisine'] ?? 'General',
      category: map['category'] ?? 'Dinner',
      dietaryTags: map['dietaryTags'] ?? '',
      keywords: map['keywords'] ?? '',
      cookTime: map['cookTime'] ?? 30,
      servings: map['servings'] ?? 2,
      ingredients: map['ingredients'] ?? '',
      instructions: map['instructions'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory Recipe.fromJson(String source) => Recipe.fromMap(json.decode(source));

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? cuisine,
    String? category,
    String? dietaryTags,
    String? keywords,
    int? cookTime,
    int? servings,
    String? ingredients,
    String? instructions,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cuisine: cuisine ?? this.cuisine,
      category: category ?? this.category,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      keywords: keywords ?? this.keywords,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
