import 'menu_item.dart';

class Menu {
  final String id;
  final String businessId;
  final String title;
  final List<MenuItem> items;

  Menu({
    required this.id,
    required this.businessId,
    this.title = '',
    required this.items,
  });

  /// Create a Menu object from JSON data
  factory Menu.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] ?? [];
    return Menu(
      id: json['id'] ?? '',
      businessId: json['business_id'] ?? '',
      title: json['title'] ?? '',
      items: itemsJson.map((item) => MenuItem.fromJson(item)).toList(),
    );
  }

  /// Convert a Menu object to JSON data
  Map<String, dynamic> toJson() => {
    'id': id,
    'business_id': businessId,
    'title': title,
    'items': items.map((item) => item.toJson()).toList(),
  };
}
