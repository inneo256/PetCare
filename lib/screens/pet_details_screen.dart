import 'package:flutter/material.dart';

class PetDetailsScreen extends StatelessWidget {
  const PetDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка питомца'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
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
                    'Мия',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Кошка',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  const _InfoRow(
                    label: 'Дата рождения',
                    value: '12.04.2021',
                  ),
                  const _InfoRow(
                    label: 'Возраст',
                    value: '5 лет',
                  ),
                  const _InfoRow(
                    label: 'Владелец',
                    value: 'Инна',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Визиты к ветеринару',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
              subtitle: const Text(
                '15.09.2026 • Диагноз: Здорова',
              ),
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
              subtitle: const Text(
                '20.05.2026 • Диагноз: Гастрит',
              ),
              trailing: const Text('480 MDL'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Прививки',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
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
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}