# Slice slice-rollen-grenze-eines-commits-hat-ein-werkzeug: Ein Werkzeug hält die Abschnitte eines Commits gegen die Rolle im Subject

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — keine Closure-Bedingung jenseits der eigenen DoD.

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.10 und §3.8 (*„Ein Wächter existiert nicht"*),
[ADR-0015](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) · Schärfung, kein ADR
([`AGENTS.md`](../../../../AGENTS.md) §3.5). Auslöser: Auftraggeber-Entscheidung vom 2026-10-09
(Option A) auf Verdikt `2026-10-09-welle-kotlin-skelett-architect-verdikt` B-4.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein Werkzeug (kein Gate) liest je Commit einer Slice-Range die Rolle aus `^Rolle <R>:` im
Subject, ordnet jeden Hunk eines Slice-Plans seinem `## N.`-Abschnitt zu und meldet (a)
Implementer-Commits mit Hunks außerhalb von §3 oder mit Pfaden unter `docs/plan/planning/observations/`,
`harness/conventions*`, `docs/plan/adr/`, `.harness/skills/`, `AGENTS.md`; (b) Architect- oder
Reviewer-Commits mit Hunks in §2 (DoD), §5, §6, §7 oder mit Register-Dateien.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Aufnahme in `make gates` — die Range ist eine Eigenschaft des Slice, nicht des Baums; Bindepunkt
  ist die Slice-Closure (Verdikt B-4).
- Inhalts-Übergriffe im eigenen Abschnitt (der Kotlin-Beleg: eine §3-Zeile mit falschem Inhalt) —
  der Abschnitt ist dafür das falsche Maß; Grenze, kein Folge-Slice.
- Commits ohne `Rolle`-Präfix und die Prüfung, ob die deklarierte Rolle stimmt — die Rolle im Subject
  ist Deklaration; das Werkzeug benennt diese Grenze.
- Der Text in `AGENTS.md` — schreibt der Architect in eigenem Commit (§3.8); hier steht nur die
  Übergabe.

## 2. Definition of Done

- [ ] Das Werkzeug liegt vor, Ziel in `harness/README.md` §Werkzeuge mit `kein Gate`; über der realen
      Quelle rot gesehen: die Commits der 9 fassbaren Belege von
      `BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext` werden gemeldet, die
      Arbeits-Commits von `slice-kotlin-freshness` nicht.
- [ ] Mutations-Fall in `test/mutations/`, der eine Melde-Regel aufhebt und den Wächter-Test rot färbt.
- [ ] Übergabe-Artefakt an den Architect: die Sätze *„Ein Wächter existiert nicht"* in `AGENTS.md`
      §3.10 (und, soweit gedeckt, §3.8) nachziehen; Architect-Commit liegt vor. Optional (Verdikt
      B-1): beratende Liste *Datei nicht in §3* über derselben Commit-Menge.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Werkzeug unter `harness/tools/` + `Makefile`-Ziel (`RANGE=<claim>..HEAD`) | neu | Melde-Regeln (a)/(b) aus §1 |
| bats-Test unter `test/` | neu | Happy (Arbeits-Commits schweigen) · Negative (fassbare Belege gemeldet) · Grenze (Commit ohne `Rolle`-Präfix ungesehen, benannt) |
| `test/mutations/` | neu | ein Fall je Melde-Richtung (DoD 2) |
| `harness/README.md` §Werkzeuge, `harness/sensors/<ziel>.md` | update / neu | Zeile `kein Gate`, Bindepunkt Slice-Closure, Grenze |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Auftraggeber; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß): die Abschnitts-Zuordnung eines Hunks braucht mehr als die
  `## N.`-Überschriften (etwa Abschnitte jenseits der Vorlage) und trägt einen eigenen Liefer-Punkt.
- `in-progress` → `open` (blockiert): die Arbeits-Commits eines geschlossenen Slice werden gemeldet
  und die Regel lässt sich nicht ohne Heuristik enger fassen.

## 5. Closure-Trigger

DoD vollständig, die rote Messung über den realen Beleg-Commits in §7 genannt, Architect-Commit zu
§3.10 liegt vor, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Ein Arbeits-Commit eines Slice berührt legitim einen fremden Abschnitt (etwa §7-Vorbereitung im
  Review-Nachgang) und erzeugt Fehlalarme — **Ausgang:** <bei Closure>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <…>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo, `ALL`) — das Werkzeug liest Commits über
alle Pfade; keine feinere Sub-Area trägt Rollen-Grenzen.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`
(10 Belege, Auslöser, Stand *geplant* mit diesem Slice); `BEO-ALL/plan-abweichung-landet-im-commit-bericht-statt-im-plan`
(7 Belege, akzeptiertes Negativ — die optionale §3-Liste aus DoD 3 berührt ihn beratend).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
