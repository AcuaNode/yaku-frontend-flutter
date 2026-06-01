import '../config/api_config.dart';
import '../domain/equipment.dart';
import 'http_client.dart';

Future<List<Equipment>> getEquipment() async {
  final res = await httpClient.get(ApiEndpoints.equipmentBase);
  final list = res.data as List? ?? [];
  return list.map((e) => Equipment.fromJson(e as Map<String, dynamic>)).toList();
}

Future<Equipment> createEquipment({required String type, required String name, required String physicalCode}) async {
  final res = await httpClient.post(ApiEndpoints.equipmentBase, data: {'type': type, 'name': name, 'physicalCode': physicalCode});
  return Equipment.fromJson(res.data as Map<String, dynamic>);
}

Future<void> deleteEquipment(int id) async {
  await httpClient.delete(ApiEndpoints.equipmentById(id));
}

Future<void> linkEquipment(int equipmentId, int pondId) async {
  await httpClient.post(ApiEndpoints.equipmentLink(equipmentId, pondId));
}
