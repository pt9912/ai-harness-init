# Slice slice-emittierte-gates-host-pfad: die emittierten Gates fahren host-native

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
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(Bootstrap — das gebootstrappte Repo läuft Gates out-of-the-box),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(jeder emittierte Gate-Target läuft auf frischem Checkout),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(emittierte Ziel-Reports bleiben make-getrieben, docker Weg statt Pflicht),
[ADR-0004](../../adr/0004-durchsetzung-emission.md) (durchgesetzte Emission),
[ADR-0109](../../adr/0109-…-gates-laeufen-docker-los.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->,
`slice-c4-environment-check-v7-0-0` ([docs/plan/planning/done/](../done/slice-c4-environment-check-v7-0-0.md)
— die emittierte `environment-check`-Vorlage wird zum Träger).

**Berührte Spec-Stellen:** `spec/spezifikation.md` — die Stelle, die die
emittierte Gates-Struktur (mk-Fragmente, Dockerfile-Stages) trägt. Der Verweis
zeigt **aufwärts**.

**Verantwortlich:** —

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die emitter-Template-Ebene trägt die host-native Gate-Form in das
gebootstrappte Ziel: die emittierte Gates-Kante startet mit
`make environment-check` (die Vorlage ist schon emittiert — sie wird Träger),
die Rezepte hinter `test`/`lint`/`build`/`shell-lint`/`ci-lint`/`docs-check`
fahren host-native Äquivalente mit Tool-Pins (Inventar wird emittiert), die
gepinnten Image-Pfade bleiben als opt-in-Weg gepinnt. Das gebootstrappte Ziel
ist damit `make gates`-fähig auf einem Host ohne Docker-Daemon — der
Bootstrap braucht nur git.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Labor-Baum (dieses Repo)** — seine eigenen Rezepte baut
  [`slice-labor-gates-host-rezepte`](slice-labor-gates-host-rezepte.md);
  hier steht die emitter-Ebene (Schicht-Abgrenzung).
- **Der Bootstrap-Code (Go) selbst, außer der Gate-Fragmente** — die
  Bootstrap-Kette bleibt (Phase-Struktur, hooks, Sprachskelett); nur die
  Gates-Ebene wandert.
- **Der d-check-Binary-Zugang im Ziel** — der emittierte Weg benennt seine
  Quelle (Pin + Beschaffung, dieselbe Form wie
  [`slice-binraire-ziehen-ohne-docker`](../in-progress/slice-binraire-ziehen-ohne-docker.md));
  die Labor-Mechanik wird nicht doppelt geführt — der emittierte Pin trägt
  den Tag, der Fetch-Zug entsteht aus denselben Fragments.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** die emittierten Gates-Fragmente (`internal/emit/templates/`
      + mk-Fragmente) tragen die host-native Form mit Inventar-Emittierung;
      `environment-check` fährt emittiert als erster Gates-Check
      (`LH-QA-01`-Messung bleibt full-smoke).
- [ ] **Liefer-Punkt 2:** ein frisch gebootstrapptes Ziel fährt `make gates`
      out-of-the-box grün auf einem Host ohne Docker-Daemon — belegt im
      realen Lauf (Verifikations-Bericht), nicht als Prosa.
- [ ] **Liefer-Punkt 3:** Go-Emitter-Tests (`internal/emit/*_test.go`) tragen
      die Form (Happy über die emittierten Rezepte, Negative über
      fehlender Inventar-Zeile) und die Mutations-Fälle, deren Anker an der
      Template-Ebene liegt, sind neu gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: emitter-Doku (`docs/user/`, README), sofern die
      emittierte Gates-Ebene öffentlich berührt (Bootstrap-Verhältnis git-only).
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
| `internal/emit/templates/**` (mk-Fragmente, Dockerfile, environment-check-Vorlage) | update | host-native Gate-Form + Inventar + opt-in Image-Pins |
| `internal/emit/**_test.go` | update / neu | Emitter-Tests je oben |
| `docs/user/**`, `README.md` | update | Bootstrap-Verhältnis (git-only) und die zwei Gate-Wege |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-labor-gates-host-rezepte`](slice-labor-gates-host-rezepte.md) liegt in
`done/` — die laborseitige Form steht als Vorbild, die emitter-Seite spiegelt
sie (dieselbe Form, keine zweite Definition).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa, wenn die Sprach-Skelett-Toolchains (Kotlin, Java,
  Python, Csharp) je Pin-Set zusätzlich umzustellen sind → re-slicen, dann
  ein Sprach-Skelett je Teil.
- `in-progress` → `open` (blockiert — Carveout?): ein emittiertes Skelett
  hat keinen host-Toolchain-Weg (Kotlin-Gradle-Toolchain ohne Container?) —
  dann die Skelett-Toolchain-Frage an die ADR-0109-Platzhalter-Synthese.

## 5. Closure-Trigger

DoD (§2) vollständig; der reale Lauf (gebootstrapptes Ziel, `make gates`
grün ohne Docker-Daemon) steht im Verifikations-Bericht. Zusätzlich:
Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die Sprach-Skelett-Toolchains (Kotlin, Java, Python, Csharp) tragen
  ihre eigene Pin-Form** ([`ADR-0088`](docs/plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)-Nachfolger)
  — **Ausgang:** je Skelett die Form benennen, wo sie docker-los lauffähig
  ist; wo nicht, ist es die Rückführung §4, nicht stiller Bestand.
- **`full-smoke` fährt die emittierte Ebene** — **Ausgang:** der reale Beleg
  der emittierten Form läuft über
  [`slice-smoke-und-full-smoke-ohne-docker`](slice-smoke-und-full-smoke-ohne-docker.md);
  bis dahin ist der Beleg der manuelle Lauf oben.

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

**Der Abschnitt selbst entällt nie.**

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind die emitter-Ebene
(`internal/emit/`) und `*` (Kürzel `ALL`); beide stehen unter der
Modus-Deklaration (GF) und erfüllen die Schwelle ≥ 2 von 3 Achsen.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer:

- [`BEO-ALL/emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache`](../observations/BEO-ALL/emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache/state.md)
  — 1 Vorgang (< 3×): gemischtes Root baut das Dockerfile einer anderen
  Sprache — der Host-Weg verlegt die Rezepte weg vom Dockerfile; der Bestand
  bleibt opt-in. Notiert, nicht gelöst hier.
- [`BEO-ALL/bats-zusicherung-nutzt-gnu-only-erweiterung`](../observations/BEO-ALL/bats-zusicherung-nutzt-gnu-only-erweiterung/state.md)
  — 2 Vorgänge (< 3×): GNU-only-Formen in bats — der host-native Weg verlegt
  denselben Fall auf den Host; bei diesem Slice sind die GNU-Annahmen
  bewusst benannt (Inventar nennt die Werkzeug-Varianten).

Keine Treffer unter der Schwelle jenseits der genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
