import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/utilisateurProvider.dart';
import '../../models/Utilisateur.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_style.dart';

class UserManagementView extends StatefulWidget {
  const UserManagementView({Key? key}) : super(key: key);

  @override
  _UserManagementViewState createState() => _UserManagementViewState();
}

class _UserManagementViewState extends State<UserManagementView> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.utilisateur;
  bool _isEditing = false;
  Utilisateur? _selectedUser;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UtilisateurProvider>(context, listen: false).chargerUtilisateurs();
    });
  }

  void _clearFields() {
    _nomController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _isEditing = false;
      _selectedUser = null;
      _selectedRole = UserRole.utilisateur;
      _obscurePassword = true;
    });
  }

  void _showUserForm(BuildContext context, {Utilisateur? user}) {
    setState(() {
      _isEditing = user != null;
      _selectedUser = user;
      _obscurePassword = true;

      if (user != null) {
        _nomController.text = user.nomUtilisateur;
        _emailController.text = user.email;
        _selectedRole = user.role;
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
                        _isEditing ? 'Modifier Utilisateur' : 'Ajouter Utilisateur',
                        style: AppStyles.titleStyle.copyWith(fontSize: 20),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildUserFormFields(context, setState),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserFormFields(BuildContext context, StateSetter setState) {
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
            label: 'Nom d\'utilisateur',
            icon: Icons.person,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildPasswordTextField(context, setState),
          const SizedBox(height: 15),
          _buildRoleDropdown(setState),
          const SizedBox(height: 20),
          ElevatedButton(
            style: AppStyles.primaryButtonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(AppColors.primary),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
            ),
            onPressed: () => _saveUser(context),
            child: Text(
              _isEditing ? 'Mettre à jour' : 'Créer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTextField(BuildContext context, StateSetter setState) {
    return TextField(
      controller: _passwordController,
      keyboardType: TextInputType.text,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: _isEditing ? 'Nouveau mot de passe (optionnel)' : 'Mot de passe',
        prefixIcon: Icon(Icons.lock, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: AppColors.primary,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
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

  Widget _buildRoleDropdown(StateSetter setState) {
    return DropdownButtonFormField<UserRole>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Rôle',
        prefixIcon: Icon(Icons.security, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        ),
      ),
      items: UserRole.values.map((UserRole role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Text(
            role == UserRole.admin ? 'Administrateur' : 'Utilisateur',
            style: TextStyle(color: AppColors.primary),
          ),
        );
      }).toList(),
      onChanged: (UserRole? newValue) {
        setState(() {
          _selectedRole = newValue!;
        });
      },
    );
  }

  void _saveUser(BuildContext context) {
    final provider = Provider.of<UtilisateurProvider>(context, listen: false);

    if (_isEditing) {
      _updateExistingUser(provider);
    } else {
      _createNewUser(provider);
    }
  }

  void _updateExistingUser(UtilisateurProvider provider) {
    final updatedUser = _selectedUser!.copyWith(
      nomUtilisateur: _nomController.text,
      email: _emailController.text,
      role: _selectedRole,
      motDePasse: _passwordController.text, // Conditionally handled in provider
    );

    provider.modifierUtilisateur(updatedUser).then((success) {
      if (success) {
        Navigator.pop(context);
        _clearFields();
        _showSuccessSnackBar('Utilisateur mis à jour');
      }
    });
  }

  void _createNewUser(UtilisateurProvider provider) {
    final newUser = Utilisateur(
      nomUtilisateur: _nomController.text,
      email: _emailController.text,
      motDePasse: _passwordController.text,
      role: _selectedRole,
    );

    provider.ajouterUtilisateur(newUser).then((success) {
      if (success) {
        Navigator.pop(context);
        _clearFields();
        _showSuccessSnackBar('Utilisateur ajouté');
      }
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

  void _confirmDelete(BuildContext context, Utilisateur user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirmer la suppression',
          style: TextStyle(color: AppColors.primary),
        ),
        content: Text('Voulez-vous vraiment supprimer l\'utilisateur ${user.nomUtilisateur} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Provider.of<UtilisateurProvider>(context, listen: false)
                  .supprimerUtilisateur(user.idUtilisateur!)
                  .then((success) {
                if (success) {
                  Navigator.pop(context);
                  _showSuccessSnackBar('Utilisateur supprimé');
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
        title: const Text('Gestion des Utilisateurs'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87
        ),
      ),
      body: Consumer<UtilisateurProvider>(
        builder: (context, provider, child) {
          final users = provider.utilisateurs;

          if (users.isEmpty) {
            return _buildEmptyState();
          }

          return _buildUserList(users);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 100,
            color: AppColors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun utilisateur trouvé',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(List<Utilisateur> users) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Utilisateur user) {
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: user.role == UserRole.admin
              ? AppColors.primary
              : AppColors.secondary,
          child: Icon(
            user.role == UserRole.admin
                ? Icons.admin_panel_settings
                : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          user.nomUtilisateur,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          user.email,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showUserForm(context, user: user),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, user),
            ),
          ],
        ),
      ),
    );
  }
}