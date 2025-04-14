import 'package:flutterinventory/data/models/user.dart';
import 'package:flutterinventory/data/repositories/repository.dart';

class LoginRepository {
  static final Repository<User> _repository = Repository<User>(
    table: 'users',
    fromMap: (map) => User.fromMap(map),
    toMap: (user) => user.toMap(),
    moduleName: "Login"
  );

  static Future<List<User>> getAllUsers({bool? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<int> insertUser(User user) async {
    return await _repository.insert(user);
  }

  static Future<User?> login(String name, String password) async {
    final users = await getAllUsers(isActive: true);
    try {
      return users.firstWhere((u) => u.name == name && u.password == password);
    } catch (e) {
      return null;
    }
  }

  static Future<int> updateUser(User user) async {
    return await _repository.update(user, user.id);
  }

  static Future<int> deleteUser(User user) async {
    return await _repository.delete(user, user.id);
  }
}
