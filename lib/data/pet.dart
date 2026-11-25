class Pet {
  final int id;
  final String name;
  final String species;
  final String birthDate;
  final String? imageUrl;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.birthDate,
    this.imageUrl,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      name: json['name'] as String,
      species: json['species'] as String,
      birthDate: json['birthDate'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'birthDate': birthDate,
      'imageUrl': imageUrl,
    };
  }

  Pet copyWith({
    int? id,
    String? name,
    String? species,
    String? birthDate,
    String? imageUrl,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      birthDate: birthDate ?? this.birthDate,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
