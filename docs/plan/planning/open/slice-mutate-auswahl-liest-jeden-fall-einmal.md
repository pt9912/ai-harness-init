# Slice slice-mutate-auswahl-liest-jeden-fall-einmal: Die Fall-Auswahl wird einmal berechnet

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — eine Closure-Bedingung über die DoD hinaus gibt es nicht.

**Bezug:** [`ADR-0003`](../../adr/0003-go-native-binaries.md), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Docker-only, kein
Host-Werkzeug), [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
[`MR-089`](../../../../harness/conventions.md#mr-089) (Form der Laufzeit-Messung),
[`MR-025`](../../../../harness/conventions.md#mr-025) (Zahl neben ihrem Kommando).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Fallmenge eines Slice wird einmal berechnet, von einem kleinen Go-Programm im vorhandenen
Dockerfile-Stack, und vom Job `plan` an alle Shards und den Job `ergebnis` weitergereicht. Die Menge bleibt
dieselbe wie heute.

**Befund (gemessen).** `faelle_ueber` in `harness/tools/mutate-auswahl.sh` (Zeilen 81–102) liest die
`# files:`-Zeile eines Falls für **jede** geänderte Datei neu (`sed … | tr`), und jede Angabe geht durch
`$(muster_zu_regex "$spec")`, eine Command Substitution mit `sed`. Der Aufwand ist Fälle × Dateien ×
Angaben mit mehreren Forks je Paar. Bei 654 Fällen und 166 geänderten Dateien (Claim-Commit `458e0836`
bis HEAD im Sprung auf v6.18.0) sind das rund 108.000 Paare. Stichproben außerhalb des Repos: etwa
1,3 CPU-s je Fall, rund 850 CPU-s für alle. Dazu rechnet jeder Job die Auswahl selbst: `plan` (Schritt
`lauf`), jeder der 10 Shards (`shard_faelle`) und `ergebnis` (`ergebnis_schreiben`, `faelle_fuer`). Im CI-Lauf
Run 38033467402 liefen die Shards rund 28 Minuten und die Auswahl je Job über 20 Minuten; ein voller Lauf
am 7.10. brauchte rund 32 Minuten.

**Soll.**

- Ein Go-Programm (Stage im `Dockerfile`, Aufruf über `make`; [`ADR-0003`](../../adr/0003-go-native-binaries.md), Docker-only, kein neues Image,
  kein Python) liest Fälle und `# files:`-Zeilen **einmal**, wertet die Muster im Prozess aus — ohne
  `sed`/`awk`/`tr` — und gibt die getroffenen Fall-Namen sortiert aus. Die Muster-Semantik bleibt (`*` trifft
  auch `/`, `?` genau ein Zeichen, alles andere wörtlich, Anker an beiden Enden).
- Der Job `plan` ruft die Auswahl einmal und reicht die Menge (Job-Output oder Artefakt) an `shard` und
  `ergebnis`; die rechnen nicht neu. `faelle_fuer`/`faelle_ueber` entfallen im Skript oder rufen das
  Programm.
- Tests der Auswahl sind Go-Tests; bats-Fälle, die an `faelle_ueber` hingen, gehen entsprechend über.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- `fall_gewicht` und die Zuteilung auf Shards, das Urteil und die Schwelle 8 — Bestand bleibt stehen:
  gemessen ist die Auswahl, und eine Schwellen-Änderung wäre ein ADR-Vorgang
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5).
- Die Muster-Semantik — die Gleichheit der Menge ist die Zusage; ein anderes Muster wäre ein anderer Vorgang.
- Norm-Text: [`MR-091`](../../../../harness/conventions.md#mr-091) nennt die Auswahl je Job; ob die
  Weitergabe eine Änderung dort verlangt, entscheidet der Architect (Übergabe, §6) — der Planner schreibt
  keinen MR.

## 2. Definition of Done

Liefer-Punkte:

- [ ] **1. Go-Auswahl** im Dockerfile-Stack (Programm, Stage, `make`-Ziel) mit Go-Tests statt bats für die
      Auswahl (Mehrfach-Angaben, Sonderzeichen, `*` über `/`, `?`, Anker). Rot-Beleg: eine Mutation am
      Programm (nur die erste Angabe lesen; Anker weglassen) färbt einen Go-Test aus dem behaupteten Grund
      rot, Meldung gelesen. **Gleichheits-Beleg** über den realen Bestand: alte (Bash) und neue Auswahl
      liefern auf dem Diff `458e0836..e5a3000b` (140 Fälle) dieselbe Menge, `diff` auf den sortierten
      Mengen leer; Gegenprobe: die Mutation macht den `diff` nicht leer.
- [ ] **2. Einmalige Berechnung im CI:** der Job `plan` berechnet die Auswahl und reicht sie an die 10
      Shards und `ergebnis` weiter; `shard_faelle`, `urteil` und `ergebnis_schreiben` rechnen nicht neu.
      Rot-Beleg: `test/mutate-auswahl.bats` bindet, dass kein Aufrufer außer `plan` die Auswahl ruft
      (Mutation: ein Shard rechnet neu, Test rot); die Mutationsfälle zu `mutate-auswahl.sh` bleiben
      grün oder werden nachgezogen.
- [ ] **3. Messung vorher/nachher** in der Form von [`MR-089`](../../../../harness/conventions.md#mr-089)
      (Geltung dort: emittierter und E2E-Lauf; hier als Form übernommen): Kommando, Lage (warm/kalt),
      Variante (über `make` oder Skript direkt), Fälle und geänderte Dateien je mit dem Kommando, das sie
      ausgibt; CI-Wanduhr des Auswahl-Schritts vor (Run 38033467402) und nach dem Umbau.

Zusätzlich, konstant je Slice:

- [ ] `make gates` grün; Review mit Report unter `docs/reviews/` (Rollenwechsel, `.harness/skills/reviewer.md`).
- [ ] Closure-Notiz mit Lerneintrag; Beobachtungs-Register fortgeschrieben (oder „keine Beobachtung");
      jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind getragen.

**Größenregel.** Drei Liefer-Punkte; Schichten: Werkzeug-Code (Go, Dockerfile) und Harness-Verdrahtung
(Skript, Makefile, Workflow) — zwei. Wächst der Eingriff ins Skript über das Ersetzen der Aufrufe hinaus,
ist das die Rückführung `in-progress` → `next` (§4).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Go-Programm der Auswahl (Ort entscheidet der Architect) | neu | Fälle und `# files:` einmal lesen, Globs im Prozess (Liefer-Punkt 1) |
| `Dockerfile`, `Makefile` | update | Stage bzw. Ziel, das das Programm im gepinnten Image baut und fährt; Docker-only (Liefer-Punkt 1) |
| `harness/tools/mutate-auswahl.sh` | update | `faelle_ueber`/`muster_zu_regex` entfallen; `lauf` gibt die Menge aus, `shard_faelle`/`urteil`/`ergebnis_schreiben` lesen sie statt zu rechnen (Liefer-Punkt 2) |
| `.github/workflows/mutate-branch.yml` | update | `plan` reicht die Menge an `shard` und `ergebnis` (Job-Output oder Artefakt) (Liefer-Punkt 2) |
| `test/mutate-auswahl.bats`, Go-Tests, `test/mutations/` | update/neu | Rot-Belege der Liefer-Punkte 1 und 2 |

## 4. Trigger

**Start** (`next` → `in-progress`): Der Sprung `slice-sprung-auf-v6180-wird-vollzogen` liegt in `done/`
oder ruht bis zu diesem Slice; der Implementer-Slot ist frei (WIP-Limit 1 je Lauf).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß): der Eingriff greift über das Ersetzen der Auswahl-Aufrufe hinaus in
  `mutate.sh`, die Verteilung oder das Urteil; oder die Weitergabe verlangt ein viertes Liefer-Element.
- `in-progress` → `open` (blockiert): die Norm ([`MR-091`](../../../../harness/conventions.md#mr-091)) verlangt vor der Umsetzung eine Änderung, die der
  Architect noch nicht geschrieben hat.

## 5. Closure-Trigger

Die drei Liefer-Punkte sind belegt, `make gates` ist grün, die Closure-Notiz trägt den Lerneintrag.

## 6. Risiken und offene Punkte

- **Randfall der Muster-Umsetzung.** Das Go-Programm weicht in einem Zeichen ab, das der reale Bestand nicht
  trägt (Tab, Backslash, `]`). Der Gleichheits-Beleg deckt nur den Bestand. — **Ausgang:** bei Closure.
- **Der alte Lauf auf dem Sprung-Diff ist teuer** (rund 850 CPU-s und mehr); die Vergleichsseite von
  Liefer-Punkt 1 muss ihn einmal fahren. — **Ausgang:** bei Closure.
- **Weitergabe über Job-Output/Artefakt.** Größe (Job-Output ist begrenzt) und Vertrauensgrenze
  (`ergebnis` schreibt mit `contents: write`; eine weitergereichte Menge ist Eingabe) sind zu klären. —
  **Ausgang:** bei Closure.
- **Norm berührt.** [`MR-091`](../../../../harness/conventions.md#mr-091) und `harness/sensors/mutate.md`
  nennen die Auswahl je Job. — **Ausgang:** bei Closure (Übergabe an den Architect vor dem Start).
- **Der Rest der Auswahl ist nicht gemessen** (`fall_gewicht`, `basis_commit`). — **Ausgang:** bei Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `harness/tools/` (`TOOLS`, Greenfield); `test/` gehört
zur Sub-Area `*` (`ALL`). Beide stehen in der Modus-Deklaration von `harness/conventions.md`.

**Vorgelagert — offene Beobachtungen sichten:** Das Register wurde nach mutate, Auswahl und Laufzeit
durchgesehen (gemergter Stand, Zähler = `ls <eintrag>/evidence | wc -l`):

- `docs/plan/planning/observations/BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor/` (1×,
  offen): betrifft die Verteilung, die dieser Slice nicht anfasst; die Kosten der Auswahl selbst sind ein
  anderer Gegenstand.
- `docs/plan/planning/observations/BEO-ALL/mutate-matrix-actions-minuten-bei-privatem-repo/` (1×, offen):
  nicht berührt.
- `docs/plan/planning/observations/BEO-ALL/mutations-fall-zeigt-auf-falsche-datei/` (2×, offen) und
  `docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/`: die Fortschrittszeile ist
  eine neue Zusage; trifft einer der Einträge hier, erreicht er mit diesem Slice 3× und braucht einen
  eigenen Folge-Slice.
- `docs/plan/planning/observations/BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen/`:
  Form der Messung ([`MR-089`](../../../../harness/conventions.md#mr-089)), nicht der Gegenstand.
- Zu Auswahl-Laufzeit gibt es keinen Eintrag; die Kosten fielen bei kleinen Slices nicht auf.

Berührt ist zusätzlich das Go-Programm samt `Dockerfile` (`*`, `ALL`). Modus: alle berührten Sub-Areas GF.

