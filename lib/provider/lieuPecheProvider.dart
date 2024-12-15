import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';
import '../models/lieupeche.dart';

class LieuPecheProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<LieuPeche> _lieux = [];

  List<LieuPeche> get lieux => _lieux;

  Future<void> fetchLieux({String? where, List<dynamic>? whereArgs}) async {
    _lieux = await _databaseHelper.obtenirLieuxPeche(where: where, whereArgs: whereArgs);
    notifyListeners();
  }

  Future<void> ajouterLieu(LieuPeche lieu) async {
    await _databaseHelper.ajouterLieuPeche(lieu);
    await fetchLieux();
  }

  Future<void> modifierLieu(LieuPeche lieu) async {
    await _databaseHelper.modifierLieuPeche(lieu);
    await fetchLieux();
  }

  Future<void> supprimerLieu(int idLieu) async {
    await _databaseHelper.supprimerLieuPeche(idLieu);
    await fetchLieux();
  }
}