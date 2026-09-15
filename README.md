<img src="docs/homy-logo.png" alt="" width="104" align="left" hspace="14" vspace="4">

# Homy

**Dein Hausaufgabenheft für iPhone und iPad.** Die Hausaufgaben des Tages eintragen und den eigenen Stundenplan immer dabeihaben.

<br clear="left">

Geschrieben in Swift/SwiftUI als native App für iPhone **und** iPad. Alle Daten bleiben auf dem Gerät – kein Konto, kein Internet, keine Werbung.

---

## Was die App kann

### 1. Hausaufgaben eintragen

- **Eine Seite pro Woche.** Ist die Woche voll, blätterst du einfach nach rechts zur nächsten Woche – mit einem Wisch oder über die Pfeile oben. Über den Titel („Diese Woche“) springst du per Kalender zu jeder beliebigen Woche.
- **Tage zum Aufklappen.** Beim Öffnen sind alle Tage zugeklappt, sodass die ganze Woche auf einen Blick passt. Der zugeklappte Kopf zeigt schon, was ansteht: die Kürzel der Fächer mit Eintrag (Erledigtes blasser), die Anzahl offener Aufgaben, „Keine Hausaufgaben“ oder „Nichts eingetragen“. Ein Tipp auf den Tag klappt ihn zum Eintragen auf.
- **Die Kürzel stehen schon da.** Zu jedem Tag zeigt die App automatisch die Fächer, die du laut deinem Stundenplan an diesem Tag hast – als farbiges Kürzel links neben dem Eingabefeld. Du tippst nur noch die Aufgabe daneben.
- Der heutige Tag ist farbig umrandet.
- Erledigtes hakst du rechts mit einem Tipp ab.
- **Rechts an jeder Zeile stehen zwei Felder zum Ankreuzen** – bei jedem Fach, nicht nur bei manchen. Über den Zeilen steht, welches welches ist:
  - **gelb** = in diesem Fach ist nichts aufgegeben. Die Zeile zeigt dann „Keine Hausaufgaben“; ein weiterer Tipp nimmt es zurück.
  - **blau** = die Aufgabe ist erledigt.
  **Beide lassen sich bei jedem Fach ankreuzen**, unabhängig davon, ob schon etwas eingetragen ist. Sie schließen einander aus: Kreuzt du „Keine Hausaufgaben“ an, wird ein bereits eingetragener Text verworfen. Und abhaken kannst du auch, bevor du etwas aufgeschrieben hast – dann steht dort „Erledigt“.
- **Was die Farben bedeuten**, steht ausführlich in den Einstellungen unter „Die Felder im Hausaufgabenheft“, und als kurze Legende über den Zeilen jedes Tages.
- **Für den ganzen Tag** geht das ebenfalls: unten in der Tageskarte „Keine Hausaufgaben“ abhaken, dann klappt sie auf eine Zeile zusammen.
- So bleibt später unterscheidbar, ob wirklich nichts aufgegeben wurde oder du es nur nicht eingetragen hast. Sobald du doch etwas einträgst, verschwindet der Vermerk von allein.
- Hattest du ausnahmsweise ein Fach, das nicht im Plan steht (z. B. Vertretung), ergänzt du es unten über **„Fach ergänzen“**.
- Getipptes wird automatisch gespeichert – es gibt keinen Sichern-Knopf.
- **Suchen** über die Lupe oben rechts: findet Hausaufgaben aus *allen* Wochen und alle Notizen. Einen Treffer antippen springt zu der Woche, in der er steht.

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

### 6. Anmeldung

Damit nicht jeder, der das Gerät in die Hand nimmt, in deinen Sachen liest, kann Homy beim Öffnen einen **Zahlencode** verlangen. Eingeschaltet wird das in den Einstellungen unter *Anmeldung*; ab Werk ist es aus.

- **Der Code** sind 4 bis 8 Ziffern. Auf dem Anmeldebild gibt es ein eigenes Tastenfeld – sobald die letzte Ziffer steht, prüft Homy von selbst.
- **Schnellstart für dich.** Ein Knopf stellt in einem Rutsch das ein, was du für dich willst: mit **Face ID bzw. Touch ID** öffnen und nur **beim Neustart** überhaupt fragen. Du schaust die App also nur an und bist drin – den Code tippen müssen die anderen.
- **Wann gefragt wird**, lässt sich auch einzeln wählen: jedes Mal, nach 5 Minuten, nach 1 Stunde oder nur beim Neustart.
- **Nach fünf Fehlversuchen** gibt es eine halbe Minute Pause.
- **„Homy jetzt zusperren“** macht die App sofort zu, etwa bevor du sie aus der Hand gibst.
- Ein freiwilliger **Merkzettel** erscheint auf dem Anmeldebild unter „Code vergessen?“.

Was dabei wichtig ist – ehrlich gesagt:

- Der Code wird **nicht im Klartext gespeichert**, sondern nur als Prüfwert (SHA-256 mit Zufallsbeigabe). Die App kann ihn dir deshalb nie wieder anzeigen. **Vergisst du ihn, hilft nur Löschen und Neuladen der App** – und die Hausaufgaben sind weg, wenn du keine Sicherung hast.
- Face ID und Touch ID prüft **iOS**, nicht Homy. Die App bekommt nie ein Gesicht oder einen Fingerabdruck zu sehen, sondern nur ein Ja oder Nein.
- Der Code steht **nicht in den Sicherungsdateien**. Eine fremde Sicherung kann deine Anmeldung also weder setzen noch aufheben, und ein Zurücksetzen der Daten hebt sie auch nicht auf.
- Das Ganze ist ein **Schloss vor der App**, keine Verschlüsselung der Datei. Wer den Code nicht kennt, kommt in der App nicht weiter – wer aber technisch an den Dateispeicher des Geräts kommt, ist damit nicht aufgehalten. Für ein Hausaufgabenheft ist das genau richtig, für Geheimnisse wäre es zu wenig.
- Es ist eine Anmeldung **auf diesem Gerät**, kein Konto: Es gibt keinen Server, bei dem man sich anmelden könnte. Wer Homy auf seinem eigenen iPhone lädt, legt dort seinen eigenen Code fest.

### 7. Einstellungen

- **Anmeldung** – Code einrichten, Schnellstart einschalten, sofort zusperren (siehe oben).
- **Meine Daten** – ein eigener Bereich für die Angaben über dich: Vor- und Nachname, Klasse, Schule, Telefon, E-Mail, Adresse und ein freies Feld für alles Weitere (Spind-Nummer, Buslinie, Notfallkontakt). Alles freiwillig, nichts muss ausgefüllt werden.

  > Diese Angaben bleiben auf dem Gerät. Die App verschickt nichts und hat keine Verbindung ins Internet. Nur wenn du selbst eine Sicherung speicherst, stehen sie mit in dieser Datei – gib sie also nicht unbedacht weiter.

- **Die Felder im Hausaufgabenheft** – erklärt, was das gelbe und das blaue Feld bedeuten.
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
- **Name auf dem Home-Bildschirm:** Homy (`CFBundleDisplayName`). Der Projekt- und Zielname im Xcode-Projekt heißt weiterhin `HausaufgabenApp`, ebenso die gespeicherte Datei – so bleiben vorhandene Installationen und Sicherungen lesbar.
- **Anmeldung:** CryptoKit (SHA-256 für den Prüfwert des Codes) und LocalAuthentication (Face ID / Touch ID). Beides gehört zu iOS, es kommt nichts dazu.
- **Mit Tastatur am iPad:** ⌘← und ⌘→ blättern durch die Wochen, ⌘F öffnet die Suche, ⌘N legt eine neue Notiz an.
- Kleine haptische Rückmeldung beim Ankreuzen und Aufklappen (iPhone).
- **Speicherung:** eine JSON-Datei im Dokumentenordner der App (`hausaufgaben.json`). Änderungen werden kurz gesammelt und dann automatisch geschrieben; beim Verlassen der App wird sofort gesichert. Ist die Datei einmal beschädigt, wird sie zur Seite gelegt statt überschrieben.
- **Keine fremden Bibliotheken**, keine Netzwerkzugriffe. Für den Scan kommen Apples eigene Frameworks zum Einsatz: VisionKit (Dokumentenscanner), Vision (Texterkennung) und PhotosUI (Fotoauswahl).

### Aufbau des Projekts

```
HausaufgabenApp/
├── HausaufgabenApp.swift        Einstiegspunkt der App
├── Models/                      Datenmodelle
│   ├── Subject.swift            Fach (Name, Kürzel, Farbe)
│   ├── Note.swift               Freie Notiz
│   ├── Profile.swift            Die eigenen Angaben (Name, Klasse, Kontakt)
│   ├── Lesson.swift             Feld im Stundenplan
│   ├── HomeworkEntry.swift      Eine Hausaufgabe
│   ├── AppSettings.swift        Einstellungen, Unterrichtszeiten
│   ├── LockSettings.swift       Anmeldung: Prüfwert des Codes, Schnellstart
│   └── AppData.swift            Alles zusammen (auch das Format der Sicherung)
├── Store/
│   ├── AppStore.swift           Hält die Daten, speichert und lädt sie
│   └── LockController.swift     Wann Homy zu ist und wann wieder gefragt wird
├── Support/
│   ├── SchoolCalendar.swift     Wochen- und Datumsberechnungen (Woche ab Montag)
│   ├── AppTheme.swift           Farben (je Fach ein heller und ein kräftiger Ton)
│   ├── Haptics.swift            Kurze Rückmeldung beim Antippen
│   ├── HomyLogo.swift           Das Zeichen von Homy, gezeichnet statt als Bild
│   ├── BiometricAuth.swift      Face ID / Touch ID über LocalAuthentication
│   ├── DoodleBackground.swift   Schulmotive blass hinter den Schreib-Seiten
│   ├── TimetableRecognizer.swift  Texterkennung und Rasteranalyse für den Scan
│   └── BackupDocument.swift     Sicherungsdatei
├── Views/
│   ├── RootView.swift           Die fünf Tabs
│   ├── Lock/                    Anmeldebild, Code einrichten, Tür vor der App
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
