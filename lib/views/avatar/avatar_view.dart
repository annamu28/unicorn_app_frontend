import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import 'package:unicorn_app_frontend/providers/avatar_providers.dart';
import 'package:unicorn_app_frontend/providers/user_provider.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../../models/avatar_models.dart';
import '../../services/avatar_service.dart';
import 'package:go_router/go_router.dart';
import 'widgets/avatar_form_submitter.dart';
import 'widgets/squad_role_selector.dart';
import 'widgets/name_display.dart';
import 'widgets/country_selector.dart';
import 'widgets/submit_button.dart';
import 'widgets/name_manager.dart';

final avatarServiceProvider = Provider((ref) => AvatarService(ref.watch(authenticatedDioProvider)));

class AvatarView extends ConsumerStatefulWidget {
  const AvatarView({Key? key}) : super(key: key);

  @override
  _AvatarViewState createState() => _AvatarViewState();
}

class _AvatarViewState extends ConsumerState<AvatarView> {
  final _formKey = GlobalKey<FormState>();
  Country? _selectedCountry;
  List<SquadRoleSelection> _squadRoles = [SquadRoleSelection(squadId: 0, roleId: 0)];
  bool _isLoading = false;
  late NameManager _nameManager;

  @override
  void initState() {
    super.initState();
    _nameManager = NameManager(ref);
    _loadInitialData();
    _loadUserInfo();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Wait for the auth state to be ready
      await Future.delayed(Duration(milliseconds: 100));
      
      final authState = ref.read(authenticationProvider);
      print('Loading data with token: ${authState.token}');

      await Future.wait([
        ref.read(avatarServiceProvider).getCountries(),
        ref.read(avatarServiceProvider).getSquads(),
        ref.read(avatarServiceProvider).getRoles(),
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

  Future<void> _loadUserInfo() async {
    try {
      final authState = ref.read(authenticationProvider);
      print('Current auth state: $authState');
      print('Token: ${authState.token}');
      print('UserInfo: ${authState.userInfo}');
      
      // If we need to fetch user info separately, do it here
      // await ref.read(authenticationProvider.notifier).fetchUserInfo();
      
    } catch (e) {
      print('Error loading user info: $e');
    }
  }

  void _addSquadRole() {
    setState(() {
      _squadRoles.add(SquadRoleSelection(squadId: 0, roleId: 0));
    });
  }

  void _removeSquadRole(int index) {
    if (_squadRoles.length > 1) {
      setState(() {
        _squadRoles.removeAt(index);
      });
    }
  }

  void _updateSquadRole(int index, {Squad? squad, Role? role}) {
    setState(() {
      final currentSelection = _squadRoles[index];
      _squadRoles[index] = SquadRoleSelection(
        squadId: squad?.id ?? currentSelection.squadId,
        roleId: role?.id ?? currentSelection.roleId,
      );
      print('Updated squad role: ${_squadRoles[index]}');  // Debug print
    });
  }

  bool _validateSquadRoles() {
    return _squadRoles.every((squadRole) {
      return squadRole.squadId != 0 && squadRole.roleId != 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);
    final squadsAsync = ref.watch(squadsProvider);
    final rolesAsync = ref.watch(rolesProvider);
    final authState = ref.watch(authenticationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Setup'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (authState.userInfo == null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Debug: UserInfo is null. Token: ${authState.token}'),
                ),
              Expanded(
                child: countriesAsync.when(
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
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          const SizedBox(height: 20),
                                          
                                          // Name display and toggle
                                          NameDisplay(
                                            fullName: _nameManager.fullName,
                                            shortName: _nameManager.shortName,
                                            showFullName: _nameManager.showFullName,
                                            onToggle: (value) {
                                              setState(() {
                                                _nameManager.setShowFullName(value);
                                              });
                                            },
                                            onFirstLastInitial: () {
                                              setState(() {
                                                _nameManager.setFirstLastInitial();
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 20),

                                          // Country selection
                                          CountrySelector(
                                            countries: countries,
                                            selectedCountry: _selectedCountry,
                                            onChanged: (value) {
                                              setState(() => _selectedCountry = value);
                                            },
                                          ),
                                          const SizedBox(height: 20),

                                          // Squad selection
                                          SquadRoleSelector(
                                            squadRoles: _squadRoles,
                                            squads: squads,
                                            roles: roles,
                                            onRemove: _removeSquadRole,
                                            onUpdate: _updateSquadRole,
                                            onAdd: _addSquadRole,
                                          ),
                                          const SizedBox(height: 20),

                                          Padding(
                                            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                            child: SubmitButton(
                                              isLoading: _isLoading,
                                              onPressed: () async {
                                                if (_formKey.currentState!.validate()) {
                                                  await _submitForm();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    final submitter = AvatarFormSubmitter(
      ref: ref,
      context: context,
      showFullName: _nameManager.showFullName,
      fullName: _nameManager.fullName,
      shortName: _nameManager.shortName,
      selectedCountry: _selectedCountry,
      squadRoles: _squadRoles,
      setLoading: (value) => setState(() => _isLoading = value),
    );

    await submitter.submitForm();
  }
}
