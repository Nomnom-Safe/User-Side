class Allergen {
  final String id;
  final String label;

  Allergen({required this.id, required this.label});

  /// Create an Allergen object from JSON data
  factory Allergen.fromJson(String id, Map<String, dynamic> json) {
    return Allergen(id: id, label: json['label'] ?? '');
  }
}
