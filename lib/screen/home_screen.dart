import 'package:flutter/material.dart';
import 'package:peche/screen/view/catch_management_view.dart';
import 'package:peche/screen/view/categorie_pecheur_view.dart';
import 'package:peche/screen/view/ficherman_technique_view.dart';
import 'package:peche/screen/view/lieu_peche_management_view.dart';
import 'package:peche/screen/view/statistics_view.dart';
import 'package:peche/screen/view/user_management_view.dart';
import '../utils/app_colors.dart';
import 'view/dashboard_view.dart';
import 'view/ficherman_management_view.dart';
import 'view/technique_peche_management_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  // Screens corresponding to sidebar options
  final List<Widget> _screens = [
    DashboardView(),
    FishermanManagementView(),
    TechniquePecheManagementView(),
    CatchManagementView(),
    StatisticsView(),
    UserManagementView(),
    CategoriePecheurView(),
    LieuPecheManagementView(),
    FishermanTechniqueView(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'icon': Icons.dashboard_outlined,
      'label': 'Tableau de Bord',
      'route': 0
    },
    {
      'icon': Icons.people_outline,
      'label': 'Gestion des Pêcheurs',
      'route': 1
    },
    {
      'icon': Icons.analytics_outlined,
      'label': 'Techniques de Pêche',
      'route': 2
    },
    {
      'icon': Icons.catching_pokemon_outlined,
      'label': 'Gestion des Captures',
      'route': 3
    },
    {
      'icon': Icons.bar_chart_outlined,
      'label': 'Statistiques',
      'route': 4
    },
    {
      'icon': Icons.verified_user,
      'label': 'Utilisateurs',
      'route': 5
    },
    {
      'icon': Icons.category_sharp,
      'label': 'Categorie',
      'route': 6
    },
    {
      'icon': Icons.water_outlined,
      'label': 'Lieux de Pêche',
      'route': 7
    },
    {
      'icon': Icons.phishing_outlined,
      'label': 'Techniques de Pêche',
      'route': 8
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  void _logout() {
    /*final utilisateurProvider = Provider.of<UtilisateurProvider>(context, listen: false);
    utilisateurProvider.logout();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title:const Text(
          'Fishing Manager',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      drawer: Drawer(
        child: Container(
          color: AppColors.primary.withOpacity(0.95),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer Header
              DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.8),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sailing,
                      size: 60,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Fishing Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              ...(_menuItems.map((item) => ListTile(
                leading: Icon(
                  item['icon'],
                  color: _selectedIndex == item['route']
                      ? Colors.white
                      : Colors.white70,
                ),
                title: Text(
                  item['label'],
                  style: TextStyle(
                    color: _selectedIndex == item['route']
                        ? Colors.white
                        : Colors.white70,
                    fontWeight: _selectedIndex == item['route']
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == item['route'],
                selectedTileColor: Colors.white.withOpacity(0.2),
                onTap: () => _onItemTapped(item['route']),
              ))),

              // Logout
              Divider(color: Colors.white30),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.white70),
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
      body: _screens[_selectedIndex],
    );
  }
}