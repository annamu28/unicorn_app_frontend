import 'package:dio/dio.dart';
import '../models/lesson_model.dart';

class LessonService {
  final Dio _dio;

  LessonService(this._dio);

  Future<List<Lesson>> getLessons({int? courseId}) async {
    try {
      print('Fetching lessons${courseId != null ? ' for course $courseId' : ''}');
      final url = courseId != null ? '/lessons?course_id=$courseId' : '/lessons';
      final response = await _dio.get(url);
      print('Lessons response: ${response.data}');
      
      if (response.data == null) {
        return [];
      }

      if (response.data is! List) {
        print('Unexpected response type for lessons: ${response.data.runtimeType}');
        return [];
      }

      final List<dynamic> lessonsJson = response.data as List;
      final List<Lesson> lessons = [];
      
      for (var json in lessonsJson) {
        try {
          final lesson = Lesson.fromJson(json as Map<String, dynamic>);
          lessons.add(lesson);
        } catch (e) {
          print('Error parsing lesson: $json');
          print('Error: $e');
          // Continue with next lesson instead of failing completely
          continue;
        }
      }
      
      return lessons;
    } catch (e) {
      print('Error fetching lessons: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
      }
      return [];
    }
  }
} 