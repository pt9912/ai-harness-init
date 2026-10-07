# Slice slice-ci-wartet-die-publikation-des-gepinnten-releases-ab: Der `ci`-Lauf am Tag-Commit rennt nicht gegen die Publikation des gepinnten Release

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

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (Festlegung 2: laut-Bruch statt stiller Ausweichung). Anlass:
`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` bei 3× (Ausgang *geplant*).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein Tag-Push, dessen Commit den Träger-Pin auf den eigenen Tag zieht, lässt den `ci`-Lauf
nicht mehr vor der Publikation des Release an `make traeger-fetch` im frischen Klon fallen — die
Struktur-Entscheidung (begrenzte Wartezeit des Fetch oder Workflow-Anordnung, die die Publikation vor
den Fetch setzt) ist getroffen und umgesetzt.

**Lage** (keine Erwartungswerte):
`ls docs/plan/planning/observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/evidence/ | wc -l`
zählt die Belege; `ls .github/workflows/` nennt die Workflows, deren Reihenfolge das Rennen trägt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Einordnung des 404 im Log.** *Bestand bleibt:* der Einordner von `full-smoke` ordnet ihn
  LEITUNG zu (`slice-full-smoke-erkennt-unveroeffentlichtes-artefakt`, in `done/`).
- **Ein Ausweichen von `traeger-fetch` auf eine andere Fassung.** *Bestand bleibt:* [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2 verlangt den lauten Bruch; eine Wartezeit ist kein Ausweichen, solange sie endet.
- **Der emittierte Träger-Pin unter Adopter-Bedingung.** *Anderer Vorgang:*
  `slice-full-smoke-misst-den-emittierten-traeger-pin`.

## 2. Definition of Done

- [ ] **1 — Entscheidung:** ein Architect-Verdikt (ADR, wenn eine fail-closed-Grenze sich verschiebt)
      wählt den Träger und nennt die Grenze, ab der der Lauf weiter laut bricht.
- [ ] **2 — Umsetzung:** Workflow bzw. `traeger-fetch` folgen dem Verdikt; `make ci-lint` grün.
      **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6) an der realen Quelle: ein Lauf
      gegen einen nicht veröffentlichten Tag bricht nach der Grenze weiter mit `AUSGANG LEITUNG`.
- [ ] **3 — Doku:** [`docs/user/releasing.md`](../../../user/releasing.md) §Prozedur Schritt 6 im
      Ist-Zustand (Re-Run entfällt oder bleibt, mit Grund).
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
| `.github/workflows/` | update | Anordnung von `ci` und Publikation, falls das Verdikt sie wählt (Liefer-Punkt 2) |
| `harness/tools/traeger-fetch.sh`, `internal/emit/templates/enforce/traeger-fetch.sh` | update | begrenzte Wartezeit, falls das Verdikt sie wählt (Liefer-Punkt 2) |
| `docs/user/releasing.md` | update | Schritt 6 (Liefer-Punkt 3) |

## 4. Trigger

**Start** (`next` → `in-progress`): das Architect-Verdikt aus Liefer-Punkt 1 liegt vor; WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: die Lösung braucht Workflow **und** Fetch zugleich und trägt mehr als eine
  Review-Sitzung — dann je Träger ein Slice.
- `in-progress` → `open`: die Wartezeit verlangt eine Netz-Annahme, die
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) widerspricht — Übergabe an den Architect.

## 5. Closure-Trigger

1. Der `ci`-Lauf am Tag-Commit des nächsten Release-Schnitts ist im ersten Versuch grün (Job-ID in §7).
2. `make gates` grün.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Eine Wartezeit verdeckt einen falsch gesetzten Pin** — der laute Bruch kommt erst nach der
  Grenze. — **Ausgang:** offen bis zur Closure.
- **Der Closure-Beleg hängt an einem Release-Schnitt** — ohne Schnitt bleibt Kriterium 1 aus. —
  **Ausgang:** offen bis zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (`.github/workflows/`, `docs/user/`) und
`TOOLS` (`harness/tools/traeger-fetch.sh`); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` bei 3× — dieser Slice ist sein
Ausgang *geplant*.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

