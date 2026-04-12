---
marp: true
size: 4:3
paginate: true
title: Individual Project Week 2 Progress Report - Anna Dinius
---

# Week 2 Progress Report

## (9/15/2025 - 9/21/2025)

> ### _NomNom Safe_
>
> - Anna Dinius

---

## Milestones Completed

✅ Design and set up OOP database with data
✅ Define `Restaurant` class
✅ Develop a minimal, functional UI for allergen input and restaurant list

---

## Carryover Items

- Write unit tests for calls to the database

---

## Surplus Delivery

- Defined `Allergen` class
- Defined `Address` class
- Defined `Menu` class
- Defined `MenuItem` class
- Created reusable AI prompt to generate sample data
- Created JS script to upload JSON data to FireStore DB

---

## LoC Summary

- **Total**: 416
- **Counting rules**: Excludes empty lines and comment-only lines. Inline comments on code lines are still counted.
- **Files scanned**: All files under `lib` and its subdirectories.

---

- **Breakdown**:
  - `lib/main.dart`: 23 lines
  - `lib/firebase_options.dart`: 74 lines
  - `lib/services/allergen_service.dart`: 16 lines
  - `lib/screens/home_screen.dart`: 82 lines
  - `lib/widgets/restaurant_card.dart`: 40 lines
  - `lib/widgets/allergen_filter.dart`: 41 lines
  - `lib/models/entities/allergen.dart`: 24 lines
  - `lib/models/entities/address.dart`: 29 lines
  - `lib/models/entities/menu.dart`: 9 lines
  - `lib/models/entities/menu_item.dart`: 29 lines
  - `lib/models/entities/restaurant.dart`: 49 lines

---

## 🔥 Burndown rate

- 3/4 Week 2 milestones completed
  - 75% per week
  - ~11% per day
- 3/16 Sprint 1 milestones completed
  - ~19% per week
  - ~3% per day

---

## Changes

- Initial AI choice: assisted (#2)
- Changed to: combination of assisted (#2) and vibe (#3)
  - My goal is to rely less on AI as I become more familiar with Flutter/Dart

---

## How I Worked With AI During Week 2

- Use AI to generate one small piece of the app at a time
  - e.g. a widget, a screen, a function
- Examine the AI's code
- Use AI to explain pieces of code I don't understand
- Place the AI's code into my project
- Test the code to make sure it worked
- Copy & paste errors into AI (if needed) to debug
- Use AI to ensure I understand why the errors occurred & why the fix worked
