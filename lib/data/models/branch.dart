class Branch {
  final String id;
  final String name;
  final String? location;

  Branch({
    required this.id,
    required this.name,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
    };
  }

  factory Branch.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null) {
      throw Exception("Branch.fromMap error: 'id' is null. Map: $map");
    }

    return Branch(
      id: map['id'] as String,
      name: map['name'] as String,
      location: map['location'] as String?,
    );
  }

}
