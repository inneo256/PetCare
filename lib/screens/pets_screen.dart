
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/pet_card.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои питомцы'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Профиль',
          ),
          IconButton(
            onPressed: () => context.push('/vaccinations'),
            icon: const Icon(Icons.vaccines_outlined),
            tooltip: 'Календарь прививок',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Поиск питомца',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Все'),
                  selected: true,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Собаки'),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Кошки'),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Кролики'),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...MockData.pets.map(
                (pet) => PetCard(
              name: pet['name'].toString(),
              species: pet['species'].toString(),
              birthDate: pet['birthDate'].toString(),
              icon: Icons.pets,
              onTap: () => context.push('/pets/${pet['id']}'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/pets/new'),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
    );
  }
}
