import 'package:flutterinventory/data/models/client.dart';
import 'package:flutterinventory/data/repositories/repository.dart';

class ClientRepository {
  static final Repository<Client> _repository = Repository<Client>(
    table: 'clients',
    fromMap: (map) => Client.fromMap(map),
    toMap: (branch) => branch.toMap(),
    moduleName: "Cliente"
  );

  static Future<List<Client>> getAllClients({bool? isActive}) async {
    return await _repository.getAll(isActive: isActive);
  }

  static Future<int> insertClient(Client client) async {
    return await _repository.insert(client);
  }

  static Future<int> updateClient(Client client) async {
    return await _repository.update(client, client.id);
  }

  static Future<int> deleteClient(Client client) async {
    return await _repository.delete(client, client.id);
  }
}