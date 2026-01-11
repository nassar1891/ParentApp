import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'api_config.dart';

/// Authentication Service
/// Handles login, token storage, and logout

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _studentNameKey = 'student_name';
  static const String _tokenExpiryKey = 'token_expiry';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _cachedToken;

  /// Login with student code
  /// Returns LoginResponse on success, throws Exception on failure
  Future<LoginResponse> login(String studentCode) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'loginCode': studentCode,
        }),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        await _saveToken(loginResponse);
        return loginResponse;
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final error = ApiError.fromJson(jsonDecode(response.body));
        throw Exception(error.message);
      } else {
        throw Exception('فشل تسجيل الدخول. حاول مرة أخرى');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('لا يمكن الاتصال بالخادم. تحقق من اتصال الإنترنت');
    }
  }

  /// Save token and related data to secure storage
  Future<void> _saveToken(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, response.token);
    await prefs.setString(_studentNameKey, response.studentName);
    
    // Calculate expiry time
    final expiry = DateTime.now().add(Duration(seconds: response.expiresIn));
    await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
    
    _cachedToken = response.token;
  }

  /// Get the stored authentication token
  Future<String?> getToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiryStr = prefs.getString(_tokenExpiryKey);

    if (token == null || expiryStr == null) {
      return null;
    }

    // Check if token is expired
    final expiry = DateTime.parse(expiryStr);
    if (DateTime.now().isAfter(expiry)) {
      await logout();
      return null;
    }

    _cachedToken = token;
    return token;
  }

  /// Get stored student name
  Future<String?> getStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_studentNameKey);
  }

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Logout - clear all stored data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_studentNameKey);
    await prefs.remove(_tokenExpiryKey);
    _cachedToken = null;
  }

  /// Get authorization headers for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('غير مسجل الدخول');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
