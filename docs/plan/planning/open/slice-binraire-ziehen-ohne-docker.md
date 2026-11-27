# Slice slice-binraire-ziehen-ohne-docker: Binär-Beschaffung ohne Docker (d-check, Träger)

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
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(der Pin des Binärs trägt auch docker-los — über Tag + Prüfsummen, nicht über
den Image-Digest allein),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(docker-los-Pfad — auch das Werkzeug-Binary kommt ohne Daemon aus),
[ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
(Träger per Fetch aus dem gepinnten Release — der Mechanismus bleibt, der
Träger des Fetches wechselt),
[ADR-0059](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(SHA256SUMS reisen als Release-Asset — die Prüfform bleibt),
[`ADR-0109`](../../adr/0109-…-gates-laeufen-docker-los.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->
(docker-los Default),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(Baseline bleibt committet vendored — kein Fetch pro Lauf).

**Berührte Spec-Stellen:** `spec/spezifikation.md` §Pins/Fetch (d-check-Quelle
und Träger-Fetch). Der Verweis zeigt **aufwärts**.

**Verantwortlich:** —

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die zwei Binär-Werkzeuge des Labors sind beschaffbar, ohne dass ein
Docker-Daemon läuft: (a) das **d-check-Binary** — heute nur über den gepinnten
Image-Digest ziehbar (`docker run … ghcr.io/pt9912/d-check@sha256:…`) — bekommt
einen docker-losen Beschaffungsweg mit Pin (Tag + Prüfsumme gegen eine
Prüfsummen-Ablage, ADR-0059-Form), (b) der **Träger-Fetch** (`make traeger-fetch`,
[ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md))
kehrt vom curl-Container auf einen docker-losen Fetch um, der denselben Pin
(`TRAEGER_TAG`) und dieselbe Prüfsummen-Form trägt. Netz darf an genau diesen
Aufrufen — derselbe Vertrag wie heute.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der vendored Baseline-Baum bleibt committet** — er ist netzlos auf jedem
  Checkout ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache));
  ein Baseline-Refresh-Weg ist ein anderer Vorgang (Slices
  `baseline-freshness`/`vendor-baseline` bleiben, wie sie sind).
- **Die Image-Pfade entfallen nicht** — `docker`-fahrende Fassungen bleiben
  als opt-in Weg gepinnt ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  ADR-0109-Platzhalter); der Host-Weg kommt dazu, statt sie zu ersetzen.
- **Kein Gates-Verdrahtung** — der d-check-Host-Pfad wird von
  [`slice-labor-gates-host-rezepte`](slice-labor-gates-host-rezepte.md) an die
  Rezepte angedockt; hier entsteht nur die Beschaffung (`make`-Ziele für den
  Binär-Zugang und ihre Pin-Prüfung).

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** ermittelt und gebaut ist der docker-lose Weg je
      Binär (d-check: welche Quelle trägt ein pinierbares Release-Artefakt —
      upstream release, `docker create`/`cp` nur als Bestand mit Docker?
      Träger: Netz-Fetch ohne Container) — die Messung steht im Slice (§7);
      je Binär ein `make`-Target, das ohne Daemon zieht.
- [ ] **Liefer-Punkt 2:** je Binär trägt die Pin-Kopplung die [ADR-0059](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)-Form:
      Tag-Pin + Prüfsumme je Asset, Paarung nach Asset-Name; ein Pin ohne
      Prüfsumme bricht fail-closed. Die Pin-Prüfung läuft
      **vor** dem ersten Gebrauch (über
      [`harness/README.md`](../../../../harness/README.md) §Sensors als
      Index-Zeile bei den bestehenden `traeger-*`-Zeilen dokumentiert).
- [ ] **Liefer-Punkt 3:** bats-Wächter über die neuen Target-Rezepte —
      Happy (Fetch zieht, Prüfsumme grün), Negative ( Prüfsummen-Abweichung
      bricht fail-closed; fehlende Prüfsumme an einem gepinnten Tag bricht) —
      Mutations-Fälle je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
      gemessen an der realen Quelle.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: `harness/README.md` §Sensors-Zeilen (offentlicher Vertrag).
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
| `Makefile` | update | Targets für den docker-losen Binär-Fetch (d-check, Träger) + Pin-Zeilen je Asset |
| `harness/tools/fetch-<werkzeug>.sh` (Name beim Implementer) | neu | Netz-Fetch mit Pin + Prüfsumme (Netz nur an diesem Aufruf) |
| `test/<werkzeug>-fetch.bats` | neu | Happy/Negative je oben |
| `harness/README.md` | update | §Sensors-Zeilen der neuen Targets |

**Ansatz als Liste (ergänzt die Tabelle):**

- Der d-check-Zugang ist **der Offene Punkt mit Messauftrag**: ob upstream ein
  pinierbares Release-Binary führt, wird vor dem Schnitt gemessen (§7 trägt
  das Ergebnis); trägt es keines, fällt der Weg auf „Repository-Klon bei
  Pin-Commit + `go build` mit Inventar-Pin `GO_VERSION`" mit demselben
  Prüfsummen-Vertrag — die Entscheidung steht dann in der ADR-0109-Platz-
  halter-Synthese, nicht still im Skript.

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-adr-gates-laeufen-host-native`](../done/slice-adr-gates-laeufen-host-native.md)
liegt in `done/` (die Weg-Form steht), und
[`slice-environment-check-fuehrt-die-gates`](../done/slice-environment-check-fuehrt-die-gates.md)
nennt curl/d-check als Inventar-Zeile (der Check sagt, was der Fetch braucht).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa, wenn d-check ein eigenes Prüfsummen-Format braucht
  (Signatur statt SHA256) → re-slicen, dann ein Binär je Teil.
- `in-progress` → `open` (blockiert — Carveout?): upstream führt **kein**
  pinierbares Artefakt für d-check — dann Carveout-Kläung an der ADR-0109-
  Synthese (Klon+Build-Weg ist der Vorschlag oben) und der Slice steht off.

## 5. Closure-Trigger

DoD (§2) vollständig; im Verifikations-Bericht steht je Binär der reale
Beschaffungslauf **ohne laufendem Docker-Daemon** (Fetch grün, Prüfsumme
grün) und der Negative (manipulierte Prüfsumme → bricht). Zusätzlich:
Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Upstream d-check führt kein pinierbares Release** — **Ausgang:** der
  Klon+Build-Weg mit inventar-gepintem `GO_VERSION` ist der Vorschlag im
  Ansatz; die Entscheidung trägt die ADR-0109-Platzhalter-Synthese.
- **Netz-Aufrufe breiten sich aus** (jedes Ziel zieht eigene Bytes) —
  **Ausgang:** der Netz-Vertrag bleibt derselbe wie heute (Netz an genau
  diesen Aufrufen, sonst keine Netzannahme); ein neuer Aufruf ohne Index-
  Zeile wäre ein Review-Befund.

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
≥ 2 von 3 Achsen (Modus-Deklaration, Phase 5, Evidenz über Netz-Fetch-Pfade).

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer:

- [`BEO-ALL/anonymes-hub-rate-limit-faerbt-den-nacht-lauf-der-digest-achse`](../observations/BEO-ALL/anonymes-hub-rate-limit-faerbt-den-nacht-lauf-der-digest-achse/state.md)
  — 1 Vorgang (< 3×): Registry-Rate-Limits färben die Digest-Achse — der
  docker-lose Fetch-Zug verlegt die Quelle auf Release-Assets; der Bestand
  (`freshness-digest`) bleibt, die Grenze des Winkels ist sein Bestand.
- [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md)
  — 1 Vorgang (< 3×): CI kann gegen eine nicht-yet-publikation laufen — der
  Fetch-Weg braucht dieselbe Sperre wie `make release-warten`. Notiert, nicht
  gelöst hier.

Keine Treffer unter der Schwelle jenseits der genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
