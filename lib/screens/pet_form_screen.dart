import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key});

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedSpecies;
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: field.value ?? now,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'Выберите дату рождения',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );

    if (selectedDate != null && mounted) {
      setState(() {
        _birthDate = selectedDate;
      });

      field.didChange(selectedDate);
    }
  }

  void _savePet() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Питомец «${_nameController.text.trim()}» успешно добавлен',
        ),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый питомец'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.pets,
                      size: 52,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  FloatingActionButton.small(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Добавление фотографии будет доступно позже',
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.camera_alt_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Имя питомца',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите имя питомца';
                }

                if (value.trim().length < 2) {
                  return 'Минимум 2 символа';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Вид',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'dog',
                  child: Text('Собака'),
                ),
                DropdownMenuItem(
                  value: 'cat',
                  child: Text('Кошка'),
                ),
                DropdownMenuItem(
                  value: 'rabbit',
                  child: Text('Кролик'),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text('Другое'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSpecies = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Выберите вид питомца';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            FormField<DateTime>(
              validator: (value) {
                if (value == null) {
                  return 'Выберите дату рождения';
                }

                return null;
              },
              builder: (field) {
                final date = field.value;

                final formattedDate = date == null
                    ? 'Выберите дату'
                    : '${date.day.toString().padLeft(2, '0')}.'
                    '${date.month.toString().padLeft(2, '0')}.'
                    '${date.year}';

                return InkWell(
                  onTap: () => _selectBirthDate(field),
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Дата рождения',
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      border: const OutlineInputBorder(),
                      errorText: field.errorText,
                    ),
                    child: Text(formattedDate),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _savePet,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}