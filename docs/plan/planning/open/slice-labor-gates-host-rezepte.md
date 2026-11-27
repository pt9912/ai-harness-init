# Slice slice-labor-gates-host-rezepte: die Gate-Rezepte des Labors laufen host-native

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
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(docker-los-Pfad — die Gates des Labors laufen ohne Daemon),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(die Pin-Form bleibt — Tool-Pin über Inventar statt Image-Digest allein),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(Exit-Klassen und Urteile bleiben dieselben),
[ADR-0003](../../adr/0003-go-native-binaries.md),
[ADR-0109](../../adr/0109-…-gates-laeufen-docker-los.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->
(docker-los Default, Image-Pfade opt-in),
[`MR-024`](../../../../harness/conventions/MR-024-d-check-pin-v0620-structure-verfuegbar.md)-Form
(d-check-Pin-Disziplin).

**Berührte Spec-Stellen:** `spec/spezifikation.md` — die Stelle, die die
Gate-Rezepte und ihre Exit-Klassen trägt. Der Verweis zeigt **aufwärts**.

**Verantwortlich:** —

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die sechs Image-Rezepte der Gates-Kante im **Labor**-Makefile fahren
host-native Äquivalente ohne Docker-Daemon: `test-go` (host `go test`, Pin
`GO_VERSION` aus Inventar), `test-bats` (host `bats`), `lint` (host
golangci-lint), `build` (host `go build` cross), `shell-lint` (host
shellcheck), `ci-lint` (host actionlint), dazu `docs-check` über das
d-check-Binary aus [`slice-binraire-ziehen-ohne-docker`](../next/slice-binraire-ziehen-ohne-docker.md).
Exit-Klassen, Urteile und die Rezepte-Hilfekommentare bleiben dieselben —
nur der Träger der Umgebung wechselt (Tool-Pin statt Image-Digest allein).
Sobald alle sechs laufen, ist `make gates` docker-los.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der d-check-Beschaffungsweg** — ist
  [`slice-binraire-ziehen-ohne-docker`](../next/slice-binraire-ziehen-ohne-docker.md)
  (Schicht-Abgrenzung); hier wird das Binary nur **aufgerufen**.
- **Die emittierten Ziel-Repos** — sie tragen ihre Rezepte aus
  [`slice-emittierte-gates-host-pfad`](slice-emittierte-gates-host-pfad.md);
  hier steht nur das Labor-Makefile.
- **`fullbuild`, `mutate`, `smoke`/`full-smoke` selbst** — die Treiber-Skripte
  baut [`slice-mutate-treiber-host-modi`](slice-mutate-treiber-host-modi.md)
  und [`slice-smoke-und-full-smoke-ohne-docker`](slice-smoke-und-full-smoke-ohne-docker.md);
  die Rezept-Umstellung reicht an sie, ohne sie zu ändern — die
  `mutate`-Sperren bleiben in Kraft wie sie sind.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** die sechs Image-Rezepte fahren host-native
      Äquivalente mit Pin aus der Inventar-Form
      ([`slice-environment-check-fuehrt-die-gates`](../done/slice-environment-check-fuehrt-die-gates.md));
      die gepinnten Image-Pfade bleiben als opt-in Weg gepinnt (Pin-Zeilen
      unverändert) und tragen denselben Exit-Vertrag.
- [ ] **Liefer-Punkt 2:** `make gates` fährt auf diesem Host **ohne**
      laufendem Docker-Daemon grün durch (voller Lauf, kein Fast-Pfad-Beleg)
      — exit-Klassen und Urteile unverändert.
- [ ] **Liefer-Punkt 3:** bats-Wächter über die Rezept-Formen — Happy (je
      Rezept-Form läuft und urteilt), Negative (fehlende/abweichender
      Tool-Pin → Umgebungs-Befund bricht an) — und die Mutations-Fälle
      nachziehen, deren Anker am Rezept-Text liegen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: `harness/README.md` §Sensors-Zeilen, sofern die Bindungen
      der Targets umschreiben ([LH-QA-03](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
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
| `Makefile` | update | die sechs Rezept-Texte + die opt-in Image-Pin-Zeilen (bestehend) |
| `test/*.bats` (Rezept-Wächter) | neu / update | Rezept-Wächter je oben |
| `harness/README.md` | update | §Sensors-Zeilen, sofern die Bindungen umschreiben |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-environment-check-fuehrt-die-gates`](../done/slice-environment-check-fuehrt-die-gates.md)
und [`slice-binraire-ziehen-ohne-docker`](../next/slice-binraire-ziehen-ohne-docker.md)
liegen in `done/` — die Inventar-Pins und das d-check-Binary stehen als
Voraussetzungen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa wenn die lint-Stufe (golangci-lint-Host-Pfad) ein
  Config-Set am Host braucht, das das Image nicht trägt → re-slicen.
- `in-progress` → `open` (blockiert — Carveout?): ein Rezept hat kein
  host-Äquivalent, das die Exit-Klasse tragen kann — dann Carveout-Klärung
  an der ADR-0109-Platzhalter-Synthese, Slice steht off.

## 5. Closure-Trigger

DoD (§2) vollständig; im Verifikations-Bericht steht der reale Lauf
`make gates` **ohne Docker-Daemon** (grün, voller Lauf, exit-Klassen
unverändert) und der Negative über einer abweichenden Inventar-Zeile.
Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **golangci-lint host-Pfad weicht vom Image-Ergebnis ab** — **Ausgang:**
  die Pin-Form trägt es (Tool-Pin GO_VERSION + golangci-lint-Version im
  Inventar mit Prüfsumme); weicht der Urteilsergebnis je Weise ab, ist der
  Befund im Verifikations-Bericht zu stehen — der Image-Pfad bleibt als
  opt-in Träger.
- **Die Mutations-Fälle, die am Dockerfile-Rezept-Text verankern** —
  **Ausgang:** je Fall gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)):
  Anker am Rezept-Text zieht nach, Anker am Dockerfile bleibt (der
  Image-Pfad steht).

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

- [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  — 7 Vorgänge, Ausgang *verkörpert*; der Host-Rezept-Teil trägt seine
  Linux-Annahme in der ADR-Fassung benannt, nicht gelöst — kein 3×-Übertritt.
- [`BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`](../observations/BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last/state.md)
  — 2 Vorgänge (< 3×): der Grün-Vorlauf fällt unter Last; der host-native
  Weg verlegt den Vorlauf auf die Host-Rezepte — der Bestand bleibt, die
  Grenze steht in der Welle §6. Notiert, nicht gelöst hier.

Keine Treffer unter der Schwelle jenseits der genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
