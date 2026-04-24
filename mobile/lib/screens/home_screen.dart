import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import '../services/auth_service.dart';
import 'recipes_screen.dart';
import 'favorites_screen.dart';
import 'add_recipe_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  // Validates the stored token against the server on startup
  Future<void> _refreshUser() async {
    final user = await AuthService.refreshCurrentUser();
    if (mounted) setState(() => _currentUser = user);
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _HomeTab();
      case 1:
        return const RecipesScreen();
      case 2:
        return const FavoritesScreen();
      case 3:
        if (_currentUser != null) {
          return ProfileScreen(
            user: _currentUser!,
            onLogout: () => setState(() {
              _currentUser = null;
              _currentIndex = 0;
            }),
          );
        }
        return AuthScreen(
          onLogin: (user) => setState(() => _currentUser = user),
        );
      default:
        return const _HomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: GarnishColors.white,
          border: Border(top: BorderSide(color: GarnishColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.menu_book_outlined,
                  activeIcon: Icons.menu_book,
                  label: 'Recipes',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _AddButton(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddRecipeScreen()),
                    );
                    setState(() {});
                  },
                ),
                _NavItem(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: 'Favorites',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _ProfileNavItem(
                  user: _currentUser,
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? GarnishColors.orange : GarnishColors.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? GarnishColors.orange : GarnishColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: GarnishColors.orange,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add, color: GarnishColors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(
            'Add',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: GarnishColors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final UserProfile? user;
  final bool isActive;
  final VoidCallback onTap;
  const _ProfileNavItem({required this.user, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            user != null
                ? Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: GarnishColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user!.initials,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: GarnishColors.white,
                        ),
                      ),
                    ),
                  )
                : Icon(Icons.person_outline,
                    color: isActive ? GarnishColors.orange : GarnishColors.textLight, size: 24),
            const SizedBox(height: 4),
            Text(
              'Profile',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: (isActive || user != null)
                    ? GarnishColors.orange
                    : GarnishColors.textLight,
                fontWeight: (isActive || user != null)
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Home Tab ────────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return FoodEmojiBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: GarnishColors.tagBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Everyday recipe discovery',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: GarnishColors.tagText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Find something\ngood to cook.',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: GarnishColors.textDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Create, save, and revisit your favourite recipes.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: GarnishColors.textMid,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // CTA Buttons
              Row(
                children: [
                  Expanded(
                    child: GarnishButton(
                      label: 'My Recipes',
                      fullWidth: true,
                      onPressed: () {
                        // Navigate to recipes tab via parent - use Navigator trick
                        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                        homeState?.setState(() => homeState._currentIndex = 1);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GarnishButton(
                      label: 'Favorites',
                      fullWidth: true,
                      outlined: true,
                      onPressed: () {
                        final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                        homeState?.setState(() => homeState._currentIndex = 2);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Feature cards
              Container(
                decoration: BoxDecoration(
                  color: GarnishColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GarnishColors.border),
                ),
                child: Column(
                  children: [
                    _FeatureCard(
                      label: 'DISCOVER',
                      title: 'Create recipes with less friction.',
                      subtitle: 'Add a title, ingredients, and instructions. Save what matters.',
                      showDivider: true,
                    ),
                    _FeatureCard(
                      label: 'SAVE',
                      title: 'Make the good ones yours.',
                      subtitle: 'Keep favourites, refine your recipes, and build your own recipe box.',
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Browse by meal type
              Text(
                'Browse by the kind of meal you need',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: GarnishColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Built for regular cooking, not endless scrolling.',
                style: GoogleFonts.dmSans(fontSize: 13, color: GarnishColors.textLight),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _MealTypeCard('Weeknight dinners', 'Reliable recipes for a Tuesday night.', GarnishColors.tagBg),
                    _MealTypeCard('Pantry cooking', 'Built around staples and leftovers.', GarnishColors.greenTagBg),
                    _MealTypeCard('Recipe box faves', 'The meals you keep coming back to.', const Color(0xFFEDE5F4)),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Why Garnish section
              Text(
                'Why Garnish works in real life',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: GarnishColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'A cleaner recipe flow from idea to dinner.',
                style: GoogleFonts.dmSans(fontSize: 13, color: GarnishColors.textLight),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _WhyCard('Cook from your own box', 'Your recipes, always at hand.')),
                  const SizedBox(width: 12),
                  Expanded(child: _WhyCard('Keep the best close', 'Save and edit your collection.')),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String label, title, subtitle;
  final bool showDivider;
  const _FeatureCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: GarnishColors.textLight,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: GarnishColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(fontSize: 13, color: GarnishColors.textMid),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(color: GarnishColors.border, height: 1),
      ],
    );
  }
}

class _MealTypeCard extends StatelessWidget {
  final String title, subtitle;
  final Color color;
  const _MealTypeCard(this.title, this.subtitle, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GarnishColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(top: BorderSide(color: GarnishColors.orange, width: 3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Collection',
              style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600, color: GarnishColors.tagText),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: GarnishColors.textDark)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: GarnishColors.textMid)),
        ],
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  final String title, subtitle;
  const _WhyCard(this.title, this.subtitle);

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
        children: [
          Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: GarnishColors.textDark)),
          const SizedBox(height: 4),
          Text(subtitle, style: GoogleFonts.dmSans(fontSize: 12, color: GarnishColors.textMid)),
        ],
      ),
    );
  }
}
