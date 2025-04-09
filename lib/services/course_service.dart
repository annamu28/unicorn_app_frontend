import 'package:dio/dio.dart';
import '../models/course_model.dart';

class CourseService {
  final Dio _dio;

  CourseService(this._dio);

  Future<List<Course>> getCourses() async {
    try {
      print('Fetching courses');
      final response = await _dio.get('/courses');
      print('Courses response: ${response.data}');
      
      if (response.data == null) {
        return [];
      }

      if (response.data is! List) {
        print('Unexpected response type for courses: ${response.data.runtimeType}');
        return [];
      }

      final List<dynamic> coursesJson = response.data as List;
      final List<Course> courses = [];
      
      for (var json in coursesJson) {
        try {
          final course = Course.fromJson(json as Map<String, dynamic>);
          courses.add(course);
        } catch (e) {
          print('Error parsing course: $json');
          print('Error: $e');
          // Continue with next course instead of failing completely
          continue;
        }
      }
      
      return courses;
    } catch (e) {
      print('Error fetching courses: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
      }
      return [];
    }
  }
} 