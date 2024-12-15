import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/lieupeche.dart';
import '../../provider/lieuPecheProvider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';

class LieuPecheManagementView extends StatefulWidget {
  const LieuPecheManagementView({Key? key}) : super(key: key);

  @override
  _LieuPecheManagementViewState createState() => _LieuPecheManagementViewState();
}

class _LieuPecheManagementViewState extends State<LieuPecheManagementView> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _profondeurController = TextEditingController();
  final TextEditingController _accesController = TextEditingController();
  final TextEditingController _restrictionsController = TextEditingController();
  final TextEditingController _proprietaireController = TextEditingController();

  String? _selectedTypeEau;
  LieuPeche? _selectedLieuPeche;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LieuPecheProvider>().fetchLieux();
    });
  }

  void _clearFields() {
    _nomController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _descriptionController.clear();
    _profondeurController.clear();
    _accesController.clear();
    _restrictionsController.clear();
    _proprietaireController.clear();

    setState(() {
      _isEditing = false;
      _selectedLieuPeche = null;
      _selectedTypeEau = null;
    });
  }

  void _showLieuPecheForm(BuildContext context, {LieuPeche? lieuPeche}) {
    setState(() {
      _isEditing = lieuPeche != null;
      _selectedLieuPeche = lieuPeche;

      if (lieuPeche != null) {
        _nomController.text = lieuPeche.nom;
        _latitudeController.text = lieuPeche.latitude?.toString() ?? '';
        _longitudeController.text = lieuPeche.longitude?.toString() ?? '';
        _descriptionController.text = lieuPeche.description ?? '';
        _profondeurController.text = lieuPeche.profondeur?.toString() ?? '';
        _accesController.text = lieuPeche.acces ?? '';
        _restrictionsController.text = lieuPeche.restrictions ?? '';
        _proprietaireController.text = lieuPeche.proprietaire ?? '';
        _selectedTypeEau = lieuPeche.typeEau;
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
                        _isEditing ? 'Modifier Lieu de Pêche' : 'Ajouter Lieu de Pêche',
                        style: AppStyles.titleStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildLieuPecheFormFields(context, setState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLieuPecheFormFields(BuildContext context, StateSetter setState) {
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
          _buildTextField(
            controller: _nomController,
            label: 'Nom *',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _latitudeController,
            label: 'Latitude',
            icon: Icons.map,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _longitudeController,
            label: 'Longitude',
            icon: Icons.map,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 15),
          _buildTypeEauDropdown(setState),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _profondeurController,
            label: 'Profondeur (m)',
            icon: Icons.water,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _accesController,
            label: 'Accès',
            icon: Icons.directions,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _restrictionsController,
            label: 'Restrictions',
            icon: Icons.warning,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _proprietaireController,
            label: 'Propriétaire',
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: AppStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
            ),
            onPressed: () => _saveLieuPeche(context),
            child: Text(
              _isEditing ? 'Mettre à jour' : 'Créer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeEauDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Type d\'Eau',
        prefixIcon: Icon(Icons.water, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedTypeEau,
      items: ['mer', 'riviere', 'lac', 'etang']
          .map((type) => DropdownMenuItem(
        value: type,
        child: Text(type),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedTypeEau = value;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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

  Future<void> _saveLieuPeche(BuildContext context) async {
    final provider = context.read<LieuPecheProvider>();

    if (_nomController.text.isEmpty) {
      _showErrorSnackBar('Le nom est obligatoire');
      return;
    }

    final lieuPeche = LieuPeche(
      idLieu: _isEditing ? _selectedLieuPeche!.idLieu : null,
      nom: _nomController.text,
      latitude: _latitudeController.text.isNotEmpty
          ? double.tryParse(_latitudeController.text)
          : null,
      longitude: _longitudeController.text.isNotEmpty
          ? double.tryParse(_longitudeController.text)
          : null,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      typeEau: _selectedTypeEau,
      profondeur: _profondeurController.text.isNotEmpty
          ? double.tryParse(_profondeurController.text)
          : null,
      acces: _accesController.text.isNotEmpty
          ? _accesController.text
          : null,
      restrictions: _restrictionsController.text.isNotEmpty
          ? _restrictionsController.text
          : null,
      proprietaire: _proprietaireController.text.isNotEmpty
          ? _proprietaireController.text
          : null,
    );

    _isEditing
        ? provider.modifierLieu(lieuPeche)
        : provider.ajouterLieu(lieuPeche);

    Navigator.pop(context);
    _clearFields();
    _showSuccessSnackBar(_isEditing ? 'Lieu de Pêche mis à jour' : 'Lieu de Pêche ajouté');
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

  void _confirmDelete(BuildContext context, LieuPeche lieuPeche) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(color: AppColors.primary),
        ),
        content: Text('Voulez-vous vraiment supprimer le lieu de pêche ${lieuPeche.nom}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<LieuPecheProvider>()
                  .supprimerLieu(lieuPeche.idLieu!)
                  .then((_) {
                Navigator.pop(context);
                _showSuccessSnackBar('Lieu de Pêche supprimé');
              });
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _descriptionController.dispose();
    _profondeurController.dispose();
    _accesController.dispose();
    _restrictionsController.dispose();
    _proprietaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestion des Lieux de Pêche'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
      ),
      body: Consumer<LieuPecheProvider>(
        builder: (context, provider, child) {
          final lieux = provider.lieux;

          if (lieux.isEmpty) {
            return _buildEmptyState();
          }

          return _buildLieuPecheList(lieux);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLieuPecheForm(context),
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
            Icons.water_outlined,
            size: 100,
            color: AppColors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Aucun lieu de pêche trouvé',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLieuPecheList(List<LieuPeche> lieux) {
    return ListView.builder(
      itemCount: lieux.length,
      itemBuilder: (context, index) {
        final lieu = lieux[index];
        return _buildLieuPecheCard(lieu);
      },
    );
  }

  Widget _buildLieuPecheCard(LieuPeche lieu) {
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
            Icons.location_on,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          lieu.nom,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          lieu.typeEau ?? 'Type d\'eau non spécifié',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showLieuPecheForm(context, lieuPeche: lieu),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, lieu),
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
                  icon: Icons.map,
                  label: 'Coordonnées',
                  value: lieu.latitude != null && lieu.longitude != null
                      ? '${lieu.latitude}° N, ${lieu.longitude}° E'
                      : 'Non renseignées',
                ),
                _buildDetailRow(
                  icon: Icons.water,
                  label: 'Profondeur',
                  value: lieu.profondeur != null
                      ? '${lieu.profondeur} mètres'
                      : 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.description,
                  label: 'Description',
                  value: lieu.description ?? 'Aucune description',
                ),
                _buildDetailRow(
                  icon: Icons.directions,
                  label: 'Accès',
                  value: lieu.acces ?? 'Pas d\'information d\'accès',
                ),
                _buildDetailRow(
                  icon: Icons.warning,
                  label: 'Restrictions',
                  value: lieu.restrictions ?? 'Aucune restriction connue',
                ),
                _buildDetailRow(
                  icon: Icons.person,
                  label: 'Propriétaire',
                  value: lieu.proprietaire ?? 'Propriétaire non renseigné',
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