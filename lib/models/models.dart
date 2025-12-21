/// Parent App Data Models
/// These models correspond to the DTOs from the TeacherManager API

// Login Response
class LoginResponse {
  final String token;
  final String studentName;
  final int expiresIn;

  LoginResponse({
    required this.token,
    required this.studentName,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      studentName: json['studentName'] ?? '',
      expiresIn: json['expiresIn'] ?? 0,
    );
  }
}

// Student Information
class StudentInfo {
  final String name;
  final String studentId;
  final String gradeName;
  final double studentPrice;

  StudentInfo({
    required this.name,
    required this.studentId,
    required this.gradeName,
    required this.studentPrice,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      name: json['name'] ?? '',
      studentId: json['studentId'] ?? '',
      gradeName: json['gradeName'] ?? '',
      studentPrice: (json['studentPrice'] ?? 0).toDouble(),
    );
  }
}

// Month
class Month {
  final int id;
  final String monthName;
  final int year;

  Month({
    required this.id,
    required this.monthName,
    required this.year,
  });

  factory Month.fromJson(Map<String, dynamic> json) {
    return Month(
      id: json['id'] ?? 0,
      monthName: json['monthName'] ?? '',
      year: json['year'] ?? 0,
    );
  }
}

// Test Result
class TestResult {
  final String testName;
  final String sessionName;
  final double? studentMark;
  final double fullMark;

  TestResult({
    required this.testName,
    required this.sessionName,
    this.studentMark,
    required this.fullMark,
  });

  String get status => studentMark != null 
      ? '${studentMark!.toStringAsFixed(1)}/${fullMark.toStringAsFixed(1)}'
      : 'غائب';

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      testName: json['testName'] ?? '',
      sessionName: json['sessionName'] ?? '',
      studentMark: json['studentMark']?.toDouble(),
      fullMark: (json['fullMark'] ?? 0).toDouble(),
    );
  }
}

// Exam Result
class ExamResult {
  final String examName;
  final String monthName;
  final double? studentMark;
  final double fullMark;

  ExamResult({
    required this.examName,
    required this.monthName,
    this.studentMark,
    required this.fullMark,
  });

  String get status => studentMark != null 
      ? '${studentMark!.toStringAsFixed(1)}/${fullMark.toStringAsFixed(1)}'
      : 'غائب';

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      examName: json['examName'] ?? '',
      monthName: json['monthName'] ?? '',
      studentMark: json['studentMark']?.toDouble(),
      fullMark: (json['fullMark'] ?? 0).toDouble(),
    );
  }
}

// Homework Result
class HomeworkResult {
  final String homeworkName;
  final String sessionName;
  final double? studentMark;
  final double fullMark;

  HomeworkResult({
    required this.homeworkName,
    required this.sessionName,
    this.studentMark,
    required this.fullMark,
  });

  String get status => studentMark != null 
      ? '${studentMark!.toStringAsFixed(1)}/${fullMark.toStringAsFixed(1)}'
      : 'لم يسلم';

  factory HomeworkResult.fromJson(Map<String, dynamic> json) {
    return HomeworkResult(
      homeworkName: json['homeworkName'] ?? '',
      sessionName: json['sessionName'] ?? '',
      studentMark: json['studentMark']?.toDouble(),
      fullMark: (json['fullMark'] ?? 0).toDouble(),
    );
  }
}

// Attendance
class Attendance {
  final String sessionName;
  final DateTime? date;
  final bool isPresent;

  Attendance({
    required this.sessionName,
    this.date,
    required this.isPresent,
  });

  String get status => isPresent ? 'حاضر' : 'غائب';

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      sessionName: json['sessionName'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      isPresent: json['isPresent'] ?? false,
    );
  }
}

// Payment
class Payment {
  final bool isPaid;
  final double amountPaid;
  final double studentPrice;
  final String monthName;

  Payment({
    required this.isPaid,
    required this.amountPaid,
    required this.studentPrice,
    required this.monthName,
  });

  String get status => isPaid ? 'مدفوع' : 'غير مدفوع';
  double get remainingAmount => studentPrice - amountPaid;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      isPaid: json['isPaid'] ?? false,
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      studentPrice: (json['studentPrice'] ?? 0).toDouble(),
      monthName: json['monthName'] ?? '',
    );
  }
}

// Monthly Report (Full)
class MonthlyReport {
  final String studentName;
  final String gradeName;
  final String monthName;
  final Payment payment;
  final List<TestResult> tests;
  final List<ExamResult> exams;
  final List<HomeworkResult> homeworks;
  final List<Attendance> attendances;
  final double totalTestMarks;
  final double totalTestFullMarks;
  final double totalExamMarks;
  final double totalExamFullMarks;
  final double totalHomeworkMarks;
  final double totalHomeworkFullMarks;
  final double overallPercentage;

  MonthlyReport({
    required this.studentName,
    required this.gradeName,
    required this.monthName,
    required this.payment,
    required this.tests,
    required this.exams,
    required this.homeworks,
    required this.attendances,
    required this.totalTestMarks,
    required this.totalTestFullMarks,
    required this.totalExamMarks,
    required this.totalExamFullMarks,
    required this.totalHomeworkMarks,
    required this.totalHomeworkFullMarks,
    required this.overallPercentage,
  });

  // Calculated properties
  double get testPercentage => totalTestFullMarks != 0 
      ? (totalTestMarks * 100 / totalTestFullMarks) 
      : 0;

  double get examPercentage => totalExamFullMarks != 0 
      ? (totalExamMarks * 100 / totalExamFullMarks) 
      : 0;

  double get homeworkPercentage => totalHomeworkFullMarks != 0 
      ? (totalHomeworkMarks * 100 / totalHomeworkFullMarks) 
      : 0;

  int get totalSessions => attendances.length;
  int get attendedSessions => attendances.where((a) => a.isPresent).length;
  
  double get attendancePercentage => totalSessions != 0 
      ? (attendedSessions * 100 / totalSessions) 
      : 0;

  factory MonthlyReport.fromJson(Map<String, dynamic> json) {
    return MonthlyReport(
      studentName: json['studentName'] ?? '',
      gradeName: json['gradeName'] ?? '',
      monthName: json['monthName'] ?? '',
      payment: Payment.fromJson(json['payment'] ?? {}),
      tests: (json['tests'] as List<dynamic>?)
          ?.map((t) => TestResult.fromJson(t))
          .toList() ?? [],
      exams: (json['exams'] as List<dynamic>?)
          ?.map((e) => ExamResult.fromJson(e))
          .toList() ?? [],
      homeworks: (json['homeworks'] as List<dynamic>?)
          ?.map((h) => HomeworkResult.fromJson(h))
          .toList() ?? [],
      attendances: (json['attendances'] as List<dynamic>?)
          ?.map((a) => Attendance.fromJson(a))
          .toList() ?? [],
      totalTestMarks: (json['totalTestMarks'] ?? 0).toDouble(),
      totalTestFullMarks: (json['totalTestFullMarks'] ?? 0).toDouble(),
      totalExamMarks: (json['totalExamMarks'] ?? 0).toDouble(),
      totalExamFullMarks: (json['totalExamFullMarks'] ?? 0).toDouble(),
      totalHomeworkMarks: (json['totalHomeworkMarks'] ?? 0).toDouble(),
      totalHomeworkFullMarks: (json['totalHomeworkFullMarks'] ?? 0).toDouble(),
      overallPercentage: (json['overallPercentage'] ?? 0).toDouble(),
    );
  }
}

// API Error Response
class ApiError {
  final String message;

  ApiError({required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(message: json['message'] ?? 'حدث خطأ غير متوقع');
  }
}
