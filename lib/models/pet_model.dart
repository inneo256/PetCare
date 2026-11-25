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

  // Состояние поиска и пагинации.
  static const int _limit = 20;

  int _page = 1;
  String _search = '';
  bool _hasMore = false;
  bool _loadingMore = false;
  String? _loadMoreError;

  // Защита от устаревших ответов.
  int _requestVersion = 0;
  bool _disposed = false;

  List<Pet> get pets => List.unmodifiable(_pets);
  int get count => _pets.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get search => _search;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _loadingMore;
  String? get loadMoreError => _loadMoreError;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Pet? byId(int id) {
    for (final pet in _pets) {
      if (pet.id == id) return pet;
    }
    return null;
  }

  // Загрузка первой страницы.
  Future<void> load({String? search}) async {
    if (_disposed) return;

    final version = ++_requestVersion;

    _search = search?.trim() ?? _search;
    _page = 1;

    _isLoading = true;
    _loadingMore = false;
    _hasMore = false;
    _error = null;
    _loadMoreError = null;

    notifyListeners();

    final result = await repository.fetchAll(
      page: _page,
      limit: _limit,
      search: _search,
    );

    if (_disposed || version != _requestVersion) {
      return;
    }

    switch (result) {
      case Ok<List<Pet>>():
        _pets = result.value;
        _hasMore = result.value.length == _limit;
        _error = null;

      case Err<List<Pet>>():
        _error = result.msg;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Загрузка следующей страницы.
  Future<void> loadMore() async {
    if (_disposed || _isLoading || _loadingMore || !_hasMore) {
      return;
    }

    final version = _requestVersion;

    _loadingMore = true;
    _loadMoreError = null;

    final result = await repository.fetchAll(
      page: _page + 1,
      limit: _limit,
      search: _search,
    );

    if (_disposed || version != _requestVersion) {
      return;
    }

    switch (result) {
      case Ok<List<Pet>>():
        final existingIds = _pets.map((pet) => pet.id).toSet();

        _pets = [
          ..._pets,
          ...result.value.where((pet) => existingIds.add(pet.id)),
        ];

        _page++;
        _hasMore = result.value.length == _limit;

      case Err<List<Pet>>():
        _loadMoreError = result.msg;
    }

    _loadingMore = false;
    notifyListeners();
  }

  // Добавление питомца.
  // null — успех, String — ошибка.
  Future<String?> add(Pet pet) async {
    final result = await repository.create(pet);

    switch (result) {
      case Ok<Pet>():
        if (!_disposed) {
          await load();
        }
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
        if (!_disposed) {
          _pets = [
            for (final item in _pets)
              if (item.id == result.value.id) result.value else item,
          ];

          notifyListeners();
          await load();
        }

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
        if (!_disposed) {
          _pets = [
            for (final pet in _pets)
              if (pet.id != id) pet,
          ];

          notifyListeners();
          await load();
        }

        return null;

      case Err<void>():
        return result.msg;
    }
  }
}
