import 'package:flutter/foundation.dart';
import '../db/databasehelper.dart';
import '../models/Utilisateur.dart';

class UtilisateurProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Utilisateur? _utilisateurActuel;
  List<Utilisateur> _utilisateurs = [];

  // Getter pour l'utilisateur actuel
  Utilisateur? get utilisateurActuel => _utilisateurActuel;

  // Getter pour la liste des utilisateurs
  List<Utilisateur> get utilisateurs => [..._utilisateurs];

  // Méthode d'authentification
  Future<bool> authentifier(String email, String motDePasse) async {
    try {
      _utilisateurActuel = await _databaseHelper.authentifier(email, motDePasse);
      notifyListeners();
      return _utilisateurActuel != null;
    } catch (e) {
      print('Erreur d\'authentification : $e');
      return false;
    }
  }

  // Méthode de déconnexion
  void deconnecter() {
    _utilisateurActuel = null;
    notifyListeners();
  }

  // Ajouter un nouvel utilisateur
  Future<bool> ajouterUtilisateur(Utilisateur utilisateur) async {
    try {
      // Vérifier si l'email existe déjà
      bool emailExisteDeja = await _databaseHelper.emailExiste(utilisateur.email);
      if (emailExisteDeja) {
        return false;
      }

      int resultat = await _databaseHelper.ajouterUtilisateur(utilisateur);
      if (resultat > 0) {
        // Recharger la liste des utilisateurs
        await chargerUtilisateurs();
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de l\'ajout d\'utilisateur : $e');
      return false;
    }
  }

  // Modifier un utilisateur
  Future<bool> modifierUtilisateur(Utilisateur utilisateur) async {
    try {
      int resultat = await _databaseHelper.modifierUtilisateur(utilisateur);

      // Mettre à jour l'utilisateur actuel si c'est le même
      if (_utilisateurActuel?.idUtilisateur == utilisateur.idUtilisateur) {
        _utilisateurActuel = utilisateur;
      }

      // Recharger la liste des utilisateurs
      await chargerUtilisateurs();

      return resultat > 0;
    } catch (e) {
      print('Erreur lors de la modification d\'utilisateur : $e');
      return false;
    }
  }

  // Supprimer un utilisateur
  Future<bool> supprimerUtilisateur(int idUtilisateur) async {
    try {
      int resultat = await _databaseHelper.supprimerUtilisateur(idUtilisateur);

      // Si l'utilisateur supprimé est l'utilisateur actuel, le déconnecter
      if (_utilisateurActuel?.idUtilisateur == idUtilisateur) {
        deconnecter();
      }

      // Recharger la liste des utilisateurs
      await chargerUtilisateurs();

      return resultat > 0;
    } catch (e) {
      print('Erreur lors de la suppression d\'utilisateur : $e');
      return false;
    }
  }

  // Réinitialiser le mot de passe
  Future<bool> reinitialiserMotDePasse(int idUtilisateur, String nouveauMotDePasse) async {
    try {
      int resultat = await _databaseHelper.reinitialiserMotDePasse(idUtilisateur, nouveauMotDePasse);
      return resultat > 0;
    } catch (e) {
      print('Erreur lors de la réinitialisation du mot de passe : $e');
      return false;
    }
  }

  // Charger tous les utilisateurs
  Future<void> chargerUtilisateurs() async {
    try {
      _utilisateurs = await _databaseHelper.obtenirUtilisateurs();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des utilisateurs : $e');
      _utilisateurs = [];
    }
  }

  // Vérifier si un email existe
  Future<bool> verifierEmailExiste(String email) async {
    try {
      return await _databaseHelper.emailExiste(email);
    } catch (e) {
      print('Erreur lors de la vérification de l\'email : $e');
      return false;
    }
  }
}