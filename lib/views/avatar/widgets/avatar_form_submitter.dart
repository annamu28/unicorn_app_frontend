import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/avatar_models.dart';
import '../../../providers/avatar_providers.dart';
import '../../../providers/user_provider.dart';
import '../../../services/avatar_service.dart';

class AvatarFormSubmitter {
  final WidgetRef ref;
  final BuildContext context;
  final bool showFullName;
  final String fullName;
  final String shortName;
  final Country? selectedCountry;
  final List<SquadRoleSelection> squadRoles;
  final Function(bool) setLoading;

  AvatarFormSubmitter({
    required this.ref,
    required this.context,
    required this.showFullName,
    required this.fullName,
    required this.shortName,
    required this.selectedCountry,
    required this.squadRoles,
    required this.setLoading,
  });

  bool _validateSquadRoles() {
    return squadRoles.every((squadRole) {
      return squadRole.squadId != 0 && squadRole.roleId != 0;
    });
  }

  Future<void> submitForm() async {
    if (selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country')),
      );
      return;
    }

    if (!_validateSquadRoles()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both squad and role for each entry')),
      );
      return;
    }

    setLoading(true);
    try {
      final data = {
        'username': showFullName ? fullName : shortName,
        'country_id': selectedCountry!.id,
        'squad_roles': squadRoles,
      };
      print('Submitting form with data: $data');

      await ref.read(avatarServiceProvider).createAvatar(
        username: showFullName ? fullName : shortName,
        squadRoles: squadRoles,
        countryId: selectedCountry!.id,
      );
      
      // Refresh user data after creating avatar
      print('Refreshing user data after avatar creation');
      ref.invalidate(userProvider);
      
      // Wait for user data to be refreshed
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (context.mounted) {
        context.go('/main');
      }
    } catch (e) {
      print('Error submitting form: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating avatar: $e')),
        );
      }
    } finally {
      setLoading(false);
    }
  }
} 