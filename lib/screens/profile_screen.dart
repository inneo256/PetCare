
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/auth_api.dart';
import '../data/mock_pet_repository.dart';
import '../models/pet_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _simulateError = false;

  @override
  void initState() {
    super.initState();

    // Синхронизируем состояние с Repository.
    // При возвращении на экран настройка не сбросится.
    _simulateError = context.read<MockPetRepository>().simulateError;
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      // Удаляем JWT-токен из SharedPreferences.
      await context.read<AuthApi>().logout();

      if (!context.mounted) return;

      // Возвращаем пользователя на экран входа.
      context.go('/login');
    }
  }

  void _toggleNetworkError(bool value) {
    setState(() {
      _simulateError = value;
    });

    context.read<MockPetRepository>().simulateError = value;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Симуляция сбоя сети включена'
              : 'Симуляция сбоя сети выключена',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final petCount = context.watch<PetModel>().count;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Редактирование профиля '
                        'будет доступно позже',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Редактировать профиль',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 52,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Инна Журак',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'inna@example.com',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.pets_outlined),
                  title: const Text('Мои питомцы'),
                  subtitle: Text('$petCount питомцев'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.go('/pets');
                  },
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Уведомления'),
                  subtitle: const Text('Напоминания о прививках'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Настройка уведомлений '
                              'будет доступна позже',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),

                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Настройки'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Настройки будут доступны позже'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Переключатель аварии из L4.
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.wifi_off_outlined),
              title: const Text('Симулировать сбой сети'),
              subtitle: const Text(
                'Проверка обработки ошибок Repository',
              ),
              value: _simulateError,
              onChanged: _toggleNetworkError,
            ),
          ),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
