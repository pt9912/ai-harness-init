# Slice slice-mutate-auswahl-liest-jeden-fall-einmal: Die Fall-Auswahl liest die Angaben jedes Falls einmal

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — eine Closure-Bedingung über die DoD hinaus gibt es nicht.

**Bezug:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Docker-only, kein
Host-Werkzeug), [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
[`MR-089`](../../../../harness/conventions.md#mr-089) (Form der Laufzeit-Messung),
[`MR-025`](../../../../harness/conventions.md#mr-025) (Zahl neben ihrem Kommando).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** `faelle_ueber` in `harness/tools/mutate-auswahl.sh` liefert dieselbe Fallmenge wie heute, ohne
je Fall, Datei und Angabe einen Prozess zu starten, und meldet Fortschritt.

**Befund (gemessen).** In `faelle_ueber` (Zeilen 81–102) liest `sed -n 's/^# files: //p' "$case_file" | tr ' ' '\n'`
die `# files:`-Zeile eines Falls für **jede** geänderte Datei neu, und jede Angabe geht durch
`$(muster_zu_regex "$spec")`, eine Command Substitution mit `sed`. Der Aufwand ist Fälle × Dateien ×
Angaben mit mehreren Forks je Paar. Bei 654 Fällen und 166 geänderten Dateien (Claim-Commit `458e0836`
bis HEAD im Sprung auf v6.18.0) sind das rund 108.000 Paare. Stichproben außerhalb des Repos: 30 Fälle
brauchten 41 CPU-s, 29 verteilte Fälle 37 CPU-s, etwa 1,3 CPU-s je Fall und rund 850 CPU-s für alle; der
Lauf auf `e5a3000b` hatte nach 20 Minuten Wanduhr 1480 CPU-s verbraucht und war nicht fertig. Bei
kleinen Slices fiel das nicht auf. Die Auswahl schreibt keine Fortschrittszeile.

**Soll.** Die Angaben eines Falls werden einmal gelesen und einmal in einen regulären Ausdruck umgesetzt
und danach gegen alle Dateien verglichen, ohne weiteren Prozess je Paar (reines Bash oder ein
`awk`-Durchlauf). Die Ausgabe auf stdout bleibt byte-gleich. Je 50 Fälle geht eine Fortschrittszeile auf
stderr.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- `mutate.sh` und die Verteilung auf Shards (`fall_gewicht`, Zuteilung) — Bestand bleibt stehen: Gemessen
  ist allein die Auswahl, und ein Eingriff dort verfälschte den Gleichheitsbeleg.
- Das Urteil und die Schwelle 8 — eine Schwellen-Änderung wäre ein ADR-Vorgang
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5), kein Teil einer Laufzeit-Korrektur.
- Die Muster-Semantik (`*` trifft auch `/`, `?` genau ein Zeichen, alles andere wörtlich) — bleibt, weil
  die Gleichheit der Ausgabe die Zusage ist; ein anderes Muster wäre ein anderer Vorgang.

## 2. Definition of Done

Liefer-Punkte:

- [ ] **1. Umbau der Auswahl** samt Fortschrittszeile auf stderr. Rot-Beleg: `test/mutate-auswahl.bats` und
      die Mutationsfälle 652–665 bleiben grün; eine Mutation am neuen Code (etwa nur die erste Angabe
      eines Falls lesen, oder den Anker `^…$` weglassen) färbt einen dieser Tests aus dem behaupteten
      Grund rot, Meldung gelesen. Bindet keiner der Tests die Mutation oder die Fortschrittszeile,
      kommt ein Test oder Fall dazu.
- [ ] **2. Messung vorher/nachher** in der Form von [`MR-089`](../../../../harness/conventions.md#mr-089)
      (Geltung dort: emittierter und E2E-Lauf; hier als Form übernommen): das Kommando, die Lage
      (warm/kalt) und die Variante (Aufruf über `make` oder Skript direkt), dazu die Dateizahl — Fälle
      und geänderte Dateien, jeweils mit dem Kommando, das sie ausgibt.
- [ ] **3. Gleichheits-Beleg über einen realen Bestand:** alter und neuer Code liefern auf demselben
      Bestand und demselben Diff dieselbe Fallmenge, mindestens für den Diff des Sprungs auf v6.18.0
      (Claim `458e0836` bis `e5a3000b`), Vergleich mit `diff` auf den sortierten Mengen. Gegenprobe:
      eine Mutation am neuen Code macht den `diff` nicht leer.

Zusätzlich, konstant je Slice:

- [ ] `make gates` grün; Review mit Report unter `docs/reviews/` (Rollenwechsel, `.harness/skills/reviewer.md`).
- [ ] Closure-Notiz mit Lerneintrag; Beobachtungs-Register fortgeschrieben (oder „keine Beobachtung");
      jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind getragen.


## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate-auswahl.sh` | update | `faelle_ueber`/`muster_zu_regex`: Angaben je Fall einmal lesen und umsetzen, danach Vergleich ohne Prozess je Paar; Fortschrittszeile je 50 Fällen auf stderr; Kopfkommentar nennt die Zusage (Liefer-Punkt 1) |
| `test/mutate-auswahl.bats` | update | Fall mit mehreren Angaben, Sonderzeichen, `*` über `/`, `?`; stdout unverändert, Fortschritt nur auf stderr (Liefer-Punkt 1) |
| `test/mutations/` | neu, nur wenn 652–665 die Mutation oder die Fortschrittszeile nicht binden | Rot-Beleg als Fall (Liefer-Punkt 1) |

## 4. Trigger

**Start** (`next` → `in-progress`): Der Sprung `slice-sprung-auf-v6180-wird-vollzogen` liegt in `done/`;
der Implementer-Slot ist frei (WIP-Limit 1 je Lauf). Der Sprung wartet selbst auf diese Auswahl; scheitert
sein Lauf daran, ist das ein Fall für die Rückführung unten.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß): Gleichheit verlangt einen Eingriff in `mutate.sh` oder in die
  Verteilung über einen Lese-Aufruf hinaus.
- `in-progress` → `open` (blockiert): Der Sprung bleibt ohne Auswahl-Lauf und der alte Code liefert für den
  Diff des Sprungs keine Menge in vertretbarer Zeit; dann fehlt die Vergleichsseite von Liefer-Punkt 3.

## 5. Closure-Trigger

Die drei Liefer-Punkte sind belegt, `make gates` ist grün, die Closure-Notiz trägt den Lerneintrag.

## 6. Risiken und offene Punkte

- **Randfall der Umsetzung.** Die Bash-Umsetzung von `muster_zu_regex` weicht in einem Zeichen ab, das
  der reale Bestand nicht trägt (Tab, Backslash, `]` in einer Angabe). Liefer-Punkt 3 misst nur den
  Bestand. — **Ausgang:** bei Closure.
- **Der alte Lauf auf dem Sprung-Diff ist teuer** (rund 850 CPU-s und mehr). — **Ausgang:** bei Closure.
- **Der Rest der Auswahl ist nicht gemessen.** `fall_gewicht` und `basis_commit` laufen nach dem Umbau
  womöglich als nächster Posten. — **Ausgang:** bei Closure.

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

Modus: alle berührten Sub-Areas GF.

