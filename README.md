# Parent App

تطبيق الوالدين للتواصل مع نظام إدارة المعلم (TeacherManager API).

## المتطلبات

- Flutter SDK 3.0+
- Dart 3.0+

## التثبيت

```bash
cd ParentApp
flutter pub get
```

## الإعداد

1. افتح `lib/services/api_config.dart`
2. غيّر `baseUrl` إلى عنوان الخادم الخاص بك:
   - للتطوير المحلي: `http://localhost:5000`
   - لمحاكي Android: `http://10.0.2.2:5000`
   - للإنتاج: `https://your-api-domain.com`

## البنية

```
lib/
├── models/
│   └── models.dart          # نماذج البيانات (DTOs)
├── services/
│   ├── api_config.dart      # إعدادات API
│   ├── auth_service.dart    # خدمة المصادقة
│   ├── parent_api_service.dart  # خدمة API الرئيسية
│   └── services.dart        # ملف التصدير
```

## الاستخدام

### تسجيل الدخول

```dart
import 'package:parent_app/services/services.dart';

final authService = AuthService();
try {
  final response = await authService.login('STUDENT_CODE');
  print('مرحباً ${response.studentName}');
} catch (e) {
  print('خطأ: $e');
}
```

### الحصول على بيانات الطالب

```dart
final apiService = ParentApiService();
final student = await apiService.getStudentInfo();
print('اسم الطالب: ${student.name}');
```

### الحصول على الشهور

```dart
final months = await apiService.getMonths();
for (final month in months) {
  print('${month.monthName} ${month.year}');
}
```

### الحصول على التقرير الشهري

```dart
final report = await apiService.getMonthlyReport(monthId);
print('النسبة الإجمالية: ${report.overallPercentage}%');
```

## نقاط النهاية (Endpoints)

| الطريقة | المسار | الوصف |
|---------|--------|-------|
| POST | `/api/parent/auth/login` | تسجيل الدخول بكود الطالب |
| GET | `/api/parent/student` | بيانات الطالب |
| GET | `/api/parent/months` | قائمة الشهور |
| GET | `/api/parent/report/{monthId}` | التقرير الشهري الكامل |
| GET | `/api/parent/tests/{monthId}` | الاختبارات القصيرة |
| GET | `/api/parent/exams/{monthId}` | الامتحانات |
| GET | `/api/parent/homeworks/{monthId}` | الواجبات |
| GET | `/api/parent/attendance/{monthId}` | الحضور |
| GET | `/api/parent/payment/{monthId}` | المدفوعات |
