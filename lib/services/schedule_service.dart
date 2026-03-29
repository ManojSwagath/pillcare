import 'api_service.dart';

class ScheduleService {
  static Future<Map<String, dynamic>> getSchedules() async {
    return await ApiService.get('/schedule');
  }

  static Future<Map<String, dynamic>> getTodaySchedules() async {
    return await ApiService.get('/schedule/today');
  }

  static Future<Map<String, dynamic>> createSchedule({
    required String medicineId,
    required String time,
    String repeatType = 'daily',
    List<int>? daysOfWeek,
    String? mealInstruction,
    String? notes,
  }) async {
    return await ApiService.post('/schedule', {
      'medicineId': medicineId,
      'time': time,
      'repeatType': repeatType,
      if (daysOfWeek != null) 'daysOfWeek': daysOfWeek,
      if (mealInstruction != null) 'mealInstruction': mealInstruction,
      if (notes != null) 'notes': notes,
    });
  }

  static Future<Map<String, dynamic>> updateSchedule(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await ApiService.put('/schedule/$id', data);
  }

  static Future<Map<String, dynamic>> deleteSchedule(String id) async {
    return await ApiService.delete('/schedule/$id');
  }
}
