import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:points_ftk/main_menu/daily_pressing_screen.dart';
import 'package:points_ftk/main_menu/archives_print_screen.dart';
import 'package:points_ftk/main_menu/the_navigation_drawer.dart';
import 'package:intl/intl.dart';

class DailyPrintScreen extends StatefulWidget {
  const DailyPrintScreen({super.key});

  @override
  DailyPrintScreenView createState() => DailyPrintScreenView();
}

class DailyPrintScreenView extends State<DailyPrintScreen> {
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
          final jourStr =
              "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
          jours.add(jourStr);
        }

        final joursList = jours.toList()..sort();

        // ✅ collectedStates vaut true uniquement si TOUS les documents du jour ont collected == true
        collectedStates =
            joursList.map((jour) {
              final docsDuJour =
                  pts.where((p) {
                    final d = (p['timestamp'] as Timestamp).toDate();
                    final jourStr =
                        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
                    return jourStr == jour;
                  }).toList();

              return docsDuJour.isNotEmpty &&
                  docsDuJour.every((doc) => doc['collected'] == true);
            }).toList();
      });
    });
  }

  // Fonction pour récupérer les détails d'un jour spécifique
  Future<List<Map<String, dynamic>>> fetchDayDetails(String dateStr) async {
    final parts = dateStr.split('-');
    final day = int.parse(parts[2]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[0]);

    final startOfDay = DateTime(year, month, day);
    final endOfDay = DateTime(year, month, day, 23, 59, 59);

    final snapshot =
        await FirebaseFirestore.instance
            .collection('points_impression')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
            .orderBy('timestamp')
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {...data, 'id': doc.id, 'timestamp': data['timestamp']};
    }).toList();
  }

  // Fonction pour mettre à jour un document
  Future<void> updateDocument(
    String documentId,
    Map<String, dynamic> newData,
  ) async {
    await FirebaseFirestore.instance
        .collection('points_impression')
        .doc(documentId)
        .update(newData);
  }

  // Fonction pour supprimer un document
  Future<void> deleteDocument(String documentId) async {
    await FirebaseFirestore.instance
        .collection('points_impression')
        .doc(documentId)
        .delete();
  }

  // Fonction pour afficher les détails du jour
  void showDayDetails(BuildContext context, String dateStr) async {
    final details = await fetchDayDetails(dateStr);
    final date = DateTime.parse(dateStr);
    final user = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Détails du ${date.day}/${date.month}/${date.year}'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  ...details.map((entry) {
                    final timestamp =
                        (entry['timestamp'] as Timestamp).toDate();
                    return user?.email == 'eliel08@hotmail.fr'
                        ? DocumentTile(
                          entry: entry,
                          onEdit: () => _showEditDialog(context, entry),
                          onDelete:
                              () => _showDeleteDialog(context, entry, dateStr),
                        )
                        : ListTile(
                          title: Text('${entry['type']}: ${entry['montant']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Heure: ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                              ),
                              if (entry['observation'] != null &&
                                  entry['observation'].isNotEmpty)
                                Text('Observation: ${entry['observation']}'),
                              Text(
                                'Par: ${entry['userEmail'] ?? 'Non enregistré'}',
                              ),
                            ],
                          ),
                          trailing: Text(entry['collected'] == true ? '✓' : ''),
                        );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  // Fonction pour afficher la boîte de dialogue d'édition
  void _showEditDialog(BuildContext context, Map<String, dynamic> entry) {
    final timestamp = (entry['timestamp'] as Timestamp).toDate();
    final montantController = TextEditingController(
      text: entry['montant'].toString(),
    );
    final observationsController = TextEditingController(
      text: entry['observation'] ?? '',
    );
    DateTime selectedDate = timestamp;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(timestamp);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Modifier le point'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          'Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: Text('Heure: ${selectedTime.format(context)}'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (picked != null && picked != selectedTime) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                      ),
                      TextField(
                        controller: montantController,
                        decoration: const InputDecoration(labelText: 'Montant'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: observationsController,
                        decoration: const InputDecoration(
                          labelText: 'Observations',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final newDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      await updateDocument(entry['id'], {
                        'timestamp': Timestamp.fromDate(newDateTime),
                        'montant': double.parse(montantController.text),
                        'observations': observationsController.text,
                      });

                      Navigator.pop(context); // Fermer la boîte d'édition
                      Navigator.pop(context); // Fermer la boîte de détails

                      // Rafraîchir les données
                      final updatedDetails = await fetchDayDetails(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                      );
                      showDayDetails(
                        context,
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                      );
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              );
            },
          ),
    );
  }

  // Fonction pour afficher la boîte de dialogue de suppression
  void _showDeleteDialog(
    BuildContext context,
    Map<String, dynamic> entry,
    String dateStr,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text(
              'Êtes-vous sûr de vouloir supprimer cette ${entry['type']} de ${entry['montant']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await deleteDocument(entry['id']);
                  Navigator.pop(context); // Fermer la boîte de confirmation
                  Navigator.pop(context); // Fermer la boîte de détails

                  // Rafraîchir les données
                  showDayDetails(context, dateStr);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Supprimer'),
              ),
            ],
          ),
    );
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
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('points_impression')
            .where(
              'timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
            .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in querySnapshot.docs) {
      batch.update(doc.reference, {'collected': newStatus});
    }

    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> fetchPointsForMonth(
    int year,
    int month,
  ) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);

    final snapshot =
        await FirebaseFirestore.instance
            .collection('points_impression')
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
      jours.add(
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      );
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
          child: Text(
            "Points d'impression - ${moisLettre[now.month]} ${now.year}",
          ),
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
                    double report = snapshot.data ?? 0;
                    double totalEntrees = 0;
                    double totalSorties = 0;
                    Map<String, double> reportParJour = {};

                    for (var jour in joursList) {
                      double entreeJour = entrees
                          .where((e) {
                            final date = (e['timestamp'] as Timestamp).toDate();
                            return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" ==
                                jour;
                          })
                          .fold(
                            0.0,
                            (sum, e) =>
                                sum +
                                (double.tryParse(e['montant'].toString()) ?? 0),
                          );
                      double sortieJour = sorties
                          .where((s) {
                            final date = (s['timestamp'] as Timestamp).toDate();
                            return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}" ==
                                jour;
                          })
                          .fold(
                            0.0,
                            (sum, s) =>
                                sum +
                                (double.tryParse(s['montant'].toString()) ?? 0),
                          );
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
                                  DataColumn(label: Text('Collecté?')),
                                  DataColumn(label: Text('Jour')),
                                  DataColumn(label: Text('Entrées')),
                                  DataColumn(label: Text('Sorties')),
                                  DataColumn(label: Text('Report à nouveau')),
                                ],
                                rows:
                                    joursList.toList().asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final jour = entry.value;
                                      //final parts = jour.split('-');
                                      //final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                                      //final moisNom = moisLettre[date.month];

                                      double entreeJour = entrees
                                          .where((e) {
                                            final d =
                                                (e['timestamp'] as Timestamp)
                                                    .toDate();
                                            return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" ==
                                                jour;
                                          })
                                          .fold(
                                            0.0,
                                            (sum, e) =>
                                                sum +
                                                (double.tryParse(
                                                      e['montant'].toString(),
                                                    ) ??
                                                    0),
                                          );
                                      double sortieJour = sorties
                                          .where((s) {
                                            final d =
                                                (s['timestamp'] as Timestamp)
                                                    .toDate();
                                            return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}" ==
                                                jour;
                                          })
                                          .fold(
                                            0.0,
                                            (sum, s) =>
                                                sum +
                                                (double.tryParse(
                                                      s['montant'].toString(),
                                                    ) ??
                                                    0),
                                          );
                                      double reportJour = reportParJour[jour]!;
                                      return DataRow(
                                        // Ajout du GestureDetector ici
                                        onSelectChanged: (_) {
                                          showDayDetails(context, jour);
                                        },

                                        cells: [
                                          DataCell(
                                            user?.email == 'eliel08@hotmail.fr'
                                                ? InkWell(
                                                  onTap:
                                                      () =>
                                                          toggleCollectedStatus(
                                                            index,
                                                            jour,
                                                          ),
                                                  child: Icon(
                                                    collectedStates[index]
                                                        ? FontAwesome
                                                            .check_square
                                                        : FontAwesome.square_o,
                                                    color:
                                                        collectedStates[index]
                                                            ? Colors.green
                                                            : Colors.grey,
                                                    size: 32,
                                                  ),
                                                )
                                                : Icon(
                                                  collectedStates[index]
                                                      ? FontAwesome.check_square
                                                      : FontAwesome.square_o,
                                                  color:
                                                      collectedStates[index]
                                                          ? Colors.green
                                                          : Colors.grey,
                                                  size: 32,
                                                ),
                                          ),
                                          DataCell(Text(jour)),
                                          DataCell(
                                            Text(entreeJour.toStringAsFixed(2)),
                                          ),
                                          DataCell(
                                            Text(sortieJour.toStringAsFixed(2)),
                                          ),
                                          DataCell(
                                            Text(reportJour.toStringAsFixed(2)),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ),
                        //const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Total du mois : ${(totalEntrees - totalSorties).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
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
                  MaterialPageRoute(builder: (_) => ArchivesPrintScreen()),
                );
              },
              // color: Colors.yellow,
              // height: 55.0,
              child: const Text(
                "Voir l'historique d'impression",
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

// Widget personnalisé pour afficher chaque document avec icônes d'édition/suppression
class DocumentTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DocumentTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = (entry['timestamp'] as Timestamp).toDate();

    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
      title: Text('${entry['type']}: ${entry['montant']}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Heure: ${DateFormat('HH:mm').format(timestamp)}'),
          if (entry['observation'] != null && entry['observation'].isNotEmpty)
            Text('Observation: ${entry['observation']}'),
          Text('Par: ${entry['userEmail'] ?? 'Pas enregistré'}'),
        ],
      ),
      trailing: Text(entry['Collected'] == true ? '✓' : ''),
    );
  }
}
