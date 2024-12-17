import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../provider/dashboardProvider.dart';
import '../../provider/statistiqueProvider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatistiquesProvider>(context, listen: false)
          .chargerToutesStatistiques();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Tableau de Bord'),
        titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<StatistiquesProvider>(context, listen: false)
                  .chargerToutesStatistiques();
            },
          ),
        ],
      ),
      body: Consumer2<StatistiquesProvider, DashboardProvider>(
        builder: (context, statistiquesProvider, dashboardProvider, child) {
          if (statistiquesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDashboardTabs(dashboardProvider),
                  const SizedBox(height: 16),
                  _buildStatistiquesCards(statistiquesProvider),
                  const SizedBox(height: 16),
                  _buildChartsSection(statistiquesProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardTabs(DashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          dashboardProvider.dashboardWidgets.length,
              (index) {
            final isSelected =
                index == dashboardProvider.selectedDashboardIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(
                  dashboardProvider.dashboardWidgets[index],
                  overflow: TextOverflow.ellipsis,
                ),
                selected: isSelected,
                selectedColor: Colors.blue,
                onSelected: (_) {
                  dashboardProvider.changerDashboard(index);
                },
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatistiquesCards(StatistiquesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatistiqueCard(
          title: 'Total Captures',
          value: provider.statistiquesGlobales['nombre_total_captures']
              ?.toString() ??
              '0',
          icon: Icons.catching_pokemon,
          color: Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildStatistiqueCard(
          title: 'Quantité Totale',
          value:
          '${provider.statistiquesGlobales['quantite_totale']?.toStringAsFixed(2) ?? '0'} kg',
          icon: Icons.scale,
          color: Colors.green,
        ),
        const SizedBox(height: 16),
        _buildStatistiqueCard(
          title: 'Pêcheurs Actifs',
          value: provider.statistiquesPecheurs['pecheurs_actifs']
              ?.toString() ??
              '0',
          icon: Icons.people,
          color: Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildStatistiqueCard(
          title: 'Techniques Utilisées',
          value: provider.capturesParTechnique.length.toString(),
          icon: Icons.hardware,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatistiqueCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(StatistiquesProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Répartition des Captures',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildPieChart(provider),
        const SizedBox(height: 16),
        const Text(
          'Top 5 Lieux de Pêche',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildBarChart(provider),
      ],
    );
  }

  Widget _buildPieChart(StatistiquesProvider provider) {
    final capturesParDestination =
    provider.calculPourcentageCapturesParDestination();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCircularChart(
          series: <CircularSeries>[PieSeries<Map<String, dynamic>, String>(
            dataSource: capturesParDestination,
            xValueMapper: (data, _) => data['destination'],
            yValueMapper: (data, _) => double.parse(data['pourcentage']),
            dataLabelMapper: (data, _) =>
            '${data['destination']}\n${data['pourcentage']}%',
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          )],
        ),
      ),
    );
  }

  Widget _buildBarChart(StatistiquesProvider provider) {
    final topLieux = provider.topLieuxPeche();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          series: <ColumnSeries<Map<String, dynamic>, String>>[
            ColumnSeries(
              dataSource: topLieux,
              xValueMapper: (data, _) => data['nom_lieu'],
              yValueMapper: (data, _) => data['nombre_captures'],
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filtrer les Données',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Period Selection
                InkWell(
                  onTap: _selectionnerPeriode,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'Sélectionner une Période',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Percentage Toggle
                Consumer<DashboardProvider>(
                  builder: (context, dashboardProvider, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.percent,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Afficher en Pourcentage',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: dashboardProvider.afficherValeursEnPourcentage,
                              onChanged: (_) {
                                dashboardProvider.toggleAffichageValeursEnPourcentage();
                              },
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // Action Buttons with Asymmetric Sizing
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
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: () {
                          // Appliquer les filtres
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text('Appliquer'),
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

  void _selectionnerPeriode() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      Provider.of<DashboardProvider>(context, listen: false)
          .definirPeriode(picked.start, picked.end);
    }
  }
}