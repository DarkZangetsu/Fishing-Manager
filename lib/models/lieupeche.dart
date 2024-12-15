class LieuPeche {
  int? idLieu;
  String nom;
  double? latitude;
  double? longitude;
  String? description;
  String? typeEau;
  double? profondeur;
  String? acces;
  String? restrictions;
  String? proprietaire;

  LieuPeche({
    this.idLieu,
    required this.nom,
    this.latitude,
    this.longitude,
    this.description,
    this.typeEau,
    this.profondeur,
    this.acces,
    this.restrictions,
    this.proprietaire,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'type_eau': typeEau,
      'profondeur': profondeur,
      'acces': acces,
      'restrictions': restrictions,
      'proprietaire': proprietaire,
    };
  }

  factory LieuPeche.fromMap(Map<String, dynamic> map) {
    return LieuPeche(
      idLieu: map['id_lieu'],
      nom: map['nom'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      description: map['description'],
      typeEau: map['type_eau'],
      profondeur: map['profondeur'],
      acces: map['acces'],
      restrictions: map['restrictions'],
      proprietaire: map['proprietaire'],
    );
  }
}