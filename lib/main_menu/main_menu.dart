import 'package:points_ftk/main_menu/daily_pressing_screen.dart';
import 'package:points_ftk/main_menu/daily_print_screen.dart';
import 'package:points_ftk/main_menu/daily_shop_screen.dart';
import 'package:points_ftk/main_menu/daily_transfert_screen.dart';
import 'package:points_ftk/main_menu/enter_points_screen.dart';
import 'dart:async';
import 'package:points_ftk/main_menu/the_navigation_drawer.dart';
import 'package:flutter/material.dart';

Color eclatColor = const Color(0xFF5ACC80);

class MainMenu extends StatefulWidget {
  //final VoidCallback onLogout;

  //const MainMenu({super.key, required this.onLogout});
  const MainMenu({super.key});

  @override
  MainMenuView createState() => MainMenuView();
}

class MainMenuView extends State<MainMenu> {
  int index = 0;

  final screens = const [
    EnterScreen(),
    DailyPressingScreen(),
    DailyPrintScreen(),
    DailyTransfertScreen(),
    DailyShopScreen(),
  ];

  late DateTime now;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: eclatColor,
        title: const Center(child: Text('POINTS FTK')),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Text(
              "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),

      body: screens[index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.green,
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
          ),
        ),

        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() => this.index = index),
          height: 60.0,
          backgroundColor:
              // userr.isDarkMode ? Colors.grey.shade900 : Colors.white,
              Colors.white,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.edit_note), label: 'Entrer'),
            NavigationDestination(
              icon: Icon(Icons.local_laundry_service),
              label: 'Pressing',
            ),
            NavigationDestination(
              icon: Icon(Icons.description),
              label: 'Printing',
            ),
            NavigationDestination(
              icon: Icon(Icons.transfer_within_a_station),
              label: 'Transfert',
            ),
            NavigationDestination(icon: Icon(Icons.shop), label: 'Shop'),
          ],
        ),
      ),
    );
  }
}
