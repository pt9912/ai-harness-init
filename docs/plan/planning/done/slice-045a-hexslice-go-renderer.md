# Slice slice-045a: hexSlice-Arch-Layout + Go-Rollen-Renderer

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-07-arch-achse](welle-07-arch-achse.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md), [ADR-0008](../../adr/0008-arch-achse-emittiertes-skelett.md).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-24.

---

## 1. Ziel

Der Generator kann das **hexSlice-Code-Layout** in Go erzeugen: `archLayout("hexslice")`
liefert die Rollen-Menge, und der **Go-Rollen-Renderer** (`goRole`) rendert sie in die
kanonischen Verzeichnisse (`internal/hexagon/{domain,application}`, `internal/adapters/{inbound,outbound}`,
`cmd/<binary>`) — abgeleitet aus der kanonischen `hexslice-architecture`-Referenz
([ADR-0009](../../adr/0009-hexslice-arch-realisierung.md)). Reine Generator-Erweiterung an der
Kompositions-Seam aus slice-044; **noch ohne** CLI-Flag (das ist slice-045b) und **ohne** a-check
(slice-046). Das flache Layout bleibt **byte-identisch**.

## 2. Definition of Done

- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Arch-Achse, Layout-Teil): `composeSkeleton(goScaffolding, goRole, version, "hexslice")` erzeugt das vollständige hexSlice-Go-Skelett (domain/application/ports/adapters + `cmd/`) plus die arch-invariante Bau-Gerüstung; ein `gen`-Test verankert die exakte Datei-Menge + Verzeichnis-Struktur gegen die kanonische Referenz.
- [ ] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (`flat` byte-identisch): `composeSkeleton(…, "flat")` bleibt bit-für-bit unverändert (kein Content-Konstant der flat-Rollen berührt); der bestehende `flat`-Test grün, `git diff` zeigt keine Änderung an flat-Content.
- [ ] `archLayout("hexslice")` liefert die hexSlice-Rollen-Menge; `archLayout(<unbekannt>)` bleibt `nil`. Der gen-Seam `GenerateArch(dir, lang, version, arch)` (Rückwärts-`Generate` = `GenerateArch(…, "flat")`) meldet unbekannte Architektur als `*UnknownArchError` (sortierte `SupportedArchs()`-Liste) — die Grundlage, an die slice-045b die `--arch`-CLI-Validierung (Exit 2) hängt.
- [ ] **Renderer-Compile-Beleg:** das gerenderte hexSlice-Skelett übersetzt und seine Tests bestehen (`go test ./...` im generierten Temp-Repo, netzlos) — die Generator-String-Konstanten sind sonst ungeprüft (Repo-Gates linten sie nicht). Der volle Lint/Gate/CLI-Nachweis end-to-end folgt in slice-045b via full-smoke.
- [ ] `make gates` grün (`go test ./...` inkl. der neuen Renderer-Tests).
- [ ] `make mutate` grün — der neue Layout-/Renderer-Wächter je rot gesehen (die rot-färbende Mutation benannt und als `test/mutations/`-Fall abgelegt).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Vor Code den Ist-Stand messen: `archLayout`/`goRole`/`composeSkeleton` aus slice-044 lesen
(`internal/gen/arch.go`, `golang.go`), und die kanonische Referenz `hexslice-architecture/lab/examples/go`
als Rollen-Quelle spiegeln (Tool-als-Quelle, [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md)).
Die a-check-Config (`.a-check.yml`/`a-check.mk`) und das CLI-Flag sind **nicht** hier.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/arch.go` — `archLayout("hexslice")` + `SupportedArchs()` | update | den `hexslice`-Zweig ergänzen (fünf Schicht-Rollen + Composition Root); `flat` und `unknown→nil` unverändert; `SupportedArchs()` als sortierte Achsen-Vokabular-Quelle |
| `internal/gen/gen.go` — `GenerateArch` + `UnknownArchError` | update | arch-aware Public-Seam: `Generate` delegiert `…, "flat"` (byte-identisch), `GenerateArch` faltet die Arch-Achse ein und meldet unbekannte Architektur typisiert (slice-045b hängt Exit 2 daran); `profiles()`-Builder auf `func(version, arch)` gehoben |
| `internal/gen/golang.go` — `goRole` (hexslice-Zweige) + Inhalt | update | die Rollen in die kanonischen Go-Pfade rendern (`internal/hexagon/domain/example`, `internal/hexagon/application/example/greet/{command,handler,validator,result,ports}`, `application/example/ports`, `internal/adapters/{inbound,outbound}/…`, `cmd/app/main.go`) mit minimalem, kompilierendem Inhalt (eine example-Area, eine greet-Slice) |
| `internal/gen/hexslice_test.go` | neu | exakte Datei-Menge (16), Renderer-Compile-Beleg (`go test` im Temp-Repo), `flat`-Byte-Identität, `UnknownArchError`, `SupportedArchs` |
| `test/mutations/61-hexslice-role-fileset.sh` | neu | rot-färbende Mutation: eine Schicht-Datei (`goHexDomain,`) aus `goRole` entfernen → Datei-Satz-Test rot |
| `internal/gen/cpp.go` — `cppProfile(version, arch)` | update | Signatur-Angleich (Arch durchgereicht); cpp-hexslice-Renderer bewusst NOCH nicht (out-of-scope, s. §6) |

## 4. Trigger

- **Beginn (`next` → `in-progress`):** slice-044 **done** (Kompositions-Seam existiert) — erfüllt.
- **`in-progress` → `next` (zu groß):** falls die ~25 Rollen-Dateien plus Byte-Identitäts-Beweis
  eine Slice sprengen, den Renderer je Schicht (domain → application → adapters → cmd) zerlegen.
- **`in-progress` → `open` (blockiert):** falls die kanonische Referenz für eine Rolle keine
  eindeutige minimal-kompilierende Form hergibt — Carveout (Modul 7) + Rückfrage.

## 5. Closure-Trigger

DoD vollständig (alle Häkchen), `make gates` + `make mutate` grün mit rot-gesehener Mutation,
Review konform + Verifier bestätigt die DoD, Closure-Notiz mit Steering-Loop-Eintrag geschrieben.

## 6. Risiken und offene Punkte

- **Byte-Identität `flat`:** die additive `hexslice`-Erweiterung darf keinen flat-Content-Konstant
  berühren (slice-044-Lehre: additive Erweiterung schützt die Sensoren) — separat mit `git diff` belegen.
- **Renderer-Inhalt vs. Referenz:** minimal-kompilierend genügt; keine Über-Nachbildung der
  Referenz-Business-Logik (Order/CreateOrder) — die Struktur ist das Vertrag, nicht die Domäne.
- **a-check-Konformität** des gerenderten Layouts wird erst in slice-046 mit `make a-check` bewiesen;
  hier nur strukturell gegen die 5-Kanten-Erwartung aus [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md) geplant.
- **cpp + hexslice** ist bewusst NICHT gebaut (nur der Go-Renderer, §6-Grenze): `cppRole` liefert für die
  Schicht-Rollen `nil`, ein `GenerateArch("cpp", …, "hexslice")` gäbe ein Gerüstung-only-Skelett. Kein
  Nutzer-Pfad erreicht das in welle-07 (die `--arch`-CLI aus slice-045b validiert `go`+`hexslice` via
  full-smoke; cpp-hexslice ist als linearer Folge-Renderer vertagt). Beim cpp-hexslice-Renderer ist eine
  sprach×arch-Unterstützungs-Prüfung nachzuziehen (Folge-Punkt), damit die Kombination nicht still leer bleibt.

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** Der Go-Renderer erzeugt das hexSlice-Layout (13 Rollen-Dateien: domain/application/
ports/adapters + Composition Root, eine `example`-Area/`greet`-Slice) über die slice-044-Seam;
`GenerateArch(dir, lang, version, arch)` faltet die Arch-Achse ein, `Generate` delegiert `flat`
(byte-identisch). `flat` blieb vierfach belegt unangetastet. Review KONFORM (kein HIGH/MEDIUM),
Verifier DoD BESTÄTIGT. Sensoren real: `make gates` grün · `make mutate` 57 ok/0 (Fall 61 rot
gesehen) · **Renderer-Compile-Beleg** grün.

**Anders als geplant.** Der gen-Seam wuchs über „nur archLayout+goRole" hinaus: `GenerateArch` +
`UnknownArchError` + `SupportedArchs()` landeten hier (die gen-Schicht besitzt jetzt die
Arch-Validierung, slice-045b hängt nur Exit-2-Mapping + CLI daran) — sauberere Schichtung als der
ursprüngliche Schnitt; Plan §3 + slice-045b nachgezogen.

**Steering-Loop-Einträge:**
- **Neuer Sensor — Compile-in-Test für Generator-String-Konstanten.** Vom Generator emittierter Code
  lebt als Go-String-Konstante und wird von den **Repo-Gates NICHT gelesen** (nur Daten) — ein
  Datei-Satz-Test allein beweist Struktur, nicht Übersetzbarkeit. `TestGenerate_GoHexslice_Compiles`
  generiert ins Temp-Repo und fährt dort ein echtes `go test ./...` (netzlos, Docker-`test`-Stage,
  `exec.LookPath`-Skip host-los). Das fängt die Klasse „String-Konstante kompiliert nicht" **im
  liefernden Slice** statt erst im nachgelagerten full-smoke. Für künftige Sprach-/Arch-Renderer
  wiederverwenden.
- **Operative Gotcha — Watcher-Selbstmatch.** Ein `until ! pgrep -f 'harness/tools/mutate.sh'`-Watcher
  matcht **seine eigene Kommandozeile** (die das Muster enthält) → er terminiert nie. Watcher-Pattern
  müssen die eigene Prozess-Zeile ausschließen (`| grep -v until`) oder anders ankern. Zudem: `make
  mutate` (57 Fälle) liegt **über** dem 10-Min-Foreground-Limit → im Hintergrund fahren (harness-
  getrackt vom Hauptkontext, NICHT detached/Subagent — slice-044-Lehre).

**Folge-Punkte (kein neuer open/-Slice nötig, in bestehende Slices gezogen):**
- slice-045b: die **sprach×arch-Support-Prüfung** muss **vor** die `--arch`-CLI (INFO-1 aus Review) —
  sonst emittiert `add-lang cpp <pfad> --arch hexslice` still ein Gerüstung-only-Skelett.
- slice-046: der emittierte `.a-check.yml`-Glob-Satz muss die realen Areas/Slices (`example`, `greet`,
  `example/ports`) enumerieren (nicht die Referenz-`order/createorder`) — Layout↔Config-Kopplung.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): die Änderung ist eine
**additive Generator-Erweiterung** (`internal/gen`, neue Renderer-Zweige + neue Tests) an der bereits
in slice-044 etablierten Kompositions-Seam — kein Bestandscode wird umgeschrieben, das flat-Layout
bleibt byte-identisch. Kein Inventur-/Diskrepanz-Risiko, kein Reconciliation-Aufwand.
