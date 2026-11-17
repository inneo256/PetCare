import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/pet_model.dart';

class PetDetailsScreen extends StatelessWidget {
  final int id;

  const PetDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final model = context.watch<PetModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка питомца'),
        actions: [
          IconButton(
            onPressed:
                model.isLoading || model.error != null || model.byId(id) == null
                ? null
                : () => context.push('/pets/$id/edit'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: model.isLoading
          ? const Center(child: CircularProgressIndicator())
          : model.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      model.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<PetModel>().load();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            )
          : _buildPetContent(context, model, colorScheme),
    );
  }

  Widget _buildPetContent(
    BuildContext context,
    PetModel model,
    ColorScheme colorScheme,
  ) {
    final pet = model.byId(id);

    if (pet == null) {
      return const Center(child: Text('Питомец не найден'));
    }

    final name = pet.name;
    final species = pet.species;
    final birthDate = pet.birthDate;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.pets,
                    size: 52,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(species, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                _InfoRow(label: 'Дата рождения', value: birthDate),
                const _InfoRow(label: 'Владелец', value: 'Инна'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: Text(
                'Визиты к ветеринару',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            FilledButton.icon(
              onPressed: () => context.push('/pets/vet-visits/new'),
              icon: const Icon(Icons.add),
              label: const Text('Добавить'),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.medical_services_outlined,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            title: const Text('Плановый осмотр'),
            subtitle: const Text('15.09.2026 • Диагноз: Здорова'),
            trailing: const Text('350 MDL'),
          ),
        ),

        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.secondaryContainer,
              child: Icon(
                Icons.medical_services_outlined,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            title: const Text('Проблемы с пищеварением'),
            subtitle: const Text('20.05.2026 • Диагноз: Гастрит'),
            trailing: const Text('480 MDL'),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Прививки',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.tertiaryContainer,
              child: Icon(
                Icons.vaccines_outlined,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
            title: const Text('Комплексная вакцина'),
            subtitle: const Text('15.09.2026'),
            trailing: const Text('15.09.2027'),
          ),
        ),

        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.tertiaryContainer,
              child: Icon(
                Icons.vaccines_outlined,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
            title: const Text('Бешенство'),
            subtitle: const Text('15.09.2026'),
            trailing: const Text('15.09.2027'),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
