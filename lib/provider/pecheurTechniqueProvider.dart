import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';
import '../models/pecheurtechnique.dart';

class PecheurTechniqueProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<PecheurTechnique> _pecheurTechnique = [];

  List<PecheurTechnique> get pecheurTechnique => _pecheurTechnique;

  Future<void> fetchPecheurTechniques({String? where, List<dynamic>? whereArgs}) async {
    _pecheurTechnique = await _databaseHelper.obtenirPecheurTechnique(where: where, whereArgs: whereArgs);
    notifyListeners();
  }

  Future<void> ajouterPecheurTechnique(int idPecheur, int idTechnique, {DateTime? dateApprentissage, String? niveauMaitrise}) async {
    await _databaseHelper.ajouterPecheurTechnique(idPecheur, idTechnique,
        dateApprentissage: dateApprentissage,
        niveauMaitrise: niveauMaitrise
    );
  }

  Future<void> supprimerPecheurTechnique(int idPecheur, int idTechnique) async {
    await _databaseHelper.supprimerPecheurTechnique(idPecheur, idTechnique);
  }
}