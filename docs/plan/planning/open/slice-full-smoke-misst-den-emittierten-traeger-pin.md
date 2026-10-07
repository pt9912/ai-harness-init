# Slice slice-full-smoke-misst-den-emittierten-traeger-pin: `full-smoke` misst den emittierten Träger-Pin unter Adopter-Bedingung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (Festlegung 1). Anlass: Review-Finding F4 zu
`slice-full-smoke-erkennt-unveroeffentlichtes-artefakt` ([Review](../../../reviews/2026-10-07-404-review.md)).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Stufe `make traeger-fetch im frischen Klon` liest `TRAEGER_TAG` aus dem emittierten
`traeger.mk` des Ziels statt aus dem Dogfood-Export; ein falscher Variablenname im Fragment färbt
einen Wächter rot, und Stufe 5 der E2E-Sicht nennt, was sie misst.

**Lage** (keine Erwartungswerte): `grep -n 'export TRAEGER_TAG' Makefile` zeigt den Export, den
`make full-smoke` vererbt; `grep -n 'TRAEGER_TAG' internal/emit/templates/enforce/traeger.mk` die
`?=`-Zuweisung, die ihm nachgibt; `pin_wert` in `test/traeger-fetch.bats` greift per Präfix
(`TRAEGER_TAGX ?= v0.5.0` liefert `v0.5.0`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Kopplung des Pin-Werts.** *Bestand bleibt:* der Fall `pin-kopplung` hält beide Stellen in
  `make gates` gegen das Literal.
- **Das Rennen gegen die Publikation.** *Folge-Slice:* `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`.
- **Andere geerbte Dogfood-Exporte.** *Anderer Vorgang:* gemessen wird hier nur `TRAEGER_TAG`; ein
  weiterer Fund geht ins Register.

## 2. Definition of Done

- [ ] **1 — Adopter-Bedingung:** `harness/tools/full-smoke.sh` ruft `traeger-fetch` im Klon ohne
      geerbten `TRAEGER_TAG`. **Rot gesehen** an der realen Quelle: ein Fall in `test/mutations/`
      (`verify: full-smoke`) verfälscht den Variablennamen in `traeger.mk`; `make mutate` meldet ihn
      gebunden, die FEHLER-Zeile der Stufe gelesen.
- [ ] **2 — Namens-Bindung:** `pin_wert` bindet den Namen exakt; ein Fall (`verify: test-bats`)
      mit `TRAEGER_TAGX` färbt `pin-kopplung` rot.
- [ ] **3 — E2E-Sicht:** die Stufen-Deklaration nennt, woher der Pin im Lauf kommt;
      `make e2e-abdeckung` zieht [`docs/user/e2e-abdeckung.md`](../../../user/e2e-abdeckung.md) nach.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke.sh` | update | Stufe ohne geerbten Pin, Stufen-Deklaration (Liefer-Punkte 1, 3) |
| `test/traeger-fetch.bats` | update | `pin_wert` mit exaktem Namen (Liefer-Punkt 2) |
| `test/mutations/` | neu | Namens-Fälschung im Fragment (`full-smoke`), `TRAEGER_TAGX` (`test-bats`) — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: eine andere Stufe braucht den geerbten Export, und das Entkoppeln zieht sie
  mit — dann die Stufen einzeln schneiden.
- `in-progress` → `open`: die Adopter-Bedingung verlangt Netz an einer weiteren Stelle — Übergabe an
  den Architect.

## 5. Closure-Trigger

1. `make gates` und `make full-smoke` grün, beide Mutations-Fälle als gebunden gemeldet.
2. Die FEHLER-Zeile des Namens-Falls gelesen (§7).

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Weitere Stufen erben Dogfood-Exporte** — dieselbe Klasse an anderem Pin. — **Ausgang:** offen bis
  zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `TOOLS` (`harness/tools/full-smoke.sh`) und `*`
(`test/`, `docs/user/`); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert; Beleg aus dem
Anlass-Slice ergänzt) — Liefer-Punkt 3 trägt die Teilmessung.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

