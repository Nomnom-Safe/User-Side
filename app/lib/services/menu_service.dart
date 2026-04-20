import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_safe/models/menu.dart';
import 'package:nomnom_safe/models/menu_item.dart';

/// Service class to handle menu-related Firestore operations
class MenuService {
  final FirebaseFirestore _firestore;

  MenuService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch a menu by business (restaurant) ID
  Future<Menu?> getMenuByRestaurantId(String restaurantId) async {
    try {
      final menuSnapshot = await _firestore
          .collection('menus')
          .where('business_id', isEqualTo: restaurantId)
          .limit(1)
          .get();

      if (menuSnapshot.docs.isEmpty) return null;

      final menuDoc = menuSnapshot.docs.first;
      return Menu.fromJson({'id': menuDoc.id, ...menuDoc.data()});
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

      return itemsSnapshot.docs.map<MenuItem>((doc) {
        return MenuItem.fromJson({'id': doc.id, ...doc.data()});
      }).toList();
    } catch (e) {
      throw Exception('Failed to load menu items: ${e.toString()}');
    }
  }
}
