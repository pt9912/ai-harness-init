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
[`MR-042`](../../../../harness/conventions/MR-042-der-anlass-einer-lastenheft-aenderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz.md)-Art
(Anlass in der Closure-Notiz, nicht in der Doku),
[ADR-0109](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** pt9912

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
die [ADR-0109](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)-Fassung — keine zweite Quelle desselben Satzes.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die emittierten Ziel-Doki** — sie wandert mit dem emitter-Slice
  ([`slice-emittierte-gates-host-pfad`](../done/slice-emittierte-gates-host-pfad.md));
  hier steht nur die laufende Doku (Schicht-Abgrenzung).
- **Keine neue Zahl ohne Kommando** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert))
  — Messwerte der anderen Slices wandern nur, wo sie als Beleg-Zeile mit
  ihrem Kommando stehen.
- **Kein Bestands-Räumung-Auftrag** — die Doku-Zeilen, die die Docker-Form
  beschreiben, bleiben, wo sie den opt-in Weg beschreiben; gestrichen wird
  nur, wo der Pflicht-Pfad den Satz trägt.

## 2. Definition of Done

[x] **Liefer-Punkt 1:** die fünf Sensor-Texte tragen die Verhältnis-Fassung
      (docker-los Pflicht, Image opt-in) — derselbe Satz an einem Ort, je
      Verweis von den übrigen (keine zweite Quelle); die `SMOKE_ARTIFACT_TARGET`-Hilfe
      trägt ihre neue Bedeutung (Hilfe, nicht Pflicht-Träger).
[x] **Liefer-Punkt 2:** `harness/README.md` §Sensors und `README.md`
      nennen `make environment-check` samt Bindung; die Docker-Annahmen der
      §3.9-verweisenden Doku-Zeilen (`AGENTS.md` bleibt Architect-Artefakt)
      sind als Wirkungs-Grenzen benannt.
[x] **Liefer-Punkt 3:** das Benutzerhandbuch (`docs/user/`) trägt den
      Bootstrap-Verhältnis git-only und die zwei Gate-Wege; die E2E-Abdeckung
      (`docs/user/e2e-abdeckung.md`) nennt, was die Stufen im Ziel messen —
      unverändert, wo die Stufen unverändert sind.
[x] `make gates` grün.
[x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
[x] Closure-Notiz mit Steering-Loop-Lerneintrag.
[x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
[x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/sensors/*.md` (5 Dateien) | update | Verhältnis-Fassung, dieselbe Quelle |
| `harness/README.md`, `README.md` | update | §Sensors-Zeilen + Verhältnis |
| `docs/user/**` | update | Bootstrap-Verhältnis, E2E-Abdeckung (sofern Stufen unverändert) |

## 4. Trigger

**Start** (`next` → `in-progress`): die Implementer-Slices
([`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md),
[`slice-mutate-treiber-host-modi`](../done/slice-mutate-treiber-host-modi.md),
[`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md),
[`slice-emittierte-gates-host-pfad`](../done/slice-emittierte-gates-host-pfad.md),
[`slice-ci-runner-ohne-docker`](../done/slice-ci-runner-ohne-docker.md))
liegen in `done/` — die Doku trägt den Bestand, nicht einen Plan.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte.
- `in-progress` → `open` (blockiert — Carveout?): emittierte Doku und
  laufende Doku lassen sich nicht trennen (derselbe Satz an beiden) — dann
  die Quelle-Entscheidung an die [ADR-0109](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)-Synthese, Slice steht off.

## 5. Closure-Trigger

DoD (§2) vollständig; `make docs-check` grün ohne Befund über der neuen
Verweis-Lage. Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die §3.10-Herkunfts-Anker der neuen Doku-Zeilen** — **Ausgang:**
  entfallen — die neuen Verhältnis-Zeilen tragen je `seit slice-<Kennung>`
  am Ort (Sensor-Texte, README-Zellen, Benutzerhandbuch; Gates-Lauf grün,
  Stempel-Set `d8c91e7d`), kein 3×-Fall.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

**Closure-Notiz (Rolle Planner, 2026-11-27)** — Quellen: eigener Lauf, das
Review
([`docs/reviews/2026-11-27-slice-doku-nachzug-ohne-docker.md`](../../../reviews/2026-11-27-slice-doku-nachzug-ohne-docker.md),
F-1..F-6) und der volle Gates-Lauf (Exit 0, Stempel-Set `d8c91e7d`: bats
664/664, test-go 9/9, shell-lint 0, mutate-greift 802/802, docs-check 0,
lint 0).

- **Was hat funktioniert:** die laufende Doku trägt den Bestand, nicht einen
  Plan — Sensor-Texte (`gates` Tier-2 je-Check, `mutate` Vorbedingung mit
  entlassener smoke-Spur, `smoke`/`full-smoke` Rest-Spur), `harness/README.md`
  Kante und Zellen, Benutzerhandbuch git-only-Bootstrap und zwei Gate-Wege,
  und die E2E-Abdeckung trägt mit `d8c91e7d` die Ort-Zeilen der Stufen
  (Text-Nachzug byte-identisch gegen den Bestand, Fall 5 des Halter-Wächters
  rot vor dem Nachzug, grün danach).
- **Was ging anders als geplant:** (1) **F-1 HIGH** — `95415a38` heilt die
  Accepted-[`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)
  still an der Adresse; die Einzel-Entscheidung trägt
  [`ADR-0110`](../../adr/0110-die-stillheilung-einer-accepted-adr-wird-zurueckgenommen.md)
  (Rückstellung auf den Accept-Stand `525749b4`, zwei namentliche
  `ignore-refs`-Paare als Ventil, Commits `dceb3b8c`/`640fa16b`). (2) **F-2
  HIGH** — dieselbe Commit schaltet neun fremde Paarungen-Häkchen im
  ausführenden Kontext auf; die Prüfung legitimiert sie im
  Wellen-Closure-Zug dieser Welle, Beleg je Slice in der
  Wellen-Ergebnisnotiz. (3) **F-3/F-4/F-6** — die 24 außerplan- berührte
  Bestand-Dokumente des selben Commits (Stop-Hook-Dogfood-Fixture,
  lint-/shell-lint-Vorbestand-Fixes, Go-Pin 1.27.4, Restbreite-Wächter,
  e2e-abdeckung) sind **Übergabe-Arbeit, hier als Bestand-Übergabe benannt,
  nicht als stiller Übernahme-Befund** — die Review-Klasse der
  Plan-Reichweite löst sich mit der Wellen-Trägerschaft: geliefert, belegt
  im Gates-Stempel `d8c91e7d`, die zwei `Gegenstand:`-Zeilen ohne Kennung
  tragen [`slice-ci-runner-ohne-docker`](slice-ci-runner-ohne-docker.md)
  (F-4, je Zeile geändert). (4) **Fall 801** — Anker am älteren
  Test-Bestand, keine heutige Rotform: Übergabe-Posten (bekannt, kein
  stiller Fix). (5) Der `mutate-auswahl`-Hang (> 10 min; Hand-Nachbau 9
  Fälle) — §7-Beobachtung, Klasse „Werkzeug-Lauf-Dauer über dem Bestand",
  Träger Nacht-Lauf; kein stiller Fix.
- **Steering-Loop-Eintrag:** geschärfte Regel (gezählt, nicht verkörpert —
  kein `liegt in`): **die e2e-abdeckung-Deklaration trägt die Ort-Zeilen der
  Stufen; der Text-Nachzug reist mit `make e2e-abdeckung`** — die
  Stufen-Deklaration ist die eine Quelle für Text und Ort-Spalte, die
  Erzeugung liest den Bestand und schreibt die Datei; ein Doku-Zug, der die
  Ort-Zeilen von Hand trägt, wird vom Halter-Wächter gehalten (Fall 5, rot
  vor, grün nach dem Nachzug).
- **Beobachtungs-Register (`../observations/`):** keine Beobachtung
  angefallen — der §8-Treffer (macOS-Hälfte der Host-Läufer, 7×, verkörpert)
  trägt unverändert; kein neuer Eintrag.
- **Folge-Slices:** [`slice-full-smoke-gates-echt-gruen`](../next/slice-full-smoke-gates-echt-gruen.md)
  (Rest-Spur, open) · die wellenlosen Posten `slice-gates-pruefgegenstand-stempel-v1`
  und `slice-stamp-records-konsum-v1` (in `next/`).
- **Risiken aus §6:** Herkunfts-Anker — entfallen (oben).
- **Drei Paarungen:** Anker — der Lerneintrag oben ist gezählt, es gibt
  keinen `liegt in` · Folge-Slices — Nehmer und wellenlose Posten oben ·
  Register — der Befund-Verbleib oben. Die Prüfung trägt die Welle-Closure
  dieser Welle.

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
