import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/categoriePecheurProvider.dart';
import '../../models/categoriepecheur.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';

class CategoriePecheurView extends StatefulWidget {
  const CategoriePecheurView({Key? key}) : super(key: key);

  @override
  _CategoriePecheurViewState createState() => _CategoriePecheurViewState();
}

class _CategoriePecheurViewState extends State<CategoriePecheurView> {
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _niveauExperienceController = TextEditingController();
  final TextEditingController _quotaCaptureController = TextEditingController();

  bool _isEditing = false;
  CategoriePecheur? _selectedCategorie;
  bool _isDetailsExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoriePecheurProvider>(context, listen: false).fetchCategories();
    });
  }

  void _clearFields() {
    _libelleController.clear();
    _descriptionController.clear();
    _niveauExperienceController.clear();
    _quotaCaptureController.clear();
    setState(() {
      _isEditing = false;
      _selectedCategorie = null;
    });
  }

  void _showCategorieForm(BuildContext context, {CategoriePecheur? categorie}) {
    setState(() {
      _isEditing = categorie != null;
      _selectedCategorie = categorie;

      if (categorie != null) {
        _libelleController.text = categorie.libelle;
        _descriptionController.text = categorie.description ?? '';
        _niveauExperienceController.text = categorie.niveauExperience ?? '';
        _quotaCaptureController.text = categorie.quotaCapture ?? '';
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
                        _isEditing ? 'Modifier Catégorie' : 'Ajouter Catégorie',
                        style: AppStyles.titleStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCategorieFormFields(context, setState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorieFormFields(BuildContext context, StateSetter setState) {
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
            controller: _libelleController,
            label: 'Libellé',
            icon: Icons.category,
            required: true,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _niveauExperienceController,
            label: 'Niveau d\'Expérience',
            icon: Icons.star_border,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _quotaCaptureController,
            label: 'Quota de Capture',
            icon: Icons.anchor,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: AppStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
            ),
            onPressed: () => _saveCategorie(context),
            child: Text(
              _isEditing ? 'Mettre à jour' : 'Créer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
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

  void _saveCategorie(BuildContext context) {
    final provider = Provider.of<CategoriePecheurProvider>(context, listen: false);

    if (_libelleController.text.isEmpty) {
      _showErrorSnackBar('Le libellé est requis');
      return;
    }

    if (_isEditing) {
      _updateExistingCategorie(provider);
    } else {
      _createNewCategorie(provider);
    }
  }

  void _updateExistingCategorie(CategoriePecheurProvider provider) {
    final updatedCategorie = CategoriePecheur(
      idCategorie: _selectedCategorie!.idCategorie,
      libelle: _libelleController.text,
      description: _descriptionController.text,
      niveauExperience: _niveauExperienceController.text,
      quotaCapture: _quotaCaptureController.text,
    );

    provider.modifierCategorie(updatedCategorie).then((success) {
      Navigator.pop(context);
      _clearFields();
      _showSuccessSnackBar('Catégorie mise à jour');
    });
  }

  void _createNewCategorie(CategoriePecheurProvider provider) {
    final newCategorie = CategoriePecheur(
      libelle: _libelleController.text,
      description: _descriptionController.text,
      niveauExperience: _niveauExperienceController.text,
      quotaCapture: _quotaCaptureController.text,
    );

    provider.ajouterCategorie(newCategorie).then((success) {
      Navigator.pop(context);
      _clearFields();
      _showSuccessSnackBar('Catégorie ajoutée');
    });
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

  void _confirmDelete(BuildContext context, CategoriePecheur categorie) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(color: AppColors.primary),
        ),
        content: Text('Voulez-vous vraiment supprimer la catégorie ${categorie.libelle} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<CategoriePecheurProvider>(context, listen: false)
                  .supprimerCategorie(categorie.idCategorie!)
                  .then((success) {
                if (success) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Catégorie supprimée');
                }
              });
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestion des Catégories Pêcheur'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
      ),
      body: Consumer<CategoriePecheurProvider>(
        builder: (context, provider, child) {
          final categories = provider.categories;

          if (categories.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCategorieList(categories);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategorieForm(context),
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
            Icons.category_sharp,
            size: 100,
            color: AppColors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucune catégorie trouvée',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorieList(List<CategoriePecheur> categories) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final categorie = categories[index];
        return _buildCategorieCard(categorie);
      },
    );
  }

  Widget _buildCategorieCard(CategoriePecheur categorie) {
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
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: const Icon(
            Icons.category,
            color: Colors.white,
          ),
        ),
        title: Text(
          categorie.libelle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showCategorieForm(context, categorie: categorie),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, categorie),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                    'Description',
                    categorie.description ?? 'N/A'
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                    'Niveau d\'Expérience',
                    categorie.niveauExperience ?? 'N/A'
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                    'Quota de Capture',
                    categorie.quotaCapture ?? 'N/A'
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}