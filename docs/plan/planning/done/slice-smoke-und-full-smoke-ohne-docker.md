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

**Verantwortlich:** pt9912

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die zwei E2E-Skripte laufen ohne Docker-Daemon: `harness/tools/smoke.sh`
und `harness/tools/full-smoke.sh` bauen ihr Prüf-Binary ohne `docker build`
(host `go build` mit Inventar-Pin oder Träger-Fetch, je Stufe der richtige
Träger), bootstrappen das Ziel-Repo und fahren dort die emittierten
host-native Gates
([`slice-emittierte-gates-host-pfad`](../done/slice-emittierte-gates-host-pfad.md)).
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
- **Die LP2/LP3-Restmenge des docker-losen `full-smoke`** — ein Folge-Slice
  übernimmt es: [`slice-full-smoke-gates-echt-gruen`](../next/slice-full-smoke-gates-echt-gruen.md) —
  Vorlauf-Wächter-/Doku-Zahn-Stufen über dem emittierten d-check.mk
  (`doc-commits`/`doc-immutable`), die Archiv-Leseprobe (unzip am Inventar), die
  hexslice-/hexagonal-Bootstraps (a-check --print-mk ohne Host-Carrier) und die
  carrier-gebundenen `gates`-Läufe des Mono-Repos. Begründung: LP2 („grün ohne
  Daemon“) und LP3 (Färbung über einem `# verify: full-smoke`-Fall) sind an der
  Restmenge nicht erreichbar; die Treiber-Daemon-Vorbedingung bleibt in Kraft für
  full-smoke, und keine Stufen-Deklaration wird still geändert (§4) — der
  reale Lauf brach am `doc-commits`-Zahn, belegt im Register-Eintrag
  [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md).

## 2. Definition of Done

[x] **Liefer-Punkt 1:** `make smoke` läuft auf einem Host **ohne**
      Docker-Daemon grün — der Bootstrapped-Zustand wird ohne Container-
      Weg erreicht (Träger aus Inventar-Pin-Bau oder Träger-Fetch), die
      Stufen-Deklarationen unverändert.
- [ ] **Liefer-Punkt 2:** `make full-smoke` läuft auf einem Host **ohne**
      Docker-Daemon grün — inklusive der emittierten Gates im Ziel (der
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Nachweis).
- [ ] **Liefer-Punkt 3:** der Mutations-Nachweis über einem schweren Fall
      (`MUTATE_CASES='<ein `# verify: full-smoke`-Fall>'`) docker-los grün —
      der Befund-Nachweis (manipulierte Inventar-Zeile → Umgebungs-Befund)
      aus [`slice-mutate-treiber-host-modi`](../done/slice-mutate-treiber-host-modi.md)
      bleibt in Kraft; neue/wanderede Fälle je [
      `MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[
      `MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit).
- [ ] `make gates` grün.
[x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/smoke.md`](../../../../harness/sensors/smoke.md),
      [`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md)
      — Doku-Nachzug im [`slice-doku-nachzug-ohne-docker`](../next/slice-doku-nachzug-ohne-docker.md).
[x] Closure-Notiz mit Steering-Loop-Lerneintrag.
[x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
[x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
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
[`slice-emittierte-gates-host-pfad`](../done/slice-emittierte-gates-host-pfad.md)
liegt in `done/` — die emittierten Gates im Ziel laufen host-native, und
[`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md)
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
  (docker-los E2E trägt keine Docker-Isolation) — **Ausgang:** entfallen —
  die Pin-Form trägt die Messmethode (Tool-Pin je Werkzeug,
  Inventar-Emittierung im Ziel), der opt-in Image-Pfad bleibt als starker
  Weg — beide tragen denselben Prüfgegenstand, keiner still.
- **Netz-Abruf im E2E-Lauf** — **Ausgang:** entfallen — derselbe Vertrag
  blieb: Netz nur an den fetchenden Stufen (`traeger-fetch`/`dcheck-fetch`),
  der restliche Lauf blieb netzlos (Verifikations-Bericht).
- **Die emittierten Docker-Formen der Rest-Stufen haben keinen Host-Weg** —
  **Ausgang:** eingetreten — der reale Lauf brach an der Vorlauf-Wächter-Stufe
  (`make -f d-check.mk doc-commits`), gemessen am Register-Eintrag
  [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md);
  die Restmenge (1a–1d) übernimmt
  [`slice-full-smoke-gates-echt-gruen`](../next/slice-full-smoke-gates-echt-gruen.md).
  Bis dahin bleiben LP2 („grün“) und LP3 (Färbung am `full-smoke`-Fall) mit
  dem Teilstand benannt — der smoke-Modus ist am Treiber entlassen,
  full-smoke nicht (Exit 4 an der Vorbedingung, Beleg im
  Verifikations-Bericht).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

**Closure-Notiz (Rolle Planner, 2026-11-27)** — Quellen: eigener Lauf, der
Verifikations-Bericht
([`docs/reviews/2026-11-27-slice-smoke-und-full-smoke-ohne-docker-verify.md`](../../reviews/2026-11-27-slice-smoke-und-full-smoke-ohne-docker-verify.md))
und der Review-Report
([`docs/reviews/2026-11-27-slice-smoke-und-full-smoke-ohne-docker.md`](../../reviews/2026-11-27-slice-smoke-und-full-smoke-ohne-docker.md),
F-1..F-7, behoben in `95988195`/`2108567e`/`5ee7d555`/`1e3ffbdc`, V-1 im
Fix `64cd1dd7`).

- **Was hat funktioniert:** `make smoke` läuft docker-los Exit 0 (5/5
  Stufen, kein Docker-Aufruf), der Paarungs-Wächter steht 5/5 und Fall 817
  färbt am realen Bestand (Rot-Zug am `environment.go`-Anker, Meldung nennt
  die fehlende `GATE_CHECKS`-Verdrahtung); `make full-smoke` kommt in der
  echten Reihenfolge bis zum 3/3-Zug und erreicht dort grün die host-nativ
  emittierten Gates im Ziel (`environment-check: grün — 7/7`), bevor der
  erste Daemon-gebundene Zahn (`doc-commits`) bricht — die 1a–1d-Ordnung des
  Kopfkommentars ist am realen Lauf an der Stelle belegt.
- **Was ging anders als geplant:** (1) LP 2 und LP 3 sind **bedingt** — die
  Restmenge (1a Vorlauf-Wächter-/Doku-Zähne, 1b Archiv-Leseprobe, 1c
  hexslice-/hexagonal-Bootstraps, 1d carrier-gebundene Gates-Läufe) trägt
  [`slice-full-smoke-gates-echt-gruen`](../next/slice-full-smoke-gates-echt-gruen.md),
  dessen Slice-Datei dieser Closure-Lauf in `next/` eingerichtet hat; die
  `# verify: full-smoke`-Spur des Treibers bleibt in der Daemon-Vorbedingung
  (Exit 4, Ursache benannt). (2) `make gates` bleibt rot an den
  vorbestehenden Klassen plus der **einen** dokumentierten F-3-Zeile
  (die Platzhalter-Verlinkung des Nehmers — mit dessen Einrichtung aufgelöst)
  und dem V-1-Befund (Fall 816, veralteter Anker), der im Fix `64cd1dd7`
  behoben ist — `make mutate-greift` meldet wieder 0 Befunde. (3) Der
  Branch-Lauf `make mutate-auswahl` am gepinnten Tip ist CI-Posten
  (Exit 10, Push-Form `mutate/slice-smoke-und-full-smoke-ohne-docker-<sha8>`),
  keine Rolle ohne Push-Befehl der Kette. (4) Doku-Zellen
  (`smoke.md`/`full-smoke.md`) tragen als Posten
  [`slice-doku-nachzug-ohne-docker`](../next/slice-doku-nachzug-ohne-docker.md)
  — offene DoD-Zeile, Form per Verifikations-Bericht stimmt.
- **Steering-Loop-Eintrag:** geschärfte Regel (gezählt, nicht verkörpert —
  kein `liegt in`): **der make-Anspruch trägt nur mit Target dahinter; der
  Träger der Probe ist der reale Lauf an der Emissionsquelle** — die
  Paarung-Probe liest den Anspruch aus dem Quell-Bestand (kein
  Fixture-Doppel) und dreht je Form die emittierte Seite; ihre Zusage erstreckt
  sich nicht auf die Verdrahtung, die der Lauf im Ziel misst. Grenze des
  ungebundenen Teils (V-1, behoben): ein Fall-Anker veraltet, wenn ein
  Implementer-Zug die Form seiner Ziel-Stelle ändert — `MR-071` misst die
  Anlage gegen den Bestand zum Anlage-Zeitpunkt, nicht gegen spätere
  Form-Wechsel; der Nachzug bindet die Fall-Anlagen in die
  Commit-Routine der berührenden Züge (Übergabe an die Welle-Planung).
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md)
  — Stand *verkörpert* (Treiber-Vorbedingung), Beleg
  [`evidence/slice-smoke-und-full-smoke-ohne-docker.md`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/evidence/slice-smoke-und-full-smoke-ohne-docker.md),
  Belegzahl 3, Schwelle erreicht; der `full-smoke`-Rest ist dort bei der
  Nehmer-Kennung benannt. Keine weitere Beobachtung anfallen — die zwei
  §8-Treffer bleiben in ihrem Stand (macOS: 4×, verkörpert; Fall-Expect:
  2×, < 3×).
- **Folge-Slices:**
  [`slice-full-smoke-gates-echt-gruen`](../next/slice-full-smoke-gates-echt-gruen.md)
  (Restmenge, LP-2/LP-3-Träger; F-7 als §6-Risiko dort) ·
  [`slice-doku-nachzug-ohne-docker`](../next/slice-doku-nachzug-ohne-docker.md)
  (Doku-Zellen).
- **Risiken aus §6:** Nachweis-Stärke — entfallen · Netz-Abruf — entfallen ·
  Rest-Stufen — eingetreten, Nehmer oben.
- **Drei Paarungen:** Anker — der Lerneintrag oben ist gezählt, es gibt
  keinen `liegt in` · Folge-Slices — Nehmer und Doku-Nachzug oben ·
  Register — der Eintrag oben (Belegzahl 3). Die Prüfung der Paarungen
  trägt die schließende Welle.

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
