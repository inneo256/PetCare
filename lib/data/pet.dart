
class Pet {
  final int id;
  final String name;
  final String species;
  final String birthDate;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.birthDate,
  });

  Pet copyWith({
    int? id,
    String? name,
    String? species,
    String? birthDate,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
