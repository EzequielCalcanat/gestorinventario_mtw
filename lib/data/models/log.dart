class Log {
  final String id;
  final String action;
  final String module;
  final String description;
  final String userName;
  final String userId;
  final String? createdAt;

  Log({
    required this.id,
    required this.action,
    required this.module,
    required this.description,
    required this.userName,
    required this.userId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'module': module,
      'description': description,
      'user_name': userName,
      'user_id': userId,
      'created_at': createdAt,
    };
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    if (map['id'] == null) {
      throw Exception("Log.fromMap error: 'id' is null. Map: $map");
    }

    return Log(
      id: map['id'],
      action: map['action'],
      module: map['module'],
      description: map['description'],
      userName: map['user_name'],
      userId: map['user_id'],
      createdAt: map['created_at'],
    );
  }

}
