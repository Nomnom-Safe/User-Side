# Week 4 Detailed Progress Report (branch: feature/ui-upgrade)

Modified:

- `main.dart`
- `home_screen.dart`
- `restaurant_screen.dart`
- `allergen_filter.dart`
- `restaurant_card.dart`
- `pubspec.lock`
- `pubspec.yaml`

New:

- `nomnom_safe/lib/utilities/` (new directory)
  - `allergen_utility.dart` (added)
  - `restaurant_utility.dart` (empty)
- `restaurant_link.dart` (new)

---

## High-level change report (per file)

- `pubspec.yaml`

  - Added dependency: `url_launcher: ^6.2.5`
  - Dev deps include `fake_cloud_firestore` and `mockito` previously added during testing; `pubspec.yaml` now contains these entries.
  - `pubspec.lock` also changed as a result of running `flutter pub get`.

- `main.dart`

  - UI theme update: added `appBarTheme` with custom background color and white foreground color.

- `home_screen.dart`

  - Added import and usage of `allergen_utility.dart`.
  - New UI visibility block showing a sentence listing selected allergens and the filtered result description using `formatAllergenList`.

- `restaurant_screen.dart`

  - Added import and usage of `restaurant_link.dart` to show a clickable website link (`RestaurantLink`).
  - Layout refinements: swapped titles to use constant app bar title "NomNom Safe" and converted several `SizedBox` spacings into `Padding` for consistent spacing.

- `allergen_filter.dart`

  - Improved accessibility/visuals: added an introductory `Text.rich` explaining the filter, added `runSpacing` to the Wrap, and wrapped clear button in a `Visibility` + padding.

- `restaurant_card.dart`

  - Layout changes: added padding around the `Inkwell`, adjusted margins around the `Card`, and converted several `SizedBox` spacings into `Padding` for consistent spacing.
  - Text content changed to show "Cuisine:" label instead of raw value in previous position alone.

- `restaurant_link.dart` (new)

  - New widget that uses `url_launcher` Link to open restaurant website in a new tab/window. Ensures URL is parsed safely.

- `allergen_utility.dart` (new)

  - Adds `formatAllergenList(List<String> allergens, String conjunction)` helper to nicely format selected allergen labels for UI.

- `restaurant_utility.dart` (new/empty)

  - File created for future use, but is currently empty.

---

## Key diffs / excerpts

- Added `url_launcher` to `pubspec.yaml`.
- Home screen: introduced `formatAllergenList(selectedAllergens, "or")` usage.
- Restaurant screen: replaced direct website text with `RestaurantLink(url: widget.restaurant.website)`.
