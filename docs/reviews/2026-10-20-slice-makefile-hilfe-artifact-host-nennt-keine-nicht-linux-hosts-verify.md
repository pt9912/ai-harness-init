# Verifikation slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts

Rolle: Verifier. Stand HEAD 838df82b (Basis 45b5b4de; Makefile-Diff a0944093). Plan: `docs/plan/planning/in-progress/slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts.md`. Review: 0 HIGH/MEDIUM/LOW, 2 INFO, vollstaendig gelesen; hier Stichproben und eigene Messungen.

## Verdikte je DoD-Punkt

- **Texte nennen keinen Nicht-Linux-Host als Einsatz, zeigen auf AGENTS.md §3.9, nennen was kein Sensor haelt** — bestaetigt (bedingt: Wortlaut ohne Sensor, s. u.).
  - `git diff 45b5b4de..a0944093 --stat`: nur `Makefile`, 13+/14-; der Diff besteht aus `#`-Kommentar- und `## `-Zeilen (gelesen); kein Rezept, Zielname, Variable, .PHONY.
  - `git grep -nE 'macOS|Windows|Nicht-Linux|Devhost' -- Makefile` -> einzige Fundstelle Z. 492 (`host-bin`, Bestand, ausdruecklich nicht Gegenstand). Alle sechs Textstellen sind frei von Plattformnamen.
  - "kein Sensor haelt diesen Text" steht bei `artifact-host` und `smoke-host` (Kommentar), nicht bei `full-smoke-host` und `artifact` (Review-INFO 2, nachvollzogen; die Zusage ist dort nicht gemacht, daher kein Befund).
  - Zusage "kein Sensor haelt den Text" gemessen: `git grep -nE 'Hilfe ohne Anspruch|kein Sensor haelt diesen' -- test harness .d-check.yml` findet nur Prosa in `harness/README.md` (Z. 75, 77), `harness/sensors/artifact-host.md` und `harness/sensors/mutate.md`; kein Test, keine Konfiguration prueft die `## `-Zeilen. Zusage stimmt.
- **Eigenschaft "nur Text, Verhalten unveraendert"** (Plan §1/§3) — bestaetigt, eigene Messung:
  - `make -n` fuer artifact, artifact-host, smoke, smoke-host, full-smoke, full-smoke-host, host-bin (DEST=/x), neuer Stand gegen `git show 45b5b4de:Makefile` (Kopie unter `.harness/state/`, danach geloescht): `cmp` je Ziel byte-gleich, inkl. Exit-Code.
  - `make help` vorher/nachher: `diff` zeigt genau drei Zeilen (artifact-host, smoke-host, full-smoke-host); sonst identisch.
- **`make gates` gruen** — siehe unten (Lauf nach Commit dieses Reports).
- Review-Report liegt vor (`docs/reviews/2026-10-20-slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts.md`) — bestaetigt.
- Closure-Notiz, Register, Risiko-Ausgang, Paarungen: Planner-Arbeit (AGENTS.md §3.10), nicht Gegenstand; §6-Risiko traegt bereits Ausgang "weiter offen" mit Register-Zeiger. Keine DoD-Haken gesetzt.

## Weitere Messungen

- §3.9 nicht angefasst: `git diff 45b5b4de..HEAD -- AGENTS.md | wc -l` -> 0.
- `make mutate-greift` (PATH mit GNU-sed): `762 Fall/Faelle, 762 greifen, 0 Befund(e)`. Ein erster Lauf ohne GNU-sed gab 755 Befunde (BSD-sed scheitert) — Host-Artefakt, kein Befund am Slice.
- `make docs-check`: `d-check: 2937 Datei(en) geprueft, 0 Befunde`.

## Rot-Beleg

Reine Text-Deklaration ohne Sensor: fuer den Wortlaut gibt es keinen Rot-Beleg und es wird keiner erfunden. Belegt ist nur die Eigenschaft "Text beruehrt keine Rezepte" — der Beleg ist die byte-gleiche `make -n`-Ausgabe oben. Zur Empfindlichkeit dieses Mittels: in einer Kopie (`.harness/state/`, geloescht) eines Makefile mit entferntem Rezept-Tab bricht `make -n` mit `*** commands commence before first target. Stop.` ab; ein Rezept-Eingriff faerbt den Vergleich also rot. Das ist ein Beleg fuer die Eigenschaft, nicht fuer den Wortlaut.

## Offene Luecken

- **INFO/LOW — Mutations-Probe gegen den neuen Stand: nicht gemessen.** `make mutate-auswahl` waehlt 21 Faelle (Schwelle 8, CI-Branch); sie waehlen nach `# files: Makefile`, nicht nach Zeile. Die CI-Probe ist (Entscheidung Hauptkontext) nicht gefahren. `make mutate-greift` (762/762) belegt nur, dass jeder Patch seine Datei aendert, nicht dass ein Waechter rot wird. Dass der Diff keine Anker-Rezepte beruehrt, ist am Diff gelesen (nur Kommentar-/Hilfezeilen), nicht durch Lauf belegt; Restrisiko gering, da `make -n` aller Rezepte der sieben Ziele byte-gleich ist (andere Rezepte unberuehrt: Diff-Hunks liegen nur an Z. 151-235).
- Wortlaut der sechs Textstellen ist ungewaechtert (Plan §6, Register-Zeiger vorhanden).
- **Plattform (AGENTS.md §3.9):** alle Laeufe hier auf macOS (make -n, help, mutate-greift, docs-check, gates, lokaler Stop-Hook-Nachweis) sind kein Beleg fuer Linux-Verhalten; Beleg ist die CI auf frischem Klon nach dem Push. Fuer eine reine Textaenderung ist das Risiko klein, bleibt aber unbelegt bis dahin.

## Zusammenfassung

Alle inhaltlichen DoD-Punkte bestaetigt; keine Findings ausser der benannten Luecke (Mutations-Probe nicht gemessen) und dem Plattform-Vorbehalt.
