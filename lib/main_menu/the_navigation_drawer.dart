import 'package:flutter/material.dart';
import 'package:points_ftk/auth_folder/auth_page.dart';
import 'package:points_ftk/auth_folder/function.dart';
import 'package:points_ftk/main_menu/main_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';

final user = FirebaseAuth.instance.currentUser;

class MyNavigationDrawer extends StatelessWidget {
  const MyNavigationDrawer({super.key});
  // final dbController = Get.put(DatabaseServiceState());

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
              buildHeader(context),
              buildMenuItems(context),
            ])),
      );
  Widget buildHeader(BuildContext context) => Material(
        color: eclatColor,
        child: InkWell(
          child: Container(
            padding: EdgeInsets.only(
              top: 24 + MediaQuery.of(context).padding.top,
              bottom: 24,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 52,
                  child: Image.asset('assets/images/profile.png'),
                ),
                Text('${user?.email }', 
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
        ),
      );
  Widget buildMenuItems(BuildContext context) => Container(
        padding: const EdgeInsets.all(24),
        child: Wrap(
          runSpacing: 16, //vertical spacing
          children: [
            const Divider(color: Colors.black12),
            ListTile(
              leading: const Icon(Icons.output_rounded),
              title: const Text('Se déconnecter'),
              onTap: () async {
                await logOut();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (builder) => const AuthPage()));
              },
            ),
          ],
        ),
      );
}
