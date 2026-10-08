# Slice slice-agent-role-traegt-nicht-bekannt: Eine unbekannte Rolle trägt die Kennzeichnung *nicht bekannt*, und die Auswertung liest sie wie die leere

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-erfassungsschicht-im-ziel](../welle-erfassungsschicht-im-ziel.md) — nach
`slice-span-traegt-die-fassung-seiner-erfassungsregel`: der Wechsel `""` → *nicht bekannt* trägt dann
seine Fassung.

**Bezug:**
[`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung),
[`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans),
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) (Festlegung 4 Punkt 3),
[`MR-015`](../../../../harness/conventions.md#mr-015),
[`MR-036`](../../../../harness/conventions.md#mr-036),
[`MR-042`](../../../../harness/conventions.md#mr-042).

**Berührte Spec-Stellen:** `SPEC-010`, `SPEC-011`, `SPEC-012`, `SPEC-014`, `SPEC-043`, `SPEC-044`, `SPEC-055`, `SPEC-056`, `SPEC-087` (`spezifikation.md §5`).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein **unbekannter** Wert trägt die Kennzeichnung *nicht bekannt* samt Quelle statt `""`
oder `[]`, und `make span-report` liest sie wie das leere Rollenfeld des Bestands — nach Lastenheft
0.25.1. Drei Stellen:

1. `agent_role` bei `general-purpose` und im Haupt-Kontext
   ([`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) *Rolle besetzt*,
   *Rolle wird abgeleitet*).
2. `branch` und `commit`, wenn die Ableitung aus dem git-Zustand nicht möglich ist
   ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) *Zweig und
   Stand*; heute `SPEC-014`/`SPEC-056`: leer).
3. `slice`/`requirement` und die Entscheidungs-Achse bei unlesbarer Slice-Datei — heute liefert `references()` dann
   `[]`, das `SPEC-011`/`SPEC-012` als *keiner* lesen
   ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) *Leer heißt
   keiner, unbekannt ist gekennzeichnet*). `[]` bleibt der Wert *keiner*.

Die Auswertung zählt den gekennzeichneten Lauf im Sammelposten, Spans vor und nach der Umstellung
landen im selben Posten (*Lesevorschrift*). `SPEC-043` verliert *(Abweichung 3)*; `SPEC-087` gilt
über die Cache-Zähler hinaus, und `SPEC-055` zählt die Fälle der Kennzeichnung vollständig auf.

```sh
grep -n 'sonst bleibt das Feld leer' spec/spezifikation.md
grep -n 'agent_role\\":\\"$erwartet' harness/tools/full-smoke.sh
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Change Request selbst.** *Anderer Vorgang:* ob [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) geändert wird, entscheidet der
  Auftraggeber ([`MR-015`](../../../../harness/conventions.md#mr-015),
  [`MR-036`](../../../../harness/conventions.md#mr-036)); der Anlass steht in der Closure-Notiz
  ([`MR-042`](../../../../harness/conventions.md#mr-042)). Entschieden in Lastenheft 0.25.0/0.25.1; dieser Slice setzt ihn um.
- **Der Cache-Status.** *Bestand bleibt stehen:* geliefert von
  `slice-span-pflichtfeld-traegt-nicht-bekannt` (`SPEC-024`, `SPEC-087`).

## 2. Definition of Done

- [ ] **1 — Spezifikation:** `SPEC-087` gilt für die drei Stellen aus §1 (Quelle je benannt), `SPEC-043`
      trägt kein *(Abweichung 3)* mehr, `SPEC-010`/`011`/`012`/`014`/`044`/`055`/`056` sind nachgezogen — gemäß dem
      geänderten [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung).
- [ ] **2 — Erfassung und Tests:** ein Span ohne erkennbare Rolle trägt die Kennzeichnung bei
      `agent_role`, einer ohne ableitbaren git-Zustand bei `branch`/`commit`, einer mit unlesbarer Slice-Datei bei den Korrelations-Listen; Feldliste (`span.FieldList`) und `make full-smoke` folgen. **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die Erfassung schreibt `""` — der benannte Test wird
      mit einer Meldung über genau dieses Feld rot; ein Fall in `test/mutations/` hält die Zusage.
- [ ] **3 — Auswertung:** `make span-report` liest die Kennzeichnung wie `""`, keine Rolle
      *nicht bekannt* entsteht. **Rot gesehen:** die Auswertung prüft nur `""` — der Test mit einem
      Span, der die Kennzeichnung trägt, wird rot.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag und dem Anlass der Lastenheft-Änderung
      ([`MR-042`](../../../../harness/conventions.md#mr-042)).
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §5 | update | Liefer-Punkt 1 |
| `internal/span/emit.go` (Rollen-, git- und Bezugs-Ableitung), `internal/span/notknown.go`, `internal/span/fieldlist.go` | update | Liefer-Punkt 2 |
| `internal/span/*_test.go`, `harness/tools/full-smoke.sh` | update | Happy/Negative nach [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) |
| `internal/report/report.go` + Test | update | Liefer-Punkt 3 |
| `test/mutations/<NNN>-…sh` | neu | Mutations-Fälle für Liefer-Punkt 2 und 3 |

## 4. Trigger

**Start** (`open` → `next`): der Auftraggeber hat den Change Request zu
[`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) entschieden — sichtbar als
Eintrag in `spec/lastenheft.md` §7 Historie — **eingetreten** (0.25.0, 0.25.1). Lehnt er ab, geht der Slice `open → done` mit
`Gegenstand: entfallen` und `SPEC-043` behält *(Abweichung 3)*.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: ein weiterer Leser von `agent_role` außer `internal/report` taucht auf.
- `in-progress` → `open`: der geänderte Wortlaut von [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) lässt die Draht-Form aus `SPEC-087`
  nicht zu — Übergabe an den Architect.

## 5. Closure-Trigger

1. `make gates` grün mit den Tests aus Liefer-Punkt 2 und 3; die Mutations-Fälle färben unter
   `make mutate` mit `MUTATE_CASES` ihren Wächter.
2. `grep -c '(Abweichung 3)' spec/spezifikation.md` → **0**, und `make full-smoke` EXIT 0.

## 6. Risiken und offene Punkte

- **Bedeutung eines Span-Felds wechselt ohne Fassungs-Angabe** — `agent_role` wechselt von `""` auf
  die Kennzeichnung; `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` (Register) — Stand 3×, `geplant` auf `slice-span-traegt-die-fassung-seiner-erfassungsregel`, der vor diesem Slice läuft;
  ein weiterer Beleg ist Evidenz. — **Ausgang:** offen bis zur Closure.
- **Die Kennzeichnung wird als Rolle gelesen** — ein Leser außer `internal/report` zählte
  *nicht bekannt* als eigene Rolle. — **Ausgang:** offen bis zur Closure.

- **Der Slice wächst um zwei Ableitungen** (git-Zustand, Bezugs-Fehlerpfad; Lastenheft 0.25.1). Trägt er sie
  nicht in einer Review-Sitzung, Rückführung `in-progress` → `next`, Teilung nach Feld. — **Ausgang:** offen bis zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — `internal/span/`,
`internal/report/` und `spec/` liegen in keiner engeren deklarierten Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet; Treffer
`span-feld-bedeutung-wechselt-ohne-fassungs-angabe` (3×, `geplant` auf den Fassungs-Slice), Zähler
`ls docs/plan/planning/observations/BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/evidence/*.md | wc -l`
(§6). Kein weiterer Treffer zum Erfassungs-Schema.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
