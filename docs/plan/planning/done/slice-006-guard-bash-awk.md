# Slice slice-006: Command-Guard bash+awk + bats-Gate

**Status:** open → next → in-progress → done (Datei wird durch die
Verzeichnisse bewegt, siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/templates-v4/kurs/de/02-planung/modul-05-planning-harness.md)).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt). Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`ADR-0004`](../../adr/0004-durchsetzungs-emission.md), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren).

**Autor:** Demo. **Datum:** 2026-06-13.

---

## 1. Ziel

Den in Phase 2 adoptierten **node**-Command-Guard durch eine **bash + awk**-
Implementierung ersetzen (zero neuer Dep, fail-closed bei Parse-Zweifel) und
das **`bats`-Gate** hochziehen — eine Implementierung ist zugleich die
Emissions-Quelle für [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (kein Drift). Erster echter Code-Slice;
self-contained (reines Shell, kein Go nötig).

## 2. Definition of Done

- [x] `.claude/hooks/pretooluse-command-guard.sh` läuft ohne `node`/`jq`:
      awk-Extraktor zieht `tool_input.command` aus der Hook-stdin-JSON;
      bei Parse-Zweifel → **fail-closed** (block). Erfüllt [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)/[`ADR-0004`](../../adr/0004-durchsetzungs-emission.md).
- [x] **Verhaltens-Parität** zum node-Guard: blockt Host-Toolchain
      (`go`/`pip`/`npm`/`cargo`/`apt`/`brew`/…), passt `make`/`git`/`docker`;
      Sub-Shell (`bash -c "…"`) rekursiv (Tiefe ≤ 3, darüber fail-closed);
      Zuweisungs-/Wrapper-Präfixe (`sudo`/`env`/…) übersprungen.
- [x] `bats`-Suite deckt: gültige JSON → korrekter Befehl; malformed JSON →
      block; blockierte vs. erlaubte Kommandos; `bash -c`-Verschachtelung;
      der Heredoc-/Commit-Message-Fall (bekannter False-Positive — dokumentiert).
- [x] Guard ist **shellcheck-clean**, keine Inline-Suppression (Hard Rule 3.2
      sinngemäß für Shell).
- [x] `make test` (`bats`) real angelegt und **im selben Commit** ins
      `gates`-Target genommen + in AGENTS.md §4 / harness/README.md §Sensors
      aus „Nicht behauptet" promotet (Promotion-Trigger, Hard Rule 3.1).
- [x] `make gates` grün auf frischem Checkout (mit `node` *abwesend* probeweise
      verifiziert — der Guard darf node nicht mehr brauchen).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/hooks/pretooluse-command-guard.sh` | rewrite | bash + awk statt node; Logik-Parität |
| `tools/harness/` (ggf. awk-Helfer) | neu/update | JSON-Feld-Extraktor, testbar isoliert |
| `test/guard.bats` | neu | Parität-, Parse- und fail-closed-Fälle |
| `Makefile` | update | `test` (bats) anlegen, in `gates` |
| AGENTS.md §4, harness/README.md §Sensors | update | Promotion `test` aus „Nicht behauptet" |

## 4. Trigger

[`ADR-0004`](../../adr/0004-durchsetzungs-emission.md) accepted (erfüllt). Sofort startbar; unabhängig vom Go-CLI.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **awk-Extraktor-Korrektheit** (verschachtelte Quotes, `\uXXXX`-Escapes):
  Kernfälle per `bats`; Zweifel → fail-closed (block). Der Guard ist
  Stolperdraht, keine Sandbox — Vollständigkeit ist nicht das Ziel.
- **bats-Verfügbarkeit**: Dev-/CI-Tooling (der Go-Pivot trennt Dev-Toolchain
  vom Runtime-Budget, [`ADR-0003`](../../adr/0003-go-native-binaries.md)). Der Container muss `bats` mitbringen.
- **Shell-Lint-Domäne**: AGENTS §3.2 ist nach dem Go-Pivot auf `golangci-lint`
  formuliert; für Shell-Skripte gilt weiterhin shellcheck — getrennt führen
  (ggf. eigener `shell-lint`-Gate als Folge-Slice).

## 7. Closure-Notiz (nach `done/`)

**Abschluss:** 2026-06-14. DoD vollständig; Gates grün.

**Ergebnis:** Der node-Command-Guard ist durch eine **bash + awk**-Implementierung
ersetzt. Der awk-Extraktor (`tools/harness/extract-command.awk`) ist ein
zeichenweiser JSON-Scanner mit Tiefen-/Key-Stack — er zieht nur `tool_input.command`
und unterscheidet Keys von Values (entschärft den „command-im-Value"-Fehlmatch).
Parse-Zweifel (malformed, abgeschnitten, `\u`-Escape im Befehl) → **fail-closed**.
28 `bats`-Tests (`test/guard.bats`) decken Extraktor- und Guard-Verhalten;
`make test` läuft Docker-only im digest-gepinnten `bats`-Image und ist in `gates`
sowie in [`AGENTS.md`](../../../../AGENTS.md) §4 / [`harness/README.md`](../../../../harness/README.md) §Sensors aus „Nicht behauptet" promotet.

**Nachweise (zwei beobachtbare Closure-Kriterien + Lerneintrag):**

- `make test` → 28/28 grün, im `bats`-Image **ohne `node`/`jq`** (verifiziert: beide
  im Image abwesend) — der Guard braucht node nicht mehr ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- `make gates` grün (docs-check + test + Nachweis); Guard ist shellcheck-clean
  (exit 0, koalaman/shellcheck:stable), **keine** Inline-Suppression.

**Steering-Loop-Lerneintrag:**

1. **`\u`-Selbstbeweis.** Beim Testen zeigte sich, dass selbst ein literales
   `g` in der Agent-Tool-Eingabe zu `g` dekodiert wird — genau die
   Umgehungsklasse, gegen die der Guard schützt. Bestätigt die Entscheidung,
   bei `\u` im Befehl **fail-closed** zu blocken statt zu dekodieren
   ([`ADR-0004`](../../adr/0004-durchsetzungs-emission.md): Stolperdraht, keine Sandbox). Test baut das Escape aus einer
   Backslash-Variable, damit der Testtext es nicht selbst dekodiert.
2. **Prozessabweichung (Guide → Sensor).** Das in [`AGENTS.md`](../../../../AGENTS.md) §1 verlangte
   Betriebsregelwerk wurde erst nach Nutzer-Hinweis gelesen, nicht zu
   Session-Beginn. Steering-Vorschlag: SessionStart-Hook, der das Regelwerk
   injiziert (offen — siehe Folge-Punkte), damit die Vorbedingung erzwungen
   statt erinnert wird.
3. **Dokumentierter False-Positive.** Heredoc-Body mit blockiertem Wort am
   Zeilenkopf (z. B. `pip` in einem `<<EOF`-Block) löst den Guard aus — als
   Test festgehalten und als bewusste Stolperdraht-Eigenschaft akzeptiert.

**Review (high-effort, Multi-Agent):** Ein 4-Winkel-Review (Korrektheit,
node→bash-Parität, adversariale Bypass-Suche, Qualität) lief über den Diff.
Ergebnis: **kein Parität-Regress** (kein Befehl, den der node-Guard blockte,
passiert den neuen). Gefunden und **gefixt**: ein fail-OPEN — ein malformed
`\u` (nicht 4 Hex) in einem String *vor* `command` desyncte den Scanner
(`i+=4` über das schliessende `"`), der Befehl wurde leer extrahiert → Guard
liess durch. Fix: der Extraktor verlangt jetzt genau 4 Hex nach `\u`, sonst
`exit 3` (fail-closed); zwei Regressionstests. Zusätzlich `strip_quotes` ohne
Subshell-Fork je Token (Hot-Path-Latenz, [`ADR-0004`](../../adr/0004-durchsetzungs-emission.md)). **Härtung
nachgezogen** (über node-Parität hinaus): einzelnes `&` (Hintergrund) und `|&`
sind jetzt Segment-Grenzen; führendes `{`/`}` wird als Wrapper-Prefix
übersprungen, sodass auch die Ein-Befehl-`{ go …; }`-Gruppe blockt (+5
Regressionstests). **Kein offener Review-Bypass mehr.**

**Folge-Slices (offen):**

- `shell-lint`-Gate (shellcheck im gepinnten Image) als eigener Slice — heute nur
  als Verifikation gelaufen, nicht als Gate (siehe §6).
- Durchsetzungsschicht-**Emission** im Picker (zweite Hälfte [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
  [`ADR-0004`](../../adr/0004-durchsetzungs-emission.md) Folge-Slice 2) — Guard ins Zielrepo emittieren, BLOCKED-Set je `--lang`.
- SessionStart-Hook fürs Regelwerk (Prozess-Härtung, siehe Lerneintrag 2).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
`tools/harness/` ist als GF deklariert ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)); `.claude/hooks/`
teilt dieselbe adoptierte Harness-Mechanik.
