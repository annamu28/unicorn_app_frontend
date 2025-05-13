import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import '../models/chatboard_model.dart';
import '../services/chatboard_service.dart';
import '../services/dio_provider.dart';
import 'user_provider.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;

final chatboardServiceProvider = Provider<ChatboardService>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return ChatboardService(dio, ApiConfig.baseUrl);
});

final chatboardsProvider = FutureProvider.family<List<Chatboard>, String?>((ref, country) async {
  final chatboardService = ref.watch(chatboardServiceProvider);
  final userAsync = ref.watch(userProvider);
  
  return userAsync.when(
    data: (user) => chatboardService.getChatboards(
      country: country,
      user: user,
    ),
    loading: () => [],
    error: (_, __) => [],
  );
});

final chatboardProvider = FutureProvider.family<Chatboard?, String>((ref, chatboardId) async {
  final chatboardService = ref.watch(chatboardServiceProvider);
  final userAsync = ref.watch(userProvider);
  
  return userAsync.when(
    data: (user) => chatboardService.getChatboard(chatboardId, user: user),
    loading: () => null,
    error: (_, __) => null,
  );
}); 