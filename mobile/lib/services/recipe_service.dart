import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'auth_service.dart';

const _base = 'http://165.232.145.102:5000';

class RecipeService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Server → mobile: structured arrays → flat strings
  static Recipe _fromServer(Map<String, dynamic> map) {
    final ingList = (map['ingredients'] as List<dynamic>? ?? []);
    final ingredients = ingList.map((i) {
      final name = (i['name'] ?? '').toString().trim();
      final amount = (i['amount'] ?? '').toString().trim();
      return amount.isNotEmpty ? '$name ($amount)' : name;
    }).where((s) => s.isNotEmpty).join('\n');

    final instList = (map['instructions'] as List<dynamic>? ?? []);
    final instructions = instList
        .map((s) => s.toString().trim())
        .where((s) => s.isNotEmpty)
        .join('\n');

    final dietaryTags = (map['dietaryTags'] as List<dynamic>? ?? []).join(', ');
    final keywords = (map['cravingTags'] as List<dynamic>? ?? []).join(', ');

    return Recipe(
      id: map['_id']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      cuisine: map['cuisine'] ?? 'General',
      category: map['category'] ?? 'Dinner',
      dietaryTags: dietaryTags,
      keywords: keywords,
      cookTime: (map['cookTime'] as num?)?.toInt() ?? 30,
      servings: (map['servings'] as num?)?.toInt() ?? 2,
      ingredients: ingredients,
      instructions: instructions,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isFavorite: map['isFavorite'] == true,
    );
  }

  // Mobile → server: flat strings → structured arrays
  static Map<String, dynamic> _toServer(Recipe r) {
    final ingredients = r.ingredients
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .map((line) {
          final match = RegExp(r'^(.+?)\s*\((.+)\)$').firstMatch(line.trim());
          if (match != null) {
            return {'name': match.group(1)!.trim(), 'amount': match.group(2)!.trim()};
          }
          return {'name': line.trim(), 'amount': ''};
        })
        .toList();

    final instructions = r.instructions
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    List<String> splitTags(String raw) => raw.isEmpty
        ? []
        : raw.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    return {
      'title': r.title,
      'description': r.description,
      'cuisine': r.cuisine,
      'category': r.category,
      'dietaryTags': splitTags(r.dietaryTags),
      'cravingTags': splitTags(r.keywords),
      'cookTime': r.cookTime,
      'servings': r.servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'isFavorite': r.isFavorite,
    };
  }

  static Future<List<Recipe>> getRecipes() async {
    final headers = await _authHeaders();
    try {
      final res = await http.get(Uri.parse('$_base/api/recipes'), headers: headers);
      if (res.statusCode == 200) {
        final list = (json.decode(res.body)['recipes'] as List<dynamic>);
        return list.map((e) => _fromServer(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<Recipe?> addRecipe(Recipe recipe) async {
    final headers = await _authHeaders();
    try {
      final res = await http.post(
        Uri.parse('$_base/api/recipes'),
        headers: headers,
        body: json.encode(_toServer(recipe)),
      );
      if (res.statusCode == 201) {
        return _fromServer(json.decode(res.body)['recipe'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> updateRecipe(Recipe recipe) async {
    final headers = await _authHeaders();
    try {
      await http.put(
        Uri.parse('$_base/api/recipes/${recipe.id}'),
        headers: headers,
        body: json.encode(_toServer(recipe)),
      );
    } catch (_) {}
  }

  static Future<void> deleteRecipe(String id) async {
    final headers = await _authHeaders();
    try {
      await http.delete(Uri.parse('$_base/api/recipes/$id'), headers: headers);
    } catch (_) {}
  }

  static Future<void> toggleFavorite(String id) async {
    final headers = await _authHeaders();
    try {
      await http.patch(
        Uri.parse('$_base/api/recipes/$id/favorite'),
        headers: headers,
      );
    } catch (_) {}
  }

  static String generateId() => '';
}
