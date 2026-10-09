import 'package:flutter/material.dart';

class VetVisitFormScreen extends StatelessWidget {
  const VetVisitFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый визит'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownMenu<String>(
            width: double.infinity,
            label: const Text('Питомец'),
            leadingIcon: const Icon(Icons.pets),
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                value: 'mia',
                label: 'Мия',
              ),
              DropdownMenuEntry(
                value: 'barni',
                label: 'Барни',
              ),
              DropdownMenuEntry(
                value: 'luna',
                label: 'Луна',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Дата визита',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Причина визита',
              prefixIcon: Icon(Icons.medical_services_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Диагноз',
              prefixIcon: Icon(Icons.description_outlined),
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Стоимость',
              prefixIcon: Icon(Icons.payments_outlined),
              suffixText: 'MDL',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_outlined),
              label: const Text('Сохранить визит'),
            ),
          ),
        ],
      ),
    );
  }
}