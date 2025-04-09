import 'package:dio/dio.dart';
import '../models/chatboard_model.dart';
import '../models/user.dart';

class ChatboardService {
  final Dio _dio;

  ChatboardService(this._dio);

  bool hasAccess(Chatboard chatboard, User user) {
    // If no access restrictions are set at all, everyone has access
    if (chatboard.access.roles.isEmpty && 
        chatboard.access.squads.isEmpty && 
        chatboard.access.countries.isEmpty) {
      return true;
    }

    // Check roles - if roles list is not empty, user must have at least one required role
    bool hasRoleAccess = chatboard.access.roles.isEmpty || 
        user.hasAnyRole(chatboard.access.roles);

    // Check squads - if squads list is not empty, user must be in at least one required squad
    bool hasSquadAccess = chatboard.access.squads.isEmpty ||
        user.squads.any((squad) => chatboard.access.squads.contains(squad.name));

    // Check countries - if countries list is not empty, user must be from at least one required country
    bool hasCountryAccess = chatboard.access.countries.isEmpty ||
        user.countries.any((country) => chatboard.access.countries.contains(country));

    // For debugging
    print('Access check for user ${user.username}:');
    print('Required roles: ${chatboard.access.roles}');
    print('User roles: ${user.roles}');
    print('Has role access: $hasRoleAccess');
    print('Required squads: ${chatboard.access.squads}');
    print('User squads: ${user.squads.map((s) => s.name).toList()}');
    print('Has squad access: $hasSquadAccess');
    print('Required countries: ${chatboard.access.countries}');
    print('User countries: ${user.countries}');
    print('Has country access: $hasCountryAccess');

    // User must meet ALL non-empty conditions
    return hasRoleAccess && hasSquadAccess && hasCountryAccess;
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
          return Chatboard.fromJson(json as Map<String, dynamic>);
        } catch (e, stackTrace) {
          print('Error parsing chatboard: $json');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();

      // Filter chatboards based on user access if user is provided
      if (user != null) {
        return chatboards.where((chatboard) => hasAccess(chatboard, user)).toList();
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

  Future<Chatboard?> getChatboard(String chatboardId, {User? user}) async {
    try {
      print('Fetching chatboard with ID: $chatboardId');
      print('User roles: ${user?.roles}');
      print('User squads: ${user?.squads.map((s) => s.name).toList()}');
      print('User countries: ${user?.countries}');
      
      // First try to get the specific chatboard
      try {
        final response = await _dio.get('/chatboards/$chatboardId');
        print('Chatboard response: ${response.data}');
        
        if (response.data == null) {
          print('Chatboard response data is null');
          return null;
        }

        final chatboard = Chatboard.fromJson(response.data as Map<String, dynamic>);
        print('Parsed chatboard: ${chatboard.title}');
        print('Chatboard access roles: ${chatboard.access.roles}');
        print('Chatboard access squads: ${chatboard.access.squads}');
        print('Chatboard access countries: ${chatboard.access.countries}');
        
        // Check user access if user is provided
        if (user != null) {
          final hasAccess = this.hasAccess(chatboard, user);
          print('User ${user.username} has access to chatboard ${chatboard.title}: $hasAccess');
          print('User roles: ${user.roles}');
          print('Chatboard required roles: ${chatboard.access.roles}');
          print('User squads: ${user.squads.map((s) => s.name).toList()}');
          print('Chatboard required squads: ${chatboard.access.squads}');
          print('User countries: ${user.countries}');
          print('Chatboard required countries: ${chatboard.access.countries}');
          
          if (!hasAccess) {
            print('User does not have access to this chatboard');
            return null;
          }
        }

        return chatboard;
      } catch (e) {
        // If we get a 404 error, try to fetch all chatboards and find the one we need
        if (e is DioException && e.response?.statusCode == 404) {
          print('Chatboard not found directly, trying to fetch all chatboards');
          
          // Fetch all chatboards
          final allChatboards = await getChatboards(user: user);
          print('Found ${allChatboards.length} chatboards');
          
          // Find the chatboard with the matching ID
          final chatboard = allChatboards.firstWhere(
            (c) => c.id.toString() == chatboardId,
            orElse: () => throw Exception('Chatboard not found in all chatboards'),
          );
          
          print('Found chatboard in all chatboards: ${chatboard.title}');
          return chatboard;
        }
        
        // If it's not a 404 error, rethrow
        rethrow;
      }
    } catch (e) {
      print('Error fetching chatboard: $e');
      return null;
    }
  }
} 