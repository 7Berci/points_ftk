import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:points_ftk/auth_folder/utils.dart';
import 'package:points_ftk/database.dart';
import 'package:points_ftk/enter_points_pages/type_impression_products.dart';
import 'package:points_ftk/main_menu/main_menu.dart';
class TypePressingSpace extends StatefulWidget {
  const TypePressingSpace({super.key});
  
  @override
  State<TypePressingSpace> createState() => _TypePressingSpaceState();
}

class _TypePressingSpaceState extends State<TypePressingSpace> {
  Utils utilsWidget = Utils();
  String typePoint = 'Entrée'; // valeur par défaut
  String takenumber = '';
  String takelocation = '';
  DatabaseService database = DatabaseService(uid: userr.uid);
  late final TextEditingController amountController;
  late final TextEditingController observationController;
  Timer? _timer;

  late DateTime now;
  late Timer timer;

  @override
  void initState() {

    amountController = TextEditingController(text: takenumber);
    observationController = TextEditingController(text: takelocation);

    EasyLoading.addStatusCallback((status) {
      // ignore: avoid_print
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });

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
    Future sendPressingPoint() async {
      _timer?.cancel();
      await EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
      );
      // ignore: avoid_print
      print('EasyLoading show');
      await savePrintandPressingPoint(
      collectionName: 'points_pressing',
      userEmail: userr.email!,
      montant: amountController.text,
      observation: observationController.text,
      type: typePoint,
    );
      _timer?.cancel();
      await EasyLoading.dismiss();
      // ignore: avoid_print
      print('EasyLoading dismiss');
      //Navigator.of(context).pop;
      // ignore: use_build_context_synchronously
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (builder) => MainMenu()));
    }

    void goToShopPageBis() {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (builder) => const MainMenu()));
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 18),
            Row(
              children: [
              Text("Point du ",
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                ),),
              Text("${now.day}/${now.month}/${now.year}",
                style: TextStyle(
                  fontSize: 16.5,
                ),),],),
            const SizedBox(height: 18),
             Row(
              children: [
                Text("Heure du point : ",
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    fontSize: 16.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Text("Point effectué par : ",
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),),
                UserName(),
            ],),
            const SizedBox(height: 18),

            //Choix double entrée ou sortie
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'Entrée',
                      groupValue: typePoint,
                      onChanged: (value) {
                        setState(() {
                          typePoint = value!;
                        });
                      },
                    ),
                    const Text('Entrée'),
                  ],
                ),
                const SizedBox(width: 30),
                Row(
                  children: [
                    Radio<String>(
                      value: 'Sortie',
                      groupValue: typePoint,
                      onChanged: (value) {
                        setState(() {
                          typePoint = value!;
                        });
                      },
                    ),
                    const Text('Sortie'),
                  ],
                ),
              ],
            ),

            // Champ de texte pour le montant er l'observation
            Center(
              child: Column(
              children: [
                const SizedBox(height: 26.5),
                TextFormField(
                  onChanged: (index) => takenumber = index,
                  controller: amountController,
                  // cursorColor: Colors.white,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  // validator: (value) => value != null && value.length < 10
                  //     ? 'Entrez au moins 10 caractères'
                  //     : null,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Combien ? (montant du point)'),
                ),
                const SizedBox(height: 18),
                TextField(
                  onChanged: (index2) => takelocation = index2,
                  controller: observationController,
                  // cursorColor: Colors.white,
                  //textInputAction: TextInputAction.next,
                  maxLines: 5,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Observation'),
                ),
                const SizedBox(height: 40),
                MaterialButton(
                  onPressed: sendPressingPoint,
                  // onPressed: () => Get.to(() => CartScreen()),
                  color: Colors.yellow,
                  height: 55.0,
                  child: const Text(
                    "ENREGISTRER LE POINT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                RichText(
                    text: TextSpan(
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  text: 'Ou annuler et revenir à la   ',
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()..onTap = goToShopPageBis,
                      text: "page d'accueil",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                )),
              ],
            ),
        ),
          ],
        ));
  }
  
}