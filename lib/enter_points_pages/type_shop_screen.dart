import 'package:flutter/material.dart';
import 'package:points_ftk/enter_points_pages/type_shop_products.dart';

class TypeShop extends StatefulWidget {
  const TypeShop({super.key});

  @override
  State<TypeShop> createState() => _TypeShopState();
}

class _TypeShopState extends State<TypeShop> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Point du shop")),
        backgroundColor: const Color(0xFF5ACC80),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        height: 900,
        child: Column(
          children: [TypeShoppingSpace(), const SizedBox(height: 10)],
        ),
      ),
    );
  }
}
