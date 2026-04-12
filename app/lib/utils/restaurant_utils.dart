import 'package:nomnom_safe/models/restaurant.dart';

/// Normalized cuisine label for filters (empty → [Restaurant.cuisineNotSpecifiedDisplay]).
String cuisineFilterLabel(Restaurant r) {
  final t = r.cuisine.trim();
  return t.isEmpty ? Restaurant.cuisineNotSpecifiedDisplay : t;
}

List<String> extractAvailableCuisines(List<Restaurant> restaurants) {
  final cuisines = restaurants.map(cuisineFilterLabel).toSet().toList();
  cuisines.sort();
  return cuisines;
}

List<Restaurant> filterRestaurantsByCuisine(
  List<Restaurant> allRestaurants,
  List<String> selectedCuisines,
) {
  if (selectedCuisines.isEmpty) return allRestaurants;
  return allRestaurants
      .where((r) => selectedCuisines.contains(cuisineFilterLabel(r)))
      .toList();
}
