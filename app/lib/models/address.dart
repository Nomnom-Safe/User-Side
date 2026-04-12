class Address {
  final String id;
  final String street;
  final String city;
  final String state;
  final String zipCode;

  Address({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
  });

  /// Create an Address object from JSON data
  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] ?? '',
    street: json['street'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',
    zipCode: json['zipCode'] ?? '',
  );

  /// Convert an Address object to JSON data
  Map<String, dynamic> toJson() => {
    'id': id,
    'street': street,
    'city': city,
    'state': state,
    'zipCode': zipCode,
  };

  /// Get the full address as a single formatted string
  String get full => '$street, $city, $state $zipCode';
}
