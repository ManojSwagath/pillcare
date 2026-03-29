class ApiConfig {
  static const String baseUrl = 'https://pillcare-82ki.onrender.com/api';
  
  static const Duration timeout = Duration(seconds: 30);
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
}
