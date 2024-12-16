import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';

class StatistiquesProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Données de statistiques globales
  Map<String, dynamic> _statistiquesGlobales = {};
  Map<String, dynamic> get statistiquesGlobales => _statistiquesGlobales;

  // Captures par destination
  List<Map<String, dynamic>> _capturesParDestination = [];
  List<Map<String, dynamic>> get capturesParDestination => _capturesParDestination;

  // Captures par lieu
  List<Map<String, dynamic>> _capturesParLieu = [];
  List<Map<String, dynamic>> get capturesParLieu => _capturesParLieu;

  // Captures par technique
  List<Map<String, dynamic>> _capturesParTechnique = [];
  List<Map<String, dynamic>> get capturesParTechnique => _capturesParTechnique;

  // Statistiques des pêcheurs
  Map<String, dynamic> _statistiquesPecheurs = {};
  Map<String, dynamic> get statistiquesPecheurs => _statistiquesPecheurs;

  // Évolution des captures
  List<Map<String, dynamic>> _evolutionCaptures = [];
  List<Map<String, dynamic>> get evolutionCaptures => _evolutionCaptures;

  // Répartition des pêcheurs par catégorie
  List<Map<String, dynamic>> _repartitionPecheurs = [];
  List<Map<String, dynamic>> get repartitionPecheurs => _repartitionPecheurs;

  // Conditions météorologiques
  List<Map<String, dynamic>> _conditionsMeteo = [];
  List<Map<String, dynamic>> get conditionsMeteo => _conditionsMeteo;

  // Indicateur de chargement
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Méthode pour charger toutes les statistiques
  Future<void> chargerToutesStatistiques() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Charger toutes les statistiques en parallèle
      await Future.wait([
        _chargerStatistiquesGlobales(),
        _chargerCapturesParDestination(),
        _chargerCapturesParLieu(),
        _chargerCapturesParTechnique(),
        _chargerStatistiquesPecheurs(),
        _chargerEvolutionCaptures(),
        _chargerRepartitionPecheurs(),
        _chargerConditionsMeteo()
      ]);
    } catch (e) {
      print('Erreur lors du chargement des statistiques: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthodes privées de chargement des différentes statistiques
  Future<void> _chargerStatistiquesGlobales() async {
    _statistiquesGlobales = await _databaseHelper.obtenirStatistiquesCapturesGlobales();
  }

  Future<void> _chargerCapturesParDestination() async {
    _capturesParDestination = await _databaseHelper.obtenirStatistiquesCapturesParDestination();
  }

  Future<void> _chargerCapturesParLieu() async {
    _capturesParLieu = await _databaseHelper.obtenirStatistiquesCapturesParLieu();
  }

  Future<void> _chargerCapturesParTechnique() async {
    _capturesParTechnique = await _databaseHelper.obtenirStatistiquesCapturesParTechnique();
  }

  Future<void> _chargerStatistiquesPecheurs() async {
    _statistiquesPecheurs = await _databaseHelper.obtenirStatistiquesPecheurs();
  }

  Future<void> _chargerEvolutionCaptures() async {
    _evolutionCaptures = await _databaseHelper.obtenirEvolutionCapturesParMois();
  }

  Future<void> _chargerRepartitionPecheurs() async {
    _repartitionPecheurs = await _databaseHelper.obtenirRepartitionPecheursParCategorie();
  }

  Future<void> _chargerConditionsMeteo() async {
    _conditionsMeteo = await _databaseHelper.obtenirStatistiquesConditionsMeteo();
  }


  // Calcul du pourcentage de captures par destination
  List<Map<String, dynamic>> calculPourcentageCapturesParDestination() {
    if (_capturesParDestination.isEmpty) return [];

    final nombreTotalCaptures = _capturesParDestination.fold(
        0,
            (sum, item) => sum + (item['nombre_captures'] as int)
    );

    return _capturesParDestination.map((item) {
      final nombreCaptures = item['nombre_captures'] as int;
      return {
        ...item,
        'pourcentage': (nombreCaptures / nombreTotalCaptures * 100).toStringAsFixed(2)
      };
    }).toList();
  }

  // Top 5 des lieux de pêche les plus productifs
  List<Map<String, dynamic>> topLieuxPeche() {
    final lieuxTries = [..._capturesParLieu]
      ..sort((a, b) => (b['nombre_captures'] as int).compareTo(a['nombre_captures'] as int));

    return lieuxTries.take(5).toList();
  }

  // Calcul de la progression des captures
  double calculProgressionCaptures() {
    if (_evolutionCaptures.length < 2) return 0.0;

    final dernierMois = _evolutionCaptures.last;
    final avantDernierMois = _evolutionCaptures[_evolutionCaptures.length - 2];

    final nombreCapturesDernierMois = dernierMois['nombre_captures'] as int;
    final nombreCapturesAvantDernierMois = avantDernierMois['nombre_captures'] as int;

    return ((nombreCapturesDernierMois - nombreCapturesAvantDernierMois) /
        nombreCapturesAvantDernierMois * 100);
  }

  Future<void> chargerCapturesParDestination() async {
    _isLoading = true;
    notifyListeners();
    try {
      _capturesParDestination = await _databaseHelper.obtenirStatistiquesCapturesParDestination();
    } catch (e) {
      print('Erreur lors du chargement des captures par destination: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> chargerCapturesParLieu() async {
    _isLoading = true;
    notifyListeners();
    try {
      _capturesParLieu = await _databaseHelper.obtenirStatistiquesCapturesParLieu();
    } catch (e) {
      print('Erreur lors du chargement des captures par lieu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> chargerCapturesParTechnique() async {
    _isLoading = true;
    notifyListeners();
    try {
      _capturesParTechnique = await _databaseHelper.obtenirStatistiquesCapturesParTechnique();
    } catch (e) {
      print('Erreur lors du chargement des captures par technique: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> chargerStatistiquesPecheurs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _statistiquesPecheurs = await _databaseHelper.obtenirStatistiquesPecheurs();
    } catch (e) {
      print('Erreur lors du chargement des statistiques des pêcheurs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
