import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:points_ftk/main_menu/archives_pressing_screen.dart';
import 'package:points_ftk/main_menu/the_navigation_drawer.dart';

class DailyTransfertScreen extends StatefulWidget {
  const DailyTransfertScreen({super.key});

  @override
  DailyTransfertScreenView createState() => DailyTransfertScreenView();
}

const List<String> moisLettre = [
  '', // pour l’index 0 (inutile)
  'Janvier',
  'Février',
  'Mars',
  'Avril',
  'Mai',
  'Juin',
  'Juillet',
  'Août',
  'Septembre',
  'Octobre',
  'Novembre',
  'Décembre',
];

class DailyTransfertScreenView extends State<DailyTransfertScreen> {
  List<Map<String, dynamic>> points = [];
  bool isLoading = true;
late DateTime date;
  late List<bool> collectedStates;

  @override
  void initState() {
    super.initState();
    date = DateTime.now();
    collectedStates = [];
    fetchPointsForMonth(date.year, date.month).then((pts) {
      setState(() {
        points = pts;
        isLoading = false;

        // Préparation des jours uniques triés
        final jours = <String>{};
        for (var p in pts) {
          final d = (p['timestamp'] as Timestamp).toDate();
          final jourStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          jours.add(jourStr);
        }

        final joursList = jours.toList()..sort();

        // ✅ collectedStates vaut true uniquement si TOUS les documents du jour ont collected == true
        collectedStates = joursList.map((jour) {
          final docsDuJour = pts.where((p) {
            final d = (p['timestamp'] as Timestamp).toDate();
            final jourStr = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
            return jourStr == jour;
          }).toList();

          return docsDuJour.isNotEmpty && docsDuJour.every((doc) => doc['collected'] == true);
        }).toList();
      });
    });
  }

  Future<void> toggleCollectedStatus(int index, String dateStr) async {
    final newStatus = !collectedStates[index];
    setState(() {
      collectedStates[index] = newStatus;
    });

    // Convertir la date string en DateTime
    final parts = dateStr.split('-');
    final day = int.parse(parts[2]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[0]);
    
    final startOfDay = DateTime(year, month, day);
    final endOfDay = DateTime(year, month, day, 23, 59, 59);

    // Mettre à jour tous les documents de cette date
    final querySnapshot = await FirebaseFirestore.instance
        .collection('points_transfert')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'collected': newStatus});
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> fetchPointsForMonth(int year, int month) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);

    final snapshot = await FirebaseFirestore.instance
        .collection('points_transfert')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Préparation des données pour le tableau
    List<Map<String, dynamic>> entrees = [];
    List<Map<String, dynamic>> sorties = [];
    final jours = <String>{};
    for (var p in points) {
      final date = (p['timestamp'] as Timestamp).toDate();
      jours.add("${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
      if (p['type'] == 'Entrée') {
        entrees.add(p);
      } else if (p['type'] == 'Sortie') {
        sorties.add(p);
      }
    }
    final joursList = jours.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: 
            Text("Points des transferts - ${moisLettre[now.month]} ${now.year}"),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF5ACC80),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30.0),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : points.isEmpty
                  ? const Center(child: Text("Aucun point enregistré ce mois-ci."))
                  : Expanded(
                    child: FutureBuilder<double>(
                        future: getReportAnterieur(now.year, now.month),
                        builder: (context, snapshot) {
                          //double report = snapshot.data ?? 0;
                          // double totalEntrees = 0;
                          // double totalSorties = 0;
                          // Map<String, double> reportParJour = {};
                              
                          // for (var jour in joursList) {
                          //   double entreeJour = entrees
                          //       .where((e) {
                          //         final date = (e['timestamp'] as Timestamp).toDate();
                          //         return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" == jour;
                          //       })
                          //       .fold(0.0, (sum, e) => sum + (double.tryParse(e['montant'].toString()) ?? 0));
                          //   double sortieJour = sorties
                          //       .where((s) {
                          //         final date = (s['timestamp'] as Timestamp).toDate();
                          //         return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" == jour;
                          //       })
                          //       .fold(0.0, (sum, s) => sum + (double.tryParse(s['montant'].toString()) ?? 0));
                          //   report += (entreeJour - sortieJour);
                          //   reportParJour[jour] = report;
                          //   totalEntrees += entreeJour;
                          //   totalSorties += sortieJour;
                          // }
                              
                          return Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('Vérifié?')),
                                        DataColumn(label: Text('Jour')),
                                        DataColumn(label: Text('Soldes')),
                                        DataColumn(label: Text('Commissions')),
                                        DataColumn(label: Text('Report à nouveau')),
                                      ],
                                      rows: joursList.toList().asMap().entries.map((entry) {
                                        final index = entry.key;
                                        final jour = entry.value;
                                        //final parts = jour.split('-');
                                        //final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                                        //final moisNom = moisLettre[date.month];
                                  
                                        // double entreeJour = entrees
                                        //     .where((e) {
                                        //       final d = (e['timestamp'] as Timestamp).toDate();
                                        //       return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == jour;
                                        //     })
                                        //     .fold(0.0, (sum, e) => sum + (double.tryParse(e['montant'].toString()) ?? 0));
                                        // double sortieJour = sorties
                                        //     .where((s) {
                                        //       final d = (s['timestamp'] as Timestamp).toDate();
                                        //       return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == jour;
                                        //     })
                                        //     .fold(0.0, (sum, s) => sum + (double.tryParse(s['montant'].toString()) ?? 0));
                                        // double reportJour = reportParJour[jour]!;
                                        return DataRow(cells: [
                                          DataCell(
                                            user?.email == 'eliel08@hotmail.fr' 
                                            ? InkWell(
                                              onTap: () => toggleCollectedStatus(index, jour),
                                              child: Icon(
                                              collectedStates[index] ? FontAwesome.check_square : FontAwesome.square_o,
                                              color: collectedStates[index] ? Colors.green : Colors.grey,
                                              size: 32,
                                            ),
                                            )
                                            : Icon(
                                              collectedStates[index] ? FontAwesome.check_square : FontAwesome.square_o,
                                              color: collectedStates[index] ? Colors.green : Colors.grey,
                                              size: 32,
                                            ),    
                                          ),
                                          DataCell(Text(jour)),
                                          /// 🧮 SOLDES + SORTIE
                                          DataCell(
                                            Builder(builder: (context) {
                                              final docsJour = points.where((p) {
                                                final d = (p['timestamp'] as Timestamp).toDate();
                                                return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == jour;
                                              }).toList();

                                              double soldeOrange = 0, soldeMTN = 0, soldeMoov = 0, soldeCaisse = 0, sortie = 0;
                                              for (var p in docsJour) {
                                                soldeOrange += double.tryParse(p['soldeOrange']?.toString() ?? '0') ?? 0;
                                                soldeMTN += double.tryParse(p['soldeMTN']?.toString() ?? '0') ?? 0;
                                                soldeMoov += double.tryParse(p['soldeMoov']?.toString() ?? '0') ?? 0;
                                                soldeCaisse += double.tryParse(p['soldeCaisse']?.toString() ?? '0') ?? 0;
                                                sortie += double.tryParse(p['montantSortie']?.toString() ?? '0') ?? 0;
                                              }

                                              return Container(
                                                constraints: BoxConstraints(minHeight: 80),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Orange: ${soldeOrange.toStringAsFixed(2)}"),
                                                    Text("MTN: ${soldeMTN.toStringAsFixed(2)}"),
                                                    Text("Moov: ${soldeMoov.toStringAsFixed(2)}"),
                                                    Text("Caisse: ${soldeCaisse.toStringAsFixed(2)}"),
                                                    Text("Sortie: ${sortie.toStringAsFixed(2)}"),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                          /// 🧮 COMMISSIONS
                                          DataCell(
                                            Builder(builder: (context) {
                                              final docsJour = points.where((p) {
                                                final d = (p['timestamp'] as Timestamp).toDate();
                                                return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == jour;
                                              }).toList();

                                              double commissionOrange = 0, commissionMTN = 0, commissionMoov = 0;
                                              for (var p in docsJour) {
                                                commissionOrange += double.tryParse(p['commissionOrange']?.toString() ?? '0') ?? 0;
                                                commissionMTN += double.tryParse(p['commissionMTN']?.toString() ?? '0') ?? 0;
                                                commissionMoov += double.tryParse(p['commissionMoov']?.toString() ?? '0') ?? 0;
                                              }

                                              return Container(
                                                constraints: BoxConstraints(minHeight: 80),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Orange: ${commissionOrange.toStringAsFixed(2)}"),
                                                    Text("MTN: ${commissionMTN.toStringAsFixed(2)}"),
                                                    Text("Moov: ${commissionMoov.toStringAsFixed(2)}"),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                          /// 🧮 TOTAUX (solde + commission)
                                          DataCell(
                                            Builder(builder: (context) {
                                              final docsJour = points.where((p) {
                                                final d = (p['timestamp'] as Timestamp).toDate();
                                                return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == jour;
                                              }).toList();

                                              double soldeTotal = 0, commissionTotal = 0;
                                              for (var p in docsJour) {
                                                soldeTotal += (double.tryParse(p['soldeOrange']?.toString() ?? '0') ?? 0) +
                                                              (double.tryParse(p['soldeMTN']?.toString() ?? '0') ?? 0) +
                                                              (double.tryParse(p['soldeMoov']?.toString() ?? '0') ?? 0) +
                                                              (double.tryParse(p['soldeCaisse']?.toString() ?? '0') ?? 0);
                                                commissionTotal += (double.tryParse(p['commissionOrange']?.toString() ?? '0') ?? 0) +
                                                                  (double.tryParse(p['commissionMTN']?.toString() ?? '0') ?? 0) +
                                                                  (double.tryParse(p['commissionMoov']?.toString() ?? '0') ?? 0);
                                              }

                                              return Container(
                                                constraints: BoxConstraints(minHeight: 80),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Solde total: ${soldeTotal.toStringAsFixed(2)}"),
                                                    Text("Commission tot.: ${commissionTotal.toStringAsFixed(2)}"),
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                        ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: Text(
                              //     "Commissions total du mois : ${(commissionTotal - totalSorties).toStringAsFixed(2)}",
                              //     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              //   ),
                              // ),
                            ],
                          );
                        },
                      ),
                  ),
                    const Divider(),
                    const SizedBox(height: 20.0),
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ArchivesPressingScreen()),
                          );
                        },
                        // color: Colors.yellow,
                        // height: 55.0,
                        child: const Text(
                          "Voir l'historique des transferts",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  // Calcul du report à nouveau du mois précédent
  Future<double> getReportAnterieur(int year, int month) async {
    int y = year;
    int m = month;
    if (m == 1) {
      y -= 1;
      m = 12;
    } else {
      m -= 1;
    }
    final prevPoints = await fetchPointsForMonth(y, m);
    double report = 0;
    for (var p in prevPoints) {
      if (p['type'] == 'Entrée') {
        report += double.tryParse(p['montant'].toString()) ?? 0;
      } else if (p['type'] == 'Sortie') {
        report -= double.tryParse(p['montant'].toString()) ?? 0;
      }
    }
    return report;
  }
}