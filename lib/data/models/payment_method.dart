import 'package:uuid/uuid.dart';

class PaymentMethod {
  final String id;
  final String name;
  final bool isActive;
  final String? createdAt;

  PaymentMethod({
    required this.id,
    required this.name,
    this.isActive = true,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null || map['name'] == null) {
      throw Exception("PaymentMethod.fromMap error: 'id' or 'name' is null. Map: $map");
    }

    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      isActive: map['is_active'] == 1,
      createdAt: map['created_at'],
    );
  }

  factory PaymentMethod.create({required String name}) {
    return PaymentMethod(
      id: const Uuid().v4(),
      name: name,
      isActive: true,
      createdAt: null,
    );
  }
}
