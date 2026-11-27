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
Doku-Nachzug: [`slice-doku-nachzug-ohne-docker`](slice-doku-nachzug-ohne-docker.md)).*

**Verantwortlich:** —

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

- [ ] **Liefer-Punkt 1:** der Treiber fährt Vorlauf und Fall-Sensor-Läufe
      host-native — `green_prerun` und `run_case` rufen die host-Rezepte; ein
      voller Lauf (`MUTATE_FORCE=1`) auf einem Host **ohne** Docker-Daemon
      läuft bis zum Bericht durch.
- [ ] **Liefer-Punkt 2:** die Umgebungs-Vorbedingung: der Treiber fährt
      `environment-check` (oder dessen Kern-Check) **vor** dem Fall-Satz;
      fehlt ein Werkzeug oder weicht es ab → Umgebungs-Befund mit
      Werkzeug · Soll · Ist und Exit-Klasse getrennt von Test-Ausgängen -
      kein Fall läuft, keine Isolationskopie entsteht, der Beleg-Slot
      bleibt unberührt.
- [ ] **Liefer-Punkt 3:** der Mutations-Wächter (`test/mutate-driver.bats`)
      trägt die Form: Happy (Teillauf docker-los grün), Negative
      (Umgebungs-Befund bricht vor der Isolationskopie, der Befund nennt
      die Ursache) — neue Fälle je
      [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      (Vertrag, Grenzen) — Doku-Nachzug im
      [`slice-doku-nachzug-ohne-docker`](slice-doku-nachzug-ohne-docker.md),
      hier nur die Zeilen, die *der Treiber-Vertrag* nennt.
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
  [`slice-smoke-und-full-smoke-ohne-docker`](slice-smoke-und-full-smoke-ohne-docker.md)**
  — **Ausgang:** bis dahin brechen sie an derselben Umgebungs-Vorbedingung
  (Umgebungs-Befund mit Ursache), nicht an einem Fall-Ausgang; die
  Werkzeug-Abwesenheit ist benannt, nicht still.
- **Der Beleg-Slot über dem docker-los Weg** — **Ausgang:** derselbe
  Beleg-Vertrag bleibt ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md));
  der Schlüssel (Prüfgegenstand) bleibt baum-abgeleitet — der Träger der
  Umgebung wechselt nicht den Schlüssel.

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
