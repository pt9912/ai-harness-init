# Slice slice-archive-welle-altbestand-hat-einen-schreibenden-pfad: `archive-welle altbestand` schreibt das Sammel-Archiv

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle

**Bezug:** [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (Festlegung 2 bis 5), [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md), [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md). Auslöser: Change Request des Auftraggebers aus seinem Konsumenten-Repo — nach [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) / [`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline) die Nutzer-Entscheidung vor diesem Slice.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-05.

---

## 1. Ziel und Abgrenzung

**Ziel:** `ai-harness-init archive-welle altbestand` (ohne `--vorschau`) archiviert den wellenlosen Altbestand als `archiv.zip` im Verzeichnis `done/altbestand/` — heute endet `--vorschau altbestand` mit Exit 3 und `[kein-schreib-pfad]`, und ohne Sammel-Archiv sperrt `[untergrenze]` jede Wellen-Archivierung.

**Reihenfolge:** Dieser Slice zuerst; `archive-slice` ([`ADR-0077`](../../adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md), `Proposed`) danach, weil dessen Einsammel-Regel den Altbestand-Lauf voraussetzt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Kein Eingriff in den Welle-Pfad — Vorschau und Lauf für Welle-Kennungen bleiben unverändert (Schicht-Abgrenzung: der Slice hängt an der Betriebsart des Schlüssels, nicht am Einsammeln einer Welle).
- Der `haenger`-Ausgang selbst — ob der Verweis-Nachzug in eingefrorene Artefakte schreiben darf, ist die Norm-Frage aus [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Folgepflicht 2 und [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md); der Lauf behält die Sperre (Festlegung 4), er löst sie nicht.
- Der Prüfbereich der `closure`-Fähigkeit des Doku-Gates ([`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Folgepflicht 3) — liegt beim archivierenden Repo und ist ein anderer Vorgang (Arbeit am Gate, nicht am Werkzeug).
- Der Einzel-Archiv-Weg für neue wellenlose Slices (`archive-slice`, [`ADR-0077`](../../adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md) ist `Proposed`) — eigener, nachfolgender Vorgang; ohne angenommene ADR keine Adresse.
- Version, Tag und Release-Notiz (F4) — Release-Schnitt nach den Regeln des Trägers, eigener Vorgang.

**Fragen des Änderungswunsches — vom Auftraggeber am 2026-10-05 wie vorgeschlagen bestätigt:**

- **F1:** ein Plan `altbestand*.md` in `done/` sperrt den Lauf fail-closed mit eigener Sperre, statt ignoriert zu werden.
- **F2:** `Geschlossen:` im Stub bleibt der Leerwert `—`; ein Welle-Datum gibt es für den Schlüssel nicht.
- **F3:** die Commit-Nachricht nennt [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md). Gemessen: `internal/archive/anwenden.go` bildet heute `archive-welle: <welle>  Zeitdokumente nach …` und `archive-welle: <welle>  Archiv, Stubs und Verweis-Nachzug …` ohne Kennung; `altbestand` trifft kein Muster der Traceability-Menge, ein `commit-msg`-Träger im Zielrepo wiese den Commit ab (`harness/README.md` §Traceability). Der Vorschlag gilt für die Nachrichten des Schlüssels `altbestand`; ob auch die der Welle-Kennungen (Eingriff in den Welle-Pfad) folgen, bleibt dem Auftraggeber.
- **F4:** Release-Schnitt danach, nicht Teil (siehe oben).

## 2. Definition of Done

Liefer-Punkte:

- [ ] **L1 — Lauf.** `archive-welle altbestand` sammelt, packt, stubt, zieht Verweise nach und committet in zwei Commits.
  - (1) Gleiche Menge wie die Vorschau: Zahl „wellenlos" aus `.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand` = `ls docs/plan/planning/done/altbestand/*.md | wc -l` nach dem Lauf; „Review-Reports" der Vorschau = Review-Reports im Archiv (`unzip -l docs/plan/planning/done/altbestand/archiv.zip | grep -c 'reviews/'`, Muster am Archiv-Layout prüfen).
  - (2) `unzip -l docs/plan/planning/done/altbestand/archiv.zip` listet genau die wellenlosen Slices (unter `done/altbestand/`) und ihre Review-Reports; an der Stelle jedes Slice liegt ein gekürzter Stub (`Welle: ohne Welle`, `Archiviert mit: altbestand`, Archiv-Zeiger, keine Abschnittsüberschrift); Review-Reports ohne Stub entfernt; Verweise nachgezogen; Welle-Plan, Ergebnisnotiz, Welle-Mitglieder und fremde Slices bleiben flach (`git status --porcelain` und `ls docs/plan/planning/done/*.md` vor/nach).
  - (3) Zwei getrennte Commits — der Move-Commit ist ein reiner Rename (`git show --numstat --format= -M HEAD~1` gibt `0 0`); `git status --porcelain` danach leer.
- [ ] **L2 — Sperren.** Der Lauf bricht mit Exit 3 und schreibt nichts, wenn die Vorprüfung sperrt.
  - (4) Ein zweiter `archive-welle altbestand` weist ab: Exit 3, `[archiviert]`, `git status --porcelain` leer, `git rev-parse HEAD` unverändert.
  - (5) `[haenger]` bleibt Sperre: bei einem eingehenden Verweis auf einen verschwindenden Review-Report Exit 3, nichts geschrieben — derselbe Zahn wie Mutationsfall [310](../../../../test/mutations/310-archive-welle-go-altbestand-hebt-haenger-mit-auf.sh) für die Vorschau.
  - F1 (Plan `altbestand*.md` in `done/`) nur, wenn der Auftraggeber sie bestätigt; sonst entfällt der Punkt.
- [ ] **L3 — Test, Mutationsfall, Dokumentation.** Go-Tests über synthetischen Baum und Git-Mitschreiber für L1/L2; mindestens ein neuer Fall in `test/mutations/`; [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) §Grenze Punkt 4, 6, 7 und §Sperren beschreiben den Ist-Stand (`kein-schreib-pfad` entfällt als Sperre, sobald der Pfad schreibt).
  - (6) Nach dem Lauf meldet `archive-welle --vorschau <welle-id>` kein `[untergrenze]` mehr (am Baum nach dem Lauf; ohne Docker-E2E nur am synthetischen Baum fahrbar, siehe Rot-Belege).

Rot-Belege (AGENTS.md §3.6), je an der realen Quelle in `internal/archive/`; fahrbar ohne Docker-E2E sind alle über `make test` (Go-Tests, synthetischer Baum) und `make mutate` mit `MUTATE_CASES`:

- `haenger` im schreibenden Lauf abschalten (die Bedingung aus Fall 310 in der Stelle, die `Anwenden` aufruft) — der Test aus L2 (5) muss mit der Meldung zu `haenger` rot werden, nicht an einer anderen Sperre.
- Die `archiviert`-Sperre im Lauf abschalten — der zweite Lauf aus (4) muss rot werden, weil er ein zweites Archiv schreibt.
- Die Einsammel-Menge des Laufs von der der Vorschau trennen (Lauf nimmt z. B. nur die Hälfte) — Test (1) muss rot werden.
- Stub-Form: die Zeile `Archiviert mit:` im Stub weglassen — Test aus (2) muss rot werden.
- Nicht ohne Docker-E2E fahrbar: der Lauf am realen Repo-Bestand (57 wellenlose Slices; die Zahl liefert `--vorschau altbestand`, kein Erwartungswert) — er wird erst durch den Vollzug nach Ausgang der Norm-Frage beobachtbar, weil `haenger` ihn bis dahin sperrt. Diese Lücke wird in der Closure benannt, nicht durch den Fixture-Erfolg verdeckt.

Gate-Läufe und Closure-Pflichten:

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Doku-Update: [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) (L3).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung angefallen" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen, von der nächsten Welle-Closure auch für diesen wellenlosen Slice.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/archive/anwenden.go`, `collect.go`, `vorschau.go` | update | `Anwenden` verlangt heute genau einen Welle-Plan; unter `AltbestandSchluessel` entfällt das, Umzüge sind die wellenlosen Slices, Ziel `done/altbestand/`; Sperren `haenger` und `archiviert` bleiben, `kein-schreib-pfad` entfällt (L1, L2) |
| `cmd/ai-harness-init/archive_welle.go` | update | Dispatch lässt den Schlüssel ohne `--vorschau` durch; Commit-Nachrichten je F3 |
| `internal/archive/anwenden_test.go`, `vorschau_test.go` | update | Happy/Boundary/Negative nach L1 (1)–(3), L2 (4)–(5), (6) |
| `test/mutations/` | neu | Fälle für `haenger` im Lauf und `archiviert` im Lauf (Muster Fall 310; Anker gegen den Quell-Bestand messen, [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)) |
| `harness/sensors/archive-welle.md` | update | L3 |

## 4. Trigger

**Start** (`next` → `in-progress`): `open → next` durch Priorisierung des Auftraggebers; F1 bis F3 beantwortet oder als Vorschlag übernommen.

**Rückführungen:**

- `in-progress` → `next`: der Lauf braucht eine Änderung am Welle-Pfad (dann ist der Schnitt falsch).
- `in-progress` → `open`: die Norm-Frage zu `haenger` ändert die Sperre und damit den Rot-Beleg (5).

## 5. Closure-Trigger

DoD vollständig, Review-Report ohne blockierenden Befund, Closure-Notiz mit Lerneintrag; `make gates` grün auf dem Stand des Abschlusses.

## 6. Risiken und offene Punkte

- Der reale Lauf über den Bestand bleibt bis zum Ausgang der Norm-Frage hinter `haenger` gesperrt; die Tests laufen nur am synthetischen Baum — **Ausgang:** weiter offen: → [`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md) (Fixture ohne reale Quelle; Beleg bei Closure)
- Commit-Nachricht ohne Kennung bricht am `commit-msg`-Träger eines Zielrepos (F3) — **Ausgang:** weiter offen: → [`BEO-ALL/commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md), falls F3 nicht entschieden wird

## 7. Closure-Notiz

- **Was hat funktioniert:**
- **Was ging anders als geplant:**
- **Steering-Loop-Eintrag:**
- **Beobachtungs-Register (`../observations/`):**
- **Folge-Slices:** `archive-slice` ([`ADR-0077`](../../adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md)), sobald angenommen
- **Risiken aus §6:**
- **Drei Paarungen:**

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`); die Modus-Deklaration führt keine feinere Sub-Area für `internal/archive/`.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`BEO-ALL/commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md) (verkörpert; berührt über F3), [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) und [`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md) (beide verkörpert in [`AGENTS.md`](../../../../AGENTS.md) §3.6; die DoD verlangt Mutationsfälle), [`BEO-ALL/mutations-fall-deckt-den-lauten-statt-den-stillen-pfad`](../observations/BEO-ALL/mutations-fall-deckt-den-lauten-statt-den-stillen-pfad/observation.md) (offen, 2×; der Fall für `archiviert` muss den stillen Pfad treffen, einen zweiten Lauf ohne Fehlermeldung), [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md) (verkörpert in [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md); der Lauf berührt sie über `haenger`). Der Zähler-Stand ist die Zahl der Dateien unter `evidence/` des jeweiligen Eintrags (`ls <eintrag>/evidence | wc -l`); der Slice hebt keinen auf 3×, der offene Eintrag steht bei 2× und erreicht mit diesem Slice 3×, wenn der Fall für `archiviert` den lauten Pfad deckt — dann braucht er nach dem Lese-Schritt einen Ausgang.

alle berührten Sub-Areas GF
