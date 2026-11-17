
import 'mock_data.dart';
import 'pet.dart';
import 'pet_repository.dart';
import 'result.dart';

class MockPetRepository implements PetRepository {
  // Данные хранятся в памяти.
  final List<Pet> _pets = List.of(MockData.pets);

  // Следующий свободный ID.
  int _nextId = 1000;

  // Переключатель ошибки сети.
  bool simulateError = false;

  // Имитация задержки сервера.
  static const Duration _latency =
  Duration(milliseconds: 800);

  static const String _networkError =
      'Сервер не отвечает — повторите попытку';

  // Получить всех питомцев.
  @override
  Future<Result<List<Pet>>> fetchAll() async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    return Ok(List.unmodifiable(_pets));
  }

  // Получить питомца по ID.
  @override
  Future<Result<Pet>> fetchById(int id) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    for (final pet in _pets) {
      if (pet.id == id) {
        return Ok(pet);
      }
    }

    return const Err('Питомец не найден');
  }

  // Добавить питомца.
  @override
  Future<Result<Pet>> create(Pet pet) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    final newPet = pet.copyWith(
      id: _nextId++,
    );

    _pets.add(newPet);

    return Ok(newPet);
  }

  // Обновить питомца.
  @override
  Future<Result<Pet>> update(Pet pet) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    final index = _pets.indexWhere(
          (item) => item.id == pet.id,
    );

    if (index == -1) {
      return const Err('Питомец не найден');
    }

    _pets[index] = pet;

    return Ok(pet);
  }

  // Удалить питомца.
  @override
  Future<Result<void>> delete(int id) async {
    await Future.delayed(_latency);

    if (simulateError) {
      return const Err(_networkError);
    }

    final index = _pets.indexWhere(
          (pet) => pet.id == id,
    );

    if (index == -1) {
      return const Err('Питомец не найден');
    }

    _pets.removeAt(index);

    return const Ok<void>(null);
  }
}
