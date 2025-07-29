import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:points_ftk/main_menu/daily_pressing_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ArchivesPressingScreen extends StatefulWidget {
  const ArchivesPressingScreen({super.key});

  @override
  ArchivesPressingScreenView createState() => ArchivesPressingScreenView();
}

class ArchivesPressingScreenView extends State<ArchivesPressingScreen> {
  String? selectedYear;
  String? selectedMonth;
  List<String> years = [];
  List<String> months = [];
  List<Map<String, dynamic>> points = [];

  @override
  void initState() {
    super.initState();
    fetchYears().then((y) => setState(() => years = y));
  }

  Future<List<String>> fetchYears() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('points_pressing')
        .orderBy('timestamp', descending: true)
        .get();

    final years = <String>{};
    for (var doc in snapshot.docs) {
      final ts = doc['timestamp'];
      if (ts != null) {
        final date = (ts as Timestamp).toDate();
        years.add(date.year.toString());
      }
    }
    return years.toList()..sort((a, b) => b.compareTo(a));
  }

  Future<List<String>> fetchMonths(String year) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('points_pressing')
        .where('timestamp', isGreaterThanOrEqualTo: DateTime(int.parse(year)))
        .where('timestamp', isLessThan: DateTime(int.parse(year) + 1))
        .get();

    final months = <String>{};
    for (var doc in snapshot.docs) {
      final ts = doc['timestamp'];
      if (ts != null) {
        final date = (ts as Timestamp).toDate();
        months.add(date.month.toString().padLeft(2, '0'));
      }
    }
    return months.toList()..sort();
  }

  Future<List<Map<String, dynamic>>> fetchPointsForMonth(String year, String month) async {
    final start = DateTime(int.parse(year), int.parse(month));
    final end = DateTime(int.parse(year), int.parse(month) + 1);

    final snapshot = await FirebaseFirestore.instance
        .collection('points_pressing')
        .where('timestamp', isGreaterThanOrEqualTo: start)
        .where('timestamp', isLessThan: end)
        .orderBy('timestamp')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Calcul du report à nouveau du mois précédent
  Future<double> getReportAnterieur(String year, String month) async {
    int y = int.parse(year);
    int m = int.parse(month);
    if (m == 1) {
      y -= 1;
      m = 12;
    } else {
      m -= 1;
    }
    final prevPoints = await fetchPointsForMonth(y.toString(), m.toString().padLeft(2, '0'));
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

  @override
  Widget build(BuildContext context) {
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
        title: const Center(child: Text("Points de pressing")),
        backgroundColor: const Color(0xFF5ACC80),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Center(
              child: Text("ARCHIVES DE PRESSING",
                  style: TextStyle(
                    fontSize: 21.0,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
            // Dropdown Année
            DropdownButton<String>(
              value: selectedYear,
              hint: const Text("Choisir une année"),
              items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              onChanged: (y) async {
                selectedYear = y;
                selectedMonth = null;
                months = await fetchMonths(y!);
                points = [];
                setState(() {});
              },
            ),
            // Dropdown Mois
            if (selectedYear != null)
              DropdownButton<String>(
                value: selectedMonth,
                hint: const Text("Choisir un mois"),
                items: months.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(moisLettre[int.parse(m)]),
                )).toList(),
                onChanged: (m) async {
                  selectedMonth = m;
                  points = await fetchPointsForMonth(selectedYear!, selectedMonth!);
                  setState(() {});
                },
              ),
            // Tableau des points
            if (points.isNotEmpty)
              FutureBuilder<double>(
                future: getReportAnterieur(selectedYear!, selectedMonth!),
                builder: (context, snapshot) {
                  double report = snapshot.data ?? 0;
                  // double totalEntrees = 0;
                  // double totalSorties = 0;
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
                    // totalEntrees += entreeJour;
                    // totalSorties += sortieJour;
                  }

                  Future<void> exportToPdf() async {
                    final pdf = pw.Document();

                    pdf.addPage(
                    pw.Page(
                      build: (pw.Context context) {
                        // Pour le nom du mois en lettres :
                        const moisLettre = [
                          '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
                          'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
                        ];
                        final moisNom = moisLettre[int.parse(selectedMonth!)];

                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Points pressing du mois de $moisNom $selectedYear',
                              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.SizedBox(height: 16),
                            pw.TableHelper.fromTextArray(
                              headers: ['Jour', 'Entrées', 'Sorties', 'Report à nouveau'],
                              data: joursList.map((jour) {
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
                                double reportJour = reportParJour[jour]!;
                                return [
                                  jour,
                                  entreeJour.toStringAsFixed(2),
                                  sortieJour.toStringAsFixed(2),
                                  reportJour.toStringAsFixed(2),
                                ];
                              }).toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  );

                    // Demande la permission d’écriture
                    bool permissionGranted = false;
                  if (Platform.isAndroid) {
                    final androidInfo = await DeviceInfoPlugin().androidInfo;
                    if (androidInfo.version.sdkInt >= 30) {
                      permissionGranted = await Permission.manageExternalStorage.request().isGranted;
                    } else {
                      permissionGranted = await Permission.storage.request().isGranted;
                    }
                  } else {
                    permissionGranted = true; // iOS ou autre
                  }

                  if (permissionGranted) {
                    final directory = await getExternalStorageDirectory();
                    if (directory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Impossible d\'accéder au stockage')),
                      );
                      return;
                    }
                    String outputFile = "${directory.path}/points_pressing_${selectedYear}_$selectedMonth.pdf";
                    final file = File(outputFile);
                    await file.writeAsBytes(await pdf.save());

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('PDF enregistré : $outputFile')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Permission refusée')),
                    );
                  }
                //     await Printing.layoutPdf(
                //   onLayout: (PdfPageFormat format) async => pdf.save(),
                // );
                  }

                  return Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            DataTable(
                              columns: const [
                                DataColumn(label: Text('Jour')),
                                DataColumn(label: Text('Entrées')),
                                DataColumn(label: Text('Sorties')),
                                DataColumn(label: Text('Report à nouveau')),
                              ],
                              rows: joursList.map((jour) {
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
                                double reportJour = reportParJour[jour]!;
                                return DataRow(cells: [
                                  DataCell(Text(jour)),
                                  DataCell(Text(entreeJour.toStringAsFixed(2))),
                                  DataCell(Text(sortieJour.toStringAsFixed(2))),
                                  DataCell(Text(reportJour.toStringAsFixed(2))),
                                ]);
                              }).toList(),
                            ),
                           ElevatedButton.icon(
                              icon: Icon(Icons.picture_as_pdf),
                              label: Text('Exporter PDF'),
                              onPressed: exportToPdf, // Your function
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (points.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Total du mois : ${(points.where((p) => p['type'] == 'Entrée').fold(0.0, (sum, p) => sum + (double.tryParse(p['montant'].toString()) ?? 0)) - points.where((p) => p['type'] == 'Sortie').fold(0.0, (sum, p) => sum + (double.tryParse(p['montant'].toString()) ?? 0))).toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}