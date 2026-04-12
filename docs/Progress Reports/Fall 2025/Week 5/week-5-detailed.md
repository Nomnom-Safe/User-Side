# Week 5 Detailed Progress Report (branch: feature/ui-upgrade)

Summary:

- Performed a repository-wide rename of the Flutter app from `nomnom_safe` to `app`.
- Regenerated platform and build files for Android, iOS, macOS, Linux and Windows.
  - Unsuccessful attempt to fix persistent error occurring within `android/` directory.
- Added and organized many unit tests for model, widget, service, and util tests.
- Added automation tooling: `scripts/update_file_tree.py` and `scripts/compare_tree.py` and improved `scripts/loc_counter.py`.
- Updated `docs/tentative-file-structure.txt` to reflect the new `app/` structure and top-level scripts and renamed to `docs/file-structure.txt`.
- Moved model files from `models/entities/` into `models/` folder, removed `entities/` folder, and adjusted imports accordingly.

---

## File Modifications

- Renamed `nomnom_safe/` → `app/` (top-level application folder). Many paths in the repository were updated to reflect the new `app/` folder.
- Platform project files were regenerated under `app/android`, `app/ios`, `app/macos`, `app/linux`, `app/windows`.
- Renamed `app/utilities/` → `app/utils` (utilities directory). Follows Dart naming convention.
- Removed legacy `test/firebase_test.dart` and unused `test/widget_test.dart`.
- Renamed various functions and variables across the codebase to improve clarity.
- Added and updated explanatory code comments.
- Created and applied a basic NomNom Safe theme.
- Refactored `allergen_service.dart` and logic of `home_screen.dart` state variables.
- Optimized code by separating business logic from UI logic and implementing helper methods.
- Extracted reusable components into flexible, reusable widgets.
- Implemented subtle UI improvements.

---

## New files and scripts

- Many unit tests were added, covering models, services, utilities, and widgets.
  - Notable test files added:
    - `app/test/models/*_model_test.dart`
    - `app/test/services/*_service_test.dart`
    - `app/test/utils/*_utils_test.dart`
    - `app/test/widgets/*_widget_test.dart`
- New tooling added under `scripts/` to keep the documentation file-structure in sync with the filesystem (`update_file_tree.py`, `compare_tree.py`).
  - `scripts/update_file_tree.py` — Script to generate an ASCII tree of the repository and write it to `docs/file-structure.txt` with specific files and directories to skip.
  - `scripts/compare_tree.py` — Helper script to compare the generated tree file with the actual filesystem and report missing/extra entries.
- `scripts/loc_counter.py` — (existing) Updated to remove `nomnom_safe/` (now `app/`) from output.

---

## Note

- The docs tree includes a snapshot at a specific depth (default depth used when generating). If you need a deeper or shallower generated tree, re-run `scripts/update_file_tree.py --depth N`.
