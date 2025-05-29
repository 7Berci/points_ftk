import 'package:points_ftk/main_menu/main_menu.dart';
import 'utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class LoginWidget extends StatefulWidget {
  //final VoidCallback onClickedSignUp;

  const LoginWidget({
    super.key,
    //required this.onClickedSignUp,
  });

  @override
  LoginWidgetState createState() => LoginWidgetState();
}

class LoginWidgetState extends State<LoginWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Utils utilsWidget = Utils();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

Future signIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushReplacement(
          MaterialPageRoute(builder: (_) => MainMenu()),
        );
      } else {
        // Fallback navigation using local context
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainMenu()),
        );
        
        // OR alternative handling:
        debugPrint('NavigatorState is null - check MaterialApp configuration');
        utilsWidget.showSnackBar('Navigation error - please restart app');}
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      print(e);
      utilsWidget.showSnackBar(e.message);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const SizedBox(height: 20),
              const Text(
                "Bon retour !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                // cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: passwordController,
                // cursorColor: Colors.white,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.lock_open, size: 32),
                label: const Text(
                  "Se connecter",
                  style: TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 90),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (builder) => const LoginAdmin()));
                },
                child: const Text(
                  '',
                ),
              ),
            ],
          ),
        ),
      );
}

void showLoginAdmin() {
  // if (1 == 1) {
  const SnackBar(
    content: LoginAdmin(),
    backgroundColor: Colors.white,
  );
  // } else {}
}

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({
    super.key,
  });

  @override
  LoginAdminState createState() => LoginAdminState();
}

class LoginAdminState extends State<LoginAdmin> {
  String takeValue = '';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Utils utilsWidget = Utils();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  bool activeButton = true;
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 190.0),
              TextFormField(
                controller: emailController,
                // cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  takeValue = value;
                  setState(() {});
                },
                validator: (String? value) {
                  if (value != "eliel08@hotmail.fr ") {
                    //if (value == null || value.isEmpty) {
                    return 'Etes-vous un admin ?';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4.0),
              TextFormField(
                controller: passwordController,
                // cursorColor: Colors.white,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton.icon(
                onPressed:
                    takeValue != "eliel08@hotmail.fr " ? null : signInAdmin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50.0),
                ),
                icon: const Icon(Icons.lock_open, size: 32.0),
                label: const Text(
                  "Se connecter",
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      );

  Future signInAdmin() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);

      utilsWidget.showSnackBar(e.message);
    }
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (builder) => const MainMenu()));
  }

}