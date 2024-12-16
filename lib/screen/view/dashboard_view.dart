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

          return Column(
            children: [
              _buildDashboardTabs(dashboardProvider),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    _buildStatistiquesGrid(statistiquesProvider),
                    _buildChartsSection(statistiquesProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardTabs(DashboardProvider dashboardProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        color: Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: List.generate(
            dashboardProvider.dashboardWidgets.length,
                (index) {
              final isSelected =
                  index == dashboardProvider.selectedDashboardIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Text(
                    dashboardProvider.dashboardWidgets[index],
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: isSelected,
                  selectedColor: Colors.blueAccent,
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
      ),
    );
  }

  SliverGrid _buildStatistiquesGrid(StatistiquesProvider provider) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      delegate: SliverChildListDelegate(
        [
          _buildStatistiqueCard(
            title: 'Total Captures',
            value: provider.statistiquesGlobales['nombre_total_captures']
                ?.toString() ??
                '0',
            icon: Icons.catching_pokemon,
            color: Colors.blue,
          ),
          _buildStatistiqueCard(
            title: 'Quantité Totale',
            value:
            '${provider.statistiquesGlobales['quantite_totale']?.toStringAsFixed(2) ?? '0'} kg',
            icon: Icons.scale,
            color: Colors.green,
          ),
          _buildStatistiqueCard(
            title: 'Pêcheurs Actifs',
            value: provider.statistiquesPecheurs['pecheurs_actifs']
                ?.toString() ??
                '0',
            icon: Icons.people,
            color: Colors.orange,
          ),
          _buildStatistiqueCard(
            title: 'Techniques Utilisées',
            value: provider.capturesParTechnique.length.toString(),
            icon: Icons.hardware,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildChartsSection(StatistiquesProvider provider) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          _buildPieChart(provider),
          _buildBarChart(provider),
        ],
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 30),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
    );
  }

  Widget _buildPieChart(StatistiquesProvider provider) {
    final capturesParDestination =
    provider.calculPourcentageCapturesParDestination();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Répartition des Captures',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SfCircularChart(
            series: <CircularSeries>[PieSeries<Map<String, dynamic>, String>(
              dataSource: capturesParDestination,
              xValueMapper: (data, _) => data['destination'],
              yValueMapper: (data, _) => double.parse(data['pourcentage']),
              dataLabelMapper: (data, _) =>
              '${data['destination']}\n${data['pourcentage']}%',
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            )],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(StatistiquesProvider provider) {
    final topLieux = provider.topLieuxPeche();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Top 5 Lieux de Pêche',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SfCartesianChart(
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
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrer les Données'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _selectionnerPeriode,
                child: const Text('Sélectionner une Période'),
              ),
              SwitchListTile(
                title: const Text('Afficher en Pourcentage'),
                value: Provider.of<DashboardProvider>(context)
                    .afficherValeursEnPourcentage,
                onChanged: (_) {
                  Provider.of<DashboardProvider>(context, listen: false)
                      .toggleAffichageValeursEnPourcentage();
                },
              ),
            ],
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
