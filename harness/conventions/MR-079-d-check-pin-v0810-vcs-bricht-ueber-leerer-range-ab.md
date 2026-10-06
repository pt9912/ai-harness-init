# MR-079 — d-check-Pin v0.81.0 (`vcs` bricht über leerer Range ab)

- **Datum:** 2026-10-06
- **Wirksamkeits-Anlass:** slice-d-check-pin-macht-den-range-leerfall-laut.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin); setzt
  [`MR-073`](../conventions.md#mr-073--d-check-pin-v0790-links-lookahead-und-referenz-definitionen-standardmäßig-aktiv)
  fort. Dazu die Aussagen über die leere Range am Modul `vcs` in `harness/tools/full-smoke.sh`,
  `harness/sensors/history-range-guard.md` und den Kommentaren von Wächter, `Makefile` und
  `.github/workflows/ci.yml`. **Nicht** die Modul-Liste der [`.d-check.yml`](../../.d-check.yml),
  **nicht** die emittierte Startkonfiguration
  ([`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)),
  **nicht** die Methode der Gegenmessung
  ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen))
  und **nicht** die Angabe eines history-lesenden Laufs
  ([`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie
  [`MR-073`](../conventions.md#mr-073--d-check-pin-v0790-links-lookahead-und-referenz-definitionen-standardmäßig-aktiv):
  ein Pin-Sprung tritt an keine Baseline-Stelle.
- **Adaption.** Der Pin springt **v0.79.0 → v0.81.0** (`v0.80.0` ohne eigenen Eintrag — zwei
  Releases, ein Gegenstand, derselbe Zuschnitt wie im Vorgänger), Digest
  `sha256:c6e613428d994acf416077024b0e47e8319af5738cbddab7c609fa2a005c92e5`
  (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.81.0`, Commit `dd26964c`). Der
  lebende Pin steht in `d-check.mk`
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen));
  `--print-mk` unterscheidet sich zwischen den Digests in einem Hunk (`DCHECK_IMAGE`), die
  Handgriffe aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)
  sind unverändert.
- **Strenge-Bilanz — keine Senkung.** Gegenmessung nach
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2, netzlos, an einer `git archive dd26964c`-Kopie (Angabe nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1: kein Objektspeicher); die Zahlen trägt die Commit-Message dieses Eintrags
  ([`MR-051`](../conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).

  | Stufe | `v0.79.0` | `v0.81.0` | `diff` |
  |---|---|---|---|
  | Dogfood unverändert | 2268 Dateien, 0 Befunde | gleich | leer |
  | Marker entwertet | 73 Befunde (36 `codepath-missing`, 37 `id-unlinked`) | gleich | leer |
  | zusätzlich Sonden (13 Grund-Codes, alle 9 Module mit Basis) | 84 Befunde | gleich | leer |
  | Ziel `--lang go` unverändert | 20 Dateien, 0 Befunde | gleich | leer |
  | Ziel mit Sonden (alle 6 Module mit Basis) | 22 Dateien, 9 Befunde | gleich | leer |

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2); tragend sind die 0 der ersten Stufen und die Gleichheit der Mengen.
- **Was sich bewegt — außerhalb der aktiven Module:**
  - **`vcs` bricht über leerer Range selbst ab.** `make doc-immutable RANGE=HEAD..HEAD`:
    `v0.79.0` Exit 0, `0 Befund(e)`; `v0.81.0` Exit 2, `Range-Leerfall … es wurde nichts geprüft`.
    Eine **Verschärfung**: aus blindem Grün wird ein lauter Abbruch.
  - **`vcs` im flachen Klon auch über nicht leerer Range.** Klon der Tiefe 2,
    `RANGE=HEAD~1..HEAD`: `v0.79.0` `0 Befund(e)`, Exit 0; `v0.81.0`
    `Range-Basis-Vorfahren nicht lesbar: object not found`, Exit 2. Ebenfalls laut statt blind.
    Der einzige history-lesende Job dieses Repos (`adr-immutable` in `.github/workflows/ci.yml`)
    checkt mit `fetch-depth: 0` aus und ist nicht betroffen.
  - **`commits`** bricht im flachen Klon ab (`Vorfahren nicht lesbar`, Exit 2, wie seit `v0.76.3`)
    und meldet im vollständigen Klon über leerer Range weiter `0 Befund(e)`, Exit 0.
  - **`hostpaths`** (opt-in, in keiner `modules:`-Liste) meldet unter `--enable hostpaths` 33 → 36;
    **`targets.makefiles`** nimmt Globs, im Dogfood nicht gesetzt. Beide ohne Gegenstand.
- **`make history-range-guard` bleibt — Retirement-Check mit Ergebnis.** Herkunft ist
  [`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 3: die auflösbare, aber leere Range lief blind grün. Für `vcs` ist dieser Grund
  entfallen, für `commits` im vollständigen Klon besteht er (gemessen, oben) — der Wächter behält
  seinen Gegenstand, im Dogfood an `doc-commits` und im Ziel an beiden vorgebundenen Targets. Vor
  `vcs` bleibt er als früherer Abbruch ohne Bild-Lauf stehen; den Vertrag in
  `harness/sensors/history-range-guard.md` hat der Implementer auf diese Lage gezogen. Ihn für
  `vcs` abzuhängen spart einen `git rev-list`-Aufruf und kostet eine zweite Kettenform —
  **akzeptiertes Negativ**, kein Folge-Slice.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5):** jede Bewegung ist eine Verschärfung
  oder ohne Gegenstand; die aktiven Module zeigen gleiche Befundmengen.
- **Grenze.**
  - Die Gegenmessung fährt den VCS-Port nicht (`git archive`-Kopie); die `vcs`-Aussagen oben sind
    Einzelläufe am Klon, nicht Teil der Sonden-Bilanz.
  - Der Digest ist über die Werkzeug-Ausgabe belegt; kein Sensor hält ihn gegen den Tag.
  - Datierte Momentaufnahme
    ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)):
    jede Werkzeug-Aussage nennt `v0.79.0` oder `v0.81.0` als Mess-Operand.
- **Begründung.** Der Digest ist die Reproduzierbarkeits-Zusage
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); der Sprung macht einen
  blinden Grün-Fall am Modul `vcs` laut
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Er löst
  namentlich die Aussage *„kein Modul deckt die leere Range“* ab, deren Neu-Prüfung
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  selbst an dieses Ereignis bindet; darum tragen
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst),
  [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)
  und
  [`MR-073`](../conventions.md#mr-073--d-check-pin-v0790-links-lookahead-und-referenz-definitionen-standardmäßig-aktiv)
  eine Kopf-Marke nach
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1 — anders als die bloße Datierung eines Sprungs (Setzung 4 dort).
- **Auflösungs-Trigger:** permanent, wie
  [`MR-073`](../conventions.md#mr-073--d-check-pin-v0790-links-lookahead-und-referenz-definitionen-standardmäßig-aktiv).
  **Neu zu prüfen** ist der Verbleib von `make history-range-guard`, sobald `commits` über leerer
  Range ebenfalls abbricht (dann ist der Retirement-Check oben erneut fällig), und die Aussage über
  `hostpaths`/`targets.makefiles`, sobald eines davon einen Gegenstand bekommt.
