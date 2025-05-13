import 'package:flutter/material.dart';
import '../../../models/avatar_models.dart';

class SquadRoleSelector extends StatelessWidget {
  final List<SquadRoleSelection> squadRoles;
  final List<Squad> squads;
  final List<Role> roles;
  final Function(int) onRemove;
  final Function(int, {Squad? squad, Role? role}) onUpdate;
  final VoidCallback onAdd;

  const SquadRoleSelector({
    Key? key,
    required this.squadRoles,
    required this.squads,
    required this.roles,
    required this.onRemove,
    required this.onUpdate,
    required this.onAdd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
        ...squadRoles.asMap().entries.map((entry) {
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
                      if (squadRoles.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => onRemove(index),
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
                        onUpdate(index, squad: squad);
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
                        onUpdate(index, role: role);
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
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Another Squad Role'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
} 