
import 'package:flutter/foundation.dart';

import '../data/pet.dart';
import '../data/pet_repository.dart';
import '../data/result.dart';

class PetModel extends ChangeNotifier {
  final PetRepository repository;

  PetModel(this.repository);

  List<Pet> _pets = [];
  bool _isLoading = false;
  String? _error;

  List<Pet> get pets => List.unmodifiable(_pets);
  int get count => _pets.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Pet? byId(int id) {
    for (final pet in _pets) {
      if (pet.id == id) return pet;
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await repository.fetchAll();

    switch (result) {
      case Ok<List<Pet>>():
        _pets = result.value;
        _error = null;
      case Err<List<Pet>>():
        _error = result.msg;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Добавление питомца.
  // null — успех, String — ошибка.
  Future<String?> add(Pet pet) async {
    final result = await repository.create(pet);

    switch (result) {
      case Ok<Pet>():
        _pets = [..._pets, result.value];
        notifyListeners();
        return null;

      case Err<Pet>():
        return result.msg;
    }
  }

  // Обновление питомца.
  Future<String?> update(Pet pet) async {
    final result = await repository.update(pet);

    switch (result) {
      case Ok<Pet>():
        _pets = [
          for (final item in _pets)
            if (item.id == result.value.id)
              result.value
            else
              item,
        ];
        notifyListeners();
        return null;

      case Err<Pet>():
        return result.msg;
    }
  }

  // Удаление питомца.
  Future<String?> remove(int id) async {
    final result = await repository.delete(id);

    switch (result) {
      case Ok<void>():
        _pets = [
          for (final pet in _pets)
            if (pet.id != id) pet,
        ];
        notifyListeners();
        return null;

      case Err<void>():
        return result.msg;
    }
  }
}
