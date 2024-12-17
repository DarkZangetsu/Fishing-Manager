import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/Utilisateur.dart';
import '../models/capture.dart';
import '../models/categoriepecheur.dart';
import '../models/conditionmeteo.dart';
import '../models/lieupeche.dart';
import '../models/pecheur.dart';
import '../db/sqlhelper.dart';
import '../models/pecheurtechnique.dart';
import '../models/techniquepeche.dart';

class DatabaseHelper {
  final SqlHelper _sqlHelper = SqlHelper();

  // Utilisateur
  Future<Utilisateur?> authentifier(String email, String motDePasse) async {
    final db = await _sqlHelper.baseDeDonnees;
    String hashedPassword = _hashPassword(motDePasse);

    try {
      // Logs de débogage détaillés
      print('Tentative de connexion:');
      print('Email: $email');
      print('Mot de passe haché: $hashedPassword');

      // Vérifiez si la base de données est ouverte
      print('Base de données ouverte : ${db.isOpen}');

      // Lister tous les utilisateurs pour vérification
      List<Map<String, dynamic>> allUsers = await db.query('utilisateur');
      print('Nombre total d\'utilisateurs : ${allUsers.length}');

      // Imprimer tous les emails dans la base de données
      allUsers.forEach((user) {
        print('Email existant: ${user['email']}');
      });

      List<Map<String, dynamic>> resultats = await db.query(
          'utilisateur',
          where: 'email = ? AND mot_de_passe = ? AND est_actif = 1',
          whereArgs: [email, hashedPassword]
      );

      print('Nombre de résultats: ${resultats.length}');
      if (resultats.isNotEmpty) {
        print('Utilisateur trouvé:');
        print(resultats.first);
      }

      if (resultats.isNotEmpty) {
        Utilisateur utilisateur = Utilisateur.fromMap(resultats.first);
        return utilisateur;
      }
      return null;
    } catch (e) {
      print('Erreur lors de l\'authentification : $e');
      return null;
    }
  }

  Future<Utilisateur?> obtenirUtilisateurParId(int idUtilisateur) async {
    final db = await _sqlHelper.baseDeDonnees;

    List<Map<String, dynamic>> resultats = await db.query(
        'utilisateur',
        where: 'id_utilisateur = ? AND est_actif = 1',
        whereArgs: [idUtilisateur]
    );

    if (resultats.isNotEmpty) {
      return Utilisateur.fromMap(resultats.first);
    }

    return null;
  }

// Ajouter un utilisateur
  Future<int> ajouterUtilisateur(Utilisateur utilisateur) async {
    final db = await _sqlHelper.baseDeDonnees;
    // Hasher le mot de passe avant insertion
    var utilisateurMap = utilisateur.toMap();
    utilisateurMap['mot_de_passe'] = _hashPassword(utilisateurMap['mot_de_passe']);

    return await db.insert('utilisateur', utilisateurMap);
  }

// Modifier un utilisateur
  Future<int> modifierUtilisateur(Utilisateur utilisateur) async {
    final db = await _sqlHelper.baseDeDonnees;
    var utilisateurMap = utilisateur.toMap();

    // Ne mettre à jour le mot de passe que s'il est fourni
    if (utilisateur.motDePasse.isNotEmpty) {
      utilisateurMap['mot_de_passe'] = _hashPassword(utilisateur.motDePasse);
    } else {
      utilisateurMap.remove('mot_de_passe');
    }

    return await db.update(
        'utilisateur',
        utilisateurMap,
        where: 'id_utilisateur = ?',
        whereArgs: [utilisateur.idUtilisateur]
    );
  }

// Réinitialiser le mot de passe
  Future<int> reinitialiserMotDePasse(int idUtilisateur, String nouveauMotDePasse) async {
    final db = await _sqlHelper.baseDeDonnees;
    return await db.update(
        'utilisateur',
        {'mot_de_passe': _hashPassword(nouveauMotDePasse)},
        where: 'id_utilisateur = ?',
        whereArgs: [idUtilisateur]
    );
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

// Récupérer tous les utilisateurs
  Future<List<Utilisateur>> obtenirUtilisateurs() async {
    final db = await _sqlHelper.baseDeDonnees;
    final List<Map<String, dynamic>> maps = await db.query('utilisateur');

    return List.generate(maps.length, (i) {
      return Utilisateur.fromMap(maps[i]);
    });
  }

// Supprimer un utilisateur
  Future<int> supprimerUtilisateur(int idUtilisateur) async {
    final db = await _sqlHelper.baseDeDonnees;
    return await db.delete(
        'utilisateur',
        where: 'id_utilisateur = ?',
        whereArgs: [idUtilisateur]
    );
  }

// Vérifier si un email existe déjà
  Future<bool> emailExiste(String email) async {
    final db = await _sqlHelper.baseDeDonnees;
    List<Map<String, dynamic>> resultats = await db.query(
        'utilisateur',
        where: 'email = ?',
        whereArgs: [email]
    );
    return resultats.isNotEmpty;
  }

  // Catégorie Pêcheur CRUD
  Future<int> ajouterCategoriePecheur(CategoriePecheur categorie) async {
    return await _sqlHelper.inserer('categorie_pecheur', categorie.toMap());
  }

  Future<List<CategoriePecheur>> obtenirCategoriesPecheurs({String? where, List<dynamic>? whereArgs}) async {
    final result = await _sqlHelper.consulter('categorie_pecheur', where: where, whereArgs: whereArgs);
    return result.map((map) => CategoriePecheur.fromMap(map)).toList();
  }

  Future<int> modifierCategoriePecheur(CategoriePecheur categorie) async {
    return await _sqlHelper.modifier(
        'categorie_pecheur',
        categorie.toMap(),
        'id_categorie = ?',
        [categorie.idCategorie]
    );
  }

  Future<int> supprimerCategoriePecheur(int idCategorie) async {
    return await _sqlHelper.supprimer('categorie_pecheur', 'id_categorie = ?', [idCategorie]);
  }

  // Pêcheur CRUD
  Future<int> ajouterPecheur(Pecheur pecheur) async {
    return await _sqlHelper.inserer('pecheur', pecheur.toMap());
  }

  Future<List<Pecheur>> obtenirPecheurs({String? where, List<dynamic>? whereArgs}) async {
    final result = await _sqlHelper.consulter('pecheur', where: where, whereArgs: whereArgs);
    return result.map((map) => Pecheur.fromMap(map)).toList();
  }

  Future<int> modifierPecheur(Pecheur pecheur) async {
    return await _sqlHelper.modifier(
        'pecheur',
        pecheur.toMap(),
        'id_pecheur = ?',
        [pecheur.idPecheur]
    );
  }

  Future<int> supprimerPecheur(int idPecheur) async {
    return await _sqlHelper.supprimer('pecheur', 'id_pecheur = ?', [idPecheur]);
  }

  // Techniques de Pêche CRUD
  Future<int> ajouterTechniquePeche(TechniquePeche technique) async {
    return await _sqlHelper.inserer('technique_peche', technique.toMap());
  }

  Future<List<TechniquePeche>> obtenirTechniquesPeche({String? where, List<dynamic>? whereArgs}) async {
    final result = await _sqlHelper.consulter('technique_peche', where: where, whereArgs: whereArgs);
    return result.map((map) => TechniquePeche.fromMap(map)).toList();
  }

  Future<int> modifierTechniquePeche(TechniquePeche technique) async {
    return await _sqlHelper.modifier(
        'technique_peche',
        technique.toMap(),
        'id_technique = ?',
        [technique.idTechnique]
    );
  }

  Future<int> supprimerTechniquePeche(int idTechnique) async {
    return await _sqlHelper.supprimer('technique_peche', 'id_technique = ?', [idTechnique]);
  }

  // Lieu de Pêche CRUD
  Future<int> ajouterLieuPeche(LieuPeche lieu) async {
    return await _sqlHelper.inserer('lieu_peche', lieu.toMap());
  }

  Future<List<LieuPeche>> obtenirLieuxPeche({String? where, List<dynamic>? whereArgs}) async {
    final result = await _sqlHelper.consulter('lieu_peche', where: where, whereArgs: whereArgs);
    return result.map((map) => LieuPeche.fromMap(map)).toList();
  }

  Future<int> modifierLieuPeche(LieuPeche lieu) async {
    return await _sqlHelper.modifier(
        'lieu_peche',
        lieu.toMap(),
        'id_lieu = ?',
        [lieu.idLieu]
    );
  }

  Future<int> supprimerLieuPeche(int idLieu) async {
    return await _sqlHelper.supprimer('lieu_peche', 'id_lieu = ?', [idLieu]);
  }

  // Conditions Météorologiques CRUD
  Future<int> ajouterConditionMeteo(ConditionMeteo conditionMeteo) async {
    return await _sqlHelper.inserer('condition_meteo', conditionMeteo.toMap());
  }

  Future<List<ConditionMeteo>> obtenirConditionsMeteo({String? where, List<dynamic>? whereArgs}) async {
    final result = await _sqlHelper.consulter('condition_meteo', where: where, whereArgs: whereArgs);
    return result.map((map) => ConditionMeteo.fromMap(map)).toList();
  }

  Future<int> modifierConditionMeteo(ConditionMeteo conditionMeteo) async {
    return await _sqlHelper.modifier(
        'condition_meteo',
        conditionMeteo.toMap(),
        'id_meteo = ?',
        [conditionMeteo.idMeteo]
    );
  }

  Future<int> supprimerConditionMeteo(int idMeteo) async {
    return await _sqlHelper.supprimer('condition_meteo', 'id_meteo = ?', [idMeteo]);
  }

  // Capture CRUD
  Future<int> ajouterCapture(Capture capture) async {
    return await _sqlHelper.inserer('capture', capture.toMap());
  }

  Future<List<Capture>> obtenirCaptures({String? where, List<dynamic>? whereArgs}) async {
    final result = await _sqlHelper.consulter('capture', where: where, whereArgs: whereArgs);
    return result.map((map) => Capture.fromMap(map)).toList();
  }

  Future<int> modifierCapture(Capture capture) async {
    return await _sqlHelper.modifier(
        'capture',
        capture.toMap(),
        'id_capture = ?',
        [capture.idCapture]
    );
  }

  Future<int> supprimerCapture(int idCapture) async {
    return await _sqlHelper.supprimer('capture', 'id_capture = ?', [idCapture]);
  }

  // Mapping Pêcheur-Technique CRUD
  Future<int> ajouterPecheurTechnique(int idPecheur, int idTechnique, {DateTime? dateApprentissage, String? niveauMaitrise}) async {
    return await _sqlHelper.inserer('pecheur_technique', {
      'id_pecheur': idPecheur,
      'id_technique': idTechnique,
      'date_apprentissage': dateApprentissage?.toIso8601String(),
      'niveau_maitrise': niveauMaitrise
    });
  }

  Future<List<PecheurTechnique>> obtenirPecheurTechnique({String? where, List<dynamic>? whereArgs}) async {
    final result = await _sqlHelper.consulter('pecheur_technique', where: where, whereArgs: whereArgs);
    return result.map((map) => PecheurTechnique.fromMap(map)).toList();
  }



  Future<int> supprimerPecheurTechnique(int idPecheur, int idTechnique) async {
    return await _sqlHelper.supprimer(
        'pecheur_technique',
        'id_pecheur = ? AND id_technique = ?',
        [idPecheur, idTechnique]
    );
  }


  Future<Map<String, dynamic>> obtenirStatistiquesCapturesGlobales() async {
    final db = await _sqlHelper.baseDeDonnees;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as nombre_total_captures,
        SUM(quantite) as quantite_totale,
        SUM(poids) as poids_total,
        AVG(poids) as poids_moyen,
        strftime('%Y', date_capture) as annee
      FROM capture
    ''');

    return result.isNotEmpty ? result.first : {};
  }

  // Statistiques de captures par destination
  Future<List<Map<String, dynamic>>> obtenirStatistiquesCapturesParDestination() async {
    final db = await _sqlHelper.baseDeDonnees;
    return await db.rawQuery('''
      SELECT 
        destination, 
        COUNT(*) as nombre_captures, 
        SUM(quantite) as quantite_totale, 
        SUM(poids) as poids_total
      FROM capture
      GROUP BY destination
    ''');
  }

  // Statistiques de captures par lieu de pêche
  Future<List<Map<String, dynamic>>> obtenirStatistiquesCapturesParLieu() async {
    final db = await _sqlHelper.baseDeDonnees;
    return await db.rawQuery('''
      SELECT 
        lp.nom as nom_lieu, 
        COUNT(c.id_capture) as nombre_captures, 
        SUM(c.quantite) as quantite_totale,
        SUM(c.poids) as poids_total
      FROM capture c
      JOIN lieu_peche lp ON c.id_lieu = lp.id_lieu
      GROUP BY lp.id_lieu
      ORDER BY nombre_captures DESC
    ''');
  }

  // Statistiques de captures par technique de pêche
  Future<List<Map<String, dynamic>>> obtenirStatistiquesCapturesParTechnique() async {
    final db = await _sqlHelper.baseDeDonnees;
    return await db.rawQuery('''
      SELECT 
        tp.nom as technique, 
        COUNT(c.id_capture) as nombre_captures, 
        SUM(c.quantite) as quantite_totale,
        SUM(c.poids) as poids_total
      FROM capture c
      JOIN technique_peche tp ON c.id_technique = tp.id_technique
      GROUP BY tp.id_technique
      ORDER BY nombre_captures DESC
    ''');
  }

  // Statistiques des pêcheurs
  Future<Map<String, dynamic>> obtenirStatistiquesPecheurs() async {
    final db = await _sqlHelper.baseDeDonnees;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as nombre_total_pecheurs,
        SUM(CASE WHEN statut = 'actif' THEN 1 ELSE 0 END) as pecheurs_actifs,
        SUM(CASE WHEN statut = 'suspendu' THEN 1 ELSE 0 END) as pecheurs_suspendus,
        (SELECT COUNT(DISTINCT id_pecheur) FROM capture) as pecheurs_ayant_capture
      FROM pecheur
    ''');

    return result.isNotEmpty ? result.first : {};
  }

  // Évolution des captures au fil du temps
  Future<List<Map<String, dynamic>>> obtenirEvolutionCapturesParMois() async {
    final db = await _sqlHelper.baseDeDonnees;
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', date_capture) as mois, 
        COUNT(*) as nombre_captures, 
        SUM(quantite) as quantite_totale,
        SUM(poids) as poids_total
      FROM capture
      GROUP BY mois
      ORDER BY mois
    ''');
  }

  // Répartition des pêcheurs par catégorie
  Future<List<Map<String, dynamic>>> obtenirRepartitionPecheursParCategorie() async {
    final db = await _sqlHelper.baseDeDonnees;
    return await db.rawQuery('''
      SELECT 
        cp.libelle as categorie, 
        COUNT(p.id_pecheur) as nombre_pecheurs
      FROM categorie_pecheur cp
      LEFT JOIN pecheur p ON cp.id_categorie = p.id_categorie
      GROUP BY cp.id_categorie
      ORDER BY nombre_pecheurs DESC
    ''');
  }

  // Conditions météorologiques lors des captures
  Future<List<Map<String, dynamic>>> obtenirStatistiquesConditionsMeteo() async {
    final db = await _sqlHelper.baseDeDonnees;
    return await db.rawQuery('''
      SELECT 
        etat_general, 
        COUNT(*) as nombre_captures,
        AVG(temperature) as temperature_moyenne,
        AVG(vitesse_vent) as vitesse_vent_moyenne
      FROM capture c
      JOIN condition_meteo cm ON c.id_meteo = cm.id_meteo
      GROUP BY etat_general
    ''');
  }
}