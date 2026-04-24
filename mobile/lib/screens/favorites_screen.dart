import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/widgets.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Recipe> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await RecipeService.getRecipes();
    if (mounted) {
      setState(() {
        _favorites = all.where((r) => r.isFavorite).toList();
        _loading = false;
      });
    }
  }

  Future<void> _toggleFav(Recipe r) async {
    await RecipeService.toggleFavorite(r.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return FoodEmojiBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorites',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: GarnishColors.textDark,
                    ),
                  ),
                  Text(
                    'The recipes you keep coming back to.',
                    style: GoogleFonts.dmSans(fontSize: 13, color: GarnishColors.textLight),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: GarnishColors.orange))
                  : _favorites.isEmpty
                      ? EmptyState(
                          emoji: '❤️',
                          title: 'No favorites yet',
                          subtitle: 'Tap the heart on any recipe\nto save it here.',
                          action: GarnishButton(
                            label: 'Browse Recipes',
                            onPressed: () {},
                          ),
                        )
                      : RefreshIndicator(
                          color: GarnishColors.orange,
                          onRefresh: _load,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: _favorites.length,
                            itemBuilder: (ctx, i) {
                              final recipe = _favorites[i];
                              return RecipeCard(
                                recipe: recipe,
                                onTap: () async {
                                  await Navigator.push(
                                    ctx,
                                    MaterialPageRoute(
                                      builder: (_) => RecipeDetailScreen(recipe: recipe),
                                    ),
                                  );
                                  _load();
                                },
                                onFavorite: () => _toggleFav(recipe),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
