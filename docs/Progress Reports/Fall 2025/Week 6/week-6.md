---
marp: true
size: 4:3
paginate: true
title: Individual Project Week 6 Progress Report - Anna Dinius
---

# Week 6 Progress Report

## (10/20/2025 - 10/26/2025)

> ### _NomNom Safe_
>
> - Anna Dinius

---

## Week 6 Milestones Completed (4/4)

✅ Implement filter restaurants by cuisine filter

- _Fulfills epic requirement 1_
- ✅ Design the data model to support cuisine tags for restaurants
  - _Fulfills sub requirement 1.1_
- ✅ Implement the filtering UI and connect it to the backend
  - _Fulfills sub requirement 1.2_
- ✅ Write unit tests for filtering logic
  - _Fulfills sub requirement 1.3_

---

## LoC Summary

- **Total**: 1,776
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under `lib` and `test` and their subdirectories.

---

- **Breakdown** (top-level files, models, & screens):
  - `lib\firebase_options.dart`: 70
  - `lib\main.dart`: 23
  - `lib\models\address.dart`: 32
  - `lib\models\allergen.dart`: 9
  - `lib\models\menu.dart`: 10
  - `lib\models\menu_item.dart`: 30
  - `lib\models\restaurant.dart`: 53
  - `lib\screens\home_screen.dart`: 165
  - `lib\screens\restaurant_screen.dart`: 124

---

- **Breakdown** (services, theme, & utils):
  - `lib\services\address_service.dart`: 21
  - `lib\services\allergen_service.dart`: 44
  - `lib\services\restaurant_service.dart`: 58
  - `lib\theme\nomnom_theme.dart`: 23
  - `lib\theme\theme_constants.dart`: 13
  - `lib\utils\allergen_utils.dart`: 18
  - `lib\utils\restaurant_utils.dart`: 15

---

- **Breakdown** (widgets):

  - `lib\widgets\allergen_chip.dart`: 25
  - `lib\widgets\allergen_filter.dart`: 70
  - `lib\widgets\filter.dart`: 110
  - `lib\widgets\nomnom_safe_appbar.dart`: 12
  - `lib\widgets\restaurant_card.dart`: 85
  - `lib\widgets\restaurant_link.dart`: 60

---

- **Breakdown** (tests: smoke, models, & services):
  - `test\main_smoke_test.dart`: 10
  - `test\models\address_model_test.dart`: 16
  - `test\models\allergen_model_test.dart`: 10
  - `test\models\menu_item_model_test.dart`: 46
  - `test\models\menu_model_test.dart`: 11
  - `test\models\restaurant_model_test.dart`: 21
  - `test\services\address_service_test.dart`: 42
  - `test\services\allergen_service_test.dart`: 55
  - `test\services\restaurant_service_test.dart`: 135

---

- **Breakdown** (tests: utils & widgets):
  - `test\utils\allergen_utils_test.dart`: 22
  - `test\utils\restaurant_utils_test.dart`: 148
  - `test\widgets\allergen_chip_widget_test.dart`: 26
  - `test\widgets\allergen_filter_widget_test.dart`: 31
  - `test\widgets\filter_widget_test.dart`: 69
  - `test\widgets\nomnom_safe_appbar_widget_test.dart`: 17
  - `test\widgets\restaurant_card_widget_test.dart`: 26
  - `test\widgets\restaurant_link_widget_test.dart`: 21

---

## 🔥 Burndown rates

- 4/4 week 6 _milestones/requirements_ completed
  - 100% total
  - ~14% per day

---

- 1/5 sprint 2 _epic requirements_ completed
  - 20% total
  - 20% per week
  - ~3% per day
- 3/15 sprint 2 _sub requirements_ completed
  - 20% total
  - 20% per week
  - ~3% per day
- 4/20 sprint 2 _total requirements_ completed
  - 20% total
  - 20% per week
  - ~3% per day
