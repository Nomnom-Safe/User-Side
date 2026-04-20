import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_safe/models/address.dart';

/// Service class to handle address-related Firestore operations
class AddressService {
  final FirebaseFirestore _firestore;

  AddressService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get the full address string for a given address id
  Future<String?> getRestaurantAddress(String addressId) async {
    if (addressId.isEmpty) return 'Unknown';

    final addressDoc = await _firestore
        .collection('addresses')
        .doc(addressId)
        .get();

    if (!addressDoc.exists) return 'Unknown';

    final addressData = addressDoc.data();
    if (addressData == null) return 'Unknown';

    final address = Address.fromJson({'id': addressDoc.id, ...addressData});
    return address.full;
  }
}
