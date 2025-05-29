import 'package:firebase_auth/firebase_auth.dart';
import 'package:points_ftk/main_menu/main_menu.dart';
import 'package:flutter/material.dart';
import 'login_widget.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Si l'utilisateur est connecté, afficher le menu principal
    if (user != null) {
      return MainMenu();
    } else {
      // Sinon, afficher la page de connexion
      return LoginWidget(
        //onClickedSignUp: toggle,
      );
    }
  }
//void toggle() => setState(() => isLogin = !isLogin);
}
