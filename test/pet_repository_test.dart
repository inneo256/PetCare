
import 'package:flutter_test/flutter_test.dart';

import 'package:petcare/data/mock_pet_repository.dart';
import 'package:petcare/data/pet.dart';
import 'package:petcare/data/result.dart';

void main() {
  test('PetRepository: CRUD и ошибка сети', () async {
    final repository = MockPetRepository();

    // Получаем исходные данные.
    final initial = await repository.fetchAll();
    expect(initial, isA<Ok<List<Pet>>>());
    expect((initial as Ok<List<Pet>>).value.length, 8);

    // Добавляем питомца.
    final created = await repository.create(
      const Pet(
        id: 0,
        name: 'Тест',
        species: 'Кошка',
        birthDate: '01.01.2024',
      ),
    );

    expect(created, isA<Ok<Pet>>());
    final pet = (created as Ok<Pet>).value;
    expect(pet.id, 1000);

    // Проверяем получение по ID.
    final found = await repository.fetchById(pet.id);
    expect(found, isA<Ok<Pet>>());

    // Обновляем питомца.
    final updated = await repository.update(
      pet.copyWith(name: 'Новое имя'),
    );
    expect((updated as Ok<Pet>).value.name, 'Новое имя');

    // Удаляем питомца.
    final deleted = await repository.delete(pet.id);
    expect(deleted, isA<Ok<void>>());

    // Удалённый питомец больше не существует.
    final missing = await repository.fetchById(pet.id);
    expect(missing, isA<Err<Pet>>());

    // Проверяем симуляцию ошибки.
    repository.simulateError = true;
    final failure = await repository.fetchAll();
    expect(failure, isA<Err<List<Pet>>>());

    // После отключения ошибки данные доступны.
    repository.simulateError = false;
    final recovered = await repository.fetchAll();
    expect(recovered, isA<Ok<List<Pet>>>());
  });
}
