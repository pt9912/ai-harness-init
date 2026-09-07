# MR-052 — d-check-Pin v0.74.1 (zwei Module verfügbar, vierte Ausgabe-Spalte)

- **Datum:** 2026-09-05
- **Wirksamkeits-Anlass:** slice-187.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), `Makefile` (das Tag-Beispiel im Kommentar
  über `DCHECK_TAG`), §Baseline; setzt
  [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) fort.
  Die Target-Aufzählung steht in
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2 und wächst
  dort mit diesem Sprung — sie ist an den Re-Pin gebunden, nicht an das Datum ihres Eintrags, und
  steht darum nicht ein zweites Mal hier.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  aus demselben Grund wie
  [`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) und
  [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt): ein
  Pin-Sprung, der Module **verfügbar** macht, ohne eines zu aktivieren, tritt an keine Stelle. Er
  ist der bewusste Digest-Commit aus
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.5.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  und die Neu-Erzeugung des Fragments aus
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.5.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk`. Auch die Strenge-Bilanz ersetzt nichts: sie beantwortet die
  §3.5-Frage von [`AGENTS.md`](../../AGENTS.md) an der Quell-Differenz.
- **Adaption:** Das gepinnte d-check-Image springt **v0.65.0 → v0.74.1**. Digest
  `sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`, **dreifach belegt**:
  Registry (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.74.1`, Zeile `Digest:`),
  lokaler RepoDigest
  (`docker image inspect --format '{{index .RepoDigests 0}}' ghcr.io/pt9912/d-check:v0.74.1`) und
  als **Fremdquelle** das Benutzerhandbuch des Werkzeugs
  (`grep -rn 'e31a372b' /Development/d-check --include='*.md'` → **1** Zeile) — drei Wege, ein Wert
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin steht
  in `d-check.mk` und, daran gekoppelt, in `internal/emit/emit.go`; hier steht, wogegen er belegt
  ist, und der Sprung, den er gemacht hat
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
- **Zwölf Tags liegen zwischen den zwei Ständen — neun Minor- und drei Patch-Releases.** Am
  lokalen Klon des Werkzeug-Repos:

  ```sh
  git -C /Development/d-check for-each-ref --sort=v:refname \
    --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.6[5-9]*' 'refs/tags/v0.7[0-9].*'
  ```

  Die Ausgabe spannt `v0.65.0` (2026-08-28) bis `v0.74.1` (2026-09-04); die neun Minors sind
  `v0.66.0`…`v0.74.0`, die drei Patches `v0.66.1`, `v0.71.1` und `v0.74.1`. **Keine
  Erwartungswerte** — die Menge wächst mit jedem Upstream-Release
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Es ist die zweitgrößte Spanne dieser Linie; größer war nur
  [`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) mit elf Minors.
- **Zweck: zwei Module werden verfügbar, keines wird aktiviert.** Der Modulsatz des Bildes wächst
  von **20** auf **22**, abzählbar an den `--disable`-Namen der generierten Recipes
  (`docker run --rm --network none <digest> --print-mk | grep -oE '\-\-disable [a-z]+' | sort -u | wc -l`
  je Digest); der `diff` der zwei Namensmengen nennt genau `reviews` und `workflows`. Ihre
  Herkunft steht im CHANGELOG des Klons als **Fremdquelle** — *„Neues Modul `workflows`"* unter
  `[0.67.0]` (das 21.), *„Neues Modul `reviews`"* unter `[0.73.0]` (das 22.). **Aktiviert ist
  keines:** `grep -m1 '^modules:' .d-check.yml` → `modules: [links, anchors, ids, matrix, codepaths, spans]`.
  Leer aktiviert wäre ein Modul ein Phantom-Gate
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), und eine
  Aktivierung ist ein **Anheben** über den Steering-Loop
  ([`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)) mit
  eigener Config-Entscheidung und eigenem Trockenlauf — dieselbe Trennung, die
  [`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) im Titel führt.
- **Eine dritte Fähigkeit kommt hinzu, und eine vierte ist älter als dieser Sprung.** Neu ist
  `planning.observations.dir` (`[0.74.0]`, Fremdquelle CHANGELOG des Klons): eine zitierte
  Beobachtungs-Kennung gilt als nachgewiesen, wenn `<observations.dir>/<pfad>/observation.md`
  existiert — die Verzeichnis-Form, die dieses Repo unter
  [`observations/`](../../docs/plan/planning/observations/README.md) führt. **`DC-FA-PLAN-001`
  gehört nicht dazu:** die Fähigkeit liegt schon im Vorgänger-Pin, gemessen an dessen eigener
  Ausgabe (`docker run --rm --network none <v0.65.0-digest> --print-mk | grep -n '^doc-planning:'`
  nennt sie im Hilfetext). Wer sie unter den *ab diesem Pin* verfügbaren führt, zählt eine mit,
  die der Vorgänger schon hatte. **Und `d-check --print-config` beantwortet die Frage nicht:** es
  gibt eine kommentierte Beispiel-Config aus, keine Schema-Liste — `observations` kommt in beiden
  Ausgaben nicht vor, in der neuen so wenig wie in der alten
  ([`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
  §Der Name, unter dem man ihn sucht).
- **Trockenlauf vor dem Pin (Pflicht, belegt —
  [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).** Beide
  Digests netzlos (`--network none`) gegen eine Kopie des Baums außerhalb des Repos
  (`git archive HEAD`), Mount `:ro`, unveränderte `.d-check.yml`: beide
  `d-check: 822 Datei(en) geprüft, 0 Befund(e)`, Exit 0, `diff` der zwei Ausgaben **leer**. **Die
  Dateizahl ist kein Erwartungswert** — sie wächst mit jedem Dokument; tragend sind die **0** und
  die leere `diff`-Ausgabe.
- **Was dieser Lauf trägt — und was nicht.** Er trägt **eine** Richtung: über diesem Korpus
  entsteht kein neuer Befund. In der **Gegenrichtung** ist er über einer 0-Befund-Basis
  **informationsleer** — eine weggefallene Befundklasse erzeugt dieselbe Ausgabe wie eine
  unveränderte. Diese Richtung tragen die zwei Messungen darunter.
- **Strenge-Bilanz an der Quell-Differenz: null bewegte Zeilen an allen sechs aktiven
  Regeldateien.** Am Klon gibt
  `git -C /Development/d-check diff --numstat v0.65.0..v0.74.1 -- internal/hexagon/core/rules/{links,anchors,ids,matrix,codepaths,spans}.go`
  **keine** Zeile aus. **Gegen das falsche Negativ geprüft**, statt aus der leeren Ausgabe
  geschlossen: `git -C /Development/d-check ls-tree --name-only <tag> internal/hexagon/core/rules/`
  führt unter **beiden** Tags alle sechs Dateien unter denselben Pfaden — eine Umbenennung, die
  dieselbe leere Ausgabe erzeugt hätte, liegt nicht vor.
- **Die Reichweite dieser Messung endet an den Regeldateien, und das ist ihre benannte Grenze.**
  Dieselbe Differenz über `'internal/**/*.go'` führt geteilte Infrastruktur, die jedes Modul
  durchläuft, und **auch sie verliert Zeilen**. Eine Bedingung, die auf die Regeldateien zeigt,
  ist deshalb die **Untergrenze** der §3.5-Frage, nicht ihre Antwort — der Auflösungs-Trigger von
  [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
  knüpft die Gegenmessung wörtlich an *„wo ein aktives Modul Zeilen verliert"*, und diese Spanne
  erfüllt das an den Regeldateien nicht. Gefahren ist sie hier trotzdem, und sie hat etwas
  gefunden (unten).
- **Gegenmessung auf Nicht-Null-Basis: identische Befundmengen.** Kopie des Baums außerhalb des
  Repos, alle Marker in getracktem Markdown außerhalb der vendored Baseline entwertet
  (`find . -name '*.md' -not -path './.harness/baseline/*' -exec sed -i 's/d-check:ignore/d-check:IGNORIERT-NICHT/g' -- {} +`;
  Restzähler danach **0**), dann beide Digests: **beide** melden
  `d-check: 826 Datei(en) geprüft, 85 Befund(e)`, Exit 1, und die Befundmenge ist je Datei, Zeile,
  Ziel und Grund-Code **identisch** — `diff` der zwei nach `cut -f1-3` sortierten Ströme ist leer,
  die Verteilung beidseitig **15** `codepath-missing`, **38** `id-unlinked`, **32**
  `target-missing`. **Auf einer Basis, auf der ein Wegfall sichtbar geworden wäre, fällt nichts
  weg.** Tragend ist die Gleichheit der zwei Mengen, nicht die Datei- oder Befundzahl.
- **Die Befund-Zeile trägt ab diesem Pin eine vierte, tab-getrennte Spalte:** den Klartext des
  Grundes (`target-missing` → *„Linkziel existiert nicht"*). Über einer 0-Befund-Basis ist die
  Änderung unsichtbar; auf der Nicht-Null-Basis oben zählt
  `awk -F'\t' '{print NF}'` über den Befundzeilen **3** unter `v0.65.0` und **4** unter `v0.74.1`.
  Wer die letzte Spalte als Grund-**Code** liest (`awk -F'\t' '{print $NF}'` — die Form, die
  [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) für
  seine Klassen-Bilanz benutzt), bekommt ab hier den Klartext; die Bilanz oben schneidet deshalb
  über `$3`. **Das ist die Verhaltensänderung dieser Spanne**, und nur die Gegenmessung zeigt sie.
- **Das geteilte Referenz-Ventil trägt unter diesem Pin — an einer roten Gegenprobe.** `.d-check.yml`
  führt `ignore-refs` als Top-Level-Schlüssel mit **vier** Paaren
  (`grep -cE '^  - in:' .d-check.yml`). Über einer Kopie des Baums außerhalb des Repos, aus deren
  `.d-check.yml` der `ignore-refs`-Block entfernt ist, meldet `make docs-check` unter `v0.74.1`
  **4 Befunde** und Exit 1 — je einen aus jedem Paar; mit dem Block **0** und Exit 0. Das ist der
  Trockenlauf, den der Auflösungs-Trigger von
  [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
  für jeden Re-Pin verlangt: Das Ventil hat seine Wirkung nicht verloren.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für
  **Senkungen**. Gemessen bewegt sich an den sechs aktiven Modulen keine Quellzeile, und auf einer
  Basis, die einen Wegfall gezeigt hätte, ist die Befundmenge identisch. Die
  CHANGELOG-Aufzählung ist dabei **bestätigend, nicht tragend** — upstream weist sie selbst als
  offen aus ([`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) §Welches
  der zwei Beine die Bilanz trägt): der eine Breaking Change der Spanne (`[0.66.1]`,
  `structure`-Tabellenschlüssel) und die eine ausgewiesene Lockerung (`[0.69.0]`, ebenfalls
  `structure`) liegen in einem Modul, das die `modules:`-Zeile oben nicht führt.
- **Emitter-Pin gekoppelt (Tier-1-Drift).** `internal/emit`s `DefaultImage`/`DefaultDigest` zieht
  per go-Test mit (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` lesen
  `d-check.mk`); die emittierte Starter-Config bleibt `modules: [links, anchors]`
  ([`MR-017`](../conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) —
  dieser Sprung bewegt eine Versions-Referenz, keine Prüfbereichs-Entscheidung.
- **Das Fragment ändert sich in acht Zeilen, und die Re-Adaption bleibt bei vier Handgriffen.**
  `--print-mk` unter beiden Digests, netzlos: **68** gegen **76** Zeilen; die frische Ausgabe führt
  vier Kopf-Kommentarzeilen mehr, je `--disable workflows --disable reviews` in sechs fokussierten
  advisory-Recipes, das neue Target `doc-usage` und die `DCHECK_IMAGE`-Zeile.
  `diff <(docker run --rm --network none <v0.74.1-digest> --print-mk) d-check.mk | grep -c '^[0-9]'`
  → **4**: genau die vier Handgriffe aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1, kein
  fünfter. Damit stammt alles übrige byte-gleich vom Werkzeug.
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen + Digest
  neu pinnen ([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  §Auflösungs-Trigger) und die Strenge-Bilanz über die neue Spanne neu ziehen — **an der
  Quell-Differenz der Regeldateien** und **zusätzlich** an einer Gegenmessung auf
  **Nicht-Null-Basis**. Die Gegenmessung hängt dabei nicht mehr an der Bedingung *„ein aktives
  Modul verliert Zeilen"*: über dieser Spanne war sie nicht erfüllt, und die Gegenmessung fand die
  vierte Ausgabe-Spalte trotzdem.
