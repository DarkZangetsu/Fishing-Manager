import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';
import '../models/capture.dart';

class CaptureProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Capture> _captures = [];

  List<Capture> get captures => _captures;

  Future<void> fetchCaptures({String? where, List<dynamic>? whereArgs}) async {
    _captures = await _databaseHelper.obtenirCaptures(where: where, whereArgs: whereArgs);
    notifyListeners();
  }

  Future<void> ajouterCapture(Capture capture) async {
    await _databaseHelper.ajouterCapture(capture);
    await fetchCaptures();
  }

  Future<void> modifierCapture(Capture capture) async {
    await _databaseHelper.modifierCapture(capture);
    await fetchCaptures();
  }

  Future<void> supprimerCapture(int idCapture) async {
    await _databaseHelper.supprimerCapture(idCapture);
    await fetchCaptures();
  }
}
