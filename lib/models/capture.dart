class Capture {
  int? idCapture;
  int? idPecheur;
  int? idLieu;
  int? idMeteo;
  int? idTechnique;
  String nomProduit;
  double? quantite;
  double? poids;
  double? taille;
  DateTime? dateCapture;
  String? heureCapture;
  String? etatProduit;
  String? destination;
  String? observations;

  Capture({
    this.idCapture,
    this.idPecheur,
    this.idLieu,
    this.idMeteo,
    this.idTechnique,
    required this.nomProduit,
    this.quantite,
    this.poids,
    this.taille,
    this.dateCapture,
    this.heureCapture,
    this.etatProduit,
    this.destination,
    this.observations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_pecheur': idPecheur,
      'id_lieu': idLieu,
      'id_meteo': idMeteo,
      'id_technique': idTechnique,
      'nom_produit': nomProduit,
      'quantite': quantite,
      'poids': poids,
      'taille': taille,
      'date_capture': dateCapture?.toIso8601String(),
      'heure_capture': heureCapture,
      'etat_produit': etatProduit,
      'destination': destination,
      'observations': observations,
    };
  }

  factory Capture.fromMap(Map<String, dynamic> map) {
    return Capture(
      idCapture: map['id_capture'],
      idPecheur: map['id_pecheur'],
      idLieu: map['id_lieu'],
      idMeteo: map['id_meteo'],
      idTechnique: map['id_technique'],
      nomProduit: map['nom_produit'],
      quantite: map['quantite'],
      poids: map['poids'],
      taille: map['taille'],
      dateCapture: map['date_capture'] != null ? DateTime.parse(map['date_capture']) : null,
      heureCapture: map['heure_capture'],
      etatProduit: map['etat_produit'],
      destination: map['destination'],
      observations: map['observations'],
    );
  }
}