# Slice slice-008: shell-lint-Gate (shellcheck)

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0003`](../../adr/0003-go-native-binaries.md).

**Autor:** Demo. **Datum:** 2026-06-14.

---

## 1. Ziel

`make shell-lint` führt **shellcheck** (digest-gepinntes Image, Docker-only)
über die harness-eigenen Shell-Hooks/-Helfer als **echtes Gate** ein und nimmt
es in `gates`. Schließt die in slice-006 §6 benannte Shell-Lint-Lücke und
erweitert das Lint-Suppression-Verbot (`AGENTS.md` Hard Rule 3.2) sinngemäß auf
die Shell-Domäne neben `golangci-lint`.

## 2. Definition of Done

- [ ] `make shell-lint` läuft shellcheck im **digest-gepinnten** Image
      (Docker-only, [`ADR-0003`](../../adr/0003-go-native-binaries.md); Pin → [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) über
      `.claude/hooks/*.sh` und `harness/tools/*.sh`; exit 0 = clean.
- [ ] In `gates` aufgenommen (vor `record-gates`) und in `AGENTS.md` §4 /
      `harness/README.md` §Sensors aus „Nicht behauptet" promotet
      (Promotion-Trigger, Hard Rule 3.1).
- [ ] `AGENTS.md` Hard Rule 3.2 erweitert: Suppression-Verbot gilt auch für
      shellcheck (`# shellcheck disable` nur mit zentralem, begründetem
      Eintrag) — Shell-Domäne neben `golangci-lint`.
- [ ] `.bats`-Behandlung entschieden + dokumentiert (shellcheck parst die
      `@test`-Syntax nicht → ausgenommen oder via passender Option) — kein
      stiller Abdeckungsverlust.
- [ ] `make gates` grün; **keine** Inline-Suppression.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | `shell-lint`-Target + `SHELLCHECK_IMAGE`-Pin; in `gates` |
| `AGENTS.md` (§3.2, §4) | update | Hard Rule 3.2 Shell-Domäne; Promotion `shell-lint` |
| `harness/README.md` (§Sensors) | update | Promotion `shell-lint` aus „Nicht behauptet" |
| zentrale shellcheck-Config | ggf. neu | begründete Ausnahmen zentral (falls nötig) |

## 4. Trigger

Sofort startbar — unabhängig vom Go-CLI. Idealerweise nach/zusammen mit
slice-007 (dann sind mehr Shell-Hooks zu linten).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **shellcheck vs. `.bats`**: `.bats`-Dateien sind kein reines Shell — bei
  Einschluss drohen Parse-Fehler. Entweder ausnehmen (Risiko: ungelintete
  bats-Logik) oder dedizierte Behandlung; im Slice entscheiden und festhalten.
- **Pin-Wartung**: `SHELLCHECK_IMAGE`-Digest wächst in die
  Reproduzierbarkeits-Liste ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) — wie `D_CHECK_IMAGE`/`BATS_IMAGE`.
- **Verhältnis zu [`ADR-0003`](../../adr/0003-go-native-binaries.md)**: dieser verlegte die *Tool*-Toolchain auf
  Go/`golangci-lint`; shellcheck betrifft die **harness-eigenen Shell-Hooks**,
  nicht die Tool-Implementierung — kein Widerspruch, aber im Slice klarstellen
  (Mini-ADR nur, falls als Architektur gewertet).

## 7. Closure-Notiz (nach `done/`)

**Abschluss:** 2026-06-14. DoD vollständig; Gates grün.

**Ergebnis:** `make shell-lint` lintet die fünf harness-eigenen
Shell-Hooks/-Helfer (`.claude/hooks/*.sh`, `harness/tools/*.sh`) mit
**shellcheck** im digest-gepinnten Image
([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), Docker-only [`ADR-0003`](../../adr/0003-go-native-binaries.md)) und ist als Gate in
`gates` (vor `record-gates`). In AGENTS.md §4 / harness/README.md §Sensors aus
„Nicht behauptet" promotet; Hard Rule 3.2 deckt jetzt auch `# shellcheck
disable`. `.bats` ist bewusst ausgenommen (shellcheck parst die `@test`-Syntax
nicht), `.awk` ist kein Shell — im Makefile-Kommentar festgehalten.

**Nachweise (zwei beobachtbare Closure-Kriterien + Lerneintrag):**

- `make shell-lint` → exit 0 über 5 `.sh` im gepinnten shellcheck-Image; **keine**
  Inline-Suppression.
- `make gates` grün (docs-check 26/0 + test 35/35 + shell-lint + Nachweis).

**Steering-Loop-Lerneintrag:**

1. **Shell-Lint-Lücke aus slice-006 geschlossen.** Dort lief shellcheck nur als
   einmalige Verifikation; jetzt ist es ein echtes, gepinntes Gate — Guard und
   SessionStart-Injektor bleiben dauerhaft lint-clean erzwungen.
2. **Kein Widerspruch zu [`ADR-0003`](../../adr/0003-go-native-binaries.md).** Dieser verlegte die *Tool*-Toolchain
   auf Go/`golangci-lint`; shellcheck betrifft die harness-eigenen Shell-Hooks,
   nicht die Tool-Implementierung — kein neuer ADR nötig (Gate-*Anheben* →
   Steering-Loop, nicht -Lockern).
3. **`.bats` ungelintet:** bewusste Grenze (shellcheck kann `@test` nicht
   parsen) — Folge-Punkt, falls bats-Logik wächst.

**Folge-Slices / offen:**

- Go-`lint`/`build`/`test`-Gates (`golangci-lint`/`go build`/`go test`) mit dem
  Go-Code.
- Optionale `.bats`-Lint-Abdeckung (Vorverarbeitung + `shellcheck --shell=bash`),
  falls die bats-Logik komplexer wird.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`.claude/hooks/` und `harness/tools/` teilen die adoptierte Harness-Mechanik
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)).
