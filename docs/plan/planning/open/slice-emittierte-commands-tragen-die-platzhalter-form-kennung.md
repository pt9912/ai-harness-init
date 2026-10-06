# Slice slice-emittierte-commands-tragen-die-platzhalter-form-kennung: Die emittierten Rollen-Commands schreiben `<Kennung>` statt nummerierter Platzhalter

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Ebene: emittiert, nicht Dogfood.** Gegenstand sind die Rollen-Commands, die das Tool in ein Zielrepo schreibt
(`internal/emit/templates/commands/`).

**Bezug:** [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (Agenten-Workflow-Commands emittieren),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine Zusage ohne Wächter ist behauptet),
[`MR-057`](../../../../harness/conventions.md#mr-057) (Kennungs-Form; die emittierte Ebene entscheidet dieser Slice),
[`MR-059`](../../../../harness/conventions.md#mr-059) (Setzung 4: die emittierte Ebene bleibt außen vor).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung



**Ziel:** Die drei emittierten Rollen-Commands schreiben die Slice- und Welle-Kennung in der Baseline-Form
`<Kennung>` (`seit welle-<Kennung>`, `slice-<Kennung>`), und ein Test färbt rot, sobald ein nummerierter
Platzhalter (`slice-<NNN>`, `welle-<NN>`) in den emittierten Commands steht.

**Start-Trigger (Architect-Verdikt, Übergabe):** Die Form der Platzhalter in der emittierten Ebene ist entschieden —
Vorschlag: `<Kennung>`, wie sie die Baseline setzt (Namen, nicht Nummern:
[`grundlagen-source-precedence.md` §Vergabe](../../../../.harness/baseline/v6.13.0/regelwerk/grundlagen-source-precedence.md#vergabe-woher-die-nächste-kennung-kommt);
Anker-Formen `seit welle-<Kennung>` / `seit slice-<Kennung>`:
[`grundlagen-traceability.md` §Herkunfts-Anker](../../../../.harness/baseline/v6.13.0/regelwerk/grundlagen-traceability.md#herkunfts-anker)).
[`MR-057`](../../../../harness/conventions.md#mr-057) schließt die emittierte Ebene ausdrücklich aus („entscheidet der Slice, der die Tool-Ebene
entscheidet"); dieser Slice ist er, und ob dafür ein Adaptions-Eintrag nötig ist, entscheidet der Architect vor dem Start
(`AGENTS.md` §3.8). Der Plan nimmt die Entscheidung nicht vorweg.

**Lage, nachgemessen** (Kommando und Befund; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025)):

```sh
grep -rnE '(slice|welle)-<(N|NN|NNN)>|<(slice|welle)-(NN|NNN)' internal/emit/templates/commands internal/emit/templates.go
```

- `commands/implement-slice.md`: `seit welle-<NN>` und `seit slice-<NNN>` (Herkunfts-Anker-Aufzählung), `evidence/slice-<NNN>.md`
  (Beleg-Form), `seit slice-<NNN>` statt `seit welle-<NN>` (wellenloser Fall), und die Aufzählung der Commit-Kennung
  (`ADR-NNNN`, `LH-XX-NN`, `MR-NNN`, `slice-N`, Zeile ~48): sie lehrt die Nummernform `slice-N` als gültige Kennung, obwohl die
  Baseline Slice-Kennungen als Namen vergibt ([`grundlagen-source-precedence.md` §Vergabe](../../../../.harness/baseline/v6.13.0/regelwerk/grundlagen-source-precedence.md#vergabe-woher-die-nächste-kennung-kommt)). Gemessen: die Menge steht allein in der Zeile `patterns=` der
  emittierten Prüfung (`grep -n 'patterns=' internal/emit/templates/enforce/commit-msg-traceability.sh`; Dogfood-Fassung
  `harness/tools/commit-msg-traceability.sh` gleich): `(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+)` — ein benannter Slice trifft
  kein Muster. Der Text bleibt wahr, wenn er nur die Klassen nennt, die so aussehen, und für die Menge auf die Zeile `patterns=` verweist
  (so [`harness/README.md`](../../../../harness/README.md) §Traceability). Dieselbe Datei führt an anderer Stelle schon
  `slice-<Kennung>` (`make slice-mv SLICE=slice-<Kennung>`): zwei Formen nebeneinander.
- `commands/close-welle.md`: `seit welle-<NN>` und `seit welle-<NN>` bzw. `seit slice-<NNN>` (Anker-Paarung).
- `commands/plan-welle.md`: `open/slice-<NN>-<titel>.md`.
- `internal/emit/templates.go`: ein Doc-Kommentar, `welle-<NN>-results.md` (Zitat der Kopier-Satz-Form; die vendorte Vorlage
  führt `<welle-id>-results.md`).
- `internal/emit/commands_test.go`: ein Test-Kommentar nennt `slice-<NN>` als erlaubtes Muster.

**Wächter, gemessen:** `TestCommands_NoInternalLeak` fängt nur `slice-[0-9]{2,}` (konkrete Dogfood-Nummern) und vier
interne Begriffe; `slice-<NN>` und `welle-<NN>` tragen keine Ziffern und gehen durch — der Test **erlaubt** die
nummerierte Platzhalter-Form ausdrücklich (sein Kommentar). Kein Test und kein `test/mutations`-Fall liest die emittierten
Commands auf nummerierte Platzhalter (`grep -rlE 'slice-<N|welle-<N' test internal` nennt
`internal/emit/commands_test.go` und den Fall `test/mutations/215-welle-results-als-singleton.sh`, beide nur mit einem Kommentar,
keinen Wächter). Die Lücke ist benannt und wird in DoD (2) geschlossen.


**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Funktionale Muster, die nummerierte Bestandskennungen erkennen:** das Fundmuster von `slice-mv.sh` (Dogfood
  und emittierte Fassung `enforce/slice-mv.sh`), das Muster `slice-[0-9]+` im emittierten `commit-msg-traceability.sh`
  (`patterns=`) und ihre Tests. *(Sie müssen den Bestand erkennen, den ein Ziel mit nummerierten Slices führt; ein Namens-Muster
  fiele auf ihn zurück. Die Frage, welche Formen eine Erkennung trägt, ist ein anderer Vorgang: Dogfood-Seite
  `slice-kennungs-erkennung-traegt-die-zugelassenen-formen`, die emittierte Seite entscheidet der Architect.)*
- **Das Muster `slice-[0-9]+` im emittierten Hook selbst (`patterns=` in `enforce/commit-msg-traceability.sh`):** der Slice ändert
  den Text, der die Menge beschreibt, nicht die Menge. *(Anderer Vorgang, Werkzeug statt Text. Der benannte Hook-Slice
  `slice-werkzeug-commits-tragen-eine-kennung` ([`ADR-0053`](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4) ist
  stillgelegt (`done/`, Gegenstand übernommen von `slice-lifecycle-werkzeuge-tragen-die-kennung`) und liefert nur Kennungen in den Werkzeug-Messages;
  die Erkennung der Formen führt `slice-kennungs-erkennung-traegt-die-zugelassenen-formen` (`open/`), und deren Gegenstand ist die
  Dogfood-Seite. **Übergabe:** die emittierte Prüfung erkennt benannte Slices ([`MR-057`](../../../../harness/conventions.md#mr-057)-Form) erst, wenn ein Slice sie trägt; dafür
  fehlt heute ein Träger — der Architect benennt ihn mit dem Verdikt aus dem Start-Trigger.)*
- **Andere Platzhalter-Klassen:** `MR-<NNN>`, `CO-<NNN>`, `ADR-<NNNN>`, `LH-XX-NN`. *(Ihre Form setzen
  [`MR-000`](../../../../harness/conventions.md#mr-000) und [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md); sie sind keine Slice-/Welle-Kennung.)*
- **`welle-NN-results.md` in `internal/emit/templates.go` (`roadmapDoneLink`) und `<welle-NN-titel>` im Doc-Kommentar zu
  den Platzhalter-Links:** die Konstante ersetzt einen Text der Baseline-Roadmap-Vorlage, der Kommentar zitiert dessen Form.
  Am vendorten Stand führt keine Vorlage `welle-NN-results` mehr (`grep -rn 'welle-NN-results' .harness/baseline/v6.13.0/templates`
  → kein Treffer). Ob die Konstante damit tot ist, ist eine Messung für sich. *(Anderer Vorgang: Arbeit an der Emission, nicht an der
  Platzhalter-Form der Commands.)*
- **Nachzug in bestehende Ziele:** die Commands tragen den ANPASSEN-Marker und werden nur an einem freien Pfad geschrieben
  (skip-if-present); ein Ziel mit eigener Fassung behält sie. *(Bestand bleibt stehen — Eigentum des Adopters.)*
- **Dogfood-Commands unter `.claude/commands/`:** sie führen die Form schon (`slice-<Kennung>`); der Bestand bleibt.

## 2. Definition of Done

- [ ] **(1) Die emittierten Commands und die Quell-Kommentare tragen `<Kennung>`.** Die Stellen aus §1 in
      `commands/implement-slice.md`, `close-welle.md`, `plan-welle.md`, im Doc-Kommentar `internal/emit/templates.go` und im
      Test-Kommentar `commands_test.go` sagen `seit welle-<Kennung>`, `seit slice-<Kennung>`, `evidence/slice-<Kennung>.md`,
      `open/slice-<Kennung>.md`; die Aufzählung der Commit-Kennung in `implement-slice.md` nennt `ADR-NNNN`, `LH-XX-NN`, `MR-NNN` und
      verweist für die vollständige Menge auf die Zeile `patterns=` von `tools/harness/commit-msg-traceability.sh`, ohne `slice-N`
      zu nennen; die Stellen aus der Abgrenzung bleiben. *Bricht die Zusage, wenn:* eine Stelle bleibt
      nummeriert (Test aus Punkt 2 rot) oder eine funktionale Stelle wird mitgeändert (die Tests der Erkennungs-Muster färben).
- [ ] **(2) Ein Wächter hält die Form und ist rot gesehen.** Ein Test in `internal/emit` liest alle emittierten Commands
      (`emit.CommandPaths()`) und fällt bei `(slice|welle)-<N+>` (nummerierter Platzhalter in spitzen Klammern);
      `MR-<NNN>` ist erlaubt. Derselbe Test fällt bei `slice-N` als Kennung (Wort `slice-N` im Command-Text), damit die Nummernform
      nicht wieder als gültige Kennung gelehrt wird. Ein Fall in `test/mutations/` führt
      je einen nummerierten Platzhalter und `slice-N` in `implement-slice.md` zurück (erwartet der Testname), `sed`-Muster gegen den
      Quell-Bestand gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071)); der Fall fährt die Stelle, die der Aufrufer benutzt
      (`emit.CommandFile`). Der Test hält die Zusage über die **Menge aller Commands**, nicht über die heutigen drei Stellen
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): ein vierter nummerierter Platzhalter färbt ihn. *Bricht die Zusage, wenn:* ein Command
      eine nummerierte Platzhalter-Form führt, oder das Muster die Form `<NN>` mit zwei Ziffern-Platzhaltern nicht mehr trifft.
- [ ] **(3) Der Test `TestCommands_NoInternalLeak` sagt nichts Gegenteiliges.** Sein Kommentar nennt die nummerierte
      Platzhalter-Form nicht mehr als erlaubt, sondern verweist auf den Wächter aus Punkt 2; sein Verhalten (nur konkrete
      Dogfood-Nummern) bleibt.

Standard (zählen nicht): `make gates` grün · `make mutate` für den neuen Fall ohne Befund · Review-Report (kein Self-Review) ·
Closure-Notiz mit Lerneintrag · Register fortgeschrieben · Risiko-Ausgänge · drei Paarungen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/commands/implement-slice.md` | update | DoD (1): vier Stellen plus die Commit-Kennung-Aufzählung |
| `internal/emit/templates/commands/close-welle.md` | update | DoD (1): zwei Stellen |
| `internal/emit/templates/commands/plan-welle.md` | update | DoD (1): eine Stelle |
| `internal/emit/templates.go` | update (Kommentar) | DoD (1) |
| `internal/emit/commands_test.go` | update | DoD (2): neuer Test; DoD (3): Kommentar von `NoInternalLeak` |
| `test/mutations/` | neu | DoD (2): Fall am Wächter |

Zwei Schichten: Emissions-Vorlagen und ihre Tests.

## 4. Trigger

**Start** (`next` → `in-progress`): Der Architect hat die Form der Platzhalter in der emittierten Ebene entschieden (§1).

**Rückführungen:**

- `in-progress` → `next`: Die Messung findet weitere nummerierte Platzhalter außerhalb von Commands und Go-Kommentaren
  (etwa in emittierten Vorlagen) — dann nach Fundort schneiden.
- `in-progress` → `open`: Der Architect verwirft `<Kennung>` für die emittierte Ebene.

## 5. Closure-Trigger

Zwei beobachtbare Kriterien: `make gates` grün; der neue Test und sein Mutations-Fall sind einmal rot gesehen
(`make mutate` für den Fall ohne Befund). Dazu ein Lerneintrag in einer der drei Formen.

## 6. Risiken und offene Punkte

- Ein Adopter hat die alte Form in seiner adaptierten Command-Fassung. — **Ausgang:** entfallen: skip-if-present, sein
  Bestand bleibt unberührt; der Lauf schreibt nur an freie Pfade.
- Das Muster des Wächters trifft eine andere Platzhalter-Klasse. — **Ausgang:**
  entfallen: das Muster verlangt spitze Klammern und das Präfix `slice-`/`welle-`; `MR-<NNN>` geht durch
  und stehen als Gegenprobe im Test.
- Die Form `<Kennung>` wird vom Architect anders entschieden. — **Ausgang:** entfallen: der Start-Trigger hält den Plan in
  `open/`, bis die Entscheidung steht; ein anderes Ergebnis ändert die Zielform, nicht den Wächter.

## 7. Closure-Notiz

*Wird bei der Closure gefüllt (Planner, `AGENTS.md` §3.10).*

- **Was hat funktioniert:**
- **Was ging anders als geplant:**
- **Steering-Loop-Eintrag:**
- **Beobachtungs-Register (`../observations/`):**
- **Folge-Slices:**
- **Risiken aus §6:**
- **Drei Paarungen:**

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, `ALL`): Emissions-Vorlagen und ihre Tests. Das
Inklusionskriterium ist erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** das Register durchgegangen, ein naher Treffer:
[`BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt`](../observations/BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt/observation.md)
(Zähler-Stand 1, `ls docs/plan/planning/observations/BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt/evidence | wc -l`
→ 1, gemergter Stand 2026-10-06) — dieselbe Kennungs-Form, aber eingefrorene Artefakte; dieser Slice ändert nur lebende
Vorlagen und berührt ihn nicht. Die Beobachtung
[`BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md)
beschreibt die Gegenrichtung (die Emission fährt eine Form, die der Dogfood nicht fährt); hier fährt die Emission die
ältere Form. Ob das dieselbe Beobachtung ist, urteilt die Closure.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — [`MR-057`](../../../../harness/conventions.md#mr-057) und [`MR-059`](../../../../harness/conventions.md#mr-059) benennen die emittierte Ebene als offen; `TestCommands_*` binden die Commands.
- **Phase-Reife:** Phase 5.
- **Evidenz-/Diskrepanz-Risiko:** niedrig; die Fundstellen sind gemessen (§1).
- **Reconciliation-Aufwand:** keiner.
