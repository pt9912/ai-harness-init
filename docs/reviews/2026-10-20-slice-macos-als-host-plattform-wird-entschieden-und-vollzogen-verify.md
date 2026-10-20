# Verifier-Report — slice-macos-als-host-plattform-wird-entschieden-und-vollzogen

Rolle Verifier, Stand HEAD da389393 (Basis 2634a855). Kein DoD-Haken gesetzt, nichts verschoben (Planner).

## Verdikte je DoD-Punkt

- **DoD 1 (Norm in AGENTS.md §3.9, Architect-Commit): bestätigt.** `git diff 2634a855..HEAD -- AGENTS.md | wc -l` → 0; der Absatz steht (AGENTS.md Z. 400-412) mit Auflösungs-Trigger und Wächter-Grenze; er nennt die vier Läufer (`mutate`, `mutate-auswahl`, `mutate-greift`, `full-smoke`), CI auf frischem Klon (MR-014) als Beleg-Ort, die Umwege als Hilfe ohne Anspruch, und LH-QA-03/-04 als unberührt, kein Change Request.
- **DoD 2 (Nicht-Norm-Texte): bestätigt, mit zwei Grenzen (unten).**
  - `git grep -nE 'Host Linux, macOS nicht getragen|Hilfe ohne Anspruch' -- harness/ docs/` (ohne docs/reviews): README Z. 58, 74, 75, 77, 80, 81 (je mit Zeiger auf §3.9), sensors/artifact-host.md Z. 7, mutate.md Z. 117, full-smoke.md Z. 14. Jede Fundstelle zeigt auf `AGENTS.md` §3.9 oder trägt `§3.9` im selben Satz; die Norm wird nicht abgeschrieben.
  - Linux als Host, CI als Beleg-Ort, Umwege ohne Anspruch: mutate.md Z. 117-119 und full-smoke.md Z. 13-14 nennen alle drei; artifact-host.md Z. 7 und README Z. 75/77 nennen „Hilfe ohne Anspruch", Z. 77 zusätzlich „ein Lauf darüber ist kein Beleg".
  - Trennung Dogfood-Läufer gegen Produkt-Binary ausdrücklich: mutate.md, full-smoke.md, artifact-host.md nennen LH-QA-03/-04 als unberührt. LH-QA-04 (Binary erstklassig auf macOS, Start-Smoke) wird nirgends widersprochen; die Diffs berühren nur Dogfood-Läufer.
  - `git diff 2634a855..HEAD --stat`: genau Plan (2 Dateien: Plan-Datei, Review-Report), `harness/README.md`, `sensors/artifact-host.md`, `full-smoke.md`, `mutate.md`; 55+/7-. AGENTS.md unberührt.
  - `docs/user/*`: `git grep -n 'artifact-host\|full-smoke-host\|gnubin' -- docs/user` → leer. Der Plan nennt docs/user „soweit dort ein Host-Lauf beschrieben ist"; keine Stelle, also keine Änderung nötig (Negativbefund, kein Befund).
  - Grenze A: README Z. 58/74/80/81 sagen „Host Linux, macOS nicht getragen" nicht wortgleich in jeder Zeile mit „Hilfe ohne Anspruch"; die Hilfe-Klasse steht in den Sensor-Dateien. Inhaltlich konsistent.
  - Grenze B: `harness/sensors/mutate.md` Z. 270-278 (unverändert, nicht im Diff) nennt als Messung, dass auf macOS mit BSD-sed `7 greifen, 646 Befunde` und mit gnu-sed `653 greifen` herauskommt, und dass §3.9 GNU-sed nicht als Host-Bedarf nennt. Das ist zur Norm konsistent (Messung, kein Anspruch) und wurde nicht neu gemessen (übernommen).
- **DoD 3 (`make gates` grün): bestätigt** — siehe unten (lokal auf macOS über Colima, nur als Stop-Hook-Stempel; kein Beleg im Sinne der Norm).

## Sensoren (selbst gefahren)

- `make docs-check` → `d-check: 2934 Datei(en) geprüft, 0 Befund(e)`.
- `make test-bats BATS_TARGET=test/targets-modul-wiring.bats` → ok 2-7 (Auszug), keine Fehlschläge.
- awk-Kommando der Zusatzklassen-Deklaration (harness/conventions.md) → letzte Zeile `0`.
- `make gates` am Ende, siehe Abschlussvermerk.

## Rot-Beleg (ehrlich)

- Die Zusage ist eine Deklaration in Prosa; **für ihren Inhalt existiert kein Sensor** (full-smoke.md/mutate.md/§3.9 sagen es selbst: kein Test weist einen Lauf auf Nicht-Linux ab). Ein Rot-Beleg für „Linux ist Host" ist nicht möglich und wird nicht behauptet.
- Messbar ist nur die Tabellenform. Bewusstes Brechen auf Worktree-Kopie (`.harness/state/wt-verify`, danach entfernt, Hauptbaum unberührt): Zeile `make lint` aus `harness/README.md` entfernt → `make docs-check`: `1 Befund(e)`, `Makefile:131 lint gate-undocumented …` (Exit 1). Das Modul `targets` greift also für Gates.
- Gegenprobe: Entfernen der Zeile `make artifact-host` blieb **0 Befunde**, weil `artifact-host` in `.d-check.yml` (Z. 199) in `exempt-targets` steht. Folge: die Werkzeuge-Zeilen (Marke `kein Gate`, §3.9-Zeiger) sind **nicht** gewächtert; ein Verlust der neuen Spaltentexte färbt nichts rot. Das ist die benannte Grenze der Deklaration, kein Befund gegen den Slice.

## Offene Punkte

- **LOW/INFO (nicht im Plan, nicht geändert): Makefile:167** `artifact-host: ## … additiv, für lokale Smokes auf Nicht-Linux-Hosts` steht in Spannung zur Norm (Hilfe ohne Anspruch; nennt Nicht-Linux als Einsatz). Die Hilfezeile ist Nicht-Norm-Text außerhalb der Plan-Dateiliste; Folge-Punkt für den Planner, wie vom Implementer vorgeschlagen. Auch Makefile Z. 165 (Kommentar „macOS, Windows") ist betroffen.
- Wächter-Lücke der Deklaration bleibt benannt (siehe oben).

## Welche Läufe wo liefen

Alle meine Läufe (`make docs-check`, `test-bats`, `make gates`, Rot-Probe) liefen auf macOS über Colima. Unter der neuen Norm sind sie **kein Beleg**; sie sind der lokale Stop-Hook-Nachweis. Beleg-Ort ist CI auf frischem Klon; ein CI-Lauf auf diesem Stand liegt **noch nicht vor** (kommt nach dem Push). DoD 3 ist darum bis dahin lokal bestätigt, in CI offen.

## Zählung/Stichproben

Review (a5d2fe29) hat gelesen; ich habe Diff, Fundstellen und Norm-Absatz selbst gelesen und gemessen, den Mutations-Messwert in mutate.md Z. 270-278 nicht neu gemessen.
