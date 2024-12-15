import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';
import '../models/techniquepeche.dart';

class TechniquePecheProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<TechniquePeche> _techniques = [];

  List<TechniquePeche> get techniques => _techniques;

  Future<void> fetchTechniques({String? where, List<dynamic>? whereArgs}) async {
    _techniques = await _databaseHelper.obtenirTechniquesPeche(where: where, whereArgs: whereArgs);
    notifyListeners();
  }

  Future<void> ajouterTechnique(TechniquePeche technique) async {
    await _databaseHelper.ajouterTechniquePeche(technique);
    await fetchTechniques();
  }

  Future<void> modifierTechnique(TechniquePeche technique) async {
    await _databaseHelper.modifierTechniquePeche(technique);
    await fetchTechniques();
  }

  Future<void> supprimerTechnique(int idTechnique) async {
    await _databaseHelper.supprimerTechniquePeche(idTechnique);
    await fetchTechniques();
  }
}
