# Slice slice-037: add-lang-Subkommando (wiederholbar, Mono-Repo)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** welle-05.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`ADR-0007`](../../adr/0007-bootstrap-phasen.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-23.

---

## 1. Ziel

<!--
Was liefert dieser Slice in einem Satz? Liefer-Fokus, kein "wir
machen aufräumen".
-->

Das Tool bekommt ein **wiederholbares** `ai-harness-init add-lang <sprache> <pfad>`-Subkommando, das je
Aufruf ein **`<pfad>`-verortetes** Sprachskelett + dessen **Code-Gate-Fragment** (`harness/mk/<modul>.mk`,
Build-Kontext `<pfad>`) + das **`blocked/<sprache>`-Fragment** (per-Sprache wiederverwendet,
skip-if-present) droppt — mehrere Aufrufe ergeben ein **Mono-Repo**
([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md)). Der bestehende `--lang <X>`-Init bleibt als
**One-Shot-Kurzform** (Init + ein `add-lang(., <X>)`) rückwärtskompatibel; `emit.Enforce` wird dabei
**sprach-agnostisch** (der `blocked/<lang>`-Drop wandert komplett zu `add-lang`).

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [ ] `ai-harness-init add-lang <sprache> <pfad>` existiert als Subkommando (Dispatch getrennt vom
  Default-Init), droppt Skelett nach `<pfad>` + `harness/mk/<modul>.mk` + `blocked/<sprache>` und ist
  **wiederholbar** (zweiter Aufruf für ein anderes Modul/eine andere Sprache → Mono-Repo, kein Fehler).
  Rot gesehen: eine Mutation, die den Subkommando-Dispatch entfernt/den Fragment-Drop unterschlägt, färbt
  einen Test rot ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)).
- [ ] Das Code-Gate-Fragment ist **`<pfad>`-aware**: `docker build <pfad>` als Build-Kontext; bei
  Subdir-Modulen **modul-scoped** Targets (`test-<modul>`/`lint-<modul>`/`build-<modul>`, kollisionsfrei bei
  mehreren Modulen), bei Root (`--lang`-One-Shot, `<pfad>=.`) die bestehenden `test`/`lint`/`build`
  (rückwärtskompatibel). `GATE_CHECKS +=` je Modul.
- [ ] `emit.Enforce` ist **sprach-agnostisch** (kein `blocked/<lang>`-Drop mehr); `blocked/<sprache>` kommt
  ausschließlich aus `add-lang`, **skip-if-present** (zweites Modul gleicher Sprache clobbert nicht).
- [ ] `--lang <X>`-Init bleibt rückwärtskompatibel: = Init (sprachlos) + `addLang(., <X>)`; dieselbe
  `addLang`-Funktion trägt beide Pfade.
- [ ] `make full-smoke`: nach `add-lang go <pfad>` läuft `make -j gates` grün **inkl.** Go-Gates
  (`record-gates` strikt zuletzt, [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Z. 157); der Guard blockt
  `go` (via `blocked/go`) + `pip` (Boden).
- [ ] `make gates` grün (Dogfood).
- [ ] Doku: [`architecture.md`](../../../../spec/architecture.md) §4.2 (add-lang-Sequenz) prüfen/nachziehen;
  ADR-Index/README bei berührtem CLI-Vertrag.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/golang.go` | refactor | `goProfile` liefert nur noch das **Skelett** (`go.mod`, `Dockerfile`, `.golangci.yml`, `cmd/app/main.go`) — das `harness/mk/*.mk`-Fragment wandert raus; neu: `gen.CodeGateFragment(lang, path)` (rendert `<pfad>`-Build-Kontext + modul-scoped/root-Targets) + `gen.ModuleName(path, lang)` |
| `internal/emit/enforce.go` | refactor | `Enforce` sprach-agnostisch (kein `blocked/<lang>` mehr, kein `lang`-Param); `blocked/<sprache>`-Drop wird `emit.BlockedFragment(targetDir, lang, force)` **skip-if-present**, von `addLang` gerufen |
| `cmd/ai-harness-init/main.go` | update | Subkommando-Dispatch (`add-lang <sprache> <pfad>` vs. Default-Init); `addLang(targetDir, path, lang, force, …)` extrahiert (Skelett→`<pfad>` + `harness/mk/<modul>.mk` + `BlockedFragment`); `--lang`-Init ruft `addLang(., lang)`; `Enforce` ohne `lang` |
| `internal/wire/wire.go` | prüfen | Placer bleibt rein; `addLang` legt das Skelett per `wire.Place` nach `targetDir/<pfad>` — evtl. Ziel-Join-Anpassung |
| `harness/tools/full-smoke.sh` | update | E2E: `add-lang go <subdir>` → `make -j gates` grün inkl. modul-scoped Go-Gates; Guard blockt go+pip; **wiederholbar** (zweites `add-lang` clobbert `blocked/go` nicht) |
| `internal/**/\*_test.go` | update | `gen.CodeGateFragment`/`ModuleName`, `Enforce` sprach-agnostisch, `BlockedFragment` skip-if-present, `addLang`-Verdrahtung, Subkommando-Parse |
| `test/mutations` | update | neu: Subkommando-Dispatch entfernt · `<pfad>`-Build-Kontext falsch · `blocked`-skip-if-present-Bruch · modul-scoped-Target-Kollision |

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

**Start** (`next` → `in-progress`): slice-036 in `done/` (Guard-Boden gebacken + `blocked/*`-Union, das
`--lang`-One-Shot droppt `blocked/<lang>`). Der Implementer beginnt, sobald der Slice nach `next/` gezogen ist.

**Rückführungen:**
- `in-progress` → `next`: Subkommando-Dispatch + `gen`-Skelett/Fragment-Split + `<pfad>`-Render +
  `emit`-Enforce/BlockedFragment-Umbau + modul-scoped Targets + full-smoke sprengen eine Session → neu zerlegen.
- `in-progress` → `open`: blockiert, falls die `<pfad>`-aware Fragment-Assembly ein `make -j gates`-Ordnungs-
  oder Kollisionsproblem zeigt, das erst ein Folge-ADR löst (Carveout, Modul 7).

## 5. Closure-Trigger

<!--
Wann ist der Slice done?
"DoD vollständig + PR gemerged + Closure-Notiz geschrieben."
-->

DoD vollständig · `make gates` grün · `make full-smoke` (`add-lang go <subdir>` + wiederholbar +
Guard go/pip) + `make mutate` grün · Slice per `git mv` nach `done/` · Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

<!--
Was könnte schief gehen? Welche Carveouts entstehen ggf.?
-->

- **Target-Kollision im Mono-Repo:** zwei Module gleicher Sprache dürften nicht beide `test`/`lint`/`build`
  definieren. Deshalb sind Subdir-Module **modul-scoped** (`test-<modul>` …); der Root-One-Shot (`<pfad>=.`)
  behält `test`/`lint`/`build` (Rückwärtskompat mit `smoke.sh`/`full-smoke.sh`). Der Modul-Name kommt aus
  `<pfad>` (`apps/api` → `apps-api`), Root → die Sprache.
- **`<pfad>`-Build-Kontext:** das Fragment baut `docker build <pfad>` (Dockerfile im Skelett unter `<pfad>`,
  `COPY . .` relativ zum Kontext) — nicht `docker build .`. Falscher Kontext = Build-Fehler; `full-smoke`
  muss das rot-sehen.
- **`blocked/<sprache>` skip-if-present (Mono-Repo-Kern):** ein zweites Go-Modul darf `blocked/go` **nicht**
  clobbern/duplizieren — `BlockedFragment` ist skip-if-present. Die **breitere** Idempotenz-Klassifikation
  (Skelett-Dateien `main.go`/`go.mod`/`Dockerfile` skip-if-present beim **Re-Lauf desselben** Moduls,
  Aggregator konvergent — [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Z. 102) ist **slice-038**; hier
  gilt für Skelett-Dateien noch die bestehende `--force`-Semantik (refuse-if-present).
- **`Enforce`-Split-Regression:** `Enforce` verliert den `lang`-Param → jeder Aufrufer (Init-Pfad,
  `emitTargets`, Tests) muss nachziehen; ein übersehener Aufrufer bricht den Build. Gate + Tests fangen es.

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

Alle berührten Sub-Areas sind **GF** (Greenfield) — siehe Kurs Modul 5 §Worked Mini-Example und die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) (`*` = Greenfield).
Kein BF/Hybrid, daher genügt dieser Hinweis.
