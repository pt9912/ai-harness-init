# Lastenheft — ai-harness-init

**Version:** 0.2.0

**Status:** Draft

**Autor:** Demo, **Datum:** 2026-06-13.

> Anforderungen abgeleitet aus dem Hand-Bootstrap-Test ("attempt1") —
> jede `LH-` trägt ihren Reibungs-Ursprung (F1–F7).

---

## 1. Zweck und Geltungsbereich

ai-harness-init ist eine CLI, die ein bestehendes Git-Repo mit dem
AI-Harness-Kurs-Prozess bootstrappt: Templates vom gepinnten Kurs-Tag,
die Doc-Gate-Baseline und sprachspezifische Code-Gates aus den
lab/example-Skeletten. Nicht im Scope: das Füllen inhaltlicher
Urteilsschritte (Spec, ADRs, Modus-Wahl) — das bleibt Mensch/Agent.

## 2. Stakeholder

| Stakeholder | Rolle | Erwartung |
|---|---|---|
| Adopter-Team | Anwender | grünes Repo out-of-the-box, ohne Hand-Reparatur |
| Code-Agent | Anwender | selbstbeschreibender Einstieg (AGENTS.md) |
| Kurs-Maintainer | Quelle | Single Source of Truth bleibt lab/example + Templates |

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

**Beschreibung:** Wiederkehrende Templates (ADR, slice, welle, carveout,
review-report) bleiben co-located als `.template.md`; Singletons werden zu
`.md`-Zielen. Die Set-Index-README wird nie mitkopiert.

### LH-FA-03 — Doc-Gate-Baseline emittieren (F6, F7)

**Beschreibung:** `.d-check.yml` (Suffix-Ignore) + `harness.mk` (d-check
per Digest gepinnt). `ids`/`codepaths` nur mit existierenden Targets/roots
aktivieren — der Gate-Config wächst mit den Artefakten.

### LH-FA-04 — Sprachskelett-Picker (F4)

**Beschreibung:** Holt das Sprachskelett vom gepinnten Kurs-Tag, verdrahtet
Code-Gates. Emittiert nur lauffähige Make-Targets (keine halluzinierten Gates).

**Unterstützte Sprachen:** `go`, `python`, `kotlin`, `java`, `csharp`, `cpp`
(je `lab/example/<lang>`). `cpp` (C++/CMake: cmake/ctest/clang-tidy) wird
upstream im Kurs ergänzt; der Picker bleibt sprach-agnostisch.

### LH-FA-05 — Root-README emittieren (F1, F2)

**Beschreibung:** Aus der project-readme-Vorlage; Pointer-/Trust-Abschnitt
als gate-sichere Vorwärts-Verweise, bis die Ziele existieren.

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

- Inhaltliche Urteilsschritte (Spec/ADR/Modus) — bleiben Mensch/Agent.
- Kein Generator aus dem Nichts — nur Picker über lab/example. (C++/CMake wird
  upstream im Kurs als `lab/example/cpp` ergänzt; das Picker-Modell bleibt.)

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
