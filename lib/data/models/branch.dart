class Branch {
  final String id;
  final String name;
  final String? location;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  Branch({
    required this.id,
    required this.name,
    this.location,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null) {
      throw Exception("Branch.fromMap error: 'id' is null. Map: $map");
    }

    return Branch(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
