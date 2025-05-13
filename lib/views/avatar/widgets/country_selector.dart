import 'package:flutter/material.dart';
import '../../../models/avatar_models.dart';

class CountrySelector extends StatelessWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final ValueChanged<Country?> onChanged;

  const CountrySelector({
    Key? key,
    required this.countries,
    required this.selectedCountry,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Country>(
      value: selectedCountry,
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
      onChanged: onChanged,
    );
  }
} 