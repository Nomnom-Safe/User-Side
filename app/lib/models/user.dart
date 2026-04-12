class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> allergies;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.allergies = const [],
  });

  /// Create a User object from JSON data
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    firstName: json['first_name'] ?? '',
    lastName: json['last_name'] ?? '',
    email: json['email'] ?? '',
    allergies: List<String>.from(json['allergies'] ?? []),
  );

  /// Convert a User object to JSON data
  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'allergies': allergies,
  };

  /// Get full name
  String get fullName => '$firstName $lastName';
}
