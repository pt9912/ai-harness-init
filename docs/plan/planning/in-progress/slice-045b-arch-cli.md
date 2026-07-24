# Slice slice-045b: CLI `--arch`-Verdrahtung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-07-arch-achse](../welle-07-arch-achse.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md), [ADR-0008](../../adr/0008-arch-achse-emittiertes-skelett.md).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

Das `--arch <arch>`-Flag ist durch `add-lang` und die `--lang`-One-Shot-Kurzform des Init
**verdrahtet**: der CLI-Wert wird an `composeSkeleton(…, arch)` durchgereicht, sodass
`add-lang go <pfad> --arch hexslice` das hexSlice-Skelett (aus slice-045a) emittiert und ohne
`--arch` (bzw. `--arch flat`) das flache. Eine **unbekannte Architektur** endet mit **Exit 2 +
sortierter Architektur-Liste** (Spiegel zur unbekannten-Sprache-Negative-AC).

## 2. Definition of Done

- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Arch-Achse, CLI-Teil): `add-lang <sprache> <pfad> --arch hexslice` emittiert das hexSlice-Layout; ohne `--arch`/`--arch flat` das flache — je ein `cmd`-Test.
- [ ] **Negative-AC:** `add-lang go <pfad> --arch <unbekannt>` → **Exit 2** + sortierte Architektur-Liste (`flat`, `hexslice`); analog beim Init-`--lang … --arch <unbekannt>`. Test referenziert.
- [ ] `--arch` je Modul (Mono-Repo): zwei `add-lang`-Läufe mit verschiedenen Architekturen koexistieren.
- [ ] `make gates` grün.
- [ ] `make mutate` grün — der neue Arch-Dispatch-/Exit-2-Wächter je rot gesehen (Mutation benannt + als `test/mutations/`-Fall).
- [ ] `make full-smoke` belegt die `--arch hexslice`-Richtung end-to-end (das Skelett trägt die Schichten; a-check selbst erst slice-046).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Vor Code den Ist-Stand messen: den `add-lang`/`--lang`-Dispatch in `cmd/` und `wireLang`
lesen (slice-037/038-Fluss), sehen wie `arch` heute (fest `archFlat`) durchgereicht wird.
`archLayout`/`goRole` für `hexslice` liegen aus slice-045a vor — dieser Slice fügt **nur** die
CLI-Achse hinzu.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/*.go` — Arg-Parsing | update | `--arch <arch>` neben `--lang` parsen; Default `flat`; an `wireLang`/`composeSkeleton` durchreichen |
| `cmd/ai-harness-init/*.go` — Arch-Validierung | update | `add-lang`/Init auf `gen.GenerateArch(…, arch)` umstellen; den `*gen.UnknownArchError` (aus slice-045a) auf **Exit 2 + sortierte `gen.SupportedArchs()`-Liste** abbilden, spiegelbildlich zur unbekannten-Sprache-Klasse (`*gen.UnknownLangError`) |
| `cmd/…_test.go` | neu | Happy-Path (`--arch hexslice`/`flat`) + Negative (Exit 2 + Liste) verankern |
| `test/mutations/NN-arch-cli-*.sh` | neu | rot-färbende Mutation für den Exit-2-Pfad (z. B. die Validierung entfernen → unbekannte Architektur nicht mehr Exit 2) |

## 4. Trigger

- **Beginn (`next` → `in-progress`):** slice-045a **done** — der `hexslice`-Renderer existiert,
  sonst hat das CLI-Flag kein Ziel-Layout zum Emittieren.
- **`in-progress` → `next` (zu groß):** unwahrscheinlich (reine CLI-Achse); falls doch,
  Happy-Path und Negative-AC trennen.
- **`in-progress` → `open` (blockiert):** falls der Init-`--lang`-One-Shot die Arch-Achse anders
  durchreichen muss als `add-lang` — Carveout + Rückfrage.

## 5. Closure-Trigger

DoD vollständig, `make gates` + `make mutate` + `make full-smoke` grün mit rot-gesehener Mutation,
Review konform + Verifier bestätigt die DoD, Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Zwei Eintrittspunkte** (`add-lang` + Init-`--lang`-One-Shot) müssen dieselbe Arch-Achse tragen —
  ein geteilter `wireLang`-Kern verhindert Divergenz (slice-037-Lehre: geteilter Kern).
- **sprach×arch-Support-Prüfung ZUERST (aus slice-045a-Review, INFO-1 — blockierend für die CLI):**
  heute rendert nur der Go-Renderer das hexSlice-Layout; `cppRole` liefert für die Schicht-Rollen `nil`,
  ein `GenerateArch("cpp", …, "hexslice")` gäbe ein **stilles Gerüstung-only-Skelett**. Bevor die
  `--arch`-CLI (via `GenerateArch`) einen Nutzer-Pfad öffnet, muss die (lang, arch)-Kombination
  validiert werden (unterstützt der Renderer die Architektur?) — sonst emittiert `add-lang cpp <pfad>
  --arch hexslice` still ein leeres Layout. Kandidat: eine sprach-deklarierte Arch-Menge oder ein
  Guard in `GenerateArch`, der eine layered-arch ohne Rollen-Beitrag als Fehler meldet.
- **Exit-2-Konsistenz:** die unbekannte-Architektur-Meldung muss dem unbekannte-Sprache-Format
  gleichen (Exit-Code + sortierte Liste), sonst zwei divergente Fehlerklassen.
- **Byte-Identität `flat`:** ohne `--arch` bleibt der Default-Pfad `flat` — der bestehende
  full-smoke-doc-only/flat-Lauf muss unverändert grün bleiben.

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** `--arch` ist durch `add-lang` und den Init-One-Shot verdrahtet (Default `flat`,
byte-identisch); `add-lang go <pfad> --arch hexslice` emittiert das hexSlice-Layout aus slice-045a,
unbekannte/sprach-fremde Architektur → Exit 2. Die slice-045a-Review-**INFO-1** ist aufgelöst: `gen`
besitzt jetzt die (lang, arch)-Support-Prüfung (`langArchs`), `cpp+hexslice` fällt fail-fast statt still
ein Gerüstung-only-Skelett zu schreiben. Review KONFORM (1 INFO), Verifier DoD BESTÄTIGT. Sensoren
real: `make gates` grün · `make mutate` **60 ok/0** (62/63/64 rot gesehen) · `make full-smoke` grün
(apps-hex build+**lint** real — der emittierte Lint auf dem Schichten-Code, den 045a nicht abdecken
konnte; cpp+hexslice → Exit 2).

**Anders als geplant.** Die Schichtung wurde schärfer als der Plan: `gen` besitzt das Achsen-Vokabular
(`SupportedArchs`, aus `langArchs` abgeleitet — eine Quelle) UND die per-Sprache-Support-Prüfung
(`archsForLang`); `cmd` besitzt nur das Exit-Code-Mapping (`callExitCode`). Zwei-stufige Validierung
(Tippfehler → globales Vokabular; sprach-fremd → sprach-Liste).

**Steering-Loop-Einträge:**
- **Mutation muss VERHALTEN brechen, nicht KOMPILAT (mutate-Befund-Weg 4 verdient sich seinen Platz).**
  Fall 62 war zuerst `errors.As(err, &uae)` → `false` — das ließ `uae` **ungenutzt** → Go-Compile-
  Fehler. `make mutate` meldete korrekt „rot, aber aus falschem Grund": eine Mutation, die das Kompilat
  bricht statt die Assertion, belegt den Wächter NICHT. Fix: `||` → `&&` (beide `errors.As` bleiben
  genutzt → kompiliert, der erwartete Test fällt an der Assertion). **Regel: eine sed-Mutation, die die
  einzige Verwendung einer Variable entfernt, färbt aus Compile-Grund rot — auf eine verhaltens-,
  nicht kompilat-brechende Form legen.**
- **F-12 strukturell auflösen (→ [slice-047](../open/slice-047-mutate-host-isolation.md)).** `make mutate`
  mutiert den **Host-Baum** (nur der Test läuft im Container, die Mutation nicht) — das machte diesen
  Slice zäh: mutate blockierte die lesenden Rollen, drei Background-Läufe wurden gekillt, der Stop-Hook
  nagte in jedem Warte-Turn. Was funktionierte: **Foreground** (der Befehl blockt den Turn → keine
  Yield/Stop-Hook-Zyklen → kein Kill). Der Backlog-Slice **slice-047** beseitigt die Wurzel (Zyklus
  gegen isolierte Kopie, Host-Baum nie anfassen).

**Folge-Punkte:** slice-046 (a-check-Emitter) unverändert offen — der emittierte `.a-check.yml`-Glob-Satz
muss die realen Areas/Slices (`example`/`greet`) enumerieren (aus slice-045a-Closure). Review-INFO
(`--arch=` leerer Wert) nicht-blockierend, kein Folge-Slice.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): additive CLI-Erweiterung
(`cmd/`, ein neuer Flag-Zweig + Validierung + Tests) auf dem bereits etablierten `add-lang`/`wireLang`-Dispatch —
kein Umbau, das Default-Verhalten (`flat`) bleibt byte-identisch. Kein Diskrepanz-Risiko.
