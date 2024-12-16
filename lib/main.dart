import 'package:flutter/material.dart';
import 'package:peche/provider/categoriePecheurProvider.dart';
import 'package:peche/provider/conditionMeteoProvider.dart';
import 'package:peche/provider/lieuPecheProvider.dart';
import 'package:peche/provider/pecheurProvider.dart';
import 'package:peche/provider/pecheurTechniqueProvider.dart';
import 'package:peche/provider/techniquePecheProvider.dart';
import 'package:peche/provider/utilisateurProvider.dart';
import 'package:provider/provider.dart';
import './routes/app_routes.dart';
import './utils/app_colors.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UtilisateurProvider()),
        ChangeNotifierProvider(create: (context) => PecheurProvider()),
        ChangeNotifierProvider(create: (context) => CategoriePecheurProvider()),
        ChangeNotifierProvider(create: (context) => TechniquePecheProvider()),
        ChangeNotifierProvider(create: (context) => LieuPecheProvider()),
        ChangeNotifierProvider(create: (context) => PecheurTechniqueProvider()),
        ChangeNotifierProvider(create: (context) => ConditionMeteoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion de Pêche',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}