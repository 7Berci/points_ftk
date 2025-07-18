import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:points_ftk/auth_folder/utils.dart';
import 'package:points_ftk/database.dart';
import 'package:points_ftk/enter_points_pages/type_impression_products.dart';
import 'package:points_ftk/main_menu/main_menu.dart';
class TypeTransfertSpace extends StatefulWidget {
  const TypeTransfertSpace({super.key});
  
  @override
  State<TypeTransfertSpace> createState() => _TypeTransfertSpaceState();
}

class _TypeTransfertSpaceState extends State<TypeTransfertSpace> {
  Utils utilsWidget = Utils();
  String takeSoldeMTN = '';
  String takeCommiMTN = '';
  String takeSoldeMoov = '';
  String takeCommiMoov = '';
  String takeSoldeOrange = '';
  String takeCommiOrange = '';
  String takeSortie = '';
  String takeCaisse = '';
  String takeObservation = '';
  DatabaseService database = DatabaseService(uid: userr.uid);
  late final TextEditingController soldeMTNController;
  late final TextEditingController commiMTNController;
  late final TextEditingController soldeMoovController;
  late final TextEditingController commiMoovController;
  late final TextEditingController soldeOrangeController;
  late final TextEditingController commiOrangeController;
  late final TextEditingController sortieController;
  late final TextEditingController caisseController;
  late final TextEditingController observationController;
  Timer? _timer;
  double totalSolde = 0;
  double totalCommission = 0;
  late DateTime now;
  late Timer timer;

  @override
  void initState() {

    soldeMTNController = TextEditingController(text: takeSoldeMTN);
    commiMTNController = TextEditingController(text: takeCommiMTN);
    soldeMoovController = TextEditingController(text: takeSoldeMoov);
    commiMoovController = TextEditingController(text: takeCommiMoov);
    soldeOrangeController = TextEditingController(text: takeSoldeOrange);
    commiOrangeController = TextEditingController(text: takeCommiOrange);
    sortieController = TextEditingController(text: takeSortie);
    caisseController = TextEditingController(text: takeCaisse);
    observationController = TextEditingController(text: takeObservation);

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
    Future sendTransfertPoint() async {
      _timer?.cancel();
      await EasyLoading.show(
        status: 'loading...',
        maskType: EasyLoadingMaskType.black,
      );
      // ignore: avoid_print
      print('EasyLoading show');
      await saveTransfertPoint(
      soldeMTN: soldeMTNController.text,
      commissionMTN: commiMTNController.text,
      soldeMoov: soldeMoovController.text,
      commissionMoov:commiMoovController.text,
      soldeOrange: soldeOrangeController.text,
      commissionOrange:commiOrangeController.text,
      montantSortie: sortieController.text,
      soldeCaisse: caisseController.text,
      observation: observationController.text,
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

    double parse(String text) => double.tryParse(text) ?? 0;

    void updateTotals() {
      setState(() {
        totalSolde = parse(soldeMTNController.text) + 
                      parse(soldeMoovController.text) + 
                      parse(soldeOrangeController.text) + 
                      parse(caisseController.text) - 
                      parse(sortieController.text);

        totalCommission = parse(commiMTNController.text) +
                          parse(commiMoovController.text) +
                          parse(commiOrangeController.text);
      });
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

            // Champ de texte pour le montant er l'observation
            Center(
              child: Column(
              children: [
                const SizedBox(height: 26.5),
                Column(
                  children: [
                    const Text("ORANGE TRANSFERT",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            onChanged: (index) {
                              takeSoldeOrange = index;
                              updateTotals();
                            },
                            controller: soldeOrangeController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Solde Orange'),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            onChanged: (index) {
                              takeCommiOrange = index;
                              updateTotals();
                            },
                            controller: commiOrangeController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Commission Orange'),
                          ),
                        ),
                      ],
                      )
                  ],
                ),
                const SizedBox(height: 18),
                
                Column(
                  children: [
                    const Text("MTN MONEY",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            onChanged: (index) {
                              takeSoldeMTN = index;
                              updateTotals();
                            },
                            controller: soldeMTNController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Solde MTN'),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            onChanged: (index) {
                              takeCommiMTN = index;
                              updateTotals();
                            },
                            controller: commiMTNController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Commission MTN'),
                          ),
                        ),
                      ],
                      )
                  ],
                ),
                const SizedBox(height: 18),
                Column(
                  children: [
                    const Text("MOOV MONEY",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            onChanged: (index) {
                              takeSoldeMoov = index;
                              updateTotals();
                            },
                            controller: soldeMoovController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Solde MOOV'),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            onChanged: (index) {
                              takeCommiMoov = index;
                              updateTotals();
                            },
                            controller: commiMoovController,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.number,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                labelText: 'Commission MOOV'),
                          ),
                        ),
                      ],
                      )
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  "Quel est le solde de la caisse ?",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  onChanged: (index) {
                            takeCaisse = index;
                            updateTotals();
                          },
                  controller: caisseController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Solde caisse'),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Y'a t-il eu une sortie ?",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  onChanged: (index) {
                            takeSortie = index;
                            updateTotals();
                          },
                  controller: sortieController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: 'Sortie (dépense)'),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Une observation ?",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  onChanged: (index2) {
                            takeObservation = index2;
                            updateTotals();
                          },
                  controller: observationController,
                  maxLines: 5,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelText: "Observation (mets surtout l'obersvation de la sortie)"),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text("TOTAL : ",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),),
                    Text("$totalSolde FCFA",
                      style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text("SOLDE TOTAL COMMISSION : ",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),),
                    Text("$totalCommission FCFA",
                      style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 40),
                MaterialButton(
                  onPressed: sendTransfertPoint,
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