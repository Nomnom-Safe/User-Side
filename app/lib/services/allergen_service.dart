import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nomnom_safe/models/allergen.dart';

/// Service class to handle allergen-related Firestore operations
class AllergenService {
  final FirebaseFirestore _firestore;

  List<Allergen>? _cachedAllergens;
  Map<String, String>? _cachedIdToLabel;
  Map<String, String>? _cachedLabelToId;

  AllergenService([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Clears in-memory caches so the next read hits Firestore again.
  void clearCache() {
    _cachedAllergens = null;
    _cachedIdToLabel = null;
    _cachedLabelToId = null;
  }

  /// Get list of Allergen objects
  Future<List<Allergen>> getAllergens() async {
    if (_cachedAllergens != null) return _cachedAllergens!;

    final snapshot = await _firestore.collection('allergens').get();

    final allergens = snapshot.docs.map<Allergen>((doc) {
      return Allergen.fromJson(doc.id, doc.data());
    }).toList();

    _cachedAllergens = allergens;

    // Build and cache maps once
    _cachedIdToLabel = _buildIdToLabelMap(allergens);
    _cachedLabelToId = _buildLabelToIdMap(allergens);

    return allergens;
  }

  /// --- Helper functions ---
  Map<String, String> _buildIdToLabelMap(List<Allergen> allergens) => {
    for (var a in allergens) a.id: a.label,
  };

  Map<String, String> _buildLabelToIdMap(List<Allergen> allergens) => {
    for (var a in allergens) a.label: a.id,
  };

  List<String> _extractLabels(List<Allergen> allergens) =>
      allergens.map((a) => a.label).toList();

  List<String> _extractIds(List<Allergen> allergens) =>
      allergens.map((a) => a.id).toList();

  /// --- Public API ---
  /// Get map of allergen ids to allergen labels
  Future<Map<String, String>> getAllergenIdToLabelMap() async {
    if (_cachedIdToLabel != null) return _cachedIdToLabel!;

    await getAllergens();
    return _cachedIdToLabel!;
  }

  /// Get map of allergen labels to allergen ids
  Future<Map<String, String>> getAllergenLabelToIdMap() async {
    if (_cachedLabelToId != null) return _cachedLabelToId!;

    final allergens = await getAllergens();
    return _buildLabelToIdMap(allergens);
  }

  /// Get list of allergen labels
  Future<List<String>> getAllergenLabels() async {
    if (_cachedAllergens != null) return _extractLabels(_cachedAllergens!);

    final allergens = await getAllergens();
    return _extractLabels(allergens);
  }

  /// Get list of allergen ids
  Future<List<String>> getAllergenIds() async {
    if (_cachedAllergens != null) return _extractIds(_cachedAllergens!);

    final allergens = await getAllergens();
    return _extractIds(allergens);
  }

  /// Get the label for a given allergen ID
  Future<String?> getLabelForId(String id) async {
    final map = await getAllergenIdToLabelMap();
    return map[id];
  }

  /// Get the ID for a given allergen label
  Future<String?> getIdForLabel(String label) async {
    final map = await getAllergenLabelToIdMap();
    return map[label];
  }

  /// Convert a list of IDs into their labels
  Future<List<String>> idsToLabels(List<String> ids) async {
    final map = await getAllergenIdToLabelMap();
    return ids.map((id) => map[id] ?? id).toList();
  }

  /// Convert a list of labels into their IDs
  Future<List<String>> labelsToIds(List<String> labels) async {
    final map = await getAllergenLabelToIdMap();
    return labels.map((label) => map[label] ?? label).toList();
  }
}
