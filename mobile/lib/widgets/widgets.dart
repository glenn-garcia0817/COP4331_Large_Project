import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/recipe.dart';

// ─── Food emoji background painter ─────────────────────────────────────────
class FoodBackgroundPainter extends CustomPainter {
  static const emojis = ['🍅', '🥑', '🧄', '🌶️', '🥕', '🍋', '🧅', '🫑', '🍄', '🫐'];
  
  @override
  void paint(Canvas canvas, Size size) {
    // Background is handled by scaffold color; this adds subtle texture via Container
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FoodEmojiBackground extends StatelessWidget {
  final Widget child;
  const FoodEmojiBackground({super.key, required this.child});

  static const _emojis = ['🍅', '🥑', '🧄', '🌶️', '🥕', '🍋', '🧅', '🫑', '🍄', '🫐', '🫒', '🥦'];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _EmojiGridPainter(_emojis),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _EmojiGridPainter extends CustomPainter {
  final List<String> emojis;
  _EmojiGridPainter(this.emojis);

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    const spacing = 80.0;
    int idx = 0;
    for (double y = 0; y < size.height + spacing; y += spacing) {
      for (double x = (y ~/ spacing).isEven ? 0.0 : 40.0; x < size.width + spacing; x += spacing) {
        tp.text = TextSpan(
          text: emojis[idx % emojis.length],
          style: TextStyle(
            fontSize: 22,
            color: Colors.black.withOpacity(0.06),
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
        idx++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Orange button ──────────────────────────────────────────────────────────
class GarnishButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;
  final bool fullWidth;

  const GarnishButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: outlined ? GarnishColors.orange : GarnishColors.white),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: outlined ? GarnishColors.orange : GarnishColors.white,
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: GarnishColors.orange, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
        child: content,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: GarnishColors.orange,
        foregroundColor: GarnishColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        minimumSize: fullWidth ? const Size(double.infinity, 52) : null,
      ),
      child: content,
    );
  }
}

// ─── Tag chip ───────────────────────────────────────────────────────────────
class GarnishTag extends StatelessWidget {
  final String label;
  final bool green;

  const GarnishTag(this.label, {super.key, this.green = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: green ? GarnishColors.greenTagBg : GarnishColors.tagBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: green ? GarnishColors.greenTagText : GarnishColors.tagText,
        ),
      ),
    );
  }
}

// ─── Recipe card ────────────────────────────────────────────────────────────
class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
    this.onFavorite,
  });

  String get _emoji {
    final c = recipe.cuisine.toLowerCase();
    if (c.contains('italian')) return '🍝';
    if (c.contains('mexican')) return '🌮';
    if (c.contains('asian') || c.contains('chinese') || c.contains('japanese')) return '🍜';
    if (c.contains('indian')) return '🍛';
    if (c.contains('mediterranean') || c.contains('greek')) return '🫒';
    if (c.contains('american')) return '🍔';
    final cat = recipe.category.toLowerCase();
    if (cat.contains('breakfast')) return '🍳';
    if (cat.contains('dessert')) return '🍰';
    if (cat.contains('salad')) return '🥗';
    if (cat.contains('soup')) return '🍲';
    return '🍽️';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: GarnishColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GarnishColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: GarnishColors.creamDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(_emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: GarnishColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${recipe.cuisine} · ${recipe.category}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: GarnishColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onFavorite,
                    child: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: recipe.isFavorite ? GarnishColors.orange : GarnishColors.textLight,
                      size: 22,
                    ),
                  ),
                ],
              ),
              if (recipe.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  recipe.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: GarnishColors.textMid,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoPill(Icons.timer_outlined, '${recipe.cookTime} min'),
                  const SizedBox(width: 8),
                  _InfoPill(Icons.people_outline, '${recipe.servings} servings'),
                  const Spacer(),
                  if (recipe.dietaryTags.isNotEmpty)
                    GarnishTag(recipe.dietaryTags.split(',').first.trim(), green: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: GarnishColors.textLight),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 12, color: GarnishColors.textLight),
        ),
      ],
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const SectionHeader({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: GarnishColors.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textLight),
          ),
        ],
      ],
    );
  }
}

// ─── Empty state ────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: GarnishColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.dmSans(fontSize: 14, color: GarnishColors.textLight),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
