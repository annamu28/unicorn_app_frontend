import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/chatboard_provider.dart';

class ChatboardCreator {
  final WidgetRef ref;
  final BuildContext context;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final List<int> selectedRoleIds;
  final List<int> selectedCountryIds;
  final List<int> selectedSquadIds;
  final Function(bool) setLoading;

  ChatboardCreator({
    required this.ref,
    required this.context,
    required this.titleController,
    required this.descriptionController,
    required this.selectedRoleIds,
    required this.selectedCountryIds,
    required this.selectedSquadIds,
    required this.setLoading,
  });

  Future<void> createChatboard() async {
    if (selectedRoleIds.isEmpty &&
        selectedCountryIds.isEmpty &&
        selectedSquadIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one role, country, or squad'),
        ),
      );
      return;
    }

    setLoading(true);
    try {
      final chatboardService = ref.read(chatboardServiceProvider);
      final success = await chatboardService.createChatboard(
        title: titleController.text,
        description: descriptionController.text,
        roleIds: selectedRoleIds,
        countryIds: selectedCountryIds,
        squadIds: selectedSquadIds,
      );

      if (success && context.mounted) {
        // Refresh the chatboards list
        ref.refresh(chatboardsProvider(null));
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chatboard created successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating chatboard: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }
} 