# Verifikation slice-benutzerhandbuch-fuehrt-java-python-csharp

- Rolle: Verifier, frischer Kontext. Datum: 2026-10-19. Stand: HEAD `db5390e0`.
- Plan: `docs/plan/planning/in-progress/slice-benutzerhandbuch-fuehrt-java-python-csharp.md` (wellenlos).
- Spec: LH-FA-04, LH-FA-02, LH-QA-01. Review-Report: `docs/reviews/2026-10-19-slice-benutzerhandbuch-fuehrt-java-python-csharp.md` (F1 LOW, F2 LOW behoben, F3 INFO).
- Der Slice wird nicht geschlossen, kein DoD-Haken gesetzt (Planner).

## Gefahren und nur gelesen

Gefahren:
- Sieben echte Bootstraps mit dem Host-Binary (sprachlos, go, cpp, kotlin, java, python, csharp), danach `harness/tools/handbuch-baum.sh` je Variante über dem unveränderten Handbuch. Ergebnis, alle Exit 0: dokument-only 95, go 13, cpp 15, kotlin 20, java 22, python 16, csharp 19 Pfade, deckungsgleich.
- Mutationen 767 bis 770 an der realen Quelle (Handbuch-Zeile streichen) auf einer Handbuch-Kopie, Prüfung mit `handbuch-baum.sh`: je Exit 1 mit genau dem Rest des `# expect:`-Textes (`[src/test/kotlin/app/MainTest.kt]`, `[config/checkstyle/checkstyle.xml]`, `[tests/test_main.py]`, `[.editorconfig]`).
- `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=768-handbuch-baum-java-pfad-ohne-nennung MUTATE_JOBS=1 make mutate` (der Fall wird mit vollem Dateinamen ohne `.sh` genannt; `768` allein bricht ab): Grün-Vorlauf `make full-smoke` grün (391 s), Fall `OK`, Meldung `Handbuch-Baum (java): vom Lauf angelegt, im Handbuch nicht genannt: [config/checkstyle/checkstyle.xml] rot`.
- Schleifen-Bruch an der realen Quelle: `java` aus `for baum_lang in …` in `harness/tools/full-smoke.sh` genommen (danach per `git checkout` zurückgesetzt), derselbe Fall 768: `BEFUND … make full-smoke blieb GRUEN — … hat keine Zaehne mehr`. Der Fall hängt damit an der Schleife, nicht an einer Fixture.
- `make e2e-abdeckung`: Arbeitsbaum danach unverändert, `docs/user/e2e-abdeckung.md` byte-gleich zur Erzeugung.

Nur gelesen / nicht gefahren:
- Fälle 767, 769, 770 nicht über `make mutate` und nicht mit Schleifen-Bruch (nur das Skript auf der Kopie); der Schleifen-Bruch gilt für 768, für die übrigen drei Sprachen derselbe Mechanismus, nicht einzeln gefahren.
- Kein Linux-/CI-Lauf; `artifact-host` statt Linux-Artefakt.
- Eine eigene Messung der Stufen-Laufzeit allein fehlt (siehe Messzahl).

Eigener Fehlgriff, offengelegt: Beim ersten Versuch liefen die Fall-Skripte 767 bis 770 wegen eines fehlgeschlagenen `sed` kurz gegen den echten Baum (`docs/user/benutzerhandbuch.md`, vier Zeilen entfernt). Per `git checkout --` zurückgesetzt, `git status` danach sauber; alle späteren Belege laufen auf Kopien oder in der Isolationskopie von `make mutate`.

## Verdikte je DoD-Punkt

- **L1 Referenz und Kapitel auf den Ist-Zustand: bestätigt.**
  `grep` über das Handbuch: `--lang`-Tabelle (Z. 461), Bauform-Grenzen (Z. 330: hexslice alle sechs, hexagonal nur go, Exit-2-Wortlaut), Fehlerfall (Z. 842), FAQ/Voraussetzungen (Z. 890) und Quellstand-Hinweis (Z. 7) führen sechs Sprachen. Meldungen und `--help` mit den drei `SKEL_*_VERSION`: vom Review am echten Aufruf gemessen, von mir nicht neu aufgerufen (gelesen). Der Wortlaut und die Standard-Tags (`9.8.1-jdk21`, `3.14.8-slim`, `10.0.402`) sind von keinem Sensor gehalten; das steht in Deklaration, GRENZE und `e2e-abdeckung.md`. Zahlwörter „alle drei"/„beide" ohne Treffer, das Review hat dasselbe gemessen.
- **L2 die drei Sprachbäume: bestätigt.**
  Marker `<!-- baum: java|python|csharp -->` vorhanden und über echten Bootstraps deckungsgleich (22/16/19 Pfade, s. o.). Der Hexslice-Code-Teil je Sprache steht im Absatz zur geschichteten Bauform; Quelle sind echte `--arch hexslice`-Bootstraps des Implementers und des Reviewers (Pfade, `__init__.py`, `Ports/inbound|outbound`). Von mir nicht neu gefahren; Stichprobe nur gelesen. Kein Sensor hält diese Prosa (benannte Grenze).
- **L3 der Sensor: bestätigt.**
  Schleife über sieben Ziele (`full-smoke.sh:507`); Deklaration nennt sieben Ziele und die Grenze (Wurzel-Variante, Etiketten, `--arch`, `add-lang`, Code-Teil, Tags, Fehlermeldungs-Wortlaut); `e2e-abdeckung.md` neu erzeugt und byte-gleich. Rot gesehen: Fälle 767 bis 770 auf der Kopie, 768 über `make mutate` mit der erwarteten Meldung, Schleifen-Bruch macht 768 zahnlos (Beleg oben). Die `# expect:`-Meldung pinnt die Ursache (der gestrichene Pfad), nicht irgendein Rot.

## Pflichten, die nicht zählen

- `make gates`: siehe Abschnitt Sensoren unten.
- Review-Report liegt vor, Rollenwechsel eingehalten: bestätigt (Commit `e8bcbd7e`). F2 durch `db5390e0` behoben: Grenze steht in `full-smoke.sh`, `handbuch-baum.sh` und `e2e-abdeckung.md`.
- Doku-Update `harness/sensors/full-smoke.md`: Die Datei nennt die Ziele der Stufe nicht (`grep -n -i 'handbuch\|kotlin' harness/sensors/full-smoke.md` ohne Bezug zur Stufe), der Plan verlangt Nachzug nur „wo es sie nennt": nicht betroffen, kein Befund.
- Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: nicht Gegenstand der Verifikation (offen, Planner).

## Zusätzliche Prüfungen

- Handbuch-Version: Z. 3 `**Software-Stand:** v0.9.0` und Z. 83 „aktuell ausgeliefert wird `v0.9.0`" unverändert (`git diff bf2af20c^ HEAD`: keine Änderung an diesen Zeilen). Bestätigt.
- Quellstand-Hinweis: vorhanden am Kopf (Z. 7) und an Tabelle, Bauform-Grenzen, Fehlerfall und FAQ. Bestätigt.
- `docs/user/benutzerhandbuch-standard.md`: `git diff --stat 74737579 HEAD` leer, unberührt. Bestätigt.
- `docs/user/e2e-abdeckung.md`: byte-gleich zur Erzeugung (siehe oben). Bestätigt.
- Messzahl MR-089 (Commit `91762ea2`): Image-Lage („warmer Image-Cache"), Variante (`full-smoke-host`, `artifact-host`), Host (macOS/colima), Reihenfolge `N V N V` genannt. **Lücken, offen: Build-Cache-Lage und kalte Lage stehen nicht als ungemessen daneben** (= Review F1, bleibt; die Commit-Message ist Historie, nicht änderbar). Gegenmessung: mein Grün-Vorlauf `make full-smoke` unter `artifact-host` dauerte 391 s; das Vorlauf-Äquivalent des Schleifen-Bruch-Laufs 395 s (Image-Cache warm, Build-Cache-Lage nicht kontrolliert), das liegt im Bereich „378 bis 430 s nachher". Die Stufenzeit allein (8 bis 10 s) habe ich nicht gemessen; der Fall 768 lief 16,5 s inklusive Bootstraps der Kopie. Die Deutung „rauscht um die Stufenzeit herum" ist durch die Zahlen nicht belegt, aber auch nicht widerlegt.

## Findings

- V1 LOW (bestätigt F1): Messzahl ohne Build-Cache-Lage und ohne „kalte Lage ungemessen". Beleg: Commit-Message `91762ea2`. Der Planner entscheidet, ob ein Register-Eintrag oder die Benennung in der Closure-Notiz genügt.
- V2 INFO: `test/mutations/768-…sh` Zeile 9 verweist auf `nur_ziel` als Meldungs-Mechanismus; der Name existiert in `handbuch-baum.sh:101/113` (zwei Variablen), korrekt, kein Befund.
- Keine HIGH/MEDIUM. Negativbefund: Plan-vs-Code in beide Richtungen (Handbuch, Schleife, Deklaration, vier Fälle, e2e-Datei): kein Gebautes ohne Plan, keine Planzusage ohne Code. Der Ausschluss „Versionsnummer" ist eingehalten.

## Offen für Planner/Architect

- Risiko §6 „Pfad hängt vom Lauf ab": gemessen entfallen, die sieben Läufe sind deckungsgleich (kein versionsabhängiger Pfad in den Bäumen); Ausgang vom Planner zu setzen.
- Register `BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke` (L3 liefert den Sensor) und die Grenze „Prosa ohne Sensor" (Hexslice-Code-Teil, Tags, Meldungswortlaut) sind in der Closure zu führen.
- Der Quellstand-Hinweis muss vom Release-Schnitt entfernt werden (Plan §1).

## Sensoren

`make gates` auf HEAD nach dem Commit dieses Reports: Ergebnis im Handback.
