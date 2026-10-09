import 'package:flutter/material.dart';

class PetCard extends StatelessWidget {
  final String name;
  final String species;
  final String birthDate;
  final IconData icon;

  const PetCard({
    super.key,
    required this.name,
    required this.species,
    required this.birthDate,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$species • Дата рождения: $birthDate',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}