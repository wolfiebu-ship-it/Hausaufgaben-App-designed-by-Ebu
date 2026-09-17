<img src="docs/homy-logo.png" alt="" width="104" align="left" hspace="14" vspace="4">

# Homy

**Dein Hausaufgabenheft für iPhone und iPad.** Die Hausaufgaben des Tages eintragen und den eigenen Stundenplan immer dabeihaben.

<br clear="left">

Geschrieben in Swift/SwiftUI als native App für iPhone **und** iPad. Alle Daten bleiben auf dem Gerät – kein Konto, kein Internet, keine Werbung.

---

## Was die App kann

### 1. Hausaufgaben eintragen

- **Eine Seite pro Woche.** Ist die Woche voll, blätterst du einfach nach rechts zur nächsten Woche – mit einem Wisch oder über die Pfeile oben. Über den Titel („Diese Woche“) springst du per Kalender zu jeder beliebigen Woche.
- **Am Bildschirm mit Maus** (also am PC) stehen die Wochentage **untereinander und alle offen** – Montag, Dienstag, Mittwoch, Donnerstag, Freitag, jeder mit seinen Fächern zum Direkt-Hineinschreiben. Nichts klappt auf und zu, und der Inhalt läuft nicht über die ganze Bildschirmbreite auseinander. Erkannt wird das an `(min-width: 900px) and (hover: hover)`: Ein iPad im Querformat ist zwar breit, hat aber keinen Mauszeiger und bleibt darum bei der Tablet-Ansicht. *(Betrifft nur die Browser-Vorschau – die native App läuft auf iPhone und iPad.)*
- **Tage zum Aufklappen** (auf iPhone und iPad). Beim Öffnen sind alle Tage zugeklappt, sodass die ganze Woche auf einen Blick passt. Der zugeklappte Kopf zeigt schon, was ansteht: die Kürzel der Fächer mit Eintrag (Erledigtes blasser), die Anzahl offener Aufgaben, „Keine Hausaufgaben“ oder „Nichts eingetragen“. Ein Tipp auf den Tag klappt ihn zum Eintragen auf.
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

### 2. Kalender und Erinnerungen

Ein eigener Tab für alles, was an einem bestimmten Tag ansteht – Arbeiten, Tests, Abgaben, Ausflüge.

- **Der Monat auf einen Blick.** Unter jedem Tag stehen kleine Punkte: **grün** für einen Ferientag, je ein farbiger für einen Termin (die Farbe sagt, was für einer) und ein grauer, wenn an dem Tag noch Hausaufgaben offen sind. Was die Punkte bedeuten, steht als Legende direkt darunter. Der heutige Tag ist umrandet.
- **Termin eintragen:** Titel, Art (Arbeit, Test, Abgabe, Ausflug, Schulfrei, Sonstiges), Fach, Tag, wahlweise eine Uhrzeit und eine Notiz für Einzelheiten. Jede Art hat ihre Farbe: rot Arbeit, orange Test, lila Abgabe, braun Ausflug, grün Schulfrei, grau Sonstiges.
- **„Als Nächstes"** steht über dem Monat und zeigt die drei nächsten Termine mit „in 5 Tagen“, „morgen“, „heute“.
- **Tippst du einen Tag an**, steht direkt unter dem Monat, was für ein Tag das ist und was ansteht:
  - ein **grüner Tag** sagt, warum er frei ist – „Herbstferien · Tag 4 von 12“, „Tag der Deutschen Einheit · Gesetzlicher Feiertag in Nordrhein-Westfalen“. Fällt ein Feiertag mitten in die Ferien, steht beides da („… · fällt in die Ferien“);
  - ein **Samstag oder Sonntag** sagt „Wochenende · Kein Schultag“;
  - darunter die Termine des Tages, die Hausaufgaben (zum Nachsehen – geändert werden sie im Hausaufgabenheft) und die Stunden aus dem Stundenplan.
  
  Im Kopf der Karte steht bei freien Tagen zusätzlich ein grünes **„Frei“**.

#### Ferien

Ferien sind keine einzelnen Termine, sondern Zeiträume – dafür gibt es einen eigenen Eintrag mit **Anfang und Ende**.

- **Eintragen** über das Plus oben rechts → *Ferien eintragen*: Name (mit Vorschlägen wie Herbstferien, Weihnachtsferien, Osterferien …), erster Ferientag, letzter Ferientag, wahlweise eine Notiz.
- Der **letzte Ferientag zählt noch dazu** – einzutragen ist der Tag, an dem du noch frei hast, nicht der erste Schultag danach. Schon im Formular steht darum in Worten, was daraus wird:

  | | |
  |---|---|
  | Anfang | Mittwoch, 23. Dezember 2026 |
  | Ende | Mittwoch, 6. Januar 2027 |
  | Dauer | 15 Tage |
  | Wieder Schule | Donnerstag, 7. Januar 2027 |

- **Im Monatsraster** bekommt jeder Ferientag einen **grünen Punkt** – der erste, der letzte und alle dazwischen. Zusätzlich sind die Ferientage grün hinterlegt, damit man den Zeitraum am Stück sieht und erkennt, wo er anfängt und wo er aufhört.
- **Direkt unter dem Monat steht, was die Punkte bedeuten:** grün = Ferien, farbig = ein Termin, grau = an dem Tag sind noch Hausaufgaben offen. Ausführlicher steht dasselbe in den Einstellungen unter „Die Punkte im Kalender“.
- **Unter dem Monat** steht die Liste aller Ferien: Name, „Von Montag, 19. Oktober 2026“, „Bis Freitag, 30. Oktober 2026“, die Dauer und der erste Schultag danach. Rechts daneben ein Countdown: „in 33 Tagen“, „ab morgen“, „Tag 3 von 12“ oder „vorbei“.
- **Der erste Schultag danach** wird richtig gerechnet: Wochenenden werden übersprungen (und der Samstag nur mitgezählt, wenn du ihn in den Einstellungen als Schultag hast), ebenso direkt anschließende weitere Ferien.
- **Tippst du einen Ferientag an**, steht darunter „Erster Ferientag · 12 Tage lang“, „Ferien · Tag 3 von 12“ oder „Letzter Ferientag · wieder Schule am Montag“ – ein Tipp darauf öffnet die Ferien zum Ändern. An Ferientagen blendet der Kalender die Stunden aus dem Stundenplan aus, und im Hausaufgabenheft zeigt der zugeklappte Tag den Namen der Ferien.
- **Auch Ferien können erinnern** – voreingestellt am Abend vor dem ersten Ferientag.
- Vertauschst du Anfang und Ende, rückt Homy es beim Sichern gerade.

> **Die Ferientermine bringt Homy nicht mit.** Sie sind in jedem Bundesland und jedem Schuljahr anders, und erfundene Daten wären schlimmer als gar keine – darum trägst du sie einmal aus dem Ferienplan deiner Schule ein. Für einen einzelnen freien Tag (beweglicher Ferientag, Feiertag) reicht auch ein normaler Termin mit der Art „Schulfrei“.

#### Bundesland und Feiertage

In den Einstellungen lässt sich das **Bundesland** einstellen. Damit trägt Homy die **gesetzlichen Feiertage** von selbst in den Kalender ein – grün wie die Ferien, mit Namen unter dem Tag.

- Das geht **ohne Internet und ohne hinterlegte Listen**: Die festen Feiertage stehen im Kalender, die beweglichen hängen alle am Ostersonntag, und der lässt sich für jedes Jahr ausrechnen (gregorianische Osterformel). Deshalb stimmt es auch in den kommenden Jahren, ohne dass jemand etwas nachpflegen muss.
- Berücksichtigt sind die neun bundesweiten Feiertage plus die des jeweiligen Landes: Heilige Drei Könige, Internationaler Frauentag, Ostersonntag und Pfingstsonntag (Brandenburg), Fronleichnam, Mariä Himmelfahrt, Weltkindertag, Reformationstag, Allerheiligen und der Buß- und Bettag in Sachsen.
- In den Einstellungen stehen gleich **die nächsten vier Feiertage** mit Wochentag und Datum – so siehst du sofort, ob das Richtige eingestellt ist.
- Tippst du im Kalender auf einen Feiertag, steht sein **Name** darunter, dazu „Gesetzlicher Feiertag in …“.
- An Feiertagen blendet der Kalender die Stunden aus dem Stundenplan aus, und der erste Schultag nach den Ferien überspringt sie.

> **Die Schulferien kann Homy nicht ausrechnen.** Die legt jedes Land für jedes Schuljahr neu fest; sie folgen keiner Formel. Erfundene Termine wären schlimmer als gar keine – darum trägst du die Ferien einmal aus dem Ferienplan deiner Schule ein (siehe oben). Ohne eingestelltes Bundesland zeigt Homy gar keine Feiertage, statt womöglich falsche.

> Zwei Feinheiten, die Homy nicht kennen kann: In **Bayern** ist Mariä Himmelfahrt nur in überwiegend katholischen Gemeinden frei – das steht als Hinweis dabei. In einzelnen Gemeinden in **Sachsen und Thüringen** kann zusätzlich Fronleichnam frei sein; das ist nicht mit drin. Genauso wenig örtliche Feiertage wie das Augsburger Friedensfest.

#### Die Erinnerung

Trägst du einen Termin oder Ferien ein, meldet sich Homy von selbst rechtzeitig – auch wenn die App gar nicht offen ist.

- Voreingestellt ist **am Abend davor um 18:00 Uhr**, wenn noch Zeit zum Lernen ist. Je Termin wählbar sind außerdem: wenn es losgeht, 1 Stunde vorher, 2 Tage vorher, 1 Woche vorher – oder gar keine.
- Im Formular steht immer darunter, **wann die Benachrichtigung genau käme**. Liegt der Zeitpunkt schon in der Vergangenheit, sagt Homy das auch.
- In der Benachrichtigung stehen der Titel, die Art und das Fach, dazu „Morgen um 8:00 Uhr“ oder „In 2 Tagen (Do, 24.9.)“.
- Beim **ersten Mal fragt iOS um Erlaubnis** – und zwar erst dann, wenn du wirklich eine Erinnerung einstellst, nicht schon beim Start der App. Sagst du Nein, steht das als Hinweis in den Einstellungen, mit einem Knopf zu den iPhone-Einstellungen.
- In den Einstellungen unter **Erinnerungen** lässt sich alles zusammen abschalten und die Voreinstellung für neue Termine ändern.

> Die Benachrichtigung schickt **iOS**, nicht Homy: Die App übergibt nur Text und Zeitpunkt, den Rest macht das System. Es geht nichts ins Internet, und es braucht keinen Server. iOS merkt sich höchstens 64 solcher Erinnerungen je App – Homy stellt darum die nächsten 56 und schiebt weiter entfernte beim nächsten Öffnen nach. Wer sehr viele Termine weit im Voraus einträgt, bekommt für die entferntesten also erst später eine Erinnerung gestellt.

### 3. Stundenplan

- Raster mit den Wochentagen als Spalten und den Stunden als Zeilen.
- Auf ein Feld tippen → Fach auswählen, fertig. Raum und Lehrkraft lassen sich für einzelne Stunden abweichend eintragen.
- Einstellbar: Anzahl der Stunden pro Tag (1–14), Samstag als sechster Schultag, Unterrichtszeiten je Stunde.
- Der heutige Wochentag ist hervorgehoben.

### 4. Stundenplan abfotografieren

Statt jedes Feld einzeln einzutippen, lässt sich der eigene Stundenplan scannen:

1. **Aufnehmen** – Apples Dokumentenscanner erkennt den Papierrand und entzerrt das Bild. Alternativ ein vorhandenes Foto aus der Mediathek.
2. **Lesen** – die Texterkennung liest die Kürzel und leitet aus ihrer Lage im Bild das Raster ab: welche Spalte welcher Wochentag ist und welche Zeile welche Stunde.
3. **Prüfen** – das Ergebnis wird als Raster angezeigt. Falsch gelesene Felder tippst du an und korrigierst sie; unbekannte Kürzel lassen sich mit einem Tipp als neue Fächer anlegen.
4. **Übernehmen** – erst dann wird der Stundenplan ersetzt.

Der Prüfschritt ist Absicht: Ein Foto kann schief, dunkel oder handgeschrieben sein, und dann liest die Erkennung Dinge falsch. **Gedruckte Pläne funktionieren deutlich besser als handgeschriebene.**

Alles läuft auf dem Gerät – das Foto wird nicht hochgeladen und nirgends gespeichert. Beim ersten Scan fragt iOS nach der Kameraerlaubnis.

> Der Dokumentenscanner braucht eine echte Kamera und funktioniert deshalb **nicht im Simulator**. Zum Ausprobieren am Mac lässt sich stattdessen ein Foto aus der Mediathek wählen.

> **In der Browser-Vorschau** gibt es das Foto und die Vorlage, aber keine automatische Texterkennung: Eine eingebettete Seite darf die dafür nötige Bibliothek nicht nachladen. Dort nimmst du das Foto auf, es bleibt über dem Raster stehen, und du tippst den Plan daneben ab.

### 5. Notizen

Ein eigener Tab unten für alles, was man sich aufschreiben will – aufgebaut wie Apples Notizen-App.

- Oben steht **ein Feld: „Notiz schreiben …“**. Antippen, die Tastatur kommt, lostippen. Mehr braucht es nicht.
- **Kein Titelfeld, kein Sichern-Knopf.** Die erste beschriebene Zeile wird automatisch zum Titel; gespeichert wird während des Schreibens.
- Darunter stehen die eigenen Notizen: Titel fett, daneben Uhrzeit bzw. Datum der letzten Änderung und der Anfang des Textes. Zuletzt bearbeitet zuerst.
- Antippen öffnet die Notiz wieder zum Weiterschreiben. Gelöscht wird über den Papierkorb in der geöffneten Notiz (mit Rückfrage) oder per langem Tippen in der Liste.
- Die App bringt **keine vorgefertigten Notizen** mit – hier steht nur, was du selbst schreibst.

> Anders als bei Apple wird die erste Zeile beim Schreiben nicht fett dargestellt, nur in der Liste. Für formatierten Text bräuchte es einen anderen Editor.

### 6. Fächer

Zu finden **im Stundenplan oben links** oder in den Einstellungen – seit dem Kalender haben die Fächer keinen eigenen Tab mehr (siehe *Technisches*).

- **Oben stehen die Stunden des Tages.** Ist heute Schule, siehst du „Heute · Montag“ mit allen Stunden dieses Tages in der Reihenfolge des Plans – mit Stundennummer, Uhrzeit und Raum. Am Wochenende oder an einem freien Tag springt die Liste auf den nächsten Schultag („Morgen · Montag“). Das stellt sich jeden Tag von allein um.
- Darunter **alle Fächer** alphabetisch zum Bearbeiten.
- Name, Kürzel, Farbe, Lehrkraft und Raum je Fach.
- Beim ersten Start sind typische Schulfächer schon angelegt (Deutsch, Mathematik, Englisch …) – umbenennen oder löschen, wie du möchtest.
- Das Kürzel ist genau das, was im Stundenplan und neben dem Hausaufgabenfeld steht.

### 7. Anmeldung

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

### 8. Einstellungen

- **Anmeldung** – Code einrichten, Schnellstart einschalten, sofort zusperren (siehe oben).
- **Erinnerungen** – an Termine und Ferien erinnern lassen, Voreinstellung für neue Einträge.
- **Fächer** – der zweite Weg zur Fächerliste (der erste ist im Stundenplan oben links).
- **Bundesland** – bestimmt die gesetzlichen Feiertage im Kalender (siehe oben).
- **Meine Daten** – ein eigener Bereich für die Angaben über dich: Vor- und Nachname, Klasse, Schule, Telefon, E-Mail, Adresse und ein freies Feld für alles Weitere (Spind-Nummer, Buslinie, Notfallkontakt). Alles freiwillig, nichts muss ausgefüllt werden.

  > Diese Angaben bleiben auf dem Gerät. Die App verschickt nichts und hat keine Verbindung ins Internet. Nur wenn du selbst eine Sicherung speicherst, stehen sie mit in dieser Datei – gib sie also nicht unbedacht weiter.

- **Die Felder im Hausaufgabenheft** – erklärt, was das gelbe und das blaue Feld bedeuten.
- **Die Punkte im Kalender** – erklärt den grünen (schulfrei), den farbigen (Termin) und den grauen Punkt (offene Hausaufgaben).
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
- **Die fünf Tabs** sind Hausaufgaben, Kalender, Stundenplan, Notizen und Einstellungen. Die **Fächer** haben keinen eigenen Tab mehr: Sie sitzen jetzt beim Stundenplan (oben links) und stehen zusätzlich in den Einstellungen. Grund ist iOS: Ab dem sechsten Tab faltet das iPhone alles Weitere in ein „Mehr“-Menü, und das wäre umständlicher als ein Tipp mehr. Die Liste „welche Stunden habe ich heute“ findest du außerdem im Kalender unter dem gewählten Tag.
- **Name auf dem Home-Bildschirm:** Homy (`CFBundleDisplayName`). Der Projekt- und Zielname im Xcode-Projekt heißt weiterhin `HausaufgabenApp`, ebenso die gespeicherte Datei – so bleiben vorhandene Installationen und Sicherungen lesbar.
- **Anmeldung:** CryptoKit (SHA-256 für den Prüfwert des Codes) und LocalAuthentication (Face ID / Touch ID). Beides gehört zu iOS, es kommt nichts dazu.
- **Erinnerungen:** UserNotifications mit `UNCalendarNotificationTrigger`. Termine und Ferien werden vorher zu einer gemeinsamen Liste von `ReminderItem` gerechnet. Nach jeder Änderung und einmal beim Start werden alle vorgemerkten Erinnerungen verworfen und die anstehenden neu gestellt – so passt das, was iOS vorgemerkt hat, immer zu dem, was im Kalender steht.
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
│   ├── CalendarEvent.swift      Ein Termin samt Erinnerungszeitpunkt
│   ├── Holiday.swift            Ferien: Zeitraum von … bis …
│   ├── FederalState.swift       Die 16 Bundesländer
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
│   ├── Reminders.swift          Benachrichtigungen bei iOS anmelden
│   ├── PublicHolidays.swift     Feiertage ausrechnen (Osterformel je Land)
│   ├── DoodleBackground.swift   Schulmotive blass hinter den Schreib-Seiten
│   ├── TimetableRecognizer.swift  Texterkennung und Rasteranalyse für den Scan
│   └── BackupDocument.swift     Sicherungsdatei
├── Views/
│   ├── RootView.swift           Die fünf Tabs
│   ├── Lock/                    Anmeldebild, Code einrichten, Tür vor der App
│   ├── Calendar/                Monatsraster, Termin- und Ferien-Formular
│   ├── Homework/                Hausaufgabenheft mit Wochenblättern
│   ├── Notes/                   Notizliste und Schreibblatt
│   ├── Timetable/               Stundenplan-Raster, Scannen und Prüfansicht
│   ├── Subjects/                Fächerverwaltung
│   └── Settings/                Einstellungen, Unterrichtszeiten
└── Assets.xcassets              App-Symbol und Akzentfarbe
```

---

## Homy veröffentlichen

Bis hierher läuft Homy auf deinen eigenen Geräten. In den App Store zu kommen ist ein eigener Schritt – hier ehrlich, was dafür nötig ist.

### Was Apple verlangt

| | |
|---|---|
| **Mac mit Xcode** | Ohne geht es nicht. Eine iOS-App lässt sich nur auf einem Mac bauen und hochladen. |
| **Apple Developer Program** | 99 € im Jahr. Ohne diese Mitgliedschaft geht weder App Store noch TestFlight. |
| **Volljährigkeit** | Apple vergibt Entwickler-Accounts nur an Volljährige. Als Schüler brauchst du dafür deine Eltern: Der Account läuft dann auf sie, und sie sind es auch, die die Vereinbarungen unterschreiben. Das ist keine Formalie, die man umgehen sollte – es ist ein Vertrag. |
| **App Store Connect** | Dort legst du den Eintrag an: Name, Beschreibung, Schlüsselwörter, Altersfreigabe, Bildschirmfotos in mehreren Größen und ein 1024-px-Symbol (hast du). |
| **Datenschutz-Angaben** | Bei Homy angenehm kurz: „Es werden keine Daten erfasst“. Homy hat keinen Server, keine Analyse, keine Werbung, keine Netzwerkzugriffe. Genau so kannst du es angeben. |
| **Prüfung** | Apple sieht sich jede App an, das dauert meist ein paar Tage. Ablehnungen sind normal und kommen mit einer Begründung; danach bessert man nach und reicht erneut ein. |

### Was Homy dafür schon mitbringt

- Ein eigenes App-Symbol in 1024 px und einen eigenen Namen.
- Keine fremden Bibliotheken – nichts, dessen Lizenz du angeben müsstest.
- Keine Datenerfassung, also eine unkomplizierte Datenschutz-Auskunft.
- Sinnvolle Texte für die Berechtigungen (Kamera, Fotos, Face ID) – die verlangt Apple, und sie stehen schon im Projekt.

### Was du dafür noch brauchst

- **Bildschirmfotos** aus dem Simulator in den von Apple verlangten Größen.
- Einen **Beschreibungstext** und ein paar Schlüsselwörter.
- Eine **Support-Adresse** (eine E-Mail reicht) – die verlangt Apple als Kontakt.
- Eine **Datenschutzerklärung** im Netz. Auch wenn Homy nichts erfasst: Apple will eine erreichbare Adresse. Ein kurzer Text auf einer GitHub-Pages-Seite genügt.

### Der kleinere Weg ohne Store

Ohne Mitgliedschaft kannst du Homy weiterhin **mit Xcode auf deine eigenen Geräte laden** (siehe oben). Die Installation hält dann sieben Tage und wird mit einem Klick erneuert. Für dich und deine Familie reicht das völlig – und kostet nichts.

---

## Den Quelltext zum Kopieren

`docs/quelltext.html` ist eine Seite, auf der **jede Datei einen eigenen Kopier-Knopf** hat – dazu „Alles kopieren“ für das ganze Projekt am Stück und ein Suchfeld. Ganz oben steht Homy noch einmal **als Prompt**: der ganze Bauplan in Worten, zum Einfügen bei einer KI.

Erzeugt wird die Seite aus dem echten Quelltext:

```
python3 docs/baue_quelltext_seite.py
```

Daneben liegen `docs/Homy-Quelltext.txt` (alles in einer Textdatei zum Lesen) und `docs/Homy-Quelltext.zip` (das komplette Projekt zum Bauen).

---

## Die Vorschau im Browser

Unter `docs/vorschau.html` liegt eine vollständige Nachbildung der Oberfläche als einzelne HTML-Datei – zum Anschauen und Ausprobieren ohne Mac. Darin funktioniert alles, was ein Browser kann:

| Funktioniert in der Vorschau | Nur in der gebauten App |
|---|---|
| Hausaufgaben eintragen, abhaken, „keine Hausaufgaben“ | |
| Wochen blättern, Suche über alle Wochen | |
| Kalender: Termine, Ferien, Feiertage je Bundesland | |
| Notizen schreiben | |
| Stundenplan ausfüllen, Fächer anlegen und ändern | |
| Unterrichtszeiten einstellen | |
| **Eigenen Code festlegen**, ändern, Anmeldung aus | Prüfwert statt Klartext (SHA-256) |
| **Schnellstart** – versucht Face ID/Touch ID über WebAuthn, sonst merkt er sich den Browser | Immer echtes Face ID / Touch ID |
| **Foto des Stundenplans** aufnehmen; es bleibt als Vorlage über dem Raster stehen | Automatische Texterkennung (Apple Vision) |
| Sicherung herauskopieren und einspielen | Sicherung als Datei, z. B. in iCloud Drive |
| Hell/dunkel, alle Erklärungen | Echte Benachrichtigungen von iOS |

Drei Dinge kann ein Browser prinzipiell nicht, und die sind deshalb nachgestellt statt echt:

- **Benachrichtigungen** – in der Vorschau erscheint zur Ansicht ein nachgebautes Banner. In der App schickt iOS sie wirklich, auch wenn Homy zu ist.
- **Texterkennung beim Scannen** – die Bibliothek dafür müsste Dateien nachladen, was eine eingebettete Seite nicht darf.
- **Herunterladen** – deshalb gibt es die Sicherung zum Kopieren statt als Datei.

---

## Wenn etwas nicht klappt

| Problem | Lösung |
|---|---|
| „Signing for … requires a development team“ | Schritt 3 der Anleitung: Team unter *Signing & Capabilities* auswählen. |
| „Failed to register bundle identifier“ | Den Bundle Identifier auf etwas Eindeutiges ändern, z. B. `de.deinname.hausaufgaben2`. |
| „Untrusted Developer“ auf dem Gerät | Schritt 5: Einstellungen → Allgemein → VPN & Geräteverwaltung → Vertrauen. |
| App startet nicht mehr nach einer Woche | Normal beim kostenlosen Account – in Xcode erneut auf ▶ drücken. |
| Beim Öffnen des Projekts erscheint eine Xcode-Warnung zur Projektversion | Xcode 16 oder neuer verwenden. |
