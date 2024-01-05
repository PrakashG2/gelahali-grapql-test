class CharacterModel {
  final String name;
  final String status;
  final String species;
    final String gender;


  CharacterModel({
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      name: json['name'],
      status: json['status'],
      species: json['species'],
      gender: json['gender']
    );
  }
}