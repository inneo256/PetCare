import 'pet.dart';
import 'result.dart';

abstract class PetRepository {
  Future<Result<List<Pet>>> fetchAll({
    int page = 1,
    int limit = 20,
    String? search,
  });

  Future<Result<Pet>> fetchById(int id);

  Future<Result<Pet>> create(Pet pet);

  Future<Result<Pet>> update(Pet pet);

  Future<Result<void>> delete(int id);
}
