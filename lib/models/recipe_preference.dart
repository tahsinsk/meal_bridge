/// Optional constraints the user can toggle on before AI-generating a
/// recipe (text-prompt or pantry-based) — independently selectable, no
/// mutual exclusivity. [RecipeAiService] turns whichever are selected into
/// explicit prompt constraints; none selected means no constraints, same
/// as before this feature existed.
enum RecipePreference { highProtein, vegetarian, quick, budgetFriendly }
