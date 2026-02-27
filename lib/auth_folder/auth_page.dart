import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:points_ftk/main_menu/main_menu.dart';
import 'package:flutter/material.dart';
import 'package:points_ftk/firebase_options.dart';
import 'login_widget.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _firebaseInitialized = false;
  bool _initializationAttempted = false;
  Stream<User?>? _authStream;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    if (_initializationAttempted) return;

    setState(() {
      _initializationAttempted = true;
    });

    try {
      // Vérifier si Firebase est déjà initialisé
      if (Firebase.apps.isNotEmpty) {
        print("Firebase déjà initialisé");
        setState(() {
          _firebaseInitialized = true;
          _authStream = FirebaseAuth.instance.authStateChanges();
        });
        return;
      }

      print("Tentative d'initialisation Firebase...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialisé avec succès sur ${Firebase.apps.length} apps");

      setState(() {
        _firebaseInitialized = true;
        _authStream = FirebaseAuth.instance.authStateChanges();
      });
    } catch (e) {
      print("Erreur d'initialisation Firebase: $e");
      setState(() {
        _firebaseInitialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si Firebase n'est pas encore initialisé et qu'on n'a pas encore essayé
    if (!_initializationAttempted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Si Firebase n'est pas initialisé malgré la tentative
    if (!_firebaseInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Firebase non disponible',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Impossible de se connecter à Firebase.\nVérifiez votre connexion internet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeFirebase,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  // Mode hors ligne temporaire
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => MainMenu()),
                  );
                },
                child: const Text('Continuer en mode hors ligne'),
              ),
            ],
          ),
        ),
      );
    }

    // Firebase est initialisé, utiliser le StreamBuilder normal
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print("Erreur StreamBuilder: ${snapshot.error}");
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Erreur d\'authentification'),
                  const SizedBox(height: 8),
                  Text(
                    'Erreur: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AuthPage()),
                      );
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        // Si l'utilisateur est connecté, afficher le menu principal
        if (snapshot.hasData && snapshot.data != null) {
          return MainMenu();
        } else {
          // Sinon, afficher la page de connexion
          return LoginWidget();
        }
      },
    );
  }

  //void toggle() => setState(() => isLogin = !isLogin);
}
