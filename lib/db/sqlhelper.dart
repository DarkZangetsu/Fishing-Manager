import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlHelper {
  static final SqlHelper _instance = SqlHelper._interne();
  static Database? _baseDeDonnees;

  factory SqlHelper() => _instance;

  SqlHelper._interne();

  Future<Database> get baseDeDonnees async {
    if (_baseDeDonnees != null) return _baseDeDonnees!;
    _baseDeDonnees = await _initialiserBaseDeDonnees();
    return _baseDeDonnees!;
  }

  Future<Database> _initialiserBaseDeDonnees() async {
    String chemin = join(await getDatabasesPath(), 'base_peche.db');
    return await openDatabase(
      chemin,
      version: 1,
      onCreate: _creerTables,
    );
  }

  Future<void> _creerTables(Database db, int version) async {
    // Table Utilisateur
    await db.execute('''
      CREATE TABLE utilisateur (
        id_utilisateur INTEGER PRIMARY KEY AUTOINCREMENT,
        nom_utilisateur TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        mot_de_passe TEXT NOT NULL,
        role TEXT NOT NULL,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        derniere_connexion DATETIME,
        est_actif INTEGER DEFAULT 1
      )
    ''');
    // Table Catégorie de Pêcheurs
    await db.execute('''
      CREATE TABLE categorie_pecheur (
        id_categorie INTEGER PRIMARY KEY AUTOINCREMENT,
        libelle TEXT NOT NULL UNIQUE, 
        description TEXT,
        niveau_experience TEXT,
        quota_capture TEXT
      )
    ''');

    // Table Pêcheurs
    await db.execute('''
      CREATE TABLE pecheur (
        id_pecheur INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prenom TEXT,
        date_naissance DATE,
        id_categorie INTEGER,
        numero_licence TEXT UNIQUE,
        adresse TEXT,
        telephone TEXT,
        email TEXT,
        date_inscription DATETIME DEFAULT CURRENT_TIMESTAMP,
        photo_profil TEXT,
        statut TEXT CHECK (statut IN ('actif', 'inactif', 'suspendu')),
        FOREIGN KEY (id_categorie) REFERENCES categorie_pecheur (id_categorie)
      )
    ''');

    // Table Techniques de Pêche
    await db.execute('''
      CREATE TABLE technique_peche (
        id_technique INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        description TEXT,
        id_categorie INTEGER,
        difficulte TEXT,
        materiel_requis TEXT,
        saison_recommandee TEXT,
        FOREIGN KEY (id_categorie) REFERENCES categorie_pecheur (id_categorie)
      )
    ''');

    // Table Mapping Pêcheur-Technique
    await db.execute('''
      CREATE TABLE pecheur_technique (
        id_pecheur INTEGER,
        id_technique INTEGER,
        date_apprentissage DATE,
        niveau_maitrise TEXT,
        PRIMARY KEY (id_pecheur, id_technique),
        FOREIGN KEY (id_pecheur) REFERENCES pecheur (id_pecheur),
        FOREIGN KEY (id_technique) REFERENCES technique_peche (id_technique)
      )
    ''');

    // Table Lieu de Pêche
    await db.execute('''
      CREATE TABLE lieu_peche (
        id_lieu INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        description TEXT,
        type_eau TEXT CHECK (type_eau IN ('mer', 'riviere', 'lac', 'etang')),
        profondeur REAL,
        acces TEXT,
        restrictions TEXT,
        proprietaire TEXT
      )
    ''');

    // Table Conditions Météorologiques
    await db.execute('''
      CREATE TABLE condition_meteo (
        id_meteo INTEGER PRIMARY KEY AUTOINCREMENT,
        date_releve DATETIME,
        temperature REAL,
        humidite REAL,
        vitesse_vent REAL,
        direction_vent TEXT,
        pression_atmospherique REAL,
        precipitation TEXT,
        visibilite TEXT,
        etat_general TEXT
      )
    ''');

    // Table Capture/Produit de Pêche
    await db.execute('''
      CREATE TABLE capture (
        id_capture INTEGER PRIMARY KEY AUTOINCREMENT,
        id_pecheur INTEGER,
        id_lieu INTEGER,
        id_meteo INTEGER,
        id_technique INTEGER,
        nom_produit TEXT NOT NULL,
        quantite REAL,
        poids REAL,
        taille REAL,
        date_capture DATETIME DEFAULT CURRENT_TIMESTAMP,
        heure_capture TEXT,
        etat_produit TEXT,
        destination TEXT CHECK (destination IN ('consommation', 'vente', 'recherche', 'autres')),
        observations TEXT,
        FOREIGN KEY (id_pecheur) REFERENCES pecheur (id_pecheur),
        FOREIGN KEY (id_lieu) REFERENCES lieu_peche (id_lieu),
        FOREIGN KEY (id_meteo) REFERENCES condition_meteo (id_meteo),
        FOREIGN KEY (id_technique) REFERENCES technique_peche (id_technique)
      )
    ''');

    await _insertDefaultAdmin(db);
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);

    var digest = sha256.convert(bytes);

    return digest.toString();
  }

  Future<void> _insertDefaultAdmin(Database db) async {
    String hashedPassword = _hashPassword('admin123');
    await db.insert('utilisateur', {
      'nom_utilisateur': 'admin',
      'email': 'admin@peche.com',
      'mot_de_passe': hashedPassword,
      'role': 'admin',
      'est_actif': 1,
    });
  }

  // Méthodes CRUD génériques (en français)
  Future<int> inserer(String table, Map<String, dynamic> donnees) async {
    final db = await baseDeDonnees;
    return await db.insert(table, donnees, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> consulter(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await baseDeDonnees;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> modifier(String table, Map<String, dynamic> donnees, String clauseWhere, List<dynamic> arguments) async {
    final db = await baseDeDonnees;
    return await db.update(table, donnees, where: clauseWhere, whereArgs: arguments);
  }

  Future<int> supprimer(String table, String clauseWhere, List<dynamic> arguments) async {
    final db = await baseDeDonnees;
    return await db.delete(table, where: clauseWhere, whereArgs: arguments);
  }

  // Méthode de fermeture de la base de données
  Future<void> fermerBaseDeDonnees() async {
    final db = await baseDeDonnees;
    await db.close();
  }
}
