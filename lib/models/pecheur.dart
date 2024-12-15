class Pecheur {
  int? idPecheur;
  String nom;
  String? prenom;
  DateTime? dateNaissance;
  int? idCategorie;
  String? numeroLicence;
  String? adresse;
  String? telephone;
  String? email;
  DateTime? dateInscription;
  String? photoProfil;
  String? statut;

  Pecheur({
    this.idPecheur,
    required this.nom,
    this.prenom,
    this.dateNaissance,
    this.idCategorie,
    this.numeroLicence,
    this.adresse,
    this.telephone,
    this.email,
    this.dateInscription,
    this.photoProfil,
    this.statut,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'prenom': prenom,
      'date_naissance': dateNaissance?.toIso8601String(),
      'id_categorie': idCategorie,
      'numero_licence': numeroLicence,
      'adresse': adresse,
      'telephone': telephone,
      'email': email,
      'photo_profil': photoProfil,
      'statut': statut,
    };
  }

  factory Pecheur.fromMap(Map<String, dynamic> map) {
    return Pecheur(
      idPecheur: map['id_pecheur'],
      nom: map['nom'],
      prenom: map['prenom'],
      dateNaissance: map['date_naissance'] != null ? DateTime.parse(map['date_naissance']) : null,
      idCategorie: map['id_categorie'],
      numeroLicence: map['numero_licence'],
      adresse: map['adresse'],
      telephone: map['telephone'],
      email: map['email'],
      dateInscription: map['date_inscription'] != null ? DateTime.parse(map['date_inscription']) : null,
      photoProfil: map['photo_profil'],
      statut: map['statut'],
    );
  }
}