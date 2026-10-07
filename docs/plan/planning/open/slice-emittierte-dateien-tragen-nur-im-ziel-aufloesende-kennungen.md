# Slice slice-emittierte-dateien-tragen-nur-im-ziel-aufloesende-kennungen: Emittierte Dateien tragen nur Kennungen, die im Ziel auflösen, und ein Wächter hält die Menge

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

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-057`](../../../../harness/conventions.md#mr-057), [`MR-059`](../../../../harness/conventions.md#mr-059).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** —

**Autor:** Planner (Gruppierungs-Durchgang, `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3). **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Kein emittierter Kommentar und keine emittierte Meldung trägt eine Kennung (`ADR-NNNN`,
`LH-XX-NN`, `MR-NNN` mit Ziffern), die im Ziel nicht auflöst; die Zusage steht in Worten, die Meldung
nennt den Satz, nach dem der Anwender handelt — und ein Go-Test in `internal/emit/` hält die
Eigenschaft über die reale Emission.

**Übernimmt:** `slice-emittierte-traeger-dateien-tragen-keine-werkzeug-kennung`,
`slice-emittierte-dateien-tragen-keine-nicht-aufloesende-kennung`. Geteilte Ursache: dieselbe
Fundmenge unter demselben Kommando; der Schnitt in Träger-Familie und Rest erzwang eine Reihenfolge
(der Wächter durfte erst nach dem Träger-Slice grün starten), die hier entfällt.

**Lage** (keine Erwartungswerte):
`git grep -cE '\b(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3})\b' -- 'internal/emit/templates' ':!*_test.go'`
und dasselbe Muster über die Go-Strings in `internal/emit/*.go`. Zwei Zeilen sind funktionale
Nutzlast — der Default-Commit-Text in `selbstpruefung.sh` und `selbstpruefung.mk` muss ein
Kennungs-Muster des Ziels treffen — und bleiben als namentliche Ausnahme.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kennungen, die das Ziel selbst führt** (Platzhalter-Form, emittierte Register). *Bestand bleibt:*
  sie lösen im Ziel auf.
- **Prosa-Verweise ohne Ziffernform** und die Frage, ob ein Ersatz-Wortlaut die Zusage trägt.
  *Anderer Vorgang:* Urteil des Reviews, kein Sensor.
- **Dogfood-Skripte und Quell-Kommentare des Werkzeugs.** *Anderer Vorgang:* Dogfood-Ebene
  ([`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1).
- **Zweige, die der Test nicht fährt** (nicht gesetzte Flag-Kombinationen). *Bestand bleibt:* benannte
  Lücke.

## 2. Definition of Done

- [ ] **1 — Wortlaut statt Kennung:** die Kommentare und Meldungen aller emittierten Dateien
      (Träger-Familie `traeger-fetch.sh`/`traeger.mk` und die übrigen) tragen keine Kennung außer den
      zwei Nutzlast-Zeilen; Tests, die eine Meldung zitieren (`grep -rn '<präfix>:' internal test`),
      ziehen mit und halten die Aussage statt der Kennung.
- [ ] **2 — Wächter:** ein Go-Test in `internal/emit/` emittiert jede Lauf-Variante (Sprache,
      `--arch`, mit/ohne Erfassung) in ein Temp-Verzeichnis und vergleicht die Fundmenge mit der
      namentlichen Liste *Datei → Kennungs-Menge* auf Gleichheit in beide Richtungen, über die
      **reale** Emission. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6), beide
      Richtungen: eine erfundene Kennung in einer Vorlage → rot mit Dateiname; eine Ausnahme aus der
      Liste gestrichen → rot. Ein Fall in `test/mutations/` führt die erste Mutation (`sed`-Anker gegen
      den Quell-Bestand, [`MR-071`](../../../../harness/conventions.md#mr-071)).
- [ ] `make gates` grün; `make mutate` für den neuen Fall ohne Befund.
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
| `internal/emit/templates/**`, `internal/emit/*.go` (Meldungs-Strings) | update | Liefer-Punkt 1 |
| Tests, die eine geänderte Meldung zitieren | update | Liefer-Punkt 1 |
| `internal/emit/*_test.go` (neuer Wächter), `test/mutations/` | neu | Liefer-Punkt 2 — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: der Meldungs-Nachzug zieht mehr Tests nach, als eine Review-Sitzung trägt —
  dann zuerst Liefer-Punkt 1 je Datei-Familie schneiden, der Wächter folgt.
- `in-progress` → `open`: eine Meldung braucht die Kennung als Nutzlast über die zwei bekannten hinaus
  — Übergabe an den Architect, ob die Ausnahme-Menge wächst.

## 5. Closure-Trigger

1. `make gates` grün, der Mutations-Fall als gebunden gemeldet.
2. Die Fundmenge des Wächters ist gleich der Ausnahme-Liste (zwei Nutzlast-Zeilen), gelesen in §7.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Eine Meldung verliert mit der Kennung die einzige Fundstelle für den Anwender.** — **Ausgang:**
  offen bis zur Closure.
- **Eine Lauf-Variante emittiert eine Datei, die der Test nicht fährt.** — **Ausgang:** offen bis zur
  Closure.
- **Der Ersatz-Wortlaut trägt die Zusage nicht.** — **Ausgang:** offen bis zur Closure (Urteil des
  Reviews).

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (`internal/emit/`, `test/`); `TOOLS` und
`CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert) — benachbarte
Klasse, nicht dieselbe: dort reicht die Zusage weiter als die Wirkung, hier zeigt die Adresse ins Leere.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

