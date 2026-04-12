import 'package:flutter/material.dart';
import 'package:nomnom_safe/models/restaurant.dart';
import 'package:nomnom_safe/services/address_service.dart';
import 'package:nomnom_safe/services/allergen_service.dart';
import 'package:nomnom_safe/widgets/restaurant_link.dart';
import 'package:nomnom_safe/nav/nav_utils.dart';
import 'package:nomnom_safe/nav/route_constants.dart';
import 'package:nomnom_safe/utils/user_feedback_messages.dart';
import 'package:nomnom_safe/services/service_utils.dart';

/// Screen displaying detailed information about a specific restaurant
class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;
  final AddressService? addressService;
  final AllergenService? allergenService;

  const RestaurantScreen({
    super.key,
    required this.restaurant,
    this.addressService,
    this.allergenService,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  String? address;
  late AddressService _addressService;
  late AllergenService _allergenService;
  List<String> _dietLabels = [];
  bool _startedLoads = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _addressService = widget.addressService ?? AddressService();
    _allergenService = widget.allergenService ?? getAllergenService(context);
    if (!_startedLoads) {
      _startedLoads = true;
      _loadAddress();
      _loadDiets();
    }
  }

  void _loadAddress() async {
    try {
      final result = await _addressService.getRestaurantAddress(
        widget.restaurant.addressId,
      );
      if (mounted) {
        setState(() {
          final r = result?.trim();
          address = (r == null || r.isEmpty || r == 'Unknown')
              ? Restaurant.unavailableDisplay
              : r;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          address = UserFeedbackMessages.loadAddressFailed;
        });
      }
    }
  }

  void _loadDiets() async {
    if (widget.restaurant.diets.isEmpty) return;
    try {
      final labels = await _allergenService.idsToLabels(
        widget.restaurant.diets,
      );
      if (mounted) {
        setState(() {
          _dietLabels = labels;
        });
      }
    } catch (_) {
      // Diets are non-critical; silently degrade
    }
  }

  /// Build the disclaimers section
  Widget _buildDisclaimers(BuildContext context) {
    final disclaimers = widget.restaurant.disclaimers;
    if (disclaimers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disclaimers:', style: Theme.of(context).textTheme.titleMedium),
          ...disclaimers.map(
            (disclaimer) => Text(
              '- $disclaimer',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => replaceIfNotCurrent(
                context,
                AppRoutes.menu,
                arguments: widget.restaurant,
              ),
              tooltip: 'Back to Menu',
            ),
          ),
          const SizedBox(height: 12),
          // Restaurant name
          Text(
            widget.restaurant.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          // Cuisine type
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Cuisine: ${widget.restaurant.cuisine}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          // Today's operating hours
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Hours Today: ${widget.restaurant.todayHours}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // All operating hours
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'All Hours:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...widget.restaurant.displayHourLines.map(
            (line) => Text(line, style: Theme.of(context).textTheme.bodySmall),
          ),
          // Address
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Address: ${address ?? 'Loading...'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // Phone number
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Phone: ${widget.restaurant.displayPhone}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // Website link
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text('Website: '),
              widget.restaurant.hasWebsite
                  ? RestaurantLink(url: widget.restaurant.website)
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(Restaurant.unavailableDisplay),
                    ),
            ],
          ),
          // Dietary accommodations
          if (_dietLabels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dietary Accommodations:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _dietLabels
                          .map((label) => Chip(label: Text(label)))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          // Disclaimer(s)
          if (widget.restaurant.disclaimers.isNotEmpty)
            _buildDisclaimers(context),
        ],
      ),
    );
  }
}
