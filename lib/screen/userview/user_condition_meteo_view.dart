import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/conditionmeteo.dart';
import '../../provider/conditionMeteoProvider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';

class UserWeatherConditionManagementView extends StatefulWidget {
  const UserWeatherConditionManagementView({Key? key}) : super(key: key);

  @override
  _UserWeatherConditionManagementViewState createState() => _UserWeatherConditionManagementViewState();
}

class _UserWeatherConditionManagementViewState extends State<UserWeatherConditionManagementView> {
  // Controllers for text inputs
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humiditeController = TextEditingController();
  final TextEditingController _vitesseVentController = TextEditingController();
  final TextEditingController _pressionAtmospheriqueController = TextEditingController();

  // State variables
  DateTime? _dateReleve;
  String? _directionVent;
  String? _precipitation;
  String? _visibilite;
  String? _etatGeneral;

  ConditionMeteo? _selectedCondition;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConditionMeteoProvider>().fetchConditions();
    });
  }

  void _clearFields() {
    _temperatureController.clear();
    _humiditeController.clear();
    _vitesseVentController.clear();
    _pressionAtmospheriqueController.clear();
    setState(() {
      _dateReleve = null;
      _directionVent = null;
      _precipitation = null;
      _visibilite = null;
      _etatGeneral = null;
      _isEditing = false;
      _selectedCondition = null;
    });
  }

  void _showConditionForm(BuildContext context, {ConditionMeteo? condition}) {
    setState(() {
      _isEditing = condition != null;
      _selectedCondition = condition;

      if (condition != null) {
        _temperatureController.text = condition.temperature?.toString() ?? '';
        _humiditeController.text = condition.humidite?.toString() ?? '';
        _vitesseVentController.text = condition.vitesseVent?.toString() ?? '';
        _pressionAtmospheriqueController.text = condition.pressionAtmospherique?.toString() ?? '';
        _dateReleve = condition.dateReleve;
        _directionVent = condition.directionVent;
        _precipitation = condition.precipitation;
        _visibilite = condition.visibilite;
        _etatGeneral = condition.etatGeneral;
      } else {
        _clearFields();
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        _isEditing ? 'Modifier Condition Météo' : 'Ajouter Condition Météo',
                        style: AppStyles.titleStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildConditionFormFields(context, setState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConditionFormFields(BuildContext context, StateSetter setState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateReleveField(context, setState),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _temperatureController,
            label: 'Température (°C)',
            icon: Icons.thermostat,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _humiditeController,
            label: 'Humidité (%)',
            icon: Icons.water_drop,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _vitesseVentController,
            label: 'Vitesse du Vent (km/h)',
            icon: Icons.wind_power,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 15),
          _buildDirectionVentDropdown(setState),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _pressionAtmospheriqueController,
            label: 'Pression Atmosphérique (hPa)',
            icon: Icons.compress,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 15),
          _buildPrecipitationDropdown(setState),
          const SizedBox(height: 15),
          _buildVisibiliteDropdown(setState),
          const SizedBox(height: 15),
          _buildEtatGeneralDropdown(setState),
          const SizedBox(height: 20),
          ElevatedButton(
            style: AppStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
            ),
            onPressed: () => _saveCondition(context),
            child: Text(
              _isEditing ? 'Mettre à jour' : 'Créer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateReleveField(BuildContext context, StateSetter setState) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateReleve ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _dateReleve) {
          setState(() {
            _dateReleve = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Date de Relevé *',
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            hintText: _dateReleve != null
                ? DateFormat('dd/MM/yyyy').format(_dateReleve!)
                : 'Sélectionner une date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          controller: TextEditingController(
            text: _dateReleve != null
                ? DateFormat('dd/MM/yyyy').format(_dateReleve!)
                : '',
          ),
        ),
      ),
    );
  }

  Widget _buildDirectionVentDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Direction du Vent',
        prefixIcon: Icon(Icons.wind_power, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _directionVent,
      items: ['Nord', 'Nord-Est', 'Est', 'Sud-Est', 'Sud', 'Sud-Ouest', 'Ouest', 'Nord-Ouest']
          .map((direction) => DropdownMenuItem(
        value: direction,
        child: Text(direction),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _directionVent = value;
        });
      },
    );
  }

  Widget _buildPrecipitationDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Précipitations',
        prefixIcon: Icon(Icons.water, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _precipitation,
      items: ['Aucune', 'Légère', 'Modérée', 'Forte']
          .map((precipitation) => DropdownMenuItem(
        value: precipitation,
        child: Text(precipitation),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _precipitation = value;
        });
      },
    );
  }

  Widget _buildVisibiliteDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Visibilité',
        prefixIcon: Icon(Icons.visibility, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _visibilite,
      items: ['Très Bonne', 'Bonne', 'Moyenne', 'Faible']
          .map((visibilite) => DropdownMenuItem(
        value: visibilite,
        child: Text(visibilite),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _visibilite = value;
        });
      },
    );
  }

  Widget _buildEtatGeneralDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'État Général',
        prefixIcon: Icon(Icons.wb_sunny, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _etatGeneral,
      items: ['Clair', 'Nuageux', 'Couvert', 'Orageux']
          .map((etat) => DropdownMenuItem(
        value: etat,
        child: Text(etat),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _etatGeneral = value;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  Future<void> _saveCondition(BuildContext context) async {
    final provider = context.read<ConditionMeteoProvider>();

    if (_dateReleve == null) {
      _showErrorSnackBar('La date de relevé est obligatoire');
      return;
    }

    final condition = ConditionMeteo(
      idMeteo: _isEditing ? _selectedCondition!.idMeteo : null,
      dateReleve: _dateReleve,
      temperature: _temperatureController.text.isNotEmpty
          ? double.tryParse(_temperatureController.text)
          : null,
      humidite: _humiditeController.text.isNotEmpty
          ? double.tryParse(_humiditeController.text)
          : null,
      vitesseVent: _vitesseVentController.text.isNotEmpty
          ? double.tryParse(_vitesseVentController.text)
          : null,
      directionVent: _directionVent,
      pressionAtmospherique: _pressionAtmospheriqueController.text.isNotEmpty
          ? double.tryParse(_pressionAtmospheriqueController.text)
          : null,
      precipitation: _precipitation,
      visibilite: _visibilite,
      etatGeneral: _etatGeneral,
    );

    _isEditing
        ? provider.modifierCondition(condition)
        : provider.ajouterCondition(condition);

    Navigator.pop(context);
    _clearFields();
    _showSuccessSnackBar(_isEditing ? 'Condition météo mise à jour' : 'Condition météo ajoutée');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of controllers to prevent memory leaks
    _temperatureController.dispose();
    _humiditeController.dispose();
    _vitesseVentController.dispose();
    _pressionAtmospheriqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestion des Conditions Météo'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
      ),
      body: Consumer<ConditionMeteoProvider>(
        builder: (context, provider, child) {
          final conditions = provider.conditions;

          if (conditions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildConditionList(conditions);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showConditionForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 100,
            color: AppColors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Aucune condition météo trouvée',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionList(List<ConditionMeteo> conditions) {
    return ListView.builder(
      itemCount: conditions.length,
      itemBuilder: (context, index) {
        final condition = conditions[index];
        return _buildConditionCard(condition);
      },
    );
  }

  Widget _buildConditionCard(ConditionMeteo condition) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.7),
          child: Icon(
            Icons.wb_sunny,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          'Relevé du ${DateFormat('dd/MM/yyyy').format(condition.dateReleve!)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          '${condition.temperature != null ? '${condition.temperature!.toStringAsFixed(1)}°C' : 'Temp. non renseignée'}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showConditionForm(context, condition: condition),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.thermostat,
                  label: 'Température',
                  value: condition.temperature != null
                      ? '${condition.temperature!.toStringAsFixed(1)}°C'
                      : 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.water_drop,
                  label: 'Humidité',
                  value: condition.humidite != null
                      ? '${condition.humidite!.toStringAsFixed(1)}%'
                      : 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.wind_power,
                  label: 'Vitesse du vent',
                  value: condition.vitesseVent != null
                      ? '${condition.vitesseVent!.toStringAsFixed(1)} km/h'
                      : 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.near_me,
                  label: 'Direction du vent',
                  value: condition.directionVent ?? 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.compress,
                  label: 'Pression atmosphérique',
                  value: condition.pressionAtmospherique != null
                      ? '${condition.pressionAtmospherique!.toStringAsFixed(1)} hPa'
                      : 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.water,
                  label: 'Précipitations',
                  value: condition.precipitation ?? 'Non renseignées',
                ),
                _buildDetailRow(
                  icon: Icons.visibility,
                  label: 'Visibilité',
                  value: condition.visibilite ?? 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.wb_sunny,
                  label: 'État général',
                  value: condition.etatGeneral ?? 'Non renseigné',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}