import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/widgets.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Recipe _recipe;
  int _activeTab = 0; // 0 = Ingredients, 1 = Instructions

  @override
  void initState() {
    super.initState();
    _recipe = widget.recipe;
  }

  String get _emoji {
    final c = _recipe.cuisine.toLowerCase();
    if (c.contains('italian')) return '🍝';
    if (c.contains('mexican')) return '🌮';
    if (c.contains('asian') || c.contains('chinese') || c.contains('japanese')) return '🍜';
    if (c.contains('indian')) return '🍛';
    if (c.contains('mediterranean') || c.contains('greek')) return '🫒';
    if (c.contains('american')) return '🍔';
    final cat = _recipe.category.toLowerCase();
    if (cat.contains('breakfast')) return '🍳';
    if (cat.contains('dessert')) return '🍰';
    if (cat.contains('salad')) return '🥗';
    if (cat.contains('soup')) return '🍲';
    return '🍽️';
  }

  Future<void> _toggleFav() async {
    await RecipeService.toggleFavorite(_recipe.id);
    final recipes = await RecipeService.getRecipes();
    final updated = recipes.firstWhere((r) => r.id == _recipe.id, orElse: () => _recipe);
    if (mounted) setState(() => _recipe = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GarnishColors.cream,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: GarnishColors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _recipe.isFavorite ? GarnishColors.orange : GarnishColors.textDark,
                ),
                onPressed: _toggleFav,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final updated = await Navigator.push<Recipe>(
                    context,
                    MaterialPageRoute(builder: (_) => AddRecipeScreen(recipe: _recipe)),
                  );
                  if (updated != null && mounted) {
                    setState(() => _recipe = updated);
                  }
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: GarnishColors.creamDark,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _EmojiPatternPainter(_emoji),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(_emoji, style: const TextStyle(fontSize: 72)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and tags
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _recipe.title,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: GarnishColors.textDark,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_recipe.cuisine} · ${_recipe.category}',
                              style: GoogleFonts.dmSans(fontSize: 13, color: GarnishColors.textLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GarnishColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GarnishColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem('⏱️', '${_recipe.cookTime} min', 'Cook Time'),
                        _Divider(),
                        _StatItem('👥', '${_recipe.servings}', 'Servings'),
                        _Divider(),
                        _StatItem('🌍', _recipe.cuisine, 'Cuisine'),
                      ],
                    ),
                  ),

                  // Tags
                  if (_recipe.dietaryTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recipe.dietaryTags
                          .split(',')
                          .where((t) => t.trim().isNotEmpty)
                          .map((t) => GarnishTag(t.trim(), green: true))
                          .toList(),
                    ),
                  ],

                  // Description
                  if (_recipe.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _recipe.description,
                      style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textMid, height: 1.6),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Tab selector
                  Container(
                    decoration: BoxDecoration(
                      color: GarnishColors.creamDark,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _TabBtn('Ingredients', _activeTab == 0, () => setState(() => _activeTab = 0)),
                        _TabBtn('Instructions', _activeTab == 1, () => setState(() => _activeTab = 1)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab content
                  if (_activeTab == 0)
                    _IngredientsView(ingredients: _recipe.ingredients)
                  else
                    _InstructionsView(instructions: _recipe.instructions),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiPatternPainter extends CustomPainter {
  final String emoji;
  _EmojiPatternPainter(this.emoji);

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: emoji,
      style: TextStyle(fontSize: 30, color: Colors.black.withOpacity(0.04)),
    );
    tp.layout();
    const spacing = 60.0;
    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = 0; x < size.width + spacing; x += spacing) {
        tp.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StatItem extends StatelessWidget {
  final String emoji, value, label;
  const _StatItem(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: GarnishColors.textDark),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: GarnishColors.textLight)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: GarnishColors.border);
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? GarnishColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active ? Border.all(color: GarnishColors.border) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? GarnishColors.textDark : GarnishColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _IngredientsView extends StatelessWidget {
  final String ingredients;
  const _IngredientsView({required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final lines = ingredients
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return Text(
        'No ingredients listed.',
        style: GoogleFonts.dmSans(color: GarnishColors.textLight),
      );
    }

    return Column(
      children: lines.map((line) => _IngredientRow(line.trim())).toList(),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String text;
  const _IngredientRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: GarnishColors.orange,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textDark, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsView extends StatelessWidget {
  final String instructions;
  const _InstructionsView({required this.instructions});

  @override
  Widget build(BuildContext context) {
    final lines = instructions
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return Text(
        'No instructions listed.',
        style: GoogleFonts.dmSans(color: GarnishColors.textLight),
      );
    }

    return Column(
      children: List.generate(lines.length, (i) {
        final line = lines[i].replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: GarnishColors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: GarnishColors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  line,
                  style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textDark, height: 1.6),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
