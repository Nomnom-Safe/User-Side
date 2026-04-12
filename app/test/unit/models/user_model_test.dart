import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/user.dart';

void main() {
  group('User model - basic', () {
    test('constructs and exposes fields', () {
      final user = User(
        id: 'u1',
        firstName: 'Alice',
        lastName: 'Brown',
        email: 'alice@example.com',
        allergies: ['peanuts', 'dairy'],
      );

      expect(user.id, 'u1');
      expect(user.firstName, 'Alice');
      expect(user.lastName, 'Brown');
      expect(user.email, 'alice@example.com');
      expect(user.allergies, ['peanuts', 'dairy']);
      expect(user.fullName, 'Alice Brown');
    });

    test('toJson returns expected map', () {
      final user = User(
        id: 'u2',
        firstName: 'Bob',
        lastName: 'Smith',
        email: 'bob@example.com',
        allergies: ['shellfish'],
      );

      final json = user.toJson();
      expect(json['id'], 'u2');
      expect(json['first_name'], 'Bob');
      expect(json['last_name'], 'Smith');
      expect(json['email'], 'bob@example.com');
      expect(json['allergies'], ['shellfish']);
    });

    test('fromJson constructs correctly with allergies', () {
      final json = {
        'id': 'u3',
        'first_name': 'Cara',
        'last_name': 'Diaz',
        'email': 'cara@example.com',
        'allergies': ['gluten'],
      };

      final user = User.fromJson(json);
      expect(user.id, 'u3');
      expect(user.firstName, 'Cara');
      expect(user.lastName, 'Diaz');
      expect(user.email, 'cara@example.com');
      expect(user.allergies, ['gluten']);
    });

    test(
      'fromJson handles missing allergies (null or absent) as empty list',
      () {
        final json1 = {
          'id': 'u4',
          'first_name': 'Dana',
          'last_name': 'Evans',
          'email': 'dana@example.com',
          // 'allergies' missing
        };

        final json2 = {
          'id': 'u5',
          'first_name': 'Eli',
          'last_name': 'Fox',
          'email': 'eli@example.com',
          'allergies': null,
        };

        final user1 = User.fromJson(json1);
        final user2 = User.fromJson(json2);

        expect(user1.allergies, isA<List<String>>());
        expect(user1.allergies, isEmpty);

        expect(user2.allergies, isA<List<String>>());
        expect(user2.allergies, isEmpty);
      },
    );

    test('toJson/fromJson roundtrip preserves data', () {
      final initial = User(
        id: 'u6',
        firstName: 'Fay',
        lastName: 'Green',
        email: 'fay@example.com',
        allergies: ['soy', 'eggs'],
      );

      final roundtrip = User.fromJson(initial.toJson());
      expect(roundtrip.id, initial.id);
      expect(roundtrip.firstName, initial.firstName);
      expect(roundtrip.lastName, initial.lastName);
      expect(roundtrip.email, initial.email);
      expect(roundtrip.allergies, initial.allergies);
    });
  });

  group('User model - edge cases', () {
    test('accepts empty strings for fields', () {
      final user = User(id: '', firstName: '', lastName: '', email: '');

      expect(user.id, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.email, '');
      expect(user.allergies, isEmpty);
      expect(user.fullName, ' ');
    });

    test('accepts long strings', () {
      final long = 'x' * 1000;
      final user = User(
        id: long,
        firstName: long,
        lastName: long,
        email: '${long}@example.com',
        allergies: List<String>.filled(50, 'a'),
      );

      expect(user.id.length, 1000);
      expect(user.firstName.length, 1000);
      expect(user.lastName.length, 1000);
      expect(user.email.contains('@'), isTrue);
      expect(user.allergies.length, 50);
    });

    test('fromJson handles missing fields with defaults', () {
      final missing = <String, dynamic>{};
      final user = User.fromJson(missing);
      expect(user.id, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.email, '');
      expect(user.allergies, isEmpty);
    });

    test('preserves allergy list contents including duplicates', () {
      final list = ['a', 'a', 'b'];
      final user = User(
        id: 'dup',
        firstName: 'D',
        lastName: 'U',
        email: 'dup@example.com',
        allergies: list,
      );

      expect(user.allergies, ['a', 'a', 'b']);
    });

    test('mutating provided allergies list affects user (current behavior)', () {
      final source = <String>['x'];
      final user = User(
        id: 'm',
        firstName: 'M',
        lastName: 'U',
        email: 'm@example.com',
        allergies: source,
      );

      // current implementation keeps the reference; modifying source will reflect in user.allergies
      source.add('y');
      expect(user.allergies, containsAll(['x', 'y']));
    });
  });
}
