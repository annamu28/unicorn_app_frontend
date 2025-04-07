import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import '../models/chatboard_model.dart';
import '../services/chatboard_service.dart';
import '../services/dio_provider.dart';

final chatboardServiceProvider = Provider((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return ChatboardService(dio);
});

final chatboardsProvider = FutureProvider<List<Chatboard>>((ref) async {
  final authState = ref.watch(authenticationProvider);
  final chatboardService = ref.watch(chatboardServiceProvider);
  
  // Get user's filters from auth state
  final userInfo = authState.userInfo;
  final country = userInfo?['countries']?[0] as String?;
  final squad = userInfo?['squads']?[0]?['name'] as String?;
  final role = userInfo?['squads']?[0]?['roles']?[0] as String?;

  return chatboardService.getChatboards(
    country: country,
    squad: squad,
    role: role,
  );
});

final chatboardProvider = FutureProvider.family<Chatboard?, String>((ref, chatboardId) async {
  final chatboardService = ref.watch(chatboardServiceProvider);
  return chatboardService.getChatboard(chatboardId);
}); 