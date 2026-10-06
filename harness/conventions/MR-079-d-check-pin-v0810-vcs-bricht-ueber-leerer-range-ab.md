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
  Setzung 2, netzlos, je Digest eine Kopie (Angabe nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1: kein Objektspeicher). `OLD`/`NEW` sind die Digests von `v0.79.0`/`v0.81.0`.

  **Prüf-Bedingung vor dem Lauf**
  ([`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1):
  - Die Symlinks bleiben stehen: `find .claude/rules -type l | wc -l` in der Kopie ist gleich
    `git ls-tree dd26964c .claude/rules/ | grep -c '^120000'`, `find .claude/rules -type f` ist leer.
  - Die alte Kopie trägt `d-check.mk` aus `dd26964c~1`.
  - In Stufe 3 hat jedes aktive Modul mindestens einen Befund. Die Dogfood-Module nennt
    `grep -m1 '^modules:' .d-check.yml` (neun), die Ziel-Module dieselbe Zeile im Ziel (sechs).

  **Kommandos.** Gemessen wurde so; die Sonden folgen dem Stand des Baums und werden je Sprung neu
  geschnitten.
  - Kopie: `git archive dd26964c | tar -x -C "$K"`. Für die alte Kopie zusätzlich
    `git show dd26964c~1:d-check.mk > "$K/d-check.mk"`.
  - Lauf je Stufe: `make -C "$K" docs-check DCHECK_DIGEST=<OLD|NEW>`. Die Befundzeilen liefert
    `awk -F'\t' 'NF>=3' | sort`. Dann folgen `diff` alt gegen neu und die Verteilung
    `cut -f3 | sort | uniq -c`.
  - Stufe 2: `sed -i 's/d-check:ignore/d-check:IGNORIERT-NICHT/g'` über jede `*.md` außer
    `.harness/baseline/`.
  - Stufe 3, Dogfood, je Modul eine Sonde:
    - `links`: eine neue Datei sonde-l3.md unter `docs/` mit totem Ziel und `../../`-Escape.
    - `anchors`: dieselbe Datei mit erfundenem Anker auf `AGENTS.md`.
    - `matrix`: `spec/architecture.md` verlinkt [`ADR-0003`](../../docs/plan/adr/0003-go-native-binaries.md), `done/slice-001a-cli-skeleton.md`
      verlinkt die erste ADR, die ersetzt ist (`superseded`).
    - `spans`: eine neue Datei sonde-spans.md unter `docs/` mit offenem Code-Span, verschachteltem Link und offener Fence.
    - `planning`: *Nichts in Arbeit.* unter *Offene Wellen*.
    - `targets`: die Zeile `make sonde-fantom-ziel-l3` in `harness/README.md`.
    - `structure`: `## 2. Definition of Done` aus `done/slice-001b-go-gates.md` gestrichen.
    - `codepaths` und `ids` haben ihre Basis in Stufe 2.
  - Ziel: `.harness/state/bin/ai-harness-init --lang go` aus `make host-bin` in ein frisches
    Verzeichnis. Die alte Kopie bekommt Tag und Digest von `v0.79.0` per `sed` in ihr
    `d-check.mk`. Sonden:
    - `links`, `anchors` und `spans` wie oben; die Link-Sonde trägt zusätzlich die Kennung der ersten ADR ohne
      Link (`ids`).
    - `matrix`: `spec/architecture.md` verlinkt `harness/README.md`.
    - `structure`: eine Zelle in `harness/README.md` ist um 230 Zeichen verlängert.

  | Stufe | `v0.79.0` | `v0.81.0` | `diff` |
  |---|---|---|---|
  | Dogfood unverändert | 2268 Dateien, 0 Befunde | gleich | leer |
  | Marker entwertet | 73 Befunde (36 `codepath-missing`, 37 `id-unlinked`) | gleich | leer |
  | zusätzlich Sonden | 84 Befunde | gleich | leer |
  | Ziel `--lang go` unverändert, auch mit entwerteten Markern | 20 Dateien, 0 Befunde | gleich | leer |
  | Ziel mit Sonden | 22 Dateien, 9 Befunde | gleich | leer |

  Verteilung der Dogfood-Stufe 3, unter beiden Digests gleich:
  - je 1: `anchor-missing`, `fence-unclosed`, `gate-phantom`, `matrix-forbidden`,
    `matrix-inactive`, `planning-drift`, `repo-escape`, `section-missing`, `span-nested-link`,
    `span-unclosed`, `target-missing`;
  - 36 `codepath-missing`, 37 `id-unlinked`.

  Das sind 13 Grund-Codes; jedes der neun Module hat eine Basis. Im Ziel trägt jeder der neun
  Grund-Codes einen Befund: `anchor-missing`, `fence-unclosed`, `id-unlinked`, `matrix-forbidden`,
  `repo-escape`, `section-cell-oversized`, `span-nested-link`, `span-unclosed`, `target-missing`.
  Damit haben alle sechs Module eine Basis.

  **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Tragend sind die 0 der unveränderten Stufen und die Gleichheit der Mengen.
  **Versioniert werden die Sonden-Skripte nicht.** Ihre Sonden hängen an Dateien und Abschnitten
  des jeweiligen Stands, und `MR-063` bindet die Bedingung, nicht ein festes Set. Ein Skript im
  Baum wäre ein Werkzeug ohne Gate, das mit dem Baum driftet. Das ist ein **akzeptiertes Negativ**:
  der nächste Sprung baut die Sonden aus der Bedingung und den Kommandos oben neu.
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
  - **`hostpaths`** ist opt-in und steht in keiner `modules:`-Liste. Am Arbeitsbaum meldet
    `docker run --rm --network none -v "$PWD:/repo:ro" ghcr.io/pt9912/d-check@<OLD|NEW> --enable hostpaths`
    33 → 36 Befunde. Die drei neuen sind `~/…`-Formen in `docs/reviews/**`.
- **`make history-range-guard` — Retirement-Check, je Ebene.** Herkunft ist
  [`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 3: die auflösbare, aber leere Range lief blind grün. Der Wächter ist kein Gate
  ([`harness/README.md`](../README.md) §Werkzeuge, *kein Gate*). Ein Rückbau wäre darum keine Senkung
  nach [`AGENTS.md`](../../AGENTS.md) §3.5; zu prüfen ist allein, ob der Grund entfallen ist.
  - **Emittiertes Ziel — der Grund besteht, der Wächter bleibt.** Er ist dort an `doc-immutable`
    **und** `doc-commits` vorgebunden. `commits` meldet im vollständigen Klon über leerer Range
    `0 Befund(e)`, Exit 0. Gemessen ist das in `harness/sensors/history-range-guard.md`
    §Im gebootstrappten Ziel — Grenze; den Fall hält `make full-smoke`.
  - **Dogfood — der Grund ist entfallen, der Wächter bleibt mit zwei anderen Gründen.** Die einzige
    Bindung ist `adr-immutable: history-range-guard doc-immutable`
    (`grep -n '^adr-immutable:' Makefile`), also das Modul `vcs`, und `vcs` bricht selbst ab.
    `doc-commits` hat dort, wo der Grund besteht, weder Wächter noch Aufrufer
    (`grep -n '^doc-commits:' d-check.mk`, `grep -c doc-commits .github/workflows/*.yml` → 0).
    Zwei Gründe tragen den Verbleib:
    - **Der leere Index unter `STAGED=1`.** Nur der Wächter sagt, dass nichts geprüft wurde.
      Gemessen unter `v0.81.0` bei leerem Index: `make history-range-guard STAGED=1` meldet
      `--staged ohne gestagte Aenderung — nichts zu pruefen.`, Exit 0. `make doc-immutable STAGED=1`
      meldet `0 Befund(e)`, Exit 0.
    - **Der Abbruch vor dem Bild-Lauf.**

    Ein Rückbau gewönne einen `git rev-list`-Aufruf. Er kostete einen Slice über `Makefile`,
    `ci.yml`, die Sensor-Doku und den Mutations-Fall 325. Dass `doc-commits` im Dogfood
    unbewacht ist, bleibt ein **akzeptiertes Negativ**: das Ziel hat keinen Aufrufer, und kein Job
    fährt es.
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
  **Neu zu prüfen** ist der Verbleib von `make history-range-guard` in drei Fällen. Bricht
  `commits` über leerer Range ebenfalls ab, entfällt der Grund im Ziel. Meldet `vcs --staged`
  einen leeren Index selbst, entfällt der erste Dogfood-Grund. Bekommt `doc-commits` im Dogfood
  einen Aufrufer, wird der Wächter dort vorgebunden. Die Aussage über
  `hostpaths`/`targets.makefiles` ist neu zu prüfen, sobald eines davon einen Gegenstand bekommt.
