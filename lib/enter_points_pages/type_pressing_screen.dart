import 'package:flutter/material.dart';
import 'package:points_ftk/enter_points_pages/type_pressing_products.dart';
import 'package:points_ftk/main_menu/main_menu.dart';

class TypePressing extends StatefulWidget {
  const TypePressing({super.key});

  @override
  State<TypePressing> createState() => _TypePressing();
}

class _TypePressing extends State<TypePressing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Point pressing :"),
          ),
          backgroundColor: const Color(0xFF5ACC80),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          height: 900,
          child: Column(
            children: [
              TypePressingSpace(),
              const SizedBox(
                height: 10,
              ),
            ],
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
