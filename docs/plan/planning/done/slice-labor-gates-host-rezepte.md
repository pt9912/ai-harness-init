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

**Verantwortlich:** pt9912

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die sechs Image-Rezepte der Gates-Kante im **Labor**-Makefile fahren
host-native Äquivalente ohne Docker-Daemon: `test-go` (host `go test`, Pin
`GO_VERSION` aus Inventar), `test-bats` (host `bats`), `lint` (host
golangci-lint), `build` (host `go build` cross), `shell-lint` (host
shellcheck), `ci-lint` (host actionlint), dazu `docs-check` über das
d-check-Binary aus [`slice-binraire-ziehen-ohne-docker`](../done/slice-binraire-ziehen-ohne-docker.md).
Exit-Klassen, Urteile und die Rezepte-Hilfekommentare bleiben dieselben —
nur der Träger der Umgebung wechselt (Tool-Pin statt Image-Digest allein).
Sobald alle sechs laufen, ist `make gates` docker-los.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der d-check-Beschaffungsweg** — ist
  [`slice-binraire-ziehen-ohne-docker`](../done/slice-binraire-ziehen-ohne-docker.md)
  (Schicht-Abgrenzung); hier wird das Binary nur **aufgerufen**.
- **Die emittierten Ziel-Repos** — sie tragen ihre Rezepte aus
  [`slice-emittierte-gates-host-pfad`](../in-progress/slice-emittierte-gates-host-pfad.md);
  hier steht nur das Labor-Makefile.
- **`fullbuild`, `mutate`, `smoke`/`full-smoke` selbst** — die Treiber-Skripte
  baut [`slice-mutate-treiber-host-modi`](../next/slice-mutate-treiber-host-modi.md)
  und [`slice-smoke-und-full-smoke-ohne-docker`](../next/slice-smoke-und-full-smoke-ohne-docker.md);
  die Rezept-Umstellung reicht an sie, ohne sie zu ändern — die
  `mutate`-Sperren bleiben in Kraft wie sie sind.

## 2. Definition of Done

- [x] **Liefer-Punkt 1:** die sechs Image-Rezepte fahren host-native
      Äquivalente mit Pin aus der Inventar-Form
      ([`slice-environment-check-fuehrt-die-gates`](../done/slice-environment-check-fuehrt-die-gates.md));
      die gepinnten Image-Pfade bleiben als opt-in Weg gepinnt (Pin-Zeilen
      unverändert) und tragen denselben Exit-Vertrag.
- [ ] **Liefer-Punkt 2:** `make gates` fährt auf diesem Host **ohne**
      laufendem Docker-Daemon grün durch (voller Lauf, kein Fast-Pfad-Beleg)
      — exit-Klassen und Urteile unverändert. *(Ausgang: siehe §7 „Was ging
      anders als geplant“ und das Risiko-Register
      [`BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`](../observations/BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante/state.md).)*
- [x] **Liefer-Punkt 3:** bats-Wächter über die Rezept-Formen — Happy (je
      Rezept-Form läuft und urteilt), Negative (fehlende/abweichender
      Tool-Pin → Umgebungs-Befund bricht an) — und die Mutations-Fälle
      nachziehen, deren Anker am Rezept-Text liegen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [ ] `make gates` grün. *(gleicher Ausgang wie Liefer-Punkt 2).*
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [x] Doku-Update: `harness/README.md` §Sensors-Zeilen, sofern die Bindungen
      der Targets umschreiben ([LH-QA-03](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten))
      *(liegt im Arbeitsbaum — ihr Commit läuft am parallel geführten
      Implementer-Lauf, siehe §7).*
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft. *(die Prüfung läuft an der schließenden
      Welle; die Paarungen selbst stehen in §7.)*

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | die sechs Rezept-Texte + die opt-in Image-Pin-Zeilen (bestehend) |
| `test/*.bats` (Rezept-Wächter) | neu / update | Rezept-Wächter je oben |
| `harness/README.md` | update | §Sensors-Zeilen, sofern die Bindungen umschreiben |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-environment-check-fuehrt-die-gates`](../done/slice-environment-check-fuehrt-die-gates.md)
und [`slice-binraire-ziehen-ohne-docker`](../done/slice-binraire-ziehen-ohne-docker.md)
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

- **golangci-lint host-Pfad weicht vom Image-Ergebnis ab** — **Ausgang:
  entfallen** — die Pin-Form trägt die Abweichungsfreiheit (Inventar-Zeile
  `golangci-lint` exakt/abgeleitet, `GO_VERSION`-Pin; Review-Report 2026-11-27,
  „Geprüft, ohne Befund“: die sechs Rezepte, den opt-in Pfad und die Pins).
  Eine beobachtete Urteils-Abweichung zwischen den beiden Wegen liegt nicht
  vor; der Grenz-Lauf derselben Stufe über beide Wege bleibt am opt-in Pfad.
- **Die Mutations-Fälle, die am Dockerfile-Rezept-Text verankern** —
  **Ausgang: entfallen** — je Fall gemessen
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)):
  die Anker am Rezept-Text ziehen nach (Fälle 806–811 greifen, Review-Protokoll),
  der Anker am Dockerfile bleibt (der Image-Pfad steht). Grenze: Fall 810
  bindet seinen Rot-Beleg an die `awk`-Zeichen-Semantik des Ausführungsorts
  (Review-Befund F-4); die Grenze steht im Register
  ([`BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`](../observations/BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante/state.md)).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

- **Was hat funktioniert:** die sechs Rezepte fahren host-native, der opt-in
  Image-Weg bleibt gepinnt und ungestrichen; der Review-Report 2026-11-27
  prüft den Range `a62fbfce..HEAD` ohne Befund gegen die Rezept-Formen, die
  Pins, die Exit-Klassen und die Mutations-Anlagen 806–811. Der parallel
  geführte Lauf reparierte im selben Push die Fork-Bombe des Fast-Pfades
  (`harness/tools/gates-keys.sh`, 6b03706e) und den Review-Befund F-1
  (BATS_ROOT/BATS_LIBDIR am bats-lint-Host-Weg, 9c788a9c).
- **Was ging anders als geplant:** (1) `make gates` ist an dieser Closure
  rot — die Ziel-Modus-Fälle von `test/traeger-fetch.bats` liefern im
  vollen Sweep und in identischen Einzelläufen jeweils andere Rot-Mengen
  (Lauf 1: Fall 3 ok, 5/7/9 rot; Lauf 2: 3/5/7/9 rot), der Auftraggeber-
  Befundlage nach im vollen Sweep rot bei grünem Einzellauf. (2) Der
  Wächter-Fall 6 von `test/targets-modul-wiring.bats`, den die Befundlage
  an 6 fehlenden `exempt-targets`-Namen sah, fällt auch **nach** deren
  Nachtrag: die drei Mengen stehen als Sets identisch (78 Regeln, 18
  Zeilen, 60 ausgenommen — Differenzmenge leer; Nachstellung am Closure-
  Lauf), der Fall fällt an der Ordnungs-Divergenz von `sort`/`comm` im
  Ambient-`en_US.UTF-8`, nicht am Inhalt. Beide Klassen messen
  Umgebungs-/Werkzeug-Varianten des Ausführungsorts statt des
  Prüfgegenstands — sie tragen den Folge-Slice unten, kein Carveout-Artefakt
  (kein stiller Ausnahme-Eintrag in einer Gate-Konfig; die roten Fälle
  bleiben rot sichtbar). (3) Die Konfig-Nachträge der `exempt-targets`
  (dcheck-fetch, traeger-fetch-image, test-bats-image, lint-image,
  shell-lint-image, ci-lint-image) schrieb dieser Closure-Lauf als
  Planner-Nachtrag in eigenem Commit: die Plan-Tabelle §3 führt die
  Gate-Konfig nicht, der Implementer-Lauf war beim Befund abgeschlossen,
  und die Werkzeuge-Zeilen der `harness/README.md` stehen bereits im
  Arbeitsbaum (Lese-Beleg, nicht geändert) — `exempt-targets` ist der Ort
  der Ziele, die nur als Werkzeuge-Zeile (nicht als
  Sensors-Tabellenzeile) liegen. (4) Die Doku-Update-Dateien des Slices
  (`harness/README.md`, `spec/spezifikation.md`, `test/spec-zitates` — 7
  WIP-Dateien) liegen uncommitted im Arbeitsbaum eines parallelen
  Implementer-Laufs; ihr Commit trägt der nächste Implementer-Lauf, kein
  Closure-Schritt (§3.10).
- **Steering-Loop-Eintrag:** benannte Lücke (gezählt, nicht verkörpert —
  kein `liegt in`): „die Weg-Agastik der Wächter endet an den Werkzeugen
  und der Umgebung des Ausführungsorts“ — Klassen: Rezept-Wächter an
  `make`/`git` im gepinnten bats-Image (F-2), Reihenfolge-Flakiness des
  Bats-Sweeps, Sortier-/Zeichen-Semantik des Hosts (Fall-6-Divergenz,
  F-4). Der Gegenstand übernimmt
  [`slice-waechter-umgebungs-robustheit`](../done/slice-waechter-umgebungs-robustheit.md);
  verkörpert ist, was dort liegt — bis dahin steht der Lerneintrag gezählt
  im Register (Ausgang dort: geplant).
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`](../observations/BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante/state.md)
  neu angelegt, Beleg `evidence/slice-labor-gates-host-rezepte.md` — der
  Zähler steht damit bei 1×.
- **Folge-Slices:**
  [`slice-waechter-umgebungs-robustheit`](../done/slice-waechter-umgebungs-robustheit.md)
  (die Wächter-Suite misst unabhängig von der Werkzeug-Umgebung des Laufs)
  — ist eine Datei in `next/`, in der Welle §4 nachgetragen.
- **Risiken aus §6:** beide entfallen (oben), je mit Grenze.
- **Drei Paarungen:** Anker — mit diesem Slice wurde nichts verkörpert, es
  gibt keinen (der Lerneintrag ist gezählt) · Folge-Slice —
  [`slice-waechter-umgebungs-robustheit`](../done/slice-waechter-umgebungs-robustheit.md),
  übernimmt die Klassen und trägt F-3 (Prosa des `docs-check`-Sensor-Texts)
  als Liefer-Punkt 3 · Register —
  [`BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`](../observations/BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante/state.md)
  (Ausgang geplant, Kennung oben) — die Prüfung der Paarungen trägt die
  schließende Welle (offen).

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
