import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'api_config.dart';
import 'auth_service.dart';

/// Parent API Service
/// Handles all API calls to the TeacherManager Parent API endpoints

class ParentApiService {
  final AuthService _authService = AuthService();

  // Singleton pattern
  static final ParentApiService _instance = ParentApiService._internal();
  factory ParentApiService() => _instance;
  ParentApiService._internal();

  /// Generic GET request with authentication
  Future<dynamic> _get(String url) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('غير مسجل الدخول')) {
        rethrow;
      }
      throw Exception('لا يمكن الاتصال بالخادم. تحقق من اتصال الإنترنت');
    }
  }

  /// Handle API response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 401:
        // Token expired or invalid
        _authService.logout();
        throw Exception('انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى');
      case 404:
        final error = ApiError.fromJson(jsonDecode(response.body));
        throw Exception(error.message);
      default:
        throw Exception('حدث خطأ غير متوقع (${response.statusCode})');
    }
  }

  // ==================== Student Info ====================

  /// Get student information
  /// GET /api/parent/student
  Future<StudentInfo> getStudentInfo() async {
    final data = await _get(ApiConfig.studentUrl);
    return StudentInfo.fromJson(data);
  }

  // ==================== Months ====================

  /// Get all available months
  /// GET /api/parent/months
  Future<List<Month>> getMonths() async {
    final data = await _get(ApiConfig.monthsUrl);
    return (data as List).map((m) => Month.fromJson(m)).toList();
  }

  // ==================== Monthly Report ====================

  /// Get full monthly report (includes everything)
  /// GET /api/parent/report/{monthId}
  Future<MonthlyReport> getMonthlyReport(int monthId) async {
    final data = await _get(ApiConfig.reportUrl(monthId));
    return MonthlyReport.fromJson(data);
  }

  // ==================== Tests ====================

  /// Get tests for a specific month
  /// GET /api/parent/tests/{monthId}
  Future<List<TestResult>> getTests(int monthId) async {
    final data = await _get(ApiConfig.testsUrl(monthId));
    return (data as List).map((t) => TestResult.fromJson(t)).toList();
  }

  // ==================== Exams ====================

  /// Get exams for a specific month
  /// GET /api/parent/exams/{monthId}
  Future<List<ExamResult>> getExams(int monthId) async {
    final data = await _get(ApiConfig.examsUrl(monthId));
    return (data as List).map((e) => ExamResult.fromJson(e)).toList();
  }

  // ==================== Homeworks ====================

  /// Get homeworks for a specific month
  /// GET /api/parent/homeworks/{monthId}
  Future<List<HomeworkResult>> getHomeworks(int monthId) async {
    final data = await _get(ApiConfig.homeworksUrl(monthId));
    return (data as List).map((h) => HomeworkResult.fromJson(h)).toList();
  }

  // ==================== Attendance ====================

  /// Get attendance records for a specific month
  /// GET /api/parent/attendance/{monthId}
  Future<List<Attendance>> getAttendance(int monthId) async {
    final data = await _get(ApiConfig.attendanceUrl(monthId));
    return (data as List).map((a) => Attendance.fromJson(a)).toList();
  }

  // ==================== Payment ====================

  /// Get payment information for a specific month
  /// GET /api/parent/payment/{monthId}
  Future<Payment> getPayment(int monthId) async {
    final data = await _get(ApiConfig.paymentUrl(monthId));
    return Payment.fromJson(data);
  }
}
