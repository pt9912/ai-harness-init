# Slice slice-neutralisierung-haelt-ihren-wortlaut-am-gepinnten-stand: Eine Wortlaut-Neutralisierung des Emitters trifft ihren Marker am gepinnten Kurs-Stand

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0037](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md), [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-07.

---
## 1. Ziel und Abgrenzung

**Ziel:** Jede Wortlaut-Neutralisierung in `internal/emit/templates.go` trifft ihren Marker in der
Vorlage des gepinnten Kurs-Stands (`DefaultTag`), und eine, die ihn dort nicht trifft, färbt
`make test` rot — gemessen am vendored Baum, nicht an der Fixture. `NeutralizeRoadmap` trifft ihren
Marker am Pin nicht und bleibt mit erwarteter Trefferzahl 0, weil ein älterer `COURSE_TAG` ihn trägt.

**Lage** (Arbeitsbaum dieses Plans, keine Erwartungswerte):

```sh
T=.harness/baseline/v6.17.0/templates
grep -c 'welle-NN-results.md`](../done/' $T/docs/plan/planning/roadmap.template.md                 # 0
grep -c '^`harness/conventions/MR-NNN-titel.template.md` der vendored' $T/harness/conventions.template.md   # 1
grep -c 'sondern in ihr eigenes `docs/plan/carveouts/done/` (Baseline' $T/docs/plan/planning/README.template.md   # 1
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- `NeutralizeMakeClaims`, `NeutralizePlaceholderLinks` — *Bestand bleibt stehen:* sie tragen eine
  Form statt eines Wortlauts und greifen an jedem Stand; der Platzhalter-Link der Roadmap fällt
  bereits unter die zweite.
- Ein Kurs-Fix upstream — *anderer Vorgang:* der Kurs-Klon wird nur gelesen.

## 2. Definition of Done

- [x] `NeutralizeRoadmap` bleibt: die emittierte Roadmap ist am Pin gate-sicher, die Neutralisierung
      wirkt für ältere Kurs-Stände (Fixture byte-gleich zu `v6.5.0`, Zeile 107), und ihr Marker trifft
      die Vorlage am Pin 0×. **Rot-Werkzeug:** Mutations-Fall 29 (`TestTemplates_RoadmapGateSafe`
      rot) und der Marker-Fall aus Liefer-Punkt 2 mit `ERWARTUNG roadmapDoneLink:0`.
- [x] Ein Fall in `make test` liest die Vorlagen des vendored Baums zu `DefaultTag` und verlangt je
      Wortlaut-Marker seine erwartete Trefferzahl (`conventionsPathRefOld`, `carveoutsDoneRefOld`
      je 1, `roadmapDoneLink` 0). **Rot-Werkzeug:** ein Fall in `test/mutations/` (`sed`-Anker gegen
      den Quell-Bestand, [`MR-071`](../../../../harness/conventions.md#mr-071)) verfälscht einen
      Marker in `templates.go`; `make mutate MUTATE_CASES=<nr>` meldet ihn gebunden, die Meldung
      (Marker und Vorlage) ist gelesen und als `expect:` eingetragen.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | Tabelle `WortlautNeutralisierungen()` trägt jeden Marker samt Vorlage und Erwartung; Doc-Kommentare nennen den neuen Fall statt „kein Sensor" |
| `internal/emit/neutralisierung_test.go` | neu | go/ast-Strukturtest: keine Wortlaut-Ersetzung außerhalb der Tabelle; `TestNeutralizeRoadmap` |
| `internal/emit/templates_test.go`, Fixture `courseSet()` | update | Roadmap-Fixture byte-gleich zu `v6.5.0` |
| `test/neutralisierung-marker.bats` | neu | Marker-Fall gegen den vendored Baum (die Go-`test`-Stage sieht `.harness/` nicht) |
| `test/mutations/` | neu | Fälle 561 und 562; Fall 29 bleibt ([`MR-071`](../../../../harness/conventions.md#mr-071)) |

## 4. Trigger

**Start** (`next` → `in-progress`): Auftrag des Auftraggebers (Inventur vom 2026-10-07); keine Abhängigkeit.

- `in-progress` → `next`: der Marker-Fall braucht den vendored Baum in einer Stage, die ihn nicht sieht, und der Ausweg sprengt drei Liefer-Punkte.
- `in-progress` → `open`: —

## 5. Closure-Trigger

DoD vollständig, `make gates` und `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Go-`test`-Stage sieht `.harness/baseline/` nicht; dann trägt ein bats-Fall in `make test` den Marker-Fall — **Ausgang:** eingetreten — der Marker-Fall
  läuft als `test/neutralisierung-marker.bats` in `make test` (Fall 561 bindet), innerhalb der drei
  Liefer-Punkte; kein Rückweg nach `next/`.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-08

- **Was hat funktioniert:** DoD 2–4 bestätigt
  ([Verifikation](../../../reviews/2026-10-08-neutralisierung-verifikation.md));
  `make mutate MUTATE_CASES=…` → 3 ok, 0 Befund(e) für 561, 562, 29. Fixture gegen den Kurs-Klon
  byte-gleich zu `v6.5.0`.
- **Was ging anders als geplant:** die Abnahme verschob sich durch das
  [Review](../../../reviews/2026-10-08-neutralisierung-review.md). MEDIUM-1: ohne `NeutralizeRoadmap`
  emittiert ein älterer `COURSE_TAG` (Handbuch-Beispiel `v3.5.2`) einen toten Link — sie bleibt, mit
  Erwartung 0 am Pin; §1 und DoD 1 sind darauf nachgezogen (vorher „entfällt"). HIGH-1: der
  Vollständigkeits-Fall blieb über Ersetzungen außerhalb der Liste grün — behoben mit der Tabelle
  `WortlautNeutralisierungen()` und dem go/ast-Strukturtest (Fall 562); §3 nachgezogen.
- **Grenze:** kein Bootstrap mit `COURSE_TAG=v6.5.0` gefahren (kein lokales Release-Asset); die
  Wirkung für ältere Stände trägt die byte-gleiche Fixture, nicht ein Lauf im Ziel.
- **Steering-Loop-Eintrag:** neuer Sensor — `test/neutralisierung-marker.bats` hält jeden
  Wortlaut-Marker der Tabelle gegen seine Vorlage im vendored Baum zu `DefaultTag`, und
  `TestWortlautNeutralisierungen_EineTabelle` hält, dass keine Ersetzung an der Tabelle vorbeiläuft.
  Grenze: ein Import-Alias auf `strings` umgeht den Strukturtest (Verifikation LOW).
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/emittierte-neutralisierung-greift-am-vendorten-stand-nicht`](../observations/BEO-ALL/emittierte-neutralisierung-greift-am-vendorten-stand-nicht/observation.md)
  → gestrichen (Begründung in `state.md`); neu
  [`BEO-ALL/strukturtest-sieht-den-import-alias-nicht`](../observations/BEO-ALL/strukturtest-sieht-den-import-alias-nicht/observation.md)
  (1 Beleg).
- **Folge-Slices:** keine.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR: kein
  Re-Evaluierungs-Trigger eingetreten. Hard Rules: keine entfernt.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (`ALL`, `harness/conventions.md`
§Modus-Deklaration pro Sub-Area); `internal/emit/` führt keine eigene Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/emittierte-neutralisierung-greift-am-vendorten-stand-nicht`
— 1 Beleg (`ls docs/plan/planning/observations/BEO-ALL/emittierte-neutralisierung-greift-am-vendorten-stand-nicht/evidence | wc -l`);
dieser Slice ist ihr Gegenstand, die Closure gibt ihr den Ausgang. `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` — 2 Belege, nicht berührt.

Alle berührten Sub-Areas GF.

