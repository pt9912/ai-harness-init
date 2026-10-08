# Slice slice-baseline-wird-je-release-adoptiert: Die Baseline wird je Release adoptiert

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt
nur durch `git mv` (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** ohne Welle — reaktiv, ein Eintrag des Beobachtungs-Registers über der Schwelle; keine
Closure-Bedingung jenseits der DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-10-08.

---

## 1. Ziel und Abgrenzung

**Ziel:** Jede Version, die `make baseline-freshness` meldet, wird als eigener Sprung adoptiert,
statt Sprünge zu sammeln — die Kosten einer Re-Baseline folgen dem Prozess, nicht der Sprungweite.

**Ausdrücklich NICHT in diesem Slice:**

- Ein Sprung selbst — anderer Vorgang; je gemeldete Version entsteht ein eigener Sprung-Slice.
- Der Norm-Text des MR-Eintrags — schreibt der Architect (`AGENTS.md` §3.8); dieser Slice trägt
  Auslöser und Übergabe.

## 2. Definition of Done

- [ ] Der Adoptions-Rhythmus *je gemeldete Version ein Sprung* steht als MR-Eintrag im
      Adaptions-Block (Architect-Commit).
- [ ] Der Auslöser ist benannt: wo die Meldung von `make baseline-freshness` ankommt und welcher
      Anweisungssatz daraus den Sprung-Slice schneidet.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder in §7 notiert, dass keine Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/conventions/MR-<NNN>-…md` + Index | neu | Rhythmus als Setzung (Architect) |
| `.claude/commands/plan-welle.md` | update | Meldung → Sprung-Slice (Planner, [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) |

## 4. Trigger

**Start** (`next` → `in-progress`): die Entscheidung des Auftraggebers *„je Release ein Sprung"* liegt
vor.

- `in-progress` → `next`: der Auslöser braucht ein neues Werkzeug statt einer Anweisung.
- `in-progress` → `open`: der Auftraggeber lehnt ab — der Ausgang der Beobachtung wird dann im
  nächsten Architect-Zug neu entschieden, nicht gestrichen.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die nächtliche Meldung bleibt ungelesen, weil kein Lauf sie konsumiert — **Ausgang:** offen bis
  Closure.

## 7. Closure-Notiz

**Gegenstand:** entfallen: Auftraggeber-Entscheidung vom 2026-10-08; ein Adoptions-Rhythmus *je gemeldete Version ein Sprung* wird nicht als Adaptions-Eintrag gesetzt, ein Sprung wird je Anlass geschnitten.

Stillgelegt ohne Lieferung (Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer übernimmt) im Bestands-Lese-Schritt der Welle-Closure `welle-emittiertes-doc-gate`, Auftraggeber-Entscheidung vom 2026-10-08. Die Liefer-Punkte der DoD bleiben leer.

- **Risiko-Ausgänge (§6):** jedes Risiko ohne vorab gesetzten Ausgang — *entfallen*: mit dem Gegenstand entfällt die Arbeit, an der es hing; vorab gesetzte Ausgänge gelten unverändert.
- **Beobachtungs-Register:** `BEO-ALL/geplanter-slice-wird-nie-gearbeitet` — Beleg `welle-emittiertes-doc-gate`, eine Gelegenheit für alle Stilllegungen dieses Lese-Schritts.
- **Paarungen:** von der Welle-Closure `welle-emittiertes-doc-gate` geprüft, Ergebnis in deren Ergebnisnotiz.

— bei Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), Kürzel `ALL`.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/baseline-sprungweite-treibt-kosten` über
der Schwelle, Stand `geplant` auf diesen Slice; Nachbar
`BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht` (geplant auf `slice-162`).

Alle berührten Sub-Areas GF.

