# ADR-0020 (Proposed) — Bestätigungsrunde vor der Annahme

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-16. **Lauf:** frischer Kontext, Subagent
`reviewer`, erster Durchgang zu dieser ADR.

**Gegenstand:** `3e1939e` (`docs/plan/adr/0020-emittierte-modul-15-regeln.md`, Proposed, sechs
Festlegungen, plus die Index-Zeile `docs/plan/adr/README.md:28`) gegen den Plan, dessen einzigen
DoD-Punkt sie erfüllt: `430f358` und `6b27edf`
(`docs/plan/planning/open/slice-062-emittierte-modul-15-regeln.md`,
`docs/plan/planning/welle-09-modul-15-konformitaet.md` §3/§4,
`docs/plan/planning/in-progress/roadmap.md`). Geprüft wird die ADR vor dem
Statuswechsel, den `AGENTS.md` §3.4 unumkehrbar macht.

**Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan, Modul 10 §Eingangs-Kontext):**
Commit-Range oben · betroffene Anforderungen `LH-FA-01`, `LH-FA-03`, `LH-FA-06`, `LH-FA-07`,
`LH-QA-01`, `LH-QA-02`, `LH-QA-03` · referenzierte **aktive** ADRs `0007`, `0011`, `0012`,
`0013`, `0016` (alle Accepted, selbst geprüft) und die **Proposed** `0019` · Hard Rules
`AGENTS.md` §3.1–§3.8 · **vorherige Findings am gleichen Modul:**
`docs/reviews/2026-08-15-adr-0019-bestaetigungsrunde.md` und
`docs/reviews/2026-08-15-adr-0019-bestaetigungsrunde-runde-2.md` (dort HIGH-1: eine Ableitung im
Indikativ als Prämisse, dieselbe Klasse zwei Runden hintereinander), dazu
`docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde{,-runde-2,-runde-3}.md` · Plan-Bezug:
`slice-062`, `welle-09`, `CO-002`.

**Nicht meine Rolle, und darum nicht getan:** die DoD-Abhakung und die Gate-Lauf-Bestätigung
(Modul 10 §Anti-Pattern). Ich habe **nichts geändert und nichts committet**;
`git status --porcelain` war vor und nach dem Lauf leer. Die Sonde unten lief in einer
Wegwerf-Kopie **außerhalb** des Repos.

**Selbst gefahren — Kommando und Ergebnis, nichts davon übernommen:**

| Kommando | Ergebnis |
|---|---|
| `make doc-targets` | `d-check: 320 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — der Träger ist im **Dogfood** heute stumm, wie die ADR sagt |
| `make docs-check` | `d-check: 320 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — die neue ADR und die Index-Zeile tragen keine toten Links/Anker/IDs |
| `docker run --rm --network none <d-check@digest> --print-config` | der `targets:`-Block der Startkonfiguration ist Zeichen für Zeichen der in der ADR zitierte (`makefiles`/`doc-tables`/`authority`/`exempt-targets`) |
| `grep -rn "claude/agents" --include=*.go .` | Exit 1, **null** Treffer |
| `grep -rn "claude/agents" internal/emit/templates .harness/baseline/v3.5.2/templates` | Exit 1, **null** Treffer |
| `grep -n "targets" .d-check.yml internal/emit/templates/d-check.yml` | Exit 1 — **keine** der beiden Konfigurationen führt einen `targets:`-Block |
| `grep -noE 'make [a-z][a-z0-9-]*' <die zwei emittierten Doku-Vorlagen>` (Backtick-Präfix im Muster weggelassen) | 19 Nennungen, **9 verschiedene** Ziele: `arch-check`, `ci`, `coverage-gate`, `coverage-gate-critical`, `fullbuild`, `gates`, `help`, `lint`, `test` |
| **Sonde A** — Nachbau der `--lang go`-Emission außerhalb des Repos, `.d-check.yml` mit **genau** dem Datei-Satz aus Festlegung 4(a) | `2 Datei(en) geprüft, 4 Befund(e)`, Exit 1 — `AGENTS.md:5 lint gate-phantom`, `AGENTS.md:6 test gate-phantom`, `harness/README.md:2 lint gate-phantom`, `harness/README.md:3 test gate-phantom` |
| **Sonde B** — dieselbe Kopie, `harness/mk/go.mk` in `makefiles:` **ergänzt** | `2 Datei(en) geprüft, 0 Befund(e)`, Exit 0 (Kausalität belegt) |
| **Sonde C** — dieselbe Kopie plus `a-check.mk` (Target `a-check`) und `harness/mk/arch-app.mk`, **beide ungenannt** | `2 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| **Sonde D** — dieselbe Kopie **ohne** `harness/mk/go.mk` (sprachloser Init), Doku unverändert | `2 Datei(en) geprüft, 4 Befund(e)`, Exit 1 — **byte-gleiche Ausgabe wie Sonde A**, diesmal aber vier **wahre** Befunde |

**Gelesen, nicht gefahren** (Fundort statt Messung): `internal/span/span.go:5-11` ·
`internal/span/span.go:76-126` · `internal/span/response.go:65-77` ·
`harness/tools/extract-agent-call.awk:1-31,82-120` · `.claude/settings.json` ·
`docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:149-157` ·
`internal/emit/emit.go:96-114` · `internal/emit/makefile.go:14-44` ·
`internal/emit/baseline.go:28-44` · `internal/emit/enforce.go:42-58` ·
`internal/emit/enforce_test.go:20-57` · `internal/emit/archgate.go:55-84` ·
`internal/gen/golang.go:907-928` · `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`
§Werkzeug-Wahl · `…/modul-11-verification.md` §Fitness Function ohne Standard-Tool ·
`…/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin) · `…/modul-15-observability.md`
§Doku-Konsistenz-Drift-Regeln · `docs/plan/adr/0011-…:176-197` ·
`docs/plan/adr/0016-…:246-297` · `docs/plan/carveouts/CO-002-…:66-90` · `spec/lastenheft.md`
§LH-FA-03/07, §LH-QA-01/03 · `harness/conventions.md` §MR-001, §MR-017.

---

## Findings

### HIGH-1 — Der tragende Beleg für T1 nennt eine andere Hook-Payload, und die Gegenmessung liegt in genau der Datei, um die es geht

- **kategorie:** HIGH
- **quelle:** `AGENTS.md` §3.6 (*„Richtig: benennen, was wirklich deckt — oder dass nichts
  deckt"*); `LH-QA-02`; Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei
  Diskrepanz (Frage 2)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:167-175` und
  `docs/plan/adr/README.md:28` gegen `internal/span/span.go:5-11`,
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:149-157`,
  `harness/tools/extract-agent-call.awk:1-31` und `.claude/settings.json`
- **befund:** T1 begründet, warum die Zelle **nicht emittiert** trägt statt *ADR-Verdikt*, mit
  dem Satz *„dieses Repo liest dieselbe Hook-Payload bereits in POSIX-awk
  (`harness/tools/extract-agent-call.awk`) … die kompilierte Form ist eine Wahl, keine
  Notwendigkeit"*; die Index-Zeile verdichtet das zu *„dafür gibt es im Repo Präzedenz"*. Zwei
  Beobachtungen stehen dagegen. **Erstens ist es nicht dieselbe Payload:**
  `.claude/settings.json` hängt `extract-agent-call.awk` an **`PreToolUse`** (Matcher `Agent`)
  und den Emitter an **`PostToolUse`/`PostToolUseFailure`/`SubagentStart`** (leerer Matcher).
  Der awk-Extraktor nimmt **zwei skalare Werte an einem festen Schlüsselpfad der Tiefe 2**
  (`tool_input.subagent_type`, `tool_input.run_in_background`,
  `harness/tools/extract-agent-call.awk:34-38,82-89`); der Emitter liest sieben Top-Level-Keys,
  `tool_input`, `duration_ms`, die **Rohlänge** von `tool_response`, neun Blattwerte hinter
  einem **zweistufigen** Abstieg (`internal/span/response.go:65-77`) und ein `error`, das je
  nach Werkzeug String, Objekt, Array, Zahl oder `null` ist (`internal/span/span.go:140-163`).
  **Zweitens hat dieses Repo genau diesen Vergleich schon einmal gefahren und anders
  entschieden — auf einer Messung:**
  `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:149-157` (*„**Go**, nicht awk.
  Begründung, und sie ist gemessen, nicht ästhetisch … `error` nur als String erkannt, bei
  `{"message":…}` meldet der Span `ok` für einen fehlgeschlagenen Aufruf … 21 externe Aufrufe
  je Span (gemessen)"*), derselbe Satz steht als Kopfkommentar in `internal/span/span.go:5-11`.
  Die ADR zitiert diese Messung weder, noch entkräftet sie sie.
- **gegenbeispiel:** Jemand nimmt T1 beim Wort und baut die Erfassung in POSIX-awk nach. Sie
  reproduziert das Ergebnis von slice-059 — ein fehlgeschlagener Aufruf wird `ok` gemeldet oder
  der `usage`-Abstieg geht verloren — und der fail-open Emitter verliert still seine eigene
  Aussage, ohne dass `make span-check` das sieht (es prüft, dass **ein** Span entsteht). Dann
  war T1 keine ernst erreichbare Schwelle, Modul 7 Frage 2 antwortet **Nein**, und die Zelle
  schuldete *ADR-Verdikt* — einen Wert, den die dann Accepted-ADR nach `AGENTS.md` §3.4 nicht
  mehr korrigieren kann.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '5,11p' internal/span/span.go` gegen
  `sed -n '149,157p' docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md`; die
  Ereignis-Achse an `.claude/settings.json`. **Maschinell nicht bewacht:** `.d-check.yml` führt
  `links, anchors, ids, matrix, codepaths, spans`; kein Modul liest, ob eine Analogie trägt.

### HIGH-2 — Der Datei-Satz aus Festlegung 4(a) lässt den emittierten Träger zwei unserer eigenen echten Targets als Phantome melden — gemessen, und die Ausgabe ist von der wahren Meldung nicht zu unterscheiden

- **kategorie:** HIGH
- **quelle:** `LH-QA-01` (zweite Hälfte: kein Befund über einem existierenden Target);
  `AGENTS.md` §3.6; `MR-017` (*„nach dem Fehlerbild, nicht nach vermuteter Präferenz"*)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:210-224` (4(a)/4(b)),
  `:250-253` (4(e)), `:276-282` (5(d)), `:335-338` (§Konsequenzen) gegen
  `internal/gen/golang.go:907-928` und
  `.harness/baseline/v3.5.2/templates/AGENTS.template.md:149-150` /
  `.harness/baseline/v3.5.2/templates/harness/README.template.md:87-88`
- **befund:** Der Satz nennt `Makefile`, `d-check.mk`, `harness/mk/baseline.mk`,
  `harness/mk/doc-gate.mk`, `harness/mk/enforce.mk` und schließt das Code-Gate-Fragment
  ausdrücklich aus. `harness/mk/go.mk` definiert aber `test`, `lint`, `build`
  (`internal/gen/golang.go:917-927`), und die **zwei emittierten Doku-Vorlagen behaupten
  `make lint` und `make test` auf fünf Zeilen** (selbst gezählt). Sonde A, mit exakt dem
  Datei-Satz der ADR über einem Nachbau der `--lang go`-Emission: **4 Befunde `gate-phantom`,
  Exit 1**, alle vier über **existierende** Targets. Sonde B (nur `harness/mk/go.mk` ergänzt):
  **0 Befunde, Exit 0** — die Ursache ist der Datei-Satz, nichts anderes. Sonde D (sprachloser
  Init, dieselben Doku-Zeilen, `lint`/`test` wirklich abwesend): **byte-gleiche Ausgabe wie
  Sonde A**. Die ADR nennt die Lücke in 5(d) und §Konsequenzen, ordnet sie aber als *weiche
  Bedingung* und **Adopter-Pflicht** ein — während beide Ursachen von uns stammen: das Fragment
  schreibt unsere Sprach-Phase, die Doku-Zeile kommt aus unserer Emission, und die
  Konfiguration schreiben ebenfalls wir. Der Adopter hat an dem Fehler keinen Anteil und kann
  am Befund nicht ablesen, dass er einer ist.
- **gegenbeispiel:** Folgepflicht 2 ist erfüllt (die fünf wirklich abwesenden Behauptungen sind
  emit-seitig neutralisiert), `slice-063` emittiert den Block, ein Adopter bootstrappt mit
  `--lang go` und ruft `make doc-targets`. Er liest vier Zeilen, die seine `AGENTS.md` und seine
  `harness/README.md` benennen, **null** davon trifft zu, und der Träger fährt mit Exit 1 — der
  exakte Ausgang, dessen Verhinderung 4(e) als *„Teil der Entscheidung"* führt. Bricht die
  Zusage aus 4(b), *die fünf seien der Satz, der die Bedingung in **jeder** Variante erfüllt*:
  sie erfüllt die **harte** Bedingung, und dass die weiche in der meistgefahrenen Variante
  (`make full-smoke` fährt `--lang go`) zu 100 % falsch ausgeht, steht nirgends beziffert.
- **verifizierbar:** ja, ohne diesen Arbeitsbaum — Sonden A/B/D sind aus
  `internal/emit/makefile.go`, `internal/emit/baseline.go`, `internal/emit/emit.go`,
  `internal/emit/enforce.go` und `internal/gen/golang.go` in wenigen Zeilen nachzubauen und
  gegen das gepinnte Image zu fahren.

### MEDIUM-1 — Die Reihenfolge-Bedingung aus 4(e) ist variantenblind formuliert, obwohl 4(a) gerade auf der Varianz beruht

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6; `LH-QA-02`
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:250-253` und `:349-351`
  (Folgepflicht 2)
- **befund:** 4(e) sagt, der Block gehe erst mit, *„solange die emittierten Dokumente selbst
  Targets behaupten, die **ein frisches Ziel** nicht hat"*. „Ein frisches Ziel" ist keine Größe:
  ohne `--lang` fehlen **sieben** der neun behaupteten Ziele, mit `--lang go` **fünf**
  (`arch-check`, `ci`, `coverage-gate`, `coverage-gate-critical`, `fullbuild`) — selbst
  ausgezählt. Die Bedingung ist damit je nach Variante zu verschiedenen Zeitpunkten erfüllt,
  und in der Variante, in der sie zuerst erfüllt ist, ist der Träger nach HIGH-2 gerade falsch.
  Folgepflicht 2 wiederholt dieselbe Formulierung und nennt sie ausdrücklich *„eine
  Eigenschaft, keine Adresse"* — die Eigenschaft ist aber nicht variantenfrei.
- **gegenbeispiel:** `slice-063` prüft die Bedingung an einem `--lang go`-Ziel, findet sie
  erfüllt und emittiert. Ein zweiter Adopter bootstrappt sprachlos; bei ihm behaupten dieselben
  Dokumente zwei weitere abwesende Targets, und die Bedingung, unter der emittiert wurde, gilt
  für sein Ziel nie.
- **verifizierbar:** ja — `grep -noE 'make [a-z][a-z0-9-]*'` über die zwei Vorlagen gegen die
  Target-Namen aus `internal/emit/makefile.go:14-37`, `internal/emit/baseline.go:31-39`,
  `internal/emit/enforce.go:42-58`, `internal/gen/golang.go:909-928`.

### MEDIUM-2 — Festlegung 3 nennt einen Auflösungs-Trigger, der eintreten, aufgelöst und nach `done/` verschoben werden kann, ohne die Zellen zu bewegen

- **kategorie:** MEDIUM
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form: Carveout (*„Auflösung ist
  ein `git mv` nach `done/`"*); `welle-09` §3 (*„**nicht emittiert** — begründete Entscheidung
  **mit Auflösungs-Trigger**"*)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:195-205` gegen
  `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:66-79`
- **befund:** Die Zellen *Token-Attribution × Tool* und *Cache-Counter × Tool* bekommen als
  Trigger den von `CO-002` — *„verwiesen und nicht wiederholt"* —, und im selben Absatz steht,
  die Schwelle wirke *„**konjunktiv mit T1**"* und das sei *„die Kopplung zu benennen, nicht
  eine Schwelle zu verdoppeln"*. Eine Konjunktion ist aber eine andere Bedingung als ihr erstes
  Glied. `CO-002`s Trigger ist eine Schwelle am **Span-Bestand dieses Repos** (ein `Agent`-Span
  trägt wieder `spawned_role` und alle vier `usage`-Zähler, und die erzeugende Mechanik liegt
  committet im Baum); er sagt nichts über die emittierte Ebene. Tritt er ein, wird der Carveout
  nach Modul 7 per `git mv` nach `done/` aufgelöst — dann zeigen zwei Zellen der Tool-Spalte
  auf einen abgeschlossenen Carveout als ihren offenen Auflösungs-Trigger, während sie
  unverändert *nicht emittiert* tragen, weil T1 nicht gefallen ist.
- **gegenbeispiel:** `slice-086` misst den `updatedInput`-Weg erfolgreich, `CO-002` löst sich
  auf und wandert nach `done/`. Das Carveout-Audit der Welle (welle-09 §3) liest die Zellen
  gegen einen Trigger, den es nur noch in `done/` findet, und kann nicht entscheiden, ob die
  Zelle offen oder erledigt ist — genau die Drift, gegen die Modul 7 den Auflösungs-Trigger
  eingeführt hat.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '195,205p'` der ADR gegen
  `sed -n '66,79p' docs/plan/carveouts/CO-002-token-achse-je-rolle.md`. Kein Sensor liest
  Trigger-Bezüge.

### MEDIUM-3 — Der Beleg, an dem der Trichter-Ausgang hängt, trägt Tag, Datei und Abschnitt, aber kein Zitat — und verdeckt damit, dass der Trichter eine vorgelagerte Frage hat

- **kategorie:** MEDIUM
- **quelle:** `ADR-0016` (**Accepted**) Festlegung 2 (*„dem **Zitat verbatim** — der Substanz"*)
  und Festlegung 3(a) (*„Bevor der Status eines ADR auf *Accepted* wechselt, werden seine
  Baseline-Belege in die Form aus Festlegung 2 gebracht"*)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:173-175` und `:270-272` gegen
  `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:246-258,285-297`
- **befund:** Von vier Regelwerks-Belegen der ADR tragen drei die volle Form aus
  `ADR-0016` Festlegung 2 (die Zitate aus `modul-13-quality-gates.md`,
  `modul-15-observability.md` und `modul-11-verification.md` habe ich gegen den vendored Baum
  gehalten — **wortgleich**). Der vierte, `:174-175`, nennt *„(`v3.5.2`,
  `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz) Frage 2"* **ohne Zitat**, und an ihm
  hängt der Ausgang, der die Zelle auf *nicht emittiert* statt *ADR-Verdikt* setzt. Ohne das
  Zitat ist im eingefrorenen Artefakt nicht mehr sichtbar, dass der Abschnitt **zwei
  sequenzielle** Fragen führt — *„Granularität *vor* Temporalität"*, wobei Frage 1 bei einem
  *„Cluster im selben Geltungsbereich"* auf eine BF-Sub-Area-Markierung leitet und *„Frage 2
  entfällt"*. Die ADR beantwortet nur Frage 2 und sagt nicht, warum Frage 1 bei drei
  Nicht-Emissionen desselben Geltungsbereichs nicht greift. Zweite, schwächere Instanz:
  `:270-272` (*„Das Observability-Modul verlangt je Doku-Konsistenz-Regel ein Feld
  Lebenszyklus"*) nennt weder Tag noch Datei noch Abschnitt noch Zitat.
- **gegenbeispiel:** Nach der Re-Baseline auf `v5.3.0` liest jemand die dann immutable ADR und
  will prüfen, ob der Trichter-Ausgang trägt. Er findet unter dem neuen Tag einen geänderten
  Abschnitt und hat im Artefakt keinen Text, gegen den er halten könnte — der Fall, für den
  `ADR-0016` gebaut wurde (dort gemessen: 21 `target-missing` bei einem Tag-Tausch, und die
  Adresse repariert die Aussage nicht).
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '173,175p;270,272p'` der ADR gegen
  `ADR-0016` Festlegung 2. Maschinell **nicht** bewacht: `.d-check.yml` prüft, ob ein Link
  auflöst, nicht ob ein Beleg ein Zitat trägt.

### MEDIUM-4 — „Der einzige denkbare Sensor wäre eine geschlossene Liste des gesamten emittierten Datei-Satzes" ist im selben Repo widerlegt

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6 (*„Keine Zusage ohne rot gesehenes Gegenbeispiel"*); `LH-QA-01`
  (die Fitness-Function-Zeile behauptet eine Unmöglichkeit)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:370` und `:339-344` gegen
  `internal/emit/enforce_test.go:49-57`
- **befund:** Die Fitness-Function-Tabelle führt für die drei Nicht-Emissionen `keines` und
  begründet: *„Der einzige denkbare Sensor wäre eine geschlossene Liste des gesamten emittierten
  Datei-Satzes; sie existiert nicht"*. Die Konsequenzen sagen dasselbe als Überschrift: *„über
  einer Abwesenheit gibt es keinen Wächter"*. Der **spezifische** Teil ist richtig und von mir
  nachgelesen — `TestEnforce_EmitsAllMechanicFiles` prüft **Enthaltensein**, nicht
  Vollständigkeit (`internal/emit/enforce_test.go:20-48`). Der **verallgemeinerte** Teil ist es
  nicht: unmittelbar darunter, in derselben Testfunktion, steht ein Wächter über genau einer
  Abwesenheit, ganz ohne geschlossene Liste — `if strings.Contains(got, "blocked/")` und
  `os.Stat(… "tools/harness/blocked"); !os.IsNotExist(err)`, beide mit `t.Errorf`
  (`internal/emit/enforce_test.go:51-57`). Ein `…KeinSpanEmitterEmittiert` oder
  `…KeinClaudeAgentsVerzeichnis` hat exakt diese Gestalt. Der Satz *„Die drei Nicht-Emissionen
  tragen ihre Verbindlichkeit aus dieser Entscheidung, nicht aus einem Sensor"* ist damit eine
  Wahl, keine Feststellung — und er steht im Indikativ, als sei die Alternative geprüft worden.
- **gegenbeispiel:** Ein späterer Slice schreibt drei fünfzeilige Go-Tests, die nach `Bootstrap`
  die Abwesenheit von `.claude/agents/`, eines Span-Emitters und eines Token-Berichts im Ziel
  behaupten, und färbt sie einmal rot. Dann existiert der Sensor, den die ADR für undenkbar
  erklärt, und die Zeile `keines` in einer §3.4-immutablen Tabelle ist falsch.
- **verifizierbar:** ja — `sed -n '49,57p' internal/emit/enforce_test.go`; `make test` färbt
  diesen Wächter heute grün, ein probeweise entferntes `blocked/`-Verbot färbt ihn rot.

### MEDIUM-5 — `welle-09` kann nach dieser Entscheidung nur über einen Slice schließen, der nicht Mitglied der Welle und nicht geschnitten ist

- **kategorie:** MEDIUM
- **quelle:** `welle-09` §3 (*„Alle Slices dieser Welle in `done/`"*, *„Eine leere Zelle ist ein
  offener Closure-Trigger"*); `LH-QA-01`
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:250-253,349-351` ·
  `docs/plan/planning/open/slice-062-emittierte-modul-15-regeln.md:307-338` ·
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:160-170`
- **befund:** Festlegung 4(e)/Folgepflicht 2 machen die Emission des `targets:`-Blocks von der
  Neutralisierung der fünf Phantom-Behauptungen abhängig. `slice-062` §6 legt diese Arbeit
  ausdrücklich in *„einen eigenen, wellenlosen Slice"*, der *„geschnitten wird, wenn er an der
  Reihe ist"* — er existiert also nicht, hat keinen Eintritts-Trigger und steht in keiner
  Slice-Tabelle. `slice-063` (Mitglied der Welle, `welle-09` §4) schuldet den Beleg beider
  Richtungen und hängt nach `slice-062` §6 an genau dieser Vorarbeit. Damit hängt der
  Closure-Trigger *„alle Slices dieser Welle in `done/`"* an einem Nicht-Mitglied, und keine der
  drei Plan-Ebenen (ADR-Folgepflichten, `slice-062` §4 Trigger, `welle-09` §4/§5) nennt die
  Abhängigkeit als solche.
- **gegenbeispiel:** Das Wellen-Closure wird angesetzt; `slice-063` steht in `open/`, sein
  Eintritt fragt nach `welle-09` §4 nur `slice-062` ab, und die Zelle *Doku-Konsistenz × Tool*
  bleibt ohne den geschuldeten *rot gesehen*-Beleg — eine leere Zelle, die nach §3 ein offener
  Closure-Trigger ist, ohne dass ein Artefakt sagt, worauf sie wartet.
- **verifizierbar:** ja, ohne Gate-Lauf — `ls docs/plan/planning/open/` gegen die Slice-Tabelle
  in `welle-09` §4 und gegen `slice-062` §6.

### MEDIUM-6 — Eine §3.4-immutabel werdende Entscheidung erklärt, auf einer *Proposed* ADR aufzubauen, die zwei Review-Runden blockiert haben

- **kategorie:** MEDIUM
- **quelle:** Modul 10 §Repo-spezifische Anker (*„nur aktive sind normativ"*); `AGENTS.md` §3.4
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:36-38` (*„Festlegung 2 baut darauf
  auf"*), `:328-330`, `:359-363` (Folgepflicht 5) gegen
  `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:3` (**Proposed**) und
  `docs/reviews/2026-08-15-adr-0019-bestaetigungsrunde-runde-2.md`
- **befund:** Die Bezug-Zeile erklärt ausdrücklich eine tragende Beziehung zu `ADR-0019`
  Folgepflicht 4; die Konsequenzen führen *„die offene Frage aus `ADR-0019` Folgepflicht 4 hat
  für heute eine Antwort"*, Folgepflicht 5 verweist erneut darauf. `ADR-0019` steht auf
  *Proposed* und ist in zwei aufeinanderfolgenden Bestätigungsrunden blockiert worden (Runde 2
  mit einem HIGH). Die inhaltliche Begründung von Festlegung 2 steht zwar unabhängig — sie ruht
  auf der Pflichtfeld-Eigenschaft der Rolle und den zwei Null-Messungen, die ich selbst
  nachgefahren habe. Was fällt, ist der **Verweis**: wird `ADR-0019` verworfen oder in eine
  andere Fassung überführt, führt eine dann unveränderliche ADR eine Folgepflicht fort, die es
  nicht gibt, und §3.4 lässt keine Korrektur zu.
- **gegenbeispiel:** Runde 3 zu `ADR-0019` fällt erneut blockierend aus, und die Entscheidung
  wird neu geschnitten. `ADR-0020` ist zu diesem Zeitpunkt Accepted und nennt in ihrem Bezug,
  ihren Konsequenzen und ihrer Folgepflicht 5 eine Folgepflicht 4, die in der neuen Fassung eine
  andere Nummer oder keinen Gegenstand hat.
- **verifizierbar:** ja, ohne Gate-Lauf —
  `grep -n '^\*\*Status:\*\*' docs/plan/adr/0019-*.md` und der Verdikt-Abschnitt von
  `docs/reviews/2026-08-15-adr-0019-bestaetigungsrunde-runde-2.md`. Das `matrix`-Modul verbietet
  Verweise auf `superseded`/`deprecated`, nicht auf `Proposed`.

### LOW-1 — „T3 enthält T1" ist enger formuliert, als Festlegung 1 zulässt

- **kategorie:** LOW
- **quelle:** Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Ziel-Form (beobachtbare Schwelle)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:190-193` gegen `:150-159`
- **befund:** Festlegung 1 nennt **zwei** Wege zu einer Emission des Erfassungs-Blocks — Quelle
  plus Bauschritt, oder ein vorgebautes Binär je Zielplattform — und verwirft beide für heute.
  T1 (*„die Erfassung läuft ohne Kompilat"*) deckt nur den ersten. Wird der zweite später
  gewählt, tritt T3 (*„der Erfassungs-Block wird emittiert"*) ein, ohne dass T1 je gefallen
  wäre; die Formulierung *„T3 **enthält** T1"* trifft das nicht. Der operative Satz daneben
  (*„wandert die Zelle aus Festlegung 1 je auf *ADR-Verdikt*, wandert diese mit"*) hält die
  Kopplung trotzdem, weshalb nichts bricht.
- **gegenbeispiel:** Eine Folge-Entscheidung nimmt die verworfene Artefakt-Klasse an und
  emittiert ein vorgebautes Binär. T3 ist erfüllt, T1 nicht — wer die Zellen entlang der
  Enthaltensein-Aussage prüft, hält die Rollen-Typen-Zelle für ungelöst.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '150,159p;190,193p'` der ADR.

### LOW-2 — Zwei der drei Argumente gegen die konditionale Emission tragen nicht; das dritte trägt sie allein

- **kategorie:** LOW
- **quelle:** `LH-FA-07`; `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:289-307` gegen
  `spec/lastenheft.md:159-173`, `internal/gen/golang.go:909-928`, `internal/emit/archgate.go:97`
- **befund:** Das Zitat aus `LH-FA-07` (*„eine **strukturelle** Bedingung … **keine Liste von
  Architektur-Namen**"*) ist wortgleich, selbst geprüft. Von den drei Gegenargumenten hält das
  **zweite** — der Gegenstand ist entgegengesetzt (ein Doku-Ziel erzeugt Tool-Calls, hat also
  sehr wohl etwas zu erfassen) —, und der Namenslisten-Einwand hält ebenfalls, weil der
  Mechanismus **Go** braucht, nicht „eine Sprache" (`gen.SupportedLangs()` führt `go` und
  `cpp`), die Bedingung also auf **einen** Namen schrumpft. Das **erste** Argument (*„das Ziel
  führt die Toolchain, die der Mechanismus braucht — und die ist unsere"*) ist für ein
  `--lang go`-Ziel widerlegbar: dieses Ziel führt seine Go-Toolchain selbst, docker-getrieben,
  in `harness/mk/go.mk`. Das **dritte** (*„Telemetrie ist ein Init-Belang, kein Sprach-Belang"*)
  setzt voraus, was die Variante bestreitet, und hat mit `LH-FA-07` selbst ein Gegenbeispiel:
  das Arch-Gate ist Harness-Infrastruktur und wird in der Sprach-/Arch-Phase emittiert
  (`internal/emit/archgate.go:97`, `add-lang … --arch`).
- **gegenbeispiel:** Eine Folge-Entscheidung greift die konditionale Variante wieder auf und
  beruft sich darauf, dass Argument eins und drei nicht tragen. Sie muss dann Argument zwei neu
  widerlegen — was die ADR ihr nicht abgenommen hat, weil sie drei Argumente kumulativ führt,
  von denen zwei die Last nicht tragen.
- **verifizierbar:** ja, ohne Gate-Lauf — `sed -n '289,307p'` der ADR gegen
  `sed -n '159,173p' spec/lastenheft.md` und `sed -n '907,928p' internal/gen/golang.go`.

### LOW-3 — Der Lebenszyklus-Wert nennt eine Stufe, für die es im emittierten Ziel keinen Aufhänger gibt

- **kategorie:** LOW
- **quelle:** Regelwerk `v3.5.2`, `modul-15-observability.md` §Doku-Konsistenz-Drift-Regeln
  (*„ist das ein Pre-commit-Check, Pre-integration, oder Continuous"*); `LH-QA-01`
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:270-275` gegen
  `internal/emit/makefile.go:14-37`, `internal/emit/baseline.go:31-39`,
  `internal/emit/enforce.go:42-58`
- **befund:** 5(c) setzt den Modul-15-Pflichtwert auf *„pre-integration, auf Abruf"* und stützt
  die Trennung von `make gates` auf `modul-11-verification.md` (*„eine DoD-/Closure-Frage hängt
  an `verify:` (nicht `make gates` …)"*, wortgleich, selbst geprüft). Das emittierte Ziel führt
  aber **kein** `verify:`-Target: der Aggregator kennt `gates`, `help`, `record-gates`, die
  Fragmente steuern `baseline-verify`, `docs-check`, `record-gates` und — mit `--lang` —
  `lint`/`build`/`test` bei. *„Pre-integration"* benennt damit eine Stufe, die im Ziel keinen
  Träger hat; *„auf Abruf"* ist zudem keiner der drei vom Modul angebotenen Werte.
- **gegenbeispiel:** Ein Adopter liest im Konfigurations-Kommentar *„pre-integration"* und sucht
  das Target, das die Regel vor der Integration fährt. Es gibt keines — die Regel läuft nur,
  wenn jemand sie von Hand aufruft, und das ist kein Lebenszyklus, sondern seine Abwesenheit.
- **verifizierbar:** ja — `grep -rn '^verify:' ` über einen frisch gebootstrappten Baum bzw.
  über die vier Emissions-Quellen oben.

### INFO-1 — Der Präzedenzfall der Nachbarspalte ist unterscheidbar, aber nicht genannt

- **kategorie:** INFO
- **quelle:** `welle-09` §3 (Wert-Tabelle)
- **pfad:** `docs/plan/adr/0020-emittierte-modul-15-regeln.md:255-269` gegen
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:94-99`
- **befund:** Dieselbe Welle hat in der **Repo**-Spalte einen Wert ausdrücklich ausgeschlossen,
  weil sein Kandidat nicht als Gate läuft (*„ein Bericht ist kein Wächter — er läuft nicht als
  Gate, er färbt nichts rot, er hat keinen `test/mutations/`-Fall"*). Festlegung 5 kommt in der
  Nachbarspalte zum umgekehrten Ergebnis (*„*rot gesehen* und *im Gate-Lauf* sind zweierlei"*).
  Die Auslegung hält: `welle-09` §3 definiert *emittiert* als *„im Ziel vorhanden **und dort rot
  gesehen**"* und nennt keinen Gate-Lauf, und `doc-targets` endet auf Befund mit Exit 1 (selbst
  gemessen: Sonde A, Exit 1) — anders als `make span-report`, der nichts rot färbt. Das
  **unterscheidende** Merkmal steht in der ADR nicht, und ohne es liest sich Festlegung 5 als
  Widerspruch zum einzigen Präzedenzfall derselben Welle.
- **gegenbeispiel:** Das Wellen-Closure vergleicht die zwei Spalten und muss ohne Anhaltspunkt
  entscheiden, warum dieselbe Frage („läuft es als Gate?") einmal ausschließt und einmal nicht.
- **verifizierbar:** nein (Lesbarkeits-/Kohärenz-Befund, kein Sensor).

---

## Negativbefunde — geprüft, ohne Befund

- **Die drei Null-Messungen aus §Kontext (`:108-113`).** Alle drei selbst nachgefahren, alle
  drei null: `claude/agents` kommt in keiner `.go`-Datei, in keiner Emissions-Vorlage und in
  keiner vendored Vorlage vor. Die Aussage *„kein emittiertes Artefakt liest das Verzeichnis"*
  trägt für den Emissions-Pfad.
- **Der `targets:`-Block als Verbatim-Zitat (`:120-126`).** Selbst aus dem gepinnten Image
  gedruckt (`--network none`) — Zeichen für Zeichen identisch, inklusive der Kommentar-Spalte.
- **Der Träger ist im Dogfood stumm (`:98-102`).** `make doc-targets` selbst gefahren:
  `320 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Die zweite Hälfte der Sonde (mit Block: 2
  Befunde, Exit 1) habe ich **nicht** wiederholt; die ADR deklariert das ausdrücklich als aus
  dem Plan übernommen, und das ist die richtige Form.
- **Der Fünfer-Satz ist die sprachlose Init-Emission (`:210-216`).** Aus dem Code gelesen, kein
  sechster Kandidat: `internal/emit/makefile.go:42` (`Makefile`), `internal/emit/emit.go:110-113`
  (`d-check.mk`, `harness/mk/doc-gate.mk`), `internal/emit/baseline.go:28`
  (`harness/mk/baseline.mk`), `internal/emit/enforce.go:52` (`harness/mk/enforce.mk`).
- **`a-check.mk` und `harness/mk/arch-<modul>.mk` ungenannt zu lassen, kostet heute nichts —
  REFUTED mit Beleg.** Sonde C: beide vorhanden, beide ungenannt, `0 Befund(e)`, Exit 0. Grund:
  Richtung 1 prüft nur, was ein Doku-Tisch behauptet, und keine der zwei emittierten Vorlagen
  nennt `make a-check` (selbst ausgezählt: die neun behaupteten Ziele führen `arch-check`, nicht
  `a-check`). Der Verzicht auf `authority:` (4(d)) schließt Richtung 2 aus, die es sonst gemeldet
  hätte. Die Sorge aus der Aufgabenstellung trifft `harness/mk/go.mk`, nicht `a-check.mk`.
- **Drei der vier Regelwerks-Zitate sind wortgleich.** `modul-13-quality-gates.md` §Hard Rule
  (Doku-Disziplin), `modul-15-observability.md` §Doku-Konsistenz-Drift-Regeln,
  `modul-11-verification.md` §Fitness Function ohne Standard-Tool — alle drei gegen den
  vendored Baum gehalten. Auch das `LH-FA-07`-Zitat und das `ADR-0011`-Festlegung-4-Zitat
  (*„nicht zwischen ‚Shell' und ‚Sprache', sondern zwischen **vorhanden** und **zu
  installieren**"*) sind wortgleich.
- **Die Abgrenzung gegen das Abhängigkeitsbudget (`:160-165`) trägt.** `ADR-0011` Festlegung 4
  führt `docker` ausdrücklich auf der erlaubten Seite; `LH-QA-03` spricht ausweislich seiner
  Messmethode von der Nutzer-Laufzeit des Tools. Der Satz *„Wer sie später mit dem Budget
  begründet, begründet sie falsch"* ist korrekt.
- **Das Vertrags-Stratum ist unberührt.** `git show --stat 3e1939e` zeigt genau zwei Dateien:
  die ADR und den Index. `spec/lastenheft.md` ist nicht darunter — die Aussage aus `:52-56` und
  aus `slice-062` §2/§3 hält für diesen Commit.
- **Rollen-Trennung nach `AGENTS.md` §3.8.** `3e1939e` berührt ausschließlich
  Architect-Artefakte (`docs/plan/adr/**`), nennt die Rolle in der Message und steht als eigener
  Commit neben den zwei Planner-Commits. Keine Vermischung.
- **Idempotenz-Annahme (c) (`:141-143`).** `internal/emit/emit.go:106` schreibt `.d-check.yml`
  per `writeSkipIfPresent` — *skip-if-present* ist der reale Zustand, nicht eine Erinnerung.
- **`MR-010`-Bezug (`:43-44`).** `doc-targets` liegt verbatim im tool-generierten Fragment:
  `d-check.mk:63-65` führt das Rezept, `internal/emit/emit.go:41-45` schreibt den Kopf *„advisory
  `doc-*`-Targets verbatim"*, und `AdaptMK` benennt nur `doc-check` um. Das Modul wird vom Rezept
  selbst freigeschaltet (`--enable targets`), die `modules:`-Liste der emittierten Konfiguration
  (`[links, anchors]`) steht ihm nicht im Weg — selbst gelesen.
- **4(d) — `authority:` weglassen ist richtig begründet.** Das zitierte Modul-13-Kapitel führt
  genau diesen Fall selbst als Beispiel an (*„die advisory-Targets (`doc-trace`, `doc-doctor`,
  …) sind verfügbar, aber nicht als Gate behauptet"*). Kein Befund.
- **Doku-Gate über dem neuen Bestand.** `make docs-check`: `320 Datei(en) geprüft, 0 Befund(e)`,
  Exit 0.
- **Was ich NICHT geprüft habe, und das gehört gesagt:** die Zahl *15 Gate-Zeilen* aus
  `slice-062` §6 (ich habe 19 Nennungen und 9 verschiedene Ziele gezählt — die Differenz ist
  vermutlich die Abgrenzung „Gate-Tabelle" gegen Fließtext und war für keinen Befund
  tragend); die zweite Hälfte der Plan-Sonde; jeder Lauf an einem wirklich gebootstrappten Ziel
  (`make full-smoke` ist Verifier-Arbeit).

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 2 | HIGH-1, HIGH-2 |
| MEDIUM | 6 | MEDIUM-1 … MEDIUM-6 |
| LOW | 3 | LOW-1, LOW-2, LOW-3 |
| INFO | 1 | INFO-1 |

---

## Verdikt

**Blockiert.** Die ADR geht in dieser Fassung **nicht** auf *Accepted*.

**Blockierend sind HIGH-1 und HIGH-2**, und sie blockieren aus verschiedenen Gründen:

- **HIGH-1** entscheidet einen **Matrix-Wert**. Fällt die Analogie, fällt die Antwort auf Modul 7
  Frage 2, und die Zelle schuldet *ADR-Verdikt* statt *nicht emittiert*. Der Beleg, den die ADR
  dafür anführt, nennt eine andere Hook-Payload, und die Gegenmessung steht im Kopfkommentar der
  Datei, um die es geht. Das ist dieselbe Klasse, die `ADR-0019` zweimal blockiert hat — eine
  Ableitung im Indikativ, deren Messung woanders liegt und in die andere Richtung zeigt.
- **HIGH-2** ist gemessen, nicht abgeleitet: der beschlossene Datei-Satz produziert in der
  meistgefahrenen Bootstrap-Variante vier Befunde, von denen **keiner** zutrifft, und die
  Ausgabe ist von der wahren Meldung nicht zu unterscheiden. Die ADR nennt die Lücke, ordnet sie
  aber als Adopter-Pflicht ein, obwohl beide Ursachen aus unserer Emission stammen. Nach §3.4
  ist das nach der Annahme nicht mehr korrigierbar.

Die sechs MEDIUM blockieren nach Modul 10 §Ablage ebenfalls typischerweise; MEDIUM-3 ist
zusätzlich eine **ausdrückliche Vorbedingung des Statuswechsels** (`ADR-0016` Festlegung 3(a)
bindet den Accept-Übergang). LOW-1 bis LOW-3 und INFO-1 blockieren nicht.

**Nicht Gegenstand dieses Verdikts:** wie die Befunde aufzulösen sind. Lösungen gehören in die
Übergabe an den Architect, nicht ins Finding (Modul 10 §Anti-Pattern). Die Auftraggeber-Setzungen
vom 2026-08-16 selbst sind hier **nicht** geprüft worden — sie sind die Eingangsgröße, nicht der
Gegenstand; geprüft ist, ob die ADR sie trägt.
