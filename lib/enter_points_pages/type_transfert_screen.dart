import 'package:flutter/material.dart';
import 'package:points_ftk/enter_points_pages/type_transfert_products.dart';
import 'package:points_ftk/main_menu/main_menu.dart';

class TypeTransfert extends StatefulWidget {
  const TypeTransfert({super.key});

  @override
  State<TypeTransfert> createState() => _TypeTransfert();
}

class _TypeTransfert extends State<TypeTransfert> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Point transfert :"),
          ),
          backgroundColor: const Color(0xFF5ACC80),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              children: [
                TypeTransfertSpace(),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> navigateToNextPage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainMenu()),
    );
  }
}
