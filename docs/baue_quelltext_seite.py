#!/usr/bin/env python3
"""Baut eine Seite, auf der jede Datei von Homy einen Kopier-Knopf hat."""
import html
import pathlib

WURZEL = pathlib.Path("/home/user/Hausaufgaben-App-designed-by-Ebu")
ZIEL = pathlib.Path(__file__).with_name("quelltext.html")  # docs/quelltext.html

# ---------------------------------------------------------------- Dateien
def sammle():
    gruppen = []

    gruppen.append(("Projekt", [
        WURZEL / "HausaufgabenApp.xcodeproj" / "project.pbxproj",
        WURZEL / "HausaufgabenApp.xcodeproj" / "project.xcworkspace" / "contents.xcworkspacedata",
        WURZEL / "HausaufgabenApp" / "HausaufgabenApp.swift",
    ]))

    for ordner, titel in [("Models", "Models – die Daten"),
                          ("Store", "Store – hält und speichert alles"),
                          ("Support", "Support – Helfer")]:
        gruppen.append((titel, sorted((WURZEL / "HausaufgabenApp" / ordner).glob("*.swift"))))

    views = WURZEL / "HausaufgabenApp" / "Views"
    gruppen.append(("Views – der Einstieg", sorted(views.glob("*.swift"))))
    for unter, titel in [("Lock", "Views/Lock – Anmeldung"),
                         ("Homework", "Views/Homework – Hausaufgabenheft"),
                         ("Calendar", "Views/Calendar – Kalender"),
                         ("Notes", "Views/Notes – Notizen"),
                         ("Timetable", "Views/Timetable – Stundenplan"),
                         ("Subjects", "Views/Subjects – Fächer"),
                         ("Settings", "Views/Settings – Einstellungen")]:
        gruppen.append((titel, sorted((views / unter).glob("*.swift"))))

    gruppen.append(("Assets – Symbol und Farbe", sorted(
        (WURZEL / "HausaufgabenApp" / "Assets.xcassets").rglob("*.json"))))
    gruppen.append(("Beschreibung", [WURZEL / "README.md"]))
    return gruppen


PROMPT = """Bau mir eine native App für iPhone und iPad in Swift und SwiftUI.
Sie heißt Homy und ist ein Hausaufgabenheft für die Schule. Alles auf Deutsch –
die Oberfläche, die Kommentare im Code, die Variablennamen dürfen deutsch sein.

GRUNDSÄTZE
- Alle Daten bleiben auf dem Gerät. Kein Konto, kein Server, kein Netzwerkzugriff,
  keine Werbung, keine Analyse.
- Keine fremden Bibliotheken. Nur, was zu iOS gehört.
- Mindestversion iOS 17. Hoch- und Querformat, iPhone und iPad.
- Gespeichert wird eine einzige JSON-Datei im Dokumentenordner. Änderungen werden
  kurz gesammelt (0,4 s) und dann geschrieben; beim Verlassen der App sofort.
  Jedes Codable-Modell bekommt ein eigenes init(from:) mit decodeIfPresent und
  Standardwerten, damit alte Sicherungen nach einem Update weiter lesbar sind.

DIE FÜNF TABS
1. Hausaufgaben – eine Seite pro Woche, waagerecht blätterbar. Jeder Tag ist eine
   Karte, beim Öffnen zugeklappt; der zugeklappte Kopf zeigt die Kürzel der Fächer
   mit Eintrag, die Zahl der offenen Aufgaben oder "Keine Hausaufgaben". Je Zeile:
   links das farbige Kürzel des Fachs aus dem Stundenplan, daneben das Eingabefeld,
   rechts zwei Felder zum Ankreuzen – gelb heißt "in dem Fach ist nichts aufgegeben",
   blau heißt "erledigt". Beide lassen sich bei jedem Fach ankreuzen und schließen
   einander aus. Über den Zeilen steht eine kleine Legende, was gelb und blau heißt.
   Unten "Fach ergänzen" für Vertretungsstunden. Oben rechts eine Lupe, die über
   alle Wochen und alle Notizen sucht; ein Treffer springt zu seiner Woche.
2. Kalender – ein Monatsraster. Unter jedem Tag kleine Punkte: grün = schulfrei
   (Ferien oder Feiertag), farbig = ein Termin (die Farbe sagt die Art), grau =
   an dem Tag sind noch Hausaufgaben offen. Direkt darunter eine Legende dazu.
   Tippt man einen Tag an, steht gleich unter dem Monat, was für ein Tag das ist:
   "Herbstferien · Tag 4 von 12", "Tag der Deutschen Einheit · Gesetzlicher
   Feiertag in Nordrhein-Westfalen", "Wochenende · Kein Schultag" – fällt ein
   Feiertag in die Ferien, steht beides da. Darunter die Termine des Tages, die
   Hausaufgaben zum Nachsehen und die Stunden aus dem Stundenplan (an freien Tagen
   ausgeblendet). Dann "Als Nächstes" mit den drei nächsten Terminen und Countdown,
   dann die Ferienliste.
   Termine: Titel, Art (Arbeit, Test, Abgabe, Ausflug, Schulfrei, Sonstiges), Fach,
   Tag, wahlweise Uhrzeit, Notiz.
   Ferien sind ein eigener Eintrag mit Anfang und Ende, weil sie ein Zeitraum sind:
   Name (mit Vorschlägen), erster und letzter Ferientag – der letzte zählt mit.
   Das Formular zeigt in Worten Anfang, Ende, Dauer und den ersten Schultag danach;
   der überspringt Wochenenden und direkt anschließende Ferien und Feiertage.
3. Stundenplan – Raster mit Wochentagen als Spalten und Stunden als Zeilen. Auf ein
   Feld tippen wählt das Fach; Raum und Lehrkraft lassen sich je Stunde abweichend
   setzen. Einstellbar: 1 bis 14 Stunden pro Tag, Samstag als sechster Schultag,
   Unterrichtszeiten je Stunde. Oben links führt ein Weg zu den Fächern, oben rechts
   das Abfotografieren.
4. Notizen – aufgebaut wie Apples Notizen: oben ein Feld "Notiz schreiben …",
   antippen, lostippen. Kein Titelfeld, kein Sichern-Knopf; die erste beschriebene
   Zeile wird der Titel, gespeichert wird beim Schreiben. Keine Beispielnotizen.
5. Einstellungen – Meine Daten (Vor- und Nachname, Klasse, Schule, Telefon, E-Mail,
   Adresse, freies Feld), Fächer, Bundesland, Erinnerungen, Anmeldung, die Erklärung
   der beiden Felder im Hausaufgabenheft, die Erklärung der Punkte im Kalender,
   hell/dunkel/automatisch, Stundenplan-Einstellungen, Sicherung, Über die App.

ANMELDUNG
Homy kann beim Öffnen einen Zahlencode verlangen (4 bis 8 Ziffern, ab Werk aus).
Eigenes Tastenfeld auf dem Anmeldebild, deckend, damit nichts durchscheint.
Gespeichert wird nur ein Prüfwert (SHA-256 mit Zufallsbeigabe über CryptoKit),
nie der Code. Ein Knopf "Schnellstart für mich einrichten" stellt Face ID bzw.
Touch ID (LocalAuthentication) ein und fragt nur noch beim Neustart nach; wann
gefragt wird, ist auch einzeln wählbar (jedes Mal, 5 Minuten, 1 Stunde, nur beim
Neustart). Nach fünf Fehlversuchen eine halbe Minute Pause. Freiwilliger Merkzettel
unter "Code vergessen?". Der Code steht nicht in den Sicherungsdateien, und ein
Zurücksetzen der Daten hebt die Anmeldung nicht auf.

ERINNERUNGEN
Termine und Ferien können erinnern, voreingestellt am Abend davor um 18 Uhr; je
Eintrag wählbar: wenn es losgeht, 1 Stunde, 2 Tage, 1 Woche vorher oder keine.
Über UserNotifications mit UNCalendarNotificationTrigger. Nach jeder Änderung und
beim Start werden alle vorgemerkten verworfen und die anstehenden neu gestellt,
höchstens 56 auf einmal (iOS lässt je App nur 64 zu). Nach der Erlaubnis wird erst
gefragt, wenn wirklich eine Erinnerung eingestellt wird.

BUNDESLAND UND FEIERTAGE
In den Einstellungen lässt sich eines der 16 Bundesländer wählen. Damit rechnet die
App die gesetzlichen Feiertage selbst aus – ohne hinterlegte Listen: die festen
stehen im Kalender, die beweglichen hängen am Ostersonntag (gregorianische
Osterformel). Je Land dazu: Heilige Drei Könige, Internationaler Frauentag, Oster-
und Pfingstsonntag (Brandenburg), Fronleichnam, Mariä Himmelfahrt, Weltkindertag,
Reformationstag, Allerheiligen, Buß- und Bettag (Sachsen, Mittwoch vor dem 23.11.).
Die Schulferien lassen sich NICHT ausrechnen – die legt jedes Land für jedes
Schuljahr neu fest. Also von Hand eintragen lassen und das auch so sagen, statt
Termine zu erfinden. Ohne eingestelltes Bundesland gar keine Feiertage zeigen.

STUNDENPLAN ABFOTOGRAFIEREN
Mit VisionKit (VNDocumentCameraViewController) den Plan aufnehmen, mit Vision
(VNRecognizeTextRequest) die Kürzel lesen und aus der Lage der Textkästchen im Bild
das Raster ableiten: Spalten sind die Wochentage, Zeilen die Stunden. Danach IMMER
ein Prüfschritt, in dem das Ergebnis als Raster gezeigt wird und falsch Gelesenes
angetippt und korrigiert werden kann; unbekannte Kürzel lassen sich als neue Fächer
anlegen. Erst dann übernehmen. Das Foto bleibt auf dem Gerät. Die Info.plist braucht
Texte für Kamera, Fotos und Face ID.

AUSSEHEN
Freundlich und bunt. Je Fach ein kräftiger Ton für die Schrift und eine helle Fläche
dahinter, zwölf Paare, hell und dunkel getrennt definiert. Blasse Schulsymbole
(Stift, Lineal, Zirkel …) als Hintergrund auf den Schreib-Seiten. Hell, dunkel oder
automatisch, für die ganze App. Grün bedeutet überall "frei" und sonst nichts.
Als Symbol ein Haus im Umriss, in dem ein Stift steckt, auf blau-violettem Verlauf.
Auf dem iPad Tastaturkürzel: Befehl + Pfeile blättern, Befehl + F sucht, Befehl + N
legt eine Notiz an. Kurze haptische Rückmeldung beim Ankreuzen und Aufklappen.

WIE DU MIT MIR REDEN SOLLST
Sag mir ehrlich, was nicht geht, statt es zu überspielen. Wenn etwas nicht
ausrechenbar ist (Schulferien) oder eine Umgebung etwas nicht zulässt, schreib das
in die App und sag es mir – erfundene Daten sind schlimmer als gar keine."""


def datei_karte(pfad, nummer):
    rel = pfad.relative_to(WURZEL).as_posix()
    text = pfad.read_text()
    zeilen = text.count("\n") + (0 if text.endswith("\n") else 1)
    sprache = {".swift": "Swift", ".md": "Markdown", ".json": "JSON",
               ".pbxproj": "Xcode-Projekt"}.get(pfad.suffix, "Text")
    return f"""<article class="datei" data-suche="{html.escape(rel.lower())}">
  <header class="dateikopf">
    <div class="dateiname">
      <span class="nummer">{nummer:02d}</span>
      <h3>{html.escape(pfad.name)}</h3>
      <p class="pfad">{html.escape(rel)}</p>
    </div>
    <div class="dateitat">
      <span class="marke">{sprache} · {zeilen} Zeilen</span>
      <button type="button" class="kopf-knopf" data-kopiere>Kopieren</button>
    </div>
  </header>
  <div class="codehuelle">
    <pre class="code"><code>{html.escape(text)}</code></pre>
    <button type="button" class="mehr" data-mehr>Ganz anzeigen</button>
  </div>
</article>"""


def baue():
    gruppen = sammle()
    anzahl = sum(len(d) for _, d in gruppen)
    zeilen_gesamt = sum(
        f.read_text().count("\n") + 1 for _, d in gruppen for f in d)

    teile, nummer = [], 0
    for titel, dateien in gruppen:
        if not dateien:
            continue
        teile.append(f'<h2 class="gruppe">{html.escape(titel)}'
                     f'<span class="gruppenzahl">{len(dateien)}</span></h2>')
        for f in dateien:
            nummer += 1
            teile.append(datei_karte(f, nummer))
    karten = "\n".join(teile)

    return TEMPLATE.replace("{{KARTEN}}", karten) \
                   .replace("{{ANZAHL}}", str(anzahl)) \
                   .replace("{{ZEILEN}}", f"{zeilen_gesamt:,}".replace(",", ".")) \
                   .replace("{{PROMPT}}", html.escape(PROMPT))


TEMPLATE = r"""<title>Homy Quelltext</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Instrument+Sans:ital,wght@0,400;0,500;0,600;0,700&family=JetBrains+Mono:wght@400;500;700&display=swap">
<style>
  :root {
    --grund:        #F4F6FB;
    --flaeche:      #FFFFFF;
    --code-grund:   #F8F9FD;
    --linie:        #DCE1EE;
    --linie-zart:   #E8EBF4;
    --tinte:        #151A26;
    --tinte-leise:  #5B6478;
    --tinte-zart:   #8A93A8;
    --akzent:       #3257E0;
    --akzent-flach: #E7ECFD;
    --stift:        #B97A05;
    --stift-flach:  #FDF1D9;
    --gruen:        #1E8E3E;
  }
  @media (prefers-color-scheme: dark) {
    :root:not([data-theme="light"]) {
      --grund:        #0F121A;
      --flaeche:      #171B26;
      --code-grund:   #12151E;
      --linie:        #2A3040;
      --linie-zart:   #222736;
      --tinte:        #E8EBF3;
      --tinte-leise:  #A0A9BE;
      --tinte-zart:   #6E778C;
      --akzent:       #8DA9FF;
      --akzent-flach: #1C2440;
      --stift:        #F0B84D;
      --stift-flach:  #2C2312;
      --gruen:        #74DFA2;
    }
  }
  :root[data-theme="dark"] {
    --grund:        #0F121A;
    --flaeche:      #171B26;
    --code-grund:   #12151E;
    --linie:        #2A3040;
    --linie-zart:   #222736;
    --tinte:        #E8EBF3;
    --tinte-leise:  #A0A9BE;
    --tinte-zart:   #6E778C;
    --akzent:       #8DA9FF;
    --akzent-flach: #1C2440;
    --stift:        #F0B84D;
    --stift-flach:  #2C2312;
    --gruen:        #74DFA2;
  }

  * { box-sizing: border-box; }

  body {
    margin: 0;
    background: var(--grund);
    color: var(--tinte);
    font-family: "Instrument Sans", ui-sans-serif, system-ui, -apple-system, sans-serif;
    font-size: 16px;
    line-height: 1.55;
    -webkit-font-smoothing: antialiased;
  }

  .huelle { max-width: 940px; margin: 0 auto; padding-inline: 20px; padding-block: 0 64px; }

  /* ---------------------------------------------------------- Kopfleiste */
  .leiste {
    position: sticky;
    top: env(safe-area-inset-top, 0px);
    z-index: 10;
    background: color-mix(in srgb, var(--grund) 92%, transparent);
    backdrop-filter: blur(14px);
    -webkit-backdrop-filter: blur(14px);
    border-bottom: 1px solid var(--linie-zart);
  }
  .leisteninhalt {
    max-width: 940px; margin: 0 auto;
    padding: 12px 20px;
    display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
  }
  .zeichen { width: 34px; height: 34px; flex: none; }
  .leistenname { font-weight: 700; letter-spacing: -0.02em; font-size: 17px; }
  .leistenzahl {
    font-family: "JetBrains Mono", ui-monospace, monospace;
    font-size: 12px; color: var(--tinte-zart);
    font-variant-numeric: tabular-nums;
  }
  .suchfeld {
    margin-left: auto; flex: 1 1 180px; min-width: 150px; max-width: 280px;
    border: 1px solid var(--linie); border-radius: 9px;
    background: var(--flaeche); color: var(--tinte);
    font: inherit; font-size: 14px; padding: 7px 11px;
  }
  .suchfeld::placeholder { color: var(--tinte-zart); }
  .suchfeld:focus-visible { outline: 2px solid var(--akzent); outline-offset: 1px; }

  .knopf {
    border: 1px solid var(--akzent); border-radius: 9px;
    background: var(--akzent); color: #fff;
    font: inherit; font-size: 14px; font-weight: 600;
    padding: 7px 14px; cursor: pointer; white-space: nowrap;
  }
  .knopf:hover { filter: brightness(1.08); }
  .knopf:focus-visible { outline: 2px solid var(--tinte); outline-offset: 2px; }

  /* ------------------------------------------------------------- Auftakt */
  .auftakt { padding-block: 40px 8px; }
  .auftakt h1 {
    font-size: clamp(30px, 5.5vw, 44px); line-height: 1.1;
    letter-spacing: -0.03em; margin: 0 0 12px; text-wrap: balance;
  }
  .auftakt p { margin: 0; color: var(--tinte-leise); max-width: 62ch; }
  .zahlen {
    display: flex; gap: 22px; flex-wrap: wrap;
    margin-top: 20px; padding-top: 18px; border-top: 1px solid var(--linie-zart);
    font-family: "JetBrains Mono", ui-monospace, monospace;
    font-size: 13px; color: var(--tinte-leise);
    font-variant-numeric: tabular-nums;
  }
  .zahlen b { color: var(--tinte); font-weight: 700; }

  /* -------------------------------------------------------------- Prompt */
  .promptblock {
    margin-top: 32px;
    border: 1px solid var(--stift);
    border-radius: 14px;
    background: var(--flaeche);
    overflow: hidden;
  }
  .promptkopf {
    display: flex; align-items: flex-start; gap: 12px; flex-wrap: wrap;
    padding: 16px 18px;
    background: var(--stift-flach);
    border-bottom: 1px solid var(--stift);
  }
  .promptkopf h2 { margin: 0; font-size: 18px; letter-spacing: -0.02em; }
  .promptkopf p { margin: 4px 0 0; font-size: 14px; color: var(--tinte-leise); max-width: 60ch; }
  .promptkopf .knopf {
    margin-left: auto; background: var(--stift); border-color: var(--stift); color: #241A05;
  }

  /* --------------------------------------------------------- Dateikarten */
  .gruppe {
    display: flex; align-items: baseline; gap: 10px;
    margin: 40px 0 14px;
    font-size: 12px; font-weight: 600; letter-spacing: 0.1em; text-transform: uppercase;
    color: var(--tinte-leise);
  }
  .gruppe::after {
    content: ""; flex: 1; height: 1px; background: var(--linie-zart);
  }
  .gruppenzahl {
    order: 3;
    font-family: "JetBrains Mono", ui-monospace, monospace;
    font-size: 11px; color: var(--tinte-zart); letter-spacing: 0;
  }

  .datei {
    background: var(--flaeche);
    border: 1px solid var(--linie-zart);
    border-radius: 12px;
    margin-bottom: 12px;
    overflow: hidden;
  }
  .datei[hidden] { display: none; }
  .dateikopf {
    display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
    padding: 12px 14px;
  }
  .dateiname { flex: 1 1 220px; min-width: 0; display: flex; align-items: baseline; gap: 9px; flex-wrap: wrap; }
  .nummer {
    font-family: "JetBrains Mono", ui-monospace, monospace;
    font-size: 11px; color: var(--tinte-zart); font-variant-numeric: tabular-nums;
  }
  .dateiname h3 {
    margin: 0; font-size: 15px; font-weight: 600; letter-spacing: -0.01em;
    font-family: "JetBrains Mono", ui-monospace, monospace;
  }
  .pfad {
    margin: 0; font-size: 12px; color: var(--tinte-zart);
    overflow-wrap: anywhere;
  }
  .dateitat { display: flex; align-items: center; gap: 10px; margin-left: auto; }
  .marke {
    font-family: "JetBrains Mono", ui-monospace, monospace;
    font-size: 11px; color: var(--tinte-leise);
    background: var(--akzent-flach);
    padding: 3px 8px; border-radius: 20px; white-space: nowrap;
  }
  .kopf-knopf {
    border: 1px solid var(--linie); border-radius: 8px;
    background: transparent; color: var(--akzent);
    font: inherit; font-size: 13px; font-weight: 600;
    padding: 5px 12px; cursor: pointer; white-space: nowrap;
  }
  .kopf-knopf:hover { background: var(--akzent-flach); }
  .kopf-knopf:focus-visible { outline: 2px solid var(--akzent); outline-offset: 1px; }
  .kopf-knopf[data-fertig] { color: var(--gruen); border-color: var(--gruen); }

  .codehuelle { position: relative; border-top: 1px solid var(--linie-zart); }
  .code {
    margin: 0; padding: 14px;
    max-height: 340px; overflow: auto;
    background: var(--code-grund);
    font-family: "JetBrains Mono", ui-monospace, "SFMono-Regular", Menlo, monospace;
    font-size: 12.5px; line-height: 1.6;
    color: var(--tinte);
    tab-size: 4;
  }
  .code.offen { max-height: none; }
  .mehr {
    display: block; width: 100%;
    border: 0; border-top: 1px solid var(--linie-zart);
    background: var(--flaeche); color: var(--tinte-leise);
    font: inherit; font-size: 12px; font-weight: 600;
    padding: 9px 12px; cursor: pointer; text-align: center;
  }
  .mehr:hover { color: var(--tinte); background: var(--akzent-flach); }
  .mehr:focus-visible { outline: 2px solid var(--akzent); outline-offset: 1px; }
  .mehr[hidden] { display: none !important; }

  .nichts {
    text-align: center; color: var(--tinte-leise);
    padding: 40px 20px; font-size: 15px;
  }

  .fuss {
    margin-top: 48px; padding-top: 20px;
    border-top: 1px solid var(--linie-zart);
    font-size: 14px; color: var(--tinte-leise);
  }
  .fuss p { margin: 0 0 8px; max-width: 62ch; }
  .fuss code {
    font-family: "JetBrains Mono", ui-monospace, monospace;
    font-size: 12.5px; background: var(--akzent-flach);
    padding: 1px 5px; border-radius: 4px;
  }

  @media (prefers-reduced-motion: reduce) {
    * { transition: none !important; animation: none !important; }
  }
</style>

<div class="leiste">
  <div class="leisteninhalt">
    <svg class="zeichen" viewBox="0 0 100 100" aria-hidden="true">
      <defs><linearGradient id="hg" x1="0" y1="0" x2="1" y2="1">
        <stop offset="0" stop-color="#3B72FF"/><stop offset="1" stop-color="#7A5AF0"/>
      </linearGradient></defs>
      <rect width="100" height="100" rx="22.5" fill="url(#hg)"/>
      <path d="M 50 18 L 81 45.28 L 81 80 L 19 80 L 19 45.28 Z" fill="none"
            stroke="#fff" stroke-width="7.5" stroke-linejoin="round"/>
      <g transform="rotate(38 50 60)">
        <path d="M 50 45 L 55.25 52.2 L 44.75 52.2 Z" fill="#4A3A22"/>
        <path d="M 44.75 52.2 L 55.25 52.2 L 55.25 71.01 Q 55.25 75 51.26 75
                 L 48.74 75 Q 44.75 75 44.75 71.01 Z" fill="#FFC44D"/>
        <rect x="44.75" y="54.6" width="10.5" height="2.1" fill="#F0A52E"/>
      </g>
    </svg>
    <div>
      <div class="leistenname">Homy</div>
      <div class="leistenzahl">{{ANZAHL}} Dateien · {{ZEILEN}} Zeilen</div>
    </div>
    <input type="search" id="suche" class="suchfeld" placeholder="Datei suchen …"
           aria-label="Datei suchen">
    <button type="button" class="knopf" id="allesKopieren">Alles kopieren</button>
  </div>
</div>

<div class="huelle">
  <div class="auftakt">
    <h1>Der ganze Quelltext von Homy</h1>
    <p>Jede Datei hat ihren eigenen Kopier-Knopf. „Alles kopieren“ oben nimmt das
       komplette Projekt auf einmal – mit Dateinamen als Trenner, damit du es
       hinterher wieder auseinandernehmen kannst.</p>
    <div class="zahlen">
      <span><b>{{ANZAHL}}</b> Dateien</span>
      <span><b>{{ZEILEN}}</b> Zeilen</span>
      <span><b>Swift 5</b> · SwiftUI</span>
      <span><b>iOS 17</b> · iPhone und iPad</span>
    </div>
  </div>

  <section class="promptblock">
    <div class="promptkopf">
      <div>
        <h2>Homy als Prompt</h2>
        <p>Der ganze Bauplan in Worten – zum Einfügen bei einer KI, wenn du die App
           noch einmal von vorn bauen lassen willst.</p>
      </div>
      <button type="button" class="knopf" data-kopiere>Prompt kopieren</button>
    </div>
    <div class="codehuelle">
      <pre class="code"><code>{{PROMPT}}</code></pre>
      <button type="button" class="mehr" data-mehr>Ganz anzeigen</button>
    </div>
  </section>

  <div id="liste">
{{KARTEN}}
  </div>
  <p class="nichts" id="nichts" hidden>Keine Datei mit diesem Namen.</p>

  <div class="fuss">
    <p><b>Nicht mit dabei</b>, weil es keine Textdateien sind: das App-Symbol
       <code>AppIcon.png</code> (1024 px) und das Logo. Auch die Browser-Vorschau
       <code>docs/vorschau.html</code> steht hier nicht – sie ist die Nachbildung
       fürs Web, nicht die App. Beides liegt im Repository und in der ZIP.</p>
    <p><b>Zum Bauen</b> brauchst du die Dateien einzeln an ihrem Platz im Ordner –
       Xcode liest den Ordnerbaum. Zum reinen Nachlesen reicht das Kopieren hier.</p>
  </div>
</div>

<script>
  "use strict";

  /* Kopieren – mit Rückfall, falls die Zwischenablage gesperrt ist. */
  async function kopiere(text, knopf) {
    const alt = knopf.textContent;
    try {
      await navigator.clipboard.writeText(text);
      knopf.textContent = "Kopiert";
    } catch (e) {
      const feld = document.createElement("textarea");
      feld.value = text;
      feld.style.position = "fixed";
      feld.style.opacity = "0";
      document.body.appendChild(feld);
      feld.select();
      let ok = false;
      try { ok = document.execCommand("copy"); } catch (e2) { ok = false; }
      feld.remove();
      knopf.textContent = ok ? "Kopiert" : "Geht nicht – bitte markieren";
    }
    knopf.dataset.fertig = "1";
    setTimeout(() => { knopf.textContent = alt; delete knopf.dataset.fertig; }, 1800);
  }

  document.addEventListener("click", ev => {
    const knopf = ev.target.closest("[data-kopiere]");
    if (knopf) {
      const karte = knopf.closest(".datei, .promptblock");
      kopiere(karte.querySelector("code").textContent, knopf);
      return;
    }

    const mehr = ev.target.closest("[data-mehr]");
    if (mehr) {
      const code = mehr.previousElementSibling;
      const offen = code.classList.toggle("offen");
      mehr.textContent = offen ? "Kleiner" : "Ganz anzeigen";
      if (!offen) code.scrollTop = 0;
    }
  });

  /* Kurze Dateien brauchen kein „Ganz anzeigen“. */
  document.querySelectorAll(".codehuelle").forEach(h => {
    const code = h.querySelector(".code");
    const mehr = h.querySelector("[data-mehr]");
    if (code.scrollHeight <= code.clientHeight + 4) mehr.hidden = true;
  });

  /* Alles auf einmal, mit Dateinamen als Trenner. */
  document.getElementById("allesKopieren").addEventListener("click", ev => {
    const stuecke = [...document.querySelectorAll("#liste .datei")].map(k => {
      const pfad = k.querySelector(".pfad").textContent;
      const strich = "=".repeat(78);
      return strich + "\n  " + pfad + "\n" + strich + "\n\n"
           + k.querySelector("code").textContent;
    });
    kopiere("HOMY – Dein Hausaufgabenheft\n\n" + stuecke.join("\n\n"), ev.currentTarget);
  });

  /* Suchen */
  const suche = document.getElementById("suche");
  const nichts = document.getElementById("nichts");
  suche.addEventListener("input", () => {
    const wort = suche.value.trim().toLowerCase();
    let treffer = 0;
    document.querySelectorAll("#liste .datei").forEach(k => {
      const passt = !wort || k.dataset.suche.includes(wort);
      k.hidden = !passt;
      if (passt) treffer++;
    });
    document.querySelectorAll(".gruppe").forEach(g => {
      let sichtbar = false;
      let n = g.nextElementSibling;
      while (n && !n.classList.contains("gruppe")) {
        if (n.classList.contains("datei") && !n.hidden) sichtbar = true;
        n = n.nextElementSibling;
      }
      g.hidden = !sichtbar;
    });
    nichts.hidden = treffer > 0;
  });
</script>
"""

ZIEL.write_text(baue())
groesse = ZIEL.stat().st_size / 1024
print(f"{ZIEL.name}: {groesse:.0f} KB")
