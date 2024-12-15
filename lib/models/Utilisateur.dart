enum UserRole { admin, utilisateur }

class Utilisateur {
  final int? idUtilisateur;
  final String nomUtilisateur;
  final String email;
  final String motDePasse;
  final UserRole role;
  final DateTime? dateCreation;
  final DateTime? dernierConnexion;
  final bool estActif;

  Utilisateur({
    this.idUtilisateur,
    required this.nomUtilisateur,
    required this.email,
    required this.motDePasse,
    this.role = UserRole.utilisateur,
    this.dateCreation,
    this.dernierConnexion,
    this.estActif = true,
  });

  // Convertir un map en Utilisateur
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      idUtilisateur: map['id_utilisateur'],
      nomUtilisateur: map['nom_utilisateur'],
      email: map['email'],
      motDePasse: map['mot_de_passe'],
      role: UserRole.values.firstWhere((e) => e.toString() == 'UserRole.${map['role']}'),
      dateCreation: map['date_creation'] != null ? DateTime.parse(map['date_creation']) : null,
      dernierConnexion: map['derniere_connexion'] != null ? DateTime.parse(map['derniere_connexion']) : null,
      estActif: map['est_actif'] == 1,
    );
  }

  // Convertir un Utilisateur en map
  Map<String, dynamic> toMap() {
    return {
      'id_utilisateur': idUtilisateur,
      'nom_utilisateur': nomUtilisateur,
      'email': email,
      'mot_de_passe': motDePasse,
      'role': role.toString().split('.').last,
      'date_creation': dateCreation?.toIso8601String(),
      'derniere_connexion': dernierConnexion?.toIso8601String(),
      'est_actif': estActif ? 1 : 0,
    };
  }

  // Copier avec modification
  Utilisateur copyWith({
    int? idUtilisateur,
    String? nomUtilisateur,
    String? email,
    String? motDePasse,
    UserRole? role,
    DateTime? dateCreation,
    DateTime? dernierConnexion,
    bool? estActif,
  }) {
    return Utilisateur(
      idUtilisateur: idUtilisateur ?? this.idUtilisateur,
      nomUtilisateur: nomUtilisateur ?? this.nomUtilisateur,
      email: email ?? this.email,
      motDePasse: motDePasse ?? this.motDePasse,
      role: role ?? this.role,
      dateCreation: dateCreation ?? this.dateCreation,
      dernierConnexion: dernierConnexion ?? this.dernierConnexion,
      estActif: estActif ?? this.estActif,
    );
  }
}