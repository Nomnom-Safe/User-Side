---
marp: true
size: 4:3
paginate: true
title: Individual Project Week 9 Progress Report - Anna Dinius
---

# Week 9 Progress Report

## (11/17/2025 - 11/23/2025)

> ### _NomNom Safe_
>
> - Anna Dinius

---

## Week 9 Milestones Completed (4/4)

✅ Epic requirement: User profile feature

- ✅ Designed a user profile schema
  - _Fulfills sub requirement 4.1_
- ✅ Implemented profile CRUD operations and persistence
  - _Fulfills sub requirement 4.2_
- ✅ Secured profile data and enforced access control
  - _Fulfills sub requirement 4.3_

---

## Surplus Delivery

- Refactored some components for reusability, flexibility, and maintainability

---

## LoC Summary

- **Total**: 4,097
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under `lib` and `test` and their subdirectories.

---

- **Breakdown** (top-level files, controllers, and models):
  - `lib\controllers\edit_profile_controller.dart`: 47
  - `lib\firebase_options.dart`: 70
  - `lib\main.dart`: 117
  - `lib\models\address.dart`: 32
  - `lib\models\allergen.dart`: 9
  - `lib\models\menu.dart`: 22
  - `lib\models\menu_item.dart`: 34
  - `lib\models\restaurant.dart`: 58
  - `lib\models\user.dart`: 32

---

- **Breakdown** (navigation & providers):
  - `lib\navigation\nav_destination.dart`: 24
  - `lib\navigation\nav_utils.dart`: 30
  - `lib\navigation\route_constants.dart`: 9
  - `lib\navigation\route_tracker.dart`: 3
  - `lib\providers\auth_state_provider.dart`: 72

---

- **Breakdown** (screens):
  - `lib\screens\edit_profile_screen.dart`: 272
  - `lib\screens\home_screen.dart`: 201
  - `lib\screens\menu_screen.dart`: 238
  - `lib\screens\profile_screen.dart`: 192
  - `lib\screens\restaurant_screen.dart`: 134
  - `lib\screens\sign_in_screen.dart`: 183
  - `lib\screens\sign_up_screen.dart`: 135

---

- **Breakdown** (services, theme, & utils):
  - `lib\services\address_service.dart`: 21
  - `lib\services\allergen_service.dart`: 44
  - `lib\services\auth_service.dart`: 166
  - `lib\services\menu_service.dart`: 38
  - `lib\services\restaurant_service.dart`: 58
  - `lib\theme\nomnom_theme.dart`: 23
  - `lib\theme\theme_constants.dart`: 13
  - `lib\utils\allergen_utils.dart`: 18
  - `lib\utils\auth_utils.dart`: 24
  - `lib\utils\restaurant_utils.dart`: 15

---

- **Breakdown** (views):
  - `lib\views\edit_profile_view.dart`: 85
  - `lib\views\sign_up_account_view.dart`: 157
  - `lib\views\sign_up_allergen_view.dart`: 69
  - `lib\views\update_password_view.dart`: 122
  - `lib\views\verify_current_password_view.dart`: 68

---

- **Breakdown** (widgets):
  - `lib\widgets\allergen_chip.dart`: 25
  - `lib\widgets\allergen_filter.dart`: 70
  - `lib\widgets\filter_modal.dart`: 107
  - `lib\widgets\multi_select_checkbox_list.dart`: 26
  - `lib\widgets\nomnom_appbar.dart`: 59
  - `lib\widgets\nomnom_scaffold.dart`: 48
  - `lib\widgets\password_field.dart`: 37
  - `lib\widgets\restaurant_card.dart`: 84
  - `lib\widgets\restaurant_link.dart`: 60
  - `lib\widgets\text_form_field_with_controller.dart`: 40

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
  - `test\widgets\filter_widget_test.dart`: 71
  - `test\widgets\nomnom_safe_appbar_widget_test.dart`: 15
  - `test\widgets\restaurant_card_widget_test.dart`: 26
  - `test\widgets\restaurant_link_widget_test.dart`: 21

---

## 🔥 Burndown rates

- 4/4 week 9 _milestones/requirements_ completed
  - 100% total
  - ~14% per day

---

- 4/5 sprint 2 _epic requirements_ completed
  - 80% total
  - 20% per week
  - ~3% per day
- 12/15 sprint 2 _sub requirements_ completed
  - 80% total
  - 20% per week
  - ~3% per day
- 16/20 sprint 2 _total requirements_ completed
  - 80% total
  - 20% per week
  - ~3% per day
