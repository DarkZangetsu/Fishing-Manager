import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/capture.dart';
import '../../models/conditionmeteo.dart';
import '../../models/lieupeche.dart';
import '../../models/pecheur.dart';
import '../../models/techniquepeche.dart';
import '../../provider/captureProvider.dart';
import '../../provider/lieuPecheProvider.dart';
import '../../provider/conditionMeteoProvider.dart';
import '../../provider/techniquePecheProvider.dart';
import '../../provider/pecheurProvider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';


class CaptureManagementView extends StatefulWidget {
  const CaptureManagementView({Key? key}) : super(key: key);

  @override
  _CaptureManagementViewState createState() => _CaptureManagementViewState();
}

class _CaptureManagementViewState extends State<CaptureManagementView> {
  // Text Controllers
  final TextEditingController _nomProduitController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _poidsController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();



  // State Variables
  DateTime? _dateCapture;
  String? _heureCapture;
  int? _selectedPecheur;
  int? _selectedLieu;
  int? _selectedMeteo;
  int? _selectedTechnique;
  String? _selectedEtatProduit;
  String? _selectedDestination;

  Capture? _selectedCapture;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaptureProvider>().fetchCaptures();
      context.read<PecheurProvider>().fetchPecheurs();
      context.read<LieuPecheProvider>().fetchLieux();
      context.read<ConditionMeteoProvider>().fetchConditions();
      context.read<TechniquePecheProvider>().fetchTechniques();
    });
  }

  void _clearFields() {
    _nomProduitController.clear();
    _quantiteController.clear();
    _poidsController.clear();
    _tailleController.clear();
    _observationsController.clear();
    setState(() {
      _dateCapture = null;
      _heureCapture = null;
      _selectedPecheur = null;
      _selectedLieu = null;
      _selectedMeteo = null;
      _selectedTechnique = null;
      _selectedEtatProduit = null;
      _selectedDestination = null;
      _isEditing = false;
      _selectedCapture = null;
    });
  }

  void _showCaptureForm(BuildContext context, {Capture? capture}) {
    setState(() {
      _isEditing = capture != null;
      _selectedCapture = capture;

      if (capture != null) {
        _nomProduitController.text = capture.nomProduit;
        _quantiteController.text = capture.quantite?.toString() ?? '';
        _poidsController.text = capture.poids?.toString() ?? '';
        _tailleController.text = capture.taille?.toString() ?? '';
        _observationsController.text = capture.observations ?? '';
        _dateCapture = capture.dateCapture;
        _heureCapture = capture.heureCapture;
        _selectedPecheur = capture.idPecheur;
        _selectedLieu = capture.idLieu;
        _selectedMeteo = capture.idMeteo;
        _selectedTechnique = capture.idTechnique;
        _selectedEtatProduit = capture.etatProduit;
        _selectedDestination = capture.destination;
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
                        _isEditing ? 'Modifier Capture' : 'Ajouter Capture',
                        style: AppStyles.titleStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCaptureFormFields(context, setState),
                ],
              ),
            ),
          );
        },
      ),
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

  Widget _buildCaptureFormFields(BuildContext context, StateSetter setState) {
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
          // Nom Produit (Required)
          _buildTextField(
            controller: _nomProduitController,
            label: 'Nom du Produit *',
            icon: Icons.phishing_sharp,
          ),
          const SizedBox(height: 15),

          // Pêcheur Dropdown
          _buildPecheurDropdown(context, setState),
          const SizedBox(height: 15),

          // Lieu de Pêche Dropdown
          _buildLieuPecheDropdown(context, setState),
          const SizedBox(height: 15),

          // Date et Heure de Capture
          _buildDateCaptureField(context, setState),
          const SizedBox(height: 15),

          // Quantité, Poids, Taille
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _quantiteController,
                  label: 'Quantité',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: _poidsController,
                  label: 'Poids (kg)',
                  icon: Icons.scale,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _tailleController,
            label: 'Taille (cm)',
            icon: Icons.straighten,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 15),

          // Condition Météo Dropdown
          _buildConditionMeteoDropdown(context, setState),
          const SizedBox(height: 15),

          // Technique de Pêche Dropdown
          _buildTechniquePecheDropdown(context, setState),
          const SizedBox(height: 15),

          // État du Produit Dropdown
          _buildEtatProduitDropdown(setState),
          const SizedBox(height: 15),

          // Destination Dropdown
          _buildDestinationDropdown(setState),
          const SizedBox(height: 15),

          // Observations
          _buildTextField(
            controller: _observationsController,
            label: 'Observations',
            icon: Icons.comment,
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            style: AppStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
            ),
            onPressed: () => _saveCapture(context),
            child: Text(
              _isEditing ? 'Mettre à jour' : 'Créer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Pêcheur *',
            prefixIcon: Icon(Icons.person, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedPecheur,
          items: pecheurProvider.pecheurs.map((pecheur) {
            return DropdownMenuItem<int>(
              value: pecheur.idPecheur,
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

  Widget _buildLieuPecheDropdown(BuildContext context, StateSetter setState) {
    return Consumer<LieuPecheProvider>(
      builder: (context, lieuProvider, child) {
        if (lieuProvider.lieux.isEmpty) {
          return CircularProgressIndicator();
        }

        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Lieu de Pêche',
            prefixIcon: Icon(Icons.location_on, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedLieu,
          items: lieuProvider.lieux.map((lieu) {
            return DropdownMenuItem<int>(
              value: lieu.idLieu,
              child: Text(lieu.nom),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLieu = value;
            });
          },
        );
      },
    );
  }

  Widget _buildConditionMeteoDropdown(BuildContext context, StateSetter setState) {
    return Consumer<ConditionMeteoProvider>(
      builder: (context, meteoProvider, child) {
        if (meteoProvider.conditions.isEmpty) {
          return CircularProgressIndicator();
        }

        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Condition Météo',
            prefixIcon: Icon(Icons.wb_sunny, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedMeteo,
          items: meteoProvider.conditions.map((meteo) {
            return DropdownMenuItem<int>(
              value: meteo.idMeteo,
              child: Text(meteo.etatGeneral ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMeteo = value;
            });
          },
        );
      },
    );
  }

  Widget _buildTechniquePecheDropdown(BuildContext context, StateSetter setState) {
    return Consumer<TechniquePecheProvider>(
      builder: (context, techniqueProvider, child) {
        if (techniqueProvider.techniques.isEmpty) {
          return CircularProgressIndicator();
        }

        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Technique de Pêche',
            prefixIcon: Icon(Icons.settings, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          value: _selectedTechnique,
          items: techniqueProvider.techniques.map((technique) {
            return DropdownMenuItem<int>(
              value: technique.idTechnique,
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

  Widget _buildEtatProduitDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'État du Produit',
        prefixIcon: Icon(Icons.health_and_safety, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedEtatProduit,
      items: ['frais', 'congelé', 'transformé']
          .map((etat) => DropdownMenuItem(
        value: etat,
        child: Text(etat),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedEtatProduit = value;
        });
      },
    );
  }

  Widget _buildDestinationDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Destination',
        prefixIcon: Icon(Icons.alt_route, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedDestination,
      items: ['consommation', 'vente', 'recherche', 'autres']
          .map((destination) => DropdownMenuItem(
        value: destination,
        child: Text(destination),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedDestination = value;
        });
      },
    );
  }

  Widget _buildDateCaptureField(BuildContext context, StateSetter setState) {
    return Row(
      children: [
        // Date Field
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _dateCapture ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null && picked != _dateCapture) {
                setState(() {
                  _dateCapture = picked;
                });
              }
            },
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Date de Capture',
                  prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                  hintText: _dateCapture != null
                      ? DateFormat('dd/MM/yyyy').format(_dateCapture!)
                      : 'Sélectionner une date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: TextEditingController(
                  text: _dateCapture != null
                      ? DateFormat('dd/MM/yyyy').format(_dateCapture!)
                      : '',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Time Field
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _heureCapture != null
                    ? TimeOfDay.fromDateTime(DateFormat.Hm().parse(_heureCapture!))
                    : TimeOfDay.now(),
              );
              if (picked != null) {
                setState(() {
                  _heureCapture = picked.format(context);
                });
              }
            },
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Heure',
                  prefixIcon: Icon(Icons.access_time, color: AppColors.primary),
                  hintText: _heureCapture ?? 'Sélectionner l\'heure',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                controller: TextEditingController(
                  text: _heureCapture ?? '',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Capture> _filterCaptures(List<Capture> captures) {
    return captures.where((capture) {
      // Filter by date range
      if (_startDate != null && _endDate != null) {
        if (capture.dateCapture == null ||
            capture.dateCapture!.isBefore(_startDate!) ||
            capture.dateCapture!.isAfter(_endDate!)) {
          return false;
        }
      }

      // Filter by lieux (fishing locations)
      if (_selectedLieux.isNotEmpty) {
        if (capture.idLieu == null || !_selectedLieux.contains(capture.idLieu)) {
          return false;
        }
      }

      // Filter by destinations
      if (_selectedDestinations.isNotEmpty) {
        if (capture.destination == null ||
            !_selectedDestinations.contains(capture.destination)) {
          return false;
        }
      }

      // Filter by techniques
      if (_selectedTechniques.isNotEmpty) {
        if (capture.idTechnique == null ||
            !_selectedTechniques.contains(capture.idTechnique)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filtrer les Captures',
                style: AppStyles.titleStyle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Date Range Filter
              _buildDateRangeFilter(setState),
              const SizedBox(height: 15),

              // Lieux (Fishing Locations) Filter
              _buildLieuxFilter(setState),
              const SizedBox(height: 15),

              // Destinations Filter
              _buildDestinationFilter(setState),
              const SizedBox(height: 15),

              // Techniques Filter
              _buildTechniquesFilter(setState),
              const SizedBox(height: 20),

              // Apply and Reset Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _startDate = null;
                          _endDate = null;
                          _selectedLieux.clear();
                          _selectedDestinations.clear();
                          _selectedTechniques.clear();
                        });
                        this.setState(() {});
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: AppStyles.primaryButtonStyle,
                      onPressed: () {
                        Navigator.pop(context);
                        this.setState(() {});
                      },
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeFilter(StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Période de Capture',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date de début',
                      hintText: _startDate != null
                          ? DateFormat('dd/MM/yyyy').format(_startDate!)
                          : 'Début',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _endDate = picked;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Date de fin',
                      hintText: _endDate != null
                          ? DateFormat('dd/MM/yyyy').format(_endDate!)
                          : 'Fin',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLieuxFilter(StateSetter setState) {
    return Consumer<LieuPecheProvider>(
      builder: (context, lieuProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lieux de Pêche',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Wrap(
              spacing: 8,
              children: lieuProvider.lieux.map((lieu) {
                final isSelected = _selectedLieux.contains(lieu.idLieu);
                return ChoiceChip(
                  label: Text(lieu.nom),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedLieux.add(lieu.idLieu!);
                      } else {
                        _selectedLieux.remove(lieu.idLieu);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDestinationFilter(StateSetter setState) {
    final destinations = ['consommation', 'vente', 'recherche', 'autres'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destinations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Wrap(
          spacing: 8,
          children: destinations.map((destination) {
            final isSelected = _selectedDestinations.contains(destination);
            return ChoiceChip(
              label: Text(destination),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedDestinations.add(destination);
                  } else {
                    _selectedDestinations.remove(destination);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTechniquesFilter(StateSetter setState) {
    return Consumer<TechniquePecheProvider>(
      builder: (context, techniqueProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Techniques de Pêche'),
            Wrap(
              children: techniqueProvider.techniques.map((technique) {
                final isSelected = _selectedTechniques.contains(technique.idTechnique);
                return ChoiceChip(
                  label: Text(technique.nom), // Display technique name
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedTechniques.add(technique.idTechnique!);
                      } else {
                        _selectedTechniques.remove(technique.idTechnique);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }



// Method to save the capture
  Future<void> _saveCapture(BuildContext context) async {
    final provider = context.read<CaptureProvider>();

    if (_nomProduitController.text.isEmpty) {
      _showErrorSnackBar('Le nom du produit est obligatoire');
      return;
    }

    if (_selectedPecheur == null) {
      _showErrorSnackBar('Un pêcheur doit être sélectionné');
      return;
    }

    final capture = Capture(
      idCapture: _isEditing ? _selectedCapture?.idCapture : null,
      nomProduit: _nomProduitController.text,
      idPecheur: _selectedPecheur,
      idLieu: _selectedLieu,
      idMeteo: _selectedMeteo,
      idTechnique: _selectedTechnique,
      quantite: _quantiteController.text.isNotEmpty
          ? double.tryParse(_quantiteController.text)
          : null,
      poids: _poidsController.text.isNotEmpty
          ? double.tryParse(_poidsController.text)
          : null,
      taille: _tailleController.text.isNotEmpty
          ? double.tryParse(_tailleController.text)
          : null,
      dateCapture: _dateCapture,
      heureCapture: _heureCapture,
      etatProduit: _selectedEtatProduit,
      destination: _selectedDestination,
      observations: _observationsController.text.isNotEmpty
          ? _observationsController.text
          : null,
    );

    _isEditing
        ? provider.modifierCapture(capture)
        : provider.ajouterCapture(capture);

    Navigator.pop(context);
    _clearFields();
    _showSuccessSnackBar(_isEditing ? 'Capture mise à jour' : 'Capture ajoutée');
  }

// Success SnackBar method
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }

// Error SnackBar method
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

// Confirm Delete method
  void _confirmDelete(BuildContext context, Capture capture) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(color: AppColors.primary),
        ),
        content: Text('Voulez-vous vraiment supprimer la capture de ${capture.nomProduit}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<CaptureProvider>()
                  .supprimerCapture(capture.idCapture!)
                  .then((_) {
                Navigator.pop(context);
                _showSuccessSnackBar('Capture supprimée');
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
    _nomProduitController.dispose();
    _quantiteController.dispose();
    _poidsController.dispose();
    _tailleController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  DateTime? _startDate;
  DateTime? _endDate;
  List<int> _selectedLieux = [];
  List<String> _selectedDestinations = [];
  List<int> _selectedTechniques = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Gestion des Captures'),
        titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.primary),
            onPressed: () => _showFilterOptions(context),
          ),
        ],
      ),
      body: Consumer<CaptureProvider>(
        builder: (context, provider, child) {
          final captures = _filterCaptures(provider.captures);

          if (captures.isEmpty) {
            return _buildEmptyState();
          }

          return _buildCaptureList(captures);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCaptureForm(context),
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
            Icons.bubble_chart_outlined,
            size: 100,
            color: AppColors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'Aucune capture trouvée',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureList(List<Capture> captures) {
    return ListView.builder(
      itemCount: captures.length,
      itemBuilder: (context, index) {
        final capture = captures[index];
        return _buildCaptureCard(capture);
      },
    );
  }

  Widget _buildCaptureCard(Capture capture) {
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
            capture.nomProduit[0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          capture.nomProduit,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          capture.dateCapture != null
              ? DateFormat('dd/MM/yyyy').format(capture.dateCapture!)
              : 'Date non renseignée',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showCaptureForm(context, capture: capture),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, capture),
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
                  icon: Icons.person,
                  label: 'Pêcheur',
                  value: _getPecheurName(capture.idPecheur),
                ),
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Lieu de Pêche',
                  value: _getLieuPecheName(capture.idLieu),
                ),
                _buildDetailRow(
                  icon: Icons.wb_sunny,
                  label: 'Condition Météo',
                  value: _getConditionMeteoEtat(capture.idMeteo)!,
                ),
                _buildDetailRow(
                  icon: Icons.settings,
                  label: 'Technique de Pêche',
                  value: _getTechniquePecheName(capture.idTechnique),
                ),
                _buildDetailRow(
                  icon: Icons.numbers,
                  label: 'Quantité',
                  value: capture.quantite?.toString() ?? 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.scale,
                  label: 'Poids (kg)',
                  value: capture.poids?.toString() ?? 'Non renseigné',
                ),
                _buildDetailRow(
                  icon: Icons.straighten,
                  label: 'Taille (cm)',
                  value: capture.taille?.toString() ?? 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Heure de Capture',
                  value: capture.heureCapture ?? 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.health_and_safety,
                  label: 'État du Produit',
                  value: capture.etatProduit ?? 'Non renseigné',
                ),
                _buildDetailRow(
                  icon: Icons.alt_route,
                  label: 'Destination',
                  value: capture.destination ?? 'Non renseignée',
                ),
                _buildDetailRow(
                  icon: Icons.comment,
                  label: 'Observations',
                  value: capture.observations ?? 'Aucune',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Helper methods to get related names/descriptions
  String _getPecheurName(int? idPecheur) {
    final pecheurProvider = context.read<PecheurProvider>();
    final pecheur = pecheurProvider.pecheurs.firstWhere(
          (p) => p.idPecheur == idPecheur,
      orElse: () => Pecheur(nom: 'Non renseigné', prenom: ''),
    );
    return '${pecheur.nom} ${pecheur.prenom ?? ''}';
  }

  String _getLieuPecheName(int? idLieu) {
    final lieuProvider = context.read<LieuPecheProvider>();
    final lieu = lieuProvider.lieux.firstWhere(
          (l) => l.idLieu == idLieu,
      orElse: () => LieuPeche(nom: 'Non renseigné'),
    );
    return lieu.nom;
  }

  String? _getConditionMeteoEtat(int? idMeteo) {
    final meteoProvider = context.read<ConditionMeteoProvider>();
    final meteo = meteoProvider.conditions.firstWhere(
          (m) => m.idMeteo == idMeteo,
      orElse: () => ConditionMeteo(etatGeneral: 'Non renseignée'),
    );
    return meteo.etatGeneral;
  }

  String _getTechniquePecheName(int? idTechnique) {
    final techniqueProvider = context.read<TechniquePecheProvider>();
    final technique = techniqueProvider.techniques.firstWhere(
          (t) => t.idTechnique == idTechnique,
      orElse: () => TechniquePeche(nom: 'Non renseignée'),
    );
    return technique.nom;
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