# Homy veröffentlichen

Diese Seite ist die Arbeitsanleitung zum Veröffentlichen – mit allen Texten
fertig zum Einfügen. Was hier in einem Kasten steht, kannst du kopieren.

Zuerst das Wichtigste, damit du weißt, woran du bist:

> **Eine iOS-App kann niemand außer dir selbst in den App Store stellen.**
> Apple nimmt Apps nur von einem Entwickler-Konto an, und dieses Konto muss
> auf eine echte volljährige Person laufen, die die Verträge unterschreibt.
> Gebaut und hochgeladen wird ausschließlich von einem Mac mit Xcode.
> Beides gibt es hier nicht – also ist das Hochladen dein Teil.
> Alles, was man vorher erledigen kann, ist erledigt.

Es gibt zwei Wege, und sie schließen sich nicht aus.

---

## Weg A: Homy heute als Webseite veröffentlichen

Das geht sofort, kostet nichts und braucht keinen Mac. Danach kann jeder, dem
du den Link schickst, Homy im Browser ausprobieren.

Im Ordner `docs/` liegt dafür schon alles fertig:

| Datei | Was daraus wird |
|---|---|
| `index.html` | die Startseite |
| `vorschau.html` | Homy zum Ausprobieren |
| `quelltext.html` | der Quelltext mit Kopier-Knopf |
| `datenschutz.html` | die Datenschutzerklärung |

**So schaltest du es ein** (einmalig, dauert eine Minute):

1. Diese Seite öffnen:
   `https://github.com/wolfiebu-ship-it/Hausaufgaben-App-designed-by-Ebu/settings/pages`
2. Bei *Source* **„Deploy from a branch“** wählen.
3. Darunter bei *Branch* den Zweig `claude/homework-schedule-app-y91c1u`
   wählen und daneben den Ordner **`/docs`**.
4. Auf **Save**.

Danach baut GitHub die Seite bei jedem Push von selbst neu – du musst das
nie wieder anfassen.

> **Diesen einen Klick kann ich dir nicht abnehmen, und ich habe es zweimal
> versucht:** Einmal über einen Actions-Ablauf mit `configure-pages`
> (`enablement: true`) – GitHub antwortet *„Resource not accessible by
> integration“*, ein Ablauf-Token darf keine Pages-Seite anlegen. Und einmal
> direkt über die GitHub-API mit meinen Push-Rechten – die Umgebung, in der
> ich laufe, lässt den Pages-Pfad nicht durch (*„Access to this GitHub API
> path is not permitted through this proxy“*). Eine Pages-Seite anzulegen ist
> eine Einstellung am Repository, und die gehört dem Besitzer: dir.

Nach ein paar Minuten ist Homy erreichbar unter:

```
https://wolfiebu-ship-it.github.io/Hausaufgaben-App-designed-by-Ebu/
```

Diese Adresse brauchst du gleich noch einmal – Apple verlangt eine
Datenschutz-Adresse, und das wird dann:

```
https://wolfiebu-ship-it.github.io/Hausaufgaben-App-designed-by-Ebu/datenschutz.html
```

> **Vorher ausfüllen:** In `docs/datenschutz.html` sind drei Stellen gelb
> markiert – Name, Anschrift und eine E-Mail-Adresse. Die müssen da stehen,
> bevor die Seite online geht. Das ist keine Formalie: Für eine öffentliche
> Seite verlangt das Gesetz eine erreichbare verantwortliche Person, und
> weil du minderjährig bist, sind das deine Eltern.

---

## Weg B: In den App Store

### 1. Was du brauchst

| | |
|---|---|
| **Mac mit Xcode** | Ohne geht es nicht. Eine iOS-App lässt sich nur auf einem Mac bauen und hochladen. |
| **Apple Developer Program** | 99 € im Jahr, jährlich neu. Ohne diese Mitgliedschaft geht weder App Store noch TestFlight. |
| **Eine volljährige Person** | Apple vergibt Entwickler-Konten nur an Volljährige. Das Konto läuft auf deine Eltern, und sie unterschreiben die Verträge. Das lässt sich nicht umgehen – es ist ein echter Vertrag mit Apple. |
| **Eine Support-Adresse** | Eine E-Mail-Adresse genügt. Apple verlangt sie als Kontakt und zeigt sie im Store an. |
| **Die Datenschutz-Adresse** | Siehe Weg A. |

### 2. Was im Projekt schon fertig ist

- App-Symbol in 1024 px, eigener Name „Homy“
- `MARKETING_VERSION = 1.0`, `CURRENT_PROJECT_VERSION = 1`
- Bundle-Kennung `de.ebu.HausaufgabenApp`
- Texte für Kamera, Fotos und Face ID (verlangt Apple, sonst Ablehnung)
- `PrivacyInfo.xcprivacy` – der Datenschutzbericht, den Apple seit 2024 verlangt
- `ITSAppUsesNonExemptEncryption = NO` – die Ausfuhr-Erklärung, damit du nicht
  bei jedem Hochladen danach gefragt wirst

> Zur Ausfuhr-Erklärung: Homy verschlüsselt nichts. Der Code wird nur mit
> SHA-256 zu einem Prüfwert verrechnet, und Hashen ist keine Verschlüsselung.
> Deshalb ist „NO“ richtig. Lies die Frage in App Store Connect trotzdem
> selbst – es ist eine rechtliche Erklärung, die du abgibst, nicht ich.

### 3. Was du noch einstellen musst

In Xcode, im Ziel `HausaufgabenApp` unter *Signing & Capabilities*:

- **Team** auf euer Entwickler-Konto stellen (steht jetzt auf leer)
- **Bundle Identifier** prüfen. `de.ebu.HausaufgabenApp` ist frei wählbar,
  muss aber weltweit einmalig sein und lässt sich nach der Veröffentlichung
  **nie wieder ändern**. Üblich ist die eigene Domain rückwärts.

### 4. Bildschirmfotos

Apple verlangt echte Aufnahmen aus der App, keine Nachbauten. Nimm sie im
Simulator auf (Xcode → *Window* → *Devices and Simulators*, dann `⌘S`):

| Gerät | Größe | Anzahl |
|---|---|---|
| iPhone 6,9″ (z. B. 16 Pro Max) | 1290 × 2796 | 3 bis 10 |
| iPhone 6,5″ (z. B. 11 Pro Max) | 1242 × 2688 | 3 bis 10 |
| iPad Pro 13″ | 2064 × 2752 | 3 bis 10, nur wenn du iPad anbietest |

Gute Reihenfolge: Hausaufgaben-Woche, Kalender mit Monat und Punkten,
Stundenplan, Termin eintragen, Anmeldebild.

> Fülle die App vorher mit echt wirkenden Daten. Leere Bildschirme sind ein
> häufiger Ablehnungsgrund – und erfundene Noten oder fremde Namen gehören
> nicht auf ein Bild, das im Store steht.

### 5. Die Texte für App Store Connect

**Name** (höchstens 30 Zeichen)

```
Homy – Hausaufgabenheft
```

**Untertitel** (höchstens 30 Zeichen)

```
Hausaufgaben, Plan, Termine
```

**Schlüsselwörter** (höchstens 100 Zeichen, mit Komma getrennt, ohne Leerzeichen)

```
hausaufgaben,stundenplan,schule,schüler,hausaufgabenheft,planer,ferien,unterricht,noten,lernen
```

**Werbetext** (höchstens 170 Zeichen, jederzeit änderbar)

```
Dein Hausaufgabenheft für die Schule: eine Seite pro Woche, dein Stundenplan zum Abfotografieren und Erinnerungen vor jeder Arbeit. Alles bleibt auf deinem Gerät.
```

**Beschreibung**

```
Homy ist ein Hausaufgabenheft für die Schule – aufgeräumt, bunt und ohne alles,
was du nicht brauchst. Kein Konto, keine Anmeldung, keine Werbung. Deine Daten
bleiben auf deinem Gerät.

HAUSAUFGABEN
Eine Seite pro Woche, waagerecht zum Blättern. Jeder Tag ist eine Karte, und
die Kürzel deiner Fächer stehen schon da – du musst nur noch schreiben, was
aufgegeben wurde. Zwei Felder je Zeile: gelb ankreuzen heißt „in dem Fach ist
nichts auf“, blau heißt „erledigt“. Ein Blick auf den zugeklappten Tag genügt,
und du weißt, was noch offen ist. Die Suche geht über alle Wochen und alle
Notizen.

KALENDER UND ERINNERUNGEN
Trag Arbeiten, Tests, Abgaben und Ausflüge ein. Homy meldet sich vorher – am
Abend davor, eine Stunde vorher, zwei Tage oder eine Woche, ganz wie du willst.
Ferien sind ein eigener Eintrag mit Anfang und Ende; die App sagt dir dazu, wie
lange sie dauern und wann der erste Schultag danach ist.

DEIN BUNDESLAND
Stell dein Bundesland ein, und Homy trägt die gesetzlichen Feiertage von selbst
ein – auch für die kommenden Jahre, ohne Internet. Die Schulferien musst du
einmal selbst eintragen: Die legt jedes Land für jedes Schuljahr neu fest, und
erfundene Termine wären schlimmer als gar keine.

STUNDENPLAN ABFOTOGRAFIEREN
Fotografier deinen Plan ab, und Homy liest ihn: Fächer, die es noch nicht gibt,
legt die App selbst an, und die Unterrichtszeiten übernimmt sie gleich mit. Du
siehst das Ergebnis und kannst es ändern, bevor es übernommen wird. Das Foto
bleibt auf deinem Gerät.

NOTIZEN
Aufgebaut wie die Notizen, die du kennst: antippen, lostippen. Kein Titelfeld,
kein Sichern-Knopf.

ANMELDUNG
Wenn du willst, öffnet sich Homy nur mit deinem Zahlencode – oder mit Face ID.
Gespeichert wird dabei nie dein Code, sondern nur ein Prüfwert daraus.

DATENSCHUTZ, EHRLICH
Homy baut keine Verbindung ins Internet auf. Es gibt keinen Server, kein Konto,
keine Werbung, keine Analyse und keine fremden Bibliotheken. Alles, was du
einträgst, liegt in einer Datei auf deinem Gerät, und eine Sicherung davon
kannst du jederzeit selbst speichern.

Für iPhone und iPad. Auf dem iPad mit Tastaturkürzeln.
```

**Support-URL**

```
https://github.com/wolfiebu-ship-it/Hausaufgaben-App-designed-by-Ebu
```

**Marketing-URL** (freiwillig)

```
https://wolfiebu-ship-it.github.io/Hausaufgaben-App-designed-by-Ebu/
```

**Datenschutz-URL** (Pflicht)

```
https://wolfiebu-ship-it.github.io/Hausaufgaben-App-designed-by-Ebu/datenschutz.html
```

**Kategorie**

- Primär: *Bildung*
- Sekundär: *Produktivität*

**Hinweise für die Prüfung** (das Feld „Notes“)

```
Die App braucht keinen Zugang und kein Testkonto. Es gibt keine Anmeldung und
keine Serververbindung; alle Daten liegen auf dem Gerät.

Die Code-Sperre ist ab Werk ausgeschaltet. Wer sie ausprobieren möchte:
Einstellungen > Anmeldung > einschalten, dann einen beliebigen Code vergeben.

Das Abfotografieren des Stundenplans braucht die Kamera. Im Simulator lässt es
sich über "Foto aus der Mediathek wählen" mit einem beliebigen Bild eines
Stundenplans ausprobieren.
```

### 6. Die Fragebögen

**Altersfreigabe** – überall „Keine“ bzw. „Nein“ ankreuzen. Homy hat keine
Gewalt, keine Themen für Erwachsene, kein Glücksspiel, keine Käufe, keine
Werbung, keinen unbeschränkten Webzugang, keinen Standort und keinen Chat.
Ergebnis: **4+**.

**App-Datenschutz** – die Frage „Erfasst diese App Daten?“ beantwortest du mit
**„Nein, wir erfassen keine Daten“**. Das stimmt: keine Analyse, keine Werbung,
kein Netzwerk, keine Weitergabe. Danach kommt kein weiterer Fragebogen.

**Ausfuhr** – „Verwendet die App Verschlüsselung?“ ist bereits im Projekt mit
*Nein* beantwortet (siehe oben).

### 7. Hochladen

1. In Xcode oben das Ziel auf **Any iOS Device (arm64)** stellen.
2. Menü **Product → Archive**. Das dauert ein paar Minuten.
3. Im Organizer, der danach aufgeht: **Distribute App → App Store Connect →
   Upload**.
4. Auf App Store Connect (`appstoreconnect.apple.com`) den neuen Build
   auswählen, die Texte oben einfügen, Bildschirmfotos hochladen.
5. **Zur Prüfung einreichen.**

Die Prüfung dauert meist ein bis drei Tage. Eine Ablehnung ist nichts
Schlimmes und kommt immer mit einer Begründung – man bessert nach und reicht
erneut ein. Das passiert fast jedem beim ersten Mal.

### 8. Was am häufigsten schiefgeht

- **Bildschirmfotos mit leerer App.** Vorher ausfüllen.
- **Support-Adresse antwortet nicht.** Apple schreibt dort manchmal hin.
- **Datenschutz-Adresse nicht erreichbar.** Erst Weg A einschalten, dann die
  Adresse im Browser aufrufen und prüfen, bevor du einreichst.
- **Berechtigungstexte zu vage.** Bei Homy stehen sie schon drin und sagen
  genau, wofür die Kamera gebraucht wird.
- **Minderjährige als Kontoinhaber.** Geht nicht. Das Konto muss auf deine
  Eltern laufen.

---

## Der kleinere Weg: nur für dich

Du musst nichts davon tun, um Homy zu benutzen. Mit einem Mac und einem
kostenlosen Apple-Konto lädst du die App direkt auf dein iPhone – die
Installation hält sieben Tage und wird mit einem Klick erneuert. Für dich und
deine Familie reicht das völlig und kostet nichts. Die Schritte stehen in der
`README.md` unter „Die App aufs iPhone oder iPad bringen“.
