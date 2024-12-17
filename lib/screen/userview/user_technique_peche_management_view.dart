import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/categoriepecheur.dart';
import '../../models/techniquepeche.dart';
import '../../provider/categoriePecheurProvider.dart';
import '../../provider/techniquePecheProvider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';

class UserTechniquePecheManagementView extends StatefulWidget {
  const UserTechniquePecheManagementView({Key? key}) : super(key: key);

  @override
  _UserTechniquePecheManagementViewState createState() => _UserTechniquePecheManagementViewState();
}

class _UserTechniquePecheManagementViewState extends State<UserTechniquePecheManagementView> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _materielRequisController = TextEditingController();

  int? _selectedCategorie;
  String? _selectedDifficulte;
  String? _selectedSaison;

  TechniquePeche? _selectedTechnique;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TechniquePecheProvider>().fetchTechniques();
    });
  }

  void _clearFields() {
    _nomController.clear();
    _descriptionController.clear();
    _materielRequisController.clear();
    setState(() {
      _selectedCategorie = null;
      _selectedDifficulte = null;
      _selectedSaison = null;
      _isEditing = false;
      _selectedTechnique = null;
    });
  }

  void _showTechniqueForm(BuildContext context, {TechniquePeche? technique}) {
    setState(() {
      _isEditing = technique != null;
      _selectedTechnique = technique;

      if (technique != null) {
        _nomController.text = technique.nom;
        _descriptionController.text = technique.description ?? '';
        _materielRequisController.text = technique.materielRequis ?? '';
        _selectedCategorie = technique.idCategorie;
        _selectedDifficulte = technique.difficulte;
        _selectedSaison = technique.saisonRecommandee;
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
                      Expanded(
                        child: Text(
                          _isEditing ? 'Modifier Technique de Pêche' : 'Ajouter de Technique',
                          style: AppStyles.titleStyle.copyWith(fontSize: 20),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTechniqueFormFields(context, setState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTechniqueFormFields(BuildContext context, StateSetter setState) {
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
            label: 'Nom de la Technique *',
            icon: Icons.analytics_outlined,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 15),
          _buildCategorieDropdown(context, setState),
          const SizedBox(height: 15),
          _buildDifficulteDropdown(setState),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _materielRequisController,
            label: 'Matériel Requis',
            icon: Icons.hardware,
          ),
          const SizedBox(height: 15),
          _buildSaisonDropdown(setState),
          const SizedBox(height: 20),
          ElevatedButton(
            style: AppStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
            ),
            onPressed: () => _saveTechnique(context),
            child: Text(
              _isEditing ? 'Mettre à jour' : 'Créer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorieDropdown(BuildContext context, StateSetter setState) {
    return Consumer<CategoriePecheurProvider>(
      builder: (context, categorieProvider, child) {
        if (categorieProvider.categories.isEmpty) {
          categorieProvider.fetchCategories();
          return CircularProgressIndicator();
        }

        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Catégorie de Pêcheur',
            prefixIcon: Icon(Icons.category, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedTechnique?.idCategorie,
          items: categorieProvider.categories.map((categorie) {
            return DropdownMenuItem<int>(
              value: categorie.idCategorie,
              child: Text(categorie.libelle),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategorie = value;
            });
          },
        );
      },
    );
  }

  Widget _buildDifficulteDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Difficulté',
        prefixIcon: Icon(Icons.speed, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedDifficulte,
      items: ['Débutant', 'Intermédiaire', 'Avancé']
          .map((difficulte) => DropdownMenuItem(
        value: difficulte,
        child: Text(difficulte),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedDifficulte = value;
        });
      },
    );
  }

  Widget _buildSaisonDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Saison Recommandée',
        prefixIcon: Icon(Icons.calendar_month, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedSaison,
      items: ['Printemps', 'Été', 'Automne', 'Hiver']
          .map((saison) => DropdownMenuItem(
        value: saison,
        child: Text(saison),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedSaison = value;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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

  Future<void> _saveTechnique(BuildContext context) async {
    final provider = context.read<TechniquePecheProvider>();

    if (_nomController.text.isEmpty) {
      _showErrorSnackBar('Le nom de la technique est obligatoire');
      return;
    }

    final technique = TechniquePeche(
      idTechnique: _isEditing ? _selectedTechnique!.idTechnique : null,
      nom: _nomController.text,
      description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
      idCategorie: _selectedCategorie,
      difficulte: _selectedDifficulte,
      materielRequis: _materielRequisController.text.isNotEmpty ? _materielRequisController.text : null,
      saisonRecommandee: _selectedSaison,
    );

    _isEditing
        ? provider.modifierTechnique(technique)
        : provider.ajouterTechnique(technique);

    Navigator.pop(context);
    _clearFields();
    _showSuccessSnackBar(_isEditing ? 'Technique de Pêche mise à jour' : 'Technique de Pêche ajoutée');
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
    _nomController.dispose();
    _descriptionController.dispose();
    _materielRequisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestion des Techniques de Pêche'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
      ),
      body: Consumer<TechniquePecheProvider>(
        builder: (context, provider, child) {
          final techniques = provider.techniques;

          if (techniques.isEmpty) {
            return _buildEmptyState();
          }

          return _buildTechniqueList(techniques);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTechniqueForm(context),
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
            Icons.not_interested_outlined,
            size: 100,
            color: AppColors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Aucune technique de pêche trouvée',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniqueList(List<TechniquePeche> techniques) {
    return ListView.builder(
      itemCount: techniques.length,
      itemBuilder: (context, index) {
        final technique = techniques[index];
        return _buildTechniqueCard(technique);
      },
    );
  }

  Widget _buildTechniqueCard(TechniquePeche technique) {
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
            Icons.analytics_outlined,
            color: Colors.white,
          ),
        ),
        title: Text(
          technique.nom,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          technique.difficulte ?? 'Difficulté non renseignée',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showTechniqueForm(context, technique: technique),
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
                  icon: Icons.description,
                  label: 'Description',
                  value: technique.description ?? 'Aucune description',
                ),
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'Catégorie de Pêcheur',
                  value: context.read<CategoriePecheurProvider>()
                      .categories
                      .firstWhere(
                        (cat) => cat.idCategorie == technique.idCategorie,
                    orElse: () => CategoriePecheur(libelle: 'Non renseignée'),
                  ).libelle,
                ),
                _buildDetailRow(
                  icon: Icons.speed,
                  label: 'Niveau de Difficulté',
                  value: technique.difficulte ?? 'Non renseigné',
                ),
                _buildDetailRow(
                  icon: Icons.hardware,
                  label: 'Matériel Requis',
                  value: technique.materielRequis ?? 'Aucun matériel spécifié',
                ),
                _buildDetailRow(
                  icon: Icons.calendar_month,
                  label: 'Saison Recommandée',
                  value: technique.saisonRecommandee ?? 'Toutes saisons',
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