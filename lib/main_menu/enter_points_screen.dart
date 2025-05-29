import 'package:points_ftk/enter_points_pages/type_impression_screen.dart';
import 'package:points_ftk/enter_points_pages/type_pressing_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class EnterScreen extends StatefulWidget {
  const EnterScreen({super.key});

  @override
  EnterPointView createState() => EnterPointView();
}

class EnterPointView extends State<EnterScreen> {

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 29.0),
            Text("Entrer le point du ${now.day}/${now.month}/${now.year} pour la catégorie :",
              style:TextStyle(
                fontSize: 37,
                fontWeight: FontWeight.bold,
                  ),
                ),
            SizedBox(height: 65.0),
            TypingSections(),
          ],
        ),
      ),
    );
  }
}

class TypingSections extends StatelessWidget {
  const TypingSections({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (builder) => const TypePrint()));
              },
              child: Row(children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Impression',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 31.0,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => const TypePrint()));
                  },
                  icon: const Icon(Icons.add_box_rounded),
                )
              ]),
            ),
            const Divider(),
            SizedBox(height: 87.0),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (builder) => const TypePressing()));
              },
              child: Row(children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Pressing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 31.0,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (builder) => const TypePressing()));
                  },
                  icon: const Icon(Icons.add_box_rounded),
                )
              ]),
            ),
            const Divider(),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }
}

int number = 0;

Widget myDialog() {
  return const AlertDialog();
}

Widget showPictures(
  String image,
) {
  return Container(
    width: 40.0,
    height: 40.0,
    decoration: BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Center(
      child: Container(
        width: 38.0,
        height: 38.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.scaleDown,
            image: AssetImage(image),
          ),
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
    ),
  );
}
