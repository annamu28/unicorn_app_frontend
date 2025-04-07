import 'package:dio/dio.dart';
import '../models/chatboard_model.dart';

class ChatboardService {
  final Dio _dio;

  ChatboardService(this._dio);

  Future<List<Chatboard>> getChatboards({
    String? country,
    String? squad,
    String? role,
  }) async {
    try {
      String url = '/chatboards';
      final queryParams = <String, String>{};
      
      if (country != null) queryParams['filter_country'] = country;
      if (squad != null) queryParams['filter_squad'] = squad;
      if (role != null) queryParams['filter_role'] = role;

      if (queryParams.isNotEmpty) {
        url += '?' + queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }

      print('Fetching chatboards from: $url');
      final response = await _dio.get(url);
      
      print('Chatboards response: ${response.data}');

      if (response.data is! List) {
        throw Exception('Expected List but got ${response.data.runtimeType}');
      }

      final List<dynamic> chatboardsJson = response.data as List;
      return chatboardsJson.map((json) {
        try {
          return Chatboard.fromJson(json as Map<String, dynamic>);
        } catch (e, stackTrace) {
          print('Error parsing chatboard: $json');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching chatboards: $e');
      rethrow;
    }
  }

  Future<bool> createChatboard({
    required String title,
    required String description,
    required List<int> squadIds,
    required List<int> roleIds,
    required List<int> countryIds,
  }) async {
    try {
      final response = await _dio.post(
        '/chatboards',
        data: {
          'title': title,
          'description': description,
          'access': {
            'squad_ids': squadIds,
            'role_ids': roleIds,
            'country_ids': countryIds,
          },
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating chatboard: $e');
      rethrow;
    }
  }

  Future<Chatboard?> getChatboard(String chatboardId) async {
    try {
      final response = await _dio.get('/chatboards/$chatboardId');
      print('Chatboard response: ${response.data}');
      
      if (response.data == null) {
        return null;
      }

      return Chatboard.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching chatboard: $e');
      // Return null instead of rethrowing for 404
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }
} 