import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';
import '../models/pecheur.dart';

class PecheurProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Pecheur> _pecheurs = [];

  List<Pecheur> get pecheurs => _pecheurs;

  Future<void> fetchPecheurs({String? where, List<dynamic>? whereArgs}) async {
    _pecheurs = await _databaseHelper.obtenirPecheurs(where: where, whereArgs: whereArgs);
    notifyListeners();
  }

  Future<void> ajouterPecheur(Pecheur pecheur) async {
    await _databaseHelper.ajouterPecheur(pecheur);
    await fetchPecheurs();
  }

  Future<void> modifierPecheur(Pecheur pecheur) async {
    await _databaseHelper.modifierPecheur(pecheur);
    await fetchPecheurs();
  }

  Future<void> supprimerPecheur(int idPecheur) async {
    await _databaseHelper.supprimerPecheur(idPecheur);
    await fetchPecheurs();
  }
}