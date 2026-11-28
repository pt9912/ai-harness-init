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
(Baseline-Regelwerk `grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)`).

**Verantwortlich:** — (geclaimt beim nächsten Implementer-Start)

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
[release.yml](.github/workflows/release.yml) ruft nur dieses Target
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

- [ ] **Liefer-Punkt a — Bau-Form: [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
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
- [ ] **Liefer-Punkt b — CI-Verdrahtung:** der `artifacts`-Job der
      [release.yml](.github/workflows/release.yml) ruft nur
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
- [ ] **Liefer-Punkt c — Doku-Zellen in der host-Form:** die Zellen, die den
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
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — eine
      weitere Datei in ein vorhandenes `evidence/` oder ein neues
      Verzeichnis; keine Beobachtung angefallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` (Target-Block neben `host-bin`, Zeilen ~619 ff.; `RELEASE_PLATFORMS`, Zeile 268) | neu | `release-artifacts-host` — Cross-Compile je Plattform am Host, `release-sums.sh generate` + Homebrew-Formel am selben Ort; Tafel je `RELEASE_PLATFORMS` (Festlegung 1) |
| [`.github/workflows/release.yml`](.github/workflows/release.yml) | update | `artifacts`-Job ruft nur das Target; Go-Install aus dem `GO_VERSION`-Pin; Kopfkommentar-Grenze entfallen-Gefasst; Formel-Fill-Zug wandert ins Target, der publish-Job liest nur noch |
| `test/release-host-bau.bats` | neu | Happy/Negative/Boundary je [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)/[`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) — je Fitness-Table der [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) |
| `test/mutations/<Nr>-release-bau-plattformzeile-gestrichen.sh` | neu | a-1 — Plattform-Zeile still gestrichen → Matrix-Wächter rot; je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |
| `test/mutations/<Nr>-release-bau-ldflags-injektion-entfallen.sh` | neu | a-2 — Fassungs-Injektion fällt still weg → rot am `--version`-Fehlt-Fall; je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |
| `test/mutations/<Nr>-release-ci-step-ruft-docker-oder-inline.sh` | neu | b-1 — Step ruft das Docker-Target oder ein Inline-Compile statt des make-Ziels → rot; je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |
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
workflow_dispatch-Lauf von [release.yml](.github/workflows/release.yml) belegt
die CI-Kette (Job ruft das Target, Toolchain aus dem Pin, Artefakte hängen an);
die drei Mutations-Fälle greifen je `make mutate` (`MUTATE_CASES`);
`make gates` grün; Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- **Der Runner-Rest:** die Toolchain-Umgebung der Runner-Images liegt
  außerhalb jedes Repo-Pins (Festlegung 3 der
  [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md), Negativ-Konsequenz)
  — **Ausgang:** weiter offen → die Re-Evaluierungs-Trigger 1/2 der
  [`ADR-0115`](../../adr/0115-release-bau-docker-los-in-ci.md) tragen ihn; am
  Pin geprüft je Bau-Lauf, die SKIP-Belehnform der CI behauptet kein
  Runner-Verdikt.
- **Byte-identische SUMS brechen:** zwei Läufe desselben Baums mit derselben
  Pin-Fassung liefern abweichende `SHA256SUMS` — **Ausgang:** bei Closure
  entscheiden — eingetreten: Folge-ADR (`Supersedes ADR-0115`, Rückfall-Form
  Option D je Re-Evaluierungs-Trigger 1); entfallen: der Zweitlauf-Beleg der
  `test/release-host-bau.bats` zeigt byte-identische SUMS.
- **Start-Smoke-Drift:** der Bau-Zug ändert Binary-Namen oder `.exe`-Form, und
  der Plattform-Smoke greift nicht mehr — **Ausgang:** entfallen: Namen und
  Form bleiben je `test/release-matrix.bats` (Zusage 2); greift der
  Start-Smoke am Dispatch-Lauf nicht, so eingetreten mit
  Folge-Slice-Kennung.

## 7. Closure-Notiz

- *(wird bei dessen Closure gefüllt)*

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist die Sub-Area `*`
(gesamtes Repo, Kürzel `ALL` — `Makefile`, CI-Workflows, Spec-/Sensor-/user-Doku,
`test/`) und, falls die Bau-Kanten-Skripte angefasst werden,
`harness/tools/` (Kürzel `TOOLS`). Beide erfüllen die Schwelle ≥ 2 von 3
Achsen: `ALL` trägt die Repo-weiten Strukturregeln (`AGENTS.md` §3,
`harness/conventions.md`, Gate-Index) und die Phase-5-Reife des Dogfood;
`TOOLS` den Werkzeug-Code mit `shell-lint`- und Mutations-Deckung. Ein
weiteres Ausdifferenzieren ist nicht nötig — die Berührung ist die
Bau-/CI-Kante je ADR-0115, keine neue Fläche.

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
