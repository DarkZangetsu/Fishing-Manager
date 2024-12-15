class TechniquePeche {
  int? idTechnique;
  String nom;
  String? description;
  int? idCategorie;
  String? difficulte;
  String? materielRequis;
  String? saisonRecommandee;

  TechniquePeche({
    this.idTechnique,
    required this.nom,
    this.description,
    this.idCategorie,
    this.difficulte,
    this.materielRequis,
    this.saisonRecommandee,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'description': description,
      'id_categorie': idCategorie,
      'difficulte': difficulte,
      'materiel_requis': materielRequis,
      'saison_recommandee': saisonRecommandee,
    };
  }

  factory TechniquePeche.fromMap(Map<String, dynamic> map) {
    return TechniquePeche(
      idTechnique: map['id_technique'],
      nom: map['nom'],
      description: map['description'],
      idCategorie: map['id_categorie'],
      difficulte: map['difficulte'],
      materielRequis: map['materiel_requis'],
      saisonRecommandee: map['saison_recommandee'],
    );
  }
}