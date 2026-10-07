# Slice slice-hook-festlegungen-ziehen-in-die-spezifikation: Die Festlegungen der Hooks und der nur emittierten Werkzeuge stehen in der Spezifikation

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md).

**Berührte Spec-Stellen:** `spezifikation.md` §1 und §7 *Festlegungen der Harness-Werkzeuge* (§7 entsteht mit `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation`).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---
## 1. Ziel und Abgrenzung

**Ziel:** Nach `grundlagen-referenz-richtung.md` §Spec-Straten am Tag `v6.16.0` (Welle 158) stehen
die Festlegungen — was geprüft wird, wie eine Randform entschieden ist — der Werkzeuge, die der
Vorgänger nicht misst, in `spec/spezifikation.md`: die Hooks unter `.claude/hooks/` und `.githooks/`
samt ihren emittierten Fassungen sowie die nur emittierten `selbstpruefung.sh` und `span-emit.sh`.
Ihre Köpfe tragen statt der Festlegung einen Rang-Zeiger.

**Lage** (Arbeitsbaum dieses Plans, keine Erwartungswerte):

```sh
ls .claude/hooks/*.sh .githooks/* | wc -l
for f in internal/emit/templates/enforce/*.sh; do [ -f harness/tools/$(basename $f) ] || echo $f; done   # 5 Dateien
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- `harness/tools/*.sh` und `harness/sensors/*.md` samt ihren emittierten Zwillingen — *Folge-Slice
  rückwärts:* der Vorgänger `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation` misst sie (Lage dort).
- Testköpfe und Mutations-Fälle — *Bestand bleibt stehen:* sie tragen die Deckung, und die lebt beim Werkzeug.
- `Accepted`-ADRs mit `Schärft: —` — *Bestand bleibt stehen:* `AGENTS.md` §3.4.
- Die Form des Rang-Zeigers in der emittierten Fassung — *anderer Vorgang einer anderen Rolle:* er
  zeigt auf eine Spezifikation, die im Ziel nicht liegt; das Verdikt setzt der Architect (§6), dieser
  Slice setzt es um.

## 2. Definition of Done

- [ ] Inventur je Hook- und nur emittiertem Skriptkopf: Festlegung getrennt von Deckung, als Tabelle in §3.
- [ ] `spec/spezifikation.md` trägt jede Festlegung als Verfeinerung in §1 oder als Zeile in §7; `make docs-check` grün.
- [ ] Die Köpfe (Dogfood und `internal/emit/templates/enforce/`) tragen die Festlegung nicht mehr, sondern
      den Rang-Zeiger in der Form des Architect-Verdikts; die Kopplungstests der emittierten Köpfe sind grün.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §1/§7 | update | Festlegungen der Hooks und nur emittierten Werkzeuge |
| `.claude/hooks/*.sh`, `.githooks/*` | update | Kopf: Rang-Zeiger statt Festlegung |
| `internal/emit/templates/enforce/{pretooluse-command-guard,stop-require-gates,span-emit,commit-msg-hook,selbstpruefung}.sh` | update | dito, emittierte Fassung |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation` liegt in
`done/`, und das Architect-Verdikt zur Zeiger-Form im emittierten Kopf liegt vor.

- `in-progress` → `next`: die Inventur ergibt mehr, als eine Review-Sitzung prüft — dann je Hook-Familie schneiden.
- `in-progress` → `open`: das Architect-Verdikt bleibt aus.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Ein Rang-Zeiger im emittierten Kopf zeigt auf eine Spezifikation, die im Ziel nicht liegt — **Ausgang:** bei Closure (Übergabe an den Architect vor dem Start).
- Emittierte Köpfe sind über Zitate an Tests in `internal/emit/` gekoppelt — **Ausgang:** bei Closure.

## 7. Closure-Notiz

- (bei Closure)

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`ALL`); `harness/tools/` (`TOOLS`) und
`.codex/` (`CODEX`) liegen außerhalb des Plans (§3).

**Vorgelagert — offene Beobachtungen sichten:** nächstliegend `BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor` — 1 Beleg (`ls docs/plan/planning/observations/BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/evidence | wc -l`); der Slice verlegt Festlegungen in die Spec und kann diese Klasse berühren — die Closure prüft, ob er einen Beleg trägt. Die übrigen Treffer von `grep -liE 'Skriptkopf|spezifikation'` über die `observation.md` betreffen andere Gegenstände.

Alle berührten Sub-Areas GF.

