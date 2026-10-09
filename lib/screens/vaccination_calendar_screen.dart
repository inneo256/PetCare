import 'package:flutter/material.dart';

class VaccinationCalendarScreen extends StatelessWidget {
  const VaccinationCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь прививок'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Ближайшие прививки',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colorScheme.errorContainer,
                child: Icon(
                  Icons.vaccines_outlined,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              title: const Text('Мия — Бешенство'),
              subtitle: const Text('Следующая прививка: 15.10.2026'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colorScheme.tertiaryContainer,
                child: Icon(
                  Icons.vaccines_outlined,
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              title: const Text('Барни — Комплексная'),
              subtitle: const Text('Следующая прививка: 28.10.2026'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colorScheme.secondaryContainer,
                child: Icon(
                  Icons.vaccines_outlined,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              title: const Text('Луна — Бешенство'),
              subtitle: const Text('Следующая прививка: 05.11.2026'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.vaccines_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              title: const Text('Макс — Комплексная'),
              subtitle: const Text('Следующая прививка: 17.11.2026'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}