# Verifikation slice-mutate-doku-nennt-den-lokalen-weg-auf-macos (HEAD c1ef5472)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Diff `a6b75443^..c1ef5472`: `harness/sensors/mutate.md` (+35, Abschnitt
„Lokaler Weg für `# verify: full-smoke`-Fälle auf macOS“), `test/mutations/171-…sh` (Kopfkommentar, 2 Zeilen), die Slice-Datei. Closure, Register,
Paarungen und Häkchen sind Planner-Arbeit (`AGENTS.md` §3.10). Einziger laufender Agent; alle Läufe seriell, Host macOS/Colima.

## Verdikte je DoD-Punkt

- **D1 `mutate.md` nennt Aufruf und Grenzen — eingeschränkt (der Aufruf trägt nur mit GNU `sed` im PATH, das der Abschnitt nicht nennt).**
  - Aufruf mit Variable, Fall 305, selbst gefahren (`PATH=<gnu-sed>:$PATH`): `ok 305-… -> FEHLER — Rollen-Typ fehlt rot`, `1 ok, 0 Befund(e)`, Exit 0,
    140 s Wanduhr, Grün-Vorlauf `full-smoke` 110,91 s, Fall 9,39 s. Damit ist der DoD-Wortlaut „am Fall 305 gefahren, Ausgang ok“ direkt belegt
    (der Implementer fuhr 171; der Wortlaut ist durch meinen Lauf erfüllt, §7 muss die Quelle des Belegs trotzdem benennen — Planner).
  - Ohne Variable, gleicher Fall: 20 s, Exit 2, `BEFUND worker-1 … Worker kehrte mit Status 1 zurueck`, `harness/tools/full-smoke.sh: line 515: …: cannot execute
    binary file: Exec format error`, `full-smoke: FEHLER — der Bootstrap (sprachlos) der Stufe Handbuch-Baum ist NICHT Exit 0 (Exit 126)` — deckt die Doku-Aussage.
  - Komma: `MUTATE_CASES=a,b` → `ABBRUCH — MUTATE_CASES nennt einen unbekannten Fall: 'a,b'`, `make: *** [mutate] Error 1` — deckt „Leerzeichen, kein Komma“.
    Voller Fallname ohne `.sh` ist am Lauf belegt (Datei `test/mutations/<name>.sh`).
  - Zeiten 157 s / 111 s der Doku sind als Einzelwerte benannt; meine Messung (111 s Grün-Vorlauf) deckt den zweiten Wert, liegt im DoD-Band 100–220 s.
  - **Befund F-1 (MEDIUM, Zusage breiter als ihr Beleg):** derselbe Aufruf **ohne** GNU `sed` vor dem BSD-`sed` im PATH (macOS-Standard) scheitert:
    `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=305-… make mutate` → `BEFUND 305-… Mutations-Skript scheiterte: sed: 1: "internal/span/emit.go ": command i expects \ followed by
    text`, `0 ok, 1 Befund(e)`, 130 s. Der Abschnitt sagt „Auf einem solchen Host läuft ein Fall … so“ und nennt weder GNU `sed` noch einen Verweis auf den Absatz
    „Der Modus braucht GNU-Werkzeuge auf dem Host“ (mutate.md, „Auf einem Host mit BSD-Werkzeugen ist das Verhalten nicht gemessen“ — jetzt gemessen: rot). Auch `make gates` ist
    auf diesem Host ohne GNU `sed` rot (`mutate-greift: 653 Fall/Faelle, 7 greifen, 646 Befund(e)`, Exit 2); mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH` grün. Der Implementer
    maß erkennbar mit GNU `sed`, ohne es als Bedingung zu nennen. Folge: der Aufruf-Block reproduziert auf einem frischen macOS-Host nicht (`LH-QA-02`).
    Behebung: Doku nennt GNU `sed` im PATH als Voraussetzung (oder verweist auf den GNU-Werkzeuge-Absatz); Sache des Implementers/Planners.
- **D2 Kopf Fall 171 nennt 615 allein; `make mutate-greift` grün — erfüllt.**
  - `git diff a6b75443^..HEAD -- test/mutations`: nur die zwei Kommentarzeilen („der Fall 615 haelt diese Stufe …“); `# files:`/`# expect:`/`# verify:` unverändert
    (`internal/emit/templates/d-check.yml` / `laesst das docs-check des Ziels GRUEN` / `full-smoke`).
  - Sachlich: `614-…sh` `# files: internal/emit/templates.go`, `# expect: … [docs/plan/carveouts/] [docs/plan/carveouts/.gitkeep]`; `615-…sh` `# files: internal/emit/enforce.go`,
    `# expect: … [harness/erfassung-feldliste.md]`. Nur 615 hält die Feldlisten-Ablage; der Kopf stimmt.
  - `make mutate-greift` (mit GNU `sed`): `653 Fall/Faelle, 653 greifen, 0 Befund(e)`.
- **D3 `make gates` grün — erfüllt (mit GNU `sed`, s. F-1).** Exit 0; `d-check: 2744 Datei(en) geprüft, 0 Befund(e)`; `.harness/state/gates-passed.head` == `git rev-parse HEAD` ==
  `c1ef54726d2c06c1ba8209180b0f791bf4f7ece0`; `git status --short` leer. `make docs-check` ist Teil von `gates`.
- **D4 Review liegt vor** — `docs/reviews/2026-10-16-slice-mutate-doku-nennt-den-lokalen-weg-auf-macos.md` existiert (df43234b); Inhalt nicht Gegenstand. Reviewer-LOWs: im Endstand
  behoben — der Abschnitt führt Rahmen „macOS mit Colima“, Kollisions-Satz „übernommen, nicht neu gemessen“, Zeit als Einzelwert samt zweiter Messung, Leerzeichen/Komma.
- **D5 Doku-Update `mutate.md`** — vorhanden (siehe D1, mit F-1). Closure/Register/Risiko-Ausgänge/Paarungen/Häkchen: offen, Planner.

## Plan-vs-Code

- §3 nennt zwei Dateien; `git diff --stat a6b75443^..HEAD` nennt neben der Slice-Datei genau diese zwei. `harness/tools`, `Makefile`: leer — Ausschlüsse §1 eingehalten
  (kein `mutate-host`, kein Treiber-Code, kein neuer Fall: `test/mutations/` hat weiter 653 Dateien).
- Gebautes ohne Plan: der Satz „Kein Wächter hält diese Aussage“ und die Kollisions-Zeile — beide zurückhaltend formuliert, keine Zusage über mehr als gemessen.
  „4 isolierte Kopien/4 Worker für 1 Fall“ im Treiber-Log steht nicht in der Doku; kein Widerspruch.

## §3.6/§3.7 der Doku

- Indikativ, keine Befund-Kennung/Chronik; „Dass ein Linux/amd64-Host sie nicht braucht … nicht gemessen“, „Ein Mehr-Fall-Lauf ist nicht zugesagt“ halten die Grenze.
  Einziger Überhang: die implizite Zusage, der Aufruf laufe auf macOS wie genannt (F-1).
- Rot-Beleg: die Aussage ist Doku; das rote Gegenbeispiel der Variable (ohne sie rot mit Exit 126) habe ich selbst gesehen (siehe D1). Für GNU `sed` ebenso (F-1).

## Nicht belegt

- Linux/arm64, Linux/amd64, Windows; Mehr-Fall-Läufe (auch rein aus `full-smoke`-Fällen); Docker-Tag-Kollision (übernommen, nicht neu gemessen);
  `make mutate-auswahl`/CI-Branch nicht gefahren (kein Branch zu lesen/löschen); Zahlen 157 s und der Kollisions-Lauf (Fälle 111/501/…) nicht nachgemessen.
- Fall 171 selbst nicht von mir gefahren (305 reicht für den DoD-Wortlaut; gleicher Pfad Variable → `ARTIFACT_TARGET`).

## Offen für Planner

- F-1 vor Closure beheben lassen (Doku nennt GNU `sed`) oder als Grenze eintragen; sonst bleibt D1 eingeschränkt.
- §7: Beleg Fall 305 (Verifier-Lauf, 140 s, `ok`) nennen; Beobachtung `lokaler-full-smoke-scheitert-auf-macos-host` kann „BSD-sed“ als vierte Ursache dokumentieren.
