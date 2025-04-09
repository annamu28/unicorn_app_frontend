import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../models/pending_user_model.dart';
import '../services/chatboard_service.dart';

final chatboardServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return ChatboardService(dio);
});

final pendingUsersProvider = FutureProvider.family<PendingUsersResponse, String>((ref, chatboardId) async {
  final chatboardService = ref.watch(chatboardServiceProvider);
  return chatboardService.getPendingUsers(chatboardId);
});

final verifyUserProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  print('verifyUserProvider called with params: $params');
  
  final chatboardService = ref.watch(chatboardServiceProvider);
  
  try {
    final result = await chatboardService.verifyUser(
      chatboardId: params['chatboardId'] as String,
      userId: params['userId'] as int,
      squadId: params['squadId'] as int,
      status: params['status'] as String,
    );
    
    print('Verification result from service: $result');
    return result;
  } catch (e) {
    print('Error in verifyUserProvider: $e');
    
    // For 500 errors, we want to show a more user-friendly message
    if (e.toString().contains('500') || e.toString().contains('Server error')) {
      throw Exception('Server error: Unable to process verification. Please try again later.');
    }
    
    // For other errors, rethrow with a more user-friendly message
    throw Exception('Error verifying user: ${e.toString().replaceAll('Exception: ', '')}');
  }
}); 