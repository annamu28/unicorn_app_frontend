import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/chatboard_provider.dart';
import '../../../providers/avatar_providers.dart';
import '../../../models/avatar_models.dart';
import 'widgets/multi_select_widget.dart';
import 'widgets/chatboard_creator.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Wait for the auth state to be ready
      await Future.delayed(Duration(milliseconds: 100));
      
      await Future.wait([
        ref.read(countriesProvider.future),
        ref.read(squadsProvider.future),
        ref.read(rolesProvider.future),
      ]);
    } catch (e) {
      print('Error loading initial data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);
    final squadsAsync = ref.watch(squadsProvider);
    final rolesAsync = ref.watch(rolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Chatboard'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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

                    // Roles selection
                    countriesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(child: Text('Error: $error')),
                      data: (countries) {
                        return squadsAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Center(child: Text('Error: $error')),
                          data: (squads) {
                            return rolesAsync.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (error, stack) => Center(child: Text('Error: $error')),
                              data: (roles) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Roles selection
                                    MultiSelect(
                                      title: 'Roles',
                                      items: roles.map((role) => {
                                        'id': role.id,
                                        'name': role.name,
                                      }).toList(),
                                      selectedIds: _selectedRoleIds,
                                      onChanged: (ids) => setState(() => _selectedRoleIds = ids),
                                    ),
                                    const SizedBox(height: 20),

                                    // Countries selection
                                    MultiSelect(
                                      title: 'Countries',
                                      items: countries.map((country) => {
                                        'id': country.id,
                                        'name': country.name,
                                      }).toList(),
                                      selectedIds: _selectedCountryIds,
                                      onChanged: (ids) => setState(() => _selectedCountryIds = ids),
                                    ),
                                    const SizedBox(height: 20),

                                    // Squads selection
                                    MultiSelect(
                                      title: 'Squads',
                                      items: squads.map((squad) => {
                                        'id': squad.id,
                                        'name': squad.name,
                                      }).toList(),
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
                                        onPressed: () {
                                          final creator = ChatboardCreator(
                                            ref: ref,
                                            context: context,
                                            titleController: _titleController,
                                            descriptionController: _descriptionController,
                                            selectedRoleIds: _selectedRoleIds,
                                            selectedCountryIds: _selectedCountryIds,
                                            selectedSquadIds: _selectedSquadIds,
                                            setLoading: (loading) => setState(() => _isLoading = loading),
                                          );
                                          creator.createChatboard();
                                        },
                                        child: const Text('Create Chatboard'),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
