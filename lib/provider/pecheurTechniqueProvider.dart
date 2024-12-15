import 'package:flutter/cupertino.dart';

import '../db/databasehelper.dart';

class PecheurTechniqueProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

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