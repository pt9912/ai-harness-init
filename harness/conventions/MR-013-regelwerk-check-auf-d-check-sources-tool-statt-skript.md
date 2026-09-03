# MR-013 — regelwerk-check auf d-check `sources` (Tool statt Skript)

- **Datum:** 2026-07-19
- **Geltungsbereich:** `Makefile` (`regelwerk-check`-Recipe), `.d-check.yml` (`sources:`-Block),
  `test/sources-pin.bats` (Kopplung); nutzt das mit [`MR-012`](../conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) verfügbar gemachte Modul.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: er vollzieht
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
  §Freshness-Audit der vendored Baseline Punkt für Punkt — Netz-Operation außerhalb der Gates,
  Asset-Prüfung durch `sources`, und die dort gezogene Grenze (*„ersetzt die
  Release-Listen-Prüfung nicht"*) trägt in diesem Repo `make baseline-freshness`
  ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)). Zwei-Pin-Kopplung und
  Unpack-Setzung füllen, was die Baseline zur **Ablage** des Hashes offen lässt: sie verlangt den
  Pin, benennt aber keine Datei, in der er kanonisch steht, und keine Prüfung gegen eine zweite
  Fassung. Eine Lücke, keine Abweichung. Gemessen am adoptierten Stand `v5.12.0`.
- **Adaption:** Das Maintenance-Target `make regelwerk-check` (Asset-Content-Drift der vendored
  Baseline gegen den Upstream) wird vom Eigenbau (`curl` + `sha256sum`) auf das d-check-Modul
  `sources` (opt-in, Netz, seit v0.51.0) umgestellt — „Tools verteilen statt Skripte pflegen". Der
  `.d-check.yml`-`sources:`-Eintrag pinnt das Release-Asset (`unpack: none` = Roh-Byte-Hash);
  `source-drift` meldet Abweichung mit vollem Ist-Hash, `source-unreachable` den Netzfehler. **Der
  Target-Name `regelwerk-check` bleibt** (Kontinuität, keine Referenz-Churn; frozen MR-Historie
  beschreibt weiter den Bash-Stand ihrer Zeit).
- **Zwei-Pin-Kopplung (Setzung).** Der Baseline-Asset-Hash lebt **kanonisch** im `Makefile`
  (`BASELINE_ZIP_SHA256`, [`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1 — die Re-Baseline nutzt ihn) und **dupliziert** im
  `.d-check.yml`-`sources:`-Block (d-check liest nur seine Config). Gegen stille Divergenz koppelt
  **`test/sources-pin.bats`** beide **fail-closed in `make gates`** (netzlos): `sources`-`sha256` ==
  `BASELINE_ZIP_SHA256`, `sources`-`url` trägt `BASELINE_TAG`. Eine Re-Baseline muss beide Pins
  bewegen — der Test erzwingt es.
- **`sources` NICHT in `modules:`** ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): es ist ein Netz-Modul und bräche den netzlosen
  `docs-check`/`make gates`. Aktiviert **nur** via `make regelwerk-check` (`--enable sources`, auf
  `sources` isoliert). `make gates` bleibt offline-grün; die Netz-Prüfung ist Maintenance/CI (wie
  `baseline-freshness`).
- **Unpack-Setzung (gemessen).** `unpack: none` (Roh-Bytes) — nicht `unpack: zip` (reihenfolge-
  invariantes Content-Manifest): der bestehende `BASELINE_ZIP_SHA256` ist ein Roh-Byte-Hash, und die
  Vendoring-Prüfung ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) verifiziert dieselben Roh-Bytes vor dem Entpacken. Gemessen:
  `unpack: none` → 0 Drift; `unpack: zip` mit demselben Hash → `source-drift` (anderer Hash-Raum).
- **Auflösungs-Trigger:** permanent; bei Re-Baseline beide Pins nachziehen (der Kopplungstest
  erzwingt es); bei d-check-Release neu gepinnt ([`MR-012`](../conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar)).
