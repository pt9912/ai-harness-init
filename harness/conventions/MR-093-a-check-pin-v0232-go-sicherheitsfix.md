# MR-093 — a-check-Pin v0.23.2 (Go-Sicherheitsfix, Prüfverhalten unverändert)

- **Datum:** 2026-10-10
- **Wirksamkeits-Anlass:** slice-a-check-pin-bringt-den-go-sicherheitsfix;
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Geltungsbereich:** `internal/emit/archgate.go` (`DefaultArchImage`/`DefaultArchDigest`,
  Kopfkommentar); der a-check-Pin ist allein emittiert und tritt an keine Stelle des Dogfood.
  Setzt [`MR-084`](../conventions.md#mr-084--d-check-pin-v0840-multi-arch-index-prüfverhalten-unverändert)
  fort, der den Sprung `v0.23.0` ohne eigenen Eintrag trug. **Nicht** die Methode der Gegenmessung
  ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie `MR-084`: ein Pin-Sprung tritt an keine Baseline-Stelle.
- **Adaption.** Der Pin springt **v0.23.0 → v0.23.2**, Digest des **Index**
  `sha256:2368f7b3a84f1dc5d075edccfe2201e19947d12fcbc8eaf4df84ef162d94f422`
  (`docker buildx imagetools inspect ghcr.io/pt9912/a-check:v0.23.2`; Manifests `linux/amd64`
  `sha256:e824afcc…`, `linux/arm64` `sha256:aeaf033e…`; alt
  `sha256:97cb6d4eb52a0c9fb8f352baeea4f028691fdffbe534499141668dd9329c3f44`). Der lebende Pin steht
  in `internal/emit/archgate.go`
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).

  **Der Grund des Sprungs ist die Go-Fassung**, gemessen am Binär (`docker create` + `docker cp
  /a-check`, gelesen mit `version` des Werkzeugs im Bild `golang:1.27.2`, per Tag gewählt, nicht per
  Digest): `linux/amd64` und `linux/arm64` je `go1.27.2`; vorher `linux/amd64` `go1.27.0`. Welche
  Befunde die Fassung behebt, sagt das CHANGELOG des Werkzeugs, nicht dieser Eintrag.
- **Strenge-Bilanz — keine Senkung, keine Verschärfung.** Je Sprache ein Root-Ziel
  `ai-harness-init --lang <l> --arch hexslice`, gelesen mit
  `docker run --rm --network none -v <ziel>:/src:ro <a-check@digest> /src`, alter gegen neuer Digest:

  | `--lang` | grünes Skelett | verbotener Import Domain→Adapter |
  |---|---|---|
  | `go` | `gesamt: 0 Befund(e)`, Exit 0, Ausgabe byte-gleich | 1 Befund `core-impurity`, Exit 1, `greeting.go:8`, an beiden Digests |
  | `cpp` | wie `go` | 1 Befund `core-impurity`, Exit 1, `greeting.hpp:1`, an beiden Digests |
  | `kotlin` | wie `go` | 1 Befund `core-impurity`, Exit 1, `Greeting.kt:4`, an beiden Digests |

  Bei `2>&1` wechselt die Zeilenfolge der `cpp`-Ausgabe zwischen Läufen desselben Digests; je Kanal
  getrennt gelesen ist alt gleich neu (`md5`), sortiert `diff` leer. **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Das Protokoll steht in der Commit-Message von `57f1fa9a`.
- **Rot am echten Pin.** `DefaultArchDigest` auf `…d94f423` verfälscht → `make full-smoke` endet mit
  Exit 2 und `exit status 125 (… manifest unknown)`; zurückgenommen, danach Exit 0. Das Rot belegt,
  dass der Pin real gezogen wird, nicht dass er zum Tag passt (Grenze).
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5):** gleiche Befunde in allen drei Sprachen,
  beide Richtungen. Die Re-Evaluierungs-Trigger von
  [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) (Regeln oder Schema der
  `.a-check.yml` ändern sich: das emittierte Schema läuft am neuen Digest grün, die Regel
  `core-impurity` färbt gleich) und
  [`ADR-0088`](../../docs/plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (die
  Kotlin-Sonde färbt rot: `Greeting.kt:4`) sind nicht eingetreten.
- **Grenze.** Die Gegenmessung lief nur auf dem Host-Manifest (`amd64`); für `arm64` ist nur die
  Go-Fassung gemessen — akzeptiertes Negativ wie in `MR-084`, weil Host und Gate-Job `amd64` fahren.
  Kein Sensor hält Tag gegen Digest (`BEO-ALL/pin-digest-ohne-waechter`): ein Digest, der nicht zum
  Tag passt, geht durch. Das Messbild `golang:1.27.2` ist an keinen Digest gebunden. Datierte
  Momentaufnahme (`MR-053`).
- **Begründung.** Der Digest ist die Reproduzierbarkeits-Zusage
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); der Sprung tauscht die
  Go-Fassung des Werkzeugs, ohne sein Prüfverhalten zu bewegen.
- **Auflösungs-Trigger:** permanent, wie `MR-084`.
