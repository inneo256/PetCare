import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/pet_model.dart';
import '../widgets/pet_card.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController(
      text: context.read<PetModel>().search,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    context.read<PetModel>().load(search: query);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final model = context.watch<PetModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои питомцы'),
        actions: [
          // Счётчик загруженных питомцев.
          Consumer<PetModel>(
            builder: (context, model, child) {
              return Badge(label: Text('${model.count}'), child: child!);
            },
            child: const Icon(Icons.pets_outlined),
          ),

          const SizedBox(width: 8),

          // Обновление списка.
          IconButton(
            onPressed: model.isLoading
                ? null
                : () {
                    context.read<PetModel>().load();
                  },
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить список',
          ),

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

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                // Серверный поиск питомцев.
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _submitSearch,
                  decoration: InputDecoration(
                    hintText: 'Поиск питомца',
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _submitSearch(_searchController.text);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Очистить поиск',
                      onPressed: () {
                        _searchController.clear();
                        _submitSearch('');
                      },
                    ),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                  ),
                ),

                const SizedBox(height: 16),

                // Существующие фильтры.
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
              ],
            ),
          ),

          Expanded(
            child: model.isLoading
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
                : model.pets.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        model.search.isEmpty
                            ? 'Питомцев пока нет'
                            : 'Питомцы не найдены',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: model.pets.length + (model.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Хвост списка для пагинации.
                      if (index == model.pets.length) {
                        if (model.loadMoreError != null) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  model.loadMoreError!,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    model.loadMore();
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Повторить'),
                                ),
                              ],
                            ),
                          );
                        }

                        model.loadMore();

                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final pet = model.pets[index];

                      return Dismissible(
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
                                'Вы действительно хотите '
                                'удалить ${pet.name}?',
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
                              SnackBar(
                                content: Text(
                                  'Питомец ${pet.name} '
                                  'удалён',
                                ),
                              ),
                            );
                          }

                          return false;
                        },

                        child: PetCard(
                          name: pet.name,
                          species: pet.species,
                          birthDate: pet.birthDate,
                          icon: Icons.pets,
                          onTap: () => context.push('/pets/${pet.id}'),
                        ),
                      );
                    },
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
