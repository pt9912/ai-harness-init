# MR-012 — d-check-Pin v0.51.1 (sources verfügbar)

- **Datum:** 2026-07-19
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`), `internal/emit/emit.go`
  (emittierter Default-Pin), §Baseline-Version; setzt [`MR-011`](../conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines) fort.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: er stellt eine Vorbedingung her, die die Baseline selbst nennt.
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
  §Freshness-Audit der vendored Baseline führt das Modul am adoptierten Stand `v5.12.0`
  namentlich — *„d-check `sources` automatisiert die Asset-Prüfung … deckt die Integritäts-Hälfte
  ab, ersetzt die Release-Listen-Prüfung nicht"* —, und dass es hier **nicht** in `modules:` steht,
  folgt aus derselben Stelle: der Audit ist eine *„Netz-Operation, außerhalb der Gates"*. Verfügbar
  machen ohne aktivieren tritt an keine Regel; es hält [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  ein, bis der Prüfbereich existiert.
- **Adaption:** Das gepinnte d-check-Image springt **v0.50.0 → v0.51.1** (Digest
  `sha256:fede3d02…`, **dreifach belegt**: lokaler RepoDigest · `imagetools` · d-check-`version.md`/
  Handbuch, [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). **Zweck:** das opt-in-Modul `sources`
  (19., Netz, seit v0.51.0) **verfügbar** machen — Vorbedingung für die geplante `sources`-Adoption
  (slice-020: ersetzt den Eigenbau `regelwerk-check` durch das tool-gelieferte Content-Pin-Modul).
  **`sources` ist hier NICHT aktiviert** (leer aktiviert wäre ein Phantom-Gate,
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Trockenlauf vor dem Pin (Pflicht, belegt — [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** v0.51.1 gegen die
  unveränderte Config, netzlos: **0-Befund-Differenz** zum v0.50.0-Stand (`sources` opt-in/Netz/nie
  Default → inert; Handbuch v0.51.1: „ohne aktives `sources` byte-identisch" — hier gemessen bestätigt).
  Einzige inhaltliche `--print-mk`-Fragment-Differenz zu v0.50.0: `--disable sources` in den fünf
  fokussierten advisory-Recipes (verbatim vom Tool, wie damals `--disable citations`).
- **Emitter-Pin gekoppelt (Tier-1-Drift).** `internal/emit`s `DefaultImage`/`DefaultDigest` zieht per
  go-test mit (`TestDefault…_MatchesCanonical` liest `d-check.mk`); die emittierte Starter-Config bleibt
  `modules: [links, anchors]` (Emitter ≠ Dogfood).
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen + Digest neu
  pinnen ([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger).
