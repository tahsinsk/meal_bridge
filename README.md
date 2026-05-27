# MealBridge

MealBridge is a simple Flutter meal planner app.

The goal of the app is to let users save recipes, create a weekly meal plan, and automatically generate a combined shopping list from the selected recipes.

This is the first MVP version. It does not use AI, backend, or user accounts yet. The focus is a working local mobile app.

## Current MVP Features

- Add recipes
- Edit custom recipes
- Delete custom recipes
- Add ingredients with amount, unit, and market category
- Add recipe instructions
- Add optional recipe notes
- Assign recipes to days in the weekly plan
- Persist weekly meal plan locally
- Generate a shopping list from planned recipes
- Merge matching ingredients where possible
- Group shopping list items by market category
- Mark shopping list items as checked / unchecked
- Persist checked shopping list items locally
- Clear checked shopping list items
- Basic mobile-friendly UI
- Tested on iOS Simulator

## Tech Stack

- Flutter
- Dart
- Local storage with SharedPreferences
- No backend for MVP
- No AI features in the first version

## Project Status

MealBridge MVP v0.1 is currently working locally.

The main user flow is complete:

1. Create a recipe
2. Add ingredients and instructions
3. Save the recipe
4. Assign recipes to weekly plan days
5. Generate a shopping list
6. Check off shopping items
7. Keep data after app restart

## How to Run

Install Flutter and make sure a device or simulator is available.

Check devices:

flutter devices

Run on Chrome:

flutter run -d chrome --web-port 8080

Run on iOS Simulator:

flutter run -d "iPhone 17"

Analyze the project:

flutter analyze

## Local Storage

The MVP stores data locally on the device.

Stored data includes:

- Custom recipes
- Weekly meal plan
- Checked shopping list items

No data is sent to a server.

## Next Steps

Possible next improvements:

- Improve visual design and icons
- Add recipe search/filter
- Add predefined ingredient categories
- Improve ingredient merging logic
- Add servings scaling
- Add export/share shopping list
- Add backend later
- Add AI features later through backend

## Long-Term Ideas

Future versions may include:

- User accounts
- Cloud sync
- AI recipe import
- AI meal planning suggestions
- Nutrition info
- Smart grocery categorization
- Multi-language support

## Notes

This project is intentionally kept simple for the MVP.

The first goal is a stable, usable mobile app before adding advanced architecture, backend, or AI features.