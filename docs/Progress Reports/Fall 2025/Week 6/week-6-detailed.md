# Individual Project

## Week 6 Detailed Progress Report on branch `feature/cuisine-filter`

### Summary

- Implemented a filter button to filter the restaurant list by cuisine

### New files

#### `widgets\filter.dart`

- Stateless, reusable widget
- Initially displays an `ElevatedButton` with an optional filter icon
  - `onPressed` opens a dialog box with:
    - a multi-select list of the available options
    - an 'x' button to close the dialog box
    - a 'Clear Selection' button to deselect all selected options
    - an 'Apply' button to close the dialog box and apply the selected options to the results list

#### `tests\restaurant_utils_test.dart`

- Contains 8 unit tests (including edge cases) for cuisine filtering logic in `utils\restaurant_utils.dart`:

#### `tests\filter_widget_test.dart`

- Contains 2 UI unit tests for `widgets\filter.dart`

### File Modifications

#### `screens\home_screen.dart`

- New imports:
  - `widgets\filter.dart`
  - `utils\restaurant_utils.dart`
- New state variables:
  - `List<String> availableCuisines`
    - Stores a list of all cuisines available based on the restaurant results
  - `List<String> selectedCuisines`
    - Stores a list of cuisines selected by the user
- New functions:
  - `_extractAvailableCuisines()`
    - Calls the `extractAvailableCuisines()` function from `utils\restaurant_utils.dart` and assigns the output to `availableCuisines` (state variable)
  - `_filterRestaurantsByCuisine()`
    - Assigns a list of cuisines selected by the user to `selectedCuisines` (state variable)
    - Calls the `filterRestaurantsByCuisine()` function from `utils\restaurant_utils.dart` and assigns the output to `restaurantList` (state variable)
- Implementations of new functions:
  - Added `_extractAvailableCuisines()` function call to `_applyAllergenFilter()` and `_fetchUnfilteredRestaurants()` after `restaurantList` (state variable) is updated.
- New cuisine filter UI:
  - Added custom `Filter` widget that appears directly below the allergen filters
  - Conditionally appears as long as there is at least 1 restaurant in the results list and at least 1 of them has a cuisine associated with it

#### `utils\restaurant_utils.dart`

- New import:
  - `models\restaurant.dart`
- New functions:
  - `extractAvailableCuisines(List<Restaurant> restaurants)`
    - Uses `.map()` to extract the cuisines from each restaurant and sort the cuisines alphabetically and returns the sorted `List<String>`
  - `filterRestaurantsByCuisine(List<Restaurant> allRestaurants, List<String> selectedCuisines,)`
    - Uses `.where()` to remove restaurants from the list that do not have one of the cuisines selected by the user and returns the `List<Restaurant>`
