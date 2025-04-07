import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/avatar_service.dart';
import '../models/avatar_models.dart';
import '../services/dio_provider.dart';  // Import the dio provider

// Create the AvatarService provider using the authenticated Dio
final avatarServiceProvider = Provider<AvatarService>((ref) {
  return AvatarService(ref.watch(authenticatedDioProvider));
});

// Data providers
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  try {
    return await ref.watch(avatarServiceProvider).getCountries();
  } catch (e) {
    print('Countries provider error: $e');
    return [];
  }
});

final squadsProvider = FutureProvider<List<Squad>>((ref) async {
  try {
    return await ref.watch(avatarServiceProvider).getSquads();
  } catch (e) {
    print('Squads provider error: $e');
    return [];
  }
});

final rolesProvider = FutureProvider<List<Role>>((ref) async {
  try {
    return await ref.watch(avatarServiceProvider).getRoles();
  } catch (e) {
    print('Roles provider error: $e');
    return [];
  }
}); 