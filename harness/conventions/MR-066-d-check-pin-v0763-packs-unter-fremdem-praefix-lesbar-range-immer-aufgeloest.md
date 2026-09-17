# MR-066 — d-check-Pin v0.76.3 (Packs unter fremdem Präfix lesbar, Range immer aufgelöst)

- **Datum:** 2026-09-17
- **Wirksamkeits-Anlass:** slice-d-check-pin-liest-fremde-packs-und-loest-jede-range.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar),
  `internal/emit/emit.go` (emittierter Default-Pin), §Baseline (Zeile `d-check:`); setzt
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  fort. Dazu die Aussagen aus
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  und
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest),
  die `Löst auf` namentlich nennt. **Nicht** die Modul-Liste der
  [`.d-check.yml`](../../.d-check.yml) und **nicht** die emittierte Startkonfiguration: Dieser
  Sprung aktiviert nichts. **Nicht** die Handgriffe der Re-Adaption: Ihre Zahl setzen
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff),
  dieser Eintrag misst sie nur. **Nicht** die Methode der Gegenmessung: Sie setzt
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen).
  **Nicht** die Angabe, die ein history-lesender Lauf trägt: Sie setzt
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1, und jede Messung dieses Eintrags trägt sie.
- **Löst auf:** in
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  in §Grenze den ersten Punkt *„Liegen Objekte der Range in einem Pack, dessen Name nicht mit
  `pack-` beginnt, brechen die history-lesenden Ziele ab …"* — als Aussage über den **gepinnten**
  Stand; und in
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  - den Satz nach der Tabelle *„Die Lagen mit Packs, deren Name nicht mit `pack-` beginnt
    (`loose-*`, `xyz-*`), misst MR-064; sie brechen ab."*;
  - in Setzung 2 den zitierten Wortlaut *„… deren Objekte in Packs mit dem Präfix `pack-` oder
    lose liegen …"*, den die Sensor-Dateien und der Kommentar am `commits`-Block seit diesem
    Sprung um das Präfix `loose-` erweitert führen
    (`grep -c 'Praefix .pack-. oder .loose-.' .d-check.yml` → **1**; kein Erwartungswert,
    [`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
    Setzung 2).

  Die **Regel** beider Setzungen bleibt: Eine Lage außerhalb der gemessenen heißt *ungemessen*,
  nicht frei.
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat die Ablösung ein Werkzeug-Pin, der
  Sprung dieses Eintrags. Dieselbe Lage beschreibt
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
  und
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab):
  Ein Pin-Sprung, der nichts aktiviert, tritt an keine Stelle. Er ist der bewusste Digest-Commit
  aus
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  und die Neu-Erzeugung des Fragments aus
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk`. Das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld.
- **Adaption:** Das gepinnte d-check-Image springt **v0.76.1 → v0.76.3**. Der Digest
  `sha256:2f2f24601251d6b6c1dda13c4a847039a88abfd7e2de508d64180be97bfd2af0` ist auf drei Wegen mit
  demselben Wert belegt:
  - Pull: `docker pull ghcr.io/pt9912/d-check:v0.76.3`, Zeile `Digest:`;
  - lokaler RepoDigest:
    `docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.76.3`;
  - Manifest: `docker manifest inspect -v ghcr.io/pt9912/d-check:v0.76.3`, Feld
    `Descriptor.digest`.

  Der erste und der dritte Weg brauchen Netz
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin steht
  in `d-check.mk` und, daran gekoppelt, in `internal/emit/emit.go`. Hier steht, wogegen er belegt
  ist und welchen Sprung er gemacht hat
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
- **Zwischen den zwei Ständen liegen zwei Patch-Releases.** Am lokalen Klon des Werkzeugs:

  ```sh
  D=<maschinen-lokaler Klon des Werkzeugs>
  git -C "$D" for-each-ref --sort=v:refname \
    --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.76*'
  ```

  Die Ausgabe nennt `v0.76.0`, `v0.76.1`, `v0.76.2` und `v0.76.3`. **Keine Erwartungswerte:** Ein
  weiterer Patch trifft dasselbe Muster
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Zweck: zwei Verhalten ändern sich, verfügbar wird nichts.** Die Beschreibung der zwei
  Releases ist **Fremdquelle** — der CHANGELOG des Klons
  (`git -C "$D" show v0.76.3:CHANGELOG.md | awk '/^## \[0\.76\.3\]/,/^## \[0\.76\.1\]/'`):
  - **`v0.76.2`:** `vcs` und jedes Modul am selben git-Port lesen Objekte auch aus einem Pack,
    dessen Dateiname ein anderes Präfix als `pack-` trägt, sofern das Hash-Suffix gültig und eine
    passende `.idx` vorhanden ist. Ein Pack ohne beides bleibt unsichtbar.
  - **`v0.76.3`:** `vcs` und `commits` lösen eine angegebene Range **immer** auf, auch ohne
    eigenen `vcs:`- bzw. `commits:`-Block in der Konfiguration; eine unauflösbare Range bricht mit
    Exit 2 ab.

  **Neu verfügbar wird nichts.** Der `diff` der zwei `--print-mk`-Ausgaben ergibt mit
  `grep -c '^[0-9]'` genau **1** Hunk, die Zeile `DCHECK_IMAGE`. Damit sind die `--disable`-Listen
  der generierten Recipes über beide Digests gleich, also auch der Modulsatz. Weder `vcs` noch
  `commits` steht in `modules:` (`grep -m1 '^modules:' .d-check.yml`); beide laufen über
  `make adr-immutable`, `make doc-immutable` und `make doc-commits`, und keines der drei ist ein
  Gate.
- **Das Fragment: sechs Hunks, fünf Handgriffe — und die Zahl zählt Hunks.**
  - Unterschied der Werkzeug-Ausgaben: der `diff`-Hunk oben, die Zeile `DCHECK_IMAGE`.
  - Adaption:
    `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@<v0.76.3-digest> --print-mk) d-check.mk | grep -c '^[0-9]'`
    ergibt **6**.
  - Anker: Die fünf Anker aus
    [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger
    treffen die `v0.76.3`-Ausgabe je einmal.

  **Die Hunk-Zahl ist keine Handgriff-Zahl, und sie hat sich ohne diesen Sprung bewegt.**
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  misst am Vorgänger **8**. Den Unterschied trägt der fünfte Handgriff
  ([`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)):
  Er greift an jedem Ziel, dessen `--enable`-Modul in der [`.d-check.yml`](../../.d-check.yml)
  keinen eigenen Top-Level-Block hat, und liefert dort **zwei** Hunks. Seine Menge ist heute ein
  Ziel (`grep -c 'keinen eigenen Block' d-check.mk` → **3**: einmal der Kopftext, zweimal dieses
  Ziel), seit `structure` einen eigenen Block trägt (`grep -c '^structure:' .d-check.yml` → **1**).
  **Keine Erwartungswerte** — beide Zahlen wandern mit der Konfiguration. Dass **kein Handgriff
  hinzukommt**, trägt nicht die Zahl, sondern der Fragment-Kopf: Seine nummerierte Liste der fünf
  Handgriffe ist über den Sprung unverändert, und der Pin-Commit bewegt in `d-check.mk` fünf
  Zeilen, alle Tag oder Digest (`git show --numstat --format= 55c2e641 -- d-check.mk`).
- **Strenge-Bilanz: jede Aussage mit ihrem Träger.** Am Klon des Werkzeugs (`D` wie oben), nur
  lesend.
  - **Keine Regeldatei eines aktiven Moduls bewegt sich. Träger: die Quell-Differenz.**
    `git -C "$D" diff --numstat v0.76.1 v0.76.3 -- internal/hexagon/core/rules/` nennt genau vier
    Dateien: `commits.go`, `commits_test.go`, `vcs.go`, `vcs_test.go`. Keine der neun Regeldateien
    aus der `modules:`-Zeile, die zum Sprung gilt (`grep -m1 '^modules:' .d-check.yml`), steht
    darin, und auch keine der Module, die ein Werkzeug dieses Repos außerhalb von `modules:`
    fährt (`sources`, `tracked`, `citations`).
  - **Was sich sonst bewegt. Träger: dieselbe Differenz.** Geteilte Infrastruktur unter
    `adapter/driven/git/`: `git.go` und das neue `packalias.go`. `Open` baut die Objekt-Storage
    über `packAliasFS`; den Port teilen `vcs`, `commits` und `tracked`. Die Änderung macht Packs
    **sichtbar**, die vorher unsichtbar waren — eine Erweiterung der gelesenen Menge, keine
    Senkung einer Prüfung.
  - **An den datei-scannenden Pfaden der neun aktiven Module fällt keine Prüfung weg. Träger: die
    Gegenmessung** (nächster Punkt).
  - **Die zwei Verhaltensänderungen sind Verschärfungen an Zielen ohne Gate-Anspruch. Träger: die
    vier Messungen** darunter.
- **Gegenmessung nach
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2.** Aufbau:
  - Grundlage ist eine Kopie von `55c2e641` per `git archive`; gemessen wird netzlos. Die Kopie
    trägt kein `.git` und fährt den VCS-Port nie.
  - Die Kopie für `v0.76.1` trägt `d-check.mk` aus `55c2e641^`, die für `v0.76.3` das Fragment aus
    `55c2e641`; die zwei Fragmente unterscheiden sich (`diff | grep -c '^[0-9]'` → **4**).
  - Symlinks als Kontrolle: `git ls-tree -r HEAD .claude/rules/ | awk '$1=="120000"' | wc -l` →
    **10**; in beiden Kopien nach dem `sed` `find .claude/rules -type l | wc -l` → **10** und
    `find .claude/rules -type f | wc -l` → **0**. Die Marker-Entwertung lässt die Symlinks stehen.
  - Die Werte gelten für diesen Commit, diese Digests und diese Sonden.

  | Stufe | `v0.76.1` | `v0.76.3` | `diff` voll |
  |---|---|---|---|
  | unverändert | 1618 Dateien, 0 Befunde | 1618 Dateien, 0 Befunde | — |
  | Marker entwertet | 57 Befunde, Exit 2 | 57 Befunde, Exit 2 | leer |
  | zusätzlich die Sonden | 76 Befunde, Exit 2 | 76 Befunde, Exit 2 | leer |

  **Die Dateizahl ist kein Erwartungswert**; tragend ist die **0** der ersten Stufe und die
  Gleichheit der Befundmengen. Stufe 3, gelesen mit
  `awk -F'\t' 'NF>=3{print $3}' <befunde> | sort | uniq -c`, nennt unter **beiden** Digests
  dieselben Codes mit denselben Häufigkeiten: `anchor-missing` 1, `citation-out-of-range` 1,
  `closure-note-missing` 1, `closure-note-thin` 1, `codepath-missing` 21, `fence-unclosed` 1,
  `gate-phantom` 1, `gate-undocumented` 1, `id-unlinked` 40, `matrix-forbidden` 1,
  `matrix-inactive` 1, `planning-drift` 1, `repo-escape` 1, `section-missing` 1,
  `section-open-tasks-marker-missing` 1, `span-unclosed` 1, `target-missing` 1. Damit hat jedes der
  **neun** aktiven Module eine Basis; `structure` über `section-open-tasks-marker-missing` und
  `section-missing`. Die Spaltenzahl (`awk -F'\t' '{print NF": "$3}' | sort -u`) ist unverändert:
  drei Spalten für `span-unclosed` und `fence-unclosed`, vier für alle übrigen.

  **Schluss: keine Senkung** an einem der neun aktiven Module.
- **Messung 1 — der Dogfood-Fall, an dem
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  abbrach.** Wegwerf-Kopie: `git clone --no-local`, Pack per `git unpack-objects` ausgepackt und
  entfernt, dann `git maintenance run --task=loose-objects`. Angabe nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1 zum Laufzeitpunkt: `ls .git/objects/pack/` nennt nur `loose-8b309a06…`, kein `pack-*`;
  `cat .git/objects/info/alternates` — die Datei fehlt, also keine Alternates;
  `git count-objects -v` nennt `count: 0`, `in-pack: 26634`. Die zwei Zahlen sind keine
  Erwartungswerte.

  | Lauf | `v0.76.1` | `v0.76.3` |
  |---|---|---|
  | `make adr-immutable RANGE=8ae647cc~1..8ae647cc` | Abbruch: `Range-Basis "8ae647cc~1" nicht auflösbar: reference not found`, make-Exit 2 | geprüft: `0 Befund(e)`, make-Exit 0 |
  | `make doc-commits RANGE=c414119b..ebb76b3d` | Abbruch: `Range-Basis "c414119b" nicht auflösbar: reference not found`, make-Exit 2 | geprüft: 1 × `commit-untraceable`, make-Exit 2 |

  **Gegenprobe:** Dieselbe Kopie ohne die `.idx` ihres Packs — dort fehlen die Objekte auch für
  `git` selbst (`git cat-file -t 8ae647cc` → `fatal: Not a valid object name`). `v0.76.3` bricht
  weiter ab, mit derselben Meldung. Der Abbruch bei einer **wirklich** unauflösbaren Objekt-Menge
  bleibt also stehen; was wegfällt, ist der Abbruch über einem lesbaren Pack.
- **Messung 2 — das frisch emittierte Ziel: bis `v0.76.1` ließ ein solches Gate jede Range
  passieren.** Gemessen an einem Ziel ohne `vcs:`- und ohne `commits:`-Block
  (`grep -cE '^(vcs|commits):' .d-check.yml` → **0** im Ziel), am Vorlauf-Wächter vorbei über den
  `docker run`-Aufruf aus dem Rezept des Ziel-Fragments, mit `--range deadbeef..cafebabe`:

  | Modul | `v0.76.1` | `v0.76.3` |
  |---|---|---|
  | `vcs` | `20 Datei(en) geprüft, 0 Befund(e)`, Exit 0 | `error: Range-Basis "deadbeef" nicht auflösbar: reference not found`, Exit 2 |
  | `commits` | `20 Datei(en) geprüft, 0 Befund(e)`, Exit 0 | dieselbe Fehlerzeile, Exit 2 |

  Ein `--enable vcs`/`--enable commits` ohne eigenen Klassen-Block war bis `v0.76.1` ein Lauf, der
  eine erfundene Range still grün meldete — die Klasse aus
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), eine Ebene
  im Werkzeug. `v0.76.3` schließt sie.
- **Messung 3 — Alternates: unverändert, jetzt auf `v0.76.3` datiert.** `git clone --shared`;
  Angabe nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1: `ls .git/objects/pack/` leer, `alternates` nennt den Objektspeicher des Arbeitsklons
  (dort nur `pack-*`), `count: 0`. `make adr-immutable RANGE=8ae647cc~1..8ae647cc` und
  `make doc-commits RANGE=c414119b..ebb76b3d` brechen unter `v0.76.3` **wie** unter `v0.76.1` mit
  make-Exit 2 ab: `Range-Basis "<ref>" nicht auflösbar: reference not found`. Tabellenzeile 5 von
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  gilt unverändert.
- **Messung 4 — die leere Range bleibt blind grün.** Am emittierten Ziel, `--range HEAD..HEAD`,
  ohne Wächter; `git rev-list --count HEAD..HEAD` ergibt in beiden Klonen **0**, der Anlass des
  Wächters liegt also in beiden vor.

  | Aufbau | `doc-immutable` | `doc-commits` |
  |---|---|---|
  | vollständiger Klon | `0 Befund(e)`, Exit 0 (beide Stände) | `0 Befund(e)`, Exit 0 (beide Stände) |
  | flacher Klon (Tiefe 1 über zwei Commits) | `0 Befund(e)`, Exit 0 (beide Stände) | `v0.76.1`: `0 Befund(e)`, Exit 0 · `v0.76.3`: `error: Range-Basis-Vorfahren nicht lesbar: object not found`, Exit 2 |

  Der blinde Grün-Fall der **auflösbaren, aber leeren** Range besteht damit fort, an beiden Zielen.
  Was `v0.76.3` dem Wächter abnimmt, ist die daneben liegende **unauflösbare Vorfahren-Kette** des
  flachen Klons, und nur am Modul `commits`, das die Range über die Vorfahren auflöst.
- **Was der Sprung ausdrücklich nicht löst.** Beides ist gemessen, nicht vermutet:
  - **Alternates** (Messung 3). Ein Klon, der seine Objekte über `alternates` liest, bricht weiter
    ab. Die Lücke steht unverändert und ist auf `v0.76.3` datiert.
  - **Die leere Range** (Messung 4). `make history-range-guard` behält seinen Gegenstand; kein
    Modul deckt ihn.
- **[`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
  Re-Evaluierungs-Trigger 2 (ein Modul des Doku-Gates hält Status und Adress-Form zusammen): nicht
  eingetreten.** Der Sprung bringt kein Modul; das trägt der Fragment-`diff` von einem Hunk oben.
  Die zwei Verhaltensänderungen betreffen, **wann** `vcs` und `commits` die Range auflösen, nicht,
  **was** sie lesen.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** Die Träger stehen in der
  Strenge-Bilanz oben:
  - In den neun aktiven Regeldateien bewegt sich keine Quellzeile (Quell-Differenz).
  - Auf den datei-scannenden Pfaden sind die Befunde aller neun Module gleich, und jedes hat eine
    eigene Basis (Gegenmessung).
  - Die zwei Verhaltensänderungen treffen `vcs` und `commits`, die in keinem Gate laufen, und
    beide sind Verschärfungen: aus dem Abbruch über einem lesbaren Pack wird eine Prüfung
    (Messung 1), aus dem stillen Grün über einer erfundenen Range ein Abbruch (Messung 2).
- **Emitter-Pin gekoppelt.** `TestDefaultImage_MatchesCanonical` und
  `TestDefaultDigest_MatchesCanonical` lesen `d-check.mk`; die Rot-Bedingung ist einmal gefahren
  (Pin nur in `d-check.mk` bewegt → `make test` Exit 2 mit beiden Namen in der Fehlermeldung). Die
  emittierte Startkonfiguration bleibt (`grep -m1 'modules:' internal/emit/templates/d-check.yml`
  → `modules: [links, anchors, ids, matrix, spans]`), und
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  ist nicht berührt. **Messung 2 wirkt trotzdem ins Ziel:** Der Default-Pin wandert mit, und ein
  Ziel, das `vcs` oder `commits` ohne eigenen Block einschaltet, bekommt ab jetzt einen Abbruch
  statt eines stillen Grün.
- **Grenze.**
  - **Gemessen ist das Pack-Präfix an `loose-*.pack`**, nicht an jedem Namen. Die
    CHANGELOG-Bedingung *gültiges Hash-Suffix und passende `.idx`* ist als Fremdquelle
    übernommen; an einem zweiten Präfix (`xyz-*`) ist sie unter `v0.76.3` nicht nachgemessen.
    Eine Lage außerhalb der gemessenen heißt **ungemessen**, nicht frei
    ([`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
    Setzung 2).
  - **Die Alternates-Lücke bleibt** (Messung 3). Keines der drei history-lesenden Ziele ist ein
    Gate. Dass d-check Alternates nicht folgt, ist eine Lücke im Werkzeug eines Nachbar-Repos;
    dort ist sie eine Anforderung, keine feste Grenze.
  - **Die Sonde für `span-nested-link` blieb stumm** (`grep -c 'span-nested-link' <befunde>` →
    **0**, unter beiden Digests). `spans` trägt seine Basis über `span-unclosed` und
    `fence-unclosed`; über den Code `span-nested-link` sagt die Gegenmessung nichts. Weil die
    Stille unter **beiden** Digests gleich ist, trägt sie keine Aussage über diesen Sprung —
    sie ist eine Lücke im Sonden-Satz
    ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)).
  - **Die Gegenmessung fährt den VCS-Port nicht.** Sie läuft über einer `git archive`-Kopie ohne
    `.git`. Für die zwei Verhaltensänderungen tragen allein die vier Messungen, jede an einer
    Stelle
    ([`MR-055`](../conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).
  - **Die Hunk-Zahl des Fragments ist kein Maß für die Handgriffe** (Absatz oben). Wer sie
    zwischen zwei Sprüngen vergleicht, vergleicht auch die Menge des fünften Handgriffs.
- **Begründung:**
  - Der Digest ist die Reproduzierbarkeits-Zusage
    ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der Sprung gibt
    `make adr-immutable` — dem Werkzeug für die Immutabilität der ADRs
    ([`AGENTS.md`](../../AGENTS.md) §3.4) — den Dogfood-Klon zurück, in dem es seit
    [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
    nur abbrach, und nimmt dem emittierten Ziel ein Gate, das jede Range passieren ließ.
  - Der Eintrag ist eine **datierte Momentaufnahme**
    ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)):
    Jede Werkzeug-Aussage nennt `v0.76.1` oder `v0.76.3` als Mess-Operand.
  - **Kopf-Marke an
    [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
    und an
    [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)**
    nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    Setzung 1 und 3. Die Ausnahme aus Setzung 4 für die Pin-Kette greift **nicht**: Abgelöst wird
    nicht ein Messwert, sondern zweimal ein Satz, der **ohne Datum im Präsens** über den
    gepinnten Stand spricht — die `pack-`-Bedingung als Grenze in
    [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
    und der Wortlaut in
    [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
    Setzung 2, den die Sensor-Dateien mitführen. Wer den Block liest, liest beide als geltend.
    Beide Dateien bleiben nach
    [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
    in [`conventions/`](../conventions/): Die Position ist binär und trägt die Teil-Ablösung nicht.
  - **Keine Kopf-Marke an
    [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv),
    [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen),
    [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) oder
    [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff).**
    Der permanente Trigger von
    [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv)
    ist **eingelöst**, nicht abgelöst; die Methode aus
    [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
    ist angewandt und trägt, mit einer Basis mehr, seit `structure` aktiv ist; und es kommt kein
    Handgriff hinzu.
- **Auflösungs-Trigger:** permanent. Bei jedem d-check-Release ist `--print-mk` neu zu erzeugen
  und der Digest neu zu pinnen
  ([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  §Auflösungs-Trigger). Die Strenge-Bilanz läuft an den drei Stellen aus dem Auflösungs-Trigger
  von
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv);
  die Gegenmessung folgt
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen),
  die Angabe je history-lesendem Lauf
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1. Bewegt sich die geteilte Infrastruktur am git-Port, nennt die Bilanz für jede Aussage
  ihren Träger; die Gegenmessung ist dort keiner. **Neu zu prüfen** ist dieser Eintrag, sobald
  d-check Alternates folgt (dann fällt Messung 3) oder ein Modul die **leere** Range abdeckt (dann
  verliert `make history-range-guard` seinen Gegenstand).
