# 🥗 Garnish — Flutter Recipe App

A beautiful mobile recipe app inspired by the Garnish web app design. Built with Flutter.

## Screenshots Preview
The app features:
- 🏠 **Home screen** with the Garnish hero layout, feature cards, and meal type collections
- 📖 **Recipes screen** with search, filtering, and tabbed view
- ➕ **Create/Edit recipe** with full form: title, description, cuisine, category, dietary tags, cook time, servings, ingredients, and instructions
- 📋 **Recipe Detail** with ingredient list, step-by-step instructions, and cook stats
- ❤️ **Favorites** screen for saved recipes
- 💾 **Persistent local storage** via SharedPreferences — recipes survive app restarts
- 3 sample recipes pre-loaded on first launch

## Design
Matches the Garnish web aesthetic:
- Warm cream/beige background (`#F5EFE6`)
- Orange CTAs (`#E88A2D`)  
- Green accents (`#3A7D44`)
- Playfair Display headings + DM Sans body text
- Food emoji watermark background pattern
- Card-based layout with subtle borders

## Setup

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode for device/emulator

### Install & Run

```bash
cd garnish_app
flutter pub get
flutter run
```

### Build for release

```bash
# Android APK
flutter build apk --release

# iOS (requires Mac + Xcode)
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── theme.dart                 # Colors, typography, theme
├── models/
│   └── recipe.dart            # Recipe data model
├── services/
│   └── recipe_service.dart    # Local storage (SharedPreferences)
├── widgets/
│   └── widgets.dart           # Shared UI components
└── screens/
    ├── home_screen.dart        # Home tab + bottom nav
    ├── recipes_screen.dart     # Discover recipes
    ├── add_recipe_screen.dart  # Create / edit recipe form
    ├── recipe_detail_screen.dart  # Full recipe view
    └── favorites_screen.dart   # Saved favorites
```

## Dependencies

| Package | Purpose |
|---|---|
| `google_fonts` | Playfair Display + DM Sans typography |
| `shared_preferences` | Persistent local recipe storage |
| `uuid` | Unique IDs for recipes |
| `flutter_staggered_animations` | List entry animations (optional) |

## Features

- ✅ Create recipes with full details
- ✅ Edit existing recipes
- ✅ Delete recipes (with confirmation)
- ✅ Favourite/unfavourite recipes
- ✅ Search across title, ingredients, cuisine, tags
- ✅ Persistent storage (survives app restarts)
- ✅ Sample recipes pre-loaded
- ✅ Responsive mobile layout

## Extending

To connect to the existing Node.js backend (`server.js`), replace `RecipeService` calls with HTTP requests to `http://localhost:5000/api/`. The backend already has `/api/addcard` and `/api/searchcards` endpoints you can adapt.
