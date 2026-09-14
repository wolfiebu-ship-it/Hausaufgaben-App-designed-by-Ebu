# Hausaufgaben – App für iPhone und iPad

Eine App, um die Hausaufgaben des Tages einzutragen und den eigenen Stundenplan immer dabeizuhaben.

Geschrieben in Swift/SwiftUI als native App für iPhone **und** iPad. Alle Daten bleiben auf dem Gerät – kein Konto, kein Internet, keine Werbung.

---

## Was die App kann

### 1. Hausaufgaben eintragen

- **Eine Seite pro Woche.** Ist die Woche voll, blätterst du einfach nach rechts zur nächsten Woche – mit einem Wisch oder über die Pfeile oben. Über den Titel („Diese Woche“) springst du per Kalender zu jeder beliebigen Woche.
- **Tage zum Aufklappen.** Beim Öffnen sind alle Tage zugeklappt, sodass die ganze Woche auf einen Blick passt. Der zugeklappte Kopf zeigt schon, was ansteht: die Kürzel der Fächer mit Eintrag (Erledigtes blasser), die Anzahl offener Aufgaben, „Keine Hausaufgaben“ oder „Nichts eingetragen“. Ein Tipp auf den Tag klappt ihn zum Eintragen auf.
- **Die Kürzel stehen schon da.** Zu jedem Tag zeigt die App automatisch die Fächer, die du laut deinem Stundenplan an diesem Tag hast – als farbiges Kürzel links neben dem Eingabefeld. Du tippst nur noch die Aufgabe daneben.
- Der heutige Tag ist farbig umrandet.
- Erledigtes hakst du rechts mit einem Tipp ab.
- **Rechts an jeder Zeile** steht, je nach Lage:
  - **ein Kreis zum Abhaken**, sobald etwas eingetragen ist – ein Tipp, und die Aufgabe ist erledigt;
  - **„nichts auf“**, solange das Feld leer ist. Antippen hält fest, dass es *in diesem Fach* nichts aufgegeben hat; die Zeile zeigt dann „Keine Hausaufgaben“ und lässt sich über das Minus wieder zurücknehmen.
- **Für den ganzen Tag** geht das ebenfalls: unten in der Tageskarte „Keine Hausaufgaben“ abhaken, dann klappt sie auf eine Zeile zusammen.
- So bleibt später unterscheidbar, ob wirklich nichts aufgegeben wurde oder du es nur nicht eingetragen hast. Sobald du doch etwas einträgst, verschwindet der Vermerk von allein.
- Hattest du ausnahmsweise ein Fach, das nicht im Plan steht (z. B. Vertretung), ergänzt du es unten über **„Fach ergänzen“**.
- Getipptes wird automatisch gespeichert – es gibt keinen Sichern-Knopf.

### 2. Stundenplan

- Raster mit den Wochentagen als Spalten und den Stunden als Zeilen.
- Auf ein Feld tippen → Fach auswählen, fertig. Raum und Lehrkraft lassen sich für einzelne Stunden abweichend eintragen.
- Einstellbar: Anzahl der Stunden pro Tag (1–14), Samstag als sechster Schultag, Unterrichtszeiten je Stunde.
- Der heutige Wochentag ist hervorgehoben.

### 3. Stundenplan abfotografieren

Statt jedes Feld einzeln einzutippen, lässt sich der eigene Stundenplan scannen:

1. **Aufnehmen** – Apples Dokumentenscanner erkennt den Papierrand und entzerrt das Bild. Alternativ ein vorhandenes Foto aus der Mediathek.
2. **Lesen** – die Texterkennung liest die Kürzel und leitet aus ihrer Lage im Bild das Raster ab: welche Spalte welcher Wochentag ist und welche Zeile welche Stunde.
3. **Prüfen** – das Ergebnis wird als Raster angezeigt. Falsch gelesene Felder tippst du an und korrigierst sie; unbekannte Kürzel lassen sich mit einem Tipp als neue Fächer anlegen.
4. **Übernehmen** – erst dann wird der Stundenplan ersetzt.

Der Prüfschritt ist Absicht: Ein Foto kann schief, dunkel oder handgeschrieben sein, und dann liest die Erkennung Dinge falsch. **Gedruckte Pläne funktionieren deutlich besser als handgeschriebene.**

Alles läuft auf dem Gerät – das Foto wird nicht hochgeladen und nirgends gespeichert. Beim ersten Scan fragt iOS nach der Kameraerlaubnis.

> Der Dokumentenscanner braucht eine echte Kamera und funktioniert deshalb **nicht im Simulator**. Zum Ausprobieren am Mac lässt sich stattdessen ein Foto aus der Mediathek wählen.

### 4. Notizen

Ein eigener Tab unten für alles, was man sich aufschreiben will – aufgebaut wie Apples Notizen-App.

- Oben steht **ein Feld: „Notiz schreiben …“**. Antippen, die Tastatur kommt, lostippen. Mehr braucht es nicht.
- **Kein Titelfeld, kein Sichern-Knopf.** Die erste beschriebene Zeile wird automatisch zum Titel; gespeichert wird während des Schreibens.
- Darunter stehen die eigenen Notizen: Titel fett, daneben Uhrzeit bzw. Datum der letzten Änderung und der Anfang des Textes. Zuletzt bearbeitet zuerst.
- Antippen öffnet die Notiz wieder zum Weiterschreiben. Gelöscht wird über den Papierkorb in der geöffneten Notiz (mit Rückfrage) oder per langem Tippen in der Liste.
- Die App bringt **keine vorgefertigten Notizen** mit – hier steht nur, was du selbst schreibst.

> Anders als bei Apple wird die erste Zeile beim Schreiben nicht fett dargestellt, nur in der Liste. Für formatierten Text bräuchte es einen anderen Editor.

### 5. Fächer

- **Oben stehen die Stunden des Tages.** Ist heute Schule, siehst du „Heute · Montag“ mit allen Stunden dieses Tages in der Reihenfolge des Plans – mit Stundennummer, Uhrzeit und Raum. Am Wochenende oder an einem freien Tag springt die Liste auf den nächsten Schultag („Morgen · Montag“). Das stellt sich jeden Tag von allein um.
- Darunter **alle Fächer** alphabetisch zum Bearbeiten.
- Name, Kürzel, Farbe, Lehrkraft und Raum je Fach.
- Beim ersten Start sind typische Schulfächer schon angelegt (Deutsch, Mathematik, Englisch …) – umbenennen oder löschen, wie du möchtest.
- Das Kürzel ist genau das, was im Stundenplan und neben dem Hausaufgabenfeld steht.

### 6. Einstellungen

- **Hell oder dunkel:** ganz oben unter „Darstellung“ lässt sich die App fest auf hell oder dunkel stellen – oder auf „Automatisch“, dann folgt sie der Einstellung des Geräts.
- Stunden pro Tag, Samstag, Uhrzeiten, Unterrichtszeiten.
- **Sicherung speichern / wiederherstellen** als Datei (z. B. in iCloud Drive). Wichtig, denn die Daten liegen nur auf dem Gerät.

---

## Die App aufs iPhone oder iPad bringen

Dafür brauchst du einen **Mac mit Xcode** (kostenlos im Mac App Store). Ohne Mac lässt sich eine native iOS-App nicht bauen – das ist eine Vorgabe von Apple, keine Einschränkung dieser App.

### Schritt für Schritt

1. **Projekt laden**

   Lade dieses Repository als ZIP herunter und entpacke es – oder im Terminal:

   ```
   git clone https://github.com/wolfiebu-ship-it/Hausaufgaben-App-designed-by-Ebu.git
   ```

2. **In Xcode öffnen**

   Doppelklick auf `HausaufgabenApp.xcodeproj`.

3. **Deinen Apple-Account eintragen** (einmalig)

   - In Xcode oben im Menü: **Xcode → Settings… → Accounts → „+“ → Apple ID** und mit deiner Apple-ID anmelden. Ein normaler, kostenloser Apple-Account genügt.
   - Dann links im Projektnavigator auf **HausaufgabenApp** klicken, in der Mitte auf das Ziel **HausaufgabenApp**, Reiter **Signing & Capabilities**.
   - Bei **Team** deinen Namen auswählen („… (Personal Team)“).
   - Bei **Bundle Identifier** etwas Eigenes eintragen, das es nur einmal auf der Welt gibt, z. B. `de.deinname.hausaufgaben`. Der voreingestellte Wert `de.ebu.HausaufgabenApp` funktioniert nur, wenn ihn nicht schon jemand benutzt.

4. **Gerät anschließen und starten**

   - iPhone oder iPad per Kabel an den Mac, auf dem Gerät „Diesem Computer vertrauen“ bestätigen.
   - In Xcode oben in der Leiste dein Gerät als Ziel auswählen.
   - Auf ▶ (Play) drücken.

5. **Auf dem Gerät dem Entwickler vertrauen** (einmalig)

   Beim ersten Start meldet iOS „Nicht vertrauenswürdiger Entwickler“. Dann auf dem Gerät:
   **Einstellungen → Allgemein → VPN & Geräteverwaltung →** deine Apple-ID antippen **→ Vertrauen**.
   Danach die App normal über das Symbol auf dem Home-Bildschirm öffnen.

### Wichtig zur Laufzeit der Installation

- Mit einem **kostenlosen** Apple-Account läuft die App **7 Tage**. Danach musst du sie in Xcode erneut aufs Gerät spielen (Schritt 4 wiederholen) – deine eingetragenen Hausaufgaben bleiben dabei erhalten.
- Mit dem **Apple Developer Program** (99 € pro Jahr) läuft sie **ein Jahr** am Stück.
- Auf iPhone und iPad musst du die App jeweils einzeln installieren. Die Daten werden **nicht** zwischen den Geräten synchronisiert – dafür gibt es die Sicherungsdatei in den Einstellungen.

---

## Technisches

- **Sprache/Framework:** Swift 5, SwiftUI
- **Mindestversion:** iOS 17.0 (iPhone und iPad, Hoch- und Querformat)
- **Speicherung:** eine JSON-Datei im Dokumentenordner der App (`hausaufgaben.json`). Änderungen werden kurz gesammelt und dann automatisch geschrieben; beim Verlassen der App wird sofort gesichert. Ist die Datei einmal beschädigt, wird sie zur Seite gelegt statt überschrieben.
- **Keine fremden Bibliotheken**, keine Netzwerkzugriffe. Für den Scan kommen Apples eigene Frameworks zum Einsatz: VisionKit (Dokumentenscanner), Vision (Texterkennung) und PhotosUI (Fotoauswahl).

### Aufbau des Projekts

```
HausaufgabenApp/
├── HausaufgabenApp.swift        Einstiegspunkt der App
├── Models/                      Datenmodelle
│   ├── Subject.swift            Fach (Name, Kürzel, Farbe)
│   ├── Note.swift               Freie Notiz mit Fach und Termin
│   ├── Lesson.swift             Feld im Stundenplan
│   ├── HomeworkEntry.swift      Eine Hausaufgabe
│   ├── AppSettings.swift        Einstellungen, Unterrichtszeiten
│   └── AppData.swift            Alles zusammen (auch das Format der Sicherung)
├── Store/
│   └── AppStore.swift           Hält die Daten, speichert und lädt sie
├── Support/
│   ├── SchoolCalendar.swift     Wochen- und Datumsberechnungen (Woche ab Montag)
│   ├── AppTheme.swift           Farben (je Fach ein heller und ein kräftiger Ton)
│   ├── DoodleBackground.swift   Schulmotive blass hinter den Schreib-Seiten
│   ├── TimetableRecognizer.swift  Texterkennung und Rasteranalyse für den Scan
│   └── BackupDocument.swift     Sicherungsdatei
├── Views/
│   ├── RootView.swift           Die vier Tabs
│   ├── Homework/                Hausaufgabenheft mit Wochenblättern
│   ├── Notes/                   Notizliste und Schreibblatt
│   ├── Timetable/               Stundenplan-Raster, Scannen und Prüfansicht
│   ├── Subjects/                Fächerverwaltung
│   └── Settings/                Einstellungen, Unterrichtszeiten
└── Assets.xcassets              App-Symbol und Akzentfarbe
```

---

## Wenn etwas nicht klappt

| Problem | Lösung |
|---|---|
| „Signing for … requires a development team“ | Schritt 3 der Anleitung: Team unter *Signing & Capabilities* auswählen. |
| „Failed to register bundle identifier“ | Den Bundle Identifier auf etwas Eindeutiges ändern, z. B. `de.deinname.hausaufgaben2`. |
| „Untrusted Developer“ auf dem Gerät | Schritt 5: Einstellungen → Allgemein → VPN & Geräteverwaltung → Vertrauen. |
| App startet nicht mehr nach einer Woche | Normal beim kostenlosen Account – in Xcode erneut auf ▶ drücken. |
| Beim Öffnen des Projekts erscheint eine Xcode-Warnung zur Projektversion | Xcode 16 oder neuer verwenden. |
