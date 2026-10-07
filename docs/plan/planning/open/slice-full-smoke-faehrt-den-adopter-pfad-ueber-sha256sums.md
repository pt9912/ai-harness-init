# Slice slice-full-smoke-faehrt-den-adopter-pfad-ueber-sha256sums: `full-smoke` fährt den Verifizierungs-Kanal des Adopters über `SHA256SUMS`

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

**Bezug:** [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0058](../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md), [ADR-0059](../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md). Anlass: LOW-1 zu
`slice-full-smoke-misst-den-emittierten-traeger-pin` ([Review](../../reviews/2026-10-07-traeger-pin-review.md)).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** Stufe 5 von `make full-smoke` (`make traeger-fetch im frischen Klon`) läuft ohne die
geerbten `TRAEGER_SHA256_*` des Dogfood-`Makefile`, nimmt damit den Kanal des Adopters (Laden und
Prüfen der `SHA256SUMS` des Release), und ihre Stufen-Deklaration nennt diesen Kanal.

**Lage** (keine Erwartungswerte): `grep -n 'TRAEGER_SHA256' Makefile` zeigt die Exporte;
`grep -n 'quelle=' internal/emit/templates/enforce/traeger-fetch.sh` die zwei Zweige `Pin` und
Manifest; `grep -n 'klon_traeger_fetch' harness/tools/full-smoke.sh` den Aufruf, der heute nur
`TRAEGER_TAG` entfernt. Den Manifest-Kanal fährt bisher allein `test/traeger-fetch.bats` mit Stubs.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Pin-Kanal im Dogfood.** *Bestand bleibt:* `make traeger-fetch` im Dogfood braucht die
  Digest-Pins; entkoppelt wird am Aufruf im Ziel.
- **`TRAEGER_CARRIER` und weitere Exporte.** *Anderer Vorgang:* gemessen wird hier nur der
  Digest-Kanal; ein weiterer Fund geht ins Register (§6).
- **Das Rennen gegen die Publikation.** *Folge-Slice:* `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`.

## 2. Definition of Done

- [ ] **1 — Adopter-Kanal:** Stufe 5 läuft ohne geerbte `TRAEGER_SHA256_*`; der Lauf lädt die
      `SHA256SUMS` des gepinnten Release. **Rot gesehen** an der realen Quelle, ein Fall in
      `test/mutations/` (`verify: full-smoke`), der im emittierten `traeger-fetch.sh` den
      Manifest-Zweig bricht, ist von `make mutate MUTATE_CASES=…` als gebunden gemeldet, die
      FEHLER-Zeile gelesen; Gegenprobe mit geerbten Pins bleibt grün.
- [ ] **2 — Negativ-Fall:** der Fall „nach EINMAL Laden" der Stufe hält den Manifest-Kanal, nicht
      die Pin-Variable.
- [ ] **3 — E2E-Sicht:** die Deklaration von Stufe 5 nennt den Kanal; `make e2e-abdeckung` zieht
      [`docs/user/e2e-abdeckung.md`](../../user/e2e-abdeckung.md) nach.
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
| `harness/tools/full-smoke.sh` | update | `klon_traeger_fetch` ohne Digest-Pins, Negativ-Fall, Deklaration (Liefer-Punkte 1–3) |
| `test/mutations/` | neu | ein Fall am Manifest-Zweig, `verify: full-smoke` — [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | Liefer-Punkt 3 |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: der Negativ-Fall braucht einen eigenen Release-Zustand (fehlender
  Plattform-Eintrag), der sich im Lauf nicht herstellen lässt — dann getrennt schneiden.
- `in-progress` → `open`: das gepinnte Release trägt kein `SHA256SUMS`-Asset — Übergabe an den
  Architect.

## 5. Closure-Trigger

1. `make gates` und `make full-smoke` grün, der neue Fall als gebunden gemeldet.
2. Die FEHLER-Zeile des Falls gelesen (§7).

## 6. Risiken und offene Punkte

- **Weitere geerbte Exporte** (`TRAEGER_CARRIER`) an derselben Stufe. — **Ausgang:** offen bis zur
  Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `TOOLS` (`harness/tools/full-smoke.sh`) und `*`
(`test/`, `docs/user/`).

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (verkörpert) — Liefer-Punkt 3
trägt die Teilmessung.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
