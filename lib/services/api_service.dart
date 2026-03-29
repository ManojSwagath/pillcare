import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> get _headers {
    final headers = Map<String, String>.from(ApiConfig.headers);
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: _headers,
          )
          .timeout(ApiConfig.timeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] ?? 'Something went wrong';
    throw ApiException(message, response.statusCode);
  }
}
