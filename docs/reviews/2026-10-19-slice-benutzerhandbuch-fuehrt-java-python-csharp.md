# Review slice-benutzerhandbuch-fuehrt-java-python-csharp

- Rolle: Reviewer, frischer Kontext. Datum: 2026-10-19.
- Diff: `bf2af20c` (L2), `91762ea2` (L3), `867d5d23` (L1) auf Basis `74737579`.
- Plan: `docs/plan/planning/in-progress/slice-benutzerhandbuch-fuehrt-java-python-csharp.md` (wellenlos).
- Geprüft gegen: Plan §1/§2, ADR-0094 bis 0097 (nur über Slice-Bezug, keine Verletzung gefunden), AGENTS.md §3.6, §3.7, §3.11, MR-089, Reviewer-Skill 2.3.0.

## Findings

### F1 — LOW — Laufzeit-Zahl nennt Build-Cache-Lage und Ungemessenes nicht
- quelle: MR-089 · pfad: Commit-Message `91762ea2` · verifizierbar: nein
- befund: Die Message nennt Image-Lage („warmer Image-Cache"), Host/Variante (`full-smoke-host`, `artifact-host`, macOS/colima) und die Reihenfolge `N V N V`. Die Build-Cache-Lage und die kalte Lage stehen nicht als „ungemessen" daneben (MR-089 Adaption a/b). Die Gesamtdauer „378 bis 430 s nachher" gegen „366 bis 372 s vorher" liegt im Maximum 58 s über dem Vorher-Maximum, die Stufe wuchs um 5 bis 6 s; „rauscht um die Stufenzeit herum" ist eine Deutung ohne Beleg im Text.
- klasse: Laufzeit-Aussage ohne vollständige Lage

### F2 — LOW — Grenzen der Handbuch-Prosa ohne Sensor stehen nur im Slice-Plan, nicht am Ort
- quelle: AGENTS.md §3.6 · pfad: `harness/tools/handbuch-baum.sh:38-41`, `harness/tools/full-smoke.sh:492-493`, `docs/user/e2e-abdeckung.md` Zeile LH-FA-02 · verifizierbar: nein
- befund: Etiketten und `--arch`-Varianten sind am Ort benannt (Kurzbeschreibung der Stufe, GRENZE des Skripts, e2e-abdeckung.md). Nicht benannt ist, dass die neuen Prosa-Aussagen (Hexslice-Code-Teil je Sprache, Z. 781; Standard-Tags `9.8.1-jdk21`, `3.14.8-slim`, `10.0.402`; Fehlermeldungs-Wortlaut) kein Sensor hält; `handbuch-baum.sh` sagt „--arch-Varianten stehen in §6 als Prosa", deckt Tags und Meldungen nicht. Ein Pin-Bump in `internal/gen` lässt das Handbuch still veralten.
- klasse: Prosa-Zusage ohne Wächter, Grenze nicht am Ort

### F3 — INFO — Mutations-Fälle 767 bis 770 durch `make mutate` hier nicht gefahren
- quelle: AGENTS.md §3.6 · pfad: `test/mutations/767`–`770` · verifizierbar: ja (Linux/CI)
- befund: `make mutate` bricht auf dem macOS-Host im Grün-Vorlauf ab (`Exec format error`, Linux-Artefakt statt `artifact-host`); das ist Umgebung, kein Befund am Diff. Ersatzprobe siehe unten.

Kein HIGH, kein MEDIUM.

## Bruchproben (Scratchpad, kein Rest im Baum)

- Sieben echte Bootstraps mit dem Host-Binary (`.harness/state/bin/ai-harness-init`), danach `handbuch-baum.sh` über dem unveränderten Handbuch: go 13, cpp 15, kotlin 20, java 22, python 16, csharp 19 Pfade, sprachlos 95, alle deckungsgleich.
- Die vier Fall-Skripte auf Kopien des Handbuchs: jedes entfernt genau eine Zeile (`diff`), und `handbuch-baum.sh` meldet exakt den `# expect:`-Text-Rest: `[src/test/kotlin/app/MainTest.kt]`, `[config/checkstyle/checkstyle.xml]`, `[tests/test_main.py]`, `[.editorconfig]`. Das Präfix `Handbuch-Baum (<variante>): ` stammt aus `full-smoke.sh:500` (`FEHLER — Handbuch-Baum (…)`); `# expect:` pinnt damit die Ursache (angelegt, nicht genannt, der gestrichene Pfad), nicht irgendein Rot. Die Rot-Richtung ist am Skript gefahren, nicht über den vollen `full-smoke`-Lauf in Linux (gelesen, nicht gefahren).
- `make e2e-abdeckung` erneut gefahren: Arbeitsbaum danach unverändert, die Datei ist byte-gleich zur Deklaration.

## Handbuch gegen Quellen

- `SupportedLangs`/`langArchs` (`internal/gen/gen.go:157`): hexslice sechs Sprachen, hexagonal nur go, stimmt mit Kapitel und `--lang`-Tabelle.
- Standard-Tags gegen `internal/gen`: `9.8.1-jdk21` (java, kotlin), `3.14.8-slim`, `10.0.402` stimmen.
- Echter Aufruf: `unbekannte Sprache "ruby"; verfuegbar: cpp, csharp, go, java, kotlin, python` und `unbekannte Architektur "hexagonal"; verfuegbar: flat, hexslice` (python) stimmen wörtlich; `--help` führt die drei `SKEL_*_VERSION` wie beschrieben.
- Hexslice-Code-Teil: echte `--arch hexslice`-Bootstraps für java, python, csharp (Pfade, `__init__.py` je Verzeichnis, `Ports/inbound|outbound` klein, `GreetTest(s)`) stimmen mit Z. 781 überein. Etiketten spot-geprüft: python ohne `[project]`, ruff/mypy/pytest gepinnt, csharp `dotnet format`, `net10.0` in `Directory.Build.props`, java checkstyle.
- Version bleibt `v0.9.0` (Z. 3 unverändert); der Quellstand-Hinweis steht am Kopf und an Tabelle, Fehlerfall, Bauform-Grenzen und FAQ und stimmt mit dem Plan-Beleg (`v0.9.0` kennt die drei nicht) überein.

## Negativbefund (geprüft, ohne Befund)

- Quellstand-Hinweis und Versions-Aussagen: korrekt, Nummer unberührt, Plan-Abgrenzung eingehalten.
- Veraltete Zahlwörter („alle drei Zielsprachen", „beide"): per `grep` keine verbliebene Sprachzahl-Aussage über drei Sprachen im Handbuch.
- `full-smoke.sh`-Schleife über sieben Ziele, Basis `sprachlos` bleibt erstes Ziel; Deklaration nennt sieben Ziele und die Grenze (Wurzel-Variante, Etiketten, `--arch`, add-lang) ehrlich.
- §3.7 / §3.11 in Diff: Kommentare tragen Zusage/Kopplung/Grenze; keine Pfad-Adresse in eingefrorenem Artefakt hinzugefügt.
- Zusage-Klassen (Skill): Mehrteilige Zusage der Deklaration (sieben Ziele): Teil-Grenzen (je Ziel) tragen Fälle 767–770 nur für kotlin/java/python/csharp, go/cpp/sprachlos hatten Bestandsfälle 614–616 (nicht neu). Exklusivitäts-Behauptung im Fall-Kopf: keine.
- Implementer-Lücken (Etiketten, `--arch`-Bäume): am Ort benannt (F2 nur für die Prosa ohne Sensor, s. o.); die Hexslice-Prosa ohne Sensor ist am Ort nicht ausdrücklich benannt, siehe F2.

## Sensoren

`make gates` siehe Commit-Lauf (Ergebnis im Handback).
