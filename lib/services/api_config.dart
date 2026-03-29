class ApiConfig {
  static const String baseUrl = 'http://localhost:5000/api';
  
  static const Duration timeout = Duration(seconds: 30);
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
}
