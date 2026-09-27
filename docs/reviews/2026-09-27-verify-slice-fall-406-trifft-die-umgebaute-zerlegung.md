# Verifikationsbericht: slice-fall-406-trifft-die-umgebaute-zerlegung — 2026-09-27

**Rolle:** Verifier (Modul 8/11) — Frage: *Bauen wir es richtig?* gegen Plan, DoD und ADR/Spec.
Nicht die Frage des Reviewers (Diff gegen Plan, ADR, Hard Rules) und nicht die des Validators.
Frischer Kontext, kein Self-Review (Modul 8).

**Gegenstand:** Slice `slice-fall-406-trifft-die-umgebaute-zerlegung` (aktuell `in-progress/`).
Commits `2dcf3ce4` (Claim-Move), `19954194` (Ruhe-Marker-Entfernung), `1a92156a`
(Fall-406-Reparatur). Reviewer-Report Commit `f3f3c828` (0 HIGH, 1 MEDIUM F-1, 1 INFO F-2). Der
Slice ist **nicht** geschlossen; dieser Bericht setzt kein DoD-Häkchen und ändert weder Slice noch
Code noch Register (`AGENTS.md` §3.10).

**Bezug:** `LH-FA-10` · `ADR-0011` (aktiv — Werte nie im Span) ·
`MR-071` (Fall-Anlage misst gegen den Quell-Bestand) · `AGENTS.md` §3.6, §3.7.

**Methode:** Alle Läufe hermetisch über Docker (`make test-go`, `make mutate`, Dockerfile-Stages),
alle Mutationen in einer isolierten `git archive HEAD`-Kopie mit eigenem `git init` im
Scratchpad — nie im Arbeitsbaum. Kein Host-Go. Am Ende `make docs-check`/`make gates` direkt im
Arbeitsbaum (unverändert, da der Slice nichts an Produktionscode/Tests ändert).

---

## Gesamturteil

**DoD (1) ist bestätigt — nicht aus dem Implementer-/Reviewer-Bericht übernommen, sondern
eigenständig rot vor grün gesehen, plus eine eigene Gegenprobe.** Der einzige Liefer-Punkt (Fall
406 reparieren) trägt die Zusage, dass die Mutation `TestCommandProgramNeverEmitsAssignmentValueFragments`
rot färbt und ohne Mutation grün bleibt — beides selbst gefahren, beides bestätigt.

**Beide Review-Findings (F-1 MEDIUM, F-2 INFO) sind bestätigt**, F-1 durch eine eigene, unabhängige
Gegenprobe mit ausgeschriebener Polarität, F-2 durch eigenes Nachzählen des Registers. Kein
zusätzlicher HIGH/MEDIUM-Befund. Ein zusätzlicher LOW-Befund (V-1, siehe unten): die
§8-Sichtungs-Aussage des Slice-Plans ist beim Lesen der zitierten Quelle nachweisbar falsch, nicht
nur unvollständig — der 2026-09-24-Report belegt den behaupteten „keinen Treffer" bereits als
Treffer, wörtlich und namentlich für Fall 406.

Der Slice ist in seinem einen Liefer-Punkt DoD-konform; die verbleibenden Closure-Pflichten
(Closure-Notiz, Register-Fortschreibung, Risiko-Ausgänge, drei Paarungen) sind — korrekt —
noch offen und Sache des Planners in frischem Kontext (§3.10). Für diesen Schritt trägt der
vorliegende Bericht die Eingaben.

---

## Gelaufene Sensoren (Kommando und Ausgang)

| Sensor | Ergebnis |
|---|---|
| `grep -nc "if c != ' ' && c != '\t' && c != '\n' {" internal/span/span.go` (Scratch-Kopie, unabhängig vom Reviewer neu gemessen) | **1** — Zeile 468 in `splitWords`, MR-071-Anker eindeutig |
| `sed`-Anwendung des Falls, `git diff` danach | genau eine Zeile geändert: `… { ` → `… && c < 0x80 {`, kein Escaping-Defekt, keine Doppelung |
| `make test-go` mit angewandter Mutation | Exit 2, `FAIL …/internal/span`; vier Subtests von `TestCommandProgramNeverEmitsAssignmentValueFragments` (Basis, `#01`–`#03` = NBSP/U+2003/U+3000/U+0085) mit `"program":"SECRET"` in der geschriebenen Zeile |
| `git checkout -- internal/span/span.go`, dann `make test-go` | Exit 0, alle acht Pakete `ok` inkl. `internal/span` |
| Gegenprobe (Punkt 3 unten): `t.Skip(...)` **nur** in `TestCommandProgramNeverEmitsAssignmentValueFragments`, Mutation weiterhin angewandt, `make test-go` | Exit 2 — weiterhin rot, aber über `TestCommandProgramNamesAProgramNotAnOperator/A=b_SECRET_cmd_x` |
| `make mutate MUTATE_JOBS=1 MUTATE_CASES='406-span-program-wortgrenze-unicode-leerraum'` (Scratch-Kopie, zurückgesetzt vor dem Lauf) | Exit 0, `mutate: 1 ok, 0 Befund(e)`, `… -> TestCommandProgramNeverEmitsAssignmentValueFragments rot`, `TEILLAUF 1 von 478 — kein Beleg (Beleg-Slot bleibt unberuehrt)` |
| `.harness/state/` in der Scratch-Kopie vor/nach dem Teillauf | kein `mutate-passed.key`, `git status --porcelain` beide Male leer |
| `git diff --stat 2dcf3ce4~1..1a92156a -- internal/span/span.go internal/span/span_test.go` (realer Repo-Bestand) | leer — keine Produktionscode-/Testdatei-Änderung |
| `git diff --stat 2dcf3ce4~1..1a92156a` (voller Umfang) | drei Dateien: Roadmap (Ruhe-Marker −3 Zeilen), Slice-Datei (reiner Move, 0 Zeilen), Fall 406 (+9/−6) |
| `grep -n "406"` in `docs/reviews/2026-09-24-…-gegenprobe.md` | Zeile 53: Tabellenzeile Fall 406, Spalte „Urteil" = **bindet**; Zeile 99–101: INFO-1 nennt 404/405/**406**/407 namentlich als Fälle, die zwei Testfunktionen binden |
| `ls docs/plan/planning/observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/evidence/*.md \| wc -l` | **2** (`slice-204-das-programm-feld-nennt-das-programm.md`, `slice-program-feld-nennt-weder-operator-noch-wertfragment.md`) — Register-`state.md` bestätigt „offen … 2×" |
| Inhalt der zweiten Evidence-Datei | nennt „Fälle 404 bis 407" (schließt 406 namentlich ein) und zitiert exakt den 2026-09-24-Gegenprobe-Report |
| `make docs-check` (Arbeitsbaum, unverändert) | Exit 0, `2049 Datei(en) geprüft, 0 Befund(e)` |
| `make gates` (Arbeitsbaum, unverändert) | Exit 0 |
| Stempel `.harness/state/gates-passed.diffsha` gegen `bash harness/tools/working-tree-hash.sh` | deckungsgleich, `51d57cb3…9994ed4`, vor diesem Commit |

---

## DoD, Punkt für Punkt

| DoD-Punkt | Urteil | Beleg |
|---|---|---|
| **(1)** Fall 406 färbt `TestCommandProgramNeverEmitsAssignmentValueFragments` unter Mutation rot, ohne Mutation grün, MR-071-Anker `grep -c` = 1 | **bestätigt** | Eigenständiger Rot-vor-Grün-Lauf (Tabelle oben); Anker unabhängig gemessen, nicht aus dem Bericht übernommen |
| `make gates` grün | **bestätigt** (am unveränderten Arbeitsbaum) | Exit 0, Stempel deckungsgleich |
| Review durchgeführt, Report unter `docs/reviews/` | **bestätigt** | Commit `f3f3c828`, committet |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **offen — Planner/Closure** (§3.10) | Slice-§7 ist per Vorlage leer, korrekt bis zur Closure |
| Beobachtungs-Register fortgeschrieben | **offen — Planner/Closure** | Zähler heute 2× (Klasse `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`); Konsequenz s. Übergaben unten |
| Risiko-Ausgänge (§6) | **offen — Planner/Closure** | drei Risiken benannt, s. Übergaben unten |
| Drei Paarungen (Anker · Folge-Slice · Register) | **offen — Planner/Closure**; im Repo ohne Wellen-Betrieb bei der Slice-Closure zu prüfen | keine der drei ist vor der Closure prüfbar (Register-Beleg existiert erst nach dem `git mv`) |

Der einzige Liefer-Punkt ist damit real erfüllt und **von mir**, nicht nur vom Implementer,
rot-vor-grün gesehen (Bewusstes Brechen, Modul 11) — die Zusage berührt `ADR-0011`
(Werte-nie-im-Span, sicherheitskritisch), der Rot-Beleg war daher ohnehin verifierpflichtig.

---

## Review-Findings: eigenes Verdikt

| ID | Reviewer-Befund | Mein Verdikt | Beleg |
|---|---|---|---|
| F-1 (MEDIUM) | Mutation färbt zwei Tests, nicht nur den `# expect:`-genannten; §8-Sichtung des Plans trifft nicht zu | **bestätigt, in beiden Teilen** | Eigene Gegenprobe: `t.Skip` nur im benannten Test, Mutation aktiv → `make test-go` bleibt rot über `TestCommandProgramNamesAProgramNotAnOperator`. Zusätzlich eigenständig gelesen: der 2026-09-24-Gegenprobe-Report dokumentiert Fall 406 (damalige Anker-Form) bereits wörtlich als „bindet" zwei Tests, und die Register-Evidence-Datei für exakt diese Klasse nennt Fall 406 namentlich unter „Fälle 404 bis 407" |
| F-2 (INFO) | Ein weiterer Beleg bei der Closure wäre der 3. Vorgang der Klasse, verlangt einen Ausgang | **bestätigt** | `ls evidence/*.md \| wc -l` → 2, unabhängig gezählt; Modul 6 §Das Beobachtungs-Register: „Bei 3× wandert der Eintrag … und wird zur verkörperten Regel" — Ausgangs-Pflicht korrekt hergeleitet |

**Zusätzlicher eigener Befund V-1 (LOW, nicht merge-blockierend, kein DoD-Verstoß):** Die
§8-Sichtungs-Zeile des Slice-Plans lautet „Kein weiterer Treffer mit Bezug zu Unicode-Wortgrenzen
oder zu `internal/span/` spezifisch." Das ist beim Lesen der zitierten Quelle nachweisbar
unzutreffend, nicht nur eine Ermessensfrage: Der Sichtungs-Schritt hatte laut §8 bereits den
Treffer `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` korrekt notiert, aber den
zweiten, ebenso einschlägigen Treffer (`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`,
zwei Belege, beide aus Arbeit an `internal/span/`, einer davon namentlich zu Fall 406) übersehen.
Modul 6 verlangt für den Sichtungs-Schritt: „Keine Treffer sind ebenfalls eine Antwort und werden
notiert" — hier lag ein Treffer vor und wurde als „kein Treffer" notiert. Das berührt keinen
DoD-Punkt (die Sichtung ist kein Liefer-Punkt), gehört aber als Genauigkeits-Lücke in die
Closure-Notiz, nicht nur als Konsequenz von F-1.

---

## Was nur gelesen ist (nicht eigenständig nachgefahren)

- Der volle Wortlaut und die Tabellen des 2026-09-24-Gegenprobe-Reports über die **Fälle 404, 405,
  407, 408** (nur Zeile zu 406 und der INFO-1-Absatz wurden gezielt geprüft, nicht die übrigen
  Zeilen der Tabelle).
- Der Inhalt der ersten Evidence-Datei (`slice-204-das-programm-feld-nennt-das-programm.md`) —
  nur ihre Existenz und ihr Dateiname wurden geprüft, nicht ihr Text.
- Die `observation.md` der beiden betroffenen Register-Klassen (Sub-Area-Feld, Erstauftreten) —
  nicht gelesen, nur `state.md` und `evidence/`.
- Dateimodus- und Header-Form-Vergleiche gegen Nachbarn 404/405/407/476/490 — vom Reviewer
  gefahren (Punkt 6 seines Reports), von mir nicht wiederholt; kein DoD-Punkt hängt daran.

---

## Übergaben an den Planner (§3.10 — Closure in frischem Kontext)

1. **Register-Beleg setzen.** Klasse `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`
   bekommt mit diesem Slice ihren **dritten** Beleg (Zähler heute 2×, unabhängig gezählt) —
   3×-Übertritt. Modul 6 verlangt beim Lese-Schritt (hier: die Slice-Closure selbst, da wellenlos,
   Anker `seit slice-<Kennung>`) einen Ausgang aus der geschlossenen Menge
   *verkörpert/geplant/gestrichen*, nicht mehr „offen".
2. **Zweiter Register-Beleg (parallel dazu, wie im DoD vorgesehen):** Klasse
   `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` bekommt ebenfalls ihren nächsten
   Beleg (Zähler vor diesem Slice 5×, MR-071 bereits verkörpert — dieser Beleg ändert am Ausgang
   nichts, da die Regel schon existiert).
3. **Risiko-Ausgänge (§6 des Slice-Plans), drei Risiken, Vorschlag mit Beleg:**
   - *Vorgeschlagener Anker ungeprüft im Docker-Sinn* → **entfallen**, mit Begründung: der Anker
     wurde real geprüft (dieser Bericht und der Reviewer-Report), traf sofort und ohne
     Nachbesserung.
   - *Entwaffnung ist keine neue Beobachtungs-Klasse* → bestätigt sich, **eingetreten** im Sinne der
     eigenen Prognose: der Beleg geht an die bestehende Klasse `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`
     (Übergabe 2 oben).
   - *Auflösungs-Trigger von MR-071 rückt näher, aber noch nicht erreicht* → weiterhin zutreffend
     für diese Klasse; **weiter offen** bzw. redaktionell durch Übergabe 2 erledigt.
4. **V-1 (LOW) in die Closure-Notiz aufnehmen** — die §8-Sichtungs-Ungenauigkeit ist ein eigener
   Lerneintrag-Kandidat (geschärfte Sichtungs-Disziplin: beide einschlägigen Register-Klassen
   prüfen, nicht nur die zuerst gefundene), unabhängig von F-1/F-2.
5. **Kein neuer Sensor, kein Folge-Slice nötig** — weder aus F-1/F-2 noch aus V-1: Der
   3×-Übertritt aus Übergabe 1 ist die vom Regelwerk vorgesehene Reaktion; MR-071s eigener
   Auflösungs-Trigger (drei weitere Vorgänge seit seiner Verkörperung) ist mit diesem einen Beleg
   noch nicht erreicht.

---

## Nachlauf `make gates`

`make gates` und `make docs-check` liefen am unveränderten Arbeitsbaum (der Slice ändert weder
Produktionscode noch Tests); beide Exit 0, Stempel `.harness/state/gates-passed.diffsha` deckte den
Baum vor diesem Commit (`51d57cb3cf89eeca6725ea6ec01990668e16dff71a2813bac6d7e09139994ed4`). Der
Nachlauf nach dem Ablegen dieses Berichts steht in der Commit-Message.
