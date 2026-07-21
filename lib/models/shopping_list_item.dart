class ShoppingListItem {
  final String name;
  final double amount;
  final String unit;
  final String category;
  final bool isChecked;
  final bool isCustom;

  const ShoppingListItem({
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
    this.isChecked = false,
    this.isCustom = false,
  });

  ShoppingListItem copyWith({
    String? name,
    double? amount,
    String? unit,
    String? category,
    bool? isChecked,
    bool? isCustom,
  }) {
    return ShoppingListItem(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}