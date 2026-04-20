import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/address_service.dart';

void main() {
  group('AddressService', () {
    test('returns Unknown for empty id', () async {
      final fs = FakeFirebaseFirestore();
      final service = AddressService(fs);
      final addr = await service.getRestaurantAddress('');
      expect(addr, 'Unknown');
    });

    test('returns Unknown when doc missing', () async {
      final fs = FakeFirebaseFirestore();
      final service = AddressService(fs);
      final addr = await service.getRestaurantAddress('missing');
      expect(addr, 'Unknown');
    });

    test('returns formatted address when document exists', () async {
      final fs = FakeFirebaseFirestore();
      await fs.collection('addresses').doc('addr1').set({
        'street': '1 Main St',
        'city': 'Newport',
        'state': 'KY',
        'zipCode': '41071',
      });
      final service = AddressService(fs);
      final addr = await service.getRestaurantAddress('addr1');
      expect(addr, '1 Main St, Newport, KY 41071');
    });
  });
}
