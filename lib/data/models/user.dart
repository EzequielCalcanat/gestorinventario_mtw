class User {
  final String id;
  final String name;
  final String? email;
  final String password;
  final String role;
  final String? branch_id;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.password,
    required this.role,
    this.branch_id
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      branch_id : map['branch_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'branch_id': branch_id
    };
  }
}
