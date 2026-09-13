# Hausaufgaben – App für iPhone und iPad

Eine App, um die Hausaufgaben des Tages einzutragen und den eigenen Stundenplan immer dabeizuhaben.

Geschrieben in Swift/SwiftUI als native App für iPhone **und** iPad. Alle Daten bleiben auf dem Gerät – kein Konto, kein Internet, keine Werbung.

---

## Was die App kann

### 1. Hausaufgaben eintragen

- **Eine Seite pro Woche.** Ist die Woche voll, blätterst du einfach nach rechts zur nächsten Woche – mit einem Wisch oder über die Pfeile oben. Über den Titel („Diese Woche“) springst du per Kalender zu jeder beliebigen Woche.
- **Die Kürzel stehen schon da.** Zu jedem Tag zeigt die App automatisch die Fächer, die du laut deinem Stundenplan an diesem Tag hast – als farbiges Kürzel links neben dem Eingabefeld. Du tippst nur noch die Aufgabe daneben.
- Der heutige Tag ist farbig umrandet.
- Erledigtes hakst du rechts mit einem Tipp ab.
- Hattest du ausnahmsweise ein Fach, das nicht im Plan steht (z. B. Vertretung), ergänzt du es unten über **„Fach ergänzen“**.
- Getipptes wird automatisch gespeichert – es gibt keinen Sichern-Knopf.

### 2. Stundenplan

- Raster mit den Wochentagen als Spalten und den Stunden als Zeilen.
- Auf ein Feld tippen → Fach auswählen, fertig. Raum und Lehrkraft lassen sich für einzelne Stunden abweichend eintragen.
- Einstellbar: Anzahl der Stunden pro Tag (1–14), Samstag als sechster Schultag, Unterrichtszeiten je Stunde.
- Der heutige Wochentag ist hervorgehoben.

### 3. Fächer

- Name, Kürzel, Farbe, Lehrkraft und Raum je Fach.
- Beim ersten Start sind typische Schulfächer schon angelegt (Deutsch, Mathematik, Englisch …) – umbenennen oder löschen, wie du möchtest.
- Das Kürzel ist genau das, was im Stundenplan und neben dem Hausaufgabenfeld steht.

### 4. Einstellungen

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
- **Keine fremden Bibliotheken**, keine Netzwerkzugriffe.

### Aufbau des Projekts

```
HausaufgabenApp/
├── HausaufgabenApp.swift        Einstiegspunkt der App
├── Models/                      Datenmodelle
│   ├── Subject.swift            Fach (Name, Kürzel, Farbe)
│   ├── Lesson.swift             Feld im Stundenplan
│   ├── HomeworkEntry.swift      Eine Hausaufgabe
│   ├── AppSettings.swift        Einstellungen, Unterrichtszeiten
│   └── AppData.swift            Alles zusammen (auch das Format der Sicherung)
├── Store/
│   └── AppStore.swift           Hält die Daten, speichert und lädt sie
├── Support/
│   ├── SchoolCalendar.swift     Wochen- und Datumsberechnungen (Woche ab Montag)
│   ├── AppTheme.swift           Farben und Maße
│   └── BackupDocument.swift     Sicherungsdatei
├── Views/
│   ├── RootView.swift           Die vier Tabs
│   ├── Homework/                Hausaufgabenheft mit Wochenblättern
│   ├── Timetable/               Stundenplan-Raster
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
