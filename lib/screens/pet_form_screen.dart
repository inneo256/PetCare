import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/pet.dart';
import '../models/pet_model.dart';

class PetFormScreen extends StatefulWidget {
  final int? petId;

  const PetFormScreen({super.key, this.petId});

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedSpecies;
  DateTime? _birthDate;

  bool _isSaving = false;
  bool _initialized = false;

  bool get _isEditing => widget.petId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    if (!_isEditing) return;

    final pet = context.read<PetModel>().byId(widget.petId!);

    if (pet == null) return;

    _nameController.text = pet.name;

    // Преобразуем название вида в значение Dropdown.
    _selectedSpecies = switch (pet.species.trim().toLowerCase()) {
      'собака' || 'dog' => 'dog',
      'кошка' || 'cat' => 'cat',
      'кролик' || 'rabbit' => 'rabbit',
      'другое' || 'other' => 'other',
      _ => 'other',
    };

    // Восстанавливаем дату рождения.
    final parts = pet.birthDate.split('.');

    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day != null && month != null && year != null) {
        final parsed = DateTime(year, month, day);

        if (parsed.year == year && parsed.month == month && parsed.day == day) {
          _birthDate = parsed;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
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

    if (!mounted || selectedDate == null) return;

    setState(() {
      _birthDate = selectedDate;
    });

    field.didChange(selectedDate);
  }

  Future<void> _savePet() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecies == null || _birthDate == null) {
      return;
    }

    final model = context.read<PetModel>();

    setState(() {
      _isSaving = true;
    });

    // Сохраняем русское название вида.
    final species = switch (_selectedSpecies!) {
      'dog' => 'Собака',
      'cat' => 'Кошка',
      'rabbit' => 'Кролик',
      _ => 'Другое',
    };

    final pet = Pet(
      // При добавлении Repository выдаст новый id.
      // При редактировании сохраняем существующий id.
      id: widget.petId ?? 0,
      name: _nameController.text.trim(),
      species: species,
      birthDate: _formatDate(_birthDate!),
    );

    final String? error;

    if (_isEditing) {
      error = await model.update(pet);
    } else {
      error = await model.add(pet);
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    // Успех: модель уже обновила все подписанные экраны.
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final existingPet = _isEditing
        ? context.watch<PetModel>().byId(widget.petId!)
        : null;

    if (_isEditing && existingPet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Редактировать питомца')),
        body: const Center(child: Text('Питомец не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Редактировать питомца' : 'Новый питомец'),
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
                    onPressed: _isSaving
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Добавление фотографии '
                                  'будет доступно позже',
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

            // Имя питомца.
            TextFormField(
              controller: _nameController,
              enabled: !_isSaving,
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

            // Вид питомца.
            DropdownButtonFormField<String>(
              value: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Вид',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'dog', child: Text('Собака')),
                DropdownMenuItem(value: 'cat', child: Text('Кошка')),
                DropdownMenuItem(value: 'rabbit', child: Text('Кролик')),
                DropdownMenuItem(value: 'other', child: Text('Другое')),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
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

            // Дата рождения.
            FormField<DateTime>(
              initialValue: _birthDate,
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
                    : _formatDate(date);

                return InkWell(
                  onTap: _isSaving ? null : () => _selectBirthDate(field),
                  borderRadius: BorderRadius.circular(4),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Дата рождения',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
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

            // Кнопка сохранения.
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _savePet,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving
                      ? 'Сохранение...'
                      : _isEditing
                      ? 'Сохранить изменения'
                      : 'Сохранить',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
