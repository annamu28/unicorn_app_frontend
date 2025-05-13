import 'package:flutter/material.dart';

class MultiSelect extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final List<int> selectedIds;
  final Function(List<int>) onChanged;

  const MultiSelect({
    super.key,
    required this.title,
    required this.items,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
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
} 