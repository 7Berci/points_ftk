import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:points_ftk/main_menu/archives_pressing_screen.dart';

class DailyPressingArchivesScreen extends StatefulWidget {
  const DailyPressingArchivesScreen({super.key});

  @override
  DailyPressingArchivesScreenView createState() => DailyPressingArchivesScreenView();
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

class DailyPressingArchivesScreenView extends State<DailyPressingArchivesScreen> {
  List<Map<String, dynamic>> points = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    fetchPointsForMonth(now.year, now.month).then((pts) {
      setState(() {
        points = pts;
        isLoading = false;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchPointsForMonth(int year, int month) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);

    final snapshot = await FirebaseFirestore.instance
        .collection('points_pressing')
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
            Text("Points de pressing - ${moisLettre[now.month]} ${now.year}"),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF5ACC80),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : points.isEmpty
              ? const Center(child: Text("Aucun point enregistré ce mois-ci."))
              : FutureBuilder<double>(
                  future: getReportAnterieur(now.year, now.month),
                  builder: (context, snapshot) {
                    double report = snapshot.data ?? 0;
                    double totalEntrees = 0;
                    double totalSorties = 0;
                    Map<String, double> reportParJour = {};

                    for (var jour in joursList) {
                      double entreeJour = entrees
                          .where((e) {
                            final date = (e['timestamp'] as Timestamp).toDate();
                            return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" == jour;
                          })
                          .fold(0.0, (sum, e) => sum + (double.tryParse(e['montant'].toString()) ?? 0));
                      double sortieJour = sorties
                          .where((s) {
                            final date = (s['timestamp'] as Timestamp).toDate();
                            return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" == jour;
                          })
                          .fold(0.0, (sum, s) => sum + (double.tryParse(s['montant'].toString()) ?? 0));
                      report += (entreeJour - sortieJour);
                      reportParJour[jour] = report;
                      totalEntrees += entreeJour;
                      totalSorties += sortieJour;
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Jour')),
                                  DataColumn(label: Text('Entrées')),
                                  DataColumn(label: Text('Sorties')),
                                  DataColumn(label: Text('Report à nouveau')),
                                ],
                                rows: joursList.map((jour) {
                                  final parts = jour.split('-');
                                  final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                                  final moisNom = moisLettre[date.month];
                            
                                  double entreeJour = entrees
                                      .where((e) {
                                        final d = (e['timestamp'] as Timestamp).toDate();
                                        return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == jour;
                                      })
                                      .fold(0.0, (sum, e) => sum + (double.tryParse(e['montant'].toString()) ?? 0));
                                  double sortieJour = sorties
                                      .where((s) {
                                        final d = (s['timestamp'] as Timestamp).toDate();
                                        return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" == jour;
                                      })
                                      .fold(0.0, (sum, s) => sum + (double.tryParse(s['montant'].toString()) ?? 0));
                                  double reportJour = reportParJour[jour]!;
                                  return DataRow(cells: [
                                    DataCell(Text("${date.day} $moisNom ${date.year}")),
                                    DataCell(Text(entreeJour.toStringAsFixed(2))),
                                    DataCell(Text(sortieJour.toStringAsFixed(2))),
                                    DataCell(Text(reportJour.toStringAsFixed(2))),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Total du mois : ${(totalEntrees - totalSorties).toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                              "Voir l'historique de pressing",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ),
                    const SizedBox(height: 15.0),
                      ],
                    );
                  },
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