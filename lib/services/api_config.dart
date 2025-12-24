/// API Configuration
/// Change baseUrl to match your API server address

class ApiConfig {
  // Change this to your API server address
  // For local development: 'http://localhost:5000' or 'http://10.0.2.2:5000' for Android emulator
  // For production: 'https://your-api-domain.com'
  static const String baseUrl = 'https://teachermanager.mahmoudnassar.com';

  // API Endpoints
  static const String authBase = '/api/parent/auth';
  static const String parentBase = '/api/parent';

  // Auth endpoints
  static String get loginUrl => '$baseUrl$authBase/login';

  // Parent API endpoints
  static String get studentUrl => '$baseUrl$parentBase/student';
  static String get monthsUrl => '$baseUrl$parentBase/months';
  
  static String reportUrl(int monthId) => '$baseUrl$parentBase/report/$monthId';
  static String testsUrl(int monthId) => '$baseUrl$parentBase/tests/$monthId';
  static String examsUrl(int monthId) => '$baseUrl$parentBase/exams/$monthId';
  static String homeworksUrl(int monthId) => '$baseUrl$parentBase/homeworks/$monthId';
  static String attendanceUrl(int monthId) => '$baseUrl$parentBase/attendance/$monthId';
  static String paymentUrl(int monthId) => '$baseUrl$parentBase/payment/$monthId';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
