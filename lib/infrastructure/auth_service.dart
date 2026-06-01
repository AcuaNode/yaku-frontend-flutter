import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../domain/user.dart';
import '../utils/token_storage.dart';
import 'http_client.dart';

Map<String, dynamic> _decodeJwt(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return {};
    final payload = parts[1];
    final normalized = base64.normalize(payload);
    return jsonDecode(utf8.decode(base64.decode(normalized))) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

String _mapRole(dynamic raw) {
  final r = raw is List ? (raw.isNotEmpty ? raw[0].toString() : '') : raw?.toString() ?? '';
  if (r.contains('ADMIN')) return 'ADMIN';
  if (r.contains('OPERATOR')) return 'OPERATOR';
  return 'ADMIN';
}

Future<Map<String, dynamic>> _fetchProfile(String username) async {
  try {
    final res = await httpClient.get(
      ApiEndpoints.usersByUsername,
      queryParameters: {'username': username},
    );
    return res.data as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

Future<User> login(String username, String password) async {
  final res = await httpClient.post(ApiEndpoints.signin, data: {
    'username': username,
    'password': password,
  });

  final token = res.data is String
      ? res.data as String
      : (res.data['token'] ?? res.data['accessToken'] ?? '') as String;

  final payload = _decodeJwt(token);
  final profile = await _fetchProfile(username);

  final id = int.tryParse(
        (profile['id'] ?? res.data['id'] ?? payload['id'] ?? 0).toString(),
      ) ??
      0;
  final role = _mapRole(profile['role'] ?? profile['roles'] ?? payload['role'] ?? payload['roles']);
  final firstName = (profile['firstName'] ?? payload['firstName'] ?? '').toString();
  final lastName = (profile['lastName'] ?? payload['lastName'] ?? '').toString();
  final email = (profile['email'] ?? payload['email'] ?? '').toString();

  await TokenStorage.saveSession(
    token: token,
    userId: id,
    username: username,
    firstName: firstName,
    lastName: lastName,
    email: email,
    role: role,
  );

  return User(id: id, username: username, firstName: firstName, lastName: lastName, email: email, role: role);
}

Future<User> register({
  required String username,
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String role,
  String? farmToken,
}) async {
  final body = {
    'username': username,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
    'role': role,
    if (farmToken != null && farmToken.isNotEmpty) 'farmToken': farmToken,
  };

  final res = await httpClient.post(ApiEndpoints.signup, data: body);

  final token = res.data is String
      ? res.data as String
      : (res.data['token'] ?? res.data['accessToken'] ?? '') as String;

  final payload = _decodeJwt(token);
  final id = int.tryParse((res.data['id'] ?? payload['id'] ?? 0).toString()) ?? 0;
  final mappedRole = _mapRole(res.data['role'] ?? res.data['roles'] ?? payload['role']);

  await TokenStorage.saveSession(
    token: token,
    userId: id,
    username: username,
    firstName: firstName,
    lastName: lastName,
    email: email,
    role: mappedRole,
  );

  return User(id: id, username: username, firstName: firstName, lastName: lastName, email: email, role: mappedRole);
}
