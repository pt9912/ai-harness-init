# `make vendor-baseline` — legt den eigenen vendored Baum aus dem Release-Asset an

## Vertrag

`make vendor-baseline` legt den vendored Baum **dieses** Repos
(`.harness/baseline/$(BASELINE_TAG)/`) aus dem verifizierten Release-Asset an, statt ihn von Hand
aus einem fremden Arbeitsbaum zu kopieren — wie `slice-mv` und `archive-welle` **kein Gate und in
keiner Prerequisite-Kette**: es stellt her, es prüft nicht
([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); der Beleg
ist `make baseline-verify` nach demselben Lauf. Die Fähigkeit liegt vollständig in
`internal/fetch.Baseline` ([`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren))
und hat außerhalb der Tests zwei Aufrufer: den Init-Pfad für Zielrepos und dieses Ziel, für den
eigenen Baum. Tag und sha256 kommen als Argumente aus den kanonischen Makefile-Variablen
`BASELINE_TAG`/`BASELINE_ZIP_SHA256` — kein zweiter, eingebetteter Wert.

**KONVERGENT** ([`ADR-0007`](../../docs/plan/adr/0007-bootstrap-phasen.md)): ein vorhandenes
`<tag>`-Verzeichnis, das genau dem übergebenen Tag entspricht, wird ersetzt, kein zweites legt
sich daneben ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 4). Real gemessen gegen den heute gepinnten Tag: der Lauf reproduziert den committeten
Baum byte-gleich (`git status --porcelain -- .harness/baseline/` bleibt leer), und
`make baseline-verify` meldet danach `OK`.

## Grenze — was das Grün nicht abdeckt

- **Ein Tag-Wechsel wird nicht nachgezogen.** Liegt statt des übergebenen Tags ein **anderer** da
  (ein Tag-Bump), bricht der Lauf **vor** jedem Zugriff ab, statt das zweite Verzeichnis zu
  erzeugen — dieses Ziel vendort nur den übergebenen Tag neu.
- **Provenienz nur zur Hälfte.** Pin → Asset hält `make regelwerk-check` (Netz, nicht in
  `make gates`). Asset → vendored Baum hält nichts eigenes: `SHA256SUMS` ist selbst erzeugt und
  trägt allein die lokale Integrität, nicht die Herkunft. Diese Hälfte hängt am Vendoring-Vorgang
  selbst, nicht an einem Sensor.

## Sperren

- Der übergebene sha256 weicht vom aus dem Asset berechneten ab → der Lauf bricht **vor** jedem
  Schreibzugriff ab (`internal/fetch.SHA256Mismatch`), ein bestehender Baum bleibt unverändert.
- Ein anderer Tag liegt bereits vor (s. Grenze) → Abbruch vor jedem Zugriff, kein zweites
  Verzeichnis.

## Bindung

[`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache); kein
Gate-Versprechen; Beleg ist `make baseline-verify` nach demselben Lauf.
