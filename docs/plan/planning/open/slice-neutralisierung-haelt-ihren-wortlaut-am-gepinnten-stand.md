# Slice slice-neutralisierung-haelt-ihren-wortlaut-am-gepinnten-stand: Eine Wortlaut-Neutralisierung des Emitters trifft ihren Marker am gepinnten Kurs-Stand

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0037](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md), [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---
## 1. Ziel und Abgrenzung

**Ziel:** Jede Wortlaut-Neutralisierung in `internal/emit/templates.go` trifft ihren Marker in der
Vorlage des gepinnten Kurs-Stands (`DefaultTag`), und eine, die ihn dort nicht trifft, färbt
`make test` rot — gemessen am vendored Baum, nicht an der Fixture. `NeutralizeRoadmap` trifft ihren
Marker am Pin nicht und entfällt.

**Lage** (Arbeitsbaum dieses Plans, keine Erwartungswerte):

```sh
T=.harness/baseline/v6.16.0/templates
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

- [ ] `NeutralizeRoadmap`, `roadmapDoneLink`, ihr Aufruf und die an ihren Wortlaut gebundenen Tests
      und Fixture-Zeilen entfallen; die emittierte Roadmap bleibt gate-sicher (`make full-smoke` EXIT 0).
- [ ] Ein Fall in `make test` liest die Vorlagen des vendored Baums zu `DefaultTag` und verlangt je
      verbleibendem Wortlaut-Marker genau einen Treffer; rot gesehen durch Verfälschen eines Markers in
      `templates.go`, die Meldung nennt Marker und Vorlage.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | Funktion, Konstante und Aufruf entfallen; Doc-Kommentare der zwei übrigen nennen den neuen Fall statt „kein Sensor" |
| `internal/emit/templates_test.go`, Fixture `courseSet()` | update | Roadmap-Wortlaut-Tests entfallen; Marker-Fall gegen den vendored Baum |

## 4. Trigger

**Start** (`next` → `in-progress`): Auftrag des Auftraggebers (Inventur vom 2026-10-07); keine Abhängigkeit.

- `in-progress` → `next`: der Marker-Fall braucht den vendored Baum in einer Stage, die ihn nicht sieht, und der Ausweg sprengt drei Liefer-Punkte.
- `in-progress` → `open`: —

## 5. Closure-Trigger

DoD vollständig, `make gates` und `make full-smoke` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Go-`test`-Stage sieht `.harness/baseline/` nicht; dann trägt ein bats-Fall in `make test` den Marker-Fall — **Ausgang:** bei Closure.

## 7. Closure-Notiz

- (bei Closure)

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (`ALL`, `harness/conventions.md`
§Modus-Deklaration pro Sub-Area); `internal/emit/` führt keine eigene Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/emittierte-neutralisierung-greift-am-vendorten-stand-nicht`
— 1 Beleg (`ls docs/plan/planning/observations/BEO-ALL/emittierte-neutralisierung-greift-am-vendorten-stand-nicht/evidence | wc -l`);
dieser Slice ist ihr Gegenstand, die Closure gibt ihr den Ausgang. `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` — 2 Belege, nicht berührt.

Alle berührten Sub-Areas GF.

