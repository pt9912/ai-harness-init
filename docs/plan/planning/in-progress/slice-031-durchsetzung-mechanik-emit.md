# Slice slice-031: Durchsetzungs-Mechanik emittieren (Gate-Nachweis + Stop-Hook)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-04-durchsetzung-und-emission](../welle-04-durchsetzung-und-emission.md).

**Bezug:** [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md), [`ADR-0004`](../../../../docs/plan/adr/0004-durchsetzungs-emission.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-22.

---

## 1. Ziel

Der Emit legt die **Durchsetzungs-Mechanik** ins Zielrepo: den **Gate-Nachweis**
(`harness/tools/record-gates.sh` + `harness/tools/working-tree-hash.sh`, in `make gates`
als letztes Prerequisite verdrahtet) und den **Stop-Hook** (`.claude/hooks/stop-require-gates.sh`
+ `.claude/settings.json`, das ihn verdrahtet) — als **Tool-als-Quelle**
([`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md):
die Durchsetzungs-Mechanik ist tool-erzeugt, nicht gefetcht). Damit ist das gebootstrappte
Repo **selbst** gegen halluzinierte Gate-Läufe abgesichert, nicht nur das Dogfood.
Der Guard (`--lang`-spezifisches BLOCKED-Set) ist **nicht** Teil — das ist slice-032;
`CLAUDE.md` bleibt **autort** (kein Emit, [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)).

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [ ] [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (Mechanik-Teil): der Emit legt ins Ziel — `harness/tools/record-gates.sh`, `harness/tools/working-tree-hash.sh`, `.claude/hooks/stop-require-gates.sh` (je 0o755) und `.claude/settings.json` (Stop-Hook verdrahtet, **ohne** PreToolUse — der Guard ist slice-032). Test belegt: emittiert, exec-Bit gesetzt.
- [ ] `record-gates` ist in die **Ziel-`make gates`** als **letztes** Prerequisite verdrahtet (läuft nur bei grünen Gates, stempelt den Content-Hash) — strukturell belegt (Ziel-Makefile bindet die Mechanik ein; `record-gates` läuft nach `docs-check`).
- [ ] Die emittierten Mechanik-Skripte sind **sprach-agnostisch** (verbatim aus tool-eigener Quelle, kein `--lang`-Zweig) — die dogfood-spezifischen [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Kommentar-Refs sind in der generischen Fassung entfernt/neutralisiert (kein toter Verweis im Ziel).
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): `make full-smoke` belegt real, dass im gebootstrappten Ziel `make gates` den Stempel schreibt und der Content-Hash von `record-gates` == `working-tree-hash` ist (nicht nur behauptet) — der Nachweis-Kreis schließt sich end-to-end.
- [ ] `make gates` grün; `make mutate` deckt die neuen Wächter (rot gesehen).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/*` | neu | generische (sprach-agnostische) Fassungen der Mechanik-Skripte: `record-gates.sh`, `working-tree-hash.sh`, `stop-require-gates.sh`, `settings.stop.json` — aus dem erprobten Dogfood, MR-Refs neutralisiert |
| `internal/emit/enforce.go` | neu | `//go:embed templates/enforce/*` + `Enforce(targetDir, force)`: schreibt die 4 Dateien an ihre Zielpfade (0o755 für `.sh`) — Muster `BaselineVerify` |
| `internal/wire/` (Makefile-Assembly) | update | `record-gates`-Target + `gates: record-gates` ans Ziel-Makefile anhängen (nach `docs-check` → läuft zuletzt) |
| `cmd/ai-harness-init/main.go` | update | Phase 3 Pre-Flight (`emitTargets`) um die Enforce-Zielpfade; Phase 4 `emit.Enforce(...)` aufrufen |
| `internal/emit/enforce_test.go` | neu | belegt: 4 Dateien emittiert, exec-Bit, settings.json ohne PreToolUse |
| `harness/tools/smoke.sh` | update | Präsenz der Mechanik im Ziel (positiver Vertreter) |
| `test/mutations/` | neu | rot färbender Wächter je neuer Zusage (§3.6) |

## 4. Trigger

<!--
Wann beginnt dieser Slice? (`next` → `in-progress`: Implementer beginnt.)
Beispiele: "Wenn Welle X done." / "Wenn Carveout CO-NN aufgelöst."

Auch die zwei Rückführungen vorab benennen — unter welcher Bedingung
geht dieser Slice zurück?
- `in-progress` → `next`: zu groß, zurück zur Zerlegung.
- `in-progress` → `open`: blockiert (Carveout? siehe Modul 7).
(kanonische Definition: [`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine))
-->

slice-030 in `done/` (der `.harness/`-Emit-Pfad ist geöffnet, [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) accepted). Zweiter welle-04-Slice — der erste **Tool-als-Quelle**-Emit der Durchsetzung.

Rückführungen: `in-progress → next`, falls die Mechanik doch zwei getrennte Slices trägt (z. B. Gate-Nachweis-Verdrahtung ins Makefile erweist sich als eigener Schnitt gegenüber dem Stop-Hook-Emit). `in-progress → open`, falls sich der Emit als blockiert erweist (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation bestätigt + Closure-Notiz → nach `done/`. Danach trägt das gebootstrappte Ziel dieselbe Gate-Nachweis-/Stop-Hook-Absicherung wie das Dogfood; slice-032 (Guard, `--lang`-BLOCKED-Set) setzt auf `.claude/settings.json` auf.

## 6. Risiken und offene Punkte

- **`settings.json`-Interdependenz mit slice-032.** `settings.json` verdrahtet Stop-Hook (dieser Slice) **und** Guard (slice-032). slice-031 emittiert es **Stop-only** — würde es schon `PreToolUse` auf den noch nicht emittierten Guard verweisen, liefe im Ziel ein Hook auf ein fehlendes Skript. slice-032 erweitert `settings.json` um den Guard. Test: die emittierte `settings.json` enthält **keinen** `PreToolUse`-Block.
- **`record-gates`-Reihenfolge im Ziel-`make gates`.** `record-gates` muss **zuletzt** laufen (nur bei grünen Gates stempeln). Make führt Prerequisites in Deklarations-Reihenfolge über kombinierte Regeln aus — die Verdrahtung muss `gates: record-gates` **nach** dem `gates: docs-check` des Wire anhängen, sonst stempelt es zu früh. Der Voll-Smoke prüft den geschlossenen Nachweis-Kreis, nicht nur die Präsenz.
- **Gate-Neutralität im Ziel.** Die Mechanik landet unter `.claude/` und `harness/tools/` — die emittierte `.d-check.yml` ignoriert `.harness/**`, scannt aber `harness/**` (codepaths-Root). `record-gates.sh`/`working-tree-hash.sh` sind `.sh` (kein `.md`) → nicht doc-gate-relevant; `.claude/**` ist nicht im Scan. Der Voll-Smoke bestätigt Gate-Neutralität, nicht annehmen (Kontrast slice-028).
- **Sprach-Agnostik (Messbefund).** Die Mechanik-Skripte tragen **keinen** `--lang`-Zweig (reine git/sha256/Hook-Infrastruktur) — anders als die welle-04-Plan-Formulierung „je `--lang`" nahelegt (die gilt für slice-032s Guard-BLOCKED-Set). Falls sich wider Erwarten doch eine Sprach-Abhängigkeit zeigt, `in-progress → next`.
- **Zielmengen-Kopplung.** Der cmd-Pre-Flight (Phase 3) und der Emit (Phase 4) müssen dieselben neuen Zielpfade sehen (Muster slice-028: sonst falsch-grün / Kollision unbemerkt).

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (`internal/emit/`, `internal/wire/`, `cmd/`, `harness/tools/`,
`test/` — siehe Kurs Modul 5 §Worked Mini-Example): adoptierte Emit-/Wire-Mechanik, tool-eigene
Quelle (die Mechanik-Skripte sind im Dogfood erprobt und werden als generische Fassung
mitgeliefert), niedriges Evidenz-/Diskrepanz-Risiko.
