import 'package:flutter/material.dart';
import '../services/parent_api_service.dart';
import '../models/models.dart';

class ReportScreen extends StatefulWidget {
  final Month month;
  
  const ReportScreen({super.key, required this.month});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  final _apiService = ParentApiService();
  late TabController _tabController;
  
  MonthlyReport? _report;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final report = await _apiService.getMonthlyReport(widget.month.id);
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.month.monthName} ${widget.month.year}'),
        centerTitle: true,
        bottom: _report != null
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: 'نظرة عامة'),
                  Tab(text: 'الاختبارات'),
                  Tab(text: 'الامتحانات'),
                  Tab(text: 'الواجبات'),
                  Tab(text: 'الحضور'),
                ],
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _loadReport,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTestsTab(),
                    _buildExamsTab(),
                    _buildHomeworksTab(),
                    _buildAttendanceTab(),
                  ],
                ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overall Performance Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'الأداء العام',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: _report!.overallPercentage / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPerformanceColor(_report!.overallPercentage),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${_report!.overallPercentage.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Performance Breakdown
          _buildStatCard(
            'الاختبارات',
            _report!.testPercentage,
            Icons.quiz_outlined,
            '${_report!.totalTestMarks.toStringAsFixed(1)} / ${_report!.totalTestFullMarks.toStringAsFixed(1)}',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'الامتحانات',
            _report!.examPercentage,
            Icons.assignment_outlined,
            '${_report!.totalExamMarks.toStringAsFixed(1)} / ${_report!.totalExamFullMarks.toStringAsFixed(1)}',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'الواجبات',
            _report!.homeworkPercentage,
            Icons.book_outlined,
            '${_report!.totalHomeworkMarks.toStringAsFixed(1)} / ${_report!.totalHomeworkFullMarks.toStringAsFixed(1)}',
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'الحضور',
            _report!.attendancePercentage,
            Icons.calendar_today_outlined,
            '${_report!.attendedSessions} / ${_report!.totalSessions} حصة',
          ),
          const SizedBox(height: 16),
          
          // Payment Status
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _report!.payment.isPaid ? Icons.check_circle : Icons.warning,
                        color: _report!.payment.isPaid ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'حالة الدفع',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المبلغ المطلوب:'),
                      Text(
                        '${_report!.payment.studentPrice.toStringAsFixed(0)} جنيه',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المبلغ المدفوع:'),
                      Text(
                        '${_report!.payment.amountPaid.toStringAsFixed(0)} جنيه',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (!_report!.payment.isPaid) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المتبقي:'),
                        Text(
                          '${_report!.payment.remainingAmount.toStringAsFixed(0)} جنيه',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double percentage, IconData icon, String subtitle) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getPerformanceColor(percentage).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _getPerformanceColor(percentage)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getPerformanceColor(percentage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestsTab() {
    if (_report!.tests.isEmpty) {
      return _buildEmptyState('لا توجد اختبارات', Icons.quiz_outlined);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _report!.tests.length,
      itemBuilder: (context, index) {
        final test = _report!.tests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: test.studentMark != null
                  ? _getPerformanceColor((test.studentMark! / test.fullMark) * 100)
                  : Colors.grey,
              child: Icon(Icons.quiz, color: Colors.white),
            ),
            title: Text(
              test.testName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(test.sessionName),
            trailing: Text(
              test.status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamsTab() {
    if (_report!.exams.isEmpty) {
      return _buildEmptyState('لا توجد امتحانات', Icons.assignment_outlined);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _report!.exams.length,
      itemBuilder: (context, index) {
        final exam = _report!.exams[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: exam.studentMark != null
                  ? _getPerformanceColor((exam.studentMark! / exam.fullMark) * 100)
                  : Colors.grey,
              child: Icon(Icons.assignment, color: Colors.white),
            ),
            title: Text(
              exam.examName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(exam.monthName),
            trailing: Text(
              exam.status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeworksTab() {
    if (_report!.homeworks.isEmpty) {
      return _buildEmptyState('لا توجد واجبات', Icons.book_outlined);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _report!.homeworks.length,
      itemBuilder: (context, index) {
        final homework = _report!.homeworks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: homework.studentMark != null
                  ? _getPerformanceColor((homework.studentMark! / homework.fullMark) * 100)
                  : Colors.grey,
              child: Icon(Icons.book, color: Colors.white),
            ),
            title: Text(
              homework.homeworkName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(homework.sessionName),
            trailing: Text(
              homework.status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceTab() {
    if (_report!.attendances.isEmpty) {
      return _buildEmptyState('لا توجد سجلات حضور', Icons.calendar_today_outlined);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _report!.attendances.length,
      itemBuilder: (context, index) {
        final attendance = _report!.attendances[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: attendance.isPresent ? Colors.green : Colors.red,
              child: Icon(
                attendance.isPresent ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(
              attendance.sessionName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: attendance.date != null
                ? Text('${attendance.date!.day}/${attendance.date!.month}/${attendance.date!.year}')
                : null,
            trailing: Text(
              attendance.status,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: attendance.isPresent ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 85) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}
