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

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      name: json['name'] as String,
      species: json['species'] as String,
      birthDate: json['birthDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'species': species, 'birthDate': birthDate};
  }

  Pet copyWith({int? id, String? name, String? species, String? birthDate}) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
