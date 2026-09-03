# MR-027 — d-check-Pin v0.65.0 (Ignore-Marker in zwei Achsen verengt)

- **Datum:** 2026-08-28
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), `Makefile` (das Tag-Beispiel im Kommentar
  über `DCHECK_TAG`), §Baseline; setzt
  [`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) fort.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  aus demselben Grund wie [`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar): der Sprung
  ist der bewusste Digest-Commit aus
  [`modul-14-docker-harness.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  und die Neu-Erzeugung des Fragments aus
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk`. Der Gegenstand — die Verengung des Zeilen-Markers in **Form** und
  **Lage** — gehört dem Werkzeug: `grep -rn 'd-check:ignore' .harness/baseline/v5.12.0/regelwerk/`
  nennt am adoptierten Stand `v5.12.0` zwei Zeilen, einen gesetzten Marker in Kommentar-Form und
  die Regel, dass solche Marker das Adoptieren eines Templates überleben müssen — keine sagt etwas
  über die Form oder die Lage, in der er wirkt. Dass der Sprung an keinem aktiven Modul senkt, ist
  die §3.5-Frage von [`AGENTS.md`](../../AGENTS.md), an der Quell-Differenz beantwortet; auch sie
  ersetzt keine Regel.
- **Adaption:** Das gepinnte d-check-Image springt **v0.62.0 → v0.65.0**. Digest
  `sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288`, **dreifach belegt**
  und jedes Bein hier gefahren: lokaler RepoDigest
  (`docker image inspect --format '{{index .RepoDigests 0}}' ghcr.io/pt9912/d-check:v0.65.0`),
  Registry (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.65.0`, Zeile `Digest:`)
  und der Release-Body als Fremdquelle
  (`gh release view v0.65.0 --repo pt9912/d-check --json body -q .body`, daraus die
  `sha256:`-Zeichenkette) — alle drei mit demselben Wert
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin steht
  in `d-check.mk` und, daran gekoppelt, in `internal/emit/emit.go`; hier steht, wogegen er
  belegt ist.
- **Zweck: der Zeilen-Marker `d-check:ignore` verengt sich, in zwei Achsen.** Ab v0.65.0
  unterdrückt er einen Befund nur noch, wenn er **(a)** in einem echten HTML-Kommentar steht
  (**Form**) **und (b)** nicht in Inline-Code eingeschlossen ist (**Lage**). An einer Sonde
  außerhalb des Repos gemessen statt dem CHANGELOG geglaubt — vier Marker-Lagen über einem toten
  Codepath und über einer unverlinkten Kennung, beide Digests, netzlos, Mount `:ro`; `codepaths`
  und `ids` antworten in allen vier Lagen gleich:

  | Lage des Markers | `v0.62.0` | `v0.65.0` |
  |---|---|---|
  | echter HTML-Kommentar, `<!-- d-check:ignore -->` | unterdrückt | unterdrückt |
  | blanke Prosa, Marker ohne Kommentar | unterdrückt | **meldet** |
  | Kommentar-Form in Inline-Code eingeschlossen | unterdrückt | **meldet** |
  | ohne Marker (Kontrolle) | meldet | meldet |

  Die Kontrollzeile färbt unter beiden Versionen — der Aufbau misst seinen Gegenstand und nicht
  seine eigene Untauglichkeit. Die Summen der Sonde: `3 Datei(en) geprüft, 2 Befund(e)` gegen
  `3 Datei(en) geprüft, 6 Befund(e)`, beide Exit 1, je Modul **zwei** zusätzliche Meldungen aus
  den zwei entwerteten Lagen; die Befundmenge von `v0.62.0` ist **echte Teilmenge** der von
  `v0.65.0`.
- **An der Quelle bestätigt, nicht nur am Verhalten.** Am lokalen d-check-Klon trägt
  `git show v0.65.0:internal/hexagon/core/rules/ids.go` beide Bedingungen in **einer** Funktion
  `markerLines` — `commentMarkerRe` für die Form, `stripInlineCodeByLine` für die Lage (Zeilen
  **161** und **182** derselben Ausgabe, `grep -n 'commentMarkerRe = \|stripped := stripInlineCodeByLine'`)
  —, und `codepaths.go` konsumiert dieselbe Funktion
  (`git show v0.65.0:internal/hexagon/core/rules/codepaths.go | grep -n 'markers := markerLines'`
  → **64**). Die zwei Module reagieren identisch, weil es **eine** Änderung an **einer**
  geteilten Stelle ist, nicht zwei zufällig gleichlautende.
- **Strenge-Bilanz an der Quell-Differenz, nicht an der CHANGELOG-Aufzählung
  ([`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)-Muster).** Aktiv sind sechs Module
  (`grep -m1 '^modules:' .d-check.yml` → `links, anchors, ids, matrix, codepaths, spans`). Über
  `v0.62.0..v0.65.0` bewegen sich am Klon genau **zwei** ihrer Regeldateien, und **beide
  verlieren Zeilen**: `git diff --numstat v0.62.0..v0.65.0 -- internal/hexagon/core/rules/ids.go`
  → **35/11**, dasselbe Kommando für `codepaths.go` → **28/6**. Für `links.go`, `anchors.go`,
  `matrix.go` und `spans.go` gibt es **keine** Zeile aus. Entfernte Zeilen an einem aktiven Modul
  sind der Grund, die Bilanz nicht am Trockenlauf zu ziehen.
- **Trockenlauf vor dem Pin (Pflicht, belegt —
  [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** Beide Digests netzlos
  (`--network none`) gegen eine Kopie des Baums außerhalb des Repos (`git archive b3d6dcc`),
  Mount `:ro`, unveränderte `.d-check.yml`: beide `d-check: 435 Datei(en) geprüft, 0 Befund(e)`,
  Exit 0, `diff` der zwei Ausgaben leer. **Die Dateizahl ist kein Erwartungswert** — sie wächst
  mit jedem Dokument
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2);
  tragend sind die **0** und die leere `diff`-Ausgabe.
- **Was dieser Lauf trägt — und was nicht.** Er trägt **eine** Richtung, und in ihr ist er
  diesmal die ganze Antwort: kein Marker, den v0.65.0 nicht mehr beachtet, unterdrückt über
  diesem Korpus einen Befund — das sagt die **0** unter v0.65.0 unmittelbar. Der Grund ist
  ausdrücklich **nicht**, dass das Repo keine solchen Marker führte: von den Marker-Zeilen in
  getracktem Markdown außerhalb der vendored Baseline stehen **84** von **268** **nicht** in
  Kommentar-Form — `git grep -h 'd-check:ignore' -- '*.md' ':!.harness/baseline/**' | wc -l`
  für die Gesamtzahl, derselbe Strom durch `grep -c '<!--[^>]*d-check:ignore'` → **184** für die
  Kommentar-Form. **Keine Erwartungswerte:** alle drei wachsen mit jedem Dokument, das den Marker
  erwähnt. Sie tragen nur nichts — es ist Prosa *über* den Marker. Die **Baseline gehört per
  Pathspec ausgenommen, nicht per Zeilen-Filter**: ein nachgeschaltetes
  `grep -v '.harness/baseline'` verwirft auch Treffer, die den Baseline-Pfad bloß im Text nennen,
  und liegt über diesem Bestand um **12** Zeilen zu niedrig (derselbe Strom durch
  `grep -c '\.harness/baseline'`). In der **Gegenrichtung** ist der Lauf über einer
  0-Befund-Basis **informationsleer**: eine weggefallene Befundklasse erzeugt dieselbe Ausgabe
  wie eine unveränderte.
- **Die Gegenrichtung, auf einer Nicht-Null-Basis gemessen.** Dieselbe Kopie, alle Marker in
  getracktem Markdown außerhalb der vendored Baseline entwertet
  (`find . -name '*.md' -not -path './.harness/baseline/*' -print0 | xargs -0 grep -l 'd-check:ignore'`
  → **142** Dateien, darin per `sed -i` die Zeichenkette ersetzt; Restzähler danach **0**), dann
  beide Digests: **beide** melden `435 Datei(en) geprüft, 37 Befund(e)`, Exit 1, `diff` der
  sortierten Ausgaben ist **leer**, und die Klassen decken sich je Version
  (`grep -v '^d-check:' <ausgabe> | awk -F'\t' '{print $NF}' | sort | uniq -c` → **15**
  `codepath-missing`, **22** `id-unlinked`). Auf einer Basis, auf der ein Wegfall sichtbar
  geworden wäre, fällt nichts weg. **Tragend sind die Gleichheit der zwei Mengen und die leere
  `diff`-Ausgabe**, nicht die Datei- oder Befundzahl — beide wandern mit dem Baum.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für
  **Senkungen**. Gemessen verengt der Sprung an zwei aktiven Modulen und senkt an keinem; die
  zwei Läufe oben sind die zwei Richtungen dieser Aussage, und keiner von beiden ist der
  Trockenlauf allein. „Anheben → Steering-Loop, kein ADR nötig" hält
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) fest.
- **Das Gate-Fragment ändert sich in genau einer Zeile.** `--print-mk` unter beiden Digests,
  netzlos: je **68** Zeilen (`wc -l`), und `diff` der zwei Ausgaben führt **genau eine** Zeile —
  `DCHECK_IMAGE ?= …:v0.62.0` → `…:v0.65.0`. Die Target-Aufzählung aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2 bleibt damit inhaltlich
  stehen (`grep -cE '^docs?-[a-z-]+:' <fragment>` → **12** über beide Ausgaben und über
  `d-check.mk`); abgeglichen ist sie trotzdem, weil ihr Auflösungs-Trigger den Abgleich verlangt
  und nicht sein Ergebnis. `diff <frische v0.65.0-Ausgabe> d-check.mk | grep -c '^[0-9]'` → **4**
  Hunks: genau die vier Handgriffe aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1.
- **Emitter-Pin gekoppelt (Tier-1-Drift).** `internal/emit`s `DefaultImage`/`DefaultDigest` zieht
  per go-Test mit (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` lesen
  `d-check.mk`); die emittierte Starter-Config bleibt `modules: [links, anchors]`
  ([`MR-017`](../conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) — dieser Sprung
  bewegt eine Versions-Referenz, keine Prüfbereichs-Entscheidung.
- **Der Sprung ist nicht nur Wartung, und der Grund steht hier, weil er sonst nirgends stünde.**
  d-checks `[0.65.0]` behebt **vierzehn** behebbare HIGH-CVEs im ausgelieferten Image (neun
  `golang.org/x/crypto`, vier `golang.org/x/net`, eine `go-git`) — gelesen am lokalen Klon mit
  `awk '/^## \[0\.65\.0\]/,/^## \[0\.64\.0\]/' CHANGELOG.md`, also **Fremdquelle**, nicht hier
  gemessen. Kein Gate dieses Repos scannt das gepinnte Fremd-Image, und
  `make freshness-dcheck` sagt „ein neuer Tag ist da", nicht „der gepinnte ist verwundbar".
- **Kein Wächter über einer Versions-Nennung in Prosa, und das gehört dazu.** Keines der sechs
  aktiven Module hält eine solche Nennung gegen den lebenden Pin
  (`grep -c 'versions\|pins' .d-check.yml` → **0**, Exit 1). Das gelieferte Modul mit genau
  diesem Vertrag ist `versions` (`DC-FA-VER-001`: *„jeder Versions-Pin muss die aktuelle Version
  seines Paares tragen, sonst Befund `version-stale`"* —
  `git show v0.65.0:internal/hexagon/core/rules/versions.go` am lokalen Klon); es liegt im
  gepinnten Image und ist **nicht** adoptiert. Solange kein Wächter zwei Fassungen
  zusammenhält, führt §Baseline die Version deshalb nicht als zweite Fassung, sondern zeigt auf
  den lebenden Ort.
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen +
  Digest neu pinnen ([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  §Auflösungs-Trigger) und die Strenge-Bilanz über die neue Spanne neu ziehen — **an der
  Quell-Differenz der Regeldateien** und, wo ein aktives Modul Zeilen **verliert**, zusätzlich an
  einer Gegenmessung auf **Nicht-Null-Basis**; der Trockenlauf allein beantwortet die
  §3.5-Frage in keiner der beiden Richtungen.
