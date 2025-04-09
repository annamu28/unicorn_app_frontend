import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../models/course_model.dart';
import '../services/course_service.dart';

final courseServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return CourseService(dio);
});

final coursesProvider = FutureProvider<List<Course>>((ref) async {
  final courseService = ref.watch(courseServiceProvider);
  return courseService.getCourses();
}); 