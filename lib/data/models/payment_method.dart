class PaymentMethod {
  final String id;
  final String name;
  final String type;
  final bool isActive;
  final String? createdAt;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['name'] == null || map['type'] == null) {
      throw Exception("PaymentMethod.fromMap error: 'id', 'name', or 'type' is null. Map: $map");
    }

    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
    );
  }
}
