import 'package:dio/dio.dart';
import 'package:unicorn_app_frontend/models/pending_user_model.dart';
import '../models/chatboard_model.dart';
import '../models/user.dart';

class ChatboardService {
  final Dio _dio;

  ChatboardService(this._dio);

  bool hasAccess(User user, Chatboard chatboard) {
    print('Checking access for user ${user.username} to chatboard ${chatboard.title}');
    print('User roles: ${user.roles}');
    print('User squads: ${user.squads.map((s) => '${s.name} (${s.roles.join(', ')})').toList()}');
    print('User countries: ${user.countries}');
    print('Chatboard required roles: ${chatboard.access.roles}');
    print('Chatboard required squads: ${chatboard.access.squads}');
    print('Chatboard required countries: ${chatboard.access.countries}');
    
    // If no access restrictions are set at all, everyone has access
    if (chatboard.access.roles.isEmpty && 
        chatboard.access.squads.isEmpty && 
        chatboard.access.countries.isEmpty) {
      print('No access restrictions set, granting access');
      return true;
    }

    // Check if user has any of the required roles (either at top level or in squads)
    if (chatboard.access.roles.isNotEmpty) {
      final hasRequiredRole = user.hasAnyRole(chatboard.access.roles);
      print('User has required role: $hasRequiredRole');
      if (!hasRequiredRole) {
        return false;
      }
    }

    // Check if user has any of the required squads
    if (chatboard.access.squads.isNotEmpty) {
      bool hasRequiredSquad = false;
      for (final squad in user.squads) {
        if (chatboard.access.squads.contains(squad.name)) {
          hasRequiredSquad = true;
          break;
        }
      }
      print('User has required squad: $hasRequiredSquad');
      if (!hasRequiredSquad) {
        return false;
      }
    }

    // Check if user has any of the required countries
    if (chatboard.access.countries.isNotEmpty) {
      final hasRequiredCountry = chatboard.access.countries.any((country) => user.countries.contains(country));
      print('User has required country: $hasRequiredCountry');
      if (!hasRequiredCountry) {
        return false;
      }
    }

    print('User has access to chatboard ${chatboard.title}');
    return true;
  }

  Future<List<Chatboard>> getChatboards({
    String? country,
    String? squad,
    String? role,
    User? user,
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
      final chatboards = chatboardsJson.map((json) {
        try {
          final chatboard = Chatboard.fromJson(json as Map<String, dynamic>);
          print('Parsed chatboard: ID=${chatboard.id}, Title=${chatboard.title}');
          return chatboard;
        } catch (e, stackTrace) {
          print('Error parsing chatboard: $json');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();

      // Filter chatboards based on user access if user is provided
      if (user != null) {
        print('Filtering chatboards for user ${user.username}');
        print('User roles: ${user.roles}');
        print('User squads: ${user.squads.map((s) => '${s.name} (${s.roles.join(', ')})').toList()}');
        print('User countries: ${user.countries}');
        
        final filteredChatboards = chatboards.where((chatboard) {
          final hasAccess = this.hasAccess(user, chatboard);
          print('User ${user.username} has access to chatboard ${chatboard.title} (ID: ${chatboard.id}): $hasAccess');
          return hasAccess;
        }).toList();
        
        print('Filtered chatboards: ${filteredChatboards.map((c) => '${c.title} (ID: ${c.id})').toList()}');
        return filteredChatboards;
      }

      return chatboards;
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

  Future<Chatboard?> getChatboard(String id, {User? user}) async {
    try {
      print('Fetching chatboard with ID: $id');
      
      // First, get all chatboards to find the correct one
      final allChatboards = await getChatboards(user: user);
      Chatboard? chatboard;
      try {
        chatboard = allChatboards.firstWhere(
          (c) => c.id.toString() == id,
        );
      } catch (e) {
        print('Chatboard with ID $id not found in the list of accessible chatboards');
        return null;
      }
      
      if (chatboard == null) {
        print('Chatboard with ID $id not found in the list of accessible chatboards');
        return null;
      }
      
      print('Found chatboard in list: ${chatboard.title} (ID: ${chatboard.id})');
      
      // Now try to fetch the chatboard details from the API
      final response = await _dio.get(
        '/chatboards/${chatboard.id}',
        options: Options(
          validateStatus: (status) {
            // Accept all status codes to handle them manually
            return true;
          },
        ),
      );
      
      print('Chatboard API response: ${response.data}');

      if (response.statusCode == 404) {
        print('Chatboard not found in API');
        // Return the chatboard from the list if API fails
        return chatboard;
      }

      if (response.data == null) {
        print('Received null response from API');
        // Return the chatboard from the list if API fails
        return chatboard;
      }

      if (response.data is String) {
        print('Received string response instead of JSON: ${response.data}');
        // Return the chatboard from the list if API fails
        return chatboard;
      }

      if (response.data is! Map<String, dynamic>) {
        print('Unexpected response type: ${response.data.runtimeType}');
        // Return the chatboard from the list if API fails
        return chatboard;
      }

      // Use the API response if available
      final apiChatboard = Chatboard.fromJson(response.data as Map<String, dynamic>);
      print('Using API chatboard: ${apiChatboard.title} (ID: ${apiChatboard.id})');
      
      // Check user access if user is provided
      if (user != null) {
        final hasAccess = this.hasAccess(user, apiChatboard);
        print('User ${user.username} has access to chatboard ${apiChatboard.title}: $hasAccess');
        if (!hasAccess) {
          return null;
        }
      }
      
      return apiChatboard;
    } catch (e) {
      print('Error fetching chatboard: $e');
      if (e is DioException) {
        print('Dio error type: ${e.type}');
        print('Dio error message: ${e.message}');
        print('Dio error response: ${e.response?.data}');
      }
      
      // Try to get the chatboard from the list as a fallback
      try {
        final allChatboards = await getChatboards(user: user);
        Chatboard? chatboard;
        try {
          chatboard = allChatboards.firstWhere(
            (c) => c.id.toString() == id,
          );
        } catch (e) {
          print('Chatboard with ID $id not found in fallback search');
          return null;
        }
        
        if (chatboard != null) {
          print('Using chatboard from list as fallback: ${chatboard.title} (ID: ${chatboard.id})');
          return chatboard;
        }
      } catch (fallbackError) {
        print('Error in fallback: $fallbackError');
      }
      
      return null;
    }
  }

  Future<PendingUsersResponse> getPendingUsers(String chatboardId) async {
    try {
      print('Fetching pending users for chatboard: $chatboardId');
      final response = await _dio.get('/chatboards/$chatboardId/pending-users');
      print('Pending users response: ${response.data}');
      
      return PendingUsersResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching pending users: $e');
      rethrow;
    }
  }

  Future<bool> verifyUser({
    required String chatboardId,
    required int userId,
    required int squadId,
    required String status,
  }) async {
    try {
      print('Verifying user $userId for chatboard $chatboardId with status: $status');
      
      // Validate the status
      if (status != 'Approved' && status != 'Rejected' && status != 'Pending') {
        print('Invalid status: $status');
        throw Exception('Invalid status. Must be "Approved", "Rejected", or "Pending"');
      }
      
      // Make the API request
      final response = await _dio.post(
        '/verification',
        data: {
          'user_id': userId,
          'squad_id': squadId,
          'status': status,
        },
        options: Options(
          validateStatus: (status) {
            // Accept all status codes to handle them manually
            return true;
          },
        ),
      );
      
      print('Verification API response: ${response.data}');
      print('Verification API status code: ${response.statusCode}');
      
      // Check for specific error messages in the response
      if (response.statusCode == 500) {
        final errorMessage = response.data['error'] ?? 'Unknown server error';
        print('Server error: $errorMessage');
        throw Exception('Server error: $errorMessage');
      }
      
      final success = response.statusCode == 200 || response.statusCode == 201;
      print('Verification success: $success');
      
      return success;
    } catch (e) {
      print('Error verifying user: $e');
      if (e is DioException) {
        print('Dio error type: ${e.type}');
        print('Dio error message: ${e.message}');
        print('Dio error response: ${e.response?.data}');
        
        // Extract a more user-friendly error message
        if (e.response?.data != null && e.response?.data is Map) {
          final errorMessage = e.response?.data['error'] ?? e.message;
          throw Exception(errorMessage);
        }
      }
      rethrow;
    }
  }
} 