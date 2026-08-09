# Review — ADR-0015, ADR-0016, ADR-0017 (alle *Proposed*), Bestätigungsrunde mit drei getrennten Verdikten

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Review-Art** | Design-Review (Modul 10 §Drei Review-Arten) — geprüft werden drei Entscheidungen gegen Spec, aktive ADRs und Hard Rules, kein Code-Diff |
| **Rolle** | Reviewer (Modul 10), `.harness/skills/reviewer.md` v1.4.0 — Lauf unter dem Rollen-Typ `reviewer`, frischer Kontext |
| **Modell** | claude-opus-5[1m] |
| **Datum** | 2026-08-09 |
| **Diff/Commit-Range** | `origin/main..HEAD` ist leer; geprüft wird der Stand `fe4d48e`. Relevante Vorgeschichte: `39e8dab` (Teilung 0016/0017), `163be8e`, `52837f0`, `ed64afc` (Ziel-Stand `v5.3.1`), `bbd8437` (ADR-0015 verengt), `fe4d48e`. Baum bei Beginn **und** Ende sauber (`git status --short` leer) |
| **Prüfgegenstand** | `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md` (433 Z.), `docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md` (189 Z.), `docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md` (190 Z.) — je in ihrer Gestalt bei `fe4d48e`, keine davon in dieser Gestalt je geprüft |
| **Gestellte Fragen** | (1) trägt der Kern von ADR-0016 — mechanischer Tag-Tausch = Inhaltsänderung? (2) ist die Gate-Senkung in ADR-0017 wirklich extensional geschlossen, oder ist es derselbe Defekt anders formuliert? (3) weist `modul-08` §*Welche Rolle braucht welche Artefaktklasse* Eigentum zu — dann ist ADR-0015 gegenstandslos? |
| **`LH-*`** | `LH-QA-01` (kein halluzinierter Gate — alle drei ADRs zitieren es selbst), `LH-QA-02` (Reproduzierbarkeits-Klammer, der Tag) |
| **Aktive ADRs** | ADR-0011, ADR-0012, ADR-0013, ADR-0014 **Accepted**; ADR-0015/0016/0017 **Proposed** (`docs/plan/adr/README.md`, Status-Spalte selbst gelesen). Kein Verweis auf eine superseded ADR im Prüfgegenstand — `matrix.status` grün über alle drei |
| **Hard Rules** | `AGENTS.md` §3.1 · §3.4 · §3.5 · §3.6 · §3.7, Wortlaut selbst gelesen |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-09-adr-0016-festlegung-4-bestaetigungsrunde.md` (2 HIGH, 3 MEDIUM, 2 LOW an der Vorgänger-Fassung von ADR-0016); `docs/reviews/2026-08-01-adr-0013-0014-review.md` + `…-bestaetigungsrunde.md`; `docs/reviews/2026-08-03-adr-0012-bestaetigungsrunde-runde-3.md`. **Wiederkehrendes Muster dort:** *Zahl korrekt, Nenner zu eng*. **Wiederkehrendes Muster hier:** *Messung korrekt, Baum weitergezogen* |
| **Regelwerk on-demand** | Regelwerk `v3.5.2` (vendored, adoptiert): `README.md` (Index), `modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill, `modul-08-agentenrollen.md` §Rollen-Regeln + §Konflikt-Pfad als Rollen-Sequenz, `modul-04-architektur-adrs.md`. Ziel-Stand `v5.3.1` aus dem lokalen Kurs-Klon für alle Gegenmessungen |
| **Gate-Lage** | `make gates` **selbst gefahren**, Exit **0**. `make docs-check`: `d-check: 310 Datei(en) geprüft, 0 Befund(e)`. `make baseline-verify`: `v3.5.2 OK — 42 Dateien`. `make mutate` **nicht** gefahren — der Mutations-Treiber kennt keine `docs-check`-Fehlerform; für diese drei Fragen ohne Aussage |

**Prüfmethode.** Jede Zahl der drei ADRs selbst nachgefahren; Kommando und Ausgabe stehen unten.
Jede Abdeckungs-Aussage **rot gesehen** — fünf Sonden im Arbeitsbaum (Tag-Tausch, vier eingeschleuste
Defekte in ADR-0013, eingehender Link mit erfundenem Anker, `matrix`-Quelle, `codepaths.roots` um
`.harness` erweitert), jede einzeln zurückgenommen, `git status --short` nach jeder Rücknahme leer.
Zitat-Prüfungen **normalisiert statt zeilenbasiert**: Markdown-Auszeichnung (`*`, `_`, Backtick)
entfernt, Zeilenumbrüche zu Leerzeichen, Whitespace kollabiert, typographische Anführungszeichen
vereinheitlicht, dann Substring-Test per `grep -qF` **als Here-String** (nicht `printf | grep -q` —
EPIPE unter `pipefail` meldet sonst falsch „nicht gefunden"). Das ist genau die Definition, die
ADR-0016 Festlegung 2 selbst setzt: *Wortlaut ohne Auszeichnung, Whitespace normalisiert.*

**Dieser Report hält sich an ADR-0016 Festlegung 2**, obwohl sie noch nicht bindet: Baseline-Belege
tragen Tag, Dateinamen, Abschnittsnamen und Zitat, keinen `.harness/baseline/<tag>/`-Pfad und keine
Zeilennummer als alleinigen Locator. Ein Rollen-Report ist dort namentlich als Artefakt geführt, das
unveränderlich wird.

---

## Die drei Verdikte

### ADR-0016 — **Kern bestätigt. Annahme blockiert (2 MEDIUM), Aufwand: zwei Sätze.**

Die tragende Aussage hält, und zwar gegen den **echten** Ziel-Tag `v5.3.1`, nicht nur gegen `v5.3.0`
(M-1). Ein mechanischer Tag-Tausch an `modul-07-carveouts.md` Zeile 129 erzeugte nachweislich ein
falsches Zitat, während Zeile 26–29 byte-gleich überlebt. Die daraus abgeleitete Verweis-Form folgt
sauber. **Alle** neun Baseline-Zitate der ADR sind gegen `v5.3.1` verbatim bestätigt (M-3), der
Delta-Beweis reproduziert exakt (M-2), die Verwerfung von Option D reproduziert bis auf die
Klassen-Aufteilung (M-6).

Blockierend ist nichts davon, sondern **zwei Zustandsaussagen, die der Baum überholt hat** (F-1,
F-2). Beide werden mit der Annahme durch `AGENTS.md` §3.4 unerreichbar — genau der Mechanismus,
gegen den diese ADR geschrieben ist. **Empfehlung: nach Korrektur der zwei Stellen annehmen.**

### ADR-0017 — **Trägt. Annahme empfohlen, ohne Vorbedingung.**

Die extensionale Schließung ist **echt und nicht dieselbe Bauart in neuen Worten**. Der Defekt der
Vorgängerfassung war eine *Aufnahme-Regel* (intensional, offen: *„genau die Accepted-ADRs, deren
Markdown-Link ein Tausch tatsächlich bricht"*) — die jetzige Fassung nennt **eine Datei namentlich**,
sagt *„und keine weitere"* und schließt den Analogieschluss ausdrücklich aus: *„jeder zusätzliche
Eintrag ist eine neue Senkung und löst §3.5 erneut aus — auch dann, wenn er dieselbe Bedingung
erfüllt wie dieser."* Damit hängt der Boden an einer Hard Rule statt an einer Prognose. Der zweite
Wachstumspfad der Vorgängerrunde (vier Zeitdokument-Links) ist nicht in diese Liste gewandert,
sondern von ADR-0016 Festlegung 4 anders gelöst — gemessen bleiben nach voller Anwendung **null**
unversorgte Befunde.

Jede Preis-Zahl reproduziert exakt (M-5), die entlastende Aussage („quellenseitig") habe ich **rot
gesehen** (M-4), und der fehlende präzise Knopf ist am gepinnten Werkzeug belegt (M-7). Alle fünf
Befunde der Vorgängerrunde, die auf diese Senkung zielten (H-1, H-2, M-1, M-2, L-1), sind
geschlossen. Zwei LOW bleiben, beide nachziehbar. **Empfehlung: annehmen.**

### ADR-0015 — **Nicht gegenstandslos, Kern bestätigt. Annahme blockiert (2 MEDIUM).**

Die Frage, mit der die ADR steht und fällt, ist gemessen entschieden: `modul-08-agentenrollen.md`
§*Welche Rolle braucht welche Artefaktklasse* weist **kein Eigentum** zu (M-8). Die Achse ist
„welche Artefaktklasse trägt das Urteil einer Rolle" — die Zelle sagt vom Implementer, *„Das Urteil
folgt einem festen Ablauf mit repo-weiten Regeln"*, und die Folge-Aufzählung handelt durchgehend von
der Frage, wann eine Rolle eine Skill-Datei braucht. Konsum, nicht Eigentum. Die Verengung von
`v5.3.1` (*„genau die Artefaktklasse"*) schärft die **Exklusivität dieser Achse**, nicht ihre
Richtung. **Die Lücke ist real, die ADR hat einen Gegenstand.**

Blockierend sind zwei andere Dinge: Festlegung 2 stützt sich auf einen Baseline-Satz, den die
**adoptierte** Baseline nicht trägt (F-5), und die von ADR-0016 Festlegung 3(a) verlangte Form ist
nur teilweise angewandt (F-6). Unter der beschlossenen Reihenfolge `0016` → `0017` → `0015` ist
ADR-0016 zum Annahme-Zeitpunkt **aktiv**; F-6 wäre dann ein Verstoß gegen eine aktive ADR.
**Empfehlung: nach Korrektur annehmen.**

---

## Die Messungen

### M-1 — der Kern von ADR-0016, gegen `v5.3.1` statt gegen `v5.3.0`

```sh
$ diff <(sed -n '26,29p' .harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md) \
       <(git -C /Development/KI/ai-harness-course show v5.3.1:lab/regelwerk/modul-07-carveouts.md | sed -n '26,29p')
                                          # leer -> byte-gleich

$ sed -n '129p' .harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md
- **Gegen "Wenn der Trigger eintritt, lösen wir den Carveout auf":** Realität: er bleibt liegen.
  Deshalb braucht jeder temporäre Carveout einen *Folge-Slice mit ID*, der das Auflösen plant.
  Slice schlägt Memo.

$ git -C … show v5.3.1:lab/regelwerk/modul-07-carveouts.md | sed -n '129p'
  *Implementer* führt `git mv` und Config-Updates aus. Verteilung über
```

Die beiden Referenzen, um die es geht, stehen in ADR-0012 — die eine mit Zitat, die andere ohne:

```sh
$ grep -n "modul-07-carveouts" docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md
71:  … modul-07-carveouts.md:26-29` beschreibt genau …
137:  … modul-07-carveouts.md:129` durch einen Slice ersetzt
157:  … nach `modul-07-carveouts.md:26-29` *de facto* permanent … nach `:105-110` … nach `:21` …
```

**Bestätigt, und die Lehre ist stärker als die ADR sie zieht:** Zeile 157 führt zusätzlich zwei reine
Zeilen-Locatoren (`:105-110`, `:21`) ganz ohne Zitat. Der Bestand liefert also drei Belege für den
Defekt, nicht zwei — die ADR zählt nur die tag-tragenden.

### M-2 — der Delta-Beweis `v5.3.0` → `v5.3.1`

```sh
$ git -C … diff --stat v5.3.0 v5.3.1 -- lab/regelwerk lab/templates
 7 files changed, 14 insertions(+), 13 deletions(-)
$ git -C … diff -U0 v5.3.0 v5.3.1 -- lab/regelwerk lab/templates | grep -cE '^[+-]#{1,6} '
0
$ git -C … diff --name-only v5.3.0 v5.3.1 -- \
    lab/regelwerk/modul-07-carveouts.md lab/regelwerk/grundlagen-harness-dateien.md \
    lab/regelwerk/modul-04-adrs.md lab/regelwerk/modul-02-harness-bootstrap.md \
    lab/templates/harness/conventions/MR-NNN-titel.template.md
                                          # leer -> alle fuenf byte-gleich
$ git -C … ls-tree -r --name-only v5.3.1 lab/regelwerk | wc -l     # 26
$ git -C … ls-tree -r --name-only v5.3.1 lab/templates | wc -l     # 25
$ git -C … ls-tree -r --name-only v3.5.2 lab/regelwerk | wc -l     # 21
```

Den vollen Delta habe ich Zeile für Zeile gelesen. Er ist: eine Stand-Zeile, vier Umbenennungen des
Werkzeugnamens `check-references` → *Referenz-Richtungs-Gate*, eine im ADR-Template, und die
Paraphrase-Reparatur der Artefaktklassen-Tabelle in `modul-08-agentenrollen.md`. **Alle drei Aussagen
der Delta-Tabelle der ADR treffen zu.** Ebenso die Suchraum-Zahl, und sie ist bei beiden Tags gleich:

```sh
$ git -C … grep -nEi 'vendor|\.harness/baseline|<tag>|verbatim|Zitat|zitier|Fundstelle|Belegstelle|Zeilennummer|Verweis-Form|Referenz-Form' v5.3.0 -- lab/regelwerk lab/templates | wc -l   # 64
$ … dieselbe Suche gegen v5.3.1                                                                       # 64
$ … dieselbe Suche gegen v3.5.2                                                                       # 36
```

`grundlagen-referenz-richtung.md` (`v5.3.1`) trägt drei Abschnitte — §*Referenz-Richtung (SDP)*,
§*Referenz-Richtung (SDP): wer darf wen referenzieren*, §*Spec-Straten: mehr als ein Spec-Dokument* —
alle über *wer wen referenzieren darf*, keiner über die Form. **Die Negativ-Aussage der ADR trägt.**

### M-3 — alle Baseline-Zitate von ADR-0016, verbatim gegen `v5.3.1`

Normalisiert wie oben beschrieben (Auszeichnung entfernt, Whitespace kollabiert):

| # | Quelle (`v5.3.1`) | Zitat (gekürzt) | Ergebnis |
|---|---|---|---|
| 1 | `modul-04-adrs.md` | *„Eine ADR mit Status Accepted wird nicht inhaltlich überschrieben."* | **TREFFER** |
| 2 | `grundlagen-harness-dateien.md` | *„Der Zeiger ist kein Zitat. Ein Template, das den Normtext ausschreibt, führt ihn ein zweites Mal — und zwei Fassungen driften."* | **TREFFER** |
| 3 | `modul-02-harness-bootstrap.md` | *„den erledigt das Doku-Gate: Die vendored Baseline liegt im Repo, ihre Dateien sind gültige Link-Ziele"* | **TREFFER** |
| 4 | `modul-02-harness-bootstrap.md` | *„Einmal prüfen, dass `.harness/baseline/` im Prüfumfang liegt; danach automatisch."* | **TREFFER** |
| 5 | `modul-02-harness-bootstrap.md` | *„Weil der Vendoring-Pfad `<tag>`-gescopt ist, liegen alte und neue Form nebeneinander"* | **TREFFER** |
| 6 | `modul-02-harness-bootstrap.md` | *„Das alte Verzeichnis fällt erst, wenn der Review durch ist."* | **TREFFER** |
| 7 | `templates/harness/conventions/MR-NNN-titel.template.md` | *„Ersetzt-Baseline-Regel nennt genau eine Regel der Baseline"* | **TREFFER** |
| 8 | dieselbe Datei | *„als Link mit Abschnitts-Anker in die vendored Fassung; ein Datei-Link benennt keine Regel"* | **TREFFER** |
| 9 | dieselbe Datei | Feld *„Ausgelöst durch Baseline-Stand"* | **TREFFER** |

Das Beispiel im Template lautet
`[…](../../.harness/baseline/<tag>/regelwerk/grundlagen-referenz-richtung.md#spec-straten-…)` — ein
`<tag>`-gescopter lokaler Pfad, wie die ADR sagt. Und der bats-Fall, auf den sich Punkt 4 des
Kontexts stützt, existiert wörtlich: `test/baseline-verify.bats:95` —
`@test "verify: zwei <tag>-Verzeichnisse -> rot (Setzung: ein Tag zur Zeit)"`.

### M-4 — der Tag-Tausch, gefahren (Sonde 1, zurückgenommen)

```sh
$ mv .harness/baseline/v3.5.2 .harness/baseline/v5.3.1 && make docs-check
d-check: 310 Datei(en) geprüft, 21 Befund(e)          # alle target-missing
$ mv .harness/baseline/v5.3.1 .harness/baseline/v3.5.2 && make baseline-verify
baseline-verify: v3.5.2 OK — 42 Dateien
```

| Klasse | Zahl | Fundorte | Ausgang nach ADR-0016/0017 |
|---|---|---|---|
| lebende Artefakte | **16** | `spec/spezifikation.md` 12 · `harness/conventions.md` 4 | Folgepflicht 1: nachziehen |
| §3.4-eingefroren | **1** | ADR-0013 | ADR-0017: `scan.ignore` |
| Zeitdokumente | **4** | `slice-076-…` 2 · zwei Reports je 1 | ADR-0016 Festlegung 4: Adresse entfällt |

**21 = 16 + 1 + 4, ohne Rest.** Beide ADRs rechnen richtig, und **genau einer** der 21 liegt in einem
nach §3.4 eingefrorenen Artefakt.

### M-5 — der Preis der Senkung, über alle fünf Module rot gesehen (Sonden 2–4)

Vier Defekte in ADR-0013 eingeschleust (Anker, Ziel, Codepath, zwei nackte Kennungen) plus eine
Probe-Datei mit **eingehendem** Link auf einen erfundenen Anker in ADR-0013:

```
OHNE scan.ignore-Eintrag:
d-check: 311 Datei(en) geprüft, 6 Befund(e)
  docs/SONDE-eingehend.md:3               …0013-…md#SONDE-anker-gibt-es-nicht   anchor-missing
  docs/plan/adr/0013-…md:212  …/spezifikation.md#SONDE-gibt-es-nicht            anchor-missing
  docs/plan/adr/0013-…md:212  harness/SONDE-fehlt.sh                            codepath-missing
  docs/plan/adr/0013-…md:212  LH-QA-01                                          id-unlinked
  docs/plan/adr/0013-…md:212  MR-007                                            id-unlinked
  docs/plan/adr/0013-…md:212  ../../../harness/SONDE-fehlt.md                   target-missing

MIT scan.ignore-Eintrag:
d-check: 310 Datei(en) geprüft, 1 Befund(e)
  docs/SONDE-eingehend.md:3               …0013-…md#SONDE-anker-gibt-es-nicht   anchor-missing
```

Und `matrix` als Quelle (Link auf das superseded ADR-0001, vor `## Geschichte` eingefügt):

```
OHNE ignore:  311 Datei(en), 7 Befund(e)   docs/plan/adr/0013-…md:205  0001-skelett-distribution.md  matrix-inactive
MIT  ignore:  310 Datei(en), 1 Befund(e)   (matrix-inactive verschwunden)
```

**Fünf Module verlieren die Datei — `links`, `anchors`, `codepaths`, `ids`, `matrix` —, die
Datei-Zahl fällt um genau eins, und die eingehende Kante bleibt bewacht.** Die Preis-Tabelle von
ADR-0017 ist damit vollständig und nicht auf `links` verengt, und die entlastende Aussage
*„`scan.ignore` wirkt quellenseitig"* ist nicht geschlossen, sondern gesehen.

Die Zahlen der Tabelle, einzeln nachgefahren:

```sh
$ F=docs/plan/adr/0013-technik-stratum-als-zielort.md
$ grep -oE '\]\([^)]+\)' "$F" | wc -l                                            # 27
$ grep -oE '\]\([^)]+\)' "$F" | sed -E 's/^\]\(//; s/\)$//' | sort -u | wc -l    # 12
$ …                                                        | sort -u | grep -c '#'   # 5  (4 davon repo-intern)
$ grep -oE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}' "$F" | wc -l          # 18
$ …                                                                | sort -u | wc -l # 8
$ grep -oE '`(\.{1,2}/|spec/|docs/|harness/)[^`]*`' "$F" | sort -u | wc -l       # 4
```

**Alle sechs stimmen aufs Stück.** Ebenso Option C:

```sh
$ für die drei Zeitdokumente:  grep -oE '\]\([^)]+\)' | wc -l   ->  120 · 48 · 17 = 185
```

**185 gegen 27 — der Faktor „siebenmal teurer" ist belegt.**

### M-6 — die Verwerfung von Option D, reproduziert (Sonde 5)

```sh
$ # codepaths.roots: [spec, docs, harness]  ->  [spec, docs, harness, .harness]
$ make docs-check
d-check: 310 Datei(en) geprüft, 44 Befund(e)
$ … | grep -c 'codepath-missing'                     # 44
$ … | cut -d: -f1 | sort -u | wc -l                  # 17 Dateien
```

Klassen-Aufteilung, nach Ziel-Pfad gruppiert — **alle vier Klassen der ADR reproduzieren exakt**:

| Klasse | gemessen | ADR sagt |
|---|---|---|
| entfernter Regelwerk-Cache (`.harness/cache/…`) | 9 + 6 + 5 = **20** | 20 |
| historische Tags (`v3.1.0`, `v3.5.0`, `v3.5.1`) | 5+1+1+1+1+1 = **10** | 10 |
| Pfade im emittierten Zielrepo | 3+3+2+2+1 = **11** | 11 |
| **Vorwärts-Verweise** (`.harness/baseline/v5.3.1/`) | **3** | 3 |

Und **null** Befunde aus der gesuchten Klasse — der gepinnte Tag existiert ja noch. Die Verwerfung
ist gemessen, nicht argumentiert.

### M-7 — der präzise Knopf fehlt wirklich (`--print-config`, gepinnter Digest)

Gefahren gegen `ghcr.io/pt9912/d-check@sha256:fede3d02…`. Der Ausgabe-Block führt Options-Sektionen
für `ids` (`exempt-paths`), `matrix` (`exempt-paths`), `codepaths` (`exempt-paths` **und**
`ignore-refs`), `hostpaths`, `diagrams`, `versions`, `vcs`, `commits`, `planning`, `tracked`,
`targets`, `external`, `sources`, `trace` — **und für `links`/`anchors` überhaupt keine.** Die
Tabelle in ADR-0017 ist am Werkzeug belegt; die Grobheit ist erzwungen, nicht gewählt.

### M-8 — die Frage, an der ADR-0015 hängt: Eigentum oder Achse?

`modul-08-agentenrollen.md` §*Welche Rolle braucht welche Artefaktklasse* (`v5.3.1`), vollständig:

> *„Sechs Rollen heißt nicht sechs Skill-Dateien. Eine Rolle wird über genau die Artefaktklasse
> geführt, die ihr Urteil trägt — und das ist meistens kein Skill:"*
>
> | Artefaktklasse | Wann | Rollen |
> | Template (Slice, Roadmap, ADR) | Das Urteil ist an einem Artefakt verankert … | Planner · Architect |
> | **Briefing (`AGENTS.md` + 8-Schritt-Workflow)** | **Das Urteil folgt einem festen Ablauf mit repo-weiten Regeln.** | **Implementer** |
> | Skill-Datei (`.harness/skills/*.md`) | Das Urteil ist inferential und beruht auf repo-spezifischem Wissen … | Reviewer |
> | keins | Die Prüfgrundlage steht bereits im Slice … | Verifier · Validator |

Darunter folgen drei Aufzählungspunkte, alle über dieselbe Achse: *„Kriterium für eine Skill-Datei:
nicht ‚die Rolle ist wichtig', sondern ohne fixierte Urteilsgrundlage driftet dasselbe Verhalten
zwischen Läufen"* · *„Skills wachsen pro Urteilstyp, nicht pro Rolle"* · *„Zusätzliche Skill-Dateien
für Rollen, die über Template oder Briefing laufen, sind Attrappen"*.

**Verdikt zur Frage: keine Eigentums-Aussage.** Die Spalte *Wann* beschreibt, **woraus** eine Rolle
ihr Urteil bezieht; die ganze Sektion beantwortet, wann eine Rolle eine eigene Skill-Datei braucht.
Der Implementer *liest* das Briefing, er besitzt es nicht. **ADR-0015 ist nicht gegenstandslos.**

Gegenprobe über beide Tags, nach jeder Stelle, die `AGENTS.md` einer Rolle zuordnet:

```sh
$ git -C … grep -nEi 'AGENTS\.md' v5.3.1 -- lab/regelwerk \
    | grep -Ei 'architect|planner|implementer|reviewer|verifier|validator|schreib|besitz|eigent|pflegt|owner'
grundlagen-klassifikation.md:14   | Inferential (LLM-gestützt) | Spec, ADR, AGENTS.md, Skills, … | Reviewer-Agent, …
modul-00-einfuehrung.md:15        …gehört in AGENTS.md oder eine Fitness Function…
modul-01-entwicklungszyklus.md:69 …sonst überschreibt die oft geänderte AGENTS.md still die…
modul-08-agentenrollen.md:157     | Briefing (AGENTS.md + 8-Schritt-Workflow) | … | Implementer |
modul-09-implementierung.md:202   …Eine Hard Rule, die nur in AGENTS.md steht…
modul-16-produktiver-betrieb.md:32 …AGENTS.md beschreibt nur…
```

Der erste Treffer ist die 2×2-Matrix aus §*Die 2×2-Matrix (Böckeler)*: `AGENTS.md` steht als Beispiel
im Quadranten *Inferential · Feedforward*, die Rollen-Agenten im Quadranten *Inferential · Feedback*
— **verschiedene Zellen, keine Zuordnung.** Damit bleibt genau **eine** Stelle, und die ist M-8.
**Die Aussage der ADR — „die eine Stelle … tut es auf einer anderen Achse" — trägt.** Bei `v3.5.2`
existiert die Sektion überhaupt nicht (`modul-08-agentenrollen.md` führt dort sieben Abschnitte, ohne
sie), die Lücke ist dort also noch größer.

### M-9 — die Zitate von ADR-0015, verbatim

| Zitat | `v3.5.2` | `v5.3.1` |
|---|---|---|
| *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als Constraint"* (`modul-08-agentenrollen.md` §Rollen-Regeln) | **TREFFER** | TREFFER |
| *„keine Rolle springt rückwärts in eine vorhergehende, ohne Übergabe-Artefakt"* (§Rollen-Sequenz für einen Slice) | **TREFFER** | TREFFER |
| *„Briefing (`AGENTS.md` + 8-Schritt-Workflow) … Implementer"* | — (Sektion existiert nicht) | **TREFFER** |
| *„Verkörperung \| Planner → Architect → Planner"* (§Rollen-Sequenz für eine Welle, Closure-Schritt 3b) | — | **TREFFER** |
| die vier Fragmente aus `grundlagen-source-precedence.md` §Spec-Stratifizierung | **0 Treffer, Datei existiert nicht** | **TREFFER** |

Und der Anlass, gemessen:

```sh
$ git -C … show v5.3.0:lab/templates/AGENTS.template.md | sed -n '150p'
### 3.7 Ein Kommentar beschreibt, was da ist        # identisch bei v5.3.1
$ git -C … show v5.1.0:lab/templates/AGENTS.template.md | grep -c '^### 3\.7'
0
$ git show -s --format='%h %ad %s' --date=short 95952b1 4aa910a f7f086e
95952b1 2026-08-08 slice-066: die zweite Quelle traegt agent_type …
4aa910a 2026-08-08 roadmap: Kandidat — das Technik-Stratum …
f7f086e 2026-08-08 AGENTS 3.7: ein Kommentar beschreibt, was da ist — als deklarierter Vorgriff
```

**Der gemessene Anlass von ADR-0015 stimmt in jedem Detail.** Ebenso die tragende Hälfte von Option D:

```sh
$ für AGENTS.md, harness/conventions.md, harness/README.md, .harness/skills/reviewer.md:
  grep -c 'Lerneintrag'   ->  0 · 0 · 0 · 0
```

### M-10 — der Ist-Bestand von ADR-0016, gegen `fe4d48e` statt gegen den Mess-Stand

```sh
$ git grep -o "\.harness/baseline/v3\.5\.2/[^ )]*" -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
34                                              # aus 9 lebenden Artefakten -> stimmt
$ git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' -- <dieselben> | wc -l
17                                              # LAUT: spezifikation 12 · conventions 4 · ADR-0013 1 -> stimmt
$ git grep -h "\.harness/baseline/v3\.5\.2/" -- <dieselben> | sed -E 's/\]\([^)]*\)//g' \
    | grep -o "\.harness/baseline/v3\.5\.2/[^ )\`]*" | wc -l
17                                              # STILL -> Summe stimmt, Aufschluesselung nicht:
```

| Datei | gemessen | ADR-0016 sagt |
|---|---|---|
| `harness/conventions.md` | 7 | 7 |
| ADR-0012 | 3 | 3 |
| ADR-0014 | 2 | 2 |
| `spec/spezifikation.md` | 1 | 1 |
| ADR-0011 | 1 | 1 |
| **ADR-0015** | **0** | **1** |
| `welle-09-…md` · `slice-083-…md` · `slice-071-…md` | **3** | *„zwei Plandateien"* |

Ursache: `bbd8437` hat die Nennung aus ADR-0015 entfernt (vorher `…/regelwerk/modul-08-agentenrollen.md`
in Zeile 25 sowie ein Tabelleneintrag). **Der Summenwert 17 hält, die Zusammensetzung nicht** — und
mit ihr fällt die Zustandsaussage in Festlegung 3 (→ F-1).

### M-11 — was `git grep` zu zwei weiteren Zahlen sagt

```sh
$ git grep -c 'check-references' -- ':!.harness/baseline'
docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:1        # ADR sagt: "-> 0 eigene Vorkommen"

$ git grep -oE '\]\([^)]*0013-technik-stratum-als-zielort\.md[^)]*\)' \
    -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
22                                                          # aus 11 Dateien; ADR sagt: 16 aus 10
$ dasselbe ohne ADR-0016 und ADR-0017                       # 17 aus 9
$ Token-Zaehlung 'ADR-0013' statt Links                     # 24 aus 11  (bzw. 17 aus 9)
```

Keine Zählweise reproduziert `16 aus 10`.

---

## Findings

### ADR-0016

#### F-1 — MEDIUM · `AGENTS.md` §3.4, `LH-QA-02` · `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:62-63` **und** `:291-296`

Zwei Stellen behaupten im Indikativ einen Zustand, den der Baum bei `fe4d48e` nicht mehr hat.
§Kontext führt ADR-0015 in der Aufschlüsselung der stillen Hälfte (*„je 1 in `spec/spezifikation.md`,
ADR-0011, ADR-0015 und zwei Plandateien"*); §Entscheidung Festlegung 3 sagt *„[ADR-0015] steht auf
Proposed und **trägt** eine Inline-Nennung in der von Festlegung 2 verbotenen Form"* und leitet daraus
den ersten Anwendungsfall ab. Gemessen (M-10): ADR-0015 trägt **null** solcher Nennungen — `bbd8437`
hat sie entfernt —, und es sind **drei** Plandateien, nicht zwei. Der Satz *„ihre Zitate überstehen
den Sprung (gemessen … je 1 Treffer bei `v3.5.2` und `v5.3.0`)"* gilt zudem nur noch für zwei der
vier Belege: das dritte und vierte Zitat von ADR-0015 stammen aus `grundlagen-source-precedence.md`,
einer Datei, die es bei `v3.5.2` nicht gibt (M-9).

**Failure-Szenario:** ADR-0016 wird angenommen und ist damit nach §3.4 unveränderlich. Ein Leser der
Regel geht zum namentlich benannten „ersten Anwendungsfall", um zu sehen, wie die Form angewandt
wurde, und findet dort weder die verbotene Form noch eine Spur davon. Er kann nicht unterscheiden, ob
der Träger gegriffen hat oder ob die Behauptung falsch war — und beide ADRs sind dann eingefroren.
Das ist exakt der Defekt, gegen den diese ADR geschrieben ist: ein unveränderliches Artefakt, dessen
Aussage die Quelle nicht deckt.

**verifizierbar:** nein durch Gate — die Nennung ist stumm (`codepaths.roots` führt `.harness` nicht).
Reproduzierbar über die drei `git grep`-Kommandos aus M-10.

#### F-2 — MEDIUM · `MR-020`, ADR-0014 · `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:155-157`

Der Nachweis, dass der Adaptions-Eintrag der Ziel-Fassung Festlegung 2 nicht widerspricht, ruht auf
einem Klammersatz über die Mechanik dieses Repos: *„der Adaptions-Eintrag ist ein **lebendes**
Artefakt (er wandert bei Auflösung per `git mv` nach `done/`)"*. Gemessen: `harness/` enthält
`conventions.md`, `README.md`, `tools` — kein `done/`. Ein aufgelöster Eintrag wandert nirgendwohin;
`MR-020` regelt ihn **am Ort**: *„der Rumpf eines vollständig aufgehobenen Eintrags wird entfernt. Es
bleiben stehen die Nummer, die Überschrift wörtlich (sie ist der Anker), das `Datum` und eine Zeile
mit dem aufhebenden Eintrag"* — belegt an `MR-018`, das seit `MR-021` genau so dasteht. `git mv` nach
`done/` ist der Lifecycle der **Slice-Dateien**, nicht der der MR-Einträge.

**Failure-Szenario:** die Schlussfolgerung („lebend, also lokaler Pfad erlaubt") ist richtig, aber aus
anderem Grund — weil MR-Einträge in `harness/conventions.md` liegen und der Bump deren vier
Baseline-Links ohnehin nachzieht (M-4). Wer den Klammersatz nach der Annahme als Repo-Mechanik liest
und danach handelt, sucht ein Verzeichnis, das es nicht gibt, oder folgert, aufgelöste Einträge seien
vom Nachziehen ausgenommen. Nach §3.4 ist der Satz dann nicht mehr korrigierbar.

**verifizierbar:** nein durch Gate — ablesbar an `ls harness/` gegen den Klammersatz.

#### F-3 — LOW · `LH-QA-02` · `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:198`

Die Delta-Tabelle beziffert die Kosten der Werkzeug-Umbenennung mit
`git grep -c 'check-references' -- ':!.harness/baseline'` → **0** eigene Vorkommen. Gefahren liefert
das Kommando eine Zeile: die ADR selbst (M-11). Die Aussage („dieses Repo benutzt den alten Namen
nirgends") bleibt wahr, das gedruckte Kommando reproduziert seine gedruckte Ausgabe nicht.

**verifizierbar:** ja — das Kommando selbst.

#### F-4 — LOW · `LH-QA-02` · `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:333` und `docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md:125-126`

Beide ADRs führen *„**16** Verweis-Vorkommen aus **10** lebenden Dateien"* auf ADR-0013 — in ADR-0016
als Preis von Option E, in ADR-0017 als Obergrenze des entlastenden Arguments. Gemessen (M-11): 22 aus
11 als Markdown-Links, 24 aus 11 als Kennungs-Token; ohne die zwei neuen ADRs je 17 aus 9. Keine
Zählweise ergibt 16/10. Beide Argumente werden dadurch **stärker**, nicht schwächer.

**verifizierbar:** ja — `git grep -oE '\]\([^)]*0013-…\.md[^)]*\)' -- <Pathspecs> | wc -l`.

#### F-5 — INFO · Nebenbefund zur Genauigkeit

*„`modul-04-adrs.md` trägt die Accepted-Hard-Rule … und kein Wort über Verweise"*: die Datei enthält
bei `v5.3.1` einen Treffer auf *Verweis* — *„explizitem Verweis auf die abgelöste oder geschärfte
Vorgängerin"*, also Supersede-Provenance, nicht Verweis-**Form**. Die Substanz der ADR-Aussage bleibt
unberührt; nur *„kein Wort"* ist wörtlich zu viel gesagt.

### ADR-0017

#### F-6 — LOW · `LH-QA-02` · `docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md:47` gegen `:111`

Das Dokument trägt zwei unvereinbare Datei-Zahlen desselben Werkzeugs, ohne sie zu datieren: §Kontext
nennt für den Tausch-Lauf `309 Datei(en) geprüft, 21 Befund(e)`, §Konsequenzen für den Ignore-Lauf
`308 → 307`. Beide stammen aus verschiedenen Baumzuständen (zwischen ihnen entstand unter anderem
diese ADR selbst); heute misst derselbe Tausch **310** und derselbe Ignore-Lauf **311 → 310** (M-4,
M-5). Die Geschichte begründet die Tag-Datierung der Sonde ausdrücklich, die Datei-Zahlen nicht.
**Der Delta „fällt um eins" reproduziert exakt und trägt das Argument** — die Absolutzahlen tragen es
nicht und altern.

**verifizierbar:** ja — `make docs-check` mit und ohne Eintrag.

#### F-7 — INFO · `docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md:117`

Die `ids`-Zeile der Preis-Tabelle druckt ihr Kommando als
`grep -oE 'ADR-[0-9]{4}\|LH-[A-Z]{2}-[0-9]{2}\|MR-[0-9]{3}'`. Die Backslashes sind
Markdown-Tabellen-Escaping; in ERE ist `\|` ein literales Pipe-Zeichen, das Kommando liefert wörtlich
kopiert **0**. Mit `|` liefert es 18 (8 eindeutig) — genau die Zahlen der Tabelle (M-5). Kein Defekt
der Entscheidung, aber eine Falle für den, der nachmisst.

### ADR-0015

#### F-8 — MEDIUM · `AGENTS.md` §3.4, `MR-000`, `MR-015` · `docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md:46-65` und `:111-112`

Festlegung 2 rechtfertigt sich mit einer Herkunft: *„Das ist kein neuer Mechanismus, sondern der Satz
aus `grundlagen-source-precedence.md` §Spec-Stratifizierung, angewandt auf zwei Artefakte, für die die
Baseline ihn nicht ausspricht."* Gemessen trägt die **adoptierte** Baseline diesen Satz nicht:

```sh
$ git -C … grep -c "Fallen Auftraggeber- und Entwickler-Rolle zusammen" v3.5.2 -- lab/regelwerk
(0 Treffer)
$ grep -rl "Fallen Auftraggeber" .harness/baseline/v3.5.2/
(0 Treffer)
$ für jeden Tag: ls-tree | grep -c grundlagen-source-precedence
v3.5.2 0 · v3.6.0 0 · v3.7.0 0 · v3.8.0 0 · v4.0.0 0 · v4.1.0 1 · … · v5.3.1 1
```

Die Datei entsteht erst bei `v4.1.0`. Die ADR nennt ihren Tag (`v5.3.1`) ehrlich — sie sagt aber
nirgends, dass dieser Tag zum Annahme-Zeitpunkt **nicht adoptiert** ist, und ihr §Kontext trägt die
Überschrift *„Was die Baseline regelt"*, ohne zwischen adoptierter und angezielter Baseline zu
trennen; im selben Abschnitt steht daneben ein `v3.5.2`-Beleg. Hinzu kommt die Richtung: die
Konstruktion steht seit dem 2026-07-26 als `MR-015` Setzung 1 und 2 im Repo, dort ausdrücklich als
**eigene Setzung** formuliert (*„hier war zu entscheiden"*), abgeleitet aus einem *anderen* Absatz der
damaligen Baseline. Dieses Repo hat die Konstruktion nicht von der Baseline übernommen; der Upstream
führt sie später.

**Failure-Szenario:** ADR-0015 wird angenommen und nach §3.4 eingefroren. Verschiebt sich die
Re-Baseline, wird sie auf ein anderes Ziel geschnitten oder fällt sie aus, begründet eine permanente
Norm ihre zweite Festlegung dauerhaft mit einem Baseline-Text, den das Repo nie adoptiert hat — die
gespiegelte Form genau des Schadens, den die ADR in §Anlass als ihren dritten gemessenen Fall führt
(*„eine Norm samt Adaptions-Eintrag, die eine Abweichung von der Baseline behauptet, die es nicht
gibt"*). Fehlend ist nicht die Messung, sondern **ein Satz, der die Abhängigkeit deklariert** — die
Bauart, die ADR-0016 vormacht (*„Grenze: dieser Nachweis deckt nur den Schritt `v5.3.0` → `v5.3.1`"*).

**verifizierbar:** nein durch Gate — reproduzierbar über die drei Kommandos oben.

#### F-9 — MEDIUM · ADR-0016 Festlegung 2/3(a) · `docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md:43`, `:105`, `:127`, `:131`, `:189`

ADR-0016 benennt ADR-0015 als **ersten Anwendungsfall** von Träger (a) und verlangt: *„Bevor der
Status eines ADR auf Accepted wechselt, werden seine Baseline-Belege in die Form aus Festlegung 2
gebracht."* Der Pfad-Beleg ist gezogen (M-10), fünf weitere Baseline-Belege sind es nicht — sie
tragen weder Tag noch Dateinamen noch Zitat:

| Ort | Text | fehlt |
|---|---|---|
| `:127` (Option A) | *„Modul 10 §Pflege verlangt nach der dritten Wiederholung einen Träger"* | Tag, Dateiname, Zitat |
| `:189` (Geschichte) | *„eine Reviewer-Eskalation nach Modul 10 §Pflege"* | dito |
| `:43` (Kontext) | *„ein Eintrag des Adaptions-Blocks aus dem Freshness-Audit nach Modul 2"* | Tag, Dateiname, Abschnittsname |
| `:131` (Option E) | *„der Freshness-Audit nach Modul 2 … nennt **keine** Rolle"* | dito |
| `:105` (Entscheidung) | *„für die ADR spricht Modul 8 genau diese Dreiteilung aus"* | Abschnittsname (Zitat steht bei `:24-26`) |

**`§Pflege` ist zudem kein Abschnittsname.** Die Regel steht bei `v3.5.2` als Aufzählungspunkt in
`modul-10-review-harness.md` §*Ziel-Form: Reviewer-Skill*: *„Pflege (Steering-Loop): bei dreimaligem
gleichem Finding Klassifikation schärfen / Folge-ADR bzw. `AGENTS.md`-Update / Gate (Modul 13)."*
Festlegung 2 verlangt ausdrücklich *„den Regelwerks-Dateinamen und den Abschnittsnamen"* — ein
erfundener Abschnittsname ist genau die Adresse, deren Verfall die Regel verhindern soll.

**Failure-Szenario:** unter der beschlossenen Reihenfolge (`0016` → `0017` → `0015`) ist ADR-0016 beim
Statuswechsel von ADR-0015 **aktiv**. Eine Annahme in dieser Fassung setzt eine ADR auf *Accepted*,
die eine aktive ADR verletzt, und §3.4 sperrt die Reparatur — die Kosten steigen von fünf Zeilen auf
eine Folge-ADR. Genau diese Rechnung stellt ADR-0016 selbst auf.

**verifizierbar:** nein durch Gate — der Form-Sensor aus ADR-0016 Fitness Function ist nicht gebaut;
ablesbar am Textabgleich der fünf Stellen gegen Festlegung 2.

#### F-10 — LOW · `LH-QA-02` · `docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md:130`

Option D verwirft den Lerneintrag als Träger mit *„die drei kanonischen Lehr-Formen stehen **57**-mal
in **32** Dateien unter `docs/plan/planning/done/`"*. Die drei Formen werden nicht genannt und kein
Kommando angegeben; keine naheliegende Zählung reproduziert das Paar:

```sh
$ grep -rhoE 'Lehre'                     docs/plan/planning/done/ | wc -l   # 40, 27 Dateien
$ grep -rhoiE 'Lehre|Gelernt|Erkenntnis' docs/plan/planning/done/ | wc -l   # 50, 34 Dateien
$ grep -rhoE  'Lehre|Gelernt|Erkenntnis' docs/plan/planning/done/ | wc -l   # 42, 28 Dateien
```

Die **tragende** Hälfte derselben Zelle — *„das Wort Lerneintrag kommt in vier Dateien nullmal vor"* —
reproduziert dagegen exakt (M-9), und sie allein trägt die Verwerfung. Der unbelegbare Teil ist die
Größenordnung, nicht das Argument.

**verifizierbar:** ja, sobald die drei Formen benannt sind.

#### F-11 — INFO · `docs/plan/adr/0015-rollen-eigentum-an-norm-artefakten.md:94-96`

Festlegung 1 sagt *„sie bestätigt keine fremde Zuordnung und setzt keine neue"* — gemeint sind die
übrigen Norm-Artefakte. Für die zwei benannten überschneidet sie sich mit Closure-Schritt 3b, den der
Kontext korrekt zitiert: dessen Träger ist *„Planner → Architect → Planner"* und sein Übergabe-Artefakt
*„verkörperte Regel (Hard Rule · Gate · Skill · `MR`)"* — also für den Steering-Loop-Weg bereits eine
Architect-Zuordnung auf genau diese zwei Artefaktklassen. Kein Widerspruch (beide sagen *Architect*),
aber Festlegung 1 **bestätigt** dort eine fremde Zuordnung, statt nur eine Lücke zu füllen. Die ADR
grenzt das in Option E richtig ab; die Entscheidung selbst sagt es nicht.

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Kern von ADR-0016.** Gegen `v5.3.1` gemessen, nicht gegen `v5.3.0` übernommen: Zeile 26–29
  byte-gleich, Zeile 129 unverwandt (M-1). Die Ableitung „mechanischer Tausch = Inhaltsänderung"
  trägt, und die Form (Tag · Dateiname · Abschnittsname · Zitat; kein lokaler Pfad, keine Zeilennummer
  als alleiniger Locator) folgt aus ihr ohne Sprung.
- **N-2 — Delta-Schluss statt Wiederholung.** 7 Dateien, 14/13 Zeilen, **0** Überschriften im Delta,
  fünf tragende Quellen byte-gleich, `modul-08-agentenrollen.md` in den Zeilen 1–149 byte-gleich
  (M-2). Die Entscheidung, die 64-Treffer-Lektüre nicht zu wiederholen, ist **belegt**, nicht bequem.
- **N-3 — Baseline-Zitate von ADR-0016.** Alle neun verbatim bestätigt (M-3), keines paraphrasiert,
  keines aus einer Datei, die die Ziel-Fassung nicht führt.
- **N-4 — extensionale Schließung von ADR-0017.** Eine namentlich genannte Datei · *„und keine
  weitere"* · ausdrücklicher Ausschluss des Analogieschlusses. Der Boden ist eine Hard Rule, keine
  Prognose. Der zweite Wachstumspfad (Zeitdokumente) läuft über ADR-0016 Festlegung 4 und nicht in
  diese Liste: 16 + 1 + 4 = 21 ohne Rest (M-4). **Der Defekt der Vorgängerfassung ist behoben, nicht
  umformuliert.**
- **N-5 — Preis von ADR-0017, rot gesehen.** Fünf Module, nicht eines; Datei-Zahl fällt um genau
  eins; eingehende Kanten bleiben bewacht (M-5). Alle sechs Preis-Zahlen und die 185/27-Rechnung von
  Option C stimmen aufs Stück.
- **N-6 — die Grobheit ist erzwungen.** `links` und `anchors` tragen im gepinnten Werkzeug **keine**
  Options-Sektion, während `codepaths`/`ids`/`matrix` `exempt-paths` führen und `codepaths`
  zusätzlich `ignore-refs` (M-7). Kein Wunsch, ein fehlender Knopf.
- **N-7 — Verwerfung von Option D.** 44 Befunde in 17 Dateien, **null** aus der gesuchten Klasse,
  alle vier Klassen exakt reproduziert, darunter die 3 Vorwärts-Verweise (M-6). Die stille Hälfte
  bekommt so wirklich keinen Sensor.
- **N-8 — Kern von ADR-0015.** `modul-08-agentenrollen.md` §*Welche Rolle braucht welche
  Artefaktklasse* (`v5.3.1`) weist kein Eigentum zu; die zweite Kandidaten-Stelle
  (`grundlagen-klassifikation.md` §*Die 2×2-Matrix*) tut es ebenfalls nicht — `AGENTS.md` und die
  Rollen-Agenten stehen in **verschiedenen Quadranten** (M-8). **Die Lücke ist real.**
- **N-9 — Anlass von ADR-0015.** Alle drei Commits existieren mit dem genannten Datum, und die
  materialisierte Falschaussage ist am Upstream belegt: `v5.3.0:lab/templates/AGENTS.template.md`
  Zeile 150 trägt `### 3.7 Ein Kommentar beschreibt, was da ist`, bei `v5.1.0` **0** Treffer (M-9).
- **N-10 — kein halluzinierter Gate (`LH-QA-01`).** Alle drei ADRs geben Ungebautes als ungebaut aus:
  ADR-0016 (*„Gebaut ist er nicht"*, `citations` ausdrücklich verworfen), ADR-0017 (*„die Grenze
  dieser Entscheidung hat keinen Sensor … Diese ADR baut ihn nicht"*), ADR-0015 (*„keine.
  … gebaut ist sie nicht"*, samt Begründung über den Mutations-Treiber). Die genannten Targets
  `make docs-check` und `make baseline-verify` existieren und laufen — beide selbst gefahren.
- **N-11 — §3.5-Gefäß.** Die Senkung lebt in einer eigenen ADR mit eigenem Preis, eigener Grenze und
  eigenen Triggern; die Kopplung steht in **beiden** Köpfen und in beide Richtungen. `MR-001` — der
  einzige Ort im Repo, der die `scan.ignore`-Einträge zählt und als *„Scoping, keine Gate-Lockerung
  nach §3.5"* klassifiziert — ist als Folgepflicht 2 benannt, Zahl **und** Klassifikation **und**
  Grenze. Der Config-Kommentar samt ADR-Zeiger ist verlangt. **Alle fünf Befunde der Vorgängerrunde
  zur Senkung sind geschlossen.**
- **N-12 — §3.6.** Keine der drei ADRs macht eine Zusage ohne benanntes Gegenbeispiel. ADR-0016
  widerlegt die naheliegende Gegenbehauptung („an diesem Träger kann kein Sensor stehen") mit einer
  Zwei-Sensor-Sonde am selben Baum; ADR-0017 nennt sein Gegenbeispiel (*„ein fünfter Eintrag ohne
  ADR-Zeiger im Kommentar"*) und sagt im selben Atemzug, dass es nicht rot gesehen ist; ADR-0015
  führt seine Fitness-Function-Zeile mit `—` statt mit einem Target.
- **N-13 — §3.4 und `matrix.status`.** Keine der drei ADRs verweist auf eine superseded ADR; keine
  ändert eine Accepted-ADR; alle drei sagen ausdrücklich *„Diese ADR ändert keine Datei"* bzw. geben
  ihre Wirkung an Folgepflichten ab. `make docs-check` grün über alle drei.
- **N-14 — Form gegen die vendored Vorlage.** Alle drei tragen die acht Pflicht-Abschnitte der
  Vorlage `templates/docs/plan/adr/NNNN-titel.template.md` (`v3.5.2`) in der Reihenfolge der Vorlage;
  alle drei stehen mit Status, Bezug und Kurzfassung im ADR-Index (`AGENTS.md` §5 erfüllt).
- **N-15 — Baum-Hygiene.** Fünf Sonden gefahren, jede einzeln zurückgenommen; `git status --short`
  nach jeder Rücknahme leer; `.harness/baseline/v3.5.2` wieder an Ort und Stelle
  (`baseline-verify: v3.5.2 OK — 42 Dateien`); `make gates` Exit 0 mit
  `d-check: 310 Datei(en) geprüft, 0 Befund(e)`.

---

## Kategorie-Summary

| Kategorie | Zahl | IDs | Verteilung |
|---|---|---|---|
| HIGH | **0** | — | — |
| MEDIUM | **4** | F-1, F-2, F-8, F-9 | ADR-0016: 2 · ADR-0017: **0** · ADR-0015: 2 |
| LOW | **4** | F-3, F-4, F-6, F-10 | ADR-0016: 2 · ADR-0017: 2 (F-4 geteilt) · ADR-0015: 1 |
| INFO | **3** | F-5, F-7, F-11 | ADR-0016: 1 · ADR-0017: 1 · ADR-0015: 1 |

## Verdikt

| ADR | Kern-Aussage | Blockiert die Annahme? | Blockierende Befunde |
|---|---|---|---|
| **ADR-0016** | **bestätigt** — Tag-Tausch ist Inhaltsänderung, gegen `v5.3.1` gemessen | **JA** | F-1, F-2 — zwei Zustandsaussagen, die §3.4 einfriert |
| **ADR-0017** | **bestätigt** — die Schließung ist extensional und echt | **NEIN** | keine |
| **ADR-0015** | **bestätigt** — die Tabelle weist kein Eigentum zu, die Lücke ist real | **JA** | F-8, F-9 |

**Keine der drei ist gegenstandslos.** Die drei Kern-Aussagen, an denen sie stehen und fallen, halten
alle drei einer eigenständigen Messung stand — die von ADR-0016 sogar gegen einen späteren Tag als
den, gegen den sie geschrieben wurde.

**Kein Befund an einer ADR blockiert eine andere.** F-1/F-2 sitzen in §Kontext und Festlegung 3 von
ADR-0016 und lassen dessen **Festlegung 1** — die Voraussetzung, auf der ADR-0017 ruht — unberührt.
ADR-0017 ist damit unabhängig annahmefähig; es wartet nur auf die beschlossene Reihenfolge, nicht auf
einen Defekt. F-8/F-9 betreffen ausschließlich ADR-0015.

**Zur Reihenfolge und zur Zwei-Baum-Frage** (beide vorab entschieden, beide nicht mein Gegenstand):
meine Messungen widersprechen ihnen nicht. Die Reihenfolge `0016` → `0017` → `0015` ist im Gegenteil
notwendig, damit ADR-0016 Festlegung 3(a) auf ADR-0015 überhaupt greifen kann — genau das macht F-9
erst zu einem Befund und nicht zu einer Stilfrage. Die Zwei-Baum-Aussage in Kontext-Punkt 4 von
ADR-0016 ist gegen den Baseline-Text belegt (M-3, Zitate 5 und 6) und der bats-Fall existiert wörtlich.

**Der Reviewer entscheidet nicht über die Annahme und setzt keinen Status.** Regelwerk `v3.5.2`,
`modul-08-agentenrollen.md` §Rollen-Regeln: *„ADR-Änderung: Architect schreibt; Reviewer prüft auf
Konsistenz; Implementer liest als Constraint"*. Übergabe an den Architect. Bei Widerspruch gegen einen
der vier MEDIUM gilt der Konflikt-Pfad aus Modul 8 mit Übergabe-Artefakt — F-1 ist über die drei
`git grep`-Kommandos aus M-10 in unter einer Minute gegenzuprüfen, F-8 über
`git -C <kurs-klon> grep -c "Fallen Auftraggeber- und Entwickler-Rolle zusammen" v3.5.2 -- lab/regelwerk`
in Sekunden.
