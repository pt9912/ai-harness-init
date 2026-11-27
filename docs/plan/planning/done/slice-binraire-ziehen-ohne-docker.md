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

**Verantwortlich:** pt9912

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
  [`slice-labor-gates-host-rezepte`](../next/slice-labor-gates-host-rezepte.md) an die
  Rezepte angedockt; hier entsteht nur die Beschaffung (`make`-Ziele für den
  Binär-Zugang und ihre Pin-Prüfung).

## 2. Definition of Done

- [x] **Liefer-Punkt 1:** ermittelt und gebaut ist der docker-lose Weg je
      Binär (d-check: welche Quelle trägt ein pinierbares Release-Artefakt —
      upstream release, `docker create`/`cp` nur als Bestand mit Docker?
      Träger: Netz-Fetch ohne Container) — die Messung steht im Slice (§7);
      je Binär ein `make`-Target, das ohne Daemon zieht.
      *Beleg:* d-check per OCI-Digest-Pull (`make dcheck-fetch`,
      `harness/tools/dcheck-fetch.sh`), Träger-Fetch host-native
      (`make traeger-fetch`, `harness/tools/traeger-fetch-host.sh`); die
      Beschaffungs-Messung trägt 15cb3586
      ([`harness/sensors/dcheck-fetch.md`](../../../../harness/sensors/dcheck-fetch.md)
      §Weg).
- [x] **Liefer-Punkt 2:** je Binär trägt die Pin-Kopplung die [ADR-0059](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)-Form:
      Tag-Pin + Prüfsumme je Asset, Paarung nach Asset-Name; ein Pin ohne
      Prüfsumme bricht fail-closed. Die Pin-Prüfung läuft
      **vor** dem ersten Gebrauch (über
      [`harness/README.md`](../../../../harness/README.md) §Sensors als
      Index-Zeile bei den bestehenden `traeger-*`-Zeilen dokumentiert).
      *Beleg:* Digest-Kette je Stufe (Index → Manifest → Blob, gehasht je
      Blob) fail-closed ohne Ablage; Index-Zeilen `make dcheck-fetch`,
      `make traeger-fetch` unter §Sensors — 15cb3586, F-2..F-6 edf99b05.
- [x] **Liefer-Punkt 3:** bats-Wächter über die neuen Target-Rezepte —
      Happy (Fetch zieht, Prüfsumme grün), Negative ( Prüfsummen-Abweichung
      bricht fail-closed; fehlende Prüfsumme an einem gepinnten Tag bricht) —
      Mutations-Fälle je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
      gemessen an der realen Quelle.
      *Beleg:* [`test/dcheck-fetch.bats`](../../../../test/dcheck-fetch.bats),
      [`test/traeger-fetch-host.bats`](../../../../test/traeger-fetch-host.bats)
      plus env-check-Fälle, hermetisch je Stub-Registry; Mutations-Fälle
      799–803 — 15cb3586, N-1/N-3 5f0c0598.
- [x] `make gates` grün — **bedingt, Verweis auf
      [Carveout CO-007](../../carveouts/CO-007-ci-rot-vorgefunden-gates-und-full-smoke.md)**:
      lokal nicht gefahren (kein Docker-Daemon, siehe
      [`AGENTS.md`](../../../../AGENTS.md) §3.9); CI auf `main` rot an
      `full-smoke` — Altbestand-Archivierung-Klasse, Trigger CO-007
      (Abschluss von welle-ohne-docker), nicht Slice-Code. Die Slice-eigene
      Werkzeug-Abdeckung trägt der Verifikations-Bericht (812f80b9).
- [x] Review durchgeführt, Report liegt vor:
      [`docs/reviews/2026-11-27-slice-binraire-ziehen-ohne-docker.md`](../../reviews/2026-11-27-slice-binraire-ziehen-ohne-docker.md)
      (a6c70467; Addendum c6b4d798) — F-1 HIGH, F-2..F-6 LOW gelöst
      (edf99b05), N-1/N-3 nachgezogen (5f0c0598); kein Self-Review (Modul 8).
- [x] Doku-Update: `harness/README.md` §Sensors-Zeilen (15cb3586;
      §Wächter-Aufzählung des d-check-Vertrags N-3, 5f0c0598).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — §7, dieser Commit.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei in der bestehenden Klasse
      `BEO-ALL/mutations-fall-skript-direkt-im-arbeitsbaum-gestartet`
      (3. Beleg), Ausgang im selben Commit (ADR-0085 Festlegung 1).
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen) — §7.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) — Ergebnis in §7;
      die erneute Prüfung durch die Welle-Closure bleibt Pflicht.

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

- **Was hat funktioniert:** Die Beschaffungs-Messung vor der Weg-Wahl —
  Upstream `d-check` führt kein pinierbares Release-Binary
  (`releases/latest` → `"assets": []`), der Ansatz-Fallback „Klon+Build"
  war nicht nötig: der Registry-Blob-Zug führt den bestehenden
  Digest-Pin als denselben Pin weiter (kein zweiter Pin-Bestand,
  pinsync-Paarung unberührt; [`harness/sensors/dcheck-fetch.md`](../../../../harness/sensors/dcheck-fetch.md)
  §Weg). Die OCI-Kette prüft je Stufe (Index → Manifest → Blob) gegen
  den vorigen Digest, 13 Layer je Blob-Digest, fail-closed ohne
  Ablage-Residuum; das Registry-Präfix haftet hart an der geprägten Quelle
  `ghcr.io`. Der Träger-Fetch wird host-native (`make traeger-fetch`),
  der opt-in Image-Weg bleibt gepinnt. Nach dem Slice ist
  `make environment-check` 11/11 — der d-check-Anwesenheitsbefund ist weg;
  das Inventar trägt die fetched Ablage als ausdrücklich benannte
  Erweiterung (SPEC-099 geschärft). Review (F-1 HIGH, F-2..F-6 LOW) und
  Nachzüge (N-1/N-3) liefen ohne Folge-Befund gegen die Pin-Einheit und
  die fail-closed-Kette.
- **Was ging anders als geplant:** Der d-check-Access wurde Review-HIGH
  (F-1): die Weg-Wahl-Abwägung stand doppelt — Skriptkopf und Sensor-Datei —
  und gehört einmal in die Sensor-Datei; der Skriptkopf trägt danach Zustand
  und Rang-Zeiger (edf99b05). Die drei `grep`-Ketten des Fetch-Skripts
  brachen still unter `set -euo pipefail` (Exit 1, bevor ihr
  fail-closed-Wächter überhaupt erreichte) — N-3 korrigiert mit `|| true`
  (5f0c0598); Klasse: ein fail-closed-Wächter unter erhabenem `set -e`
  braucht einen stillen Stillbruch-Übergang. Test 5 der bats-Fälle läuft am
  hermetischen `env: 'bash'` mit engem `PATH` — seine Deckung in der
  Docker-Stage (`test-go`) ist dadurch nicht geklärt und gehört als
  Rest-Übergabe weiter (unten).
- **Steering-Loop-Eintrag:** kein `liegt in`-Feld — der Eintrag ist
  beobachtend, nicht verkörpert; die Verkörperung ist Entscheidung der
  Welle-Closure (Zug 3b). Eintrag: die Klasse
  [`BEO-ALL/mutations-fall-skript-direkt-im-arbeitsbaum-gestartet`](../observations/BEO-ALL/mutations-fall-skript-direkt-im-arbeitsbaum-gestartet/state.md)
  erreicht mit diesem Slice 3× (Lese-Schritt ist diese Closure, ADR-0085
  Festlegung 1). Kandidaten-Regel für die Verkörperung: *kein
  Mutations-Fall-Skript direkt im Arbeitsbaum starten* — Kopie oder
  `make mutate`/`make mutate-greift`; Zielort-Kandidaten sind die
  Rollen-Sätze (`.claude/commands/implement-slice.md`,
  `.claude/agents/verifier.md`) und
  [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md).
  · seit slice-binraire-ziehen-ohne-docker
- **Beobachtungs-Register (`../observations/`):** der Implementer-Fund
  (ein Mutations-Fall fuhr je Direktaufruf und verfälschte den realen
  Bestand; heil restauriert und am Diff gegen den Basisstand geprüft) trifft
  exakt die bestehende Klasse
  `BEO-ALL/mutations-fall-skript-direkt-im-arbeitsbaum-gestartet` — kein
  neues Verzeichnis; dritter Beleg als
  [`evidence/slice-binraire-ziehen-ohne-docker.md`](../observations/BEO-ALL/mutations-fall-skript-direkt-im-arbeitsbaum-gestartet/evidence/slice-binraire-ziehen-ohne-docker.md),
  Ausgang `geplant` im selben Commit (ADR-0085 Festlegung 1). Paarung (c)
  über das ganze Register: ein Verzeichnis ohne `evidence/*.md` —
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/`.
- **Folge-Slices / Rest-Übergaben:** kein Folge-Slice neu angelegt; die
  Reste tragen benannte Träger — (1) **Mutations-CI-Konsum offen:** Run
  `45959944410` (Attempt 1, `in_progress` beim Abschluss dieses Slices) zum
  geprüften Commit `15cb3586`, Branch
  `mutate/slice-binraire-ziehen-ohne-docker-15cb3586`; Konsum je
  [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) §CI-Branch:
  `git fetch origin mutate/slice-binraire-ziehen-ohne-docker-15cb3586 && git
  show FETCH_HEAD:mutate-ergebnis.txt` → Fassung nach
  `.harness/stamp/mutate/slice-binraire-ziehen-ohne-docker-15cb3586-<form>.txt`
  → Commit auf `main` → erst dann Branch-Löschung. Träger: der
  übergeordnete Lauf. Bis zum Abschluss bleibt der Branch stehen. Bisher:
  shard 0/1 grün, shard 2/5 rot mit Exit 143 (SIGTERM — Infra-Deutung,
  Qualifikator-Kandidat `infra`). Deckungs-Grenze: der Branch tippt
  `15cb3586` — die Fix-Commits `edf99b05`/`5f0c0598` sind im CI-Umfang
  nicht; ihre Rot-Belege tragen die lokal gefahrenen Hand-Mutationen
  (Implementer, Verifier). (2) Der CI-Run war beim Verifier unvollständig:
  shard 3/4/6/7/8/9 liefen noch — ihr Ausgang ist Teil des selben Konsums.
  (3) Test-5-Deckung in der Docker-Stage — Übergabe an den übergeordneten
  Lauf (Folge-Slice oder Welle-Closure schneiden). (4) Befund-Rückstand
  784/785/794 — bleibt beim Schwesterslice. (5) Die drei CI-Störstellen —
  Träger ist [CO-007](../../carveouts/CO-007-ci-rot-vorgefunden-gates-und-full-smoke.md)
  mit Ereignis-Trigger (Abschluss von welle-ohne-docker).
- **Risiken aus §6:** *Upstream d-check führt kein pinierbares Release* —
  **eingetreten:** die Messung bestätigte es (`"assets": []`); geschultert
  über die ADR-0109-Synthese (Weg-D-Form,
  [`slice-adr-gates-laeufen-host-native`](../done/slice-adr-gates-laeufen-host-native.md)
  in done/) und die Weg-Wahl dieses Slices
  ([`harness/sensors/dcheck-fetch.md`](../../../../harness/sensors/dcheck-fetch.md)
  §Weg). *Netz-Aufrufe breiten sich aus* — **entfallen:** der Netz-Vertrag
  blieb derselbe wie vor dem Slice — Netz nur an den zwei Fetch-Aufrufen,
  beide als Index-Zeile unter §Sensors in
  [`harness/README.md`](../../../../harness/README.md); kein zusätzlicher
  Netz-Aufruf ist in die Gates gerutscht.
- **Drei Paarungen:** Anker — §7 trägt kein `liegt in`-Feld (Eintrag
  beobachtend), nichts zu prüfen. Folge-Slice — keiner neu angelegt; die
  Rest-Übergaben (1)–(5) tragen ihre benannten Träger. Register — Paarung
  (c) gefahren: ein belegloses Verzeichnis (`einstiegs-datei-…`,
  oben benannt); die Hälfte ist als Befund behauptet, nicht als getragen.

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
