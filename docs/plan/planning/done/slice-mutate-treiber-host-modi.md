# Slice slice-mutate-treiber-host-modi: der Mutations-Treiber fährt docker-los

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
(docker-los-Pfad — der Treiber fährt ohne Daemon),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Sperren bleiben fail-closed; die Diagnose nennt die Ursache),
[ADR-0109](../../adr/0109-…-gates-laeufen-docker-los.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->,
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin je neuem Fall).

**Berührte Spec-Stellen:** — *(der Treiber ist kein Spec-Artefakt; die
Sensor-Texte `harness/sensors/mutate.md`/`gates.md` tragen den Vertrag —
Doku-Nachzug: [`slice-doku-nachzug-ohne-docker`](../next/slice-doku-nachzug-ohne-docker.md)).*

**Verantwortlich:** pt9912

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** der Treiber (`harness/tools/mutate.sh`) fährt seinen Prüf- und
Vorlauf-Zug vollständig ohne Docker-Daemon: der Grün-Vorlauf (`green_prerun`)
und je Fall der Sensor-Lauf (`run_case`, `( cd "$WORK" && make "$verify" )`)
laufen über die host-native Gate-Rezepte
([`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md)); der
Treiber startet mit einer `environment-check`-Vorbedingung — fehlt ein
Werkzeug oder weicht es vom Pin ab, bricht der Lauf mit Umgebungs-Befund ab
(die Diagnose nennt Werkzeug · Soll · Ist), nicht an einem Fall-Ausgang. Die
Sperren-Meldung unterscheidet die Ursache: Umgebungs-Befund ≠ Test-Fehlschlag
(Befund-Klasse, [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Fall-Anlage (316 Fälle) wird nicht umgeschrieben** — die Fälle
  bleiben; nur das, was ihre `# verify:`-Modi ausführen, hat geändert
  (host-Rezepte). Fall-Anker am Rezept-Text werden in
  [`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md)
  nachgemessen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
- **`mutate-greift` bleibt, wie es ist** — es läuft schon docker-los
  (Sensors-Text [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
  §Greift-Modus: „Kein Grün-Vorlauf, kein Sensor-Lauf, kein Lock, kein
  Beleg-Slot, kein Docker"); Bestand bleibt bewusst stehen.
- **Der Beleg-Slot, Lock, `MUTATE_JOBS`** — die Mechanik bleibt (Beleg-
  Übersprung, Sperren, Worker-Verteilung); nur der Träger der Sensor-Läufe
  wechselt.

## 2. Definition of Done

[x] **Liefer-Punkt 1:** der Treiber fährt Vorlauf und Fall-Sensor-Läufe
      host-native — `green_prerun` und `run_case` rufen die host-Rezepte; ein
      voller Lauf (`MUTATE_FORCE=1`) auf einem Host **ohne** Docker-Daemon
      läuft bis zum Bericht durch.
[x] **Liefer-Punkt 2:** die Umgebungs-Vorbedingung: der Treiber fährt
      `environment-check` (oder dessen Kern-Check) **vor** dem Fall-Satz;
      fehlt ein Werkzeug oder weicht es ab → Umgebungs-Befund mit
      Werkzeug · Soll · Ist und Exit-Klasse getrennt von Test-Ausgängen -
      kein Fall läuft, keine Isolationskopie entsteht, der Beleg-Slot
      bleibt unberührt.
[x] **Liefer-Punkt 3:** der Mutations-Wächter (`test/mutate-driver.bats`)
      trägt die Form: Happy (Teillauf docker-los grün), Negative
      (Umgebungs-Befund bricht vor der Isolationskopie, der Befund nennt
      die Ursache) — neue Fälle je
      [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit).
- [ ] `make gates` grün.
[x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
[x] Doku-Update: [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      (Vertrag, Grenzen) — Doku-Nachzug im
      [`slice-doku-nachzug-ohne-docker`](../next/slice-doku-nachzug-ohne-docker.md),
      hier nur die Zeilen, die *der Treiber-Vertrag* nennt.
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
| `harness/tools/mutate.sh` | update | `main`-Einstieg: Umgebungs-Vorbedingung; `green_prerun`/`run_case` rufen host-Rezepte |
| `test/mutate-driver.bats` | update / neu | Happy/Negative je oben |
| `test/mutations/<neue Fälle>` | neu | Umgebungs-Befund-Zweig je Anlage-Form |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md) liegt in
`done/` — die host-Rezepte stehen; der Treiber ruft sie.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa, wenn die `MUTATE_JOBS`-Verteilung an der
  Umgebungs-Vorbedingung eine je-Worker-Messung braucht → re-slicen.
- `in-progress` → `open` (blockiert — Carveout?): ein `# verify:`-Modus hat
  kein host-Äquivalent (nach
  [`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md)), und
  der Treiber kann ihn nicht fail-closed auswerten → Carveout-Kläung an der
  ADR-0109-Platzhalter-Synthese.

## 5. Closure-Trigger

DoD (§2) vollständig; im Verifikations-Bericht steht der reale Lauf: ein
Teillauf (`MUTATE_CASES='<zwei echte Fälle>'`) docker-los grün und der
Negative (manipulierte Inventar-Zeile → Umgebungs-Befund, vor der
Isolationskopie). Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die 64 schweren Fälle (`smoke`/`full-smoke`) laufen erst nach
  [`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md)**
  — **Ausgang:** eingetreten — die Entkoppelung trägt
  [`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md);
  bis dahin brechen die 64 Fälle an der gebauten Daemon-Vorbedingung
  (Umgebungs-Befund, Exit 4), nicht an einem Fall-Ausgang; die
  Werkzeug-Abwesenheit ist benannt, nicht still (Verifikations-Bericht,
  Vorbestand-Klasse 5).
- **Der Beleg-Slot über dem docker-los Weg** — **Ausgang:** derselbe
  Beleg-Vertrag bleibt ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md));
  der Schlüssel (Prüfgegenstand) bleibt baum-abgeleitet — der Träger der
  Umgebung wechselt nicht den Schlüssel. — **Ausgang:** entfallen — der
  Beleg-Vertrag blieb unverändert (der Teillauf meldet `TEILLAUF 1 von 800 —
  kein Beleg`), die Umgebungs-Vorbedingung bricht vor Beleg-Lesung und
  Isolationskopie (Verifikations-Bericht, Läufe 1 und 3).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

**Closure-Notiz (Rolle Planner, 2026-11-27)** — Quellen: eigener Lauf, der
Verifikations-Bericht
([`docs/reviews/2026-11-27-slice-mutate-treiber-host-modi-verify.md`](../../reviews/2026-11-27-slice-mutate-treiber-host-modi-verify.md))
und der Review-Report
([`docs/reviews/2026-11-27-slice-mutate-treiber-host-modi.md`](../../reviews/2026-11-27-slice-mutate-treiber-host-modi.md),
F-1 LOW im Fix `3f29742d` behoben).

- **Was hat funktioniert:** die Vorbedingungs-Kette trägt — der Umgebungs-
  Befund (Werkzeug · Soll · Ist, make `Fehler 4`) bricht **vor** Beleg-Lesung,
  Entwertung und Isolationskopie (Negativ-Lauf: manipulierte Inventar-Zeile,
  kein Fall läuft, kein Lock-Rest, Beleg-Slot unberührt); der Teillauf
  `10-ci-workflow-syntax` läuft docker-los grün bis zum Bericht (Exit 0,
  `TEILLAUF 1 von 800 — kein Beleg`); alle fünf neuen/berührten Anlagen
  (784/785/814/815/816) sind an der realen Quelle je einmal rot gesehen
  (Zug-Tabelle des Verifikations-Berichts), der Exit-Vertrag je Treiber-Stufe
  hält an der Sensor-Doku.
- **Was ging anders als geplant:** (1) LP 1 mit Grenze — der **volle** Lauf
  (`MUTATE_FORCE=1`) läuft an diesem Bestand nicht bis zum Bericht: der
  Grün-Vorlauf bricht fail-closed an den zwei vorbestehenden test-go-Klassen
  und benennt die Ursache; §5s „zwei echte Fälle" ist nicht in der geforderten
  Form am Vorbestand erreichbar (Fall 778 am shell-lint-Vorbestand, Lauf 2) —
  die Vollform trägt die Welle/CI nach dem Vollgrün. (2) `make gates` ist an
  dieser Closure rot an den **fünf vorbestehenden Klassen** — docs-check 114
  Befunde (am Claim `ffe3c1eb` byte-identisch, diff-tragende Pfade 0 Befunde),
  bats Fall 273, test-go zwei Klassen (GO_VERSION-Drift, Stop-Hook-Bindung),
  shell-lint SC2254/SC2016 an 797–801, smoke/full-smoke-Entkoppelung (Exit 4)
  beim Folge-Slice — keine aus dem Diff, kein Carveout-Artefakt. (3) F-1 LOW
  (rot-Grund-Zeile des Falls 785) ist im Fix `3f29742d` behoben; der Rand der
  Grenz-Mutation bleibt über den Bestands-Test gebunden.
- **Steering-Loop-Eintrag:** geschärfte Regel (gezählt, nicht verkörpert —
  kein `liegt in`): **der Beleg-Übersprung läuft hinter der Umgebungs-Vorbedingung
  — kein Fall läuft, keine Isolationskopie entsteht, bevor der Träger der
  Läufe seinen Soll-Stand belegt hat** (Diagnose nennt Werkzeug · Soll · Ist,
  Exit-Klasse getrennt von jedem Test-Ausgang). Grenze/Übergabe (nicht
  still übernommen): die Spur-/Modus-Klassifikation über die 267 der 316
  blockierten Fälle ist am Treiber benannt und nicht geplant — Übergabe-
  Artefakt an die Welle-Planung (Treiber-Schnitt über die host-Rezept-Pläne,
  Sensor-Doku „Spur-Grenze").
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md)
  — Ausgang dieses Slices (die Ursachentrennung ist Treiber-Vertrag geworden),
  Beleg
  [`evidence/slice-mutate-treiber-host-modi.md`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/evidence/slice-mutate-treiber-host-modi.md),
  Zähler 2, unter der Schwelle. Der zweite §8-Treffer
  ([`BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`](../observations/BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf/state.md),
  4 Vorgänge über der Schwelle) — kein Übertritt: der Beleg-Vertrag blieb
  unverändert, sein Bestands-Ausgang steht (Treiber-Rest).
- **Folge-Slices:**
  [`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md)
  (Entkoppelung der 64 schweren Fälle, §6-Risiko 1) ·
  [`slice-doku-nachzug-ohne-docker`](../next/slice-doku-nachzug-ohne-docker.md)
  (Rest des Doku-Nachzugs).
- **Risiken aus §6:** 64 schwere Fälle — eingetreten, Folge-Slice oben ·
  Beleg-Slot — entfallen (oben).
- **Drei Paarungen:** Anker — der Lerneintrag oben ist gezählt, es gibt
  keinen `liegt in` · Folge-Slices —
  [`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md)
  und [`slice-doku-nachzug-ohne-docker`](../next/slice-doku-nachzug-ohne-docker.md)
  · Register —
  [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md)
  (Zähler 2). Die Prüfung der Paarungen trägt die schließende Welle.

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

- [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md)
  — 1 Vorgang (< 3×): ein Docker-Aussetzer wird als falscher Grund gemeldet
  — hier wird die Ursachentrennung zum Vertrag (Umgebungs-Befund ≠
  Test-Ausgang); der Ausgang des Bestands bleibt.
- [`BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`](../observations/BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf/state.md)
  — 4 Vorgänge, über der Schwelle; Ausgang steht im Bestand (belegt, der
  Treiber-Rest). Kein Übertritt mit diesem Slice — der Beleg-Vertrag bleibt.

Keine Treffer unter der Schwelle jenseits der genannten.

**Modus-Begründigungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
