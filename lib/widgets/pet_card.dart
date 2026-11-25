import 'package:flutter/material.dart';

import 'pet_avatar.dart';

class PetCard extends StatelessWidget {
  final String name;
  final String species;
  final String birthDate;
  final String? imageUrl;
  final IconData icon;
  final VoidCallback onTap;

  const PetCard({
    super.key,
    required this.name,
    required this.species,
    required this.birthDate,
    this.imageUrl,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: PetAvatar(imageUrl: imageUrl, radius: 28, icon: icon),

        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),

        subtitle: Text('$species • Дата рождения: $birthDate'),

        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
