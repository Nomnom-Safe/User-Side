import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/models/allergen.dart';

void main() {
  group('AllergenService', () {
    test(
      'idsToLabels and labelsToIds maps convert correctly and handle unknowns',
      () async {
        final fs = FakeFirebaseFirestore();
        await fs.collection('allergens').doc('a1').set({'label': 'Peanuts'});
        await fs.collection('allergens').doc('a2').set({'label': 'Dairy'});
        final service = AllergenService(fs);

        final all = await service.getAllergens();
        expect(all, isA<List<Allergen>>());
        expect(all.map((a) => a.id), containsAll(['a1', 'a2']));

        final labels = await service.idsToLabels(['a1', 'x']);
        expect(labels, containsAll(['Peanuts', 'x']));

        final ids = await service.labelsToIds(['Dairy', 'Unknown']);
        expect(ids, containsAll(['a2', 'Unknown']));
      },
    );

    test('getAllergens returns empty list when no collection', () async {
      final fs = FakeFirebaseFirestore();
      final service = AllergenService(fs);
      final all = await service.getAllergens();
      expect(all, isEmpty);
    });
  });
}
