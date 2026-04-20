import 'package:flutter/material.dart';
import 'package:nomnom_safe/services/service_utils.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/models/user.dart';
import 'package:nomnom_safe/widgets/restaurant_card.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:provider/provider.dart';
import 'package:nomnom_safe/providers/allergen_selection_provider.dart';
import 'package:nomnom_safe/services/restaurant_service.dart';
import 'package:nomnom_safe/utils/allergen_utils.dart';
import 'package:nomnom_safe/widgets/filter_modal.dart';
import 'package:nomnom_safe/utils/restaurant_utils.dart';
import 'package:nomnom_safe/services/auth_service.dart';
import 'package:nomnom_safe/nav/route_tracker.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';
import 'package:nomnom_safe/theme/screen_insets.dart';
import 'package:nomnom_safe/widgets/nomnom_progress.dart';
import 'package:nomnom_safe/widgets/error_banner.dart';

/// Main screen displaying allergen filters and a list of restaurants
class HomeScreen extends StatefulWidget {
  final RestaurantService? restaurantService;
  final AllergenService? allergenService;
  final User? injectedCurrentUser;
  final bool useInjectedCurrentUser;

  const HomeScreen({
    super.key,
    this.restaurantService,
    this.allergenService,
    this.injectedCurrentUser,
    this.useInjectedCurrentUser = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  // Service classes
  late AllergenService _allergenService;
  late RestaurantService _restaurantService;

  // State variables
  bool isLoadingRestaurants = true; // controls loading spinner visibility
  Map<String, String> allergenIdToLabel = {};
  Map<String, String> _allergenLabelToId = {};
  Set<String> _selectedAllergenIds =
      {}; // store IDs instead of Allergen objects
  Set<String> _selectedAllergenLabels = {}; // cached labels for display
  bool isLoadingAllergens = true;
  String? allergenError;
  List<Restaurant> unfilteredRestaurants = []; // all restaurants from Firestore
  List<Restaurant> restaurantList = []; // restaurants to be displayed
  List<String> selectedCuisines = [];
  List<String> availableCuisines = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
    _allergenService = getAllergenService(context);

    // Initialize selection from global provider if available
    try {
      final selectionProvider = context.read<AllergenSelectionProvider>();
      if (_selectedAllergenIds.isEmpty &&
          selectionProvider.selectedIds.isNotEmpty) {
        _selectedAllergenIds = selectionProvider.selectedIds;
      }
    } catch (_) {
      // Provider not present in this test harness — ignore
    }

    if (isLoadingAllergens) {
      _fetchAllergens();
    }
  }

  @override
  void initState() {
    super.initState();

    // allow optional injection for tests
    _restaurantService = (widget.restaurantService ?? RestaurantService());

    // Load restaurants when the widget is first built
    _fetchUnfilteredRestaurants();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _allergenService.clearCache();
    _fetchAllergens();
  }

  void _retryRestaurantLoad() {
    if (_restaurantError == UserFeedbackMessages.filterRestaurantsFailed) {
      _applyAllergenFilter();
    } else {
      _fetchUnfilteredRestaurants();
    }
  }

  /// Fetch allergen labels and update the state if the widget is still mounted
  Future<void> _fetchAllergens() async {
    if (mounted) {
      setState(() {
        isLoadingAllergens = true;
        allergenError = null;
      });
    }
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
          isLoadingAllergens = false;
          allergenError = null;
          _selectedAllergenLabels = selectedLabels.toSet();
        });
      }
      _applyUserAllergensIfLoggedIn();
    } catch (e) {
      if (mounted) {
        setState(() {
          allergenError = UserFeedbackMessages.loadAllergensFailed;
          isLoadingAllergens = false;
        });
      }
    }
  }

  void _applyUserAllergensIfLoggedIn() async {
    final user = widget.useInjectedCurrentUser
        ? widget.injectedCurrentUser
        : AuthService().currentUser;
    if (user == null) {
      return;
    }

    final userAllergenIds = user.allergies.toSet();

    if (userAllergenIds.isNotEmpty) {
      final labels = await _allergenService.idsToLabels(
        userAllergenIds.toList(),
      );
      setState(() {
        _selectedAllergenIds = userAllergenIds;
        _selectedAllergenLabels = labels.toSet();
      });
      // Persist profile-based selection globally
      if (mounted) {
        try {
          context.read<AllergenSelectionProvider>().setSelectedIds(
            userAllergenIds,
          );
        } catch (_) {}
      }
      _applyAllergenFilter();
    }
  }

  String? _restaurantError;

  void _fetchUnfilteredRestaurants() async {
    setState(() {
      isLoadingRestaurants = true;
      _restaurantError = null;
    });

    try {
      final allRestaurants = await _restaurantService.getAllRestaurants();
      if (mounted) {
        setState(() {
          unfilteredRestaurants = allRestaurants;
          restaurantList = allRestaurants;
          _extractAvailableCuisines();
          isLoadingRestaurants = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _restaurantError = UserFeedbackMessages.loadRestaurantsFailed;
          isLoadingRestaurants = false;
        });
      }
    }
  }

  void _extractAvailableCuisines() {
    setState(() {
      availableCuisines = extractAvailableCuisines(restaurantList);
    });
  }

  void _filterRestaurantsByCuisine(List<String> cuisines) {
    setState(() {
      selectedCuisines = cuisines;
      restaurantList = filterRestaurantsByCuisine(
        unfilteredRestaurants,
        cuisines,
      );
    });
  }

  Future<void> _applyAllergenFilter() async {
    if (_selectedAllergenIds.isEmpty) {
      setState(() {
        restaurantList = unfilteredRestaurants;
        _restaurantError = null;
        _extractAvailableCuisines();
      });
      return;
    }

    setState(() {
      isLoadingRestaurants = true;
      _restaurantError = null;
    });

    try {
      final filteredRestaurants = await _restaurantService
          .filterRestaurantsFromList(
            unfilteredRestaurants,
            _selectedAllergenIds.toList(),
          );

      if (mounted) {
        setState(() {
          restaurantList = filteredRestaurants;
          _extractAvailableCuisines();
          isLoadingRestaurants = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _restaurantError = UserFeedbackMessages.filterRestaurantsFailed;
          isLoadingRestaurants = false;
        });
      }
    }
  }

  Widget _buildCuisineFilter(BuildContext context) {
    final allCuisineOptions = extractAvailableCuisines(unfilteredRestaurants);
    final visibleOptions = availableCuisines;

    if (allCuisineOptions.isEmpty) {
      return FilterModal(
        buttonLabel: 'Cuisines',
        title: 'Filter by Cuisine',
        options: const [],
        selectedOptions: selectedCuisines,
        onChanged: (_) {},
        enabled: false,
        disabledTooltip:
            'No cuisine types are available for the loaded restaurants.',
      );
    }

    final canFilter = restaurantList.isNotEmpty && visibleOptions.isNotEmpty;
    if (!canFilter) {
      return FilterModal(
        buttonLabel: 'Cuisines',
        title: 'Filter by Cuisine',
        options: visibleOptions.isNotEmpty ? visibleOptions : allCuisineOptions,
        selectedOptions: selectedCuisines,
        onChanged: _filterRestaurantsByCuisine,
        enabled: false,
        disabledTooltip:
            'No restaurants match your filters. Adjust allergen filters to use cuisine filter.',
      );
    }

    return FilterModal(
      buttonLabel: 'Cuisines',
      title: 'Filter by Cuisine',
      options: visibleOptions,
      selectedOptions: selectedCuisines,
      onChanged: _filterRestaurantsByCuisine,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ScreenInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Allergen Filter
                Expanded(
                  child: isLoadingAllergens
                      ? // Show a loading spinner if allergens haven’t loaded yet
                        Center(child: NomNomProgress.pageIndicator())
                      : allergenError != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ErrorBanner(allergenError!),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                _fetchAllergens();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        )
                      : // Show the allergen filter widget once allergens are loaded
                        FilterModal(
                          buttonLabel: 'Allergens',
                          title: 'Filter by Allergen',
                          options: allergenIdToLabel.values.toList(),
                          selectedOptions: _selectedAllergenIds
                              .map((id) => allergenIdToLabel[id] ?? id)
                              .toList(),
                          onChanged: (selectedLabels) {
                            final matchedIds = selectedLabels
                                .map((label) => _allergenLabelToId[label])
                                .where((id) => id != null)
                                .cast<String>()
                                .toSet();

                            setState(() {
                              _selectedAllergenIds = matchedIds;
                              _selectedAllergenLabels = selectedLabels.toSet();
                            });
                            // Persist selection globally so other screens (menu) can pick it up
                            try {
                              context
                                  .read<AllergenSelectionProvider>()
                                  .setSelectedIds(matchedIds);
                            } catch (_) {}
                            _applyAllergenFilter();
                          },
                        ),
                ),
                if (!isLoadingAllergens && allergenError == null) ...[
                  const SizedBox(width: 12),
                  Expanded(child: _buildCuisineFilter(context)),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _selectedAllergenIds.isNotEmpty
                  ? "The following restaurants offer at least one menu item that doesn't contain ${formatAllergenList(_selectedAllergenLabels.toList(), "or")}:"
                  : UserFeedbackMessages.homeSelectAllergensHint,
            ),
          ),
          // Make the restaurant list take up remaining space
          Expanded(
            child: isLoadingRestaurants
                ? NomNomProgress.centeredPage()
                : _restaurantError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ErrorBanner(_restaurantError!),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton.icon(
                              onPressed: _retryRestaurantLoad,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : restaurantList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _selectedAllergenIds.isNotEmpty
                            ? UserFeedbackMessages.homeNoRestaurantsMatch
                            : UserFeedbackMessages.homeNoRestaurantsAvailable,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(0),
                    itemCount: restaurantList.length,
                    itemBuilder: (context, index) {
                      return RestaurantCard(restaurant: restaurantList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
