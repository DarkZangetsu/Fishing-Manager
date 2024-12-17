import 'package:flutter/material.dart';
import 'package:peche/provider/captureProvider.dart';
import 'package:peche/provider/categoriePecheurProvider.dart';
import 'package:peche/provider/conditionMeteoProvider.dart';
import 'package:peche/provider/dashboardProvider.dart';
import 'package:peche/provider/lieuPecheProvider.dart';
import 'package:peche/provider/pecheurProvider.dart';
import 'package:peche/provider/pecheurTechniqueProvider.dart';
import 'package:peche/provider/statistiqueProvider.dart';
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
        ChangeNotifierProvider(create: (context) => CaptureProvider()),
        ChangeNotifierProvider(create: (context) => StatistiquesProvider()),
        ChangeNotifierProvider(create: (context) => DashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      home: SplashScreen(),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Restaurer la session
    final utilisateurProvider = Provider.of<UtilisateurProvider>(context, listen: false);
    utilisateurProvider.restaurerSession();

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ic_launcher.png',
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Fishing Manager',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Votre compagnon de pêche ultime',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}