# Slice slice-022a: Baseline-Fetch ins Zielrepo (additiv)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md), [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20, **re-sliced 2026-07-20.**

---

## 1. Ziel

> **Re-Slice 2026-07-20.** Dieser Slice hieß slice-022 und trug Baseline-Fetch **und**
> Embed-Entfernung zusammen. Die Ist-Messung vor der Implementierung ergab: (a) der
> Fetch-Umbau ist kein „update", sondern ein Umbau der Extrakt-Kernlogik (streaming
> gzip+tar → ZIP, das `io.ReaderAt` verlangt), (b) [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)s Prüfsummen-AC
> braucht einen **Ziel-Verifier**, den weder Template-Satz noch Emit-Pfad heute liefern.
> Beides zusammen sprengt den Ein-Sitzungs-Review → Teilung nach der §4-Rückführung, die
> der Plan vorsah. **022a ist additiv** (Embed bleibt, von `test/skel-drift.bats` bewacht),
> **[slice-022b](slice-022b-embed-raus.md)** räumt es ab. Der Zwischenzustand „zwei
> Template-Quellen" ist damit kurz **und bewacht** — die ursprüngliche §6-Sorge trifft
> schwächer als beim Schneiden angenommen.

`internal/fetch` holt das **sha256-gepinnte Baseline-Bundle** (`lab-regelwerk.zip`) und legt
Regelwerk **und** Templates als vendored Baseline ins Zielrepo — samt `SHA256SUMS` und einem
**tool-generierten `baseline-verify`**, mit dem das Ziel seine Baseline netzlos prüfen kann
([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)). Das Zielrepo erhält damit erstmals ein Regelwerk. Der
Embed-Pfad bleibt in diesem Slice **unangetastet**.

## 2. Definition of Done

- [x] [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) Happy Path: der Bootstrap legt Regelwerk **und** Templates als `.harness/baseline/<version>/{regelwerk,templates}/` + `SHA256SUMS` im Zielrepo ab (spiegelt [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) fürs Ziel), Test referenziert.
- [x] [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) Prüfsummen-AC: das Tool **generiert** einen `baseline-verify` (Tool-als-Quelle, wie `d-check --print-mk`), der **Integrität und Vollständigkeit** prüft — nicht nur `sha256sum -c`. [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3 belegt, dass `-c` allein bei einer **eingelegten** Datei grün bleibt; diese Lücke wird **nicht** ins Ziel vererbt.
- [x] `SHA256SUMS`-Form nach [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2: über **alle** Dateien beider Bäume, Pfade relativ zu `<tag>/`, `LC_ALL=C`-sortiert, die Datei selbst ausgenommen.
- [x] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): das Asset ist **sha256-gepinnt** und wird **vor** dem Entpacken verifiziert ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1 — Provenienz ≠ Integrität); zwei Läufe mit gleicher Version → identische Ablage.
- [x] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) Kein-Halluzinat-AC: fehlt das Kurs-Asset zur Version oder bricht der sha256, wird **begründet nicht emittiert** (kein erfundenes Regelwerk, keine Teil-Baseline). `make gates` bleibt **offline-grün** — der Netz-Fetch ist Bootstrap-Pfad, kein Gate.
- [x] **Abgrenzung zu [slice-022b](slice-022b-embed-raus.md) belegt:** `internal/emit/skel` ist unverändert und `test/skel-drift.bats` weiter grün — dieser Slice fügt hinzu, er räumt nicht ab.
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/fetch` | update | ZIP-Pfad (`archive/zip` braucht `io.ReaderAt` → Bytes puffern, kein Streaming) **neben** dem bestehenden Tarball-Pfad; sha256-Verify **vor** dem Entpacken |
| `internal/fetch` | neu | `SHA256SUMS`-Erzeugung nach [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2 |
| `internal/emit` | neu | `baseline-verify` generieren (Tool-als-Quelle; Integrität **+** Vollständigkeit) |
| `cmd/ai-harness-init` | update | Baseline-Fetch in den Init-Flow; `fetch.Skeleton` bleibt vorerst (trägt die `--lang`-Validierung, s. §6) |
| Fetch-Tests | neu/update | ZIP-Fixture, sha256-Mismatch → kein Teil-Emit, `SHA256SUMS`-Form, Determinismus |

**Nachgeführt 2026-07-20 (aus den Review-Runden).** Modul 9 macht diese Tabelle zum
*Protokoll* des Slice; vier Artefakte kamen dazu, die beim Schneiden nicht absehbar waren:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/emitted-baseline-verify.bats` | neu | Das emittierte Skript war nur gegrept, nie ausgeführt — genau deshalb passierte H1 (eingelegter Symlink → „OK") die Suite. Zehn ausführende Fälle |
| `harness/tools/baseline-verify.sh`, `test/baseline-verify.bats` | update | **Scope-Ausweitung, bewusst entschieden:** H1 traf den Dogfood-Zwilling vorbestehend. Den emittierten zu fixen und das Gate, das in `make gates` dieses Repos läuft, blind zu lassen, war nicht vertretbar |
| `Makefile` | update | `shell-lint` deckt `internal/emit/templates/*.sh` — ohne das ginge ein **ungelintetes** Skript ins Zielrepo. Verschärfung, keine Lockerung (Hard Rule 3.5 unberührt) |
| `harness/tools/smoke.sh` | update | Kopf-Kommentar kannte den zweiten Netz-Fetch nicht (Doku-Drift) |

## 4. Trigger

[`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) accepted (**erfüllt 2026-07-19**) und welle-02 aktiv. Dieser Slice ist der
**erste** der umgeplanten welle-02.

Rückführungen: `in-progress → next`, wenn schon der Fetch-Umbau allein (ZIP + sha256 +
`SHA256SUMS` + generierter Verifier) den Ein-Sitzungs-Review sprengt — dann den Verifier
als eigenen Slice führen. `in-progress → open`, wenn das Kurs-Asset die Templates nicht in
der von [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) verlangten Zweiklassigkeit trägt (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Entsperrt
[slice-022b](slice-022b-embed-raus.md).

## 6. Risiken und offene Punkte

- **ZIP ≠ Tar (gemessen, nicht vermutet):** der heutige Pfad (`internal/fetch`) ist ein
  *streamender* gzip+tar-Leser über den codeload-**Repo**-Tarball. `archive/zip` verlangt
  `io.ReaderAt` + Größe, also die Bytes vollständig gepuffert. Das trifft sich mit
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1 (sha256 über die Roh-Bytes **vor** dem Entpacken), ist aber
  ein Umbau der Kernlogik — auch die Test-Fixture (heute gzip-Tar-Writer) zieht mit.
- **Der generierte `baseline-verify` ist neues Tool-Wissen** und damit Wartungslast — derselbe
  Preis, den [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) für die Generator-Klasse ausdrücklich benennt. Er muss
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3 abbilden, sonst erbt das Ziel ein stilles Grün.
- **`--lang` hängt heute am Skelett-Fetch:** `cmd/ai-harness-init` holt das Skelett **zuerst**,
  fail-fast — das ist die *einzige* Sprachprüfung. Dieser Slice lässt sie deshalb bewusst
  stehen; slice-023 (Generator) löst sie ab. Ohne diese Setzung stünde zwischen 022a und 023
  ein Bootstrap ohne Sprachvalidierung.
- **Zwei Template-Quellen bis [slice-022b](slice-022b-embed-raus.md)** — bewusst, kurz und von
  `test/skel-drift.bats` bewacht (Embed == vendored bleibt geprüft, bis das Embed fällt).

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** `internal/fetch.Baseline` holt das sha256-gepinnte `lab-regelwerk.zip`,
verifiziert es **vor** dem Entpacken und legt Regelwerk + Templates als vendored Baseline
des Ziels ab (`SHA256SUMS` nach [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2); `emit.BaselineVerify` emittiert den
tool-generierten Verifier nach `tools/harness/`. Unabhängig verifiziert am realen Asset:
43 Dateien (21+21+Summen), byte-identisch zur vendored Baseline dieses Repos, `make smoke`
Exit 0. Der Embed-Pfad blieb unangetastet — die Abgrenzung zu
[slice-022b](slice-022b-embed-raus.md) hält.

**Was anders lief.** Der Slice brauchte **zwei Review- und zwei Verifikations-Runden**.
Der erste Review war merge-blockierend (HIGH: das emittierte Gate-Skript meldete einen
eingelegten Symlink als „OK"), der zweite ebenfalls (zwei MEDIUM, **beide durch meine
eigenen Fixes eingeführt**). Der Umfang wuchs über die geplante §3-Tabelle hinaus — nachgeführt,
siehe dort. Positiv: alle vier Runden liefen in frischem Kontext, und jede fand etwas, das
die vorige nicht sah.

### Steering-Loop-Eintrag — geschärfte Regel

**Die Klasse: „die Zusage greift weiter als die Abdeckung."** Drei Instanzen in **einem**
Slice, jede von einer anderen Rolle gefunden:

| | Zusage | Wirklichkeit |
|---|---|---|
| M1 | Doc-Kommentar beschrieb `--force`-Semantik | im Code nicht vorhanden |
| N1 | Fix lieferte die Semantik | brach dafür zwei andere Zusagen derselben Datei |
| Verifier | „bis zum finalen Rename bleibt destDir unveraendert" | `MkdirAll` legt destDir vorher an |

Dazu zweimal dieselbe Signatur bei **Tests**: `TestBaselineVerify_BothAxes` war auf den Marker
`find . -type f` gepinnt — auf exakt das Detail, das den H1-Fehler *enthielt*; und
`TestBaseline_TraversalEntriesEscapeNothing` prüfte „bricht nicht aus", während zwei Einträge
seiner eigenen Fixture unbeobachtet **im** Baum landeten.

**Geschärfte Regel für Folge-Slices:** Eine Zusage in Doc-Kommentar, Test-Namen oder
Commit-Message ist erst fertig, wenn ihr **Gegenbeispiel** benannt ist — *was genau müsste
passieren, damit sie bricht, und beobachtet das jemand?* Ein Test, dessen Name eine
Eigenschaft behauptet, muss die Eigenschaft messen, nicht ihre aktuelle Implementierung.
Praktisch heißt das: **rot gesehen haben**, bevor die Zusage geschrieben wird. Die drei
Zähne-Beweise dieses Slice (Pin-Kopplung, Sortier-Achse, H1-Symlink) haben getragen — die
Stellen ohne Zähne-Beweis sind exakt die, die durchgerutscht sind.

### Benannte Spec-Lücke (I3)

`tools/harness/` mischt im emittierten Repo **zwei Herkunftsklassen**: [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`ADR-0004`](../../../../docs/plan/adr/0004-durchsetzungs-emission.md)
füllen es aus dem **Picker** (Kurs-Template-Satz), `baseline-verify.sh` ist **Generator**
(Tool-als-Quelle, [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md)). Weder ADR noch [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) noch dieser Plan sagen,
**ob das Verzeichnis klassenrein sein soll**. Die Pfadwahl selbst ist korrekt (Lastenheft
rank-1 vor lokaler Adaption) — offen ist die Regel dahinter. Gehört beim Durchsetzungsschicht-Emit
([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)) entschieden, spätestens dann treffen beide Klassen real aufeinander.

### Bewusst nicht getan (I4)

Das Zielrepo erhält den Verifier, aber **kein** `make baseline-verify`. Es gibt heute kein
emittiertes Root-`Makefile` (das kommt mit dem Generator, slice-023) — ein Target zu
behaupten wäre ein halluziniertes Gate (Hard Rule 3.1). [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)s „netzlos
verifizierbar" ist als **Fähigkeit** abgenommen (Skript läuft standalone, Zähne nachgewiesen),
nicht als verdrahtetes Gate. Verdrahtung: slice-004b.

### Folge-Slices

- [slice-022b](slice-022b-embed-raus.md) — entsperrt: das Embed kann jetzt gegen die gefetchte Quelle getauscht werden.
- [slice-025](slice-025-bootstrap-preflight.md) — neu aus diesem Slice: die Teil-Bootstrap-Kette (I1, vierte Wiederholung) plus L3/L4 aus demselben Codepfad.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
