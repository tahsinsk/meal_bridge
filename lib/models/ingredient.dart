class Ingredient {
  final String name;
  final double amount;
  final String unit;
  final String category;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'category': category,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String,
    );
  }
}
