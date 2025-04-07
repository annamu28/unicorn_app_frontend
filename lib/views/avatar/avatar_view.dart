import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicorn_app_frontend/providers/authentication_provider.dart';
import 'package:unicorn_app_frontend/providers/avatar_providers.dart';
import 'package:unicorn_app_frontend/services/dio_provider.dart';
import '../../models/avatar_models.dart';
import '../../services/avatar_service.dart';
import 'package:go_router/go_router.dart';

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
  bool _showFullName = true;

  String get _fullName {
    final authState = ref.read(authenticationProvider);
    final userInfo = authState.userInfo;
    
    print('UserInfo: $userInfo');
    
    final firstName = userInfo?['first_name'] as String?;
    final lastName = userInfo?['last_name'] as String?;

    if (firstName == null || lastName == null) {
      print('Name is null - firstName: $firstName, lastName: $lastName');
      return 'Name not available';
    }
    return "$firstName $lastName";
  }

  String get _shortName {
    final authState = ref.read(authenticationProvider);
    final userInfo = authState.userInfo;
    final firstName = userInfo?['first_name'] as String?;
    final lastName = userInfo?['last_name'] as String?;

    if (firstName == null || lastName == null) return 'Name not available';
    
    final first = firstName.length >= 3 ? firstName.substring(0, 3) : firstName;
    final last = lastName.length >= 3 ? lastName.substring(0, 3) : lastName;
    return "$first$last";
  }

  String get _nameLabel => _showFullName ? 'Full Name' : 'Short Name';

  @override
  void initState() {
    super.initState();
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
                                          
                                          // Name Label
                                          Center(
                                            child: Text(
                                              _nameLabel,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          
                                          // Display Name
                                          Center(
                                            child: Text(
                                              _showFullName ? _fullName : _shortName,
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 20),

                                          // Display name toggle
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Show ${_showFullName ? 'Short' : 'Full'} Name',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Switch(
                                                value: _showFullName,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _showFullName = value;
                                                  });
                                                },
                                                activeColor: Colors.black,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),

                                          // Country selection
                                          DropdownButtonFormField<Country>(
                                            value: _selectedCountry,
                                            decoration: const InputDecoration(
                                              labelText: 'Country',
                                              border: OutlineInputBorder(),
                                            ),
                                            items: countries.map((country) {
                                              return DropdownMenuItem(
                                                value: country,
                                                child: Text(country.name),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() => _selectedCountry = value);
                                            },
                                          ),
                                          const SizedBox(height: 20),

                                          // Squad selection
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Squad Roles',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ..._squadRoles.asMap().entries.map((entry) {
                                                final index = entry.key;
                                                final squadRole = entry.value;
                                                
                                                return Card(
                                                  margin: const EdgeInsets.only(bottom: 16),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(16),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('Squad Role ${index + 1}'),
                                                            if (_squadRoles.length > 1)
                                                              IconButton(
                                                                icon: const Icon(Icons.remove_circle_outline),
                                                                onPressed: () => _removeSquadRole(index),
                                                                color: Colors.red,
                                                              ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 8),
                                                        // Squad selection
                                                        DropdownButtonFormField<Squad>(
                                                          value: squads.firstWhere(
                                                            (s) => s.id == squadRole.squadId,
                                                            orElse: () => squads.first,
                                                          ),
                                                          decoration: const InputDecoration(
                                                            labelText: 'Unicorn Squad',
                                                            border: OutlineInputBorder(),
                                                          ),
                                                          items: squads.map((squad) {
                                                            return DropdownMenuItem(
                                                              value: squad,
                                                              child: Text(squad.name),
                                                            );
                                                          }).toList(),
                                                          validator: (value) => value?.id == 0 ? 'Please select a squad' : null,
                                                          onChanged: (squad) {
                                                            if (squad != null) {
                                                              _updateSquadRole(index, squad: squad);
                                                            }
                                                          },
                                                        ),
                                                        const SizedBox(height: 16),
                                                        // Role selection
                                                        DropdownButtonFormField<Role>(
                                                          value: roles.firstWhere(
                                                            (r) => r.id == squadRole.roleId,
                                                            orElse: () => roles.first,
                                                          ),
                                                          decoration: const InputDecoration(
                                                            labelText: 'Role',
                                                            border: OutlineInputBorder(),
                                                          ),
                                                          items: roles.map((role) {
                                                            return DropdownMenuItem(
                                                              value: role,
                                                              child: Text(role.name),
                                                            );
                                                          }).toList(),
                                                          validator: (value) => value?.id == 0 ? 'Please select a role' : null,
                                                          onChanged: (role) {
                                                            if (role != null) {
                                                              _updateSquadRole(index, role: role);
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              
                                              // Add Squad Role button
                                              Center(
                                                child: TextButton.icon(
                                                  onPressed: _addSquadRole,
                                                  icon: const Icon(Icons.add_circle_outline),
                                                  label: const Text('Add Another Squad Role'),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : () async {
                                        if (_formKey.currentState!.validate()) {
                                          await _submitForm();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(50),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        elevation: 0,
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text('Complete Setup'),
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
    
    if (_selectedCountry == null) {
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

    setState(() => _isLoading = true);
    try {
      final data = {
        'username': _showFullName ? _fullName : _shortName,
        'country_id': _selectedCountry!.id,
        'squad_roles': _squadRoles,
      };
      print('Submitting form with data: $data');

      await ref.read(avatarServiceProvider).createAvatar(
        username: _showFullName ? _fullName : _shortName,
        squadRoles: _squadRoles,
        countryId: _selectedCountry!.id,
      );
      
      if (mounted) {
        context.go('/main');
      }
    } catch (e) {
      print('Error submitting form: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating avatar: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
