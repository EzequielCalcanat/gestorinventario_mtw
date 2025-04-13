class Client {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null) {
      throw Exception("Client.fromMap error: 'id' is null. Map: $map");
    }

    return Client(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
