# Slice slice-release-bau-dockerlos-v1: Release-Bau docker-los — Cross-Kompilierung host-nativ aus CI

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung, die von der DoD dieses Slices
verschieden ist
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird));
die Umstellung je [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md)
Festlegung 6 trägt je Slice.

**Bezug:** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) (die bindende
Fassung, Festlegungen 1–6),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (revidiert je Teil-Supersede),
[`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md),
[`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4,
[`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
[`MR-098`](../../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit).

**Berührte Spec-Stellen:** `ARC-012`, `ARC-013`
(`spec/architecture.md` §3 — die Festlegung-5-Fortschreibung trägt der
Architect-Commit `90930bf8` bereits; dieser Slice liest sie als Soll). Der
Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** pt9912 (Zweig slice-release-bau-dockerlos-v1)

**Autor:** pt9912 (Rolle Planner). **Datum:** 2026-11-28.

---

## 1. Ziel und Abgrenzung

**Ziel:** der Release-Bau läuft host-nativ, docker-los — neues make-Ziel
`make release-artifacts-host` je
[`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) Festlegungen 1
und 6 (Tafel über `RELEASE_PLATFORMS`, `Makefile` Zeile 268, gemessen:
`grep -n 'RELEASE_PLATFORMS' Makefile`; Form des Rezepts `make host-bin`,
`Makefile` Zeile 619, gemessen: `grep -n '^host-bin:' Makefile`): je der
sechs Plattformen
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ein
Cross-Compile mit `CGO_ENABLED=0`/`GOOS`/`GOARCH`/`-trimpath`, ldflags je
[`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
Festlegung 1 aus `TRAEGER_VERSION`, danach `harness/tools/release-sums.sh
generate` und die Homebrew-Formel am selben Ort
([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Folgepflicht 1). Der `artifacts`-Job der
[release.yml](../../../../.github/workflows/release.yml) ruft nur dieses Target
([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
Setzung 1, Form
[`ADR-0111`](../../adr/0111-ci-stempel-eingecheckt-committed-je-check-keys.md)
Festlegung 2) und erhält die Toolchain aus dem `GO_VERSION`-Pin des
`Makefile` (Mischform je [`MR-098`](../../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host),
am Pin geprüft je [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4) — die Entfallen-Grenze des gepinnten Bildes tritt an die
Stelle der Kopfkommentar-Grenze von heute (`grep -n 'bleibt im gepinnten
Bild' .github/workflows/release.yml` → Zeile um die 20). Der Repro-Träger
wandert vom Image-Digest zum Inventar-Pin
([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
Festlegung 3): zwei Läufe desselben Baums mit derselben Pin-Fassung liefern
byte-identische `SHA256SUMS`. Nach dem Umstellungszug heißt
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
wörtlich: kein Pflicht-Pfad dieses Repos braucht docker.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Tag-Schnitt und die Pin-Nachzüge** (`TRAEGER_TAG`, die sechs
  `TRAEGER_SHA256_*`, der Tag-Pin des Traeger-Fetch-Emits) — ein
  Folge-Slice übernimmt es:
  `slice-traeger-tag-nachzug-untergrenze-v1` (liegt in `in-progress/`,
  sein §1 nennt den Schnitt selbst und nimmt damit die Adresse an). Dieser
  Slice liefert nur die Bau-Form und ihre CI-Verdrahtung; der neue Tag, an
  dem die Kette erst Publikation trägt, ist dessen Gegenstand.
- **Rückbau der gepinnten Docker-Rezepte** (`release-artifacts`,
  `artifact`, `artifact-host`, `build-image`, `host-bin-image`, `compile`)
  — Bestand bleibt bewusst stehen:
  [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) Festlegung 2
  und [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)
  — der opt-in Weg bleibt gepinnt und ungestrichen; kein Lauf der
  Pflicht-Kette ruft sie mehr, ein Rückbau wäre dessen eigene Entscheidung
  (Re-Evaluierungs-Trigger 4 der [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md)).
- **Der Start-Smoke auf den Plattform-Runnern** — Bestand bleibt bewusst
  stehen: `harness/tools/start-smoke.sh` unverändert je
  [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) Festlegung 1
  — die Plattform-Runner bauen weiter nichts; der Start-Smoke ist der
  Plattform-Nachweis, nicht der Bau.
- **Hard-Rules-Züge in `AGENTS.md`** — Schicht-Abgrenzung und Eigentum: der
  Bestand nennt den Release-Bau dort nicht (gemessen:
  `grep -n 'Release-Bau' AGENTS.md` → 0), und die Hard Rules schreibt der
  Architect (`AGENTS.md` §3.8) — dieser Slice berührt keine normative Zeile.

## 2. Definition of Done

- [x] **Liefer-Punkt a — Bau-Form: [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
      am Host:** `make release-artifacts-host DEST=<dir>` erzeugt je
      `RELEASE_PLATFORMS`-Eintrag das Binary (Windows mit `.exe`) plus
      `SHA256SUMS` und Homebrew-Formel am selben Ort; Wächter
      `test/release-host-bau.bats`: happy — der zweite Lauf desselben Baums
      liefert byte-identische SUMS
      ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)),
      `--version` ohne `TRAEGER_VERSION` meldet den Fehlt-Fall je
      [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
      Festlegung 2 (real go build, kein Stub je
      [`AGENTS.md`](../../../../AGENTS.md) §3.6); negative — ein Binary fehlt
      im `DEST` → rot; boundary — die Tafel hält den Sechs-Satz von
      [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
      gegen die `RELEASE_PLATFORMS`-Zeile. Mutations-Fälle a-1 (Plattform-Zeile
      gestrichen) und a-2 (ldflags-Injektion entfallen) angelegt je
      [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/
      [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
      und färben ihren Wächter rot.
- [x] **Liefer-Punkt b — CI-Verdrahtung:** der `artifacts`-Job der
      [release.yml](../../../../.github/workflows/release.yml) ruft nur
      `make release-artifacts-host` — kein Docker-Zug, kein Inline-Compile
      ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
      Setzung 1); die Toolchain-Install richtet Go aus dem `GO_VERSION`-Pin
      ein (keine zweite Version-Stelle); die Kopfkommentar-Fassung trägt die
      Entfallen-Grenze des gepinnten Bildes statt der heutigen Ausnahme; der
      reale workflow_dispatch-Lauf belegt die Kette — die CI ist dort das
      Netz, [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Form.
      Mutations-Fall b-1 (Step ruft das Docker-Target oder ein
      Inline-Compile) angelegt je
      [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/
      [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
      und färbt rot.
- [x] **Liefer-Punkt c — Doku-Zellen in der host-Form:** die Zellen, die den
      Release-Bau docker-getrieben nennen, tragen die host-Form und nennen
      den opt-in Weg je
      [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)-Fassung —
      `harness/README.md` (Sensor-Zeile `make build`), 
      `harness/sensors/artifact-host.md`, `docs/user/releasing.md` (Bau-Zug,
      Zeilen 43/164/290); die `spec/architecture.md`-§3-Züge trägt der
      Architect-Commit `90930bf8` bereits. Messung: `grep -n
      'docker-getrieben\|Docker-only' harness/README.md
      harness/sensors/artifact-host.md docs/user/releasing.md` → nur die
      opt-in gekennzeichneten Treffer bleiben.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — eine
      weitere Datei in ein vorhandenes `evidence/` oder ein neues
      Verzeichnis; keine Beobachtung angefallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft — in diesem Repo **ohne** Wellen-Betrieb
      hier geprüft, nach dem `git mv` (2026-11-28).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` (Target-Block neben `host-bin`, Zeilen ~619 ff.; `RELEASE_PLATFORMS`, Zeile 268) | neu | `release-artifacts-host` — Cross-Compile je Plattform am Host, `release-sums.sh generate` + Homebrew-Formel am selben Ort; Tafel je `RELEASE_PLATFORMS` (Festlegung 1) |
| [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml) | update | `artifacts`-Job ruft nur das Target; Go-Install aus dem `GO_VERSION`-Pin; Kopfkommentar-Grenze entfallen-Gefasst; Formel-Fill-Zug wandert ins Target, der publish-Job liest nur noch |
| `test/release-host-bau.bats` | neu | Happy/Negative/Boundary je [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)/[`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) — je Fitness-Table der [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) |
| `test/mutations/<Nr>-release-bau-plattformzeile-gestrichen.sh` | neu | a-1 — Plattform-Zeile still gestrichen → Matrix-Wächter rot; je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |
| `test/mutations/<Nr>-release-bau-ldflags-injektion-entfallen.sh` | neu | a-2 — Fassungs-Injektion fällt still weg → rot am `--version`-Fehlt-Fall; je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |
| `test/mutations/<Nr>-release-ci-step-ruft-docker-oder-inline.sh` | neu | b-1 — Step ruft das Docker-Target oder ein Inline-Compile statt des make-Ziels → rot; je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |
| `test/ci-runner-ohne-docker.bats` (Fall `releasegrenze`) | update | der Bestand-Wächter hielt die alte Grenze (`release-artifacts` im gepinnten Bild, kein `ci-runner-setup`) — [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) Festlegung 1 kehrt die Grenze um; Umstellung auf Host-Form, Rot-Beleg als Hand-Mutation am realen release.yml (Bericht) |
| Homebrew-Formel-Stufe im Target | neu | ein Teil-Lauf über `RELEASE_PLATFORMS` bricht am fail-closed Fill des Skeletts (vier brew-Plattformen fehlen) — die Stufe meldet dann den Fehlt statt den Lauf zu brechen; der vollständige Lauf füllt die Formel |
| `harness/README.md` (Sensor-Zeile `make build`) | update | Release-Bau-Zelle in der host-Form; opt-in Weg bleibt je [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) |
| `harness/sensors/artifact-host.md` | update | Release-Bau-Züge in der host-Form (Festlegung 5, Konsequenz-Folgepflicht) |
| `docs/user/releasing.md` | update | Bau-Züge des Release-Workflows in der host-Form (Zeilen 43/164/290) |

**Bestand, bewusst unberührt** — die Wächter-Zusagen um diese Änderungen
stehen, sie wandern nicht: `test/release-matrix.bats` (Zusage 1 — die
Plattform-Liste im `Makefile` deckt genau die [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)-
Matrix; Zusage 2 — Windows-`.exe`) bleibt der Bestand, an dem der a-1-Fall
verankern kann; die gepinnten Image-Rezepte bleiben wie im Auschluss oben.

## 4. Trigger

**Start** (`next` → `in-progress`): [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md)
ist Accepted (2026-11-28) und trägt die Festlegungen 1–6 als Vorgang; der
Implementer-Auftrag übernimmt je WIP-Regel
(Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit), Claim durch den
`git mv` auf dem Hauptzweig.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa wenn der reale Nachweis der CI-Kette am Tag hängen
  muss, der erst beim Publizieren entsteht (TRAEGER-Versions-Zug hinter der
  Publikation gehört `slice-traeger-tag-nachzug-untergrenze-v1`) → re-slicen
  je Bau-Kante: a bleibt, b/c sind das CI-Fassungs-Paar.
- `in-progress` → `open` (blockiert — Carveout?): der Linux-Runner trägt die
  Go-Toolchain nicht in der Fassung des `GO_VERSION`-Pins
  (Install- oder Netz-Ausfall) — dann Carveout-Klärung je
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 4 (am Pin geprüft, nicht gepinselt) und/oder
  [`MR-098`](../../../../harness/conventions.md#mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host);
  keine Schwellen-Senkung (`AGENTS.md` §3.5), der Pin bleibt je Bestand.

## 5. Closure-Trigger

§2 vollständig; Belege: `test/release-host-bau.bats` grün einschließlich des
byte-identischen Zweitlaufs und des `--version`-Fehlt-Falls; der reale
workflow_dispatch-Lauf von [release.yml](../../../../.github/workflows/release.yml) belegt
die CI-Kette (Job ruft das Target, Toolchain aus dem Pin, Artefakte hängen an);
die drei Mutations-Fälle greifen je `make mutate` (`MUTATE_CASES`);
`make gates` grün; Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- **Der Runner-Rest:** die Toolchain-Umgebung der Runner-Images liegt
  außerhalb jedes Repo-Pins (Festlegung 3 der
  [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md), Negativ-Konsequenz)
  — **Ausgang:** *weiter offen* → Register
  `BEO-ALL/runner-toolchain-liegt-ausserhalb-jedes-repo-pins` (neu angelegt,
  Beleg `evidence/slice-release-bau-dockerlos-v1.md`); die Re-Evaluierungs-Trigger 1/2
  der [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) tragen ihn; am
  Pin geprüft je Bau-Lauf, die SKIP-Belehnform der CI behauptet kein
  Runner-Verdikt. Der reale Dispatch-Lauf belegt die Gelingens-Seite, nicht
  die Umgebungs-Pflicht der Runner-Images.
- **Byte-identische SUMS brechen:** zwei Läufe desselben Baums mit derselben
  Pin-Fassung liefern abweichende `SHA256SUMS` — **Ausgang:** *entfallen* —
  der Zweitlauf-Beleg der `test/release-host-bau.bats` zeigt byte-identische
  SUMS; der Lauf ist Teil der grünen Suite, Verifikation bestätigt
  Liefer-Punkt a vollständig (Review §Negativbefunde: realer Bau, kein
  Fixtures-Grün).
- **Start-Smoke-Drift:** der Bau-Zug ändert Binary-Namen oder `.exe`-Form, und
  der Plattform-Smoke greift nicht mehr — **Ausgang:** *entfallen* — Namen und
  Form bleiben je `test/release-matrix.bats` (Zusage 2; Bestand, bewusst
  unberührt), und der Start-Smoke bestand am realen workflow_dispatch-Lauf
  46155129162 auf allen sieben Plattform-Positionen (`artifacts`-success,
  `start-smoke` je success, Windows-Positionen je `.exe`-Form amd64/arm64).
- **Mutations-Vollauf über den CI-Branch** (nachgetragen, Review-Handoff
  M-1): der planmäßige CI-Branch-Lauf der Mutations-Probe (Workflow
  `mutate-branch.yml`, Run 46158137040, Zweig
  `mutate/slice-release-bau-dockerlos-v1-908725fe`, 124 Fälle auf 10 Shards,
  577 s Wanduhr) brach je Grün-Vorlauf an `make full-smoke` in der Kopie
  **ohne Mutation** — an dem Traeger-Pin-Bruch (gepinnt `v0.10.0` sperrt über
  dem heutigen Bestand), den auch der `ci`-Job `full-smoke` am Push von
  `main` fährt; die Shards liefen nie durch, kein Fall-Ergebnis,
  `Urteil: BEFUND` — **Ausgang:** *weiter offen* → Register
  `BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe` (Beleg
  `evidence/slice-release-bau-dockerlos-v1.md`, zweites Auftreten), Träger
  [`slice-traeger-tag-nachzug-untergrenze-v1`](../in-progress/slice-traeger-tag-nachzug-untergrenze-v1.md)
  (liegt in `in-progress/`); der ABBRUCH ist kein Beleg-Defekt dieses Slices —
  die direkte Rot-Messung der Fälle 835–838 trägt der lokale Beleg an der
  realen Quelle (Hand-Mutation je Wächter `not ok`, Fall 838 je Treiber-Lauf,
  Commit `7063c0b9`).

## 7. Closure-Notiz

- **Was hat funktioniert:** die drei Liefer-Punkte je Plan — Bau-Form
  (`make release-artifacts-host` über der `RELEASE_PLATFORMS`-Tafel,
  Cross-Compile je `LH-QA-04`-Plattform, `release-sums.sh generate` und
  Homebrew-Formel am selben Ort je ADR-0059 Folgepflicht 1), CI-Verdrahtung
  (der `artifacts`-Job ruft nur das Target, Go-Install aus dem
  `GO_VERSION`-Pin, MR-014 Setzung 1) und Doku-Zellen in der host-Form.
  Der reale `workflow_dispatch`-Lauf von release.yml (Run 46155129162, Ref
  main, kein Tag) belegt die Kette am frischen Runner: `artifacts` success je
  host-nativer Cross-Kompilierung — kein Docker im Pflicht-Weg —,
  `start-smoke` success auf allen sieben Plattform-Positionen je
  `LH-QA-04`-Matrix, `publish`/`tap` skipped je tag-gebundener Condition
  (richtig — kein Release geschnitten). `test/release-host-bau.bats` grün
  einschließlich byte-identischer Zweitlauf (`LH-QA-02`) und
  `--version`-Fehlt-Fall je ADR-0063 Festlegung 2; `make gates` grün am
  frischen HEAD `7063c0b9` (record-gates Exit 0, `mutate-greift` 824/824,
  transportierte je-Check-Keys decken je ADR-0111 Festlegung 2), CI grün je
  Push `bf662609` (gates, adr-immutable, smoke — frischer Klon je MR-014).
- **Was ging anders als geplant:** der Release-Bau-Zweig lief nach main über
  fünf Cherry-Pick-Commits je fast-forward (`bf662609`) — die zwei
  Doppel-Läufe des Zwischenstands (der Fall-823-Vorbestand und der
  Treiber-env-Zug der main-Validierung) trägt main je validierter Fassung:
  am Zwischenstand rot, am gepickten Stand je neu validiert. Und der
  Mutations-Vollauf brach im Grün-Vorlauf am Pin-Bruch statt Fall-Ergebnisse
  zu liefern (M-1, §6 vierter Punkt) — die Rot-Messung trägt darum der
  lokale Beleg an der realen Quelle, der ABBRUCH ist kein Defekt dieses
  Slices, sondern derselbe benannte Blocker.
- **Steering-Loop-Eintrag:** Lernkandidat, **gezählt statt verkörpert** —
  die Vorlauf-Bruch-Klasse im gebootstrappten CI: der Grün-Vorlauf der
  Mutations-Züge liest dieselbe Kante wie der push-main-`full-smoke`-Job
  (`make full-smoke` am aus `TRAEGER_TAG` gefetchten Traeger). Das Auftreten
  ist im Register `BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe`
  gezählt (Beleg `evidence/slice-release-bau-dockerlos-v1.md`, zweites
  Auftreten der Klasse), nicht neu benannt. Verkörpert wurde nichts über den
  gelieferten Umfang hinaus — die Zeile `liegt in …` entfällt; die
  Anker-Paarung prüft darum keinen Zielort.
- **Beobachtungs-Register (`../observations/`):**
  `BEO-ALL/werkzeug-zelle-traegt-einen-ist-stand-der-vom-ausgelieferten-abweicht/evidence/slice-release-bau-dockerlos-v1.md`
  ergänzt (Zähler 2) — die `make build`-Sensor-Zelle trug den
  docker-getrieben-Ist-Stand; Liefer-Punkt c ist der Fix.
  `BEO-ALL/gepinnter-werkzeug-weg-umgangen-ohne-guard-treffer/evidence/slice-release-bau-dockerlos-v1.md`
  ergänzt (Zähler 2) — Review F-3, der MR-014-Text-Wächter entkennt der
  Quoted-Hash-Form. `BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe/evidence/slice-release-bau-dockerlos-v1.md`
  ergänzt (Zähler 2) — der Mutations-Vorlauf-ABBRUCH (M-1).
  `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/evidence/slice-release-bau-dockerlos-v1.md`
  ergänzt — **Zähler 3, Schwelle erreicht** (Review F-2, dritte Instanz der
  Umgebungs-Leak-Klasse); die Lücke trägt der Folge-Slice
  `slice-mutate-cases-leakt-nicht-am-teillauf` (liegt in `next/`), Register-
  Stand je `state.md` auf `geplant` gesetzt. Neu:
  `BEO-ALL/runner-toolchain-liegt-ausserhalb-jedes-repo-pins` (Ausgang des
  ersten §6-Risikos) — 1 Beleg, Stand offen. Kürzel `TOOLS`: keine Treffer
  (§8-Sichtung bestätigt). Die übrigen Finding-Klassen des Review-Reports
  (LOW/INFO, Einzelformen) sind ohne Zähler benannt — der Report selbst ist
  Lauf-Beleg.
- **Folge-Slices:** keiner neu angelegt — die offenen Ausgänge tragen der
  in `in-progress/` laufende
  [`slice-traeger-tag-nachzug-untergrenze-v1`](../in-progress/slice-traeger-tag-nachzug-untergrenze-v1.md)
  (Träger der Pin-Lage und damit des Mutations-Vorlauf-Aufholens nach der
  Publikation) und die Re-Evaluierungs-Trigger 1/2 von ADR-0115 (Runner-Rest).
- **Risiken aus §6:** Runner-Rest *weiter offen* →
  `BEO-ALL/runner-toolchain-liegt-ausserhalb-jedes-repo-pins` · byte-identische
  SUMS *entfallen* (Zweitlauf-Beleg `test/release-host-bau.bats`) ·
  Start-Smoke-Drift *entfallen* (`test/release-matrix.bats` Zusage 2 +
  Start-Smoke-Bestehen am Dispatch-Lauf 46155129162) · Mutations-Vollauf
  *weiter offen* → Träger `slice-traeger-tag-nachzug-untergrenze-v1`, gezählt
  in `BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe`.
- **Drei Paarungen:** geprüft am 2026-11-28, nach dem `git mv` — (a) Anker:
  kein Steering-Loop-Eintrag mit `liegt in` getragen (der §7-Eintrag ist
  gezählt statt verkörpert, die Zeile entfällt; die `liegt in`-Treffer im
  Dokument nennen den Verzeichnis-Stand des Träger-Slices, sie sind kein
  Pflichtfeld); (b) Folge-Slice: keiner neu angelegt — die offenen Ausgänge
  tragen `slice-traeger-tag-nachzug-untergrenze-v1`
  (`ls docs/plan/planning/*/slice-traeger-tag-nachzug-untergrenze-v1.md` →
  genau eine Datei, `in-progress/`) und die Re-Evaluierungs-Trigger 1/2 von
  ADR-0115; (c) Register: die fünf berührten Verzeichnisse existieren mit
  nicht leerem `evidence/` (`BEO-ALL/werkzeug-zelle-…` 2, `BEO-ALL/gepinnter-werkzeug-weg-…`
  2, `BEO-ALL/gefetchter-traeger-…` 2, `BEO-ALL/mutate-cases-leakt-…` 3,
  `BEO-ALL/runner-toolchain-…` 1 Beleg) — zweite Hälfte: 1 Verzeichnis ohne
  Beleg, namentlich
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do …; done`,
  [ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2) — nicht als getragen behauptet.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist die Sub-Area `*`
(gesamtes Repo, Kürzel `ALL` — `Makefile`, CI-Workflows, Spec-/Sensor-/user-Doku,
`test/`) und, falls die Bau-Kanten-Skripte angefasst werden,
`harness/tools/` (Kürzel `TOOLS`). Beide erfüllen die Schwelle ≥ 2 von 3
Achsen: `ALL` trägt die Repo-weiten Strukturregeln (`AGENTS.md` §3,
`harness/conventions.md`, Gate-Index) und die Phase-5-Reife des Dogfood;
`TOOLS` den Werkzeug-Code mit `shell-lint`- und Mutations-Deckung. Ein
weiteres Ausdifferenzieren ist nicht nötig — die Berührung ist die
Bau-/CI-Kante je [ADR-0115](../../adr/0115-release-bau-docker-los-in-ci.md), keine neue Fläche.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen
(Kürzel `ALL`, Stand je `state.md`), die im Keyword-Sicht der Bau-/CI-Kante
stehen:

- [`BEO-ALL/werkzeug-zelle-traegt-einen-ist-stand-der-vom-ausgelieferten-abweicht`](../observations/BEO-ALL/werkzeug-zelle-traegt-einen-ist-stand-der-vom-ausgelieferten-abweicht/state.md)
  — 1 Beleg (< 3×), Stand offen; berührt: die `make build`-Sensor-Zelle in
  `harness/README.md` trägt heute "Release-Bau bleibt docker-getrieben" —
  dieser Slice ändert die Zelle und ergänzt bei Closure einen Beleg (Stand
  2). Kein Übertritt, Liefer-Punkt c ist der Fix.
- [`BEO-ALL/gepinnter-werkzeug-weg-umgangen-ohne-guard-treffer`](../observations/BEO-ALL/gepinnter-werkzeug-weg-umgangen-ohne-guard-treffer/state.md)
  — 1 Beleg (< 3×), Stand offen; berührt: der `artifacts`-Job ist heute die
  letzte Pflicht-Stelle des gepinnten Bildes — nach der Umstellung tritt der
  b-1-Wächter an die make-Setzung-1-Grenze. Vorgangs-Kennung bei Closure je
  Ist, kein Übertritt vorab zugesagt.
- Stand verkörpert, kein Übertritt durch diesen Slice:
  [`docker-aussetzer-im-vorlauf`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md)
  (3 Belege, verkörpert),
  [`pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/state.md)
  (8 Belege, verkörpert — die Image-Pins der Bau-Rezepte),
  [`host-werkzeug-variante-auf-macos`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  (8 Belege, verkörpert — der Bau ist Linux-Runner-Sache je
  [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) Festlegung 4).

Kürzel `TOOLS`: keine Treffer — kein Eintrag des Kürzels berührt die
Bau-/CI-Kante (Sichtung über die `observation.md`-Beschreibungen).

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
