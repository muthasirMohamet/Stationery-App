class User {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String role; // Admin, Patient, etc.
  final String password; // Store hashed passwords in real apps

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'password': password,
    };
  }
}
