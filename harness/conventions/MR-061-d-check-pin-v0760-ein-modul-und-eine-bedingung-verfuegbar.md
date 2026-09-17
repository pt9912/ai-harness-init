# MR-061 — d-check-Pin v0.76.0 (ein Modul und eine structure-Bedingung verfügbar, beide nicht aktiv)

> **ÜBERHOLT: die Gegenmessung auf Nicht-Null-Basis samt dem Satz zur vierten Ausgabe-Spalte, im Absatz „Kein ADR nötig“ der Satzteil über die Basis, im Auflösungs-Trigger die Stelle zur Gegenmessung, die Zahl „vier Anker“ und der Zeiger „ihre Zahl setzt MR-010 Setzung 1“ → [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen).** Pin, Digest, Quell-Differenz, Trockenlauf und die übrigen Messungen gelten fort, ebenso der Schluss „keine Senkung“, den MR-063 über alle acht aktiven Module misst.

- **Datum:** 2026-09-17
- **Wirksamkeits-Anlass:** slice-d-check-pin-bringt-die-stilllegungs-bedingung.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), §Baseline (Zeile `d-check:`); setzt
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
  fort. **Nicht** die Modul-Liste der [`.d-check.yml`](../../.d-check.yml) und **nicht** die
  emittierte Startkonfiguration — dieser Sprung aktiviert nichts. **Nicht** die Handgriffe der
  Re-Adaption: ihre Zahl setzt
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1, und dieser
  Eintrag misst sie nur.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  aus demselben Grund wie
  [`MR-024`](../conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar),
  [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) und
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte):
  ein Pin-Sprung, der Fähigkeiten **verfügbar** macht, ohne eine zu aktivieren, tritt an keine
  Stelle. Er ist der bewusste Digest-Commit aus
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  und die Neu-Erzeugung des Fragments aus
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk`. Das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld.
- **Adaption:** Das gepinnte d-check-Image springt **v0.74.1 → v0.76.0**. Digest
  `sha256:f0b55fde2be414dda51ddeea5677d5ad1094eecb23a528cfef768cbd61945396`, auf vier Wegen mit
  einem Wert belegt: Registry (`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.76.0`,
  Zeile `Digest:`), Pull (`docker pull ghcr.io/pt9912/d-check:v0.76.0`, Zeile `Digest:`), lokaler
  RepoDigest (`docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.76.0`)
  und als **Fremdquelle** das Benutzerhandbuch des Werkzeugs
  (`D=<maschinen-lokaler Klon des Werkzeugs>; grep -rn 'f0b55fde' "$D" --include='*.md'` → **1**
  Zeile; kein Erwartungswert, der Klon wandert). Die ersten zwei Wege brauchen Netz
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin steht
  in `d-check.mk` und, daran gekoppelt, in `internal/emit/emit.go`; hier steht, wogegen er belegt
  ist, und der Sprung, den er gemacht hat
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
- **Zwei Minor-Releases liegen zwischen den zwei Ständen.** Am lokalen Klon des Werkzeug-Repos:

  ```sh
  D=<maschinen-lokaler Klon des Werkzeugs>
  git -C "$D" for-each-ref --sort=v:refname \
    --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.75*' 'refs/tags/v0.76*'
  ```

  Die Ausgabe nennt `v0.75.0` (2026-09-08) und `v0.76.0` (2026-09-17). **Keine
  Erwartungswerte** — ein Patch-Release auf einer der zwei Linien trifft dasselbe Muster
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Zweck: ein Modul und eine `structure`-Bedingung werden verfügbar, keines wird aktiviert.**
  - **Das Modul `mentions`.** Der Modulsatz des Bildes wächst von **22** auf **23**, abzählbar an
    den `--disable`-Namen der generierten Recipes
    (`docker run --rm --network none <digest> --print-mk | grep -oE '\-\-disable [a-z]+' | sort -u | wc -l`
    je Digest); der `diff` der zwei Namensmengen nennt genau `mentions`. Die Herkunft steht als
    **Fremdquelle** im CHANGELOG des Klons unter `[0.75.0]`: ein opt-in-Modul, das eine
    Artefakt-Menge gegen ihre Nennung in Dokumenten hält, Grund-Code `artifact-unmentioned`.
  - **Die Bedingung `open-tasks-require-marker`** samt `open-tasks-require-marker-section`, die
    elfte Bedingung des Moduls `structure`, Grund-Code `section-open-tasks-marker-missing`
    (CHANGELOG `[0.76.0]`, Fremdquelle). Sie koppelt Überschuss-Task-Items gegen
    `max-open-tasks` an eine Marke; ohne ihre Schlüssel verhält sich das Modul laut demselben
    Eintrag byte-identisch. Als Anlass nennt der Eintrag einen Änderungswunsch zur Pflichtzeile
    Baseline-konformer Stilllegungs-Slices — die Form, deren Meldungen
    [`harness/sensors/docs-check.md`](../sensors/docs-check.md) für dieses Repo misst.
  - **Das Feld `summary.notes`** (CHANGELOG `[0.75.0]`): Die Lauf-Zusammenfassung kann vor der
    Zählzeile weitere `d-check: …`-Zeilen tragen; gefüllt werden sie nur von `mentions`. Kein
    Werkzeug dieses Repos liest `summary`
    (`git grep -n 'filesChecked\|findingCount' -- harness/tools test internal ':!*.md'` → kein
    Treffer, Exit 1), und über diesem Baum bleibt die Zeile aus: Die Gegenmessung unten endet
    unter beiden Digests mit genau einer `d-check:`-Zeile auf stderr.
  - **Aktiviert ist keines.** `grep -m1 '^modules:' .d-check.yml` →
    `modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]`, weder
    `mentions` noch `structure`; eine `structure`-Bedingung wirkt zudem nur in einem
    `structure:`-Block, und `grep -c '^structure:' .d-check.yml` → **0**, Exit 1. Beides sind
    keine Erwartungswerte. Leer aktiviert wäre ein Modul ein Phantom-Gate
    ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); eine
    Aktivierung ist ein **Anheben**
    ([`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)) mit
    eigener Konfiguration, eigenem grünen Start und eigenem roten Gegenbeispiel. Für die
    Bedingung trägt sie `slice-stilllegungs-form-hat-einen-waechter`.
- **Trockenlauf vor dem Pin (Pflicht, belegt —
  [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster).**
  `make docs-check DCHECK_DIGEST=<digest>` über dem Arbeitsbaum, je Digest: beide
  `d-check: 1565 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Das Rezept führt keine
  `--disable`-Liste und fährt darum beide Digests (`sed -n '/^docs-check:/,+1p' d-check.mk`).
  **Die Dateizahl ist kein Erwartungswert**; tragend ist die **0**. In der Gegenrichtung ist der
  Lauf über einer 0-Befund-Basis **informationsleer** — ein Wegfall sähe gleich aus. Diese
  Richtung tragen die Messungen darunter.
- **Ein Rezept mit voller `--disable`-Liste fährt nur den Digest seines Fragments.** Jede solche
  Liste nennt jetzt `mentions`, und der alte Digest bricht daran ab:
  `make doc-immutable RANGE=<range> DCHECK_DIGEST=<v0.74.1-digest>` →
  `d-check: error: unbekanntes Modul "mentions"`, make-Exit 2. Ein Vergleichslauf eines solchen
  Rezepts fährt deshalb jeden Digest mit dem Fragment seines Standes; für `v0.74.1` ist das
  `git show 0fbefa46^:d-check.mk`.
- **Strenge-Bilanz an der Quell-Differenz: null bewegte Zeilen an allen acht aktiven
  Regeldateien.** Am Klon (`D` wie oben) gibt
  `git -C "$D" diff --numstat v0.74.1..v0.76.0 -- internal/hexagon/core/rules/{links,anchors,ids,matrix,codepaths,spans,planning,targets}.go`
  **keine** Zeile aus. **Gegen das falsche Negativ geprüft:**
  `git -C "$D" ls-tree --name-only <tag> internal/hexagon/core/rules/` führt unter **beiden** Tags
  alle acht Dateien unter denselben Pfaden. Die acht Namen sind die der `modules:`-Zeile oben: Die
  Bilanz folgt der Zeile, die zum Sprung gilt, nicht der Liste des Vorgänger-Eintrags.
- **Die geteilte Infrastruktur verliert Zeilen, und sie ist gelesen.**
  `git -C "$D" diff --numstat v0.74.1..v0.76.0 -- 'internal/**/*.go' ':!*_test.go'` führt
  dreizehn Dateien. Außerhalb der Regeldateien verlieren vier Zeilen: `rules/run.go` (+22/−6 — die
  sechs Minuszeilen sind die Signatur von `runPostPasses`, das ein drittes Ergebnis `notes`
  bekommt), `model/config.go` (+59/−1 — die Modul-Liste nimmt `mentions` auf), `cli/cli.go`
  (+1/−1 — die Zusammenfassung trägt `Notes`) und `cli/config_template.go` (+13/−1 — die Zeile
  `Verfügbar:`). Keine dieser Stellen nimmt einem aktiven Modul eine Prüfung. Damit greift die
  zweite Hälfte des Auflösungs-Triggers von
  [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt),
  und die Gegenmessung unten ist Pflicht.
- **Drei Regeldateien nicht aktiver Module bewegen sich, und eine davon fährt ein Werkzeug dieses
  Repos.** `rules/structure.go` (+46/−3) trägt die neue Bedingung, `rules/workflows.go` (+6/−2)
  ändert einen Kommentar. `rules/vcs.go` (+9/−1) wird **schärfer**: Eine als hinzugefügt
  gemeldete Datei liest jetzt ihren BASE-Stand, und ist der nicht lesbar, endet der Lauf mit einem
  Fehler, statt befundfrei durchzugehen (`git -C "$D" diff v0.74.1..v0.76.0` über derselben
  Datei). `vcs` steht nicht in `modules:`; gefahren wird es von `make adr-immutable` über
  `doc-immutable`, kein Gate. Der lesbare Fall bleibt still:
  `make adr-immutable RANGE=8ae647cc~1..8ae647cc` — eine Range, die eine ADR-Datei hinzufügt
  (`git show --name-only --diff-filter=A --format= 8ae647cc`) — meldet unter `v0.76.0`
  `0 Befund(e)`, make-Exit 0. **Den abbrechenden Fall misst dieser Eintrag nicht.** Eine Senkung
  ist die Änderung nicht: Sie nimmt einem Lauf einen stillen Durchgang.
- **Gegenmessung auf Nicht-Null-Basis: identische Befundmengen.** Kopie des Baums außerhalb des
  Repos (`git archive 0fbefa46`), alle Marker in Markdown außerhalb der vendored Baseline
  entwertet
  (`find . -name '*.md' -not -path './.harness/baseline/*' -exec sed -i 's/d-check:ignore/d-check:IGNORIERT-NICHT/g' -- {} +`;
  Restzähler außerhalb der Baseline danach **0**), dann beide Digests per
  `docker run --rm --network none -v "<kopie>:/repo:ro" ghcr.io/pt9912/d-check@<digest>`:
  **beide** melden `d-check: 1575 Datei(en) geprüft, 379 Befund(e)`, Exit 1. Der `diff` der
  sortierten vollen Befundzeilen ist **leer**, und die Verteilung über `cut -f3 | sort | uniq -c`
  ist beidseitig **21** `codepath-missing`, **39** `id-unlinked`, **319** `target-missing`.
  **Tragend ist die Gleichheit der zwei Mengen**, nicht die Datei- oder Befundzahl — beide wachsen
  mit dem Bestand. Auf derselben Basis zählt `awk -F'\t' '{print NF}'` unter beiden Digests nur
  **4**: Die vierte Ausgabe-Spalte aus
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
  bleibt.
- **[`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
  Re-Evaluierungs-Trigger 2 (ein Modul des Doku-Gates hält Status und Adress-Form zusammen): nicht
  eingetreten.** Der `diff` der `--print-config`-Ausgaben beider Digests zählt
  `| grep -c '^[<>]'` → **14** Zeilen: die Zeile `Verfügbar:` in beiden Fassungen, deren neue
  `mentions` nennt, und zwölf Kommentarzeilen zu den zwei neuen `structure`-Schlüsseln. Die
  Bedingung koppelt offene Task-Items an eine Marke, `mentions` hält Artefakte gegen ihre
  Nennung; keines liest eine Status-Zeile zusammen mit der Form eines Verweises, und die
  Regeldatei von `planning` steht unter den acht unbewegten oben. Der `diff` **bestätigt**, er
  trägt nicht: `--print-config` gibt eine Beispiel-Config aus, keine Schema-Liste
  ([`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)).
- **Das Fragment: sieben Hunks zwischen den zwei Werkzeug-Ausgaben, acht zwischen Ausgabe und
  Adaption, unter beiden Digests.** `--print-mk` liefert unter beiden Digests **76** Zeilen
  (`… --print-mk | wc -l`); der `diff` der zwei Ausgaben zählt `grep -c '^[0-9]'` → **7** Hunks:
  die `DCHECK_IMAGE`-Zeile und `--disable mentions` in den sechs fokussierten Rezepten. Kein neues
  Target: `grep -cE '^docs?-[a-z-]+:'` → **13** über beiden Ausgaben und über `d-check.mk`. Die
  vier Anker aus
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger
  treffen die neue Ausgabe und `internal/emit/testdata/raw-print-mk.txt` je einmal; die Fixture
  bleibt. Gegen die Adaption zählt
  `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@<v0.76.0-digest> --print-mk) d-check.mk | grep -c '^[0-9]'`
  → **8**, und dasselbe Paar am Vorgänger — die `v0.74.1`-Ausgabe gegen
  `git show 0fbefa46^:d-check.mk` — ebenfalls **8**. Die Re-Adaption kostet dieselben Handgriffe
  wie am Vorgänger-Fragment.
- **Es sind fünf Handgriffe, und der fünfte steht in keinem Eintrag dieses Blocks bis
  [`MR-060`](../conventions.md#mr-060--ein-neues-pflichtfeld-gilt-für-neue-einträge-bestehende-werden-nicht-nachgetragen).**
  Der Kopf von `d-check.mk` zählt fünf. Der fünfte ist die Marke bei `doc-tracked` und
  `doc-structure`, Hilfetext-Anhang und Ausgabe-Zeile, und er allein erzeugt vier der acht Hunks:
  Die `diff`-Ausgabe oben nennt an den zwei Zielen je einen `c`- und einen `a`-Hunk. Den fünften
  hält [`test/doc-block-marke-wiring.bats`](../../test/doc-block-marke-wiring.bats).
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 zählt vier,
  und die übrigen Einträge, die den Begriff führen, ebenfalls
  (`grep -li handgriff harness/conventions/MR-0[0-5]*.md harness/conventions/MR-060-*.md` → die
  Dateien von MR-010, MR-024, MR-027 und MR-052). **Dieser Eintrag misst den fünften Handgriff,
  deklariert ihn aber nicht:** Ein Pin-Eintrag datiert einen Sprung
  ([`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 4), und eine Setzung über die Re-Adaption gehört an den Ort, den
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) hat.
- **Neu gemessen am neuen Digest, mit genanntem Stand
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  Setzung 2).**
  - Der Abbruch unter `--range`, den der Kommentar am `commits`-Block der
    [`.d-check.yml`](../../.d-check.yml) und
    [`harness/sensors/commit-msg-check.md`](../sensors/commit-msg-check.md) führen:
    `make doc-commits RANGE=HEAD~3..HEAD` endet unter beiden Digests, jeder mit seinem Fragment, mit
    `d-check: error: Range-Basis-Vorfahren nicht lesbar: object not found`, make-Exit 2.
  - `make commit-msg-check MSG=<datei>`, das den `commits`-Block über `--commit-msg` fährt, hält
    unter `v0.76.0` beide Richtungen: Eine Message mit Kennung ergibt make-Exit 0, eine ohne
    Kennung ergibt `commit-untraceable`.
  - Die Stilllegungs-Tabelle in [`harness/sensors/docs-check.md`](../sensors/docs-check.md) nennt
    ihren Messstand selbst (`grep -n 'f0b55fde' harness/sensors/docs-check.md`).
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** §3.5 verlangt einen ADR für
  **Senkungen**. Gemessen bewegt sich an den acht aktiven Modulen keine Quellzeile. Die geteilte
  Infrastruktur nimmt keinem aktiven Modul eine Prüfung, und auf einer Basis, die einen Wegfall
  gezeigt hätte, ist die Befundmenge identisch. Die einzige Verhaltensänderung an einem gefahrenen
  Modul (`vcs`) ist eine Verschärfung. Die CHANGELOG-Aufzählung **bestätigt nur**, sie trägt
  nicht: Sie weist für die Spanne keinen Breaking Change aus
  (`git -C "$D" show v0.76.0:CHANGELOG.md | awk '/^## \[0\.76\.0\]/,/^## \[0\.74\.1\]/'`), und ihr
  *Changed* betrifft nur den Harness des Werkzeugs.
- **Emitter-Pin gekoppelt (Tier-1-Drift).** `internal/emit`s `DefaultImage`/`DefaultDigest` zieht
  per go-Test mit (`TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` lesen
  `d-check.mk`). Die emittierte Startkonfiguration bleibt
  (`grep -m1 'modules:' internal/emit/templates/d-check.yml` →
  `modules: [links, anchors, ids, matrix, spans]`): Dieser Sprung bewegt eine Versions-Referenz,
  keine Modul-Zusammensetzung, und berührt
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  damit nicht.
- **Begründung:** Der Digest ist die Reproduzierbarkeits-Zusage
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der Sprung stellt die
  Bedingung bereit, die ein Wächter über der Stilllegungs-Form braucht; ohne ihn hätte ihre
  Aktivierung kein Bild, in dem sie läuft. Der Eintrag ist eine **datierte Momentaufnahme**
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)):
  Jede Werkzeug-Aussage nennt `v0.74.1` oder `v0.76.0` als Mess-Operand, keine den lebenden Pin.
  **Keine Kopf-Marke an
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte):**
  Dieser Eintrag löst keine Aussage jenes Eintrags ab — dessen Messungen sind über `v0.74.1`
  genommen und bleiben wahr —, und für die d-check-Pin-Kette nennt
  [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 4 die Marke nicht fällig. Auch die Zahl von vier Handgriffen dort löst dieser Sprung
  nicht ab: Das Vorgänger-Fragment ergibt gegen seine Ausgabe schon acht Hunks.
- **Auflösungs-Trigger:** permanent. Bei jedem d-check-Release ist `d-check --print-mk` neu zu
  erzeugen und der Digest neu zu pinnen
  ([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  §Auflösungs-Trigger). Danach wird die Strenge-Bilanz über die neue Spanne neu gezogen, an drei
  Stellen:
  - an der Quell-Differenz der Regeldateien der Module, die die `modules:`-Zeile **zum Sprung**
    führt;
  - an einer Gegenmessung auf **Nicht-Null-Basis**;
  - **zusätzlich** an den Regeldateien der Module, die ein Werkzeug dieses Repos außerhalb von
    `modules:` fährt (`grep -ohE '\-\-enable [a-z]+' d-check.mk Makefile | sort -u`) — über dieser
    Spanne fand erst diese Stelle die Verschärfung in `vcs`.
