import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';
import '../models/categoriepecheur.dart';

class CategoriePecheurProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<CategoriePecheur> _categories = [];

  List<CategoriePecheur> get categories => _categories;

  Future<void> fetchCategories({String? where, List<dynamic>? whereArgs}) async {
    _categories = await _databaseHelper.obtenirCategoriesPecheurs(where: where, whereArgs: whereArgs);
    notifyListeners();
  }

  Future<void> ajouterCategorie(CategoriePecheur categorie) async {
    await _databaseHelper.ajouterCategoriePecheur(categorie);
    await fetchCategories();
  }

  Future<void> modifierCategorie(CategoriePecheur categorie) async {
    await _databaseHelper.modifierCategoriePecheur(categorie);
    await fetchCategories();
  }

  Future<bool> supprimerCategorie(int idCategorie) async {
    try {
      await _databaseHelper.supprimerCategoriePecheur(idCategorie);
      await fetchCategories();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de la catégorie: $e');
      return false;
    }
  }
}