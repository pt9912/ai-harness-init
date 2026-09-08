# Review-Report — slice-197: Ventil für eingefrorene Baseline-Adressen, Wächter auf deklarierte Zahl

**Rolle:** Reviewer · **Datum:** 2026-09-08 · **Runde:** 1

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `4fa6679d..e3905ccd` — zwei Commits: `5632ee2b` (Ruhe-Marker aus
  `docs/plan/planning/in-progress/roadmap.md` entfernt, mechanische Folge des Lifecycle-Moves) und
  `e3905ccd` (`.d-check.yml` + `test/ignore-refs-restbreite.bats`).
- **Betroffene `LH-*`:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (ein Gate, das über stumm geschalteter Fläche grün meldet) und
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Deklaration ist eine
  Messung, die ein Nachfolger reproduzieren muss).
- **Referenzierte aktive ADRs:**
  [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (Constraint dieses
  Slice, `Accepted`), [ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
  [ADR-0027](../plan/adr/0027-tote-adresse-in-eingefrorener-adr.md),
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  [ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md),
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
  [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.1, §3.5, §3.6, §3.7, §3.9,
  §3.10.
- **Vorherige Findings am gleichen Modul:**
  [2026-09-07 · ADR-0039/0040](2026-09-07-adr-0039-0040-review.md) (2 HIGH / 6 MEDIUM) und die
  [Bestätigungsrunde](2026-09-07-adr-0039-0040-bestaetigungsrunde.md) (1 MEDIUM). Deren MEDIUM-1
  (der `in:`-Glob auf das Beobachtungs-Register deckt zwei nicht einfrierende Datei-Klassen) ist im
  Slice-Plan §6 als Risiko übernommen und unten nicht erneut gemeldet. Dazu
  [2026-09-05 · slice-177](2026-09-05-slice-177-register-verzeichnis-form-review.md) HIGH-2
  (*„sein Config-Kommentar nennt einen engeren Bereich, als der Eintrag hat"*) — dieselbe Klasse
  wie MEDIUM-1 unten, damit ihr **zweites** Auftreten.
- **Slice-Plan (Repo-Ergänzung):** `slice-197`, gelesen in `in-progress/`.

**Zustand des Baums vor dem Lauf:** `git status --porcelain` leer, `main`, 8 Commits vor
`origin/main`.

**Instrumente dieses Laufs.** Alle Messungen Docker-only ([`AGENTS.md`](../../AGENTS.md) §3.9):
der gepinnte d-check aus `d-check.mk` über synthetischen Sonden-Repos außerhalb des Arbeitsbaums,
und das gepinnte `BATS_IMAGE` über einer `tar`-Kopie des Repos in `/tmp` (`.git` ausgenommen), an
der die Gegenbeispiele gefahren und nach jedem Fall per `cp` zurückgesetzt wurden. Der
Arbeitsbaum ist dabei nicht angefasst worden.

---

## Findings

### HIGH-1 — Der Wächter-Kopf und seine Rot-Meldung nennen `git ls-files`; gelistet wird mit `find`

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (*„Ein Kommentar beschreibt, was da ist"*), §3.6
- `pfad`: `test/ignore-refs-restbreite.bats:32`, `:37`, `:236`
- `befund`: Drei Stellen sagen, der Glob werde über `git ls-files` aufgelöst — der Kopf
  (*„listet den Baum ueber `git ls-files` und summiert die Treffer aller darin gefuehrten
  Dateien"*), die Netzlos-Zeile (*„nur Datei-Lesen und `git ls-files`"*) und die Befund-Zeile
  (*„kein Quell-Baum getroffen (git ls-files liefert nichts)"*). `count_total` fährt
  `find "$dir" -type f` (`:173`), und der Kommentar unmittelbar darüber (`:164`–`:167`) sagt das
  Gegenteil des Kopfes: *„Gelistet wird ueber `find` und nicht ueber `git ls-files`"*. Die Datei
  widerspricht sich damit über den Mechanismus, dessen Wahl den Prüfumfang bestimmt (MEDIUM-2).
  Die dritte Stelle ist die schwerste: Sie wird **nur im Rot** ausgegeben und schickt den Leser
  genau dann zu einem Werkzeug, das nicht gelaufen ist.
- `verifizierbar`: ja, ohne Gate. `make comment-claims` hat `test/**` dauerhaft außerhalb seines
  Prüfbereichs ([`harness/README.md`](../../harness/README.md) §Was `comment-claims` nicht deckt,
  Punkt 2), und kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml) liest
  Kommentare. Belegt durch Lesen plus die Sonde aus MEDIUM-2: eine **untrackte** Datei bewegt die
  Zählung, was unter `git ls-files` unmöglich wäre.
- `klasse`: Kommentar nennt ein anderes Werkzeug, als der Code fährt

### MEDIUM-1 — Die Deklaration misst eine engere Menge, als der Eintrag deckt: der Link auf das bare Verzeichnis

- `kategorie`: MEDIUM
- `quelle`: [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2
  (*„Deckt er mehr, ist er rot: eine Referenz fiele aus der Prüfung, die niemand entschieden hat"*);
  [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `test/ignore-refs-restbreite.bats:152` gegen `.d-check.yml:53`–`:55`
- `befund`: Der Prefix-Zweig zählt nur, was `prefix + "/"` am Anfang trägt; ein Markdown-Link, der
  auf das Vendoring-Verzeichnis **selbst** zeigt, zählt nicht. d-check zählt ihn sehr wohl zur
  Ausnahme: über einem Sonden-Repo mit `refs: ["vendor/**"]` verstummen `](../../vendor)` **und**
  `](../../vendor/)` zusammen mit `](../../vendor/v1/weg.md)`, während der Kontroll-Link ohne
  Präfix als `target-missing` bleibt. Drei zusätzliche bare Links in
  `docs/plan/planning/done/` lassen den Wächter grün und die Deklaration `3` unverändert —
  die Zusage kann für diese Klasse unter keiner Mutation rot werden. Die Config sagt an derselben
  Stelle, die Deklaration beantworte *„wie viele Referenzen ein Eintrag wirklich stumm schaltet"*;
  für diese Klasse tut sie es nicht. **Die Grenze selbst ist richtig gewählt** — sie reproduziert
  das Kommando aus Festlegung 2 (`case … in .harness/baseline/*`) exakt, und ohne sie zählte
  `docs/plan/planning/done/**` gemessen **4** statt 3 (der eine Fall steht in
  `docs/plan/planning/done/slice-120-co-003-wird-vollzogen.md` als Link-Ziel `../../../../.harness/baseline`,
  ohne Segment dahinter);
  falsch ist nicht die Zahl, sondern der Satz darüber. Der Schaden ist heute begrenzt, und das
  gehört dazu: Ein Link auf das existierende Verzeichnis löst auf, ist also ohnehin kein Befund,
  und `make baseline-verify` in `make gates` hält seine Existenz.
- `verifizierbar`: ja — zwei Sonden gegen den in `d-check.mk` gepinnten Digest bzw. das gepinnte
  `BATS_IMAGE`; kein Gate dieses Repos hält beide Seiten gegeneinander.
- `klasse`: Config-Kommentar nennt einen anderen Bereich, als der Eintrag hat

### MEDIUM-2 — Wächter, ADR-Kommando und d-check messen über drei verschiedenen Datei-Mengen, und die Config nennt keine davon

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit);
  [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 2
- `pfad`: `.d-check.yml:133`, `:136`, `:139` gegen `test/ignore-refs-restbreite.bats:173`
- `befund`: Der Wächter zählt über dem **Arbeitsbaum** (`find`, jeder Dateityp, Bind-Mount aus
  `test-bats`), das Kommando neben den Zahlen in Festlegung 2 über dem **Index**
  (`git ls-files`), und d-check über **`.md` minus `scan.ignore`**. Am Stand dieses Laufs fallen
  die Mengen zusammen — für alle drei Bäume ist `find … -type f` gleich `git ls-files`
  (302 / 162 / 284), unter ihnen liegt keine `*.template.md`, und die Deklarationen `33 · 3 · 2`
  reproduzieren mit dem ADR-Kommando exakt. Sie fallen aber nicht **strukturell** zusammen: eine
  untrackte `.md` in `docs/reviews/` mit einem Baseline-Link hebt den Wächter auf `34`, während
  das ADR-Kommando weiter `33` sagt; eine `*.template.md` unter einem der drei Bäume zählte für
  den Wächter und würde von d-check nie gescannt. Die Deklaration steht als blanke Zahl ohne
  Angabe ihrer Bezugsmenge; wer sie nach einem Bump neu misst, hat zwei Kommandos zur Auswahl,
  die verschiedene Antworten geben können, und die Config nennt keines.
- `verifizierbar`: ja — Mengen-Vergleich `find` gegen `git ls-files` je Baum; Sonde mit untrackter
  Datei gegen das gepinnte `BATS_IMAGE` (`34 aufloesende(r) Link(s), deklariert sind 33`).
- `klasse`: Zahl ohne benannte Bezugsmenge

### MEDIUM-3 — Ein `ignore-refs`-Eintrag ohne `refs:`-Zeile fällt lautlos aus beiden Prüfungen

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  die Zusage des ersten Tests an sich selbst
- `pfad`: `test/ignore-refs-restbreite.bats:96` und `:193`–`:214`
- `befund`: `pairs()` gibt eine Zeile erst beim `refs:`-Treffer aus. Trägt ein Eintrag nur
  `- in:`, folgt die nächste `- in:`-Zeile, `src` wird überschrieben, und der Eintrag erscheint in
  keiner Ausgabe — ohne `UNGELESEN`-Marke, weil keine unbekannte Zeilenform auftrat. Der erste
  Test vergleicht `- in:`-Marken der Datei gegen die des Blocks; beide Seiten zählen dieselbe
  fehlende Zeile nicht und bleiben gleich. Gemessen: `refs:` des fünften Eintrags gelöscht →
  beide Tests grün. Damit hält der erste Test seine eigene Zusage nicht, *„eine andere Form wird
  nicht stillschweigend uebergangen: sie waere eine ungemessene Ausnahme"*. Die Folge ist
  begrenzt und das gehört dazu: d-check schaltet für einen `refs`-losen Eintrag gemessen nichts
  stumm, `make docs-check` würde also laut rot — die Blindstelle liegt im Wächter, nicht im Gate.
  Geprüft und **nicht** betroffen sind die drei benachbarten Fehlformen: `refs` in YAML-Blockform,
  Flow-Map-Form `- {in: …, refs: …}` und vertauschte Schlüssel-Reihenfolge fallen alle als
  `UNGELESEN` auf.
- `verifizierbar`: ja — reproduziert an der Repo-Kopie gegen das gepinnte `BATS_IMAGE`.
- `klasse`: Vollständigkeits-Zahn zählt Marken statt Paare

### LOW-1 — Ein Wort im neuen Config-Kommentar macht seinen Satz unlesbar

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7
- `pfad`: `.d-check.yml:124`
- `befund`: *„traegt Adressen in den vendored Baum, die mit jedem Tag-Wechsel **toben**"*. Das Wort
  trägt keine der fünf Kommentar-Klassen und lässt den Satz ohne Aussage; gemeint sein kann nur
  der Zustand *tot*, den der Rest des Absatzes trägt.
- `verifizierbar`: nein — kein Gate liest Kommentar-Prosa; belegt durch `grep -n 'toben'
  .d-check.yml` → eine Fundstelle.
- `klasse`: Kommentar-Satz durch Wort-Korruption ohne Aussage

### LOW-2 — „die vier Paare" nennt fünf Kennungen

- `kategorie`: LOW
- `quelle`: Maintainability; [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  dem Sinn nach (eine Zahl neben ihrer Aufzählung)
- `pfad`: `.d-check.yml:59`
- `befund`: *„die vier Paare MR-021/ADR-0026/ADR-0027/ADR-0030/ADR-0034"* — die Aufzählung führt
  fünf Kennungen. Wer sie als Paar-Liste liest, zählt eines zu viel; wer die Zahl liest, weiß
  nicht, welche der fünf zusammenfallen (`grep -c '^[[:space:]]*-[[:space:]]*in:' .d-check.yml`
  minus die drei neuen ergibt **4**).
- `verifizierbar`: nein — kein Gate zählt Kennungen gegen Zahlwörter.
- `klasse`: Zahlwort und Aufzählung im selben Satz stimmen nicht überein

### LOW-3 — Die Sammel-Meldung des zweiten Tests passt nicht auf den Befund „keine Deklaration"

- `kategorie`: LOW
- `quelle`: Maintainability
- `pfad`: `test/ignore-refs-restbreite.bats:246`–`:251` gegen `:224`
- `befund`: Die Kopfzeile lautet *„Eine ignore-refs-Ausnahme deckt nicht so viele Referenzen, wie
  sie deklariert"* und erklärt danach die zwei Richtungen MEHR und WENIGER. Für den dritten
  Befund-Typ — es gibt gar keine Deklaration — trifft weder Kopfzeile noch Erklärung; gemessen
  steht die Detailzeile *„keine Deckung-Deklaration (# Deckung: N fehlt am Eintrag)"* unter einer
  Kopfzeile, die eine Zahl-Differenz behauptet. Dieser Text erscheint nur im Rot.
- `verifizierbar`: ja — Gegenbeispiel 1 unten, dessen Ausgabe beides nebeneinander zeigt.
- `klasse`: Begründungstext im Rot deckt nicht jeden Befund-Typ, den er sammelt

### LOW-4 — Der Wächter liest jeden Dateityp, d-check nur `.md`

- `kategorie`: LOW
- `quelle`: Maintainability; [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `test/ignore-refs-restbreite.bats:173`
- `befund`: `find "$dir" -type f` filtert keinen Namen; jede Datei unter einem gedeckten Baum geht
  durch dieselbe `](…)`-Regex. Gemessen: eine handgebaute Binärdatei mit der Byte-Folge `](…)`
  unter `docs/plan/planning/done/` hebt die Zählung auf `4` gegen die Deklaration `3`, obwohl
  d-check die Datei nie scannt (Sonde mit `.md`/`.txt`/`.zip`: *1 Datei(en) geprüft*). **Der
  naheliegende Anlass ist dabei gemessen widerlegt**: Ein realer Deflate-Strom über allen
  Markdown-Dateien von `docs/plan/planning/done/` (1 196 625 Bytes) enthält **0** Treffer der
  Wächter-Regex, das kommende `done/<welle-id>/archiv.zip` aus `make archive-welle` ist also kein
  praktischer Fall. Was bleibt, ist der Textdatei-Fall mit anderer Endung; heute liegen unter den
  drei Bäumen nur `.md` und eine `.gitkeep`
  (`find docs/plan/planning/done -type f | sed 's#.*\.##' | sort -u`).
- `verifizierbar`: ja, in beide Richtungen — die Binär-Sonde färbt den Wächter rot, die
  Deflate-Messung entkräftet den Archiv-Anlass.
- `klasse`: Prüfbereich des Wächters weiter als der des Gates, das er beschreibt

### INFO-1 — Der Ruhe-Marker wird im Implementations-Kontext nachgezogen, und dazwischen steht `planning-drift`

- `kategorie`: INFO
- `quelle`: [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  Festlegung 1; [`AGENTS.md`](../../AGENTS.md) §3.10 (nach ihrem Wortlaut **nicht** einschlägig)
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:22` (Commit `5632ee2b`)
- `befund`: Der Ruhe-Marker ist ein derivatives Zustandsfeld; sein Original ist die
  Verzeichnis-Position, die der Planner mit `281a1f79` gesetzt hat. Der Nachzug liegt in einem
  Commit ohne Rollen-Nennung zwischen den Planner-Commits und der Implementations-Arbeit.
  §3.10 bindet allein den **Abschluss** und trägt hier nicht; eine Quelle, die den Marker
  ausdrücklich zuordnet, führt das Repo nicht — deshalb INFO und kein Verstoß. Messbar ist die
  Folge des Zuschnitts: nach `4fa6679d` trägt `in-progress/` einen `slice-*.md` **und** die
  Roadmap den Marker (`git ls-tree --name-only 4fa6679d docs/plan/planning/in-progress/` gegen
  `git show 4fa6679d:docs/plan/planning/in-progress/roadmap.md | grep -c '^Nichts in Arbeit\.$'`),
  also stand `planning-drift` zwei Commits lang auf dem Hauptzweig — verdeckt davon, dass
  `docs-check` in dieser Zeit ohnehin rot war. Die Klasse ist
  [`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  (Stand: verkörpert, mit ausdrücklich benannter Deckungslücke außerhalb der Closure).
- `verifizierbar`: nein — kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml) liest
  Commits, und `make mutate` kennt keine Fehlschlag-Form für einen Commit-Zuschnitt.
- `klasse`: fremdes Rollen-Artefakt im Implementations-Kontext

### INFO-2 — Die Code-Span-Achse der drei neuen Einträge ist heute folgenlos, aber an `scan.ignore` gekoppelt

- `kategorie`: INFO
- `quelle`: [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
  Folgepflicht 2; [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
  §Fitness Function
- `pfad`: `.d-check.yml:28` gegen `:134`–`:141`
- `befund`: Der Top-Level-Schlüssel wird auch von `codepaths` honoriert, und die zwei neuen Bäume
  `docs/plan/planning/done/**` und `docs/plan/planning/observations/**` liegen in
  `codepaths.roots` (`docs/reviews/**` ist dort ohnehin datei-weit ausgenommen). Unter ihnen
  stehen **224** Inline-Code-Nennungen des vendored Baums, davon **19** auf dem gefallenen
  Tag — keine Erwartungswerte, beide wandern mit dem Bestand:

  ```sh
  PS=( 'docs/plan/planning/done/*' 'docs/plan/planning/observations/*' )
  git grep -ohE '`[^`]*\.harness/baseline/[^`]*`'          -- "${PS[@]}" | wc -l   # 224
  git grep -ohE '`[^`]*\.harness/baseline/v6\.0\.0/[^`]*`' -- "${PS[@]}" | wc -l   #  19
  ```

  Gemessen schaltet der neue Eintrag davon **nichts** stumm: über einem
  Sonden-Repo meldet d-check den Kontroll-Pfad als `codepath-missing`, den Baseline-Pfad mit und
  ohne Eintrag gar nicht — weil `scan.ignore` den Baum ausnimmt. Die Deklaration ist damit heute
  vollständig für das, was der Eintrag wirklich deckt. Sie ist es nur, solange
  `.harness/baseline/**` in `scan.ignore` steht; genau das ist der Gegenstand von `slice-201`,
  und dessen Plan nennt die Kopplung.
- `verifizierbar`: ja — Sonde mit und ohne Eintrag gegen den gepinnten d-check.
- `klasse`: gemessene Deckung gilt unter einer Bedingung, die ein anderer Slice bewegt

---

## Nachgefahrene Gegenbeispiele (Auflage des Eingangs)

Alle vier an einer `tar`-Kopie des Repos, je einzeln gefahren und danach per `cp` auf die
Original-Config zurückgesetzt; Basis-Lauf über der unveränderten Kopie ist grün.

| # | Mutation | Ergebnis | gelesene Detailzeile |
|---|---|---|---|
| 1 | `# Deckung: 33` am fünften Eintrag entfernt | **rot** | `docs/reviews/** -> .harness/baseline/**: keine Deckung-Deklaration (# Deckung: N fehlt am Eintrag)` |
| 2 | `33` → `34` | **rot** | `docs/reviews/** -> .harness/baseline/**: 33 aufloesende(r) Link(s), deklariert sind 34` |
| 3 | `33` → `32` | **rot** | `docs/reviews/** -> .harness/baseline/**: 33 aufloesende(r) Link(s), deklariert sind 32` |
| 4 | Null-Paar `0` → `1` | **rot** | `docs/plan/adr/0018-…md -> docs/plan/planning/welle-10-re-baseline.md: 0 aufloesende(r) Link(s), deklariert sind 1` |
| — | Kalibrierung: Null-Paar bleibt `0` | **grün** | beide Tests `ok` |

Fall 4 trägt, was er tragen soll: Der Eintrag mit `0` wird **gezählt** und nicht übersprungen,
sonst bliebe er bei jeder Zahl grün. Die Behauptung des Slice-Plans zu den vier Gegenbeispielen
ist damit nicht übernommen, sondern nachgemessen.

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Die drei neuen Einträge entsprechen der Tabelle aus Festlegung 1 wörtlich.** `in:`-Werte
  `docs/reviews/**`, `docs/plan/planning/done/**`, `docs/plan/planning/observations/**`, alle mit
  `refs: [".harness/baseline/**"]`; kein vierter Baum, kein zweiter `refs`-Wert, damit Festlegung 3
  eingehalten.
- **N-2 — Der baum-weite `refs`-Wert deckt, was Festlegung 1 deckt, und nicht mehr.** Vier Sonden
  gegen den gepinnten d-check: toter Link in den gefallenen Baum aus gedeckter Datei → stumm ·
  toter Link **ohne** Baseline-Bezug aus gedeckter Datei → bleibt rot (`target-missing`) · toter
  Link in den gefallenen Baum aus **nicht** gedeckter Datei → bleibt rot · Nicht-`.md`-Datei →
  wird gar nicht gescannt. Der Schlüssel wirkt ziel-weit und nicht datei-weit, wie die ADR sagt.
- **N-3 — Die Deklarationen reproduzieren am Lauf-Tag.** Das Kommando aus Festlegung 2 liefert
  `docs/reviews 33 · docs/plan/planning/done 3 · docs/plan/planning/observations 2` — identisch
  mit den drei Zahlen in der Config. Die vier bestehenden Paare tragen `1 · 1 · 0 · 1`, und der
  Wächter ist über allen sieben grün.
- **N-4 — Die Arithmetik aus Festlegung 2 geht auf.** 36 Adressen auf dem gefallenen Tag, 1 auf
  dem lebenden, 1 Platzhalter in Inline-Code = 38 = 33 + 3 + 2, je mit `git grep -oE … | wc -l`
  gemessen. Die beiden „Extras" sind die, die die ADR benennt.
- **N-5 — Der Wächter läuft wirklich in `make gates`.** `gates` → `record-gates` → `test` →
  `test-bats` fährt `test/` im gepinnten `BATS_IMAGE`; die zwei Fälle dieser Datei laufen mit
  (9,4 s). Kein halluziniertes Gate.
- **N-6 — Verschachtelte Bäume werden auf beiden Seiten getroffen.** 283 der 284 Dateien unter
  `docs/plan/planning/observations/` liegen zwei Ebenen tief; der eine dort gedeckte tote Link
  steht in `BEO-ALL/<slug>/observation.md` und ist stumm, also honoriert d-check `**` über
  Verzeichnisgrenzen — und `find` tut es ohnehin.
- **N-7 — Kein Lint-Suppression-Verstoß und keine Herkunfts-Prosa in den neuen Zeilen.** Der Diff
  führt weder `//nolint` noch `# shellcheck disable` ([`AGENTS.md`](../../AGENTS.md) §3.2) und
  keine Slice-Nummer und keine Befund-Kennung in einem Kommentar
  ([`AGENTS.md`](../../AGENTS.md) §3.7, Quellen-Klausel); Herkunft steht ausschließlich als
  `ADR-*`-Kennung.
- **N-8 — Der Commit-Zuschnitt folgt dem Plan.** Konfiguration und Wächter liegen in **einem**
  Commit (`e3905ccd`), wie §3 des Plans es begründet; getrennt wäre ein Zwischenstand rot
  gewesen. Die Commit-Message nennt `ADR-0039` und `LH-QA-01`.
- **N-9 — Die Gate-Senkung ist durch eine aktive ADR gedeckt.** Drei neue `ignore-refs`-Einträge
  sind eine Senkung nach [`AGENTS.md`](../../AGENTS.md) §3.5;
  [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) steht auf `Accepted`
  und trägt sie. Der Maßstab-Wechsel des Wächters ist gegenüber den vier bestehenden Paaren keine
  Senkung: `1 · 1 · 0 · 1` ist gleich streng oder strenger als „höchstens 1", und für das
  Null-Paar wird die alte Konstante durch eine Oberschranke ersetzt, die es vorher nicht gab.
- **N-10 — Der Block-Schnitt hält.** Die Prosa-Nennung `"# Deckung: N"` in der Kopf-Erklärung
  (`.d-check.yml:55`) steht in Spalte 0 und damit außerhalb des von `block()` gelesenen Bereichs;
  gezählt werden genau sieben Deklarationen für sieben `- in:`-Zeilen.
- **N-11 — Der `in:`-Glob auf das Beobachtungs-Register ist nicht erneut gemeldet.** Dass er
  `state.md` und die `README.md` mitdeckt, die nicht einfrieren, ist Befund der Vorrunde und im
  Plan §6 als Risiko mit offenem Ausgang geführt; dieser Lauf bestätigt ihn und zählt ihn nicht
  doppelt.

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 1 | HIGH-1 |
| MEDIUM | 3 | MEDIUM-1, MEDIUM-2, MEDIUM-3 |
| LOW | 4 | LOW-1, LOW-2, LOW-3, LOW-4 |
| INFO | 2 | INFO-1, INFO-2 |

**Wiederkehrende Finding-Klasse dieses Laufs:** *Config-Kommentar nennt einen anderen Bereich, als
der Eintrag hat* (MEDIUM-1) — zweites Auftreten, das erste in
[2026-09-05 · slice-177](2026-09-05-slice-177-register-verzeichnis-form-review.md) HIGH-2. Eine
Route ins Beobachtungs-Register läuft über die Closure dieses Slice; die benachbarte, dort schon
geführte Klasse ist `BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`.

## Verdikt

**Der Kern der Arbeit trägt.** Die drei Einträge sind die aus Festlegung 1, der `refs`-Wert
verhält sich gemessen so, wie die Entscheidung ihn begründet, die vier Gegenbeispiele sind
nachgefahren statt geglaubt, und die Deklarationen reproduzieren am Lauf-Tag. Die vom Eingang
besonders benannte Randfalle **trägt ebenfalls**: Die Unterscheidung reproduziert das Kommando aus
Festlegung 2 exakt und verhindert die falsche `4`.

**Blockierend ist ein Befund, und er sitzt nicht in der Logik, sondern in ihrer Beschreibung.**
HIGH-1: Der Wächter sagt an drei Stellen `git ls-files` und fährt `find` — einmal in einem Text,
den nur der rote Lauf ausgibt. Das ist kein Schönheitsfehler, weil MEDIUM-2 zeigt, dass genau
diese Achse den Prüfumfang bestimmt: Wer dem Kopf glaubt, hält untrackte Dateien für ausgeschlossen
und kann die Deklaration nach dem nächsten Bump nicht reproduzieren.

MEDIUM-1 bis MEDIUM-3 sind vor Merge zu klären, nicht weil sie heute etwas durchlassen — jede ihrer
Folgen ist gemessen begrenzt —, sondern weil alle drei dieselbe Form haben: eine Zusage, die weiter
reicht als ihre Messung. Genau dagegen ist dieser Wächter gebaut.

**Nachmessung des eigenen Beitrags.** Dieser Report ist eine neue Datei unter `docs/reviews/` und
geht damit in die Bezugsmenge des fünften Eintrags ein. Er trägt **keinen** Markdown-Link in den
vendored Baum — jede Nennung steht als Inline-Code oder als Kennung —; die Deklaration `33` bleibt
gültig. Der Gate-Lauf nach dem Schreiben steht unten.

**Gate-Lauf nach dem Schreiben dieses Reports:** `make gates` EXIT **0** — die Kette bleibt
grün. `make docs-check` meldet `949 Datei(en) geprüft, 0 Befund(e)` (eine Datei mehr als vor
dem Lauf: dieser Report), und der Breiten-Wächter ist über allen sieben Einträgen `ok`. Kein
Befund dieses Reports ist ein Gate-Rot; alle sind an Sonden gegen die gepinnten Bilder
gemessen, weil kein Gate dieses Repos sie hält.
