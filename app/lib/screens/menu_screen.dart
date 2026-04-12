import 'package:flutter/material.dart';
import 'package:nomnom_safe/services/service_utils.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/menu_item.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/widgets/filter_modal.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/services/menu_service.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/providers/allergen_selection_provider.dart';
import 'package:nomnom_safe/models/menu.dart';
import 'package:nomnom_safe/nav/route_constants.dart';

class MenuScreen extends StatefulWidget {
  final Restaurant restaurant;
  final MenuService? menuService;
  final AllergenService? allergenService;

  const MenuScreen({
    super.key,
    required this.restaurant,
    this.menuService,
    this.allergenService,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late AllergenService _allergenService;
  late MenuService _menuService;
  AllergenSelectionProvider? _selectionProvider;

  Map<String, String> allergenIdToLabel = {};
  Map<String, String> _allergenLabelToId = {};
  Set<String> _selectedAllergenIds = {};
  Set<String> _selectedAllergenLabels = {};

  List<MenuItem> filteredMenuItems = [];
  List<MenuItem> allMenuItems = [];
  // Item type filter state
  static const List<String> availableItemTypes = [
    'Sides',
    'Entrees',
    'Desserts',
    'Drinks',
    'Appetizers',
  ];
  List<String> selectedItemTypes = [];
  Menu? restaurantMenu;

  bool isLoadingMenu = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _allergenService = widget.allergenService ?? getAllergenService(context);

    // allow injection for tests
    _menuService = widget.menuService ?? MenuService();

    // Initialize selection provider and subscribe to changes (if present)
    try {
      _selectionProvider = context.read<AllergenSelectionProvider>();
      if (_selectedAllergenIds.isEmpty &&
          _selectionProvider!.selectedIds.isNotEmpty) {
        _selectedAllergenIds = _selectionProvider!.selectedIds;
      }
      _selectionProvider!.addListener(_onSelectionChanged);
    } catch (_) {
      _selectionProvider = null;
    }

    // Only fetch once
    if (allergenIdToLabel.isEmpty) {
      _loadData();
    }
  }

  void _onSelectionChanged() async {
    if (_selectionProvider == null) return;
    final ids = _selectionProvider!.selectedIds;
    final labels = await _allergenService.idsToLabels(ids.toList());
    if (!mounted) return;
    setState(() {
      _selectedAllergenIds = ids;
      _selectedAllergenLabels = labels.toSet();
      _updateFilteredMenuItems();
    });
  }

  @override
  void dispose() {
    try {
      _selectionProvider?.removeListener(_onSelectionChanged);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadData() async {
    await _fetchAllergens();
    _fetchMenuItems();
  }

  /// Fetch menu and menu items for the restaurant
  Future<void> _fetchMenuItems() async {
    setState(() {
      isLoadingMenu = true;
    });

    try {
      // First get the menu for this restaurant
      restaurantMenu = await _menuService.getMenuByRestaurantId(
        widget.restaurant.id,
      );

      if (restaurantMenu != null) {
        // Then get all menu items for that menu
        allMenuItems = await _menuService.getMenuItems(restaurantMenu!.id);
        _updateFilteredMenuItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading menu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingMenu = false;
        });
      }
    }
  }

  Future<void> _fetchAllergens() async {
    try {
      final idToLabel = await _allergenService.getAllergenIdToLabelMap();
      final labelToId = await _allergenService.getAllergenLabelToIdMap();
      final selectedLabels = await _allergenService.idsToLabels(
        _selectedAllergenIds.toList(),
      );

      if (mounted) {
        setState(() {
          allergenIdToLabel = idToLabel;
          _allergenLabelToId = labelToId;
          _selectedAllergenLabels = selectedLabels.toSet();
        });
        // Recompute filtered items now that we have allergen labels available
        _updateFilteredMenuItems();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not load allergens.')));
      }
    }
  }

  void _updateFilteredMenuItems() {
    setState(() {
      // Start from all items
      var results = List<MenuItem>.from(allMenuItems);

      // Apply allergen filtering (exclude items containing any selected allergen)
      if (_selectedAllergenIds.isNotEmpty) {
        results = results.where((item) {
          return !item.allergens.any(
            (allergenId) => _selectedAllergenIds.contains(allergenId),
          );
        }).toList();
      }

      // Apply item type filtering (include only items whose itemType is selected)
      if (selectedItemTypes.isNotEmpty) {
        results = results.where((item) {
          // Convert plural capitalized display names to singular lowercase for comparison
          return selectedItemTypes
              .map((type) => type.toLowerCase().replaceAll(RegExp('s\$'), ''))
              .contains(item.itemType.toLowerCase());
        }).toList();
      }

      filteredMenuItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Restaurant name and navigation buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => replaceIfNotCurrent(context, AppRoutes.home),
                tooltip: 'Back to Home',
              ),
              Expanded(
                child: Text(
                  widget.restaurant.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.restaurant),
                onPressed: () {
                  replaceIfNotCurrent(
                    context,
                    AppRoutes.restaurant,
                    arguments: widget.restaurant,
                  );
                },
                tooltip: 'Restaurant Details',
              ),
            ],
          ),
        ),
        // Allergen filter
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Allergen Filter
              Expanded(
                child: FilterModal(
                  buttonLabel: 'Allergens',
                  title: 'Filter by Allergen',
                  options: allergenIdToLabel.values.toList(),
                  selectedOptions: _selectedAllergenLabels.toList(),
                  onChanged: (selectedLabels) {
                    final matchedIds = selectedLabels
                        .map((label) => _allergenLabelToId[label])
                        .where((id) => id != null)
                        .cast<String>()
                        .toSet();

                    setState(() {
                      _selectedAllergenIds = matchedIds;
                      _selectedAllergenLabels = selectedLabels.toSet();
                      _updateFilteredMenuItems();
                    });
                    // Persist selection so HomeScreen and other screens update
                    try {
                      context.read<AllergenSelectionProvider>().setSelectedIds(
                        matchedIds,
                      );
                    } catch (_) {}
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Item type filter (uses reusable Filter widget)
              Expanded(
                child: FilterModal(
                  buttonLabel: 'Item Types',
                  title: 'Filter by item type',
                  options: availableItemTypes,
                  selectedOptions: selectedItemTypes,
                  onChanged: (selected) {
                    setState(() {
                      // Keep original capitalization for display
                      selectedItemTypes = selected.toList();
                      _updateFilteredMenuItems();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        // Filter description text
        if (_selectedAllergenLabels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Showing menu items that do not contain your selected allergens:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        // Menu items list
        Expanded(
          child: isLoadingMenu
              ? const Center(child: CircularProgressIndicator())
              : filteredMenuItems.isEmpty
              ? const Center(
                  child: Text('No menu items match your allergen filters'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  itemCount: filteredMenuItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredMenuItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.description.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(item.description),
                              ),
                            if (item.hasIngredients)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Ingredients: ${item.ingredients}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[700]),
                                ),
                              ),
                            if (item.allergens.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Contains: ${item.allergens.map((id) => allergenIdToLabel[id] ?? id).join(", ").toLowerCase()}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
