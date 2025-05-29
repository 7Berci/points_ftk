import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:points_ftk/auth_folder/auth_page.dart';
import 'package:points_ftk/auth_folder/utils.dart';
import 'package:points_ftk/themes.dart';

//le void main
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: "points-ftk",
        options: const FirebaseOptions(
          apiKey: "AIzaSyCvDdkEw07faIC97CQWs3GtFM6pblIaiGY",
          authDomain: "points-ftk.firebaseapp.com",
          storageBucket: "points-ftk.appspot.com",
          appId: "1:842557104070:android:0d007c7a5bfd234213dcc7",
          messagingSenderId: "842557104070",
          projectId: "points-ftk",
        ),
      );
    }
    //await Firebase.initializeApp();
    runApp(MyApp());
    configLoading();
  } catch (e) {
    print("Erreur d'initialisation Firebase: $e");
    // Vous pourriez vouloir exécuter une version sans Firebase en cas d'échec
    // runApp(MyAppWithoutFirebase());
  }
}

// //le void main
// Future<void> main() async {
//   runApp(MyApp());
// }

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue
    ..userInteractions = true
    ..dismissOnTap = false;
}

final navigatorKey = GlobalKey<NavigatorState>();

//Stateless du MaterialApp
// ignore: must_be_immutable
class MyApp extends StatelessWidget {

 MyApp({super.key});
  static const String title = "Points FTK";
  Utils utilsInstance = Utils();

  @override
  Widget build(BuildContext context) => ThemeProvider(
        initTheme: MyThemes.lightTheme,
        child: Builder(
          builder: (context) => MaterialApp(
            scaffoldMessengerKey: utilsInstance.messengerKey,
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: MyThemes.lightTheme,
            title: title,
            home: AuthPage(),
            builder: EasyLoading.init(),
          ),
        ),
      );
}

// // ignore: must_be_immutable
// class MyApp extends StatelessWidget {

//  MyApp({super.key});
//   static const String title = "Points FTK";
//   Utils utilsInstance = Utils();

//   @override
//   Widget build(BuildContext context) => ThemeProvider(
//         initTheme: MyThemes.lightTheme,
//         child: Builder(
//           builder: (context) => MaterialApp(
//             title: title,
//             home: AuthPage(),
//           ),
//         ),
//       );
// }