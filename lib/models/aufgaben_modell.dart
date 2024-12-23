import 'dart:convert';

// Diese Funktion wandelt einen JSON-String in eine Liste von Objekten  der AufgabenModell Klasse um
List<AufgabenModell> postAufgabenFromJson(String str) =>
    List<AufgabenModell>.from(
      json.decode(str).map((x) => AufgabenModell.fromJson(x)),
    );
// hier werden die ooben erstelle Liste in einen Json String um
String postAufgabenToJson(List<AufgabenModell> data) =>
    json.encode(List<dynamic>.from(data.map((e) => e.toJson)));

class AufgabenModell {
  AufgabenModell(
      {required this.id,
      required this.titel,
      required this.datum,
      required this.beschreibung});
  int id;
  String titel;
  String datum;
  String beschreibung;
// Hier werden einzenlne AufgabenModell Objekte aus dem JSON String erstellt
  factory AufgabenModell.fromJson(Map<String, dynamic> json) => AufgabenModell(
      id: json["id"],
      titel: json["titel"],
      datum: json["datum"],
      beschreibung: json["beschreibung"]);

  // Hier ist der umgekehrte Weg ein AufgabenModell Objekt wird in einen Json String umgewandelt
  Map<String, dynamic> toJson() => {
        "id": id,
        "titel": titel,
        "datum": datum,
        "beschreibung": beschreibung,
      };
}
