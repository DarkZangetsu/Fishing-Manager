import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';
import '../models/conditionmeteo.dart';

class ConditionMeteoProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<ConditionMeteo> _conditions = [];

  List<ConditionMeteo> get conditions => _conditions;

  Future<void> fetchConditions({String? where, List<dynamic>? whereArgs}) async {
    _conditions = await _databaseHelper.obtenirConditionsMeteo(where: where, whereArgs: whereArgs);
    notifyListeners();
  }

  Future<void> ajouterCondition(ConditionMeteo condition) async {
    await _databaseHelper.ajouterConditionMeteo(condition);
    await fetchConditions();
  }

  Future<void> modifierCondition(ConditionMeteo condition) async {
    await _databaseHelper.modifierConditionMeteo(condition);
    await fetchConditions();
  }

  Future<void> supprimerCondition(int idMeteo) async {
    await _databaseHelper.supprimerConditionMeteo(idMeteo);
    await fetchConditions();
  }
}