import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peche/provider/utilisateurProvider.dart';

import 'package:peche/screen/userview/user_catch_management_view.dart';
import 'package:peche/screen/userview/user_condition_meteo_view.dart';
import 'package:peche/screen/userview/user_ficherman_management_view.dart';
import 'package:peche/screen/userview/user_ficherman_technique_view.dart';
import 'package:peche/screen/userview/user_lieu_peche_management_view.dart';
import 'package:peche/screen/userview/user_technique_peche_management_view.dart';

import 'package:peche/screen/view/catch_management_view.dart';
import 'package:peche/screen/view/categorie_pecheur_view.dart';
import 'package:peche/screen/view/condition_meteo_view.dart';
import 'package:peche/screen/view/ficherman_technique_view.dart';
import 'package:peche/screen/view/lieu_peche_management_view.dart';
import 'package:peche/screen/view/user_management_view.dart';
import 'package:peche/screen/view/dashboard_view.dart';
import 'package:peche/screen/view/ficherman_management_view.dart';
import 'package:peche/screen/view/technique_peche_management_view.dart';

import '../models/Utilisateur.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  int? _expandedGroupIndex;

  // Tous les groupes de menu possibles
  final List<MenuGroup> _menuGroups = [
    MenuGroup(
        groupName: 'Tableau de Bord',
        groupIcon: Icons.dashboard_outlined,
        items: [
          MenuItem(
              icon: Icons.dashboard_outlined,
              label: 'Tableau de Bord',
              route: 0
          ),
        ]
    ),
    MenuGroup(
        groupName: 'Gestion des Pêcheurs',
        groupIcon: Icons.people_outline,
        items: [
          MenuItem(
              icon: Icons.people_outline,
              label: 'Gestion des Pêcheurs',
              route: 1
          ),
          MenuItem(
              icon: Icons.category_sharp,
              label: 'Categorie de Pêcheurs',
              route: 5
          ),
          MenuItem(
              icon: Icons.phishing_outlined,
              label: 'Techniques de Pêche',
              route: 7
          ),
        ]
    ),
    MenuGroup(
        groupName: 'Captures et Techniques',
        groupIcon: Icons.catching_pokemon_outlined,
        items: [
          MenuItem(
              icon: Icons.catching_pokemon_outlined,
              label: 'Gestion des Captures',
              route: 3
          ),
          MenuItem(
              icon: Icons.analytics_outlined,
              label: 'Techniques de Pêche',
              route: 2
          ),
        ]
    ),
    MenuGroup(
        groupName: 'Environnement',
        groupIcon: Icons.water_outlined,
        items: [
          MenuItem(
              icon: Icons.water_outlined,
              label: 'Lieux de Pêche',
              route: 6
          ),
          MenuItem(
              icon: Icons.wb_sunny_outlined,
              label: 'Conditions Météo',
              route: 8
          ),
        ]
    ),
    MenuGroup(
        groupName: 'Administration',
        groupIcon: Icons.admin_panel_settings,
        items: [
          MenuItem(
              icon: Icons.verified_user,
              label: 'Utilisateurs',
              route: 4
          ),
        ]
    ),
  ];

  // Tous les écrans possibles
  final List<Widget> _screens = [
    DashboardView(),
    FishermanManagementView(),
    TechniquePecheManagementView(),
    CaptureManagementView(),
    UserManagementView(),
    CategoriePecheurView(),
    LieuPecheManagementView(),
    FishermanTechniqueView(),
    WeatherConditionManagementView(),

    UserFishermanManagementView(),
    UserFishermanTechniqueView(),
    UserCaptureManagementView(),
    UserWeatherConditionManagementView(),
    UserLieuPecheManagementView(),
    UserTechniquePecheManagementView()
  ];

  late List<MenuGroup> _filteredMenuGroups;
  late List<Widget> _filteredScreens;

  @override
  void initState() {
    super.initState();
    final utilisateurProvider = Provider.of<UtilisateurProvider>(context, listen: false);
    final currentUser = utilisateurProvider.utilisateurConnecte;

    _filterMenuAndScreens(currentUser);
  }

  void _filterMenuAndScreens(Utilisateur? currentUser) {
    if (currentUser == null) return;

    switch (currentUser.role) {
      case UserRole.admin:
        _filteredMenuGroups = _menuGroups;
        _filteredScreens = _screens;
        _selectedIndex = 0; // Tableau de bord par défaut pour l'admin
        break;
      case UserRole.utilisateur:
      // Filtrer pour les vues spécifiques des utilisateurs
        _filteredMenuGroups = [
          MenuGroup(
              groupName: 'Gestion des Pêcheurs',
              groupIcon: Icons.people_outline,
              items: [
                MenuItem(
                    icon: Icons.people_outline,
                    label: 'Gestion des Pêcheurs',
                    route: 0
                ),
              ]
          ),
          MenuGroup(
              groupName: 'Captures et Techniques',
              groupIcon: Icons.catching_pokemon_outlined,
              items: [
                MenuItem(
                    icon: Icons.catching_pokemon_outlined,
                    label: 'Gestion des Captures',
                    route: 1
                ),
                MenuItem(
                    icon: Icons.analytics_outlined,
                    label: 'Techniques de Pêche',
                    route: 2
                ),
              ]
          ),
          MenuGroup(
              groupName: 'Environnement',
              groupIcon: Icons.water_outlined,
              items: [
                MenuItem(
                    icon: Icons.water_outlined,
                    label: 'Lieux de Pêche',
                    route: 3
                ),
                MenuItem(
                    icon: Icons.wb_sunny_outlined,
                    label: 'Conditions Météo',
                    route: 4
                ),
              ]
          ),
        ];

        _filteredScreens = [
          UserFishermanManagementView(),
          UserCaptureManagementView(),
          UserFishermanTechniqueView(),
          UserLieuPecheManagementView(),
          UserWeatherConditionManagementView()
        ];

        // Sélectionner automatiquement la première vue utilisateur
        _selectedIndex = 0;
        break;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logout Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 60,
                    color: Colors.red.shade300,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  'Déconnexion',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Message
                Text(
                  'Êtes-vous sûr de vouloir vous déconnecter ?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          // Fermer le dialogue
                          Navigator.of(context).pop();

                          // Logique de déconnexion
                          final utilisateurProvider =
                          Provider.of<UtilisateurProvider>(context, listen: false);
                          utilisateurProvider.deconnecter();

                          // Naviguer vers l'écran de connexion
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Se Déconnecter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _getUserAppBarTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 1,
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.primary.withOpacity(0.95),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // En-tête du tiroir
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.sailing,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _getUserAppBarTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Éléments de menu groupés
              ...List.generate(_filteredMenuGroups.length, (index) =>
                  _buildMenuGroup(_filteredMenuGroups[index], index)),

              // Déconnexion
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white70),
                title: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: _filteredScreens[_selectedIndex],
    );
  }

  Widget _buildMenuGroup(MenuGroup group, int groupIndex) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.white.withOpacity(0.2),
        ),
      ),
      child: ExpansionTile(
        key: Key('group_$groupIndex'),
        leading: Icon(group.groupIcon, color: Colors.white70),
        title: Text(
          group.groupName,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Icon(
          _expandedGroupIndex == groupIndex
              ? Icons.keyboard_arrow_up
              : Icons.keyboard_arrow_down,
          color: Colors.white70,
        ),
        onExpansionChanged: (isExpanded) {
          setState(() {
            _expandedGroupIndex = isExpanded ? groupIndex : null;
          });
        },
        children: group.items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
            dense: true,
            leading: Icon(
              item.icon,
              color: _selectedIndex == item.route
                  ? Colors.white
                  : Colors.white70,
              size: 20,
            ),
            title: Text(
              item.label,
              style: TextStyle(
                color: _selectedIndex == item.route
                    ? Colors.white
                    : Colors.white70,
                fontWeight: _selectedIndex == item.route
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            selected: _selectedIndex == item.route,
            selectedTileColor: Colors.white.withOpacity(0.2),
            onTap: () => _onItemTapped(item.route),
            hoverColor: Colors.white.withOpacity(0.1),
          ),
        )).toList(),
      ),
    );
  }

  // Nouvelle méthode pour obtenir le titre approprié de la barre d'application
  String _getUserAppBarTitle() {
    final utilisateurProvider = Provider.of<UtilisateurProvider>(context, listen: false);
    final currentUser = utilisateurProvider.utilisateurConnecte;

    return currentUser?.role == UserRole.admin
        ? 'Fishing Manager'
        : 'Espace Utilisateur';
  }
}

// Classes d'assistance pour l'organisation des menus
class MenuGroup {
  final String groupName;
  final IconData groupIcon;
  final List<MenuItem> items;

  MenuGroup({
    required this.groupName,
    required this.groupIcon,
    required this.items,
  });
}

class MenuItem {
  final IconData icon;
  final String label;
  final int route;

  MenuItem({
    required this.icon,
    required this.label,
    required this.route
  });
}