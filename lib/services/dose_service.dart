import 'api_service.dart';

class DoseService {
  static Future<Map<String, dynamic>> respondToDose({
    required String doseLogId,
    required String status,
    String? notes,
  }) async {
    return await ApiService.post('/dose/respond', {
      'doseLogId': doseLogId,
      'status': status,
      if (notes != null) 'notes': notes,
    });
  }

  static Future<Map<String, dynamic>> getDoseHistory({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    String endpoint = '/dose/history?page=$page&limit=$limit';
    if (status != null) endpoint += '&status=$status';
    return await ApiService.get(endpoint);
  }

  static Future<Map<String, dynamic>> getTodayDoses() async {
    return await ApiService.get('/dose/today');
  }

  static Future<Map<String, dynamic>> getAdherenceStats({int days = 7}) async {
    return await ApiService.get('/dose/stats?days=$days');
  }
}
