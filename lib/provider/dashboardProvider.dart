import 'package:flutter/cupertino.dart';

class DashboardProvider with ChangeNotifier {
  // États du dashboard
  int _selectedDashboardIndex = 0;
  int get selectedDashboardIndex => _selectedDashboardIndex;

  // Liste des widgets ou vues de dashboard
  final List<String> _dashboardWidgets = [
    'Statistiques Globales',
    'Captures par Destination',
    'Lieux de Pêche',
    'Techniques de Pêche',
    'Profil des Pêcheurs'
  ];
  List<String> get dashboardWidgets => _dashboardWidgets;

  // Méthode pour changer l'index du dashboard
  void changerDashboard(int nouvelIndex) {
    if (nouvelIndex >= 0 && nouvelIndex < _dashboardWidgets.length) {
      _selectedDashboardIndex = nouvelIndex;
      notifyListeners();
    }
  }

  // Filtres et préférences de visualisation
  bool _afficherValeursEnPourcentage = false;
  bool get afficherValeursEnPourcentage => _afficherValeursEnPourcentage;

  void toggleAffichageValeursEnPourcentage() {
    _afficherValeursEnPourcentage = !_afficherValeursEnPourcentage;
    notifyListeners();
  }

  // Période de visualisation
  DateTime? _debutPeriode;
  DateTime? _finPeriode;

  void definirPeriode(DateTime debut, DateTime fin) {
    _debutPeriode = debut;
    _finPeriode = fin;
    notifyListeners();
  }

  void reinitialiserPeriode() {
    _debutPeriode = null;
    _finPeriode = null;
    notifyListeners();
  }
}