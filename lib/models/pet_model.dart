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
}
