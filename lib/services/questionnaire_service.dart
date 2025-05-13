import 'package:dio/dio.dart';
import '../models/questionnaire_model.dart';

class QuestionnaireService {
  final Dio _dio;

  QuestionnaireService(this._dio);

  Future<List<Questionnaire>> getQuestionnaires({int? lessonId}) async {
    try {
      print('Fetching questionnaires${lessonId != null ? ' for lesson $lessonId' : ''}');
      
      final response = await _dio.get('/tests');
      print('Questionnaires response: ${response.data}');
      
      if (response.data == null) {
        return [];
      }

      if (response.data is! List) {
        print('Unexpected response type for questionnaires: ${response.data.runtimeType}');
        return [];
      }

      final List<dynamic> questionnairesJson = response.data as List;
      final List<Questionnaire> questionnaires = [];
      
      for (var json in questionnairesJson) {
        try {
          if (lessonId != null && json['lesson_id'] != lessonId) {
            continue;
          }
          
          final questionnaire = Questionnaire.fromJson(json as Map<String, dynamic>);
          questionnaires.add(questionnaire);
        } catch (e) {
          print('Error parsing questionnaire: $json');
          print('Error: $e');
          continue;
        }
      }
      
      return questionnaires;
    } catch (e) {
      print('Error fetching questionnaires: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
      }
      return [];
    }
  }

  Future<Questionnaire> createQuestionnaire({
    required int lessonId,
    required String title,
    required String description,
    required List<Question> questions,
  }) async {
    try {
      print('Creating questionnaire for lesson $lessonId');
      
      final response = await _dio.post(
        '/tests',
        data: {
          'lesson_id': lessonId,
          'title': title,
          'description': description,
          'questions': questions.map((q) => q.toJson()).toList(),
        },
      );
      
      print('Create questionnaire response: ${response.data}');
      
      if (response.data == null) {
        throw Exception('Received null response when creating questionnaire');
      }

      return Questionnaire.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error creating questionnaire: $e');
      if (e is DioException) {
        print('Response data: ${e.response?.data}');
        print('Request data: ${e.requestOptions.data}');
      }
      rethrow;
    }
  }
} 