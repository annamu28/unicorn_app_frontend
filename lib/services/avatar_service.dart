import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/avatar_models.dart';

class AvatarService {
  final Dio _dio;
  
  AvatarService(this._dio) {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.validateStatus = (status) => status! < 500;
  }

  Future<List<Country>> getCountries() async {
    try {
      print('Fetching countries with headers: ${_dio.options.headers}');
      final response = await _dio.get('/countries');
      print('Countries raw response: ${response.data}');

      if (response.data is Map && response.data['error'] != null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['error'],
        );
      }

      final List<dynamic> data = response.data as List;
      return data.map((json) => Country.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching countries: $e');
      rethrow;
    }
  }

  Future<List<Squad>> getSquads() async {
    try {
      print('Fetching squads with headers: ${_dio.options.headers}');
      final response = await _dio.get('/squads');
      print('Squads raw response: ${response.data}');

      if (response.data is Map && response.data['error'] != null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['error'],
        );
      }

      final List<dynamic> data = response.data as List;
      return data.map((json) => Squad.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching squads: $e');
      rethrow;
    }
  }

  Future<List<Role>> getRoles() async {
    try {
      print('Fetching roles with headers: ${_dio.options.headers}');
      final response = await _dio.get('/roles');
      print('Roles raw response: ${response.data}');

      if (response.data is Map && response.data['error'] != null) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data['error'],
        );
      }

      final List<dynamic> data = response.data as List;
      return data.map((json) {
        try {
          return Role.fromJson(json);
        } catch (e) {
          print('Error parsing role: $json');
          print('Parse error: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching roles: $e');
      rethrow;
    }
  }

  Future<void> createAvatar({
    required String username,
    required List<SquadRoleSelection> squadRoles,
    required int countryId,
  }) async {
    try {
      final data = {
        'username': username,
        'country_id': countryId,
        'squad_roles': squadRoles.map((sr) => {
          'squad_id': sr.squadId,
          'role_id': sr.roleId,
          'status': 'Pending'
        }).toList(),
      };
      
      print('Sending avatar data: $data');
      
      final response = await _dio.post(
        '/avatar',
        data: data,
      );
      
      print('Avatar creation response: ${response.data}');
      return response.data;
    } catch (e) {
      print('Error creating avatar: $e');
      rethrow;
    }
  }
} 