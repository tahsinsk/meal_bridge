# MealBridge

MealBridge is a simple Flutter meal planner app.

The goal of the app is to let users save recipes, create a weekly meal plan, and automatically generate a combined shopping list from the selected recipes.

This is the first MVP version. It does not use AI, backend, or user accounts yet. The focus is a working local mobile app.

- Add recipes
- Edit custom recipes
- Delete custom recipes
- Search recipes by name or category
- Show improved empty and search result states for recipe discovery
- Add ingredients with amount, unit, and market category
- Select ingredient units from predefined options
- Select market categories from predefined options
- Validate recipe form inputs
- Prevent duplicate ingredients inside a recipe
- Add recipe instructions
- Add optional recipe notes
- Assign recipes to days in the weekly plan
- View weekly meal plan progress
- Show improved weekly plan guidance when no meals are planned yet
- Persist weekly meal plan locally
- Generate a shopping list from planned recipes
- Merge matching ingredients where possible
- Normalize ingredient names, units, and categories for better merging
- Convert basic compatible units in the shopping list, such as g/kg and ml/l
- Group shopping list items by market category
- Sort shopping list items by market category order
- Mark shopping list items as checked / unchecked
- Persist checked shopping list items locally
- Clear checked shopping list items
- Copy the full shopping list to clipboard
- Copy only unchecked shopping list items to clipboard
- Show remaining shopping item count
- Show improved shopping list empty state guidance
- Polished recipe list, recipe detail, recipe form, meal plan, and shopping list screens
- Basic mobile-friendly UI
- Tested on iOS Simulator

## Tech Stack

- Flutter
- Dart
- Local storage with SharedPreferences
- No backend for MVP
- No AI features in the first version

## Project Status

MealBridge MVP v0.2 is currently working locally and has passed a basic manual stability test.

A stable v0.2 MVP checkpoint has been tagged in Git as `v0.2-mvp`.

The main user flow is complete:

1. Create a recipe
2. Add ingredients and instructions
3. Save the recipe
4. Search and manage saved recipes
5. Assign recipes to weekly plan days
6. Generate a merged shopping list with basic unit conversion
7. Check off shopping items
8. Copy the shopping list when needed
9. Keep recipes, meal plan, and checked shopping items after app restart

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

- Continue improving visual design and icons
- Improve advanced ingredient merging logic
- Add servings scaling in a future milestone
- Continue Breakfast / Lunch / Dinner meal slot implementation on the `feature/meal-slots` branch
- Add shopping list share/export options
- Add onboarding or empty-state guidance
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

Current development focuses on small, practical MVP improvements and clean local-first behavior.

Recent polish work improved recipe search empty states, weekly plan guidance, shopping list empty state guidance, and app metadata.

A basic manual test pass has confirmed recipe add/edit/delete, meal plan sync, shopping list generation, ingredient merging, unit conversion, checked item persistence, clear checked, and clipboard copy flows.

Servings scaling is planned for a future milestone. Current shopping list generation uses each recipe's base servings.

Breakfast, lunch, and dinner planning is being prepared on the `feature/meal-slots` branch. The first groundwork includes `MealType`, `PlannedMeal`, meal-plan key preparation, and lightweight UI hints, but the current MVP still uses one planned recipe per day.