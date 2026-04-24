import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/widgets.dart';
import 'recipe_detail_screen.dart';
import 'add_recipe_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> with SingleTickerProviderStateMixin {
  List<Recipe> _recipes = [];
  List<Recipe> _filtered = [];
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final recipes = await RecipeService.getRecipes();
    if (mounted) {
      setState(() {
        _recipes = recipes;
        _filtered = recipes;
        _loading = false;
      });
    }
  }

  void _search(String q) {
    final query = q.toLowerCase().trim();
    setState(() {
      _filtered = query.isEmpty
          ? _recipes
          : _recipes.where((r) =>
              r.title.toLowerCase().contains(query) ||
              r.cuisine.toLowerCase().contains(query) ||
              r.category.toLowerCase().contains(query) ||
              r.ingredients.toLowerCase().contains(query) ||
              r.keywords.toLowerCase().contains(query) ||
              r.dietaryTags.toLowerCase().contains(query)).toList();
    });
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
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover recipes',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: GarnishColors.textDark,
                          ),
                        ),
                        Text(
                          'Search and save what looks worth making.',
                          style: GoogleFonts.dmSans(fontSize: 13, color: GarnishColors.textLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: GarnishColors.creamDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 14),
                  labelColor: GarnishColors.textDark,
                  unselectedLabelColor: GarnishColors.textLight,
                  indicator: BoxDecoration(
                    color: GarnishColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GarnishColors.border),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  padding: const EdgeInsets.all(4),
                  tabs: const [
                    Tab(text: 'All Recipes'),
                    Tab(text: 'My Recipes'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Search by dish, ingredient, cuisine…',
                  hintStyle: GoogleFonts.dmSans(color: GarnishColors.textLight),
                  prefixIcon: const Icon(Icons.search, color: GarnishColors.textLight),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            _search('');
                          },
                          child: const Icon(Icons.close, color: GarnishColors.textLight),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: GarnishColors.orange))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _RecipeList(
                          recipes: _filtered,
                          onFavorite: _toggleFav,
                          onRefresh: _load,
                        ),
                        _RecipeList(
                          recipes: _filtered,
                          onFavorite: _toggleFav,
                          onRefresh: _load,
                          emptyMessage: 'No saved recipes yet.\nTap + to create your first.',
                          emptyEmoji: '📝',
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onFavorite;
  final VoidCallback onRefresh;
  final String emptyMessage;
  final String emptyEmoji;

  const _RecipeList({
    required this.recipes,
    required this.onFavorite,
    required this.onRefresh,
    this.emptyMessage = 'No recipes found.\nTry a different search.',
    this.emptyEmoji = '🔍',
  });

  @override
  Widget build(BuildContext context) {
    if (recipes.isEmpty) {
      return EmptyState(
        emoji: emptyEmoji,
        title: 'Nothing here yet',
        subtitle: emptyMessage,
        action: GarnishButton(
          label: 'Add a Recipe',
          icon: Icons.add,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
            );
            onRefresh();
          },
        ),
      );
    }

    return RefreshIndicator(
      color: GarnishColors.orange,
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: recipes.length,
        itemBuilder: (ctx, i) {
          final recipe = recipes[i];
          return RecipeCard(
            recipe: recipe,
            onTap: () async {
              await Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => RecipeDetailScreen(recipe: recipe),
                ),
              );
              onRefresh();
            },
            onFavorite: () => onFavorite(recipe),
          );
        },
      ),
    );
  }
}
