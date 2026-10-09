# Review — slice-mutations-anker-greift-in-den-gates

**Rolle:** Reviewer (`.harness/skills/reviewer.md`) · **Datum:** 2026-10-09 ·
**Gegenstand:** `9fbc304c`, `aeb318d4`, `e49b8534` gegen den Plan
`docs/plan/planning/in-progress/slice-mutations-anker-greift-in-den-gates.md`, `MR-071`, `MR-089`,
`AGENTS.md` §3. DoD-Abhakung nicht geprüft (Verifier).

**Summary:** 0 HIGH · 3 MEDIUM · 2 LOW · 3 INFO — Modus greift real, Fixtures byte-gleich, Fall 635
grün; offen sind die ungedeckte Verdrahtung `--greift` → `greift_main`, ein latenter Stilles-Grün-Pfad
bei Präfix-Pfaden, die GNU-Abhängigkeit im Gate-Pfad und die nicht gezogene Rückführung §4 (an den
Planner).

## Findings

### M-1 — Die Verdrahtung Rezept → Modus hält kein Test

- **kategorie:** MEDIUM · **quelle:** `AGENTS.md` §3.6, `LH-QA-01`
- **pfad:** `harness/tools/mutate.sh:1964-1968`; `harness/sensors/mutate.md` §Greift-Modus, Satz *„die
  Verdrahtung hält `test/gate-nachweis-kante.bats`"*
- **befund:** Beide bats-Fälle und Fall 635 rufen `greift_main` über `source` direkt; den Zweig
  `--greift` im Direktaufruf, den `make mutate-greift` fährt, ruft kein Test
  (`grep -rn -- '--greift\|mutate-greift' test/` → nur Kommentar und die Kanten-Liste). Bruchprobe in
  einer Scratch-Kopie mit den Fixtures 29/247 als Fall-Set: unmutiert Exit 1 mit zwei Befunden;
  `greift_main "$CASES_DIR" "$REPO"` → `true` ersetzt: Exit 0 ohne Ausgabe. `gate-nachweis-kante.bats`
  hält nur, dass das Ziel an `record-gates` hängt, nicht was sein Rezept tut.
- **verifizierbar:** ja (Bruchprobe oben) · **klasse:** Zahn fährt nicht die Verdrahtung des Aufrufers

### M-2 — Latenter Stilles-Grün-Pfad: Präfix-Pfade in `# files:`

- **kategorie:** MEDIUM (LOW, Kontext-Eskalation Gate-Pfad) · **quelle:** `AGENTS.md` §3.6, Skill
  §HIGH *Stilles-Grün-Pfad* (heute nicht erreichbar, darum nicht HIGH)
- **pfad:** `harness/tools/mutate.sh` `greift_case`, Schleife `grep -F -- " $f" .greift-before | sha256sum -c -`
- **befund:** Trägt ein Fall zwei Pfade, deren einer Präfix des anderen ist (`a.txt`, `a.txt.bak`),
  trifft der grep für `a.txt` beide Zeilen; ändert der Patch nur `a.txt.bak`, scheitert `sha256sum -c`
  an dieser Zeile und `a.txt` gilt als gegriffen. Sonde in Scratch: Fall `# files: a.txt a.txt.bak`,
  Patch nur auf `.bak` → als greifend gezählt, kein Befund. Im Bestand trägt kein Fall zwei Pfade
  (`grep -l '^# files: .* ' test/mutations/*.sh` → leer); die Form ist aus `run_case` (Zeile ~805)
  übernommen, steht jetzt aber im Gate, dessen Zeile in `harness/README.md` *„jede Datei aus
  `# files:`"* zusagt.
- **verifizierbar:** ja · **klasse:** Zusicherung je Datei über Teilstring-Match

### M-3 — Gate-Pfad braucht GNU-Werkzeuge auf dem Host (an den Planner, Risiko §6 Punkt 2)

- **kategorie:** MEDIUM · **quelle:** `LH-QA-02` (Reproduzierbarkeits-Risiko), `AGENTS.md` §3.9
- **pfad:** `Makefile` Rezept `mutate-greift` und Kommentar *„Hermetisch wie comment-claims"*;
  `harness/sensors/mutate.md` §Grenze
- **befund:** §3.9 ist nicht verletzt — `bash`, `sed`, `sha256sum` sind keine Toolchain und kein
  Paketmanager, und `make mutate` fuhr Fall-Skripte schon bisher auf dem Host (Zeile 760). Neu ist, dass
  `make gates` jetzt 617 Fall-Skripte mit `sed -i '…'` ohne Suffix-Argument und `\t` im Muster sowie
  `mktemp -d -p` auf dem Host fährt — GNU-Formen. `comment-claims.sh` und `register-ausgang.sh`
  nutzen keine davon (`grep -cE 'sed -i|mktemp -d -p|grep -P'` → 0/0); der Vergleich „wie
  comment-claims" trägt darum nur für die Ausführung ohne Container, nicht für die Werkzeugmenge.
  §3.9 nennt als Host-Bedarf „`git`, `docker` und GNU `make`, sonst nichts"; die Grenze in
  `mutate.md` nennt die GNU-Abhängigkeit nicht. Dass CI auf `ubuntu` läuft, deckt das nicht ab.
- **verifizierbar:** nein (kein Nicht-GNU-Host gefahren; gelesen) · **klasse:** Host-Werkzeug-Annahme im Gate-Pfad unbenannt

### M-4 — Rückführung §4 nicht gezogen, Out-of-Scope §1 überschritten (an den Planner)

- **kategorie:** MEDIUM · **quelle:** Plan §1/§4, `AGENTS.md` §3.10, Baseline-Regelwerk
  `modul-05-planning-harness.md` §Ziel-Form: Slice
- **pfad:** Plan §1 Punkt 3, §4 `in-progress → open`; Commit `9fbc304c`
- **befund:** §1 schließt die Reparatur entwaffneter Fälle aus und verweist auf §4; §4 verlangt bei
  diesem Fund die Rückführung, die Reparatur als eigenen Vorgang und erst danach den Anschluss an das
  Gate. Repariert wurde im selben Slice (eigener Commit, aber derselbe Vorgang), ohne Plan-Diff. Die
  Begründung, MR-071 mache das zur Pflicht des Implementers, deckt der Text nicht: MR-071 regelt die
  **Anlage** neuer Fälle und schließt den Treiber und den Bestand ausdrücklich aus. Damit ist eine
  Out-of-Scope-Grenze verschoben, ohne dass ein Übergabe-Artefakt an den Planner vorliegt; die
  Reparatur selbst ist in Ordnung (s. L-1).
- **verifizierbar:** nein (Prozess) · **klasse:** Abgrenzung im Lauf überschritten ohne Plan-Korrektur

### L-1 — Fall 145 mutiert breiter, als sein Kopf sagt

- **kategorie:** LOW · **quelle:** `AGENTS.md` §3.6, `MR-071`
- **pfad:** `test/mutations/145-report-rollenlose-im-nenner.sh:17`
- **befund:** Die Erwartung ist unverändert, und der Fall wird aus dem richtigen Grund rot. Der neue
  Anker entfernt aber zusätzlich den Filter `!span.IsNotKnown(…)`, den Fall 602 bewacht. Die enge Form
  (nur `s.AgentRole != "" &&` entfernen) färbt den benannten Test allein: Sonde
  `make mutate MUTATE_CASES=999-reviewer-probe-145-eng` → `ok … TestAggregiere_RollenloseCallsNichtImNenner rot`
  (Sondenfall danach entfernt). Der Kopf nennt nur die rollenlosen Calls. Fall 147 ist exakt (er
  entfernt nur `&& s.Tool != ""`).
- **verifizierbar:** ja · **klasse:** Mutation breiter als die benannte Bedingung

### L-2 — Übergabe an den Architect: in der Grenzen-Liste fehlen vier Punkte

- **kategorie:** LOW · **quelle:** `AGENTS.md` §3.8, `MR-071` §Grenze
- **pfad:** `docs/reviews/2026-10-09-slice-mutations-anker-greift-in-den-gates-uebergabe-architect.md` §Vorschlag, Grenze 1–4
- **befund:** Die Übergabe schreibt keinen Norm-Text vor. Sie liefert einen Vorschlag zu Form,
  Sensor und Grenze und stellt die Trigger-Frage offen; das ist zulässig. Es fehlen M-1 bis M-3 und
  die Einengung durch `MUTATE_CASES` (I-1). Ein Architect, der die Grenze aus dieser Quelle schreibt,
  sagt zu viel zu.
- **verifizierbar:** nein · **klasse:** Übergabe-Grenze unvollständig

### I-1 — `MUTATE_CASES` aus der Umgebung engt das Gate ein

- **kategorie:** INFO · **pfad:** `Makefile` `mutate-greift`; `greift_main`
- **befund:** `MUTATE_CASES=29-roadmap-nicht-neutralisiert make mutate-greift` → `1 Fall/Faelle,
  1 greifen, 0 Befund(e)`, Exit 0; unter `record-gates` stempelt das einen eingeengten Lauf. Das ist
  dokumentiert (`mutate.md`: „engt ein wie beim vollen Lauf") und hat einen Vorläufer
  (`BATS_TARGET ?= test/`). Die Zeile in §Sensors sagt trotzdem „Jeder Mutations-Fall".

### I-2 — Beleg im Register-Eintrag / MR-071 Auflösungs-Trigger 3 (an den Planner)

- **kategorie:** INFO · **pfad:** Plan §8 (*„seit der Verkörperung 2 von 3"*)
- **befund:** 145/147 wurden von `ac429eec` entwaffnet, also von derselben Änderung, die Fall 602
  anlegte. Das ist eine weitere Instanz von
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`. Zählt sie, steht der dritte
  Auflösungs-Trigger von MR-071 an (*„drei weitere Vorgänge"*). Entscheidung bei der Closure.

### I-3 — „scheitert in der Kopie" ist eine bedingte Zusage

- **kategorie:** INFO · **pfad:** `harness/tools/mutate.sh` Kopf von `greift_case`; `mutate.md` §Grenze Punkt 2
- **befund:** Ein Fall-Skript, das eine fremde Datei nur bedingt liest (`if grep -q … ; then`), scheitert
  in der Kopie nicht, sondern läuft durch. Die Zusage gilt für Skripte, die unter `set -e` am Fehlen
  abbrechen. Im Bestand: 622 von 622 greifen (`make mutate-greift`). Gelesen, nicht gefahren.

## Kommandos und Ausgaben

```text
make mutate-greift                                  → 622 Fall/Faelle, 622 greifen, 0 Befund(e); real 18,4 s
git show 98bfab0b^:test/mutations/<fall>.sh | cmp - test/fixtures/mutate-greift/<fall>.sh   → 29, 247 gleich
make mutate MUTATE_CASES=635-greift-modus-uebersieht-ungegriffenen-anker            → 1 ok, 0 Befund(e) (141,8 s)
make mutate MUTATE_CASES=999-reviewer-probe-145-eng (temporär, entfernt)           → 1 ok
Scratch: Dispatch → true                             → Exit 0, keine Ausgabe (unmutiert Exit 1)
Scratch: # files: a.txt a.txt.bak, Patch nur .bak    → als greifend gezählt
```

## Geprüft, ohne Befund

- **Reparatur 145/147:** Erwartung (`# expect:`) unverändert, beide `ok` laut Commit-Beleg; 147 exakt; zu 145 s. L-1.
- **Fixtures:** byte-gleich zu `98bfab0b^`. Dass kein Sensor das hält, nennt `mutate.md` §Grenze letzter Punkt.
- **Fall 635:** trifft `greift_case`, das der Modus real fährt. Der zweite greift-Test und
  `gate-nachweis-kante.bats` berühren die Stelle nicht; die Exklusivität des benannten Tests ist
  gelesen, nicht gefahren. Ungedeckt bleibt die Stelle davor (M-1).
- **Sensors-Zeile / `mutate.md` / Kommentare (§3.6, §3.7):** Die Grenze „Anker trifft, nicht Wächter
  rot" steht an allen drei Orten. Kein Kommentar beschreibt eine verworfene Alternative oder einen
  abwesenden Text. Ausnahmen: M-1 (Verdrahtungs-Satz), M-2, I-1.
- **§3.3 / §3.8 / §3.5:** Kein Commit berührt `AGENTS.md` oder `harness/conventions*`. Das Gate wird
  angehoben, ohne Senkung, ein ADR ist darum nicht nötig. Jede Message trägt Rolle und Kennung.
- **MR-089:** Nicht anwendbar. Die Laufzeit-Aussage betrifft `make gates` dieses Repos, keinen Lauf
  im Ziel und keinen E2E-Lauf. Die Lage (warmer Cache, 20 Kerne) ist trotzdem genannt.
- **MR-071:** Der Modus ändert keinen Fall-Anker. MR-071 §Grenze Punkt 2 ist mit dem Modus falsch;
  das trägt die Übergabe.
