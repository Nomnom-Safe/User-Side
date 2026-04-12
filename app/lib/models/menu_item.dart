class MenuItem {
  final String id;
  final String name;
  final String description;
  final List<String> allergens;
  final String itemType;
  final String menuId;
  final String ingredients;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.allergens,
    required this.itemType,
    required this.menuId,
    this.ingredients = '',
  });

  /// Create a MenuItem object from JSON data
  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    allergens: List<String>.from(json['allergens'] ?? []),
    itemType: json['item_type'] ?? '',
    menuId: json['menu_id'] ?? '',
    ingredients: json['ingredients'] ?? '',
  );

  /// Convert a MenuItem object to JSON data
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'allergens': allergens,
    'item_type': itemType,
    'menu_id': menuId,
    'ingredients': ingredients,
  };

  bool get hasIngredients => ingredients.trim().isNotEmpty;
}
