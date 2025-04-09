import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/chatboard_service.dart';
import '../../../providers/chatboard_provider.dart';

class CreateNewChatboardView extends ConsumerStatefulWidget {
  const CreateNewChatboardView({super.key});

  @override
  CreateNewChatboardViewState createState() => CreateNewChatboardViewState();
}

class CreateNewChatboardViewState extends ConsumerState<CreateNewChatboardView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<int> _selectedRoleIds = [];
  List<int> _selectedCountryIds = [];
  List<int> _selectedSquadIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Chatboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Chatboard Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Chatboard Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Description is required' : null,
                ),
                const SizedBox(height: 30),

                const Text(
                  'Who can access this chatboard?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Use your actual roles, countries, and squads data here
                // This is just an example - you should get these from your API
                _buildMultiSelect(
                  title: 'Roles',
                  items: [{'id': 1, 'name': 'Admin'}],
                  selectedIds: _selectedRoleIds,
                  onChanged: (ids) => setState(() => _selectedRoleIds = ids),
                ),
                const SizedBox(height: 20),

                _buildMultiSelect(
                  title: 'Countries',
                  items: [{'id': 1, 'name': 'Estonia'}],
                  selectedIds: _selectedCountryIds,
                  onChanged: (ids) => setState(() => _selectedCountryIds = ids),
                ),
                const SizedBox(height: 20),

                _buildMultiSelect(
                  title: 'Squads',
                  items: [{'id': 1, 'name': 'HK Unicorn Squad'}],
                  selectedIds: _selectedSquadIds,
                  onChanged: (ids) => setState(() => _selectedSquadIds = ids),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _createChatboard,
                    child: const Text('Create Chatboard'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelect({
    required String title,
    required List<Map<String, dynamic>> items,
    required List<int> selectedIds,
    required Function(List<int>) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return FilterChip(
              label: Text(item['name'] as String),
              selected: selectedIds.contains(item['id']),
              onSelected: (selected) {
                final newIds = List<int>.from(selectedIds);
                if (selected) {
                  newIds.add(item['id'] as int);
                } else {
                  newIds.remove(item['id']);
                }
                onChanged(newIds);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _createChatboard() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRoleIds.isEmpty &&
        _selectedCountryIds.isEmpty &&
        _selectedSquadIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one role, country, or squad'),
        ),
      );
      return;
    }

    try {
      final chatboardService = ref.read(chatboardServiceProvider);
      final success = await chatboardService.createChatboard(
        title: _titleController.text,
        description: _descriptionController.text,
        roleIds: _selectedRoleIds,
        countryIds: _selectedCountryIds,
        squadIds: _selectedSquadIds,
      );

      if (success && mounted) {
        // Refresh the chatboards list
        ref.refresh(chatboardsProvider(null));
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chatboard created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating chatboard: $e')),
        );
      }
    }
  }
}
