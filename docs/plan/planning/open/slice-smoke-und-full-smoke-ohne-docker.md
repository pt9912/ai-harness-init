# Slice slice-smoke-und-full-smoke-ohne-docker: `smoke` und `full-smoke` laufen ohne Docker

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-ohne-docker](../welle-ohne-docker.md) — der Closure-Trigger
der Welle beobachtet mehr als ein Slice-DoD trägt (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Messmethode „make gates grün out-of-the-box" — jetzt docker-los),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ,
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) ,
[ADR-0109](../../adr/0109-…-gates-laeufen-docker-los.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->,
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
(die `SMOKE_ARTIFACT_TARGET`-Hilfe entfällt oder wird umgebund — im
Linux-Hauptweg ohne Docker-Abhängigkeit).

**Berührte Spec-Stellen:** `spec/spezifikation.md` — die Stelle, die die
smoke/full-smoke-Stufen trägt (E2E-Stufen-Deklarationen). Der Verweis zeigt
**aufwärts**.

**Verantwortlich:** —

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die zwei E2E-Skripte laufen ohne Docker-Daemon: `harness/tools/smoke.sh`
und `harness/tools/full-smoke.sh` bauen ihr Prüf-Binary ohne `docker build`
(host `go build` mit Inventar-Pin oder Träger-Fetch, je Stufe der richtige
Träger), bootstrappen das Ziel-Repo und fahren dort die emittierten
host-native Gates
([`slice-emittierte-gates-host-pfad`](slice-emittierte-gates-host-pfad.md)).
Die Stufen-Deklarationen der E2E-Abdeckung bleiben — der Prüfgegenstand
(LH-QA-01 over-the-box) ist derselbe, nur der Träger der Umgebung wechselt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die 316 Mutations-Fälle themselves** — die 64 schweren laufen über
  `make smoke`/`make full-smoke` und fallen hier mit; ihr Fall-Satz
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand))
  wird nicht umgeschrieben, nur der Träger wechselt.
- **Der Release-Schnitt am Tag** ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix))
  — ein anderer Vorgang; der CI-Rest (reale Plattform-Matrix) bleibt.
- **`make artifact-host`/`SMOKE_ARTIFACT_TARGET` als macOS-Hilfe** — der
  Bestand bleibt; mit Host-Build über Inventar-Pin läuft der Hauptweg über
  dieselbe Form — macOS bleibt ungetragen
  ([`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)).

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** `make smoke` läuft auf einem Host **ohne**
      Docker-Daemon grün — der Bootstrapped-Zustand wird ohne Container-
      Weg erreicht (Träger aus Inventar-Pin-Bau oder Träger-Fetch), die
      Stufen-Deklarationen unverändert.
- [ ] **Liefer-Punkt 2:** `make full-smoke` läuft auf einem Host **ohne**
      Docker-Daemon grün — inklusive der emittierten Gates im Ziel (der
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Nachweis).
- [ ] **Liefer-Punkt 3:** der Mutations-Nachweis über einem schweren Fall
      (`MUTATE_CASES='<ein `# verify: full-smoke`-Fall>'`) docker-los grün —
      der Befund-Nachweis (manipulierte Inventar-Zeile → Umgebungs-Befund)
      aus [`slice-mutate-treiber-host-modi`](slice-mutate-treiber-host-modi.md)
      bleibt in Kraft; neue/wanderede Fälle je [
      `MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[
      `MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/smoke.md`](../../../../harness/sensors/smoke.md),
      [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md)
      — Doku-Nachzug im [`slice-doku-nachzug-ohne-docker`](slice-doku-nachzug-ohne-docker.md).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/smoke.sh` | update | Bootstrapped-Träger docker-los (7 Docker-Stufen → host) |
| `harness/tools/full-smoke.sh` | update | dieselbe Form je Stufe |
| `Makefile` | update | `smoke`/`full-smoke`-Rezepte + `artifact`-Weg-Träger |
| `test/smoke-ohne-docker.bats` (je Implementer) | neu | Happy/Negative je oben |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-emittierte-gates-host-pfad`](slice-emittierte-gates-host-pfad.md)
liegt in `done/` — die emittierten Gates im Ziel laufen host-native, und
[`slice-labor-gates-host-rezepte`](../next/slice-labor-gates-host-rezepte.md)
steht (die host-Rezepte des Labors existieren).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa wenn die E2E-Stufen-Zugang je Bootstrap-Layout
  (dokument-only, go, cpp, …) nicht in einen Träger-Pfad fällt → re-slicen.
- `in-progress` → `open` (blockiert — Carveout?): eine E2E-Stufe hat
  keinen host-Prüfen-Weg (etwa die `full-smoke`-Stufe, die Docker-Behauptungen
  der emittierten Ebene messen will) — dann die Abgrenzung an die ADR-0109-
  Platzhalter-Synthese und die Stufen-Deklaration wird neu formuliert —
  nicht still geändert.

## 5. Closure-Trigger

DoD (§2) vollständig; der reale Lauf `make full-smoke` ohne Docker-Daemon
(grün) und der Mutations-Befund über einem schweren Fall im Verifikations-
Bericht. Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Der `LH-QA-01`-Nachweis über `make full-smoke` wird schwächer gelesen**
  (docker-los E2E trägt keine Docker-Isolation) — **Ausgang:** die Pin-Form
  tragt es (Tool-Pin je Werkzeug; Inventar); der opt-in Image-Pfad bleibt als
  starker Weg — beide tragen den Nachweis, einer ist Pflicht.
- **Netz-Abruf im E2E-Lauf** — **Ausgang:** derselbe Vertrag wie heute
  (Netz nur bei den fetchenden Stufen; sonst kein Netz-Annahme).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <… | keine Beobachtung angefallen>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** und die **vier Pflichtkriterien**.

**Der Abschnitt selbst entfällt nie.**

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `harness/tools/` (Kürzel
`TOOLS`) und `*` (gesamtes Repo, Kürzel `ALL`); beide erfüllen die Schwelle
≥ 2 von 3 Achsen.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer:

- [`BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/state.md)
  — 4 Vorgänge, Ausgang *verkörpert* (Weg, nicht Behebung); die Open
  Behebung steht beim Auftraggeber — dieser Weg (Host-Build über Inventar-Pin)
  ist der Behebung-Typ, der macOS aber weiterhin nicht trägt. Kein
  3×-Übertritt; der offene Punkt bleibt beim Auftraggeber.
- [`BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache`](../observations/BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache/state.md)
  — 2 Vorgänge (< 3×): Fall-Expect pinnt nicht die Ursache — die Stufen-
  Deklarationen werden nicht umgeschrieben (bestand bleibt).

Keine Treffer unter der Schwelle jenseits der genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
