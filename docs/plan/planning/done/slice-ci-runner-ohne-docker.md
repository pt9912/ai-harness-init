# Slice slice-ci-runner-ohne-docker: CI auf frischem Klon — ohne Docker-Daemon

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-ohne-docker](../welle-ohne-docker.md) — der Closure-Trigger
der Welle („`make gates` grün auf einem Runner ohne Docker-Daemon") ist
genau die Übergabe dieses Slices plus die der Rezept-Slices.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ,
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ,
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ,
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
(CI auf frischem Klon — der Net-Träger),
[`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md).

**Berührte Spec-Stellen:** `spec/spezifikation.md` — die CI-Stellen (Runner,
Schritte). Der Verweis zeigt **aufwärts**.

**Verantwortlich:** pt9912

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die GitHub-Workflows (`ci.yml`, `mutate.yml`, `mutate-branch.yml`)
fahren ohne Docker-Daemon: die Runner-Setup-Steps installieren die
Inventar-Werkzeuge (go/bats/shellcheck/actionlint/d-check-Binary, Version je
Pin aus dem Inventar), die Gates- und Mutations-Jobs rufen nur `make`-Targets,
der Release-Bau (Tag-Workflow) bleibt im gepinnten Image
([ADR-0003](../../adr/0003-go-native-binaries.md)). `MR-014` bleibt in Kraft —
CI läuft auf frischem Klon, nur ohne Daemon-Annahme.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Tag-Workflow/Release** — bleibt docker-getrieben (Tool-Build im
  gepinnten Image über den Runner-Daemon; [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **Die d-check-Pin-Ebene** — kommt aus
  [`slice-binraire-ziehen-ohne-docker`](../done/slice-binraire-ziehen-ohne-docker.md);
  hier wird sie an die Runner-Stufen verdrahtet.
- **macOS- oder Windows-Runner für die Host-Läufer** — [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
  bleibt Linux-CI; die macOS-Tragung ist ein ADR-Gegenstand (Bestand:
  [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)).
- **Die daemon-gebundene Rest-Spur des `full-smoke`-Jobs in `ci.yml`** — dieselbe
  Klasse wie der smoke/full-smoke-Zug: der CI-Job fährt die Rest-Stufen am
  Runner-Daemon, der Daemon-Gang selbst trägt
  [`slice-full-smoke-gates-echt-gruen`](../next/slice-full-smoke-gates-echt-gruen.md);
  die docker-lose LP2-Form gilt für die Gates- und Smoke-Kette, nicht für diese
  Rest-Spur (LP2, §5).
- **`.github/workflows/upstream-drift.yml` bleibt, wie er ist** — sein
  `regelwerk-check` fährt den sources-Modul-Lauf im gepinnten Bild desselben
  d-check-Pins, die übrigen Stufen tragen die curl-Form: der docker-lose
  Pflicht-Weg (Bezug oben) verlangt ihn für Gates- und Lab-Läufer, nicht für die
  Netz-Freshness-Sensoren — der Modul-Lauf am Bild ist opt-in Weg, Bestand bleibt
  bewusst stehen.

## 2. Definition of Done

[x] **Liefer-Punkt 1:** die Gates- und Mutations-Workflows tragen die
      Runner-Setup-Steps gemäß Inventar-Pins; kein Job setzt Docker-Daemon
      voraus (der daemon-fahrende Tag-Workflow bleibt gepinnt).
- [ ] **Liefer-Punkt 2:** ein Push/PR-Lauf (`ci.yml`) auf frischem Klon
      läuft grün — `make gates` + `make smoke` docker-los (der reale Lauf im
      Verifikations-Bericht); der `full-smoke`-Job ist die daemon-gebundene
      Rest-Spur (§1), sein Ausgang trägt
      [`slice-full-smoke-gates-echt-gruen`](../next/slice-full-smoke-gates-echt-gruen.md).
- [ ] **Liefer-Punkt 3:** der Nacht-Workflow (`mutate.yml`) fährt einen
      Shard docker-los grün (reale Messung — Wall-Clock und je-Case-Ausgang
      im Bericht); die `mutate-branch`-Schritte bleiben wirksam.
- [ ] `make gates` grün.
[x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/gates.md`](../../../../harness/sensors/gates.md),
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      (CI-Verhältnis) — Doku-Nachzug im
      [`slice-doku-nachzug-ohne-docker`](../in-progress/slice-doku-nachzug-ohne-docker.md).
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
| `.github/workflows/ci.yml` | update | Runner-Setup gemäß Inventar-Pin; Gates/Smoke-Jobs ohne Daemon |
| `.github/workflows/mutate.yml` | update | Shard-Jobs ohne Daemon |
| `.github/workflows/mutate-branch.yml` | update | dasselbe, `ergebnis`-Schritt bleibt |
| `.github/workflows/release.yml` (Name beim Implementer) | update | nur der Tag-Workflow bleibt gepinnt-image-getrieben — Kommen-Kommentar nennt die Grenze |
| `test/ci-*.bats` (je Implementer) | neu / update | ci-lint-Wächter über die neuen Workflows |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md),
[`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md)
und [`slice-binraire-ziehen-ohne-docker`](../done/slice-binraire-ziehen-ohne-docker.md)
liegen in `done/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte.
- `in-progress` → `open` (blockiert — Carveout?): ein Runner trägt eine
  Inventar-Version nicht (etwa die gepinnte `go`-Version via setup-step) —
  dann die Pin-Form an die Inventar-Ablage zurückmelden, Slice steht off.

## 5. Closure-Trigger

DoD (§2) vollständig; die zwei realen CI-Läufe (Push-Lauf + Nacht-Shard)
stehen im Verifikations-Bericht — der Push-Lauf trägt die Trennung: die
Gates- und Smoke-Kette grün docker-los, der `full-smoke`-Job an der
daemon-gebundenen Rest-Spur (§1, sein Ausgang beim Nehmer). Zusätzlich:
Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Runner-Setup schweift ab vom Inventar-Pin** — **Ausgang:** der Setup
  liest seinen Pin aus dem Inventar (eine Quelle); `pinsync`
  ([`slice-environment-check-fuehrt-die-gates`](../done/slice-environment-check-fuehrt-die-gates.md))
  hält die Stellen gegeneinander; weichens Abweichung bricht an
  `environment-check`. — **Ausgang:** entfallen (entwaffnet) — der Setup
  liest das Soll aus dem Inventar (eine Quelle, `soll()`-Spalte 4); der
  Rot-Zug über dem künftigen Soll-Literal färbt Fall 6 rot (B-1), die
  Kommentar-Nennung trägt keinen Soll und bleibt grün (B-2) — kein
  Soll-Literal im Wächter.
- **Die Nacht-Shard-Zeiten verschieben sich docker-los** — **Ausgang:**
  weiter offen — die reale Messung trägt CI (LP 3, Träger); die zwei
  §8-Treffer ([`BEO-ALL/mutate-matrix-actions-minuten-bei-privatem-repo`](../observations/BEO-ALL/mutate-matrix-actions-minuten-bei-privatem-repo/state.md)
  und [`BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor`](../observations/BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor/state.md),
  je 1×) stehen unter der Schwelle und halten den Stand.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

**Closure-Notiz (Rolle Planner, 2026-11-27)** — Quellen: eigener Lauf, der
Verifikations-Bericht
([`docs/reviews/2026-11-27-slice-ci-runner-ohne-docker-verify.md`](../../reviews/2026-11-27-slice-ci-runner-ohne-docker-verify.md))
und der Review-Report
([`docs/reviews/2026-11-27-slice-ci-runner-ohne-docker.md`](../../reviews/2026-11-27-slice-ci-runner-ohne-docker.md),
F-1..F-7, behoben `cb965055`/`bc46815d`/`678e4f7e`/`6f0b50ca`/`b20ffd8b`).

- **Was hat funktioniert:** die hermetische Form steht — Runner-Setup je
  Job gemäß Inventar-Pin ohne Soll-Literal (`CI_RUNNER_SETUP_PLAN=1`-Probe
  grün, PLAN-Idempotenz byte-gleich in beide Richtungen, L-3/L-4), der
  Carrier-Tisch `make dcheck-fetch` je Job, der Tag-Workflow im gepinnten
  Bild (B-4 Rot), `make ci-lint` Exit 0 über die fünf Workflows und die
  Bruchproben B-1..B-4 färben je benannten Wächter an der realen Quelle.
- **Was ging anders als geplant:** (1) LP 2 und LP 3 sind **am
  Verifier-Lauf nicht bestätigt** — der Träger ist der reale Runner-Lauf in
  CI (Push-Lauf `ci.yml` + Nacht-Shard; Wall-Clock und je-Case-Ausgang
  dessen Beleg); solange die Vorbestand-Rotmenge steht (docs-check 128 am
  HEAD — 3 Befunde weniger am Claim durch die Verweis-Reparatur `3dfd114d`,
  lint, shell-lint, bats 158/281, test-go 2 Klassen), ist die
  LP-2-„grün"-Zusage an CI rot — nicht am Diff, am Bestand. (2) O-1: der
  lint-Vorbestand `gochecknoglobals` am `inventoryBasissatz`
  (`internal/emit/environment.go:57`) blockiert den CI-Push-Lauf vor der
  LP-2-Lesung — Träger: ein eigener Posten vor dem CI-Beleg. (3) O-2: der
  Mutations-Branch-Posten steht bei 62 Fällen (Exit 10), Push-Form
  `mutate/slice-ci-runner-ohne-docker-b20ffd8b`, Lesung von
  `mutate-ergebnis.txt`, danach Ref-Räumung — kein Zug dieser Rolle ohne
  Push. (4) O-6: Fall 818s kuratierte Entstehung trägt der Lauf nach dem
  Vorbestand-Fix (Grenze am Fall-Kopf). (5) Die Plan-Zeile des
  Platzhalter-Befunds (Zeile 22, `target-missing`) ist in diesem
  Closure-Zug auf die reale ADR-0109-Datei umgestellt — der
  `d-check:ignore`-Kommentar wirkte dort nicht.
- **Steering-Loop-Eintrag:** geschärfte Regel (gezählt, nicht verkörpert —
  kein `liegt in`): **ein Soll trägt EINE Quelle; der Wächter hält die
  Eigenschaft, nicht den heutigen Pin-Wert** — die Bindung liest die
  Werkzeug-Menge aus dem Inventar (`soll_anker`), und der Rot-Zug der
  Bruchprobe färbt über einem *künftigen* Pin-Wert, während die
  Kommentar-Nennung desselben Werts grün bleibt (B-1/B-2 beide Richtungen
  an der realen Quelle); ein Pin-Wechsel macht die Zusage damit nicht
  unsichtbar. Grenze (F-6/F-7, INFO, offene Posten des Bestands):
  `gochecknoglobals` am `inventoryBasissatz` (O-1) und die Probe-Formen des
  `environment-check`-exakt-Zweigs (F-7) tragen am gelesenen Lauf bzw. am
  Vorbestand-Fix, nicht hier.
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar`](../observations/BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar/state.md)
  — Beleg
  [`evidence/slice-ci-runner-ohne-docker.md`](../observations/BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar/evidence/slice-ci-runner-ohne-docker.md)
  ergänzt (Zähler folgt aus den Dateien: 2, unter der Schwelle). Die zwei
  §8-Treffer (Actions-Minuten 1×, Shard-Kosten 1×) bleiben — die reale
  Messung trägt CI, kein neuer Stand.
- **Folge-Slices:**
  [`slice-doku-nachzug-ohne-docker`](../in-progress/slice-doku-nachzug-ohne-docker.md)
  (Sensor-Zellen `gates.md`/`mutate.md`, O-5) ·
  [`slice-full-smoke-gates-echt-gruen`](../next/slice-full-smoke-gates-echt-gruen.md)
  (Rest-Spur full-smoke + adr-immutable).
- **Risiken aus §6:** Setup-Abweichung — entfallen (entwaffnet) ·
  Shard-Zeiten — weiter offen, Register oben.
- **Drei Paarungen:** Anker — der Lerneintrag oben ist gezählt, es gibt
  keinen `liegt in` · Folge-Slices — die zwei oben · Register — der Eintrag
  oben (Zähler 2). Die Prüfung der Paarungen trägt die schließende Welle.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** und die **vier Pflichtkriterien**.

**Der Abschnitt selbst entfällt nie.**

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `.github/workflows/`
(über den `ci-lint`-Prüfbereich) und `*` (Kürzel `ALL`); beide erfüllen die
Schwelle ≥ 2 von 3 Achsen.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer:

- [`BEO-ALL/mutate-matrix-actions-minuten-bei-privatem-repo`](../observations/BEO-ALL/mutate-matrix-actions-minuten-bei-privatem-repo/state.md)
  — 1 Vorgang (< 3×): Actions-Minuten bei privatem Repo — der docker-los Lauf
  verschiebt die Kostenform; reale Messung im Bericht.
- [`BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor`](../observations/BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor/state.md)
  — 1 Vorgang (< 3×) — Bestand bleibt, Vergleichswert in der Messung.

Keine Treffer unter der Schwelle jenseits der genannten.

**Modus-Begründigungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründigungsblock entfällt.
