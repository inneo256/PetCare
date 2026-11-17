
import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';

class PetModel extends ChangeNotifier {

  final List<Map<String, dynamic>> _pets =
  MockData.pets.map((pet) {
    return <String, dynamic>{
      'id': pet.id,
      'name': pet.name,
      'species': pet.species,
      'birthDate': pet.birthDate,
    };
  }).toList();


  // Коллекция только для чтения.
  List<Map<String, dynamic>> get pets =>
      List.unmodifiable(
        _pets.map((pet) => Map<String, dynamic>.unmodifiable(pet)),
      );

  // Общее количество питомцев.
  int get count => _pets.length;

  // Поиск питомца по ID.
  Map<String, dynamic>? byId(int id) {
    for (final pet in _pets) {
      if (pet['id'] == id) {
        return Map<String, dynamic>.unmodifiable(pet);
      }
    }
    return null;
  }

  // Добавление питомца.
  void add(Map<String, dynamic> pet) {
    _pets.add(Map<String, dynamic>.from(pet));
    notifyListeners();
  }

  // Удаление питомца.
  void remove(int id) {
    _pets.removeWhere((pet) => pet['id'] == id);
    notifyListeners();
  }

  // Обновление питомца.
  void update(Map<String, dynamic> updatedPet) {
    final index = _pets.indexWhere(
          (pet) => pet['id'] == updatedPet['id'],
    );

    if (index != -1) {
      _pets[index] = Map<String, dynamic>.from(updatedPet);
      notifyListeners();
    }
  }
}
