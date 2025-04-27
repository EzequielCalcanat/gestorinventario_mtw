import 'package:flutterinventory/data/models/log.dart';
import 'package:flutterinventory/data/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterinventory/data/repositories/repository.dart';

class LogRepository {
  static final Repository<Log> _logRepository = Repository<Log>(
    table: 'logs',
    moduleName: "Logs",
    fromMap: (map) => Log.fromMap(map),
    toMap: (log) => log.toMap(),
  );

  Future<void> insertLog(Log log) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('logs', log.toMap());
  }

  static Future<List<Log>> getAllLogs({int? isActive}) async {
    return await _logRepository.getAll(isActive: isActive);
  }

  Future<String?> getLoggedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logged_user_id');
  }

  Future<String?> getLoggedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }
}
