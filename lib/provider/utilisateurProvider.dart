import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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


  // Nouveau getter pour utilisateurConnecte (identique à utilisateurActuel)
  Utilisateur? get utilisateurConnecte => _utilisateurActuel;

  // Méthode d'authentification
  Future<bool> authentifier(String email, String motDePasse) async {
    try {
      // Vérifier si les champs sont vides
      if (email.isEmpty || motDePasse.isEmpty) {
        print('Email ou mot de passe vide');
        return false;
      }

      // Récupérer l'utilisateur depuis la base de données
      Utilisateur? utilisateur = await _databaseHelper.authentifier(email, motDePasse);

      if (utilisateur != null) {
        // Vérifier le statut de l'utilisateur
        if (!utilisateur.estActif) {
          print('Compte utilisateur désactivé');
          return false;
        }

        // Stocker l'utilisateur connecté
        _utilisateurActuel = utilisateur;

        // Enregistrer la session
        await _sauvegarderSession(utilisateur);

        // Notifier les écouteurs du changement d'état
        notifyListeners();

        return true;
      }

      return false;
    } catch (e) {
      print('Erreur lors de l\'authentification : $e');
      return false;
    }
  }

  Future<void> _sauvegarderSession(Utilisateur utilisateur) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Sauvegarder les informations essentielles de l'utilisateur
      await prefs.setInt('utilisateur_id', utilisateur.idUtilisateur!);
      await prefs.setString('utilisateur_email', utilisateur.email);
      await prefs.setString('utilisateur_role', utilisateur.role.toString());
    } catch (e) {
      print('Erreur lors de la sauvegarde de la session : $e');
    }
  }

  // Méthode pour restaurer la session
  Future<void> restaurerSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final utilisateurId = prefs.getInt('utilisateur_id');

      if (utilisateurId != null) {
        // Récupérer l'utilisateur depuis la base de données
        Utilisateur? utilisateur = await _databaseHelper.obtenirUtilisateurParId(utilisateurId);

        if (utilisateur != null) {
          _utilisateurActuel = utilisateur;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Erreur lors de la restauration de la session : $e');
    }
  }

// Méthode de déconnexion
  void deconnecter() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Supprimer les informations de session
      await prefs.remove('utilisateur_id');
      await prefs.remove('utilisateur_email');
      await prefs.remove('utilisateur_role');

      // Réinitialiser l'utilisateur actuel
      _utilisateurActuel = null;

      // Notifier les écouteurs
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
    }
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