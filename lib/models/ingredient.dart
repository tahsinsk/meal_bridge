class Ingredient {
  final String name;
  final double amount;
  final String unit;
  final String? categoryOverride;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.categoryOverride,
  });

  String get resolvedCategory {
    if (categoryOverride != null && categoryOverride!.trim().isNotEmpty) {
      return categoryOverride!;
    }
    return guessMarketCategory(name);
  }

  bool get isCategoryAuto => categoryOverride == null || categoryOverride!.trim().isEmpty;

  Ingredient copyWith({
    String? name,
    double? amount,
    String? unit,
    String? categoryOverride,
    bool clearCategoryOverride = false,
  }) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      categoryOverride: clearCategoryOverride ? null : (categoryOverride ?? this.categoryOverride),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'categoryOverride': categoryOverride,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      categoryOverride: json['categoryOverride'] as String? ?? json['category'] as String?,
    );
  }
}

String guessMarketCategory(String ingredientName) {
  final name = ingredientName.toLowerCase();

  // Vegetables — TR + EN + NL
  if ([
    // EN
    'tomato', 'cucumber', 'lettuce', 'carrot', 'onion', 'garlic',
    'pepper', 'broccoli', 'spinach', 'zucchini', 'eggplant', 'celery',
    'leek', 'mushroom', 'cabbage', 'cauliflower', 'corn', 'pea',
    'bean', 'lentil', 'potato', 'sweet potato', 'pumpkin',
    // TR
    'domates', 'salatalık', 'marul', 'havuç', 'soğan', 'sarımsak',
    'biber', 'brokoli', 'ıspanak', 'kabak', 'patlıcan', 'kereviz',
    'pırasa', 'mantar', 'lahana', 'karnabahar', 'mısır', 'bezelye',
    'fasulye', 'mercimek', 'patates', 'balkabağı',
    // NL
    'tomaat', 'komkommer', 'sla', 'wortel', 'ui', 'knoflook',
    'paprika', 'broccoli', 'spinazie', 'courgette', 'aubergine',
    'champignon', 'kool', 'bloemkool', 'erwt', 'boon', 'aardappel',
  ].any(name.contains)) { return 'Vegetables'; }

  // Fruit — TR + EN + NL
  if ([
    // EN
    'apple', 'banana', 'orange', 'lemon', 'lime', 'grape', 'strawberry',
    'blueberry', 'raspberry', 'peach', 'pear', 'mango', 'pineapple',
    'watermelon', 'melon', 'cherry', 'avocado', 'kiwi', 'fig',
    // TR
    'elma', 'muz', 'portakal', 'limon', 'üzüm', 'çilek', 'yaban mersini',
    'şeftali', 'armut', 'mango', 'ananas', 'karpuz', 'kavun', 'kiraz',
    'avokado', 'kivi', 'incir',
    // NL
    'appel', 'banaan', 'sinaasappel', 'citroen', 'druif', 'aardbei',
    'bosbes', 'framboos', 'perzik', 'peer', 'watermeloen', 'kers',
  ].any(name.contains)) { return 'Fruit'; }

  // Meat — TR + EN + NL
  if ([
    // EN
    'chicken', 'beef', 'pork', 'lamb', 'turkey', 'tuna', 'salmon',
    'shrimp', 'fish', 'meat', 'steak', 'mince', 'sausage', 'bacon',
    'egg', 'eggs',
    // TR
    'tavuk', 'dana', 'sığır', 'kuzu', 'hindi', 'ton balığı', 'somon',
    'karides', 'balık', 'et', 'biftek', 'kıyma', 'sosis', 'yumurta',
    // NL
    'kip', 'rundvlees', 'varkensvlees', 'lam', 'kalkoen', 'tonijn',
    'zalm', 'garnaal', 'vis', 'vlees', 'gehakt', 'worst', 'ei', 'eieren',
  ].any(name.contains)) { return 'Meat'; }

  // Dairy — TR + EN + NL
  if ([
    // EN
    'milk', 'yogurt', 'cheese', 'butter', 'cream', 'sour cream',
    'whipped cream', 'mozzarella', 'parmesan', 'cheddar',
    // TR
    'süt', 'yoğurt', 'peynir', 'tereyağı', 'krema', 'kaymak',
    'mozarella', 'parmesan', 'beyaz peynir',
    // NL
    'melk', 'yoghurt', 'kaas', 'boter', 'room', 'zure room',
    'mozzarella', 'roomkaas',
  ].any(name.contains)) { return 'Dairy'; }

  // Bakery — TR + EN + NL
  if ([
    // EN
    'bread', 'toast', 'bagel', 'croissant', 'bun', 'roll', 'pita',
    'tortilla', 'wrap', 'naan',
    // TR
    'ekmek', 'tost', 'simit', 'pide', 'lavaş', 'bazlama',
    // NL
    'brood', 'toast', 'bagel', 'croissant', 'broodje', 'pita',
  ].any(name.contains)) { return 'Bakery'; }

  // Spices — TR + EN + NL
  if ([
    // EN
    'salt', 'pepper', 'paprika', 'cumin', 'cinnamon', 'oregano',
    'thyme', 'basil', 'rosemary', 'turmeric', 'ginger', 'chili',
    'bay leaf', 'nutmeg', 'cardamom', 'clove', 'vanilla',
    // TR
    'tuz', 'karabiber', 'kırmızıbiber', 'kimyon', 'tarçın', 'kekik',
    'fesleğen', 'biberiye', 'zerdeçal', 'zencefil', 'defne', 'karanfil',
    'nane', 'maydanoz', 'dereotu',
    // NL
    'zout', 'peper', 'paprika', 'kaneel', 'oregano', 'tijm',
    'basilicum', 'rozemarijn', 'kurkuma', 'gember', 'nootmuskaat',
  ].any(name.contains)) { return 'Spices'; }

  // Pantry — TR + EN + NL
  if ([
    // EN
    'pasta', 'rice', 'oats', 'flour', 'sugar', 'oil', 'vinegar',
    'soy sauce', 'tomato sauce', 'ketchup', 'mustard', 'honey',
    'jam', 'peanut butter', 'chocolate', 'cocoa', 'baking powder',
    'noodle', 'couscous', 'quinoa', 'can', 'canned',
    // TR
    'makarna', 'pirinç', 'yulaf', 'un', 'şeker', 'yağ', 'sirke',
    'soya sosu', 'domates sosu', 'ketçap', 'hardal', 'bal',
    'reçel', 'çikolata', 'kakao', 'kabartma tozu', 'eriştee',
    'bulgur', 'nohut', 'konserve',
    // NL
    'pasta', 'rijst', 'havermout', 'bloem', 'suiker', 'olie', 'azijn',
    'sojasaus', 'tomatensaus', 'ketchup', 'mosterd', 'honing',
    'jam', 'chocolade', 'cacao', 'bakpoeder', 'noedel',
  ].any(name.contains)) { return 'Pantry'; }

  // Drinks — TR + EN + NL
  if ([
    // EN
    'water', 'juice', 'coffee', 'tea', 'wine', 'beer', 'soda',
    'milk', 'smoothie', 'lemonade',
    // TR
    'su', 'meyve suyu', 'kahve', 'çay', 'şarap', 'bira', 'soda',
    'limonata', 'ayran',
    // NL
    'water', 'sap', 'koffie', 'thee', 'wijn', 'bier', 'frisdrank',
    'limonade',
  ].any(name.contains)) { return 'Drinks'; }

  // Frozen
  if ([
    'frozen', 'dondurulmuş', 'diepvries', 'ice cream', 'dondurma', 'ijsje',
  ].any(name.contains)) { return 'Frozen'; }

  return 'Other';
}