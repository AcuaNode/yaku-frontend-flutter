import '../config/api_config.dart';
import 'http_client.dart';

class Farm {
  final int id;
  final String name;
  final int ownerId;
  final String address;
  const Farm({required this.id, required this.name, required this.ownerId, required this.address});
  factory Farm.fromJson(Map<String, dynamic> j) => Farm(
    id: j['id'] as int,
    name: j['name']?.toString() ?? '',
    ownerId: (j['ownerId'] as num?)?.toInt() ?? 0,
    address: j['address']?.toString() ?? '',
  );
}

Future<Farm?> getUserFarm(int userId) async {
  try {
    final res = await httpClient.get(ApiEndpoints.farmsBase);
    final list = res.data as List? ?? [];
    if (list.isEmpty) return null;
    final farms = list.map((e) => Farm.fromJson(e as Map<String, dynamic>)).toList();
    return farms.firstWhere((f) => f.ownerId == userId, orElse: () => farms.first);
  } catch (_) { return null; }
}

Future<Farm> createFarm({required String name, required String address}) async {
  final res = await httpClient.post(ApiEndpoints.farmsBase, data: {'name': name, 'address': address});
  return Farm.fromJson(res.data as Map<String, dynamic>);
}

Future<String> generateFarmToken(int farmId) async {
  final res = await httpClient.post(ApiEndpoints.createFarmToken(farmId));
  return (res.data['token'] ?? '') as String;
}
