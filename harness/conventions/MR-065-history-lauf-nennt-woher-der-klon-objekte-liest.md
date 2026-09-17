# MR-065 — Ein history-lesender Lauf einer d-check-Bilanz nennt, woher sein Klon die Objekte liest

> **ÜBERHOLT: der Satz nach der Tabelle „Die Lagen mit Packs, deren Name nicht mit `pack-` beginnt (`loose-*`, `xyz-*`), misst MR-064; sie brechen ab.“ und in Setzung 2 der zitierte Wortlaut „… deren Objekte in Packs mit dem Präfix `pack-` oder lose liegen …“ → [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst).** Setzung 1, die Regel von Setzung 2 — eine Lage außerhalb der gemessenen heißt ungemessen, nicht frei —, die Tabelle und ihre Grenzen gelten fort; die Alternates-Zeile ist am Stand `v0.76.3` nachgemessen und bricht dort unverändert ab.

- **Datum:** 2026-09-17
- **Wirksamkeits-Anlass:** slice-d-check-pin-zieht-den-vcs-patch-nach.
- **Geltungsbereich:** die **Angabe**, die ein history-lesender Lauf (`make adr-immutable`, das
  Rezept darunter `make doc-immutable`, `make doc-commits`) trägt, wenn er in die Strenge-Bilanz
  eines d-check-Sprungs eingeht, und die Aussage, in welcher Lage ein solcher Lauf geprüft hat.
  **Nicht** Pin, Digest, Strenge-Bilanz und die übrigen Messungen von
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab):
  Sie gelten fort, ebenso seine Bedingung für den Abbruch. **Nicht** die Sensor-Dateien unter
  [`harness/sensors/`](../sensors/) und der Kommentar am `commits`-Block der
  [`.d-check.yml`](../../.d-check.yml): Sie führen die Bedingung selbst, mit demselben Wortlaut
  wie Setzung 2. **Nicht** `docs/plan/adr/`, wo [`AGENTS.md`](../../AGENTS.md) §3.4 gilt;
  **nicht** die emittierte Ebene.
- **Löst auf:** in
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  - in §Grenze den Punkt *„Frei von solchen Packs ist ein Klon, dessen Packs zum Zeitpunkt des
    Laufs alle mit `pack-` beginnen …"*;
  - im Auflösungs-Trigger den Satz *„Zusätzlich nennt jeder history-lesende Lauf, der in die
    Bilanz eingeht, die Pack-Namen seines Klons zum Laufzeitpunkt (`ls .git/objects/pack/`)."*
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat die Ablösung ein Gegenbeispiel zu
  einer Messung dieses Repos. Dieselbe Lage beschreiben
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  und
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**; das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld. Die Baseline kennt keine Angabe für einen history-lesenden Lauf. Nahe
  liegt
  [`modul-13-quality-gates.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-13-quality-gates.md#hard-rule-doku-disziplin)
  §Hard Rule (Doku-Disziplin): *„Ein Gate ohne seine Grenze behauptet ebenfalls zu viel"*
  (`grep -c 'Ein Gate ohne seine Grenze behauptet ebenfalls zu viel' .harness/baseline/v6.9.0/regelwerk/modul-13-quality-gates.md`
  → **1**), und die Differenz wird dort mit dem Kommando benannt, das den Ausschnitt zeigt. Diese
  Setzung wendet das auf Läufe an, die kein Gate sind, und tritt an keine Stelle.
- **Adaption — Setzung 1, die Angabe.** Ein history-lesender Lauf, der in eine Bilanz eingeht,
  nennt **zum Laufzeitpunkt**, woher sein Klon die Objekte liest, in drei Teilen:
  - **Pack-Namen:** `ls .git/objects/pack/`;
  - **Alternates:** `cat .git/objects/info/alternates`; fehlt die Datei, bestehen keine.
    `git count-objects -v` nennt sie ebenfalls, je als Zeile `alternate:`;
  - **lose Objekte:** `git count-objects -v`, Zeile `count:`.

  Die Pack-Namen allein reichen nicht. Ein Klon, der seine Objekte über Alternates liest, hat kein
  eigenes Pack und bricht trotzdem ab (Tabelle unten).
- **Setzung 2, was „geprüft" heißt.** Der Wortlaut, den auch die Sensor-Dateien und der Kommentar
  in der `.d-check.yml` führen: *„Geprüft hat der Range-Lauf in den gemessenen Klonen ohne
  Alternates, deren Objekte in Packs mit dem Präfix `pack-` oder lose liegen; dass das genügt, ist
  nicht belegt."* Eine Lage außerhalb der Tabelle heißt **ungemessen**, nicht frei.
- **Die Messungen, unter `v0.76.1`.** Der Arbeitsklon und Kopien davon außerhalb des Repos.
  Ranges: `8ae647cc~1..8ae647cc` für `make adr-immutable` und `c414119b..ebb76b3d` für
  `make doc-commits`, sofern die Zelle keine andere nennt. In jeder Zeile liest das git des Hosts
  den Baum (`git cat-file -t '8ae647cc~1:.claude/hooks'` → `tree`); wo `adr-immutable` läuft,
  löst `history-range-guard` die Range auf. Die Zahl in der Spalte `count:`
  (`git count-objects -v`) gilt zum Laufzeitpunkt und ist kein Erwartungswert: Sie wandert mit
  jedem Commit und jeder Wartung.

  | Klon | `ls .git/objects/pack/` | Alternates | `count:` | `adr-immutable` | `doc-commits` |
  |---|---|---|---|---|---|
  | `git clone --no-local` | nur `pack-*` | keine | nicht erhoben | geprüft: `0 Befund(e)`, make-Exit 0 | geprüft: 1 × `commit-untraceable`, make-Exit 2 |
  | derselbe Klon, Pack per `git unpack-objects` ausgepackt und entfernt | leer | keine | 26255 | geprüft: `0 Befund(e)`, make-Exit 0 | geprüft: 1 × `commit-untraceable`, make-Exit 2 |
  | Arbeitsklon nach `git repack -a -d`, Kopf `439731c5` | ein `pack-*`-Pack | keine | 100 | geprüft: `0 Befund(e)`, make-Exit 0 | geprüft: 1 × `commit-untraceable`, make-Exit 2 |
  | `git clone --no-local`, danach ein leerer Commit ohne Kennung | ein `pack-*`-Pack | keine | 1, der neue Commit | nicht gefahren | `RANGE=HEAD~1..HEAD`: geprüft, 1 × `commit-untraceable` auf dem neuen Commit, make-Exit 2 |
  | `git clone --shared` | leer | der Objektspeicher des Arbeitsklons, dort nur `pack-*` | 0 | Abbruch: `Range-Basis "8ae647cc~1" nicht auflösbar: reference not found`, make-Exit 2 | Abbruch: `Range-Basis "c414119b" nicht auflösbar: reference not found`, make-Exit 2 |

  Die zwei Mischungs-Zeilen verteilen die Objekte verschieden. In der Einzel-Commit-Zeile liegt der
  geprüfte Commit lose und sein Vorgänger im Pack. In der Arbeitsklon-Zeile ist nicht erhoben,
  welche Objekte der zwei Ranges lose liegen.

  Die Lagen mit Packs, deren Name nicht mit `pack-` beginnt (`loose-*`, `xyz-*`), misst
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab);
  sie brechen ab.
- **Der Abbruch über Alternates hängt nicht am Mount.** Das Rezept hängt nur das
  Arbeitsverzeichnis ein. Für die Gegenprobe wird derselbe `docker run`-Aufruf genommen, den die
  Rezepte `doc-immutable` und `doc-commits` erzeugen (`make -s -n … | grep '^docker run'`). Er
  bekommt einen zweiten Mount, der den Pfad aus der `alternates`-Datei unter demselben absoluten
  Pfad read-only einhängt. Beide Läufe enden weiter mit Werkzeug-Exit 2 und derselben Meldung. In
  dieser Messung folgt d-check `v0.76.1` den Alternates nicht. Eine Aussage über andere
  Alternates-Formen (relative Pfade, mehrere Einträge) ist das nicht.
- **Grenze.**
  - **Gemessen ist nur, was die Tabelle zeigt:** fünf Lagen, ein Stand (`v0.76.1`), drei Ranges,
    zwei Ziele. Unter `v0.76.0` misst diese Tabelle nichts; was dort gemessen ist, führt
    [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab).
  - **Ungemessen ist die Mischung im Allgemeinen.** Gemessen sind zwei Mischungen aus einem
    `pack-*`-Pack und losen Objekten (Tabelle), nicht jede Verteilung der Range-Objekte auf Pack
    und lose Dateien. Ebenso ungemessen sind `git worktree`, flache Klone (`--depth`), partielle
    Klone (`--filter`) und Submodule. Über sie sagt dieser Eintrag nichts.
  - **Kein Wächter.** Kein `make`-Ziel gibt die Angabe aus. `history-range-guard` löst die Range
    über das git des Hosts auf, das Alternates und Packs jeden Namens liest, und sieht die Lage
    darum nicht: In der Zeile *Alternates* meldet er OK. Träger der Angabe ist der Lauf, der die
    Bilanz zieht.
  - Die drei Kommandos brauchen nur `git`, `ls` und `cat` auf dem Host
    ([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **Was dieser Eintrag nicht anfasst.**
  [`ADR-0053`](../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  führt in Alternative E weiter die Einordnung, `--range` des `commits`-Moduls sei am gepinnten
  d-check unbedienbar, sobald `commits.id-patterns` eine nicht-leere Liste trägt. Diese Einordnung
  löst
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
  ab. Die ADR ist `Accepted` und bleibt nach [`AGENTS.md`](../../AGENTS.md) §3.4 unverändert; ihre
  Entscheidung hängt nicht an diesem Satz. Hier steht nur der Hinweis, keine Korrektur.
- **Begründung:**
  - Die Angabe aus MR-064 sieht eine Lage nicht, die den Abbruch trägt. Ein `--shared`-Klon hat
    kein eigenes Pack und gilt nach ihr als frei, und trotzdem brechen beide Ziele ab. Eine
    Diagnose, die ihren Fall nicht sieht, meldet frei, wo sie nichts weiß. Die Klasse führt das
    Beobachtungs-Register als
    [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../../docs/plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md).
  - MR-064 ist angenommen. Die Korrektur steht darum in einem Folge-Eintrag, und MR-064 trägt die
    **Kopf-Marke** nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    Setzung 1 und 3. Seine Datei bleibt nach
    [`MR-046`](../conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)
    in [`conventions/`](../conventions/).
- **Auflösungs-Trigger:** permanent, solange ein history-lesender Lauf in eine Bilanz eingeht.
  Neu zu prüfen ist die Setzung in zwei Fällen:
  - ein `make`-Ziel gibt die Angabe selbst aus; dann trägt ein Werkzeug, was heute der Lauf trägt;
  - d-check liest nachweislich Alternates und Packs jeden Namens; dann bleibt die Angabe nur noch
    Diagnose.

  Kommt eine neue Lage in die Tabelle, dann in einem neuen Eintrag.
