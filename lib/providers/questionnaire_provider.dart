import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../models/questionnaire_model.dart';
import '../services/questionnaire_service.dart';

final questionnaireServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return QuestionnaireService(dio);
});

final questionnairesProvider = FutureProvider.family<List<Questionnaire>, int?>((ref, lessonId) async {
  final questionnaireService = ref.watch(questionnaireServiceProvider);
  return questionnaireService.getQuestionnaires(lessonId: lessonId);
});

final questionnaireProvider = FutureProvider.family<Questionnaire?, int>((ref, questionnaireId) async {
  final questionnaireService = ref.watch(questionnaireServiceProvider);
  final questionnaires = await questionnaireService.getQuestionnaires();
  try {
    return questionnaires.firstWhere((q) => q.id == questionnaireId);
  } catch (e) {
    return null;
  }
});

final createQuestionnaireProvider = FutureProvider.family<Questionnaire, Map<String, dynamic>>((ref, params) async {
  final questionnaireService = ref.watch(questionnaireServiceProvider);
  return questionnaireService.createQuestionnaire(
    lessonId: params['lessonId'] as int,
    title: params['title'] as String,
    description: params['description'] as String,
    questions: params['questions'] as List<Question>,
  );
}); 