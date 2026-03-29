import 'api_service.dart';

class CaregiverService {
  static Future<Map<String, dynamic>> linkPatient(String patientEmail) async {
    return await ApiService.post('/caregiver/link', {
      'patientEmail': patientEmail,
    });
  }

  static Future<Map<String, dynamic>> getPatients() async {
    return await ApiService.get('/caregiver/patients');
  }

  static Future<Map<String, dynamic>> getPatientDetails(String patientId) async {
    return await ApiService.get('/caregiver/patients/$patientId');
  }

  static Future<Map<String, dynamic>> unlinkPatient(String patientId) async {
    return await ApiService.delete('/caregiver/patients/$patientId');
  }

  static Future<Map<String, dynamic>> getAlerts({bool unreadOnly = false}) async {
    return await ApiService.get('/caregiver/alerts?unreadOnly=$unreadOnly');
  }

  static Future<Map<String, dynamic>> markAlertRead(String alertId) async {
    return await ApiService.put('/caregiver/alerts/$alertId/read', {});
  }
}
