import 'package:flutter/material.dart';

class NameDisplay extends StatelessWidget {
  final String fullName;
  final String shortName;
  final bool showFullName;
  final ValueChanged<bool> onToggle;
  final VoidCallback onFirstLastInitial;

  const NameDisplay({
    Key? key,
    required this.fullName,
    required this.shortName,
    required this.showFullName,
    required this.onToggle,
    required this.onFirstLastInitial,
  }) : super(key: key);

  String get _nameLabel => showFullName ? 'Full Name' : 'Short Name';
  String get _displayName => showFullName ? fullName : shortName;

  @override
  Widget build(BuildContext context) {
    return Column(
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
            _displayName,
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
              'Show ${showFullName ? 'Short' : 'Full'} Name',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            Switch(
              value: showFullName,
              onChanged: onToggle,
              activeColor: Colors.black,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // First name + last initial button
        TextButton.icon(
          onPressed: onFirstLastInitial,
          icon: const Icon(Icons.edit),
          label: const Text('Use First Name + Last Initial'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
} 