# welle-07-arch-achse — Results-Notiz

**Welle:** [welle-07-arch-achse](welle-07-arch-achse.md). **Abschluss-Beleg statt Datum:** alle vier
Slices in `done/`, `make gates` Exit 0 (170 Dateien, 0 Befunde), `make mutate` 67 ok/0 (die neuen
Kompositions-, Renderer- und Emitter-Wächter je rot gesehen), `make full-smoke` Exit 0 mit **beiden**
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Richtungen real
gefahren, dieser Beleg-Text.

---

## 1. Geliefert

Das emittierte Skelett hat seit dieser Welle eine **zweite Achse** neben der Sprache: die
**Architektur**. Ein Zielrepo wählt sie je Modul, und das Architektur-Gate folgt der Wahl.

- **slice-044 — Kompositions-Seam.** Der Generator ist von der flachen `profiles()`-Map auf
  `lang-renderer × arch-layout` gehoben: arch-invariante Bau-/Toolchain-Gerüstung plus arch-gegatetes
  Code-Layout. **N Sprachen + M Architekturen statt N×M Profile.** Das `flat`-Skelett blieb dabei
  **byte-identisch** — vierfach belegt (Datei-Satz-Test, full-smoke, `mutate`, git-diff).
- **slice-045a — hexSlice-Layout + Go-Rollen-Renderer.** Das erste schichten-tragende Layout nach
  [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md): `internal/hexagon/domain`,
  `internal/hexagon/application/<area>/<usecase>` (mit slice-lokalen und area-geteilten Ports),
  `internal/adapters/{inbound,outbound}` und der Composition Root `cmd/app`. Referenz-geerdet aus dem
  realen `lab/examples/go`-Beispiel, nicht erfunden.
- **slice-045b — CLI-Achse `--arch`.** Durch `add-lang` und den Init-One-Shot verdrahtet, Default
  `flat`. Unbekannte **oder** sprach-fremde Architektur → Exit 2 mit sortierter Liste; `gen` besitzt
  das Achsen-Vokabular und die per-Sprache-Support-Prüfung, `cmd` nur das Exit-Code-Mapping.
- **slice-046 — konditionaler Arch-Gate-Emitter.** `--arch hexslice` dropt `<pfad>/.a-check.yml`
  (skip-if-present), `a-check.mk` (aus `a-check --print-mk`, auf die **erzeugende** Referenz gepinnt)
  und `harness/mk/arch-<modul>.mk` (konvergent, modul-scoped) — und `make gates` fährt a-check mit.
  Bei `flat` liegt **kein** Artefakt im Ziel
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

Damit ist **M4** erreicht: [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)
ist erfüllt, und zwar **emitted-only** — der Dogfood bleibt flach und behauptet a-check weiterhin
nicht als eigenes Gate (welle-07 §6).

## 2. Was funktionierte

- **Die Seam zuerst, das Layout danach.** slice-044 hat nur die Naht gelegt und dabei nichts am
  Verhalten geändert; slice-045a konnte das reiche Rollen-Set dann additiv einhängen. Die
  Byte-Identität des `flat`-Pfades war während der ganzen Welle die Rückversicherung — sie hat die
  bestehenden Sensoren geschützt, statt sie zu verschieben.
- **Doc führt, Code folgt.** [`ADR-0008`](../../adr/0008-arch-achse-emittiertes-skelett.md) (Mechanik)
  und [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) (konkrete Realisierung) standen vor
  der ersten Zeile Code, jeweils nach zwei Proposed-Review-Runden. Die Welle musste unterwegs kein
  einziges Mal auf eine Architektur-Entscheidung warten.
- **Der Re-Slice 045 → 045a/045b.** [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md) pinnte
  das Layout auf ~25 Rollen-Dateien; Layout+Renderer und CLI wurden getrennt, weil das Layout ohne CLI
  testbar ist, die CLI ohne Layout aber nicht. Beide DoDs blieben einzeln verifizierbar.
- **Rollen-Trennung, gemessen.** In slice-046 fanden Reviewer und Verifier **unabhängig voneinander**
  denselben Kern-Defekt (der include-once-Wächter keyte auf den dokumentierten Adopter-Override und
  hätte das Gate abgeschaltet, sobald jemand ihn benutzt). Dasselbe Signal wie in slice-038.

## 3. Was anders lief als geplant

- **Die Wellen-Vorbedingung war schwächer, als sie aussah.** Der Plan verließ sich auf den
  a-check-Pin aus [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md). Die reale Verifikation in
  slice-046 förderte zwei Dinge zutage, die keine ADR wissen konnte: `--print-mk` druckt einen im
  Binary **gebackenen** Pin, der dem laufenden Image nachhinkt, und die vom Bootstrap emittierte
  Baseline landete mit Modus **0700** im Ziel — für den Host unsichtbar, aber die Gates laufen als
  Nicht-Root über einem read-only Mount, und a-check brach dort mit „permission denied" ab. Beides
  wurde mit Test und Mutation nachgezogen.
- **Die Mono-Repo-Verortung war eine echte Entwurfsfrage.** Eine Root-Config mit Pfad-Präfixen
  kollidiert bei zwei Modulen; gewählt wurde **modul-scoped** (Config im Modul, Gate mountet nur das
  Modul) nach dem slice-037-Muster. Die Alternative hätte einen zweiten hexSlice-Modul-Fall still
  ungedeckt gelassen.
- **Zwei Review-Runden auf einem Slice.** slice-046 ging in Runde 1 als NICHT KONFORM (5 MEDIUM)
  zurück; Runde 2 auf den Fix-Diff war KONFORM, fand aber drei Punkte, die der **Fix selbst**
  eingeführt oder übersehen hatte. Das war kein Mehraufwand aus Formalismus — es war der Unterschied
  zwischen „behoben" und „wirklich behoben".
- **`make mutate` war die Reibungsquelle der Welle** (F-12): es mutiert den **Host**-Baum, blockiert
  damit jede lesende Rolle und ließ den Stop-Hook in jedem Warte-Turn anschlagen. Der strukturelle Fix
  ist als [slice-047](../done/slice-047-mutate-host-isolation.md) geschnitten, aber bewusst **nicht**
  Teil dieser Welle.

## 4. Steering-Loop-Einträge

- **Ein Marker muss messen, was der Lauf AUSGIBT — nicht, wie das geprüfte Ding heißt.** Der erste
  full-smoke-Marker suchte den Target-Namen `a-check-apps-hex`; `make` druckt aber die **Recipe**, und
  die trägt den Target-Namen nirgends (bei den Go-Gates steht er nur zufällig via `-t apps-hex:lint`
  darin). Der Sensor war rot, das Gate grün. **Regel: den Marker aus einer real gesehenen Ausgabezeile
  ziehen.**
- **Ein Klassen-Befund ist erst erledigt, wenn alle Instanzen gesucht wurden.** Ein Review-Finding
  nannte *eine* `| grep -q`-unter-`pipefail`-Stelle; genau die wurde behoben — die zweite Runde fand
  die **zweite Instanz im selben Slice**, ausgerechnet in der Zeile, die den Zähne-Beleg druckt.
  **Regel: bei einem Klassen-Befund über das ganze Artefakt greppen.**
- **Ein Fix an einer überdehnten Zusage kann selbst eine überdehnte Zusage sein.** Der Truth-Accuracy-
  Fix ersetzte „der Präfix hält die Slice-Regeln scharf" durch „a-check meldet die vergessene Slice" —
  wahr nur, wenn sie eine Schicht importiert. **Der Zwei-Runden-Präzedenzfall aus
  [`ADR-0007`](../../adr/0007-bootstrap-phasen.md) gilt damit auch auf Slice-Ebene, nicht nur bei ADRs.**
- **Eine Mutation muss VERHALTEN brechen, nicht das Kompilat.** Ein `sed`, das die einzige Verwendung
  einer Variable entfernt, färbt aus Compile-Grund rot und belegt den Wächter **nicht** (slice-045b,
  Fall 62). Der Mutations-Treiber meldete das korrekt als „rot aus falschem Grund".
- **Relocation heißt: Code, Wächter und Mutation zusammen bewegen** (slice-044/045a) — eine entfernte
  Mutation ist entfernte Deckung, und „behavioral gedeckt" ist keine Deckung im Sinne von
  [`AGENTS.md`](../../../../AGENTS.md) §3.6, solange kein Fall sie fährt.
- **Ein emittiertes Verzeichnis muss traversierbar sein wie ein frischer Klon.** 0700 ist auf dem Host
  unsichtbar und für ein Container-Gate tödlich. Diese Klasse trifft jedes künftige Tool, das das
  Zielrepo read-only als Nicht-Root liest.

## 5. Folge-Slices / offene Punkte

- **[slice-047](../done/slice-047-mutate-host-isolation.md)** (`in-progress/`, ohne Welle): `make mutate`
  gegen eine isolierte Kopie fahren, den Host-Baum nie anfassen. Löst die F-12-Klasse strukturell.
- **Benannte Restrisiken aus slice-046** (kein Folge-Slice, in seiner Closure-Notiz begründet): keine
  Atomaritäts-Zusage im Emit-Pfad · Fragment-Namenskollision erst bei einem Modul unter
  `arch/<sprache>` · der Sentinel verschiebt die Adopter-Override-Klasse auf einen tool-privaten Namen,
  tilgt sie nicht (Restfall fail-loud) · der Rot-Pfad des include-once-Sensors ist bauartbedingt nicht
  von `make mutate` erreichbar · `lateral-slice`/`port-locality` können mit der **einen** generierten
  Slice noch nicht feuern.
- **Weitere Architekturen** (clean/onion/…) und **hexSlice für andere Sprachen** als Go: bewusst
  out-of-scope (welle-07 §6), je nur mit belegtem Bedarf.
- **`done/`-Link-Churn:** achte Instanz in dieser Welle (die Review-Reports zeigten nach dem Move auf
  `in-progress/`). Eine Exemption bzw. ein Reconciliation-Helfer ist überfällig — Kandidat für die
  nächste Welle.

## 6. Verifikation (die Belege aus Schritt 1)

| Kriterium (welle-07 §3) | Beleg |
|---|---|
| Alle Welle-Slices in `done/` | `slice-044`, `slice-045a`, `slice-045b`, `slice-046` liegen in `docs/plan/planning/done/` |
| `make gates` grün | Exit 0 — `d-check: 170 Datei(en) geprüft, 0 Befund(e)`, `baseline-verify: v3.5.1 OK — 42 Dateien` |
| `make mutate` grün, neue Wächter je rot gesehen | **67 ok, 0 Befund(e)**; die Welle fügte die Fälle 60–71 hinzu, jeder einmal rot gesehen |
| `make full-smoke` belegt **beide** [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Richtungen | Exit 0, 11 OK-Zeilen. `hexslice`: `docker run … -v "…/apps/hex":/src:ro ghcr.io/pt9912/a-check@sha256:6425c93a… /src` **innerhalb** des zusammengeführten `make -j gates`, dazu `make a-check` Exit 0 am Root-Modul. `flat`: kein `.a-check.yml`/`a-check.mk`/Arch-Fragment, `make gates` grün ohne a-check |
| Zähne des emittierten Gates | ein eingeschmuggelter `domain → adapters`-Import färbt es rot: `internal/hexagon/domain/example/greeting.go:8: core-impurity: Kern importiert app/internal/adapters/outbound/notify` (im full-smoke-Output sichtbar) |
| Carveout-Audit (Modul 7) | **1 offener Carveout, unverändert gültig:** [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) (shell-lint deckt `.bats` nicht ab — technische Werkzeuggrenze). welle-07 fügte **keine** `.bats`-Datei hinzu, der Geltungsbereich ist unberührt. **Kein stilles rotes Gate in dieser Welle** |

**Grenze der Belege, ehrlich benannt:** `gates` lief auf dem finalen Baum. `mutate` und `full-smoke`
liefen auf dem Stand von `6a4e76f`; die Commits danach sind **rein dokumentarisch** (Closure-Notizen,
Roadmap, Review-Report-Links) und von `docs-check` im finalen `gates`-Lauf abgedeckt — sie berühren
keinen Code-Pfad, den die beiden Sensoren messen. Die CI fährt ohnehin `gates` + `smoke` +
`full-smoke` + `mutate` pro Push auf frischem Klon.
