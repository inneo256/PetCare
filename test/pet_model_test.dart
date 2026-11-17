
import 'package:flutter_test/flutter_test.dart';

import 'package:petcare/data/mock_pet_repository.dart';
import 'package:petcare/data/pet.dart';
import 'package:petcare/models/pet_model.dart';

void main() {
  test('PetModel: добавление, обновление, удаление', () async {
    final repository = MockPetRepository();
    final model = PetModel(repository);

    await model.load();
    expect(model.count, 8);

    var notifications = 0;
    model.addListener(() => notifications++);

    final addError = await model.add(
      const Pet(
        id: 0,
        name: 'Тестовый питомец',
        species: 'Кошка',
        birthDate: '01.01.2024',
      ),
    );

    expect(addError, isNull);
    expect(model.count, 9);
    expect(notifications, greaterThan(0));

    final created = model.pets.last;
    expect(created.name, 'Тестовый питомец');

    final updateError = await model.update(
      created.copyWith(name: 'Новое имя'),
    );

    expect(updateError, isNull);
    expect(model.byId(created.id)?.name, 'Новое имя');

    final removeError = await model.remove(created.id);

    expect(removeError, isNull);
    expect(model.count, 8);
    expect(model.byId(created.id), isNull);

    repository.simulateError = true;

    final failedAdd = await model.add(
      const Pet(
        id: 0,
        name: 'Ошибка',
        species: 'Собака',
        birthDate: '01.01.2024',
      ),
    );

    expect(failedAdd, isNotNull);
    expect(model.count, 8);

    model.dispose();
  });
}
