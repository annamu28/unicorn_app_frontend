import 'package:dio/dio.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final Dio _dio;

  AttendanceService(this._dio);

  Future<List<Attendance>> getAttendances({int? lessonId, int? userId}) async {
    try {
      print('Fetching attendances${lessonId != null ? ' for lesson $lessonId' : ''}${userId != null ? ' and user $userId' : ''}');
      
      String url = '/attendances';
      if (lessonId != null || userId != null) {
        final params = <String>[];
        if (lessonId != null) params.add('lesson_id=$lessonId');
        if (userId != null) params.add('user_id=$userId');
        url += '?${params.join('&')}';
      }
      
      final response = await _dio.get(url);
      print('Attendances response: ${response.data}');
      
      if (response.data == null) {
        return [];
      }

      if (response.data is! List) {
        print('Unexpected response type for attendances: ${response.data.runtimeType}');
        return [];
      }

      final List<dynamic> attendancesJson = response.data as List;
      final List<Attendance> attendances = [];
      
      for (var json in attendancesJson) {
        try {
          final attendance = Attendance.fromJson(json as Map<String, dynamic>);
          attendances.add(attendance);
        } catch (e) {
          print('Error parsing attendance: $json');
          print('Error: $e');
          // Continue with next attendance instead of failing completely
          continue;
        }
      }
      
      return attendances;
    } catch (e) {
      print('Error fetching attendances: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
      }
      return [];
    }
  }

  Future<Attendance> markAttendance({
    required int lessonId,
    required int userId,
    required String status,
  }) async {
    try {
      print('Marking attendance for lesson $lessonId, user $userId with status $status');
      
      final response = await _dio.post(
        '/attendances',
        data: {
          'lesson_id': lessonId,
          'user_id': userId,
          'status': status,
        },
      );
      
      print('Mark attendance response: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Received null response when marking attendance');
      }

      return Attendance.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error marking attendance: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request data: ${e.requestOptions.data}');
      }
      rethrow;
    }
  }
} 