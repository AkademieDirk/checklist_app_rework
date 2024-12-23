// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:checklist_app_rework/Apis/shared_preferences_api.dart';
import 'package:checklist_app_rework/models/aufgaben_modell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  TextEditingController titel = TextEditingController();
  TextEditingController datum = TextEditingController();
  TextEditingController beschreibung = TextEditingController();
  List<AufgabenModell>? aufgabe = [];
  bool loaded = false;
  bool editpressed = false;
  int thisid = 0;
  // hier wird beim Beginn die Methode geladen um zu sehen ob fir Aifgaben geladen sind
  @override
  void initState() {
    super.initState();
    _ladeAufgaben();
  }

  //! Diese Methode musste ich auslagern da im InitState kein Future funktioniert
  Future<void> _ladeAufgaben() async {
    aufgabe = await SharedPreferencesApi().getList(); // Daten asynchron laden
    if (aufgabe != null) {
      setState(() {
        loaded = true; // State aktualisieren, wenn die Daten geladen sind
      });
    }
  }

// hier wird die nächste freie ID rausgesucht und
  getId() {
    int max = 0;
    List<int> ids = [];
    if (aufgabe != null) {
      for (var i in aufgabe!) {
        ids.add(i.id.toInt());
      }

      for (int i in ids) {
        if (i > max) {
          max = i;
        }
      }
      return max + 1;
    } else {
      return 0;
    }
  }

  // hier wird einfach anhand des Indexes die ausgewählte Aufgabe gelöscht
  loescheAufgabe(int id) {
    for (var i in aufgabe!) {
      if (i.id == id) {
        aufgabe!.remove(i);
        break;
      }
    }

    // hier wieder beispielhaft der Zugriff auf die Shared Preferences
    SharedPreferencesApi().saveList(aufgabe!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.greenAccent,
          title: const Text(
            "ToDoList",
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w400),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 25, top: 15),
                    child: Text(" Aufgabe hinzufügen"),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: titel,
                decoration: InputDecoration(
                    constraints: const BoxConstraints(maxHeight: 50),
                    hintText: "Aufgabe rein",
                    labelText: "Aufgabe",
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                  controller: datum,
                  decoration: InputDecoration(
                      hintText: "Datum rein",
                      labelText: "Datum",
                      prefixIcon: const Icon(Icons.calendar_month),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                  readOnly: true,
                  // Hier wird die Datumsauswahl gestartet und das datum in eine Variable gepackt
                  onTap: () async {
                    DateTime? datumpicked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(DateTime.now().year + 1));
                    if (datumpicked != null) {
                      String datumformatted =
                          DateFormat("yyyy-MM-dd").format(datumpicked);
                      setState(() {
                        datum.text = datumformatted;
                      });
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("kein datum gewählt")));
                      }
                    }
                  }),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                controller: beschreibung,
                maxLines: 3,
                decoration: InputDecoration(
                    constraints: const BoxConstraints(
                        maxHeight:
                            150), // hier habe ich die Höhe der Beschreibungsbox eingestellt
                    hintText: "Beschreibung rein",
                    labelText: "Beschreibung",
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.greenAccent)),
                      // anders habe ich die Hintergrundfarbe nicht hinbekommen
                      onPressed: () {
                        if (editpressed == false) {
                          if (titel.text != "") {
                            if (datum.text != "") {
                              if (beschreibung.text != "") {
                                aufgabe!.add(AufgabenModell(
                                  id: getId(),
                                  titel: titel.text,
                                  beschreibung: beschreibung.text,
                                  datum: datum.text,
                                ));

                                // Hier wirrd die Methode aufgerufen um den neuen REintrag zu speichern. Die Informationen kommen aus den Shard Preferences
                                SharedPreferencesApi().saveList(aufgabe!);
                                _ladeAufgaben();
                              } else {
                                print(" Beschreibung fehlt");
                              }
                            } else {
                              print("Datum fehlt");
                            }
                          } else {
                            print("Titel fehlt");
                          }
                        } else {
                          if (titel.text != "") {
                            if (datum.text != "") {
                              if (beschreibung.text != "") {
                                SharedPreferencesApi().updateList(
                                  aufgabe!,
                                  thisid,
                                  titel.text,
                                  beschreibung.text,
                                  datum.text,
                                );
                                // hier werden die Aufgaben neu geladen um sie wieder anzuzeigen nach änderungen
                                setState(() {
                                  thisid = 0;
                                  editpressed = false;
                                  _ladeAufgaben();
                                });
                              } else {
                                print(" Beschreibung fehlt");
                              }
                            } else {
                              print("Datum fehlt");
                            }
                          } else {
                            print("Titel fehlt");
                          }
                        }
                      },
                      icon: const Icon(
                        Icons.save,
                        color: Colors.black,
                      ),
                      label: const Text(
                        " speichern",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton.icon(
                      style: const ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.greenAccent)),
                      onPressed: () {
                        titel.clear();
                        datum.clear();
                        beschreibung.clear();
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                      label: const Text(
                        " löschen",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Divider(
                color: Colors.black,
                indent: 15,
                endIndent: 15,
                thickness: 1,
              ),
              const Padding(
                padding: EdgeInsets.only(
                  left: 15,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Meine To Do List",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: loaded,
                      replacement:
                          const Center(child: CircularProgressIndicator()),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: aufgabe!.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            key: Key(aufgabe![index].id.toString()),
                            startActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                dismissible: DismissiblePane(
                                    key: Key(aufgabe![index].id.toString()),
                                    onDismissed: () {
                                      loescheAufgabe(aufgabe![index].id);
                                    }),
                                children: const [
                                  SlidableAction(
                                    onPressed: null,
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.green,
                                    icon: Icons.delete,
                                    label: "Löschen",
                                  )
                                ]),
                            endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                dismissible:
                                    DismissiblePane(onDismissed: () {}),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) {
                                      titel.text = aufgabe![index].titel;
                                      datum.text = aufgabe![index].datum;
                                      beschreibung.text =
                                          aufgabe![index].beschreibung;
                                      setState(() {
                                        editpressed = true;
                                        thisid = aufgabe![index].id;
                                      });
                                    },
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.green,
                                    icon: Icons.edit,
                                    label: "bearbeiten",
                                  )
                                ]),
                            child: Card(
                              elevation: 10,
                              color: const Color.fromARGB(255, 27, 82, 55),
                              margin: const EdgeInsets.all(5),
                              child: SizedBox(
                                height: 80,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12.0, right: 24),
                                      child: Text(
                                        aufgabe![index].titel,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        aufgabe![index].datum,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        aufgabe![index].beschreibung,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ]),
          ),
        ));
  }
}
