import 'package:points_ftk/enter_points_pages/type_impression_screen.dart';
import 'package:points_ftk/enter_points_pages/type_pressing_screen.dart';
import 'package:flutter/material.dart';
import 'package:points_ftk/enter_points_pages/type_shop_screen.dart';
import 'dart:async';

import 'package:points_ftk/enter_points_pages/type_transfert_screen.dart';

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
            Text(
              "Entrer le point du ${now.day}/${now.month}/${now.year} pour la catégorie :",
              style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TypePressing(),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 130,
                    height: 130,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons
                              .local_laundry_service, // icône de santé / pression
                          size: 50,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'PRESSING',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TypePrint()),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 130,
                    height: 130,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.description, // icône de balance
                          size: 50,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'IMPRESSION',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TypeShop()),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 130,
                    height: 130,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.shopping_cart, // icône de santé / pression
                          size: 50,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'SHOP FTK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TypeTransfert(),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 130,
                    height: 130,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.currency_exchange, // icône de balance
                          size: 50,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'TRANSFERT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

int number = 0;

Widget myDialog() {
  return const AlertDialog();
}

Widget showPictures(String image) {
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
