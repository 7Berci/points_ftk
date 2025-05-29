// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:points_ftk/enter_points_pages/type_impression_products.dart';
import '../auth_folder/utils.dart';

String imagePath =
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQSyfJnaSYfgnTEhLH2AM5Q8fy1IROMZ3gvKlE6OK8&s';
String name = "";
String identification = "";
String location = "";
bool isDarkMode = false;
// late final Products product;
String imagePathProduct = 'assets/images/chemisemc.png';
String nameProduct = "??";
int quantity = 0;
String total = "??";

class DatabaseService {
  Utils utilsWidget = Utils();

  final String? uid;
  DatabaseService({required this.uid});
}

@override
  Future<void> savePrintPoint({
    required String montant,
    required String observation,
    required String type,
    // Add other fields as needed
  }) async {
    await FirebaseFirestore.instance.collection('points_impression').add({
      'uid': userr.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'montant': montant,
      'observation': observation,
    });
  }

  @override
  Future<void> savePressingPoint({
    required String montant,
    required String observation,
    required String type,
    // Add other fields as needed
  }) async {
    await FirebaseFirestore.instance.collection('points_pressing').add({
      'uid': userr.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'montant': montant,
      'observation': observation,
    });
  }