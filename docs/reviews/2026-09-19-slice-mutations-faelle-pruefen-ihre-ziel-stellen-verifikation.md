# Verifikations-Report: slice-mutations-faelle-pruefen-ihre-ziel-stellen — 2026-09-19 (DoD-Konformität, Modul 11)

**Verifikations-Art:** Code — geprüft gegen den Slice-Plan (`in-progress/`) §2 DoD, gegen
`AGENTS.md` §3.6/§3.7 und `ADR-0037` Festlegung 4; dynamisch je Zahn im Wegwerf-Klon und über
den realen `make mutate`-Lauf. Geprüft wird **nicht** gegen den Review — der trägt den
Plan-Anker-Befund F-1, den diese Verifikation selbst gegen den Baum entscheidet.

**Gegenstand:** Diff `09f9d89f..f3743466` — genau ein Commit (`f3743466`, 4 Dateien,
+23/−28): `internal/gen/archgate_test.go` (Schlussform des Zahn-Kommentars),
`test/mutations/29-roadmap-nicht-neutralisiert.sh`,
`275-planning-readme-carveouts-done-ref-nicht-neutralisiert.sh`,
`114-span-lock-verzeichnis.sh`.

**Lauf-Basis:** Kopf `81a373e5` (gepusht), Baum leer. `make gates` grün und `docs-check`
1760/0 sind vom Kopf-Beleg übernommen und hier nicht wiederholt. Dieser Report friert den
Stand dieses Laufs ein und wird über Läufe hinweg nicht wieder gelesen.

## Dynamische Belege (dieser Lauf)

**Die drei Zähne je real gefahren.** Drei Wegwerf-Klone von `81a373e5`, je Fall-Skript angewandt
(Zieldatei laut `git status` geändert: `internal/emit/templates.go` beziehungsweise
`internal/span/emit.go`), `make test-go` je Klon → Exit 2, rot gelesen:

| Fall | `# expect:`-Wächter | Meldung (gelesen, nicht nur Exit) |
|---|---|---|
| 29 | `TestTemplates_RoadmapGateSafe` | `templates_test.go:804: emittierte Roadmap traegt noch einen broken ../done/-Link` |
| 275 | `TestTemplates_PlanningReadmeCarveoutsDoneRefGateSafe` | `templates_test.go:880: emittierte docs/plan/planning/README.md traegt keinen d-check:ignore-Marker auf der docs/plan/carveouts/done/-Zeile` |
| 114 | `TestLeftoverLockDirectoryDoesNotBlock` | `span_test.go:547: Emit: open …/.s1.lock: is a directory` |

Je Lauf genau **ein** FAIL-Test — das Rot kommt aus dem benannten Wächter, nicht aus einem
Kaskaden-Bruch. Bei 114 ist die Meldung die behauptete Ursache (das Verzeichnis überlebt den
Chmod, der zweite `OpenFile` scheitert mit EISDIR); bei 29/275 fehlt die Neutralisierung in der
emittierten Ausgabe.

**Der reale `make mutate`-Lauf** (diese Verifikation, 2026-09-20, 365 Fälle auf 4 Workern in
isolierten Kopien — der Host-Baum blieb unangetastet):

```text
mutate: 365 ok, 0 Befund(e)
mutate: ok    29-roadmap-nicht-neutralisiert             -> TestTemplates_RoadmapGateSafe rot
mutate: ok    275-planning-readme-carveouts-done-ref-nicht-neutralisiert -> TestTemplates_PlanningReadmeCarveoutsDoneRefGateSafe rot
mutate: ok    114-span-lock-verzeichnis                  -> TestLeftoverLockDirectoryDoesNotBlock rot
```

`MUTATE-EXIT=0`, 365 OK-Zeilen (`grep -c 'OK ('` über das Log des Laufs → 365), keine
BEFUND-Zeile. Damit ist die Umkehrung der Rote-Probe belegt: die drei Fälle melden keinen
BEFUND (Bedingung 2) mehr und färben ihre benannten Wächter rot. Die Vor-Umschnitt-Gegenprobe
(`MUTATE-EXIT=2`, Bedingung 2) wurde vom Verifikations-Lauf des Vorgänger-Slices gemessen
(Beleg `docs/plan/planning/observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/evidence/slice-stumme-mutations-faelle-folgen-der-config-form.md`) und ist hier
übernommen, nicht wiederholt.

## DoD-Punkt für DoD-Punkt

| Punkt | Verdikt | Beleg |
|---|---|---|
| **Liefer-Punkt 1** — die drei Zähne treffen wieder | **erfüllt** | Neumuster je genau 1: `grep -cF 'return NeutralizeRoadmap(body), nil' internal/emit/templates.go` → 1 (`:414`); `grep -cF 'return NeutralizePlanningReadmeCarveoutsDoneRef(body), nil' internal/emit/templates.go` → 1 (`:428`); `grep -cF 'if rmErr := removeStaleDir(path); rmErr != nil {' internal/span/emit.go` → 1 (`:346`). Alt-Formen je 0: `grep -cF 'body = NeutralizeRoadmap(body)' …` → 0; `grep -cF 'body = NeutralizePlanningReadmeCarveoutsDoneRef(body)' …` → 0; `grep -cF 'syscall.Rmdir' internal/span/emit.go` → 0. Mutation greift je Zahn, `make test-go` rot am benannten Wächter (Tabelle oben), `make mutate` meldet keinen BEFUND auf den drei Fällen — realer Lauf, 365 ok, 0 Befund(e) |
| **Liefer-Punkt 2** — die Kommentar-Schlussform trägt ihre Herkunft auflösbar oder gar nicht | **erfüllt** | `internal/gen/archgate_test.go:233-235` trägt den Sensor im Indikativ („die rot faerbende Aenderung ist der Pin-Wert selbst und faerbt diesen Test") statt Beleg-Existenz ohne auflösbaren Ort; kein Fall für den Pin: `grep -rln DefaultArchImage test/mutations/` → 0 — die Grenze (kein kuratierter Fall) ist mitgenannt, und der Test selbst liest den Pin-Wert, also färbt die benannte Änderung ihn |
| `make gates` grün | **belegt** | Kopf-Beleg `81a373e5` übernommen (nicht wiederholt); zusätzlich der Grün-Vorlauf `make test-go` des `make mutate`-Laufs — ohne ihn hätte der Lauf fail-closed vor der ersten Mutation geendet |
| Review, Report unter `docs/reviews/` | **erfüllt** | Runde 1 (`2026-09-19-slice-mutations-faelle-pruefen-ihre-ziel-stellen-runde-1.md`) — HIGH 0 · MEDIUM 1 (F-1, nicht merge-blockierend) · INFO 1 |
| Closure-Notiz mit Lerneintrag | **fällig — nicht prüfbar** | §7-Platzhalter stehen; die Closure ist Planner-Arbeit (§3.10), nicht des ausführenden Laufs |
| Reconciliation-Register | **entfällt** | der Plan entbindet — dieses Repo führt die Register-Datei nicht |
| Beobachtungs-Register fortgeschritten | **fällig — nicht prüfbar** | die Register-Lage selbst ist der Verkörperungs-Befund unten; der Zähler trägt 5 Beleg-Dateien (`ls docs/plan/planning/observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/evidence/ \| wc -l` → 5) |
| Risiko-Ausgänge aus §6; drei Paarungen | **fällig — nicht prüfbar** | §6 trägt den Ausgang „weiter offen → nächtlicher `mutate`-Lauf nach dem Umschnitt"; der reale Lauf dieses Reports liefert jetzt den dynamischen Beleg dafür (365 ok, 0 Befund(e)) — die Ausgangs-Zuweisung bleibt bei der Planner-Closure |

## Die Verkörperungs-Frage (F-1) — der Kernbefund der Verifikation

Der Register-Eintrag `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`
(`state.md`) trägt Ausgang *geplant*, Zählerstand 5×, und weist diesem Slice das Schreiben der
Regel zu — „die Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand, nicht gegen die
Fassung der letzten Fassung". Der Plan §8 verankert die Verkörperung an „Liefer-Punkt 2 und 3
dieses Plans".

**Verdikt: die Verkörperung trägt nicht — der Register-Ausgang löst ins Leere.** In drei Schritten:

1. **Die drei gezogenen Zähne heilen die drei Instanzen**, nicht die Regel. Ihre Zusage ist
   Liefer-Punkt 1; die Regel spricht von der *Fall-Anlage* und wäre als Regel an einem Zielort
   zu verkörpern (`AGENTS.md`-Anker, Sensor-Doku, Skill, `MR` oder Make-Target) — davon legt
   der Diff nichts fest.
2. **Kein Zielort trägt die Regel.** `grep -rn 'Fall-Anlage' --include='*.md' --include='*.sh' --include='*.go' .` (ohne `.harness/baseline`, `docs/reviews`, Register) trifft genau zwei
   Stellen: den Lerneintrag des Vorgänger-Slices in `done/` (Beleg, nicht Regel) und diesen
   Plan. `grep -rln 'sed-Muster' harness/ test/mutations/ .claude/` → leer. Kein
   Herkunfts-Anker existiert.
3. **Der geplante Anker ist falsch.** §2 führt nur Liefer-Punkt 1 und 2; keiner trägt die
   Regel — Liefer-Punkt 2 ist die Kommentar-Schlussform des `archgate`-Zahns, ein anderer
   Gegenstand —, und einen Liefer-Punkt 3 gibt es nicht. §3 (Plan vor Code) hat keine Zeile
   dafür.

Damit ist die Runde-1-Lage bestätigt und über die Register-Seite geschlossen: der Ausgang
*geplant* ist ein Ausgang mit Kennung (Modul 6), und die Adresse muss die Sendung annehmen —
dieser Slice schreibt die Regel nicht, solange kein Punkt des Plans sie an einen Zielort
schreibt. Die maschinelle Register-Paarung (c) fängt das nicht (sie prüft Verzeichnis und
Beleg, nicht den Ausgang); die Klasse ist Verifier-only.

**Übergabe an den Planner (§3.10):** die Planner-Closure entscheidet über die Auflösung —
Verkörperung als Architect-Zug der Closure (Planner → Architect → Planner), eigener Plan-Punkt,
oder der Ausgang dreht auf einen Ausgang mit Kennung eines Folge-Slice. Diese Verifikation
legt die Lage, nicht die Wahl fest.

## Plan-vs-Code-Diff (beide Richtungen)

- **Code ohne Plan:** keine — der Commit berührt genau die vier Dateien der §3-Tabelle
  (`git show --pretty=format: --stat f3743466` → 4 Dateien, +23/−28). Die Chmod-Wahl des
  Falls 114 liegt in der Plan-Zeile („der Fall folgt der Span-Sperre mit je-OS-Dateien (kein
  `Rmdir` mehr)").
- **Plan ohne Code:** die Verkörperung der 5×-Regel (§8-Anker) — geplant behauptet, nirgends
  gebaut (Abschnitt oben). Das ist der eine Plan-vs-Code-Befund.

## Spec-Lücken

Keine. Der Plan führt „Berührte Spec-Stellen: —", und der Diff berührt keine; die Lücke der
Verkörperung ist eine Plan-/Register-Verankerung, keine Spec-Lücke.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Kaskaden-Rot je Zahn | geprüft, ohne Befund — je `make test-go`-Lauf genau ein benannter FAIL-Test (Fall 114: das docker-Echo verdoppelt die Zeile, derselbe Test) |
| Kopplung des 114-Kommentars („removeStaleDir nimmt nur ein Verzeichnis") | geprüft, ohne Befund — `grep -rn 'removeStaleDir' internal/span/` (ohne `_test`) nennt nur `internal/span/lock_unix.go:24` und `internal/span/lock_windows.go:50`; eine Lock-DATEI wird nicht angetastet; die Kompilat-Klausel trägt (Grün-Vorlauf grün, Fall-Läufe kompilieren) |
| Chronik-Formen in den drei Fall-Kommentaren (`AGENTS.md` §3.7) | geprüft, ohne Befund — `grep -nE 'slice-[0-9]\|Review\|Befund\|ANKER'` über die drei Skripte → keine Treffer; Zustands-/Kopplungsform im Indikativ |
| Fremd-Kennungen in zugefügten Zeilen | geprüft, ohne Befund — `git show f3743466 \| grep '^+' \| grep -oE '\b(ADR\|MR\|CO\|LH\|BEO\|welle\|slice)-[A-Za-z]*-?[0-9]+\b' \| sort \| uniq -c` → ein Treffer, `ADR-0037` (eigen, `Accepted`; trägt die Tag-0-Formen samt dem `d-check:ignore`-Marker, den der Fall 275 fordert) |
| F-2-Rest-Form und der Pin-Fall | geprüft, ohne Befund — Sensor im Indikativ, kein Fall für den Pin (`grep -rln DefaultArchImage test/mutations/` → 0) |
| Fallzahl-Vollständigkeit | geprüft, ohne Befund — `ls test/mutations/*.sh \| wc -l` → 365; Bilanz des realen Laufs 365 ok, 0 Befund(e) |
| Fundort-Trägerschaft der Klasse | geprüft, ohne Befund — die zwei Fundmengen (68/71/96 und 29/275/114) stehen im Beleg des Vorgangs als benannte Fundorte, eine Zählung |

## Übergabe an den Planner

1. **F-1-Verkörperung (ausdrücklich):** die Verkörperung der 5×-Regel trägt nicht; der
   Register-Ausgang (*geplant*, 5×, Kennung dieses Slice) löst ins Leere. Die Planner-Closure
   entscheidet über die Auflösung.
2. **F-2** (Runde 1, INFO): die Commit-Message nennt zum Fall 114 den Ort nicht — offen beim
   Planner.
3. **§6-Risiko:** der reale Lauf dieser Verifikation liefert den dynamischen Beleg (365 ok,
   0 Befund(e), die drei Fälle OK am benannten Wächter) — die Ausgangs-Zuweisung bleibt bei der
   Planner-Closure.