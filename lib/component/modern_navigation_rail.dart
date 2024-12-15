import 'package:flutter/material.dart';

class ModernNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onDestinationSelected;

  const ModernNavigationRail({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.selected,
      backgroundColor: Colors.blue[900],
      unselectedIconTheme: IconThemeData(color: Colors.white70),
      selectedIconTheme: IconThemeData(color: Colors.white),
      destinations: [
        _buildNavigationRailDestination(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard,
          label: 'Tableau de Bord',
        ),
        _buildNavigationRailDestination(
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: 'Gestion Pêcheurs',
        ),
        _buildNavigationRailDestination(
          icon: Icons.fitness_center_outlined,
          selectedIcon: Icons.fitness_center,
          label: 'Techniques Pêche',
        ),
        _buildNavigationRailDestination(
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
          label: 'Produits Pêchés',
        ),
        _buildNavigationRailDestination(
          icon: Icons.analytics_outlined,
          selectedIcon: Icons.analytics,
          label: 'Reporting',
        ),
      ],
    );
  }

  NavigationRailDestination _buildNavigationRailDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}