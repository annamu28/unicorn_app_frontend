import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/dio_provider.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(authenticatedDioProvider);
  return UserService(dio);
});

final userProvider = FutureProvider<User>((ref) async {
  final userService = ref.watch(userServiceProvider);
  return userService.getUserInfo();
});

// Helper provider to check if user has specific roles
final hasRoleProvider = Provider.family<bool, List<String>>((ref, roles) {
  final userAsync = ref.watch(userProvider);
  
  return userAsync.when(
    data: (user) => user.hasAnyRole(roles),
    loading: () => false,
    error: (_, __) => false,
  );
}); 