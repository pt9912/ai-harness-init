# MR-064 — d-check-Pin v0.76.1 (vcs bricht bei unlesbarem Unterbaum ab)

- **Datum:** 2026-09-17
- **Wirksamkeits-Anlass:** slice-d-check-pin-zieht-den-vcs-patch-nach.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), §Baseline (Zeile `d-check:`); setzt
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
  fort. Dazu die zwei Aussagen jenes Eintrags, die `Löst auf` nennt. **Nicht** die Modul-Liste
  der [`.d-check.yml`](../../.d-check.yml) und **nicht** die emittierte Startkonfiguration: Dieser
  Sprung aktiviert nichts. **Nicht** die Handgriffe der Re-Adaption: Ihre Zahl setzen
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff),
  dieser Eintrag misst sie nur. **Nicht** die Methode der Gegenmessung: Sie setzt
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen).
- **Löst auf:** in
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
  - im Absatz über die drei Regeldateien nicht aktiver Module den Satz *„Der lesbare Fall bleibt
    still: …"* samt seiner Messung und den Satz *„Den abbrechenden Fall misst dieser Eintrag
    nicht."*;
  - im Absatz *„Neu gemessen am neuen Digest"* die Gleichsetzung des gemessenen
    `--range`-Abbruchs mit dem Abbruch, den der Kommentar am `commits`-Block der `.d-check.yml` und
    `harness/sensors/commit-msg-check.md` an jenem Stand beschrieben.
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat die Ablösung ein Werkzeug-Pin, der
  Sprung dieses Eintrags. Dieselbe Lage beschreibt
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv):
  Ein Pin-Sprung, der nichts aktiviert, tritt an keine Stelle. Er ist der bewusste Digest-Commit
  aus
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  und die Neu-Erzeugung des Fragments aus
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk`. Das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld.
- **Adaption:** Das gepinnte d-check-Image springt **v0.76.0 → v0.76.1**. Der Digest
  `sha256:1470ecdcaa686a5ef4513dee9b0ae522586f54b87d568b06fc6b5b2741b633b3` ist auf drei Wegen mit
  demselben Wert belegt:
  - Pull: `docker pull ghcr.io/pt9912/d-check:v0.76.1`, Zeile `Digest:`;
  - Registry: `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.76.1`, Zeile `Digest:`;
  - lokaler RepoDigest:
    `docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.76.1`.

  Die ersten zwei Wege brauchen Netz
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin
  steht in `d-check.mk` und, daran gekoppelt, in `internal/emit/emit.go`. Hier steht, wogegen er
  belegt ist und welchen Sprung er gemacht hat
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
- **Zwischen den zwei Ständen liegt ein Patch-Release.** Am lokalen Klon des Werkzeugs:

  ```sh
  D=<maschinen-lokaler Klon des Werkzeugs>
  git -C "$D" for-each-ref --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.76*'
  ```

  Die Ausgabe nennt `v0.76.0` und `v0.76.1`, beide vom 2026-09-17. **Keine Erwartungswerte:** Ein
  weiterer Patch trifft dasselbe Muster
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Zweck: `vcs` bricht bei einem unlesbaren Unterbaum ab.** Bisher meldete es in diesem Fall
  still grün oder eine falsche Ursache. Der CHANGELOG des Klons nennt das als **Fremdquelle**
  (`git -C "$D" show v0.76.1:CHANGELOG.md | awk '/^## \[0\.76\.1\]/,/^## \[0\.76\.0\]/'`):
  - `vcs` löst die geschützte Pfad-Menge gegen beide Tree-Stände auf.
  - Ein unlesbarer Unterbaum bricht den Lauf mit Exit 2 ab.
  - Ein unlesbarer Spitzen-Baum meldet einen Umgebungsfehler statt `core-drift-vcs`.

  **Neu verfügbar wird nichts.** `--print-mk` unterscheidet sich zwischen den zwei Digests nur in
  der Zeile `DCHECK_IMAGE`. Die `--disable`-Listen sind damit gleich, also auch der Modulsatz.
  Der `diff` der zwei `--print-config`-Ausgaben ist leer. `vcs` steht nicht in `modules:`; es
  läuft über `make adr-immutable` und `doc-immutable`, und keines der beiden ist ein Gate.
- **Trockenlauf vor dem Pin.** `make docs-check DCHECK_DIGEST=<digest>` über dem Arbeitsbaum
  meldet unter beiden Digests `d-check: 1585 Datei(en) geprüft, 0 Befund(e)`, make-Exit 0.
  **Die Dateizahl ist kein Erwartungswert;** tragend ist die **0**. Ob eine Prüfung wegfällt,
  zeigt dieser Lauf nicht; das zeigt die Gegenmessung unten.
- **Das Fragment: ein Hunk zwischen den zwei Werkzeug-Ausgaben, acht zwischen Ausgabe und
  Adaption.**
  - Umfang: `docker run --rm --network none ghcr.io/pt9912/d-check@<digest> --print-mk | wc -l`
    ergibt unter beiden Digests **76**.
  - Unterschied: Der `diff` der zwei Ausgaben ergibt mit `grep -c '^[0-9]'` genau **1** Hunk, die
    Zeile `DCHECK_IMAGE`.
  - Targets: `grep -cE '^docs?-[a-z-]+:'` ergibt **13** über beiden Ausgaben und über
    `d-check.mk`. Es kommt kein Target hinzu.
  - Adaption:
    `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@<v0.76.1-digest> --print-mk) d-check.mk | grep -c '^[0-9]'`
    ergibt **8**. Das ist dieselbe Zahl, die
    [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
    am Vorgänger misst; es kommt kein Handgriff hinzu.
  - Anker: Die fünf Anker aus
    [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
    treffen die `v0.76.1`-Ausgabe und `internal/emit/testdata/raw-print-mk.txt` je einmal. Die
    Fixture bleibt unverändert.

  **Der fünfte Anker ist ein Literal mit führendem Hochkomma.** `grep -cF "'^doc-[a-z-]+:"`
  ergibt **1** über beiden Dateien. Als Regex gelesen (`grep -cE '^doc-[a-z-]+:'`) zählt dasselbe
  Muster die Ziel-Zeilen, über der Fixture **11**, und ist dann nicht der Anker.
- **Strenge-Bilanz: jede Aussage mit ihrem Träger.** Am Klon des Werkzeugs (`D` wie oben), nur
  lesend.
  - **Die acht aktiven Regeldateien bewegen sich nicht. Träger: die Quell-Differenz.**
    `git -C "$D" diff --numstat v0.76.0..v0.76.1 -- internal/hexagon/core/rules/{links,anchors,ids,matrix,codepaths,spans,planning,targets}.go`
    gibt keine Zeile aus. Gegenprobe auf ein falsches Negativ:
    `git -C "$D" ls-tree --name-only v0.76.1 internal/hexagon/core/rules/` führt alle acht Dateien
    unter denselben Pfaden; für `v0.76.0` misst das
    [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv).
    Die acht Namen stammen aus der `modules:`-Zeile, die zum Sprung gilt
    (`grep -m1 '^modules:' .d-check.yml`).
  - **Was sich sonst bewegt. Träger: die Quell-Differenz.**
    `git -C "$D" diff --numstat v0.76.0..v0.76.1 -- internal/` nennt sieben Dateien, davon drei
    `_test.go`. Die übrigen vier:
    - `core/rules/vcs.go` (+42/−26), die einzige bewegte Regeldatei; von den Modulen, die ein
      Werkzeug dieses Repos außerhalb von `modules:` fährt, bewegt sich damit keine andere;
    - `adapter/driven/git/git.go` (+54/−70), der git-Adapter;
    - `port/driven/vcs.go` (+11/−27), der VCS-Port;
    - `port/driven/workflow.go` (+1/−1): Der `diff` dieser Datei ändert nur eine Kommentarzeile.

    **Die geteilte Infrastruktur verliert Zeilen.** Damit greift die zweite Hälfte des
    Auflösungs-Triggers von
    [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt).
  - **Kein aktives Modul liest über den git-Adapter oder den VCS-Port. Träger: die Quell-Lesung am
    Tag `v0.76.1`.**
    - `git -C "$D" grep -nE '\.(TrackedPaths|FileAt|AllPaths|CommitMessages)\(' v0.76.1 -- 'internal/**/*.go' ':!*_test.go' ':!internal/adapter/driven/git/*'`
      nennt sechs Aufrufe der vier Port-Methoden, alle in drei Dateien: `rules/vcs.go`
      (`AllPaths`, `FileAt`), `rules/commits.go` (`CommitMessages`) und `rules/run.go`, dort nur
      unter aktivem `tracked` (`TrackedPaths`).
    - `git -C "$D" grep -n 'adapter/driven/git' v0.76.1 -- '*.go' ':!*_test.go'` nennt einen
      Import, in `cli/cli.go`. Dort öffnet genau eine Stelle den Adapter (`gitadapter.Open`), und
      der Kommentar davor bindet die Verdrahtung an ein aktives git-Modul.
    - `vcs`, `commits` und `tracked` stehen nicht in `modules:`.

    **Die Gegenmessung trägt diese Aussage nicht.** Sie läuft über einer `git archive`-Kopie ohne
    `.git` und fährt den Port nie.
  - **An den datei-scannenden Pfaden der acht aktiven Module fällt keine Prüfung weg. Träger: die
    Gegenmessung** (nächster Absatz).
  - **Die Verhaltensänderung in `vcs.go` ist eine Verschärfung. Träger: die Wegwerf-Kopie** (unten).
    Der CHANGELOG bestätigt das nur.
- **Gegenmessung nach
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2.** Aufbau:
  - Grundlage ist eine Kopie von `e4c6cb0b`; gemessen wird netzlos. Die Kopie trägt kein `.git`,
    und über den VCS-Port läuft sie nicht.
  - Die Kopie für `v0.76.0` trägt `d-check.mk` aus `e4c6cb0b`, die für `v0.76.1` das Fragment aus
    `ebb76b3d`.
  - Dass beide Fragmente gelaufen sind, zeigt die `make`-Fehlerzeile der dritten Stufe:
    `d-check.mk:88` unter dem alten Stand, `d-check.mk:87` unter dem neuen.
    `grep -n '^docs-check:'` nennt in beiden Fassungen die Zeile davor.
  - Die Werte gelten nur für diesen Commit, diese Digests und diese Sonden.

  | Stufe | `v0.76.0` | `v0.76.1` | `diff` voll |
  |---|---|---|---|
  | unverändert | 0 Befunde, make-Exit 0 | 0 Befunde, make-Exit 0 | leer |
  | Marker entwertet, Symlinks bleiben (10 von 10, 0 reguläre; Kontrolle nach MR-063 Setzung 2) | 57: 20 `codepath-missing`, 37 `id-unlinked` | 57: dieselben | leer |
  | zusätzlich die Sonden aus MR-063 | 74, make-Exit 2 | 74, make-Exit 2 | leer |

  Stufe 3, gelesen über den Befundzeilen ab drei Spalten (`awk -F'\t' 'NF>=3'`):
  - `cut -f3 | sort | uniq -c` zählt unter beiden Digests dieselben Codes mit denselben
    Häufigkeiten wie die Messung in
    [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen):
    `anchor-missing` 1, `citation-out-of-range` 1, `closure-note-missing` 1, `codepath-missing` 21,
    `fence-unclosed` 1, `gate-phantom` 1, `gate-undocumented` 1, `id-unlinked` 40,
    `matrix-forbidden` 1, `matrix-inactive` 1, `planning-drift` 1, `repo-escape` 1,
    `span-nested-link` 1, `span-unclosed` 1, `target-missing` 1. Damit hat jedes der acht aktiven
    Module eine Basis.
  - `awk -F'\t' '{print NF": "$3}' | sort -u` nennt unter beiden Digests drei Spalten für die drei
    `spans`-Codes und vier für alle übrigen.
- **Der abbrechende Fall von `vcs`, an einer Wegwerf-Kopie hergestellt.** Aufbau:
  - `git archive e4c6cb0b` in ein leeres Verzeichnis, dort `git init` und drei Commits A, B und C
    mit losen Objekten; der Arbeitsbaum steht auf C.
  - Ein Baum-Objekt wird unlesbar, indem seine Datei unter `.git/objects/` entfernt wird.
  - Gefahren wird `make doc-immutable RANGE=<range>`, jeder Digest mit seinem Fragment. Gezählt
    wird mit `grep -c 'core-drift-vcs'` über der Ausgabe.

  | Fall | intakt, beide Digests | Objekt entfernt, `v0.76.0` | Objekt entfernt, `v0.76.1` |
  |---|---|---|---|
  | Basis: `A..B`; B entfernt `docs/plan/adr`; entfernt wird der Baum `A:docs/plan/adr` | 48 × `core-drift-vcs` | `0 Befund(e)`, make-Exit 0: **still grün** | make-Exit 2, `Range-Basis … nicht lesbarer Unterbaum docs/plan/adr: object not found` |
  | Spitze: `A..C`; C ändert nur den Abschnitt *Geschichte* einer ADR; entfernt wird der Baum `C:docs/plan/adr` | `0 Befund(e)` | 48 × `core-drift-vcs`, make-Exit 2: **falsche Diagnose**, gelöscht ist nichts | make-Exit 2, `Range-Spitze … nicht lesbarer Unterbaum docs/plan/adr: object not found` |

  Unter `v0.76.1` nennt die Meldung in beiden Fällen den entfernten Unterbaum. Das Rot nennt also
  die Ursache, die tatsächlich vorliegt.
- **Im Arbeitsklon bricht `vcs` genauso ab, und der Abbruch hängt am Objektspeicher, nicht an der
  Range.**
  - **Die Bedingung:** *Objekte der Range liegen in einem Pack, dessen Name nicht mit `pack-`
    beginnt; gemessen ist das an `loose-*.pack`.* Dass es am Namens-Präfix liegt, ist eine
    Vermutung über die git-Bibliothek des Werkzeugs (go-git); im Quelltext nachgelesen ist sie
    nicht.
    Ein zweiter Name stützt die Vermutung. In einem Klon per `git clone --no-local`, dessen
    einziges Pack auf das Präfix `xyz-` umbenannt ist, liest git das Objekt weiter:
    `git cat-file -t 8ae647cc~1:.claude/hooks` ergibt `tree`, und `history-range-guard` löst die
    Range auf. `make adr-immutable RANGE=8ae647cc~1..8ae647cc` bricht dort unter `v0.76.1` trotzdem
    mit make-Exit 2 ab, mit der Meldung
    `Range-Basis "8ae647cc~1" nicht auflösbar: reference not found`; hier liegt auch der Commit im
    umbenannten Pack. Vor der Umbenennung meldet derselbe Klon `0 Befund(e)`, make-Exit 0. Belegt
    ist die Vermutung damit nicht.
  - **Pack-Namen.** Der Arbeitsklon, in dem dieser Eintrag misst, trägt neben Packs mit dem Namen
    `pack-*.pack` auch solche mit dem Namen `loose-*.pack`. Solche Namen vergibt
    `git maintenance run --task=loose-objects` (CHANGELOG `[0.76.1]`, Fremdquelle).
    `ls .git/objects/pack/ | grep -c '^loose-.*\.pack$'` ergibt **5**,
    `ls .git/objects/pack/ | grep -c '^pack-.*\.pack$'` ergibt **2**. Beides sind keine
    Erwartungswerte: Die nächste git-Wartung verschiebt die Zahlen.
  - **Welche Klon-Form solche Packs übernimmt.** Gemessen an einem Wegwerf-Repo nach
    `git maintenance run --task=loose-objects`, je Klon mit `ls .git/objects/pack/`:
    - `git clone <pfad>` (Voreinstellung) übernimmt `loose-*`;
    - `git clone --no-hardlinks <pfad>` übernimmt `loose-*`;
    - `git clone --no-local <pfad>` legt `pack-*` an.
  - **`make adr-immutable RANGE=8ae647cc~1..8ae647cc` im Arbeitsklon.** Unter `v0.76.0` meldet der
    Lauf `0 Befund(e)`, make-Exit 0. Unter `v0.76.1` bricht er mit make-Exit 2 ab:
    `Range-Basis "8ae647cc~1" nicht auflösbar: nicht vollständig lesbarer Tree zu "8ae647cc~1": nicht lesbarer Unterbaum ".claude/hooks": object not found`.
  - **Derselbe Lauf in einem Klon per `git clone --no-local <pfad>`** (`ls .git/objects/pack/`
    nennt dort nur `pack-*`-Dateien) meldet unter beiden Digests `0 Befund(e)`, make-Exit 0.

  **Das `0 Befund(e)` unter `v0.76.0` ist im Arbeitsklon darum kein lesbarer Fall.** Es ist ein
  stiller Durchgang über einem Baum, den das Werkzeug nicht lesen konnte. Tatsächlich geprüft wird
  die Range erst im `--no-local`-Klon. Dort ist sie befundfrei, und `v0.76.1` bestätigt das,
  obwohl es bei einem unlesbaren Unterbaum abbräche.
- **Der `--range`-Abbruch von `commits` hängt am selben Objektspeicher.** Gemessen mit
  `make doc-commits RANGE=HEAD~3..HEAD` beim Kopf `ebb76b3d`, nur unter `v0.76.1`:
  - Im Arbeitsklon bricht der Lauf mit `Range-Basis-Vorfahren nicht lesbar: object not found` ab,
    make-Exit 2.
  - Im `--no-local`-Klon bricht er nicht ab. Er prüft und meldet einen Befund:
    `grep -c 'commit-untraceable'` ergibt **1**, nämlich den `slice-mv`-Commit der Range;
    make-Exit 2.

  Dass die gefüllte `id-patterns`-Liste den Abbruch mitbestimmt, misst
  [`harness/sensors/commit-msg-check.md`](../sensors/commit-msg-check.md) an einem eigenen Stand,
  unter beiden Digests: Mit leerer Liste läuft derselbe Arbeitsklon durch und prüft nichts. Die
  zwei Läufe oben sind davon getrennt.
- **[`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
  Re-Evaluierungs-Trigger 2 (ein Modul des Doku-Gates hält Status und Adress-Form zusammen): nicht
  eingetreten.** Der Sprung bringt kein Modul und keine Bedingung: Das zeigen der Fragment-`diff`
  und die gleichen `--print-config`-Ausgaben oben. Die einzige Verhaltensänderung betrifft, wann
  `vcs` abbricht, nicht was es liest. Der `diff` von `--print-config` **bestätigt** das nur und
  trägt es nicht, denn `--print-config` gibt eine Beispiel-Config aus, keine Schema-Liste
  ([`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)).
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** Die Träger stehen in der
  Strenge-Bilanz oben:
  - In den acht aktiven Regeldateien bewegt sich keine Quellzeile (Quell-Differenz).
  - Kein aktives Modul liest über den geänderten git-Adapter oder VCS-Port (Quell-Lesung).
  - Auf den datei-scannenden Pfaden sind die Befunde aller acht Module gleich, und jedes hat eine
    eigene Basis (Gegenmessung).
  - Die einzige Verhaltensänderung trifft `vcs`, das in keinem Gate läuft, und sie ist eine
    Verschärfung: Aus dem stillen Durchgang wird ein Abbruch, aus der falschen Diagnose ein
    Umgebungsfehler (Wegwerf-Kopie).

  Der CHANGELOG **bestätigt nur** (*„Kein Konfigurations-Bruch, keine Änderung am Grund-Code"*).
- **Emitter-Pin gekoppelt.** `TestDefaultImage_MatchesCanonical` und
  `TestDefaultDigest_MatchesCanonical` lesen `d-check.mk`. Die emittierte Startkonfiguration bleibt
  (`grep -m1 'modules:' internal/emit/templates/d-check.yml` →
  `modules: [links, anchors, ids, matrix, spans]`), und
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  ist nicht berührt.
- **Grenze.**
  - **Liegen Objekte der Range in einem Pack, dessen Name nicht mit `pack-` beginnt, brechen die
    history-lesenden Ziele ab; gemessen ist das an `loose-*.pack`.** Dass es am Namens-Präfix
    liegt, ist eine Vermutung über go-git und im Quelltext nicht nachgelesen. Unter `v0.76.1`
    enden in einem solchen Klon mit make-Exit 2:
    - `make adr-immutable` und das Rezept darunter, `make doc-immutable`: gemessen an einem
      Unterbaum (Meldung `nicht lesbarer Unterbaum`);
    - `make doc-commits`: gemessen an der Vorfahren-Kette der Range (Meldung
      `Range-Basis-Vorfahren nicht lesbar`).

    Der Abbruch sagt dann etwas über den Klon, nicht über den Verlauf; die Meldung nennt
    `object not found`. Keines der drei Ziele ist ein Gate. Dass d-check solche Packs nicht liest,
    ist eine Lücke im Werkzeug eines Nachbar-Repos. Dort ist sie eine Anforderung, keine feste
    Grenze.
  - **Nur ein Klon per `git clone --no-local` ist von solchen Packs frei.** Die Voreinstellung und
    `--no-hardlinks` übernehmen die Pack-Namen der Quelle. Ein frisch angelegter Klon ist darum
    nicht schon deshalb frei davon.
  - **Unter `v0.76.0` bleibt ein solcher Klon still.** Ein `0 Befund(e)`, das ein
    history-lesender Lauf dort unter jenem Stand meldet, sagt nichts aus.
  - **Die Wegwerf-Kopie misst nur eine Stelle**
    ([`MR-055`](../conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)):
    zwei Fälle, einen Unterbaum, einen Objekt-Typ (Baum). Einen unlesbaren Blob stellt sie nicht
    her, und über ihn sagt dieser Eintrag nichts.
  - **Die Grenzen der Gegenmessung aus
    [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
    gelten weiter.** Für Codes ohne Basis trägt allein die Quell-Differenz den Schluss. Einen Pfad
    über den VCS-Port fährt sie nicht; dort trägt die Quell-Lesung.
- **Begründung:**
  - Der Digest ist die Reproduzierbarkeits-Zusage
    ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der Sprung beseitigt
    in `make adr-immutable`, dem Werkzeug für die Immutabilität der ADRs
    ([`AGENTS.md`](../../AGENTS.md) §3.4), einen stillen Durchgang und eine falsche Diagnose.
  - Der Eintrag ist eine **datierte Momentaufnahme**
    ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)):
    Jede Werkzeug-Aussage nennt `v0.76.0` oder `v0.76.1` als Mess-Operand.
  - **Kopf-Marke an
    [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)**
    nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    Setzung 1 und 3. Ein Pin-Eintrag setzt sonst keine (Setzung 4). Dieser löst aber zwei Aussagen
    namentlich ab; dieselbe Lage beschreibt
    [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
    Setzung 3. Die Datei bleibt nach
    [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
    in [`conventions/`](../conventions/).
  - Abgelöst wird die **Einordnung**, nicht der Messwert: MR-061 nennt für beide Läufe weder den
    Klon noch dessen Packs. Ohne diese Angabe ist ein `0 Befund(e)` oder ein Abbruch eine Messung
    an einer Stelle, und sie wird als Eigenschaft der Range oder der Konfiguration gelesen.
  - **Keine Kopf-Marke an MR-063:** Dort ist der fünfte Anker als Literal gezählt, und diese
    Zählung stimmt (Absatz zum Fragment oben).
  - **Keine Kopf-Marke an MR-010 oder MR-062:** Es kommt kein Handgriff hinzu.
- **Auflösungs-Trigger:** permanent. Bei jedem d-check-Release ist `--print-mk` neu zu erzeugen
  und der Digest neu zu pinnen
  ([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  §Auflösungs-Trigger). Die Strenge-Bilanz läuft an den drei Stellen aus dem Auflösungs-Trigger
  von
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv);
  die Gegenmessung folgt
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen).
  Bewegt sich die geteilte Infrastruktur, nennt die Bilanz für jede Aussage ihren Träger; über
  den VCS-Port ist das die Quell-Lesung, nicht die Gegenmessung.
  **Zusätzlich** läuft jeder history-lesende Lauf, der in die Bilanz eingeht, in einem Klon per
  `git clone --no-local` oder nennt die Pack-Namen seines Klons (`ls .git/objects/pack/`). Die
  Grenze ist neu zu prüfen, sobald d-check Objekte in einem Pack liest, dessen Name nicht mit
  `pack-` beginnt.
