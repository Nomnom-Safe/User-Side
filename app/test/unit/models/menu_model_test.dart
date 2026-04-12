import 'package:flutter_test/flutter_test.dart';
import 'package:nomnom_safe/models/menu.dart';

void main() {
  test('Menu.fromJson and toJson', () {
    final data = {'id': 'm1', 'business_id': 'b1', 'title': 'Lunch Menu'};
    final menu = Menu.fromJson(data);
    expect(menu.id, 'm1');
    expect(menu.businessId, 'b1');
    expect(menu.title, 'Lunch Menu');
    expect(menu.toJson()['business_id'], 'b1');
    expect(menu.toJson()['title'], 'Lunch Menu');
  });

  test('Menu.fromJson handles missing optional fields', () {
    final data = {'id': 'm2', 'business_id': 'b2'};
    final menu = Menu.fromJson(data);
    expect(menu.title, '');
    expect(menu.items, isEmpty);
  });
}
