import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../models/categoriepecheur.dart';
import '../../provider/categoriePecheurProvider.dart';
import '../../provider/pecheurProvider.dart';
import '../../models/pecheur.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';
import 'package:intl/intl.dart';

class FishermanManagementView extends StatefulWidget {
  const FishermanManagementView({Key? key}) : super(key: key);

  @override
  _FishermanManagementViewState createState() => _FishermanManagementViewState();
}

class _FishermanManagementViewState extends State<FishermanManagementView> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _licenceController = TextEditingController();
  DateTime? _dateNaissance;
  int? _selectedCategorie;
  DateTime? _dateInscription;
  String? _selectedStatut;
  File? _imageFile;

  Pecheur? _selectedPecheur;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Utiliser un post-frame callback avec un contexte différent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Utiliser context.read() au lieu de Provider.of()
      context.read<PecheurProvider>().fetchPecheurs();
    });
  }

  void _clearFields() {
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    _telephoneController.clear();
    _adresseController.clear();
    _licenceController.clear();
    setState(() {
      _dateNaissance = null;
      _isEditing = false;
      _selectedPecheur = null;
    });
  }

  void _showPecheurForm(BuildContext context, {Pecheur? pecheur}) {
    setState(() {
      _isEditing = pecheur != null;
      _selectedPecheur = pecheur;

      if (pecheur != null) {
        _nomController.text = pecheur.nom;
        _prenomController.text = pecheur.prenom ?? '';
        _emailController.text = pecheur.email ?? '';
        _telephoneController.text = pecheur.telephone ?? '';
        _adresseController.text = pecheur.adresse ?? '';
        _licenceController.text = pecheur.numeroLicence ?? '';
        _dateNaissance = pecheur.dateNaissance;
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
                        _isEditing ? 'Modifier Pêcheur' : 'Ajouter Pêcheur',
                        style: AppStyles.titleStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPecheurFormFields(context, setState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPecheurFormFields(BuildContext context, StateSetter setState) {
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
            icon: Icons.person,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _prenomController,
            label: 'Prénom',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 15),
          _buildDatePickerField(context, setState),
          const SizedBox(height: 15),
          // Ajout du champ Catégorie
          _buildCategorieDropdown(context, setState),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _telephoneController,
            label: 'Téléphone',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _adresseController,
            label: 'Adresse',
            icon: Icons.location_on,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _licenceController,
            label: 'Numéro de Licence',
            icon: Icons.card_membership,
          ),
          const SizedBox(height: 15),

          _buildDateInscriptionField(context, setState),
          const SizedBox(height: 15),

          _buildStatutDropdown(setState),
          const SizedBox(height: 15),

          _buildPhotoProfil(setState),
          const SizedBox(height: 20),
          ElevatedButton(
            style: AppStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
            ),
            onPressed: () => _savePecheur(context),
            child: Text(
              _isEditing ? 'Mettre à jour' : 'Créer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context, StateSetter setState) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateNaissance ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _dateNaissance) {
          setState(() {
            _dateNaissance = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Date de Naissance',
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            hintText: _dateNaissance != null
                ? DateFormat('dd/MM/yyyy').format(_dateNaissance!)
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
            text: _dateNaissance != null
                ? DateFormat('dd/MM/yyyy').format(_dateNaissance!)
                : '',
          ),
        ),
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
          value: _selectedPecheur?.idCategorie,
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

  Widget _buildDateInscriptionField(BuildContext context, StateSetter setState) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateInscription ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _dateInscription) {
          setState(() {
            _dateInscription = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Date d\'Inscription',
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            hintText: _dateInscription != null
                ? DateFormat('dd/MM/yyyy').format(_dateInscription!)
                : 'Sélectionner une date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          controller: TextEditingController(
            text: _dateInscription != null
                ? DateFormat('dd/MM/yyyy').format(_dateInscription!)
                : '',
          ),
        ),
      ),
    );
  }

  Widget _buildStatutDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Statut',
        prefixIcon: Icon(Icons.check_circle, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedStatut,
      items: ['actif', 'inactif', 'suspendu']
          .map((statut) => DropdownMenuItem(
        value: statut,
        child: Text(statut),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatut = value;
        });
      },
    );
  }

// Pour la photo de profil
  Widget _buildPhotoProfil(StateSetter setState) {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(Icons.camera_alt, color: AppColors.primary),
            SizedBox(width: 10),
            Text(
              _imageFile != null ? 'Image sélectionnée' : 'Sélectionner une photo de profil',
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Erreur de sélection d\'image : $e');
      _showErrorSnackBar('Impossible de sélectionner l\'image');
    }
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

  Future<void> _savePecheur(BuildContext context) async {
    final provider = context.read<PecheurProvider>();

    if (_nomController.text.isEmpty) {
      _showErrorSnackBar('Le nom est obligatoire');
      return;
    }

    String? photoPath;
    if (_imageFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_profile.jpg';
      photoPath = '${directory.path}/$fileName';


      await _imageFile!.copy(photoPath);
    }

    final pecheur = Pecheur(
      idPecheur: _isEditing ? _selectedPecheur!.idPecheur : null,
      nom: _nomController.text,
      prenom: _prenomController.text.isNotEmpty ? _prenomController.text : null,
      dateNaissance: _dateNaissance,
      idCategorie: _selectedCategorie,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      telephone: _telephoneController.text.isNotEmpty ? _telephoneController.text : null,
      adresse: _adresseController.text.isNotEmpty ? _adresseController.text : null,
      numeroLicence: _licenceController.text.isNotEmpty ? _licenceController.text : null,
      dateInscription: _dateInscription ?? DateTime.now(),
      photoProfil: photoPath,
      statut: _selectedStatut ?? 'actif',
    );

    _isEditing
    ? provider.modifierPecheur(pecheur)
        : provider.ajouterPecheur(pecheur);

    Navigator.pop(context);
    _clearFields();
    _showSuccessSnackBar(_isEditing ? 'Pêcheur mis à jour' : 'Pêcheur ajouté');
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

  void _confirmDelete(BuildContext context, Pecheur pecheur) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(color: AppColors.primary),
        ),
        content: Text('Voulez-vous vraiment supprimer le pêcheur ${pecheur.nom} ${pecheur.prenom ?? ''}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<PecheurProvider>()
                  .supprimerPecheur(pecheur.idPecheur!)
                  .then((_) {
                Navigator.pop(context);
                _showSuccessSnackBar('Pêcheur supprimé');
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
    // Dispose of controllers to prevent memory leaks
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _licenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestion des Pêcheurs'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
      ),
      body: Consumer<PecheurProvider>(
        builder: (context, provider, child) {
          final pecheurs = provider.pecheurs;

          if (pecheurs.isEmpty) {
            return _buildEmptyState();
          }

          return _buildPecheurList(pecheurs);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPecheurForm(context),
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
            Icons.phishing_outlined,
            size: 100,
            color: AppColors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Aucun pêcheur trouvé',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPecheurList(List<Pecheur> pecheurs) {
    return ListView.builder(
      itemCount: pecheurs.length,
      itemBuilder: (context, index) {
        final pecheur = pecheurs[index];
        return _buildPecheurCard(pecheur);
      },
    );
  }

  Widget _buildPecheurCard(Pecheur pecheur) {
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
          child: pecheur.photoProfil != null
              ? ClipOval(
            child: Image.file(
              File(pecheur.photoProfil!),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          )
              : Text(
            pecheur.nom[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          '${pecheur.nom} ${pecheur.prenom ?? ''}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          pecheur.numeroLicence ?? 'Pas de licence',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showPecheurForm(context, pecheur: pecheur),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, pecheur),
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
                  icon: Icons.email,
                  label: 'Email',
                  value: pecheur.email ?? 'Non renseigné',
                ),
                _buildDetailRow(
                  icon: Icons.phone,
                  label: 'Téléphone',
                  value: pecheur.telephone ?? 'Non renseigné',
                ),
                _buildDetailRow(
                  icon: Icons.cake,
                  label: 'Date de naissance',
                  value: pecheur.dateNaissance != null
                      ? DateFormat('dd/MM/yyyy').format(pecheur.dateNaissance!)
                      : 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Adresse',
                  value: pecheur.adresse ?? 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'Catégorie',
                  value: context.read<CategoriePecheurProvider>()
                      .categories
                      .firstWhere(
                        (cat) => cat.idCategorie == pecheur.idCategorie,
                    orElse: () => CategoriePecheur(libelle: 'Non renseignée'),
                  ).libelle,
                ),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date d\'inscription',
                  value: pecheur.dateInscription != null
                      ? DateFormat('dd/MM/yyyy').format(pecheur.dateInscription!)
                      : 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.check_circle,
                  label: 'Statut',
                  value: pecheur.statut ?? 'Non renseigné',
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