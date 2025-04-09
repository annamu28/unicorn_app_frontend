import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../models/lesson_model.dart';
import '../services/lesson_service.dart';

final lessonServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return LessonService(dio);
});

final lessonsProvider = FutureProvider.family<List<Lesson>, int?>((ref, courseId) async {
  final lessonService = ref.watch(lessonServiceProvider);
  return lessonService.getLessons(courseId: courseId);
}); 