import 'api_service.dart';

class MedicineService {
  static Future<Map<String, dynamic>> getMedicines() async {
    return await ApiService.get('/medicine');
  }

  static Future<Map<String, dynamic>> getMedicine(String id) async {
    return await ApiService.get('/medicine/$id');
  }

  static Future<Map<String, dynamic>> createMedicine({
    required String name,
    required String dosage,
    String? unit,
    String? color,
    String? instructions,
    int? stockCount,
  }) async {
    return await ApiService.post('/medicine', {
      'name': name,
      'dosage': dosage,
      if (unit != null) 'unit': unit,
      if (color != null) 'color': color,
      if (instructions != null) 'instructions': instructions,
      if (stockCount != null) 'stockCount': stockCount,
    });
  }

  static Future<Map<String, dynamic>> updateMedicine(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await ApiService.put('/medicine/$id', data);
  }

  static Future<Map<String, dynamic>> deleteMedicine(String id) async {
    return await ApiService.delete('/medicine/$id');
  }
}
