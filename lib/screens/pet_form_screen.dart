import 'package:flutter/material.dart';

class PetFormScreen extends StatelessWidget {
  const PetFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый питомец'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 56,
                  child: Icon(
                    Icons.pets,
                    size: 52,
                  ),
                ),
                FloatingActionButton.small(
                  onPressed: () {},
                  child: const Icon(Icons.camera_alt_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Имя питомца',
              prefixIcon: Icon(Icons.pets),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownMenu<String>(
            width: double.infinity,
            label: const Text('Вид'),
            leadingIcon: const Icon(Icons.category_outlined),
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: 'dog',
                label: 'Собака',
              ),
              DropdownMenuEntry(
                value: 'cat',
                label: 'Кошка',
              ),
              DropdownMenuEntry(
                value: 'rabbit',
                label: 'Кролик',
              ),
              DropdownMenuEntry(
                value: 'other',
                label: 'Другое',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Дата рождения',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}