# Slice slice-doku-nachzug-ohne-docker: Doku-Nachzug der docker-los-Form

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
(keine halluzinierten Gates — die Index-Zeilen nennen nur existierende Targets),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-042`](../../../../harness/conventions/MR-042-der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz.md)-Art
(Anlass in der Closure-Notiz, nicht in der Doku),
[ADR-0109](../../adr/0109-…-gates-laeufen-docker-los.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die laufende Doku trägt die docker-los-Form: die Sensor-Texte
([`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md),
[`harness/sensors/smoke.md`](../../../../harness/sensors/smoke.md),
[`harness/sensors/full-smoke.md`](../../../../harness/sensors/full-smoke.md),
[`harness/sensors/gates.md`](../../../../harness/sensors/gates.md),
[`harness/sensors/environment-check.md`](../../../../harness/sensors/environment-check.md)),
die Index-Zeilen ([`harness/README.md`](../../../../harness/README.md)),
das Benutzerhandbuch (`docs/user/`) und die README nennen denselben Verhältnis-
Zug (docker-los Pflicht-Pfad, Image-Pfade opt-in) mit denselben Begriffen wie
die ADR-0109-Platzhalter-Fassung — keine zweite Quelle desselben Satzes.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die emittierten Ziel-Doki** — sie wandert mit dem emitter-Slice
  ([`slice-emittierte-gates-host-pfad`](slice-emittierte-gates-host-pfad.md));
  hier steht nur die laufende Doku (Schicht-Abgrenzung).
- **Keine neue Zahl ohne Kommando** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert))
  — Messwerte der anderen Slices wandern nur, wo sie als Beleg-Zeile mit
  ihrem Kommando stehen.
- **Kein Bestands-Räumung-Auftrag** — die Doku-Zeilen, die die Docker-Form
  beschreiben, bleiben, wo sie den opt-in Weg beschreiben; gestrichen wird
  nur, wo der Pflicht-Pfad den Satz trägt.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** die fünf Sensor-Texte tragen die Verhältnis-Fassung
      (docker-los Pflicht, Image opt-in) — derselbe Satz an einem Ort, je
      Verweis von den übrigen (keine zweite Quelle); die `SMOKE_ARTIFACT_TARGET`-Hilfe
      trägt ihre neue Bedeutung (Hilfe, nicht Pflicht-Träger).
- [ ] **Liefer-Punkt 2:** `harness/README.md` §Sensors und `README.md`
      nennen `make environment-check` samt Bindung; die Docker-Annahmen der
      §3.9-verweisenden Doku-Zeilen (`AGENTS.md` bleibt Architect-Artefakt)
      sind als Wirkungs-Grenzen benannt.
- [ ] **Liefer-Punkt 3:** das Benutzerhandbuch (`docs/user/`) trägt den
      Bootstrap-Verhältnis git-only und die zwei Gate-Wege; die E2E-Abdeckung
      (`docs/user/e2e-abdeckung.md`) nennt, was die Stufen im Ziel messen —
      unverändert, wo die Stufen unverändert sind.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
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
| `harness/sensors/*.md` (5 Dateien) | update | Verhältnis-Fassung, dieselbe Quelle |
| `harness/README.md`, `README.md` | update | §Sensors-Zeilen + Verhältnis |
| `docs/user/**` | update | Bootstrap-Verhältnis, E2E-Abdeckung (sofern Stufen unverändert) |

## 4. Trigger

**Start** (`next` → `in-progress`): die Implementer-Slices
([`slice-labor-gates-host-rezepte`](../in-progress/slice-labor-gates-host-rezepte.md),
[`slice-mutate-treiber-host-modi`](slice-mutate-treiber-host-modi.md),
[`slice-smoke-und-full-smoke-ohne-docker`](slice-smoke-und-full-smoke-ohne-docker.md),
[`slice-emittierte-gates-host-pfad`](slice-emittierte-gates-host-pfad.md),
[`slice-ci-runner-ohne-docker`](slice-ci-runner-ohne-docker.md))
liegen in `done/` — die Doku trägt den Bestand, nicht einen Plan.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte.
- `in-progress` → `open` (blockiert — Carveout?): emittierte Doku und
  laufende Doku lassen sich nicht trennen (derselbe Satz an beiden) — dann
  die Quelle-Entscheidung an die ADR-0109-Platzhalter-Synthese, Slice steht off.

## 5. Closure-Trigger

DoD (§2) vollständig; `make docs-check` grün ohne Befund über der neuen
Verweis-Lage. Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die §3.10-Herkunfts-Anker der neuen Doku-Zeilen** — **Ausgang:** Anker
  `seit slice-<Kennung>` je Zeile der neuen Verhältnis-Fassung — Form nach
  Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker für
  Steering-Loop-Regeln.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (gesamtes Repo,
Kürzel `ALL`); die Schwelle ≥ 2 von 3 Achsen ist erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer:

- [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  — 7 Vorgänge, Ausgang *verkörpert*; die Doku-Zeilen der Läufer tragen die
  Linux-Annahme weiter — kein 3×-Übertritt.

Keine Treffer unter der Schwelle jenseits des genannten.

**Modus-Begründigungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründigungsblock entfällt.
