import 'dart:convert';

import 'package:checklist_app_rework/models/aufgaben_modell.dart';
import "package:shared_preferences/shared_preferences.dart";

class SharedPreferencesApi {
  static const key = " todo_list";
  Future<List<AufgabenModell>> getList() async {
    //! Hier wird die Instanz der Shred Preferences geholt um damit arbeiten zu können
    SharedPreferences sf = await SharedPreferences.getInstance();
    final jsonString = sf.getString(key) ?? "[]";
    final jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded
        .map(
          (e) => AufgabenModell.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
// Liste speichern

  void saveList(List<AufgabenModell> todos) async {
    final stringJson = json.encode(todos);
    SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setString(key, stringJson);
  }

// Liste updaten

  void updateList(List<AufgabenModell> aufgabe, int id, String titel,
      String beschreibung, String datum) async {
    for (var i in aufgabe) {
      if (i.id == id) {
        i.titel = titel;
        i.beschreibung = beschreibung;
        i.datum = datum;
      }
    }
    saveList(aufgabe);

    final stringJson = json.encode(aufgabe);
    SharedPreferences sf = await SharedPreferences.getInstance();
    sf.setString(key, stringJson);
  }
}
