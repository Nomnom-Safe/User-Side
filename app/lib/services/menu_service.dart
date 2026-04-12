import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_safe/models/menu.dart';
import 'package:nomnom_safe/models/menu_item.dart';

/// Service class to handle menu-related Firestore operations
class MenuService {
  final dynamic _firestore;

  MenuService([dynamic firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch a menu by business (restaurant) ID
  Future<Menu?> getMenuByRestaurantId(String restaurantId) async {
    try {
      final menuSnapshot = await _firestore
          .collection('menus')
          .where('business_id', isEqualTo: restaurantId)
          .limit(1)
          .get();

      final docs = (menuSnapshot.docs as List).cast<dynamic>();
      if (docs.isEmpty) return null;

      final menuDoc = docs.first;
      return Menu.fromJson({
        'id': menuDoc.id,
        ...menuDoc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to load menu: ${e.toString()}');
    }
  }

  /// Fetch menu items by menu ID
  Future<List<MenuItem>> getMenuItems(String menuId) async {
    try {
      final itemsSnapshot = await _firestore
          .collection('menu_items')
          .where('menu_id', isEqualTo: menuId)
          .get();

      final docs = (itemsSnapshot.docs as List).cast<dynamic>();
      return docs.map<MenuItem>((doc) {
        return MenuItem.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to load menu items: ${e.toString()}');
    }
  }
}
