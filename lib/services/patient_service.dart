import 'api_service.dart';

class PatientService {
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get('/patient/profile');
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    return await ApiService.put('/patient/profile', data);
  }
}
