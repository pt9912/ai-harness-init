# MR-068 — d-check-Pin v0.77.0 (Instanz-Identitäts-Ausnahme verfügbar, ohne Gegenstand)

- **Datum:** 2026-09-18
- **Wirksamkeits-Anlass:** slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar samt
  Zustandssatz), `internal/emit/emit.go` (emittierter Default-Pin), §Baseline (Zeile
  `d-check:`); setzt
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  fort. Dazu der **Zustandssatz** im Fragment-Kopf über Hunk-Zahl und Handgriffe — seine Form
  setzt
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 (die
  Hunk-Zahl ist kein Maß für die Handgriffe), seine Zustandsaussage misst dieser Eintrag.
  **Nicht** die Modul-Liste der
  [`.d-check.yml`](../../.d-check.yml) und **nicht** die emittierte Startkonfiguration: Dieser
  Sprung aktiviert nichts, und was ins emittierte Gate geht, setzt
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel).
  **Nicht** die Handgriffe der Re-Adaption: Ihre Zahl setzen
  [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 und
  [`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff),
  und es kommt keiner hinzu — dieser Eintrag misst sie nur. **Nicht** die Methode der
  Gegenmessung: Sie setzt
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen).
  **Nicht** die Angabe, die ein history-lesender Lauf trägt: Sie setzt
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1, und jede Messung dieses Eintrags trägt sie. **Nicht** die Reihenfolge, mit der eine
  Aufbau-Anleitung ihre Lage herstellt: Sie setzt
  [`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1, und die Gegenmessung dieses Eintrags trägt ihre Prüf-Bedingung vor ihren
  Kommandos.
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat die Ablösung ein Werkzeug-Release,
  der Sprung dieses Eintrags. Dieselbe Lage beschreibt
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv),
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  und
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst):
  ein Pin-Sprung, der eine Fähigkeit verfügbar macht, ohne etwas zu aktivieren, tritt an keine
  Stelle. Er ist der bewusste Digest-Commit aus
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)
  und die Neu-Erzeugung des Fragments aus
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk`. Das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld.
- **Adaption:** Das gepinnte d-check-Image springt **v0.76.3 → v0.77.0**. Der Digest
  `sha256:3f84502b09af65246fff38b1c3893130050e50581943a0434da95bf68091e337` ist auf den drei
  Wegen aus
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  mit demselben Wert belegt:
  - Pull: `docker pull ghcr.io/pt9912/d-check:v0.77.0`, Zeile `Digest:`;
  - lokaler RepoDigest:
    `docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.77.0`;
  - Manifest: `docker manifest inspect -v ghcr.io/pt9912/d-check:v0.77.0`, Feld
    `Descriptor.digest`.

  Der erste und der dritte Weg brauchen Netz
  ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der **lebende** Pin steht
  in `d-check.mk` und, daran gekoppelt, in `internal/emit/emit.go`. Hier steht, wogegen er
  belegt ist und welchen Sprung er gemacht hat
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
- **Ein Release liegt zwischen den zwei Ständen.** Am lokalen Klon des Werkzeugs:

  ```sh
  D=<maschinen-lokaler Klon des Werkzeugs>
  git -C "$D" for-each-ref --sort=v:refname \
    --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.77*'
  ```

  Die Ausgabe nennt genau `v0.77.0` (2026-09-18). **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Zweck: eine Fähigkeit wird verfügbar, kein Verhalten ändert sich.** Die Beschreibung des
  Releases ist **Fremdquelle** — der CHANGELOG des Klons
  (`git -C "$D" show v0.77.0:CHANGELOG.md | awk '/^## \[0\.77\.0\]/,/^## \[0\.76\.3\]/'`):
  - **`v0.77.0`:** `matrix` bekommt eine **Instanz-Identitäts-Ausnahme für die Token-Form**. Mit
    `allow-if-same-id: true` auf einer Regel wird das bereits vorhandene `token`-Regex der
    beteiligten Klassen zweifach genutzt: wie gewohnt gegen den Fließtext (Fund-Erkennung) und
    zusätzlich gegen den repo-wurzel-relativen Pfad der **Quelldatei** (Instanz-Ermittlung).
    Trägt das Regex genau eine Capture-Gruppe und stimmen Quell- und Ziel-ID überein (getrimmt,
    case-sensitiv), fällt der Fund weg. Die Ausnahme wirkt **ausschließlich** auf die Token-Form
    von `matrix-forbidden`; Link-Referenzen und `matrix-inactive` sind unberührt. Fail-closed am
    Config-Rand: `allow-if-same-id: true` auf einer Regel, deren beteiligte Klassen kein `token`
    mit genau einer Capture-Gruppe tragen, ist Exit 2.
  - Der Anlass des Releases nennt laut derselben Quelle einen Change Request eines
    Adopter-Repos — samt der Kennungen jenes Repos und des Werkzeugs. Der Eintrag übernimmt die
    **Klasse**, nicht die Adressen: *eine Quelldatei zitiert die eigene Instanz eines Ziels*. An
    unserem Bestand ist die Klasse unbelegt (unten gemessen).
  - **Ohne den Schlüssel verspricht das Werkzeug byte-identisches Verhalten** — kein neuer
    Grund-Code an den Regeldateien der übrigen Module, kein Modul kommt hinzu, keine
    Verhaltensänderung wie in
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst).
    Träger ist die Quell-Differenz (nächster Punkt) und der byte-identische Befundbestand über
    beide Digests (Gegenmessung).
- **Das Fragment: sechs Hunks, fünf Handgriffe — und die Pin-Zeile verschmilzt zwei Hunks.**
  - Adaption:
    `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@sha256:3f84502b09af65246fff38b1c3893130050e50581943a0434da95bf68091e337 --print-mk) d-check.mk | grep -c '^[0-9]'`
    ergibt **6**.
  - Anker: Die fünf Anker aus
    [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger
    treffen die `v0.77.0`-Ausgabe je einmal; die Menge des fünften Handgriffs
    ([`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff))
    ist unverändert. **Es kommt kein Handgriff hinzu** — das trägt nicht die Zahl, sondern der
    Fragment-Kopf: Seine nummerierte Liste der fünf Handgriffe ist über den Sprung unverändert,
    und der Pin-Commit bewegt in `d-check.mk` vierzehn Zeilen, alle Kopfkommentar oder Pin
    (`git show --numstat --format= cb3bc567 -- d-check.mk` → **8/6**).
  - **Der Zustandssatz im Kopf.** Der Kopfkommentar trägt seit diesem Sprung den Satz, dass
    dasselbe Zählkommando gegen ein Fragment mit **ungleichem** Tag **5** statt 6 liefert — die
    Pin-Zeile rückt Kopf- und Digest-Block in einen Hunk. Damit hat die Zahl zwischen zwei
    Sprüngen zwei Ursachen, die sie nicht trennt: die Menge des fünften Handgriffs und diese
    Verschmelzung. Wer Hunks zwischen Sprüngen vergleicht, vergleicht beide.

  Die zwei Fragmente des Sprungs unterscheiden sich in genau diesem Diff:
  `diff <(git show cb3bc567^:d-check.mk) d-check.mk | grep -c '^[0-9]'` → **5**.
- **Strenge-Bilanz: jede Aussage mit ihrem Träger.** Am Klon des Werkzeugs (`D` wie oben), nur
  lesend. Die Messwerte stehen im Umsetzungs-Commit `cb3bc567`
  ([`MR-051`](../conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  - **Eine Regeldatei eines aktiven Moduls bewegt sich, und ihre Änderung ist der opt-in-Schlüssel.
    Träger: die Quell-Differenz.**
    `git -C "$D" diff --numstat v0.76.3 v0.77.0 -- internal/hexagon/core/rules/` nennt genau zwei
    Dateien: `matrix.go` (**61/10**) und `matrix_test.go` (**71/0**). `matrix` ist eines der neun
    aktiven Module (`grep -m1 '^modules:' .d-check.yml`), und die Änderung ist die neue
    Fähigkeit — ein Schlüssel, der ohne ihn byte-identisch bleibt; dass nichts senkt, trägt die
    Gegenmessung. Außerhalb von `rules/` nennt
    `git -C "$D" grep -ln 'allow-if-same-id' v0.77.0 -- internal/` genau zwei weitere Dateien:
    den Konfigurations-Parser (`internal/adapter/driven/configyaml/configyaml.go`) und seinen
    Test — der Config-Rand, kein Regel-Code. Keine Regeldatei eines der übrigen acht aktiven
    Module bewegt sich.
  - **An den datei-scannenden Pfaden der neun aktiven Module fällt keine Prüfung weg. Träger: die
    Gegenmessung** (nächster Punkt).
- **Gegenmessung nach
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2.** Prüf-Bedingung vor den Kommandos
  ([`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1): Die Kopie trägt **keinen Objektspeicher** — `git archive` schreibt keinen
  `.git`-Baum —, und der Lauf fährt den VCS-Port nie. Die Angabe nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1 lautet darum je Lauf: kein Objektspeicher, keine Packs, keine Alternates, keine losen
  Objekte.
  - Grundlage ist eine Kopie von `cb3bc567` per `git archive`; gemessen wird netzlos. Die Kopie
    für `v0.76.3` trägt `d-check.mk` aus `cb3bc567^`, die für `v0.77.0` das Fragment aus
    `cb3bc567`.
  - Symlinks als Kontrolle: `git ls-tree -r HEAD .claude/rules/ | awk '$1=="120000"' | wc -l` →
    **10**; in beiden Kopien nach der Marker-Entwertung `find .claude/rules -type l | wc -l` →
    **10** und `find .claude/rules -type f | wc -l` → **0**. Die Entwertung lässt die Symlinks
    stehen.
  - Die Werte gelten für den Pin-Commit `cb3bc567`, diese Digests und diese Sonden.

  | Stufe | `v0.76.3` | `v0.77.0` | `diff` voll |
  |---|---|---|---|
  | unverändert | 1702 Dateien, 0 Befunde | 1702 Dateien, 0 Befunde | — |
  | Marker entwertet | 59 Befunde, Exit 2 | 59 Befunde, Exit 2 | leer |
  | zusätzlich die Sonden | 78 Befunde, Exit 2 | 78 Befunde, Exit 2 | leer |

  **Die Dateizahl ist kein Erwartungswert**; tragend ist die **0** der ersten Stufe und die
  Gleichheit der Befundmengen — volle Zeilen und Verteilung je Grund-Code sind über beide
  Digests identisch (`awk -F'\t' 'NF>=3{print $3}' <befunde> | sort | uniq -c`):
  `anchor-missing` 1, `citation-out-of-range` 1, `closure-note-missing` 1, `closure-note-thin` 1,
  `codepath-missing` 23, `fence-unclosed` 1, `gate-phantom` 1, `gate-undocumented` 1,
  `id-unlinked` 40, `matrix-forbidden` 1, `matrix-inactive` 1, `planning-drift` 1, `repo-escape` 1,
  `section-missing` 1, `section-open-tasks-marker-missing` 1, `span-unclosed` 1, `target-missing` 1.
  Damit hat jedes der **neun** aktiven Module eine Basis; `structure` über
  `section-missing` und `section-open-tasks-marker-missing` (wie in
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)).

  **Schluss: keine Senkung** an einem der neun aktiven Module.
- **Die neue Fähigkeit hat in beiden Konfigurationen dieses Repos keinen Gegenstand.** Träger:
  zwei Messungen.
  - Die Dogfood-[`.d-check.yml`](../../.d-check.yml) führt überhaupt kein `token`
    (`grep -c 'token' .d-check.yml` → **0**).
  - Die emittierte Vorlage führt drei Token-Klassen —
    `sed -n '53p;54p;60p' internal/emit/templates/d-check.yml` nennt `slice`, `welle` und
    `adaptionsblock`, je mit `token:` und Capture-Gruppe — und **vier Token-Form-Regeln**:
    `sed -n '/^  rules:/,/^  status:/p' internal/emit/templates/d-check.yml | grep -cE '\{from: (spec-straten|adr), to: (slice|welle|adaptionsblock)'`
    → **4**. Die Quell-Klassen dieser Regeln sind `spec-straten` mit der Pfad-Menge
    `spec/lastenheft.md`, `spec/spezifikation.md`, `spec/architecture.md` sowie `adr` mit
    `docs/plan/adr/[0-9]*.md`. Keiner dieser Pfade kann eine `slice-`-, `welle-`- oder
    `MR-`-Kennung tragen: Es gibt keine Quelldatei, deren eigene Instanz-ID mit einer gefundenen
    Ziel-ID übereinstimmen könnte.
  - Für die einzige inhaltlich nahe Regel (`spec-straten` → `adaptionsblock`) wäre der Schlüssel
    heute ein Exit-2-Fehler — die Quell-Klasse führt kein `token` mit genau einer Capture-Gruppe
    (Werkzeug-Zusage am Config-Rand, Fremdquelle oben). Ihn zu setzen hieße, den Spec-Straten ein
    Kennungs-Muster zu geben; das ist ein eigener Vorgang mit eigener Begründung.
  - Der Schlüssel wird hier **nicht gesetzt** — ein Opt-in ohne Objekt wäre eine Entscheidung,
    die niemand getroffen hat. Sein Verhalten am Bestand ist darum nicht gemessen; was hier
    gemessen ist, ist der **Gleichstand der Befundmengen** über beide Digests — er ist zugleich
    die byte-identische Verhaltens-Zusage am Messgegenstand.
- **Emitter-Pin gekoppelt.** `TestDefaultImage_MatchesCanonical` und
  `TestDefaultDigest_MatchesCanonical` lesen `d-check.mk`; die Rot-Bedingung ist einmal gefahren
  (Pin nur in `d-check.mk` bewegt → `make test` Exit 1 mit beiden Namen in der Fehlermeldung).
  Die emittierte Startkonfiguration bleibt
  (`grep -m1 'modules:' internal/emit/templates/d-check.yml` →
  `modules: [links, anchors, ids, matrix, spans]`), und
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  ist nicht berührt. Die zwei `--disable`-Kopplungs-diffs im `Makefile` sind leer;
  `grep -m1 '^modules:' .d-check.yml` nennt unverändert neun Module.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** Die Träger stehen in der
  Strenge-Bilanz oben:
  - Die eine bewegte Regeldatei trägt einen opt-in-Schlüssel, der ohne ihn byte-identisch bleibt
    (Quell-Differenz).
  - Auf den datei-scannenden Pfaden sind die Befunde aller neun Module gleich, und jedes hat eine
    eigene Basis (Gegenmessung).
  - Die Fähigkeit hat in beiden Konfigurationen keinen Gegenstand; der Schlüssel wird nicht
    gesetzt.
- **Was der Sprung ausdrücklich nicht löst.** Die zwei Lücken aus
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  stehen unverändert — Träger ist die Quell-Differenz: keine Datei am git-Port bewegt sich, und
  der Befundbestand ist byte-identisch.
  - **Alternates** (Messung 3 dort): ein Klon, der seine Objekte über `alternates` liest, bricht
    weiter ab.
  - **Die leere Range** (Messung 4 dort): `make history-range-guard` behält seinen Gegenstand;
    kein Modul deckt ihn.
- **Grenze.**
  - **Die Sonde für `span-nested-link` blieb stumm** (`grep -c 'span-nested-link' <befunde>` →
    **0**, unter beiden Digests). `spans` trägt seine Basis über `span-unclosed` und
    `fence-unclosed`; über den Code `span-nested-link` sagt die Gegenmessung nichts. Weil die
    Stille unter **beiden** Digests gleich ist, trägt sie keine Aussage über diesen Sprung —
    sie ist eine Lücke im Sonden-Satz
    ([`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)).
  - **Die Gegenmessung fährt den VCS-Port nicht.** Sie läuft über einer `git archive`-Kopie ohne
    `.git`; die Angabe nach
    [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
    Setzung 1 trägt sie je Lauf (Aufbau oben). Der Instanz-Ausnahme am Bestand trägt der
    byte-identische Befundbestand, dass sie nichts bewegt — gesetzt wird sie hier nicht, und ihr
    Verhalten **mit** dem Schlüssel ist am Bestand nicht gemessen.
  - **Die Hunk-Zahl des Fragments ist kein Maß für die Handgriffe** — und seit diesem Sprung
    hängt an ihr die Verschmelzung der Pin-Zeile (Zustandssatz oben). Wer sie zwischen Sprüngen
    vergleicht, vergleicht die Menge des fünften Handgriffs **und** diese Verschmelzung.
  - **Der Eintrag ist eine datierte Momentaufnahme**
    ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)):
    Jede Werkzeug-Aussage nennt `v0.76.3` oder `v0.77.0` als Mess-Operand.
- **Begründung:**
  - Der Digest ist die Reproduzierbarkeits-Zusage
    ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der Sprung macht die
    Instanz-Identitäts-Ausnahme verfügbar; benutzt wird sie hier nicht — sie hat in beiden
    Konfigurationen dieses Repos keinen Gegenstand, und das Setzen wäre eine Entscheidung mit
    Objekt, die niemand getroffen hat.
  - **Keine Kopf-Marke an
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
    (und damit auch nicht neu an
    [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
    oder
    [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)).**
    Fällig wäre sie nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    Setzung 1, wenn dieser Eintrag eine Aussage **namentlich** ablöst. Nichts wird abgelöst: Die
    Aussagen von
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
    sind datierte Momentaufnahmen über `v0.76.1`/`v0.76.3`, seine zwei Lücken stehen unverändert
    (Träger oben), und die Pin-Kette ist genau der Fall der Setzung 4 — ein Pin-Eintrag datiert
    einen Sprung, er löst keine Aussage ab. §Baseline führt die Kette fort; die Zeile `d-check:`
    dieser Sektion bekommt [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand).
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
  Setzung 1, die Prüf-Bedingung einer herzustellenden Lage
  [`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1. **Neu zu prüfen** ist die Fähigkeit, sobald eine Regel einer der zwei Konfigurationen
  eine Quell-Klasse bekommt, deren Pfad eine Ziel-Kennung tragen kann — dann hat
  `allow-if-same-id` einen Gegenstand, und das Setzen ist eine Entscheidung mit Objekt. Die zwei
  Lücken aus
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  tragen ihre Auflösungs-Trigger fort.