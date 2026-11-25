import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../data/file_api.dart';
import '../data/pet.dart';
import '../data/result.dart';
import '../models/pet_model.dart';
import '../widgets/pet_avatar.dart';

class PetFormScreen extends StatefulWidget {
  final int? petId;

  const PetFormScreen({super.key, this.petId});

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _selectedSpecies;
  DateTime? _birthDate;

  // Ссылка на фотографию, сохранённую на сервере.
  String? _imageUrl;

  // Локальная фотография, выбранная из галереи.
  XFile? _selectedImage;

  bool _isSaving = false;
  bool _isPicking = false;
  bool _initialized = false;

  bool get _isEditing => widget.petId != null;
  bool get _busy => _isSaving || _isPicking;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    if (!_isEditing) return;

    final pet = context.read<PetModel>().byId(widget.petId!);

    if (pet == null) return;

    _nameController.text = pet.name;
    _imageUrl = pet.imageUrl;

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

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Выбор фотографии из галереи.
  Future<void> _pickImage() async {
    if (_busy) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (!mounted || image == null) return;

      final size = await image.length();

      if (!mounted) return;

      if (size > 5 * 1024 * 1024) {
        _showError('Размер фотографии не должен превышать 5 МБ');
        return;
      }

      setState(() {
        _selectedImage = image;
      });
    } on PlatformException {
      if (mounted) {
        _showError('Не удалось открыть галерею');
      }
    } on FileSystemException {
      if (mounted) {
        _showError('Не удалось прочитать фотографию');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
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
    if (_busy) return;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecies == null || _birthDate == null) {
      return;
    }

    final model = context.read<PetModel>();
    final fileApi = context.read<FileApi>();

    setState(() {
      _isSaving = true;
    });

    try {
      // Если выбрана новая фотография, сначала загружаем её.
      if (_selectedImage != null) {
        final result = await fileApi.upload(_selectedImage!.path);

        if (!mounted) return;

        switch (result) {
          case Ok<String>():
            setState(() {
              _imageUrl = result.value;
              _selectedImage = null;
            });

          case Err<String>():
            _showError(result.msg);
            return;
        }
      }

      // Сохраняем русское название вида.
      final species = switch (_selectedSpecies!) {
        'dog' => 'Собака',
        'cat' => 'Кошка',
        'rabbit' => 'Кролик',
        _ => 'Другое',
      };

      final pet = Pet(
        id: widget.petId ?? 0,
        name: _nameController.text.trim(),
        species: species,
        birthDate: _formatDate(_birthDate!),
        imageUrl: _imageUrl,
      );

      final String? error;

      if (_isEditing) {
        error = await model.update(pet);
      } else {
        error = await model.add(pet);
      }

      if (!mounted) return;

      if (error != null) {
        _showError(error);
        return;
      }

      // Успех: модель обновила подписанные экраны.
      context.pop();
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // Предварительный просмотр выбранной фотографии.
  Widget _buildAvatar() {
    final image = _selectedImage;

    if (image == null) {
      return PetAvatar(imageUrl: _imageUrl, radius: 56);
    }

    return ClipOval(
      child: Image.file(
        File(image.path),
        width: 112,
        height: 112,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return PetAvatar(imageUrl: _imageUrl, radius: 56);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildAvatar(),

                  FloatingActionButton.small(
                    heroTag: 'pet_photo_picker',
                    onPressed: _busy ? null : _pickImage,
                    tooltip: 'Выбрать фотографию',
                    child: _isPicking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt_outlined),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                _selectedImage != null
                    ? 'Фото выбрано'
                    : _imageUrl != null
                    ? 'Изменить фотографию'
                    : 'Добавить фотографию',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 28),

            // Имя питомца.
            TextFormField(
              controller: _nameController,
              enabled: !_busy,
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
              initialValue: _selectedSpecies,
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
              onChanged: _busy
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
                  onTap: _busy ? null : () => _selectBirthDate(field),
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
                onPressed: _busy ? null : _savePet,
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
