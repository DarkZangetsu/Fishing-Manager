import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/pecheur.dart';
import '../../models/pecheurtechnique.dart';
import '../../models/techniquepeche.dart';
import '../../provider/pecheurProvider.dart';
import '../../provider/techniquePecheProvider.dart';
import '../../provider/pecheurTechniqueProvider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';

class FishermanTechniqueView extends StatefulWidget {
  const FishermanTechniqueView({Key? key}) : super(key: key);

  @override
  _FishermanTechniqueViewState createState() => _FishermanTechniqueViewState();
}

class _FishermanTechniqueViewState extends State<FishermanTechniqueView> {
  // Contrôleurs pour les champs de formulaire
  final TextEditingController _niveauMaitriseController = TextEditingController();

  // Variables d'état
  DateTime? _dateApprentissage;
  Pecheur? _selectedPecheur;
  TechniquePeche? _selectedTechnique;
  String? _selectedNiveauMaitrise;

  // Liste des niveaux de maîtrise
  final List<String> _niveauxMaitrise = [
    'Débutant',
    'Intermédiaire',
    'Avancé',
    'Expert'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PecheurProvider>().fetchPecheurs();
      context.read<TechniquePecheProvider>().fetchTechniques();
      context.read<PecheurTechniqueProvider>().fetchPecheurTechniques();
    });
  }

  void _clearFields() {
    setState(() {
      _dateApprentissage = null;
      _selectedPecheur = null;
      _selectedTechnique = null;
      _selectedNiveauMaitrise = null;
      _niveauMaitriseController.clear();
    });
  }

  void _showPecheurTechniqueForm(BuildContext context) {
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
                        'Ajouter Technique de Pêche',
                        style: AppStyles.titleStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPecheurTechniqueFormFields(context, setState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPecheurTechniqueFormFields(BuildContext context, StateSetter setState) {
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
          // Dropdown pour sélectionner le pêcheur
          _buildPecheurDropdown(context, setState),
          const SizedBox(height: 15),

          // Dropdown pour sélectionner la technique de pêche
          _buildTechniqueDropdown(context, setState),
          const SizedBox(height: 15),

          // Date d'apprentissage
          _buildDateApprentissageField(context, setState),
          const SizedBox(height: 15),

          // Dropdown pour le niveau de maîtrise
          _buildNiveauMaitriseDropdown(setState),
          const SizedBox(height: 20),

          ElevatedButton(
            style: AppStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
            ),
            onPressed: () => _savePecheurTechnique(context),
            child: const Text(
              'Ajouter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPecheurDropdown(BuildContext context, StateSetter setState) {
    return Consumer<PecheurProvider>(
      builder: (context, pecheurProvider, child) {
        if (pecheurProvider.pecheurs.isEmpty) {
          return CircularProgressIndicator();
        }

        return DropdownButtonFormField<Pecheur>(
          decoration: InputDecoration(
            labelText: 'Pêcheur',
            prefixIcon: Icon(Icons.person, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedPecheur,
          items: pecheurProvider.pecheurs.map((pecheur) {
            return DropdownMenuItem<Pecheur>(
              value: pecheur,
              child: Text('${pecheur.nom} ${pecheur.prenom ?? ''}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedPecheur = value;
            });
          },
        );
      },
    );
  }

  Widget _buildTechniqueDropdown(BuildContext context, StateSetter setState) {
    return Consumer<TechniquePecheProvider>(
      builder: (context, techniqueProvider, child) {
        if (techniqueProvider.techniques.isEmpty) {
          techniqueProvider.fetchTechniques();
          return CircularProgressIndicator();
        }

        return DropdownButtonFormField<TechniquePeche>(
          decoration: InputDecoration(
            labelText: 'Technique de Pêche',
            prefixIcon: Icon(Icons.phishing, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedTechnique,
          items: techniqueProvider.techniques.map((technique) {
            return DropdownMenuItem<TechniquePeche>(
              value: technique,
              child: Text(technique.nom),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedTechnique = value;
            });
          },
        );
      },
    );
  }

  Widget _buildDateApprentissageField(BuildContext context, StateSetter setState) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dateApprentissage ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _dateApprentissage) {
          setState(() {
            _dateApprentissage = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Date d\'Apprentissage',
            prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
            hintText: _dateApprentissage != null
                ? DateFormat('dd/MM/yyyy').format(_dateApprentissage!)
                : 'Sélectionner une date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          controller: TextEditingController(
            text: _dateApprentissage != null
                ? DateFormat('dd/MM/yyyy').format(_dateApprentissage!)
                : '',
          ),
        ),
      ),
    );
  }

  Widget _buildNiveauMaitriseDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Niveau de Maîtrise',
        prefixIcon: Icon(Icons.leaderboard, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedNiveauMaitrise,
      items: _niveauxMaitrise
          .map((niveau) => DropdownMenuItem(
        value: niveau,
        child: Text(niveau),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedNiveauMaitrise = value;
        });
      },
    );
  }

  Future<void> _savePecheurTechnique(BuildContext context) async {
    if (_selectedPecheur == null || _selectedTechnique == null) {
      _showErrorSnackBar('Veuillez sélectionner un pêcheur et une technique');
      return;
    }

    final provider = context.read<PecheurTechniqueProvider>();

    await provider.ajouterPecheurTechnique(
        _selectedPecheur!.idPecheur!,
        _selectedTechnique!.idTechnique!,
        dateApprentissage: _dateApprentissage,
        niveauMaitrise: _selectedNiveauMaitrise
    );

    Navigator.pop(context);
    _clearFields();
    _showSuccessSnackBar('Technique ajoutée au pêcheur');
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

  void _confirmDelete(BuildContext context, int idPecheur, int idTechnique) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(color: AppColors.primary),
        ),
        content: const Text('Voulez-vous vraiment supprimer cette technique pour ce pêcheur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<PecheurTechniqueProvider>()
                  .supprimerPecheurTechnique(idPecheur, idTechnique)
                  .then((_) {
                Navigator.pop(context);
                _showSuccessSnackBar('Technique supprimée');
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
    _niveauMaitriseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Techniques de Pêche des Pêcheurs'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
      ),
      body: Consumer<PecheurTechniqueProvider>(
        builder: (context, pecheurTechniqueProvider, child) {
          final pecheurTechniques = pecheurTechniqueProvider.pecheurTechnique;

          if (pecheurTechniques.isEmpty) {
            return _buildEmptyState();
          }

          return _buildPecheurTechniqueList(pecheurTechniques);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPecheurTechniqueForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPecheurTechniqueList(List<PecheurTechnique> pecheurTechniques) {
    return ListView.builder(
      itemCount: pecheurTechniques.length,
      itemBuilder: (context, index) {
        final pecheurTechnique = pecheurTechniques[index];
        return _buildPecheurTechniqueCard(pecheurTechnique);
      },
    );
  }

  Widget _buildPecheurTechniqueCard(PecheurTechnique pecheurTechnique) {
    // Find the full name of the pecheur using the idPecheur
    Pecheur? pecheur = context.read<PecheurProvider>()
        .pecheurs
        .firstWhere((p) => p.idPecheur == pecheurTechnique.idPecheur);

    // Find the technique name using the idTechnique
    TechniquePeche? technique = context.read<TechniquePecheProvider>()
        .techniques
        .firstWhere((t) => t.idTechnique == pecheurTechnique.idTechnique);

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
          child: Text(
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
          technique.nom,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(
              context,
              pecheurTechnique.idPecheur,
              pecheurTechnique.idTechnique
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date d\'Apprentissage',
                  value: pecheurTechnique.dateApprentissage != null
                      ? DateFormat('dd/MM/yyyy').format(pecheurTechnique.dateApprentissage!)
                      : 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.leaderboard,
                  label: 'Niveau de Maîtrise',
                  value: pecheurTechnique.niveauMaitrise ?? 'Non renseigné',
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
}