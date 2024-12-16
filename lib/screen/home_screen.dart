import 'package:flutter/material.dart';
import 'package:peche/screen/view/catch_management_view.dart';
import 'package:peche/screen/view/categorie_pecheur_view.dart';
import 'package:peche/screen/view/condition_meteo_view.dart';
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
  int? _expandedGroupIndex;

  // Grouped menu items
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
              route: 6
          ),
          MenuItem(
              icon: Icons.phishing_outlined,
              label: 'Techniques de Pêche',
              route: 8
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
              route: 7
          ),
          MenuItem(
              icon: Icons.wb_sunny_outlined,
              label: 'Conditions Météo',
              route: 9
          ),
        ]
    ),
    MenuGroup(
        groupName: 'Rapports',
        groupIcon: Icons.bar_chart_outlined,
        items: [
          MenuItem(
              icon: Icons.bar_chart_outlined,
              label: 'Statistiques',
              route: 4
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
              route: 5
          ),
        ]
    ),
  ];

  // Screens corresponding to routes
  final List<Widget> _screens = [
    DashboardView(),
    FishermanManagementView(),
    TechniquePecheManagementView(),
    CaptureManagementView(),
    StatisticsView(),
    UserManagementView(),
    CategoriePecheurView(),
    LieuPecheManagementView(),
    FishermanTechniqueView(),
    WeatherConditionManagementView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop();
  }

  void _logout() {
    // Logout implementation
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
        title: const Text(
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

              // Grouped Menu Items
              ...List.generate(_menuGroups.length, (index) =>
                  _buildMenuGroup(_menuGroups[index], index)),

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
}

// Helper classes for menu organization
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