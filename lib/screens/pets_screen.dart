import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/pet_model.dart';
import '../widgets/pet_card.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final model = context.watch<PetModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои питомцы'),
        actions: [
          // Счётчик питомцев через Consumer.
          Consumer<PetModel>(
            builder: (context, model, child) {
              return Badge(label: Text('${model.count}'), child: child!);
            },
            child: const Icon(Icons.pets_outlined),
          ),
          const SizedBox(width: 16),
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

      // Загрузка, ошибка или список питомцев.
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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Поиск питомца.
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

                // Фильтры.
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

                if (model.pets.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Питомцев пока нет'),
                    ),
                  ),

                // Карточки питомцев с удалением свайпом.
                ...model.pets.map(
                  (pet) => Dismissible(
                    key: ValueKey(pet.id),
                    direction: DismissDirection.endToStart,

                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: colorScheme.errorContainer,
                      child: Icon(
                        Icons.delete_outline,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),

                    confirmDismiss: (_) async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Удалить питомца?'),
                          content: Text(
                            'Вы действительно хотите удалить '
                            '${pet.name}?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, false);
                              },
                              child: const Text('Отмена'),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(dialogContext, true);
                              },
                              child: const Text('Удалить'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true || !context.mounted) {
                        return false;
                      }

                      // Удаляем через модель и Repository.
                      final error = await context.read<PetModel>().remove(
                        pet.id,
                      );

                      if (!context.mounted) {
                        return false;
                      }

                      if (error != null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(error)));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Питомец ${pet.name} удалён')),
                        );
                      }

                      // Список уже обновился через
                      // notifyListeners().
                      return false;
                    },

                    child: PetCard(
                      name: pet.name,
                      species: pet.species,
                      birthDate: pet.birthDate,
                      icon: Icons.pets,
                      onTap: () => context.push('/pets/${pet.id}'),
                    ),
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
