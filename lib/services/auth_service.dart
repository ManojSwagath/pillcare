import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final response = await ApiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      if (phone != null) 'phone': phone,
    });

    if (response['success'] == true) {
      final token = response['data']['token'];
      ApiService.setToken(token);
    }

    return response;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response['success'] == true) {
      final token = response['data']['token'];
      ApiService.setToken(token);
    }

    return response;
  }

  static Future<Map<String, dynamic>> getMe() async {
    return await ApiService.get('/auth/me');
  }

  static void logout() {
    ApiService.clearToken();
  }

  static Future<void> updateFcmToken(String fcmToken) async {
    await ApiService.put('/auth/fcm-token', {'fcmToken': fcmToken});
  }
}
