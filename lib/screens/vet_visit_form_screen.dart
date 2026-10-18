
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetVisitFormScreen extends StatefulWidget {
  const VetVisitFormScreen({super.key});

  @override
  State<VetVisitFormScreen> createState() => _VetVisitFormScreenState();
}

class _VetVisitFormScreenState extends State<VetVisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _costController = TextEditingController();

  String? _selectedPet;
  DateTime? _visitDate;
  TimeOfDay? _visitTime;

  @override
  void dispose() {
    _reasonController.dispose();
    _diagnosisController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
      helpText: 'Выберите дату визита',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );

    if (date != null && mounted) {
      setState(() {
        _visitDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _visitTime ?? TimeOfDay.now(),
      helpText: 'Выберите время визита',
      cancelText: 'Отмена',
      confirmText: 'Выбрать',
    );

    if (time != null && mounted) {
      setState(() {
        _visitTime = time;
      });
    }
  }

  void _saveVisit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPet == null ||
        _visitDate == null ||
        _visitTime == null) {
      setState(() {});
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Визит успешно добавлен'),
      ),
    );

    context.pop();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Выберите дату';

    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Новый визит'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedPet,
              decoration: const InputDecoration(
                labelText: 'Питомец',
                prefixIcon: Icon(Icons.pets),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'mia', child: Text('Мия')),
                DropdownMenuItem(value: 'barni', child: Text('Барни')),
                DropdownMenuItem(value: 'luna', child: Text('Луна')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPet = value;
                });
              },
              validator: (value) =>
              value == null ? 'Выберите питомца' : null,
            ),
            const SizedBox(height: 16),
            FormField<DateTime>(
              validator: (value) =>
              value == null ? 'Выберите дату визита' : null,
              builder: (field) => InkWell(
                onTap: () async {
                  await _selectDate();
                  field.didChange(_visitDate);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Дата визита',
                    prefixIcon:
                    const Icon(Icons.calendar_today_outlined),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    border: const OutlineInputBorder(),
                    errorText: field.errorText,
                  ),
                  child: Text(_formatDate(_visitDate)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FormField<TimeOfDay>(
              validator: (value) =>
              value == null ? 'Выберите время визита' : null,
              builder: (field) => InkWell(
                onTap: () async {
                  await _selectTime();
                  field.didChange(_visitTime);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Время визита',
                    prefixIcon: const Icon(Icons.access_time),
                    suffixIcon: const Icon(Icons.arrow_drop_down),
                    border: const OutlineInputBorder(),
                    errorText: field.errorText,
                  ),
                  child: Text(
                    _visitTime?.format(context) ?? 'Выберите время',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Причина визита',
                prefixIcon: Icon(Icons.medical_services_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Укажите причину визита';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _diagnosisController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Диагноз',
                prefixIcon: Icon(Icons.description_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Стоимость',
                prefixIcon: Icon(Icons.payments_outlined),
                suffixText: 'MDL',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final text = value?.trim() ?? '';

                if (text.isEmpty) {
                  return 'Укажите стоимость';
                }

                final cost = double.tryParse(
                  text.replaceAll(',', '.'),
                );

                if (cost == null || cost < 0) {
                  return 'Введите корректную стоимость';
                }

                return null;
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveVisit,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Сохранить визит'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
