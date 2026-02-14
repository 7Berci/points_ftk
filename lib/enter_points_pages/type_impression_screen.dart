import 'package:flutter/material.dart';
import 'package:points_ftk/enter_points_pages/type_impression_products.dart';

class TypePrint extends StatefulWidget {
  const TypePrint({super.key});

  @override
  State<TypePrint> createState() => _TypePrintState();
}

class _TypePrintState extends State<TypePrint> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Point d'impression")),
        backgroundColor: const Color(0xFF5ACC80),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        height: 900,
        child: Column(
          children: [TypePrintingSpace(), const SizedBox(height: 10)],
        ),
      ),
    );
  }
}
