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
> **[slice-022b](../open/slice-022b-embed-raus.md)** räumt es ab. Der Zwischenzustand „zwei
> Template-Quellen" ist damit kurz **und bewacht** — die ursprüngliche §6-Sorge trifft
> schwächer als beim Schneiden angenommen.

`internal/fetch` holt das **sha256-gepinnte Baseline-Bundle** (`lab-regelwerk.zip`) und legt
Regelwerk **und** Templates als vendored Baseline ins Zielrepo — samt `SHA256SUMS` und einem
**tool-generierten `baseline-verify`**, mit dem das Ziel seine Baseline netzlos prüfen kann
([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)). Das Zielrepo erhält damit erstmals ein Regelwerk. Der
Embed-Pfad bleibt in diesem Slice **unangetastet**.

## 2. Definition of Done

- [ ] [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) Happy Path: der Bootstrap legt Regelwerk **und** Templates als `.harness/baseline/<version>/{regelwerk,templates}/` + `SHA256SUMS` im Zielrepo ab (spiegelt [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) fürs Ziel), Test referenziert.
- [ ] [`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) Prüfsummen-AC: das Tool **generiert** einen `baseline-verify` (Tool-als-Quelle, wie `d-check --print-mk`), der **Integrität und Vollständigkeit** prüft — nicht nur `sha256sum -c`. [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 3 belegt, dass `-c` allein bei einer **eingelegten** Datei grün bleibt; diese Lücke wird **nicht** ins Ziel vererbt.
- [ ] `SHA256SUMS`-Form nach [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2: über **alle** Dateien beider Bäume, Pfade relativ zu `<tag>/`, `LC_ALL=C`-sortiert, die Datei selbst ausgenommen.
- [ ] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): das Asset ist **sha256-gepinnt** und wird **vor** dem Entpacken verifiziert ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1 — Provenienz ≠ Integrität); zwei Läufe mit gleicher Version → identische Ablage.
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) Kein-Halluzinat-AC: fehlt das Kurs-Asset zur Version oder bricht der sha256, wird **begründet nicht emittiert** (kein erfundenes Regelwerk, keine Teil-Baseline). `make gates` bleibt **offline-grün** — der Netz-Fetch ist Bootstrap-Pfad, kein Gate.
- [ ] **Abgrenzung zu [slice-022b](../open/slice-022b-embed-raus.md) belegt:** `internal/emit/skel` ist unverändert und `test/skel-drift.bats` weiter grün — dieser Slice fügt hinzu, er räumt nicht ab.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/fetch` | update | ZIP-Pfad (`archive/zip` braucht `io.ReaderAt` → Bytes puffern, kein Streaming) **neben** dem bestehenden Tarball-Pfad; sha256-Verify **vor** dem Entpacken |
| `internal/fetch` | neu | `SHA256SUMS`-Erzeugung nach [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2 |
| `internal/emit` | neu | `baseline-verify` generieren (Tool-als-Quelle; Integrität **+** Vollständigkeit) |
| `cmd/ai-harness-init` | update | Baseline-Fetch in den Init-Flow; `fetch.Skeleton` bleibt vorerst (trägt die `--lang`-Validierung, s. §6) |
| Fetch-Tests | neu/update | ZIP-Fixture, sha256-Mismatch → kein Teil-Emit, `SHA256SUMS`-Form, Determinismus |

## 4. Trigger

[`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) accepted (**erfüllt 2026-07-19**) und welle-02 aktiv. Dieser Slice ist der
**erste** der umgeplanten welle-02.

Rückführungen: `in-progress → next`, wenn schon der Fetch-Umbau allein (ZIP + sha256 +
`SHA256SUMS` + generierter Verifier) den Ein-Sitzungs-Review sprengt — dann den Verifier
als eigenen Slice führen. `in-progress → open`, wenn das Kurs-Asset die Templates nicht in
der von [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) verlangten Zweiklassigkeit trägt (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Entsperrt
[slice-022b](../open/slice-022b-embed-raus.md).

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
- **Zwei Template-Quellen bis [slice-022b](../open/slice-022b-embed-raus.md)** — bewusst, kurz und von
  `test/skel-drift.bats` bewacht (Embed == vendored bleibt geprüft, bis das Embed fällt).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
