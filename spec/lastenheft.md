# Lastenheft — ai-harness-init

**Version:** 0.9.0

**Status:** Draft

**Autor:** Demo, **Datum:** 2026-06-13.

> Anforderungen abgeleitet aus dem Hand-Bootstrap-Test ("attempt1") —
> jede `LH-` trägt ihren Reibungs-Ursprung (F1–F7).

---

## 1. Zweck und Geltungsbereich

ai-harness-init ist eine CLI, die ein bestehendes Git-Repo mit dem
AI-Harness-Kurs-Prozess bootstrappt: Templates **und Regelwerk** vom
gepinnten Kurs-Stand (Fetch), die Doc-Gate-Baseline (generiert) und ein
sprachspezifisches Code-Skelett (deterministisch generiert, Tool-als-Quelle).
Nicht im Scope: das Füllen inhaltlicher Urteilsschritte (Spec, ADRs,
Modus-Wahl, AGENTS.md) — das bleibt Mensch/Agent.

## 2. Stakeholder

| Stakeholder | Rolle | Erwartung |
|---|---|---|
| Adopter-Team | Anwender | grünes Repo out-of-the-box, ohne Hand-Reparatur |
| Code-Agent | Anwender | selbstbeschreibender Einstieg (AGENTS.md) |
| Kurs-Maintainer | Quelle | Single Source of Truth für Templates + Regelwerk (das Sprachskelett generiert das Tool) |

## 3. Funktionale Anforderungen

### LH-FA-01 — Repo bootstrappen

**Beschreibung:** Im Zielverzeichnis die Harness-Struktur anlegen:
Templates (zweiklassig), Doc-Gate-Baseline, Sprachskelett-Gates,
Projektname gestempelt.

**Akzeptanzkriterien:**

- **Happy Path:** Given leeres Git-Repo, when `ai-harness-init --lang go --name X`, then make gates läuft grün.
- **Boundary:** Given bereits vorhandene Artefakte, when Lauf, then kein Überschreiben ohne `--force`.
- **Negative:** Given fehlendes `--lang`, when Lauf, then Exit 2 + Usage.

### LH-FA-02 — Zweiklassige Template-Ablage (F3)

**Beschreibung:** Der emittierte Doc-Layer ist zweiklassig. **Singletons**
(authored-once: `AGENTS.md`, `spec/*`, `harness/*`, Root-`README.md`, Roadmap)
werden zu gestempelten `.md`-Zielen. **Wiederkehrende** Vorlagen (ADR · slice ·
welle · carveout · review-report) werden **referenziert, nicht co-located
dupliziert**: sie liegen als Teil der gefetchten, committet-vendored Baseline
([`LH-FA-09`](../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) unter
`.harness/baseline/<version>/templates/` und werden **von dort** beim Anlegen
eines Artefakts kopiert-und-ausgefüllt. **Derivative Index-Sichten** (ADR-/
Carveout-Index) sind Fülle-wenn-Inhalt-da — sie entstehen durch Kopieren aus der
Baseline, sobald der erste ADR/Carveout existiert, nicht als gate-unsichere
Platzhalter-Skelette bei Bootstrap. Leere Struktur-Verzeichnisse (Lifecycle-
Ordner, ADR-/Carveout-/Reviews-Ordner) werden mit `.gitkeep` gehalten; die
Set-Index-README wird nie mitkopiert. Der emittierte Stand ist damit
out-of-the-box **gate-sicher** ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

### LH-FA-03 — Doc-Gate-Baseline emittieren (F6, F7)

**Beschreibung:** `.d-check.yml` (Suffix-Ignore) + `d-check.mk` (d-checks
`--print-mk`-Fragment, d-check-Image per Digest gepinnt). Das Gate-Fragment ist
**per-Tool** und trägt den tool-eigenen Namen (`d-check` → `d-check.mk`), nicht den
obsoleten Sammelnamen `harness.mk`; weitere Gate-Tools emittieren analog ihr eigenes
`--print-mk`-Fragment. `ids`/`codepaths` nur mit existierenden Targets/roots aktivieren —
der Gate-Config wächst mit den Artefakten.

### LH-FA-04 — Sprachskelett-Picker (F4)

> **Titel historisch.** „Picker" benennt die ursprüngliche Fetch-Variante; die
> Anforderung ist auf einen **deterministischen Generator** (Tool-als-Quelle)
> umgestellt — siehe Historie (§7, v0.7.0). Der Heading-Anker bleibt bewusst
> stabil, damit bestehende Verweise nicht rotten.

**Beschreibung:** Das Tool **generiert** das Sprachskelett — Verzeichnis-Layout
plus Skelett-Dateien (`Dockerfile`, `Makefile`, `go.mod`, `.golangci.yml` …) —
**deterministisch aus tool-eigenem Sprach-/Architektur-Wissen** (Tool-als-Quelle,
nachvollziehbar wie `d-check --print-mk`, **nicht aus dem Nichts**). Verdrahtet
die Code-Gates; emittiert nur lauffähige Make-Targets (keine halluzinierten
Gates, [`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Smoke).

**Unterstützte Sprachen:** `go`, `python`, `kotlin`, `java`, `csharp`, `cpp`.
`cpp` (C++/CMake: cmake/ctest/clang-tidy) folgt; der Generator bleibt
sprach-agnostisch (ein Layout-Profil je Sprache).

### LH-FA-05 — Root-README emittieren (F1, F2)

**Beschreibung:** Aus der project-readme-Vorlage; Pointer-/Trust-Abschnitt
als gate-sichere Vorwärts-Verweise, bis die Ziele existieren.

### LH-FA-06 — Durchsetzungsschicht emittieren

**Beschreibung:** Der Bootstrap emittiert die Durchsetzungsschicht ins
Zielrepo: Stop-Hook + Gate-Nachweis-Mechanik (`tools/harness/`,
`record-gates`, `.claude/settings.json`), `CLAUDE.md`, Reviewer-Skill und
Command-Guard. **Quelle:** die Durchsetzungs-**Mechanik** (Stop-Hook, Guard,
Gate-Nachweis, `CLAUDE.md`) bringt das Tool selbst mit — **Tool-als-Quelle**, je
`--lang` parametriert (wie das Sprachskelett [`LH-FA-04`](../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4));
der **Reviewer-Skill** bleibt aus dem gepinnten Kurs-Template-Satz gefetcht (er
liegt dort).

**Akzeptanzkriterien:**

- **Happy Path:** Given Bootstrap mit `--lang <X>`, then Stop-Hook,
  Gate-Nachweis und `CLAUDE.md` liegen im Zielrepo; `make gates` schreibt
  den Nachweis.
- **Guard:** Der Command-Guard ist **bash + awk** (kein node/jq/OCI),
  fail-closed bei Parse-Zweifel; sein BLOCKED-Set ist auf `--lang`/Build-Model
  des Ziels abgestimmt.
- **Minimal:** Das emittierte Repo braucht über `bash + git + docker` hinaus
  nichts (awk ist POSIX-Basis).

### LH-FA-07 — Arch-Gate-Baseline emittieren

**Beschreibung:** Analog [`LH-FA-03`](../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (per-Tool-Fragment) emittiert der Bootstrap das
**Architektur-Gate**: `.a-check.yml` (Schicht-/Sprach-Config) + `a-check.mk` (a-checks
`--print-mk`-Fragment, a-check-Image per Digest gepinnt). a-check prüft hexagonale Schichten
(domain/ports/adapters) im emittierten Sprachskelett ([`LH-FA-04`](../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) — read-only, netzlos.

**Akzeptanzkriterien:**

- **Happy Path:** Given Bootstrap mit einem Sprachskelett, das hexagonale Schichten trägt,
  then `.a-check.yml` + `a-check.mk` liegen im Zielrepo und `make a-check` ist Exit 0 (die
  Config bildet die realen Schichten ab).
- **Keine halluzinierten Gates ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):** a-check bricht bei fehlender/ungültiger
  `.a-check.yml` mit Exit 2 ab. Trägt das Skelett **keine** hexagonalen Schichten, wird das
  Gate begründet **nicht** emittiert — statt ein arch-Gate über einem leeren Prüfbereich leer
  grün melden zu lassen.
- **Minimal ([`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)):** a-check läuft Docker-only, netzlos, read-only — das emittierte
  Repo braucht über `git + docker` hinaus nichts.

### LH-FA-08 — Agenten-Workflow-Commands emittieren

**Beschreibung:** Der Bootstrap emittiert die **Agenten-Workflow-Commands** ins Zielrepo
(`.claude/commands/…`: `implement-slice`, `plan-welle`, `close-welle`) — die Slash-Command-
*Anleitung*, mit der ein Agent die Harness-Rollen fährt (Slice implementieren, Welle
planen/schließen, geerdet in den Regelwerk-Modulen zu Lifecycle/Rollen/Review/Verifikation).
Damit erhält der Adopter den **Prozess**, nicht nur die Gerüste.

**Quelle (Tool-als-Quelle — §5).** Die Command-Vorlagen bringt das Tool selbst mit — abgeleitet
aus den Kurs-Prozess-Modulen und dem erprobten Dogfood-Stand, je `--lang` parametriert und mit
adaptierbaren Markern (wie das Sprachskelett [`LH-FA-04`](../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)).
**Kein** aus dem Nichts generiertes Command: die Fassung ist real erprobt (Dogfood) und kurs-geerdet
(Prozess-Module), so wie das generierte Skelett sprach-geerdet ist ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Eine Kurs-Upstream-Ergänzung ist damit **nicht** mehr Vorbedingung (die frühere Picker-Setzung entfällt).

**Abgrenzung zu [`LH-FA-06`](../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren).** LH-FA-06 emittiert die **Durchsetzung** (Stop-Hook,
Gate-Nachweis, Command-Guard, `CLAUDE.md`, Reviewer-Skill — was den Prozess *erzwingt*);
LH-FA-08 die **Anleitung** (die Workflow-Slash-Commands — was den Prozess *beschreibt*). Beide
sind `.claude/`-Inhalt, aber verschiedene Klassen.

**Akzeptanzkriterien:**

- **Happy Path:** Given Bootstrap mit `--lang <X>`, then
  `.claude/commands/{implement-slice,plan-welle,close-welle}.md` liegen im Zielrepo (Tool-als-Quelle,
  je `--lang` parametriert).
- **Adaptierbar (zweiklassig, [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)):** Command-Vorlagen tragen repo-spezifische
  Stellen (Adaptions-/„MR-Block", Build-Modell) als **adaptierbare** Marker, nicht 1:1 hart —
  der Adopter passt sie an sein Repo an.
- **Kein aus dem Nichts ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):** die emittierte Command-Fassung
  ist real erprobt (Dogfood) und kurs-geerdet (Prozess-Module) — kein erfundenes Command, aber auch
  kein Warten auf eine Upstream-Quelle.

### LH-FA-09 — Regelwerk emittieren

**Beschreibung:** Der Bootstrap legt das **Betriebsregelwerk** ins Zielrepo: Er
holt es vom gepinnten Kurs-Stand (Fetch, dieselbe Kurs-Version wie die Templates
aus [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3))
und schreibt es als **committet-vendored Baseline** des Zielrepos
(`.harness/baseline/<version>/regelwerk/` + Prüfsummen). Damit trägt das
emittierte Repo die kanonischen Prozess-Module (Lifecycle/Rollen/Review/
Verifikation), auf die seine `AGENTS.md` §1 (Source Precedence) zeigt — und läuft
**nach** dem einmaligen Bootstrap-Fetch **netzlos** (Gates/Agenten offline).

**Akzeptanzkriterien:**

- **Happy Path:** Given Bootstrap mit einer Kurs-Version, then liegt das
  Regelwerk als vendored Baseline im Zielrepo und ist netzlos verifizierbar
  (Prüfsummen).
- **Reproduzierbar ([`LH-QA-02`](../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)):**
  dieselbe Kurs-Version → derselbe Baum (Content-Pin).
- **Minimal/netzlos ([`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)):**
  der Fetch läuft **einmal** beim Bootstrap; danach braucht das Zielrepo für
  seine Gates kein Netz.
- **Kein Halluzinat ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):**
  fehlt das Kurs-Asset zur Version, wird begründet **nicht** emittiert (statt
  ein erfundenes Regelwerk).

## 4. Nichtfunktionale Anforderungen

### LH-QA-01 — Keine halluzinierten Gates (F4, F5, F6)

- **Anforderung:** Jeder emittierte Gate-Target läuft auf frischem Checkout; make gates grün out-of-the-box.
- **Messmethode:** Smoke-Test — Bootstrap in tmp-Repo, make gates, Exit 0.

### LH-QA-02 — Reproduzierbarkeit

- **Anforderung:** Templates, Sprachskelett, d-check-Image **und das Tool-Build-Image (Go-Toolchain)** auf Tag/Digest gepinnt — kein floating main.
- **Messmethode:** zwei Läufe mit gleichem Tag erzeugen identische Ausgabe.

### LH-QA-03 — Minimale Abhängigkeiten

- **Anforderung:** Das Tool ist ein **natives Go-Binary**; die Laufzeit beim
  Bootstrap braucht nur **git + docker** (keine Host-Sprachlaufzeit, kein
  Paketmanager). Der **Tool-Build** läuft reproduzierbar im gepinnten Image
  (Go-Toolchain, Cross-Compile) — **kein Host-`go`** (Docker-only). Emittierte
  Ziel-Repos bleiben make/docker-getrieben.
- **Messmethode:** `golangci-lint`-clean + `go test` grün (im Image); Smoke:
  Binary auf frischem System mit nur git + docker → Bootstrap grün.

### LH-QA-04 — Plattform-Matrix

- **Anforderung:** Native Binaries für **linux · macos · windows** ×
  **amd64 · arm64**, cross-kompiliert im gepinnten Image. Erstklassig auf
  allen dreien ohne WSL2-Zwang — das Tool ruft Host-`docker` (Docker Desktop
  liefert die docker-CLI auf macOS/Windows).
- **Messmethode:** Release liefert ein Binary je `GOOS`/`GOARCH`;
  Plattform-Smoke in der CI-Matrix.

## 5. Globale Out-of-Scope-Punkte

- Inhaltliche Urteilsschritte (Spec/ADR/Modus, AGENTS.md) — bleiben Mensch/Agent.
- **Kein Artefakt aus dem Nichts (halluziniert)** — jede emittierte Klasse hat
  eine nachvollziehbare Quelle: Templates + Regelwerk per **Fetch** (Kurs-SSoT,
  [`LH-FA-09`](../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)); Durchsetzung
  + Workflow-Commands per **Picker** (Kurs-Template-Satz); das Sprachskelett per
  **deterministischem Generator** (Tool-als-Quelle). C++/CMake folgt
  sprach-agnostisch.

## 6. Glossar

| Begriff | Bedeutung |
|---|---|
| Singleton-Template | einmal beim Bootstrap gefüllt, dann verworfen |
| Wiederkehrendes Template | bleibt co-located für spätere Instanzen |

## 7. Historie

| Version | Datum | Änderung | Verweis |
|---|---|---|---|
| 0.1.0 | 2026-06-13 | Initial, abgeleitet aus attempt1 (F1–F7) | — |
| 0.2.0 | 2026-06-13 | CR: Impl-Sprache Go + native Binaries ([`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md), supersedes [`ADR-0002`](../docs/plan/adr/0002-test-tooling-grenze.md)); [`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) Go-Toolchain/Docker-only; neue [`LH-QA-04`](../spec/lastenheft.md#lh-qa-04--plattform-matrix) Plattform-Matrix; [`LH-FA-04`](../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) Zielsprache `cpp` | Plan-Review-Folge |
| 0.3.0 | 2026-06-13 | CR: neue [`LH-FA-06`](../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) Durchsetzungsschicht emittieren; Guard bash+awk (zero-dep), Quelle Kurs-Templates ([`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md)) | Phase-2-Folge |
| 0.4.0 | 2026-07-18 | CR: emittiertes Doc-Gate-Fragment `harness.mk` → `d-check.mk` ([`LH-FA-03`](../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)) — per-Tool-Fragment aus `d-check --print-mk`, Sammelname obsolet, konsistent mit dem Dogfood ([`MR-010`](../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); weitere Gate-Tools analog (arch-Gate a-check → `a-check.mk`, wenn integriert) | slice-017-Folge |
| 0.5.0 | 2026-07-18 | CR: neue [`LH-FA-07`](../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) Arch-Gate-Baseline emittieren (`.a-check.yml` + `a-check.mk`, per-Tool analog [`LH-FA-03`](../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)) — a-check als Architektur-Gate (hexagonale Schichten); nur aktiviert, wo das Skelett Schichten trägt ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Implementierung folgt mit Emitter/Go-Code (Doc-führt) | a-check-Integration |
| 0.6.0 | 2026-07-18 | CR: neue [`LH-FA-08`](../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) Agenten-Workflow-Commands emittieren (`.claude/commands/` — Picker aus den Kurs-Templates, abgegrenzt von [`LH-FA-06`](../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)-Durchsetzung; Vorbedingung Kurs-Upstream-Ergänzung). Header-Version mit der Historie reconciled (lag auf 0.3.0). Implementierung folgt als späterer Slice (Doc-führt) | Workflow-Command-Idee |
| 0.7.0 | 2026-07-19 | CR: [`LH-FA-04`](../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) Picker (Fetch `lab/example`) → **deterministischer Generator** (Tool-als-Quelle); neue [`LH-FA-09`](../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) Regelwerk emittieren (Fetch Kurs @ version → Ziel-Baseline, danach netzlos); [`ADR-0005`](../docs/plan/adr/0005-ziel-repo-distribution.md) supersedes [`ADR-0001`](../docs/plan/adr/0001-skelett-distribution.md); §1/§2/§5 aufs Distributionsmodell nachgezogen | Distributionsmodell-CR |
| 0.8.0 | 2026-07-21 | CR: [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) an [`ADR-0005`](../docs/plan/adr/0005-ziel-repo-distribution.md) nachgezogen — das Zielrepo erhält den **vollen** vendored Template-Baum ([`LH-FA-09`](../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)), darum wiederkehrende Vorlagen **referenziert statt co-located**, derivative Indexe Fülle-wenn-Inhalt, Leerordner via `.gitkeep`; out-of-the-box gate-sicher ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Beim 0.7.0-CR übersehene LH-FA-02-Prämisse; die [`MR-008`](../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Abgrenzung ist damit aufgelöst | Emit gate-sicher (slice-024-Smoke) |
| 0.9.0 | 2026-07-22 | CR: [`LH-FA-06`](../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) + [`LH-FA-08`](../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) Durchsetzung + Workflow-Commands **Picker → Tool-als-Quelle** (das Tool bringt eine generische, je `--lang` parametrierte Fassung mit, abgeleitet aus Dogfood + Kurs-Prozess-Modulen; keine Kurs-Upstream-Ergänzung mehr als Vorbedingung). [`ADR-0006`](../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) revidiert die Picker-Herkunft aus [`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md)/[`ADR-0005`](../docs/plan/adr/0005-ziel-repo-distribution.md), Präzedenz [`LH-FA-04`](../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4). Reviewer-Skill bleibt Fetch; [`LH-FA-07`](../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (a-check) unberührt (hängt an hexagonalen Schichten) | Quellmodell-Reconciliation (Cluster A entsperren) |
