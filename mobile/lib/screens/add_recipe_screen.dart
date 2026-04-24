import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/widgets.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // If provided, we're editing

  const AddRecipeScreen({super.key, this.recipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _cuisineCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _dietaryCtrl;
  late final TextEditingController _keywordsCtrl;
  late final TextEditingController _cookTimeCtrl;
  late final TextEditingController _servingsCtrl;
  late final TextEditingController _ingredientsCtrl;
  late final TextEditingController _instructionsCtrl;

  bool get _isEditing => widget.recipe != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recipe;
    _titleCtrl = TextEditingController(text: r?.title ?? '');
    _descCtrl = TextEditingController(text: r?.description ?? '');
    _cuisineCtrl = TextEditingController(text: r?.cuisine ?? 'General');
    _categoryCtrl = TextEditingController(text: r?.category ?? 'Dinner');
    _dietaryCtrl = TextEditingController(text: r?.dietaryTags ?? '');
    _keywordsCtrl = TextEditingController(text: r?.keywords ?? '');
    _cookTimeCtrl = TextEditingController(text: '${r?.cookTime ?? 30}');
    _servingsCtrl = TextEditingController(text: '${r?.servings ?? 2}');
    _ingredientsCtrl = TextEditingController(text: r?.ingredients ?? '');
    _instructionsCtrl = TextEditingController(text: r?.instructions ?? '');
  }

  @override
  void dispose() {
    for (final c in [_titleCtrl, _descCtrl, _cuisineCtrl, _categoryCtrl, _dietaryCtrl,
        _keywordsCtrl, _cookTimeCtrl, _servingsCtrl, _ingredientsCtrl, _instructionsCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final recipe = Recipe(
      id: widget.recipe?.id ?? RecipeService.generateId(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      cuisine: _cuisineCtrl.text.trim().isEmpty ? 'General' : _cuisineCtrl.text.trim(),
      category: _categoryCtrl.text.trim().isEmpty ? 'Dinner' : _categoryCtrl.text.trim(),
      dietaryTags: _dietaryCtrl.text.trim(),
      keywords: _keywordsCtrl.text.trim(),
      cookTime: int.tryParse(_cookTimeCtrl.text) ?? 30,
      servings: int.tryParse(_servingsCtrl.text) ?? 2,
      ingredients: _ingredientsCtrl.text.trim(),
      instructions: _instructionsCtrl.text.trim(),
      createdAt: widget.recipe?.createdAt ?? DateTime.now(),
      isFavorite: widget.recipe?.isFavorite ?? false,
    );

    if (_isEditing) {
      await RecipeService.updateRecipe(recipe);
    } else {
      await RecipeService.addRecipe(recipe);
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context, recipe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Recipe updated!' : 'Recipe saved!',
            style: GoogleFonts.dmSans(color: GarnishColors.white),
          ),
          backgroundColor: GarnishColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GarnishColors.cream,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recipe' : 'Create a recipe'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _isEditing
                  ? 'Update your recipe details.'
                  : 'Capture your own recipe or refine something you found.',
              style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textLight),
            ),
            const SizedBox(height: 20),

            _FormCard(
              children: [
                _FieldLabel('Recipe Title *'),
                _Field(
                  controller: _titleCtrl,
                  hint: 'e.g. Lemon Herb Roast Chicken',
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Please enter a title' : null,
                ),
                const SizedBox(height: 16),
                _FieldLabel('Description'),
                _Field(
                  controller: _descCtrl,
                  hint: 'A short description of this dish…',
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 16),

            _FormCard(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Cuisine'),
                          _Field(controller: _cuisineCtrl, hint: 'e.g. Italian'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Category'),
                          _Field(controller: _categoryCtrl, hint: 'e.g. Dinner'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Cook Time (min)'),
                          _Field(
                            controller: _cookTimeCtrl,
                            hint: '30',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Servings'),
                          _Field(
                            controller: _servingsCtrl,
                            hint: '2',
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _FieldLabel('Dietary Tags (comma separated)'),
                _Field(
                  controller: _dietaryCtrl,
                  hint: 'e.g. vegetarian, gluten-free',
                ),
                const SizedBox(height: 16),
                _FieldLabel('Search Keywords'),
                _Field(
                  controller: _keywordsCtrl,
                  hint: 'e.g. pasta, quick, weeknight',
                ),
              ],
            ),
            const SizedBox(height: 16),

            _FormCard(
              children: [
                _FieldLabel('Ingredients *'),
                Text(
                  'One per line works best',
                  style: GoogleFonts.dmSans(fontSize: 12, color: GarnishColors.textLight),
                ),
                const SizedBox(height: 8),
                _Field(
                  controller: _ingredientsCtrl,
                  hint: '400g spaghetti\n500g ground beef\n1 onion, diced\n…',
                  maxLines: 8,
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Please add ingredients' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            _FormCard(
              children: [
                _FieldLabel('Instructions *'),
                Text(
                  'Step-by-step instructions',
                  style: GoogleFonts.dmSans(fontSize: 12, color: GarnishColors.textLight),
                ),
                const SizedBox(height: 8),
                _Field(
                  controller: _instructionsCtrl,
                  hint: '1. Boil a large pot of salted water…\n2. Brown the meat…\n3. …',
                  maxLines: 10,
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Please add instructions' : null,
                ),
              ],
            ),
            const SizedBox(height: 28),

            GarnishButton(
              label: _saving ? 'Saving…' : (_isEditing ? 'Update Recipe' : 'Save Recipe'),
              fullWidth: true,
              onPressed: _saving ? null : _save,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GarnishColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Recipe', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${widget.recipe!.title}"?',
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: GarnishColors.textMid)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.dmSans(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await RecipeService.deleteRecipe(widget.recipe!.id);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GarnishColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GarnishColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: GarnishColors.textDark,
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textLight),
      ),
    );
  }
}
