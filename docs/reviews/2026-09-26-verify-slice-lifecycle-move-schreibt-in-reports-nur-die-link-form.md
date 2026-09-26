# Verifikations-Report: slice-lifecycle-move-schreibt-in-reports-nur-die-link-form — 2026-09-26

**Rolle:** Verifier (Modul 11), frischer Kontext. **Frage:** Bauen wir es richtig? — gegen Plan, DoD, `ADR-0070` und die
Hard Rules; nicht gegen den Reviewer-Maßstab.

**Gegenstand:** Stand `52417dea`, Baum sauber. Geprüft ist `git diff bc96ec5a..HEAD` (Move-Commit `f9f089f4` als Basis-Vorlauf).
Der Review-Report `2026-09-26-slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` (0 HIGH · 0 MEDIUM · 1 LOW · 4 INFO) las den Stand
`83044cc4`; **sechs Commits danach hat kein Reviewer gelesen** und sind hier gegen Läufe geprüft: `2e6e5684` (Härtung von `psed_i`,
Status-Auswertung in `main()`, bats-Fälle 19–21, Go-Test der Härtung), `12727a25` (Anker Fall 462), `cbaaee83` (Fälle 463–465),
`83d14458` (bats-Fall „mehrere Links je Zeile"), `31fe3217` (Fall 466), `52417dea` (Sensor-Doku).

**Constraint:** DoD und §1/§3/§4/§5/§6/§8 des Slice (Kennung, nicht Pfad — der Plan wandert mit dem Lifecycle, `AGENTS.md` §3.11) ·
`ADR-0070` (`Accepted`; Festlegungen 1–3, Fitness-Zeilen 1–6, Trigger 1 und 4–7, §Nicht gebaut) · `ADR-0042` Festlegung 1 samt
Index-Marke · `AGENTS.md` §3.6, §3.7, §3.10, §3.11 · `MR-071` · `harness/tools/slice-mv.sh` · `internal/emit/templates/enforce/slice-mv.sh`
(nur gelesen) · `test/slice-mv.bats` · `cmd/ai-harness-init/slice_mv_echt_test.go` · `test/mutations/313`, `315`, `316`, `346`, `363-…slice-mv…`,
`459`–`466` · `harness/sensors/slice-mv.md`.

**Eingang / Sensor-Belege des Implementers:** Der Implementer-Bericht lag nicht als Datei vor; bestätigt wird, was die Commits behaupten
(Commit-Messages, Kommentare, Sensor-Doku), gegen eigene Läufe.

## Eigene Läufe

Alle Läufe in Scratchpad-Kopien von `git archive` (außerhalb des Repos) bzw. im Docker-Bild über die Ziele des Makefiles; `git status`
im Repo blieb leer. Kein voller `make mutate`, kein Push, keine Host-Toolchain (Host: `bash`, `git`, `docker`, `make`).

| # | Lauf | Ergebnis |
|---|---|---|
| L1 | bats `test/slice-mv.bats` im gepinnten Bild, Kopie von `HEAD` | `1..23`, 23 × `ok`, kein `not ok` |
| L2 | dieselben Tests gegen `slice-mv.sh` von `18bc480e` (Stand des Reviews) | rot: 19 (`psed_i`: sed scheitert, Status 0 statt 2), 20 (Zurückschreiben, Status 0), 21 (Nachzug, Status 0); 20 × `ok` |
| L3 | dieselben Tests gegen `slice-mv.sh` von `bc96ec5a` (Vorzustand des Slice) | rot: 12–17 (`rewrite_incoming_nach_baum`/`_links_in_file` nicht vorhanden, Status 127), 19–21; 14 × `ok` |
| L4 | `make test-go` in der `HEAD`-Kopie | Exit 0 (gesamte Suite, darunter `TestSliceMvEchtSchreibtInReportsNurDieLinkForm`, `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb`, `TestSliceMvEchtUebergehtAcceptedADRBeimNachzug`) |
| L5 | `make test-go` mit dem Skript von `18bc480e` und den neuen Tests | rot: `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb` — `erwartet Exit 2, ist <nil>` |
| L6 | Teillauf `make mutate MUTATE_JOBS=1 MUTATE_CASES='313 315 316 346 363-slice-mv 459 460 461 462 463 464 465 466'` | `13 ok, 0 Befund(e)`; `TEILLAUF 13 von 454 — kein Beleg`. Beleg-Slot `.harness/state/mutate-passed.key`: **vorher nicht vorhanden, nachher nicht vorhanden** |
| L7 | Fälle 462 und 465 einzeln in Kopie, `make test-go`, Meldung gelesen | 462: einziger roter Test `TestSliceMvEchtSchreibtInReportsNurDieLinkForm`, Meldung `Report: nur der Link darf nachgezogen sein (ADR-0070 Festlegung 1)`; 465: einziger roter Test `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb`, Meldung `erwartet Exit 2, ist <nil>` |
| L8 | Gegenprobe „grün heißt bindet", Mutation angewendet, Zusicherung(en) des benannten Falls entfernt, bats (`gegenprobe`, 16 Läufe) | siehe Tabelle unten |
| L9 | R-1-Nachfahren: Datei `0200` unter `done/`, `rewrite_incoming_nach_baum` aus `sed`-Ausfall (Lesen scheitert) | Skript von `18bc480e`: Status **0**, Datei **0 Byte**; Skript von `HEAD`: Status **2**, Datei **34 Byte** (unverändert) |
| L10 | Politik-D-Messung: `git archive HEAD` nach Scratch, `git init` + Commit, `make docs-check`, `make slice-mv SLICE=slice-071 TO=in-progress`, `make docs-check` | `1974 Datei(en) geprüft, 0 Befund(e)` vorher und nachher; **0** `target-missing`; siehe §Closure-Trigger 2 |
| L11 | Titel-Link und Spitzklammer-Form: Report mit je einem Link auf einen nicht vorhandenen Pfad, `make docs-check` | 3 × `target-missing` (laut); die Regel ersetzt nur die Form ohne Titel/Spitzklammer |
| L12 | Abbruch mit Ausfall an einer **späteren** Datei (PATH-Wrapper, der `sed -E` nur für einen Report scheitern lässt), `make slice-mv` in der Kopie | Exit 2 und Meldung; ein Commit (Move); **11 getrackte Dateien im Arbeitsbaum geändert** (V-1) |
| L13 | `rewrite_incoming_bare_in_file` und `rewrite_outgoing_bare_in_file` bei ausfallendem `sed -E` (PATH-Wrapper) | beide Status **0**, Zähler `2` bzw. `1`, Datei unverändert (V-2) |
| L14 | `|| return 2` in `rewrite_incoming_nach_baum` entfernt, bats | 23 × `ok` — kein Zahn (V-4) |

**Gegenprobe (L8):** *grün heißt bindet* — mit der Mutation angewendet und der genannten Zusicherung entfernt wird der Fall grün.

| Fall | Mutation allein | Zusicherung entfernt | Deutung |
|---|---|---|---|
| 459 · bats-Fall 12 | rot (12, 13; 15 bleibt `ok`) | ohne die Byte-Gleichheit: **grün** | die Byte-Gleichheit bindet Fall 12 |
| 466 · bats-Fall 15 | rot | ohne Zähler: rot · ohne Inhaltsvergleich: rot · ohne beides: **grün** | Zähler **und** Inhaltsvergleich binden je allein; kein dritter Fänger |
| 463 · bats-Fall 19 | rot | ohne Status: rot · ohne Dateivergleich: rot · ohne beides: **grün** | Status- **und** Dateizeile binden je allein |
| 464 · bats-Fall 20 | rot | ohne Statuszeile: **grün** | die Statuszeile bindet (einzige Zusicherung des Falls) |
| 461 · bats-Fall 17 | rot | ohne Zählzeile: rot · ohne `!`-Zeile: rot · ohne beides: **grün** | beide binden je allein |

Die Nummerierung der bats-Fälle im Report des Reviews (19 Fälle) ist durch den neuen Fall „mehrere Links je Zeile" um eins verschoben; die
neuen Fälle heißen jetzt 12–21 (Regel 12–16, `done/` 17, Kontrolle 18, Härtung 19–21), 23 gesamt. `# expect:` von 466 trägt den Namen von Fall 15.

## Verdikt je Punkt

### Liefer-Punkt 1 — die Form-Regel im Träger — **bestätigt**

- **Regel:** Fall 12 (Link + reiner Span + Operand + Block + Fließtext in einer Datei, ganze Datei gegen Literal) und Fall 14 (Tiefen `../../`, `../`, präfixlos;
  Anker; Code-Span als Link-Text; verklebtes Wort, längerer Name, anderes Verzeichnis bleiben) und Fall 15 (mehrere Links je Zeile, Link direkt hinter einem
  Code-Span, fremder Link derselben Zeile bleibt) sind grün und färben unter 459/460/466 rot (L1, L6, L8). Am Vorzustand sind sie rot (L3).
- **Real, nicht nur Probe:** die Politik-D-Messung (L10) an `slice-071-bilanz-nennt-ihren-bestand` (fünf Nicht-Link-Vorkommen und zwei Link-Zeilen in Reports):
  in `docs/reviews/` sind **genau zwei Zeilen** umgeschrieben (`git diff --numstat` je `1 1`), beide Link-Ziele; die fünf übrigen Zeilen mit dem alten Pfad
  (Span, Operand, Fließtext) stehen byte-gleich (`git grep -cF 'next/slice-071' -- docs/reviews` vorher 7, nachher 5). In `done/` (neun) und `open/` (eine) sind Dateien in jeder
  Form nachgezogen.
- **Ausnahmeliste unverändert:** `eingehend_ausgenommene_pfade()` liefert `:!.harness/baseline` und `:!docs/plan/adr` (gelesen; Fall 22 grün, Fall 313 rot unter Mutation).
  `git diff bc96ec5a..HEAD --stat -- internal .d-check.yml docs/plan/adr harness/conventions.md harness/conventions AGENTS.md` → leer.
- **Kommentar an der Ausnahmeliste** zitiert `ADR-0070` Festlegung 2 statt Abnahme-Kriterium 1 von `ADR-0033` (gelesen, Zeilen 183–189); der Skriptkopf zitiert
  `ADR-0070` in ZUSAGE (22–23) und in Grenze (5); `ADR-0033` steht im Skript nicht mehr.
- **`main()`-Zählung:** die Meldung der Messung nennt `12 eingehend`, gleich der Zahl der geänderten Dateien (`git show --stat`: 9 in `done/`, 1 in `open/`,
  2 Reports — zwölf); ein Report, der nur Span/Operand trägt, fällt aus dem Inhalts-Commit (Fall 13, Status 1).
- **Rot-Belege der drei Bricht-wenn-Klauseln:** Form-Regel entfällt → 459 rot (12, 13), Link-Nachzug entfällt → 460 rot, Regel auf `done/` ausgedehnt → 461 rot; die dritte
  Klausel (Träger nimmt nur den unmittelbaren Backtick-Kontext aus) ist im Review als Schwächung M-c rot gesehen (Fall 12: Operand, Block, Fließtext umgeschrieben) —
  **von mir nicht nachgefahren, aus dem Review übernommen**; Fall 12 trägt alle vier Nicht-Link-Formen (gelesen) und ist unter 459 rot.

### Liefer-Punkt 2 — die Tests, die sie halten — **bestätigt**

- (a) Fall 12 und Go-Test `TestSliceMvEchtSchreibtInReportsNurDieLinkForm` (gelesen und grün, L4): eine Datei, vier Nicht-Link-Formen. (b) Fall 16 (Link-Zitat im Span
  wird mitersetzt, der reine Pfad daneben nicht; Name nennt Trigger 6). (c) Fall 17 und der Go-Test (fünf Formen unter `done/`). (d) Fälle 459 und 460 färben je den Fall 12
  rot und tragen in **einer** Datei beide Hälften. Alle acht neuen Fälle: Kopf (`# files:`, `# expect:`, `# verify:`) vorhanden, `# expect:` deckt den Namen des rot
  werdenden Tests; die Anker treffen im Quell-Bestand **genau eine Stelle** (`grep -c`/`grep -cF` je Fall, alle acht → `1`, `MR-071`).
- **Mutations-Fälle 459–466 gefahren:** L6 (alle acht, `ok`), L7 (462, 465 mit gelesener Meldung), L8 (459, 461, 463, 464, 466 mit Gegenprobe — fünf, mehr als die verlangten vier).
  459/460/461/463/464/466 färben den Test rot, den `# expect:` nennt (L8: rote Fälle 12, 12/13, 17, 19, 20, 15). Bestandsfälle: 313, 315, 316, 346, `363-slice-mv` — Anker trifft,
  `ok` in L6.
- **Was die Härtung ab `2e6e5684` deckt:** Fälle 19–21 (bats) und `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb`. Rot am Vorzustand von `18bc480e` (L2, L5), grün am `HEAD`.
  Die Zusage der Sensor-Doku „Datei bleibt, wie sie war" ist für **die scheiternde Datei** gemessen (L9): Status 2 und 34 Byte, wo der Vorzustand Status 0 und 0 Byte zeigt.
- **Zusage 2 der Härtung — ist es die richtige?** `main()` bricht bei `rc>1` mit Meldung und Exit 2 ab; der Move-Commit steht, der Nachzug ist nicht committet. Kein
  halb-committeter Zustand entsteht (L12: ein Commit). **Aber** ein halb-geschriebener Arbeitsbaum bleibt: siehe V-1.

### Liefer-Punkt 3 — die Sensor-Doku — **bestätigt** (Vorbehalt zum Zusatzabschnitt: V-1)

- „Fünf gemessene Grenzen" zählt die Aufzählung (Pfade-nicht-Zustandssätze · Welle-Plan · präfixlose Ersetzung · Zeichenklasse · Form-Regel: fünf; MR-025: es ist eine Zählung des
  Aufzählungstexts, kein Messwert). Die Span-Hälfte ist gebunden (Fall 16 grün und unter 459/460 rot), Block-Zitat und Referenz-Definition stehen als benannte Lücken mit Trigger 6/7.
- Titel-Link und Spitzklammer-Form (Rand aus dem Review R-2): **laut, nicht still** — 3 × `target-missing` (L11); die Regel lässt beide stehen (`[b]` mit Titel, `[c]` mit `<…>`).
- „in zwei Stufen gedeckt": 459–461 → bats, 462 → Go-Test; 466 → Fall 15; 463/464 → Fälle 19/20; 465 → Go-Test — jede Aussage gegen L6/L7/L8 belegt.
- „Die zwei Ersetzungen … reichen den Status von `psed_i` nicht weiter — sie kürzen die Datei nicht mehr, melden aber Erfolg (gefahren für die erste … Status 0, Zähler 1 …; für die
  zweite gelesen)": bestätigt und **schärfer** (L13: der Zähler nennt Ersetzungen, die nicht stattfanden; V-2). „Die emittierte Fassung führt diese Härtung von `psed_i` nicht":
  bestätigt (gelesen; V-3).
- §3.7: Zustandsform im Indikativ; keine Slice-Adresse als Pfad (nur Kennungen der Fälle und Tests, die Dateien liegen ortsfest); die Zahl „Fünf" steht ohne Kommando, ist aber die Zahl
  des Aufzählungstexts. Ein Lauf-Protokoll im Perfekt steht in „gefahren an einem Report mit je einem Link …" — Markdown-Doku, nicht Code/Konfiguration/Skript; nur genannt.

### Weitere DoD-Punkte

- `make gates` grün: Baum und Stempel laut Auftrag gedeckt; L1 und L4 (bats/Go) sind die Sensoren dieses Slice und grün. Der Gate-Lauf **nach** diesem Commit steht in der Rückmeldung, nicht hier.
- Review durchgeführt, Report liegt vor: **ja** (`2026-09-26-slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`). Er deckt sechs Commits nicht (oben); sie sind hier geprüft.
- Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: **Planner** (`AGENTS.md` §3.10); §7 des Plans ist leer, wie es vor der Closure sein muss.

### Closure-Trigger

1. **Tests aus Liefer-Punkt 2 grün in `make gates`, Rot-Belege je einmal gesehen:** bestätigt (L1, L4, L6–L8); der Rot-Beleg der dritten Bricht-wenn-Klausel (M-c) stammt aus dem Review.
2. **Politik-D-Messung:** **bestätigt.** Kopie von `git archive HEAD` außerhalb des Repos, `git init` + ein Basis-Commit; `make docs-check` vorher `1974 Datei(en) geprüft, 0 Befund(e)`;
   `make slice-mv SLICE=slice-071 TO=in-progress` (zwei Commits: reiner Move, Nachzug); `make docs-check` nachher `1974 Datei(en) geprüft, 0 Befund(e)`, `grep -c target-missing` → `0`. Der bekannte
   `planning-drift` eines Moves ohne Stilllegungs-Inhalt trat nicht auf, weil `in-progress/` in der Kopie durch den Slice besetzt war (Marker-Lage). `git diff -U0` auf `docs/reviews/`: zwei
   `+`/`-`-Paare, beide Link-Ziele. Gegenstück (Politik B, der Link stirbt): 460 färbt Fall 12 rot; das Gate-Rot dazu ist in L11 an den zwei ausgelassenen Formen gefahren (laut).

### Abgrenzung §1

`git diff bc96ec5a..HEAD --stat` nennt: Go-Test, Roadmap (Ruhe-Marker entfernt, drei Zeilen), Slice-Datei (Adress-Nachzug), Review-Report, Sensor-Doku, `slice-mv.sh`, neun Mutations-Fälle (313 geändert,
459–466 neu), `test/slice-mv.bats`. **Nicht berührt:** `internal/archive` und die ganze `internal/` (Geschwister-Slice), `.d-check.yml`, `docs/plan/adr/`, `harness/conventions*`, `AGENTS.md`. Die emittierte Fassung
ist unverändert; ihre Kopplung (Fall 23) ist grün, weil die zwei neuen Funktionen außerhalb von `KERN` liegen. Kein eingefrorenes Zeitdokument ist umgeschrieben (der Nachzug in `cb0638e4` traf nur die Slice-Datei).

## Plan-vs-Code-Diff

| Richtung | Befund |
|---|---|
| Geplant und gebaut | Regel als Funktion plus Pfad-Zweig in `main()` (`rewrite_incoming_links_in_file`, `rewrite_incoming_nach_baum`, Aufruf in der Schleife); Kommentar an der Ausnahmeliste; bats-Fälle nach Fitness-Zeilen 1, 2, 5; Go-Test für `main()`; Mutations-Fälle (459/460 binden beide Hälften, 461 `done/`, 462 `main()`); Sensor-Doku. |
| Gebaut, nicht geplant | (1) `psed_i`-Härtung, `|| return 2`-Kette, Status-Auswertung in `main()` (`2e6e5684`) — Anlass: Review-Befund R-1, den der Slice mit der Aufrufform `|| continue` selbst ausgelöst hat; (2) Fälle 463–465, bats-Fälle 19–21, Go-Test `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb`; (3) Fall 466 und bats-Fall „mehrere Links je Zeile" (R-3, optional); (4) Sensor-Doku: Abschnitt „Scheitert die Ersetzung …" und der Rand Titel/Spitzklammer (R-2); (5) Nachzug der Anker 313 und 462 in eigenen Commits (MR-071, §3.3), Umbenennung des bats-Falls der Ausnahmeliste; (6) Formen-Probe als Funktion (gochecknoglobals). |
| Geplant, nicht gebaut | nichts. Ausgeschlossen mit Adresse: `archive-welle` (Geschwister-Slice), Kopplungs-Test (Kopplungs-Slice), Kontext-Erkennung, Code-Block-Zitat/Referenz-Definition. |

**Liegt die Härtung im Rahmen der DoD?** Ja, mit einer Anmerkung für den Planner. Liefer-Punkt 1 sagt „jede andere Pfad-Adresse bleibt Byte für Byte"; die Aufrufform des Slice (`|| continue`) entwaffnete `set -e` im gesamten Nachzug, und ein
`sed`-Ausfall kürzte die Datei auf 0 Byte (L9) — die Zusage wäre im Fehlerfall gebrochen. Die Behebung berührt dieselben Funktionen und ändert kein Abnahmekriterium. **Sie ändert aber den Rückgabewert von `rewrite_incoming_in_file` und die
Reichweite aller Bäume** (ein Nachzug in `done/` bricht jetzt bei Ausfall ab), also mehr als das Format der Reports; das gehört in §7 unter *Was ging anders als geplant*, nicht in die DoD.
**Größe:** drei Liefer-Punkte, zwei Schichten (Werkzeug-Skript samt Tests; Doku); `git diff bc96ec5a..HEAD --numstat` nennt 16 Dateien, 711 Zeilen davon 135 im Review-Report. Die Rückführungs-Bedingungen aus §4 (Regel in `KERN`, Echt-Test nicht in einer Sitzung prüfbar) sind nicht eingetreten.

## Befunde

### V-1 — LOW — die Zusage „bei Ausfall bleibt die Datei, wie sie war" gilt je Datei; der Lauf lässt den Arbeitsbaum teil-umgeschrieben zurück

- `klasse`: Zusage breiter als ihr Sensor (Zustand nach dem Abbruch)
- `pfad`: `harness/tools/slice-mv.sh` (`main()`, Abbruch-Zweig), `harness/sensors/slice-mv.md` (Überschrift „Scheitert die Ersetzung, bricht der Lauf ab und die Datei bleibt, wie sie war"), `cmd/ai-harness-init/slice_mv_echt_test.go` (`TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb`)
- `befund`: Die Schleife zieht Datei für Datei nach; bei einem Ausfall an der **k-ten** Datei bleiben die Dateien 1…k−1 umgeschrieben und **nicht committet** (L12: Ausfall an einem Report mitten in der Trefferliste, elf getrackte Dateien geändert, ein Commit). Meldung und Sensor-Doku sagen „der Nachzug ist nicht committet"
  bzw. „die Datei bleibt, wie sie war" — wahr für die scheiternde Datei und für die Commit-Historie, nicht für den Arbeitsbaum. Der Go-Test bindet die Aussage nur, weil sein Wrapper **jeden** `sed -E` scheitern lässt und die erste Datei schon fällt; er trifft den späteren Ausfall nicht.
- `failure-szenario`: der Lauf bricht in der Mitte ab, der Arbeitsbaum ist schmutzig, ein zweiter `make slice-mv` verweigert („Arbeitsbaum nicht sauber"); wer den Move erneut versucht oder `git commit -a` tippt, nimmt einen Teil-Nachzug mit. Der Ausgang ist eng (`sed`-Ausfall) und laut.
- `wirkung auf die DoD`: keine (Zusatzabschnitt der Sensor-Doku, nicht Liefer-Punkt 3). Erwartet: die Zusage auf „bricht ab, die scheiternde Datei bleibt, wie sie war; bereits nachgezogene Dateien stehen ungestaged im Arbeitsbaum (`git restore .`)" einschränken, oder den Nachzug erst nach dem letzten Erfolg schreiben.

### V-2 — INFO — `rewrite_incoming_bare_in_file` und `rewrite_outgoing_bare_in_file` melden bei Ausfall Erfolg, samt falschem Zähler

- `klasse`: Härtung erreicht nicht alle Aufrufer (vom Implementer benannt; hier schärfer gemessen)
- `befund`: L13 — bei ausfallendem `sed -E`: Status 0, Zähler `2` (bzw. `1`), Datei ungekürzt. Der Zähler kommt aus einem `grep`, nicht aus der Ersetzung; `main()` nimmt die Datei in `touched` und schreibt `N eingehend nachgezogen`, obwohl nichts nachgezogen wurde (gelesen, nicht gefahren: fällt keine andere Datei an,
  scheitert das `git commit` an „nichts zu committen"). Beide Funktionen liegen in `KERN` und sind in der emittierten Fassung wortgleich; ein Umbau zieht die Kopplung (Fall 23) mit. Die Aufrufer laufen unter `$(…)`, dort gilt `set -e` nicht.
- `Sensor-Doku` nennt die Lücke ausdrücklich; nicht Teil der DoD.

### V-3 — INFO — die emittierte Fassung trägt `psed_i` in der alten Form

- `befund`: gelesen (`internal/emit/templates/enforce/slice-mv.sh`, Zeilen 80–87): `sed "$@" >"$tmp"; cat "$tmp" >"$ziel"; rm -f "$tmp"`. Der Aufrufer `rewrite_incoming_in_file` steht in der emittierten `main()` **bloß** (ohne `||`) unter `set -euo pipefail`: ein `sed`-Ausfall bricht dort vor dem `cat` ab, die Datei bleibt (abgeleitet, nicht gefahren). Die Aussage des Implementers „ihr Aufrufer nutzt `$(…)`, wo `set -e` ohnehin nicht gilt" trifft nur `rewrite_incoming_bare_in_file` und
  `rewrite_outgoing_bare_in_file` (`$(…)`); für die Präfix-Schleife gilt sie nicht, und sie ist dort **unproblematisch**. Bestätigt als Restrisiko: `psed_i` steht außerhalb von `KERN`, ein Vergleich der Fassungen sieht die Abweichung nicht.

### V-4 — INFO — zwei Zweige der Härtung ohne eigenen Zahn

- `befund`: `|| return 2` in `rewrite_incoming_nach_baum` (Zeile `n="$(rewrite_incoming_links_in_file "$@")" || return 2`): entfernt bleibt die Suite grün (L14) — `[ "" -gt 0 ]` liefert ebenfalls Status 2, die Kette trägt zufällig. `mktemp … || return 2` in `psed_i` (gelesen, nicht gefahren). Kein DoD-Punkt; wer die Zusage „Status 2" je Zweig halten will, braucht je einen Fall.

### V-5 — INFO — Skriptkopf und Sensor-Doku sagen die Ränder der Form-Regel verschieden

- `befund`: Sensor-Doku (fünfte Grenze) nennt Titel-Link und Spitzklammer-Form; Grenze (5) im Skriptkopf von `slice-mv.sh` nennt sie nicht. Beide Aussagen sind wahr (L11); der Kopf ist enger als die Doku.

## Übergaben

**Planner** — nicht in diesem Lauf zu schreiben (`AGENTS.md` §3.10):

- **Abnahme:** DoD Liefer-Punkte 1–3 und der Closure-Trigger 2 sind bestätigt; V-1 verschiebt sie nicht. Für §7 *Was ging anders als geplant*: die Härtung (`2e6e5684`) ist gebaut-nicht-geplant und ändert die Reichweite über `docs/reviews/` hinaus.
- **Risiko-Ausgänge §6 (Vorschlag, nach Belegen):** (1) Anker des Falls — *entfallen* (acht Anker je `1`, acht Fälle `ok`, jeder an der behaupteten Mutation rot gelesen). (2) Regex-Träger — *entfallen* (Gegenprobe M-c im Review rot; Fall 12 bindet, L8). (3) Verdrahtung — *entfallen* (Fall 462, Go-Test rot mit gelesener Meldung, L7).
  (4) `KERN`-Kopplung — *entfallen* (Regel liegt daneben; Fall 23 grün; `internal/` unberührt). (5) Link-Zitat im Span — *weiter offen* als benannte Grenze (Sensor-Doku, Fall 16, Trigger 6); kein Register-Eintrag, solange kein Move eine solche Zeile umschreibt.
- **Register / Klassen-Kandidaten** (Zähler und Belege urteilt der Planner): (a) *Fehlerabbruch durch Aufruf im `||`-Kontext entwaffnet* (Review R-1, im Slice behoben); (b) *Regel-Rand ohne benannte Lücke* (R-2, behoben in der Doku); (c) *Regel-Ausprägung ohne Fall* (R-3, behoben mit Fall 15/466);
  (d) V-1: *Zusage „Datei unverändert" gilt je Datei, nicht je Lauf*; (e) V-2/V-3 als **Beobachtung** (weiter offen): *Härtung eines Helfers erreicht nicht alle Aufrufer* — `psed_i` in der emittierten Fassung und die zwei `rewrite_*_bare_in_file` in `KERN` melden bei Ausfall Erfolg. Die Beobachtung ist ohne Vorgang, den der Zähler trägt, nur benannt, wenn der Planner sie so führt.
- **Ruhe-Marker:** der Marker *Nichts in Arbeit* ist mit `9840d434` aus der Roadmap entfernt, weil dieser Slice `in-progress/` beansprucht; er ist bei der Closure (`git mv` nach `done/`) wieder zu setzen, wenn `in-progress/` danach leer ist.
- **Zustandsaussagen, die sich ändern:** in der Sensor-Doku *„ein Kopplungs-Test dafür führt dieses Werkzeug noch nicht"* (Kopplungs-Slice) und *„die emittierte Fassung führt diese Härtung von `psed_i` nicht"* (Vorgang, der die Tool-Ebene entscheidet); im Plan §1 der Übergang *„bis der zweite Träger folgt"* und in `ADR-0070` Festlegung 5 der Übergang der von Hand wiederhergestellten Code-Span-Adresse —
  beide enden mit dem Geschwister-Slice für `archive-welle`. Der Geschwister-Slice muss die Form-Regel in `harness/sensors/archive-welle.md` nennen (Folgepflicht 1 (c)); bis dahin sagt die Sensor-Doku nur für `slice-mv`, dass Reports nur Link-Ziele bekommen.
- **Heredoc-Verstöße der Implementer:** keine Beobachtung meinerseits; die Commits dieses Diffs tragen ihre Messages aus Dateien (`.harness/state/commit-msg-impl-*.txt`, nicht ausgewertet). **Eigener Verstoß dieses Laufs:** ein einziges Heredoc (`cat > … <<'X'` auf eine leere Scratch-Datei, im Scratchpad, gleich wieder gelöscht) — kein Repo-Artefakt betroffen.

**Architect:** keine. **Implementer:** V-1 (Zusage einschränken oder Nachzug erst nach dem letzten Erfolg schreiben; Fall mit Ausfall an der zweiten Datei), V-4 optional.

## Was nur gelesen, nicht gemessen ist

- M-c (Träger nimmt nur den unmittelbaren Backtick-Kontext aus): aus dem Review übernommen, nicht nachgefahren.
- V-2 (`git commit` scheitert an „nichts zu committen"): abgeleitet; gefahren ist nur das Status-0-Verhalten und der falsche Zähler.
- `mktemp … || return 2` in `psed_i`, der `|| return 2` in `rewrite_incoming_links_in_file`: gelesen; der zweite ist an Fall 21 gebunden (Status 2 der Beispielprobe), einen eigenen Zahn führt keiner der beiden.
- Die emittierte Fassung: gelesen, nicht gefahren; `make full-smoke` ist nicht Gegenstand dieses Slice und nicht gelaufen.
- Beleg-Slot für den vollen `make mutate` ist nicht vorhanden und wurde nicht angelegt; die 13 Fälle sind ein Teillauf, kein Beleg.

## Summary

Liefer-Punkt 1 **bestätigt** · Liefer-Punkt 2 **bestätigt** · Liefer-Punkt 3 **bestätigt** (Zusatzabschnitt der Sensor-Doku mit Vorbehalt, V-1) · Closure-Trigger 2 (Politik D) **bestätigt** · 0 HIGH · 0 MEDIUM · 1 LOW (V-1) · 4 INFO (V-2 bis V-5).
