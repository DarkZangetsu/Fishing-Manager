class CategoriePecheur {
  int? idCategorie;
  String libelle;
  String? description;
  String? niveauExperience;
  String? quotaCapture;

  CategoriePecheur({
    this.idCategorie,
    required this.libelle,
    this.description,
    this.niveauExperience,
    this.quotaCapture,
  });

  Map<String, dynamic> toMap() {
    return {
      'libelle': libelle,
      'description': description,
      'niveau_experience': niveauExperience,
      'quota_capture': quotaCapture,
    };
  }

  factory CategoriePecheur.fromMap(Map<String, dynamic> map) {
    return CategoriePecheur(
      idCategorie: map['id_categorie'],
      libelle: map['libelle'],
      description: map['description'],
      niveauExperience: map['niveau_experience'],
      quotaCapture: map['quota_capture'],
    );
  }
}
