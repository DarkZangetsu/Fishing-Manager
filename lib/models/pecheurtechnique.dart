class PecheurTechnique {
  final int idPecheur;
  final int idTechnique;
  final DateTime? dateApprentissage;
  final String? niveauMaitrise;

  PecheurTechnique({
    required this.idPecheur,
    required this.idTechnique,
    this.dateApprentissage,
    this.niveauMaitrise,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_pecheur': idPecheur,
      'id_technique': idTechnique,
      'date_apprentissage': dateApprentissage?.toIso8601String(),
      'niveau_maitrise': niveauMaitrise,
    };
  }


  factory PecheurTechnique.fromMap(Map<String, dynamic> map) {
    return PecheurTechnique(
      idPecheur: map['id_pecheur'],
      idTechnique: map['id_technique'],
      dateApprentissage: map['date_apprentissage'] != null
          ? DateTime.parse(map['date_apprentissage'])
          : null,
      niveauMaitrise: map['niveau_maitrise'],
    );
  }
}
