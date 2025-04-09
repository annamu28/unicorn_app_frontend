import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';

final attendanceServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return AttendanceService(dio);
});

final attendancesProvider = FutureProvider.family<List<Attendance>, Map<String, int?>>((ref, params) async {
  final attendanceService = ref.watch(attendanceServiceProvider);
  return attendanceService.getAttendances(
    lessonId: params['lessonId'],
    userId: params['userId'],
  );
});

final markAttendanceProvider = FutureProvider.family<Attendance, Map<String, dynamic>>((ref, params) async {
  final attendanceService = ref.watch(attendanceServiceProvider);
  return attendanceService.markAttendance(
    lessonId: params['lessonId'] as int,
    userId: params['userId'] as int,
    status: params['status'] as String,
  );
}); 