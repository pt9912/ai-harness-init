# welle-05 — Closure-Notiz (Ergebnisse)

**Welle:** [welle-05-bootstrap-phasen](welle-05-bootstrap-phasen.md). **Meilenstein:** kein formaler — die Welle liefert die [`ADR-0007`](../../adr/0007-bootstrap-phasen.md)-Fähigkeit („doc führt" gilt auch für die Zielsprache); M1/M2 waren bereits erreicht.
**Abschluss:** 2026-07-23 (beobachtbarer Trigger, kein Kalendertag).

Lerneintrag zur Wellen-Closure (Modul 6, Schritt 3): *was gelernt wurde*, nicht nur *dass sie weg ist*.

---

## 1. Geliefert

Der **Bootstrap ist phasiert** ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)): `ai-harness-init` läuft **sprach-agnostisch** (Init → `make gates` grün auf reinen Docs), die Zielsprache ist eine **Adopter-ADR-Entscheidung** statt eines Init-Arguments, und `add-lang` ist **wiederholbar** (Mono-Repo). Die Emission ist **idempotent** (konvergent / skip-if-present, prunt nie), der Command-Guard trägt einen **gebackenen universellen Boden** (nie fail-open).

- [slice-034](slice-034-gate-fragment-assembly.md): **Gate-Fragment-Assembly** — der Aggregator (`include harness/mk/*.mk` + `GATE_CHECKS +=` + Ordnungskante `record-gates: $(GATE_CHECKS)`), Fragmente je Belang. Verhaltens-erhaltender Refactor (Nutzer-Option A), Fundament der Welle.
- [slice-035](slice-035-cli-phasierung.md): **CLI-Phasierung** — `--lang` optional, Init sprach-agnostisch, doc-only-Gate grün. Der Aggregator vom `gen` in den Init-Emitter `emit.Makefile` relocatet.
- [slice-036](slice-036-guard-blocked-union.md): **Guard-BLOCKED-Union** — der emittierte Guard trägt den universellen Boden GEBACKEN (nie fail-open, [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) NEU-H1) + vereinigt `tools/harness/blocked/*` ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [slice-037](slice-037-add-lang.md): **`add-lang`-Subkommando** — `<pfad>`-verortetes Skelett + Code-Gate-Fragment (`harness/mk/<modul>.mk`, modul-scoped im Subdir) + `blocked/<sprache>`, wiederholbar → Mono-Repo ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)).
- [slice-038](slice-038-idempotenz-klassifikation.md): **Idempotenz-Klassifikation** — jede emittierte Datei genau eine Klasse (konvergent / skip-if-present), das Pre-Flight-refuse/`--force`-Modell ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) revidiert slice-025) gefallen, 2. Init-Lauf idempotent (Exit 0).

## 2. Was funktionierte

- **Die Doc-Führung zahlte sich in der Implementierung aus.** [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (nach ZWEI Proposed-Review-Runden accepted), die CR [`lastenheft.md`](../../../../spec/lastenheft.md) 0.10.0 und der [`architecture.md`](../../../../spec/architecture.md)-Nachzug (§5 Idempotenz) schrieben die **Ziel-Form vor dem Code** — slice-038 musste das Modell nur einholen, nicht erfinden. „Doc führt, Code folgt" trug über eine ganze Welle.
- **Zwei Nutzer-Scope-Entscheidungen (AskUserQuestion) schnitten Slices richtig.** slice-037 „voller Mono-Repo" (Option A) statt eines leeren ersten Schnitts; slice-038 „`--force` entfernen" (ADR-treu) statt es als toten No-op zu behalten. Wo der ADR-Wortlaut Spielraum ließ, entschied der Mensch den Vertrag.
- **Die getrennt-Kontext-Rollenkette trug 5×.** Jeder Slice: Implementation → unabhängiger Reviewer (frischer Kontext) → unabhängiger Verifier (fährt die Sensoren selbst) → Planner-Closure. Sie fing eine echte MEDIUM je in slice-037 (`<pfad>`-Containment-Ausbruch) und slice-038 (`.harness/skills/*` Fehl-Klasse) — beide für den schreibenden Kontext unsichtbar.
- **`make full-smoke` wuchs mit jeder Fähigkeit mit** und misst jetzt die ganze [`ADR-0007`](../../adr/0007-bootstrap-phasen.md)-Fitness real: doc-only-Init ohne Skelett · `add-lang` Mono-Repo (zwei Module in EINEM `make -j gates`) · Idempotenz (2. Init Exit 0, skip-if-present unberührt, konvergent geheilt) · kein Prune · Guard-Boden fail-safe.

## 3. Was anders lief

- **Messen-zuerst deckte einen Re-Slice und einen Doc-Stale-Fehler auf.** slice-034s Plan setzte die Lieferung von slice-035 voraus (Ist-Messung → Nutzer wählte den verhaltens-erhaltenden Option-A-Schnitt). slice-037s Review fand, dass [`ADR-0007`](../../adr/0007-bootstrap-phasen.md)s „Durchsetzung sprach-agnostisch" gegen den Ist-Guard (je `--lang`) falsch war — schon in der ADR-Proposed-Runde gefangen.
- **Eine abgeschaffte Mechanik hatte abzuschaffende, nicht zu migrierende Tests.** slice-038 entfernte den Pre-Flight-Refuse — die 6 cmd-Kollisions-Tests + ihre 5 Mutationen (12/14/23/25/46) wurden ENTFERNT (nicht „idempotent umgeschrieben"), die Deckung wanderte in Emitter-Unit-Tests + `full-smoke`.
- **Fix-induzierte Regressionen brauchten den zweiten Blick.** slice-037: das neue zweite `if !ok {` machte Mutation 17 unspezifisch (Nil-Func-Panic) → `make mutate` meldete's als BEFUND, an eindeutiger Zeile re-verankert. Die Sicherheits-sensiblen Stellen ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) NEU-H1 fail-open, `<pfad>`-Containment) lohnten je einen expliziten zweiten Verifikations-Durchgang.

## 4. Steering-Loop-Einträge (wellen-übergreifend)

- **Einen Batch-Emitter uniform auf eine Idempotenz-Klasse zu stellen faltet Datei-Ausnahmen still ein.** slice-038 machte `emit.Templates` pauschal skip-if-present und übersah, dass `.harness/skills/*` konvergent ist ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Z.100). Regel: bei Per-Datei-Klassifikation über einen Sammel-Emitter jede Datei gegen die ADR-Tabelle abgleichen — DocGate (`.d-check.yml` skip + `.mk` konvergent) ist der Mischklasse-Präzedenzfall.
- **Der erste nutzer-kontrollierte Pfad zu einer Schreib-Operation braucht einen Containment-Check.** slice-037s `add-lang <pfad>` war die erste Stelle, an der ein CLI-Argument zu `wire.Place` floss — `..`/absolut → Exit 2 ist dort Pflicht, mit Ausbruch-Test + Mutation.
- **Additive Erweiterung schützt bestehende Sensoren durch Byte-Identität.** slice-037 hielt die Root-Fragment-Fassung byte-identisch (statt „auch den Root scopen") → drei Sensoren (smoke/full-smoke/`--lang`) blieben ohne Anpassung grün, die Regressionsfläche blieb auf den neuen Subdir-Zweig begrenzt.
- **Zwei Verifikations-Rollen, die dieselbe Fehl-Klasse unabhängig finden, bestätigen den Wert der Rollen-Trennung.** slice-038: Reviewer (gegen ADR-Tabelle) UND Verifier (gegen DoD „architecture.md prüfen") fingen die Skills-Fehl-Klasse getrennt — der Batch-Refactor-Blindfleck war für den schreibenden Kontext unsichtbar, für zwei frische nicht.

## 5. Carveout-Audit (Modul 7, Schritt 2)

- **[CO-001](../../carveouts/CO-001-bats-shell-lint.md)** (shell-lint deckt die `.bats`-Dateien nicht ab): **unverändert aktiv + dokumentiert**. welle-05 berührt den `shell-lint`-Belang nicht (die neuen `test/mutations/*.sh` sind reguläre Skripte, von shell-lint gedeckt) — kein welle-05-Bezug, keine Verlängerung/Auflösung nötig.
- **Keine neuen Carveouts** in welle-05: jedes rote Gate wurde behoben, nie still akzeptiert (die zwei Review-MEDIUM in slice-037/038 wurden aufgelöst, nicht weggecarvet).

## 6. Folge-Slices (benannte `open/`-Kandidaten, Backlog)

- **`smoke.sh:89` toter `@@BLOCKED_SET@@`-Check** (slice-036-Folgepunkt) — tautologisch grün seit der Platzhalter entfiel; kleiner Cleanup zu `! grep 'BLOCKED="apt'` mit `make smoke`-Beleg.
- **git-Repo-Vorbedingung der emittierten `make gates`** ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) INFO I-1) — `record-gates` → `git rev-parse`; Kandidat README-Zeile oder Bootstrap-`git init`. `full-smoke` git-init'et das Ziel bereits.
- **Interaktives TTY-Frontend** ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Entscheidung 4: optional, nie tragend) — separater Slice, wenn gewünscht.
- **Weitere Sprach-Profile / -BLOCKED-Sets** über `go` hinaus ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) — ein neues gen-Profil + `blocked/<lang>`-Fragment je Sprache).
- **a-check / [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)** — bleibt aufgeschoben (hängt an hexagonalen Schichten, die weder Dogfood noch Skelett tragen).

## 7. Verifikation (die Belege aus Schritt 1)

- **Alle Slices 034–038 in `done/`** (`git mv`, je eigener Move-Commit).
- **`make gates` Exit 0** — `d-check` 142 Dateien / 0 Befunde, `baseline-verify` OK, `lint` 0 issues, `test`/`shell-lint`/`ci-lint` grün, `record-gates` STAMP-MATCH.
- **`make full-smoke` Exit 0** — die volle [`ADR-0007`](../../adr/0007-bootstrap-phasen.md)-Fitness real: doc-only-Init ohne Skelett · `add-lang` Mono-Repo (`apps/api` + `apps/web` in EINEM `make -j gates`) · Idempotenz (2. Init Exit 0, README skip-if-present unberührt, Makefile-Drift konvergent geheilt) · kein Prune (sprachloser Re-Lauf prunt kein add-lang-Fragment) · Guard-Boden fail-safe.
- **`make mutate` 44 ok / 0 Befund** — die Klassifikations- (49–53) und add-lang-/Guard-Wächter (44–48, 42/43) tragen Zähne; 5 obsolete Pre-Flight-Mutationen entfernt.
- **Review konform + DoD bestätigt je Slice** (`docs/reviews/2026-07-23-slice-03{4,5,6,7,8}-{review,verify}.md`).
