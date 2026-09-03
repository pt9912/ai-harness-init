# MR-007 — Baseline committet vendored statt gefetchter Cache

- **Datum:** 2026-07-17
- **Geltungsbereich:** `.harness/baseline/`, `Makefile`, [`harness/tools/`](../../harness/tools/), `.gitignore`, `.d-check.yml`, `AGENTS.md`, `CLAUDE.md`, [`harness/README.md`](../README.md), [`test/`](../../test/); löst den Cache-Teil von [`MR-004`](../conventions.md#mr-004--sessionstart-regelwerk-injektor)/[`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) ab.
- **Ersetzt-Baseline-Regel:**
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
  §Freshness-Audit der vendored Baseline — die Koexistenz-Setzung: *„Weil der Vendoring-Pfad
  `<tag>`-gescopt ist, liegen alte und neue Form nebeneinander: `diff -r
  .harness/baseline/<alt>/templates .harness/baseline/<neu>/templates` zeigt umbenannte Sektionen
  und neue Felder direkt. Das alte Verzeichnis fällt erst, wenn der Review durch ist."* An ihre
  Stelle tritt Setzung 4 unten: **ein Tag zur Zeit**, Historie in `git`, und mehr als ein
  `<tag>`-Verzeichnis ist ein Fehler, den `baseline-verify` und der Injektor erzwingen. Die alte
  Form bleibt damit erreichbar, aber als Tree-Operand statt als zweites Verzeichnis.
  **Das Vendoren selbst ersetzt nichts** und steht deshalb nicht im Feld: Regelwerk *und* Templates
  committet unter `.harness/baseline/<tag>/{regelwerk,templates}/` plus `SHA256SUMS`, netzlos, ist
  Schritt 2 derselben Sequenz. Die Setzungen 1–3 füllen, was die Baseline zu Format, Umfang und
  Vollständigkeitsprüfung von `SHA256SUMS` offen lässt — eine Lücke, keine Abweichung. Gemessen am
  adoptierten Stand `v5.12.0`.
- **Adaption:** Regelwerk **und** Templates liegen **committet vendored** unter
  `.harness/baseline/<tag>/{regelwerk,templates}/` + `SHA256SUMS` (42 Dateien:
  21 + 21), netzlos auf jedem Checkout präsent — Baseline-Vorgabe aus Modul 2
  („nicht pro Lauf extern gefetcht"). `make regelwerk-fetch` entfällt; an seine
  Stelle tritt das **netzlose** `make baseline-verify` (in `gates` — anders als
  ein Netz-Fetch verletzt es offline-grün nicht,
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Die
  Geschwister-Lage ist funktional: die `../templates/…`-Ziel-Form-Verweise des
  Regelwerks lösen dadurch lokal auf (12 eindeutige Ziele, 0 tot — gemessen).
- **Setzung 1 — Provenienz ≠ Integrität (beide nötig).** `SHA256SUMS` ist
  **selbst erzeugt**: es beweist, dass der Baum sich seit dem Vendoring nicht
  bewegt hat, **nicht**, dass er vom offiziellen Release stammt. Die
  Upstream-Kette hängt allein an `BASELINE_ZIP_SHA256` (`Makefile`) — dem sha256
  des Release-Assets, gegen das **vor** dem Entpacken verifiziert wird. Beide
  Anker sind zu führen; wer nur `SHA256SUMS` hat, hat Integrität ohne Herkunft.
- **Setzung 2 — `SHA256SUMS`-Umfang.** Die Baseline schreibt nur *dass* die Datei
  existiert; Format, Umfang und Erzeugung sind unspezifiziert, und das ZIP liefert
  **keine** mit. Setzung: `sha256sum` über **alle** Dateien beider Bäume, Pfade
  relativ zu `<tag>/`, `LC_ALL=C`-sortiert, die Datei **selbst ausgenommen** (sie
  kann sich nicht selbst hashen — ihre Integrität trägt git).
- **Setzung 3 — Vollständigkeits-Check ist Pflicht, nicht Kür.** `sha256sum -c`
  prüft **nur, was gelistet ist**, und bleibt bei einer **zusätzlich eingelegten**
  Datei grün. `baseline-verify` vergleicht deshalb zusätzlich den Dateibestand
  gegen die Liste. Real vorgeführt (slice-011): geänderte Datei → rot; eingelegte
  Datei → `sha256sum -c` **grün**, `baseline-verify` **rot**. Ohne diesen Schritt
  wäre „prüft die Integrität der Arbeitskopie" überdehnt — ein stilles Grün.
- **Setzung 4 — `<tag>`-Politik.** Das Regelwerk sagt zu alten
  `<tag>`-Verzeichnissen nichts (Koexistenz vs. Ersetzen). Setzung: **ein Tag zur
  Zeit** (Ersetzen), Historie liegt in git. Der Tag-String hat **genau eine**
  Quelle: `BASELINE_TAG` (`Makefile`). `baseline-verify` und der SessionStart-Injektor
  **entdecken** das Verzeichnis (Glob) statt es zu kennen, `.d-check.yml` nutzt
  `.harness/baseline/**` — so ist ein Tag-Bump eine Zeile + der Baum, kein
  repo-weiter Grep ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
  Beide Werkzeuge **erzwingen** die Setzung: mehr als ein `<tag>`-Verzeichnis ist
  ein Fehler (Verify rot, Injektor warnt und injiziert **nichts** — er sucht sich
  nicht still einen aus).
- **Begründung:** Netzlose Präsenz auf jedem Checkout und Wegfall der
  Host-`unzip`-Abhängigkeit zahlen auf
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  ein; der Preis ist ein ~241 KB großer committeter Fremd-Blob, den `AGENTS.md` §1
  bisher ausdrücklich verbot (bewusst umgestellt). Der Baum ist **derivativ** und
  trägt kurs-eigene MR-/ADR-Kennungen (Beispiele, nicht die des Repos) → vom
  Doc-Gate ausgenommen (`scan.ignore`), sonst träfe ihn die `ids`-Link-Pflicht.
- **Auflösungs-Trigger:** permanent. **Upstream-Überwachung — und ihre Grenze:**
  `make regelwerk-check` (Maintenance/Netz, **nicht** in `gates`) vergleicht das
  Upstream-Asset **des gepinnten Tags** gegen `BASELINE_ZIP_SHA256`. Es erkennt
  damit ein **nachträglich verändertes Release-Asset** — **nicht** einen **neuen
  Tag**. Ein Upstream-Release bleibt unsichtbar, bis jemand die Release-Liste
  prüft; genau so entging dem Repo v3.0.0/v3.1.0, während sein Sensor auf v1.2.0
  „kein Drift" meldete. Diese Lücke schließt **`make baseline-freshness`** (slice-018):
  ein read-only Sensor auf die Release-*Liste* — er folgt dem `releases/latest`-Redirect
  und vergleicht den effektiven Tag gegen `BASELINE_TAG` (die **Tag-Achse** neben
  `regelwerk-check`s Asset-Achse). Maintenance/Netz, **nicht** in `gates` (offline-grün
  bleibt); der Sensor mutiert nichts (Re-Baseline bleibt die bewusste Operation oben).
  `baseline-verify` deckt weiterhin **keine** der beiden Upstream-Achsen ab — es prüft nur
  die eigene Arbeitskopie, nie den Upstream. **Generalisiert (slice-040):** die
  `releases/latest`-Tag-Mechanik von `baseline-freshness` lebt seit slice-040 als
  parametrierter Sensor `harness/tools/component-freshness.sh` (`name · pinned ·
  releases-latest-url`); `baseline-freshness` ist ein dünner Wrapper darum, und
  **`make freshness-golangci`** (Pin: `GOLANGCI_LINT_VERSION`) sowie
  **`make freshness-dcheck`** (Pin: `DCHECK_IMAGE`-Tag aus [`d-check.mk`](../../d-check.mk))
  tragen dieselbe Read-only-/Nachtlauf-Disziplin auf zwei weitere Komponenten-Achsen —
  Maintenance/Netz, **nicht** in `gates` ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
  bash+curl ohne jq/node ([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). **Sonderquelle Go
  (slice-041):** die Go-Toolchain hat kein GitHub-`releases/latest` (`golang/go` redirected auf
  `.../releases`), darum ein eigener Wrapper `harness/tools/go-freshness.sh` — Fetch von
  `go.dev/VERSION?m=text` + Normalisierung (`go1.x.y` → `1.x.y`), dann derselbe wiederverwendete
  Vergleicher; **`make freshness-go`** (Pin: `GO_VERSION`) hängt ebenfalls im Nachtlauf.
  **Sonderquelle C++/ubuntu (slice-042):** der ubuntu-Base-Tag des emittierten C++-Skeletts
  (`DefaultCppVersion` in `internal/gen/cpp.go`) wird gegen das **Docker-Hub-LTS** geprüft — Wrapper
  `harness/tools/cpp-freshness.sh` holt die ubuntu-Tags (`hub.docker.com/v2/…/ubuntu/tags`) und
  extrahiert das aktuelle LTS (höchstes `NN.04` mit **geradem** `NN`; Interims `23.04`/`25.04`/`.10`
  raus), dann derselbe Vergleicher; **`make freshness-cpp`** hängt im Nachtlauf.
- **Reichweite des Drift-Jobs — ehrlich, nicht rund.** Er deckt die **Baseline**, **d-check**,
  **golangci-lint**, die **Go-Toolchain** und den **ubuntu-Base-Tag** ab. **Nicht** abgedeckt sind
  die drei übrigen digest-gepinnten Werkzeug-Images: **bats**, **shellcheck** und **actionlint** —
  sie altern unbeobachtet. Hier stand bis 2026-07-25 „damit deckt der Drift-Job jede versions-gepinnte
  Komponente ab"; das war eine Zusage über der halben Menge, aufgefallen erst, als ein Nutzer den
  veralteten bats-Pin von Hand fand (real **1.11.0**, während bats-core bereits weiter ist).
  Der Grund für die Lücke ist mechanisch: diese drei sind **nur per Digest** gepinnt, tragen also
  keinen Versions-String, den ein Vergleich lesen könnte. Der saubere Weg ist, die Version **aus dem
  gepinnten Image selbst** zu lesen (`bats --version`, `shellcheck --version`, `actionlint -version`)
  und gegen `releases/latest` zu vergleichen — dann gibt es keine zweite Quelle, die driften kann.
  Bis das gebaut ist, gilt die Lücke als **benannt**, nicht als geschlossen.
- **Migration:** Ein bestehender `.harness/cache/`-Cache aus
  [`MR-006`](../conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) ist nach dem
  Umstieg ein nicht mehr regenerierbares Überbleibsel (`regelwerk-fetch` existiert
  nicht mehr) und **lokal zu löschen**. Frische Checkouts sind nicht betroffen —
  der Cache war gitignored und daher nie im Repo.
