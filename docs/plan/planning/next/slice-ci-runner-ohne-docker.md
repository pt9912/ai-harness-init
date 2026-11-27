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
[`ADR-0109`](../../adr/0109-…-gates-laeufen-docker-los.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->.

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

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** die Gates- und Mutations-Workflows tragen die
      Runner-Setup-Steps gemäß Inventar-Pins; kein Job setzt Docker-Daemon
      voraus (der daemon-fahrende Tag-Workflow bleibt gepinnt).
- [ ] **Liefer-Punkt 2:** ein Push/PR-Lauf (`ci.yml`) auf frischem Klon
      läuft grün — `make gates` + `make smoke` + `make full-smoke` docker-los
      (der reale Lauf im Verifikations-Bericht).
- [ ] **Liefer-Punkt 3:** der Nacht-Workflow (`mutate.yml`) fährt einen
      Shard docker-los grün (reale Messung — Wall-Clock und je-Case-Ausgang
      im Bericht); die `mutate-branch`-Schritte bleiben wirksam.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/gates.md`](../../../../harness/sensors/gates.md),
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      (CI-Verhältnis) — Doku-Nachzug im
      [`slice-doku-nachzug-ohne-docker`](slice-doku-nachzug-ohne-docker.md).
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
| `.github/workflows/ci.yml` | update | Runner-Setup gemäß Inventar-Pin; Gates/Smoke-Jobs ohne Daemon |
| `.github/workflows/mutate.yml` | update | Shard-Jobs ohne Daemon |
| `.github/workflows/mutate-branch.yml` | update | dasselbe, `ergebnis`-Schritt bleibt |
| `.github/workflows/release.yml` (Name beim Implementer) | update | nur der Tag-Workflow bleibt gepinnt-image-getrieben — Kommen-Kommentar nennt die Grenze |
| `test/ci-*.bats` (je Implementer) | neu / update | ci-lint-Wächter über die neuen Workflows |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md),
[`slice-smoke-und-full-smoke-ohne-docker`](slice-smoke-und-full-smoke-ohne-docker.md)
und [`slice-binraire-ziehen-ohne-docker`](../done/slice-binraire-ziehen-ohne-docker.md)
liegen in `done/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte.
- `in-progress` → `open` (blockiert — Carveout?): ein Runner trägt eine
  Inventar-Version nicht (etwa die gepinnte `go`-Version via setup-step) —
  dann die Pin-Form an die Inventar-Ablage zurückmelden, Slice steht off.

## 5. Closure-Trigger

DoD (§2) vollständig; die zwei reale CI-Läufe (Push-Lauf + Nacht-Shard)
doker-los grün stehen im Verifikations-Bericht. Zusätzlich: Closure-Notiz
mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Runner-Setup schweift ab vom Inventar-Pin** — **Ausgang:** der Setup
  liest seinen Pin aus dem Inventar (eine Quelle); `pinsync`
  ([`slice-environment-check-fuehrt-die-gates`](../done/slice-environment-check-fuehrt-die-gates.md))
  hält die Stellen gegeneinander; weichens Abweichung bricht an
  `environment-check`.
- **Die Nacht-Shard-Zeiten verschieben sich docker-los** — **Ausgang:**
  reale Messung im Bericht (der Bestand `BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor`
  zählt als < 3×, der Lauf wird mit dem Bestand verglichen).

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
