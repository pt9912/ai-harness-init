# Review: ADR-0036 — Konsistenz-Bestätigungsrunde nach den Fix-Commits

**Rolle:** Unabhängiger Reviewer (Harness Modul 10) — Diff gegen Plan + ADRs + Hard Rules
(**nicht** DoD; das ist Verifier-Rolle).

**Datum:** 2026-09-05 · **Reviewer:** Claude, frischer Kontext, keines der geprüften Artefakte
selbst geschrieben.

**Gegenstand und Zuschnitt.** Kein voller Erst-Review. Dieser Lauf prüft **nachmessend**, ob die
zwei Fix-Commits die vier Stellen wirklich schließen, die der Vorbericht
[`2026-09-05-slice-178-nachtraeglich-review.md`](2026-09-05-slice-178-nachtraeglich-review.md)
an [`ADR-0036`](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) als blockierend
benannt hat (HIGH-1, MEDIUM-1, MEDIUM-2, MEDIUM-3), dazu LOW-3 zur Vollständigkeit — und ob die
Datei gegen [`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) und
[`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) konsistent ist.
Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren; keine Angabe ist
aus einer Commit-Message oder aus dem Vorbericht übernommen.

**Trigger-Bezug.** [`ADR-0036`](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md)
§Der Acceptance-Trigger macht genau diesen Report zur Bedingung ihres Umschlags auf `Accepted`:
*„wenn eine Reviewer-Runde sie gegen ADR-0018 und ADR-0031 auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund in `docs/reviews/` liegt"*.

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `ec3343a` (ADR-0036, vier Stellen) und `c296a37`
  (`BEO-040/…/state.md`, die wortgleiche Stelle). Gegenprobe gegen den Ist-Stand `d8929ea`, weil
  seither zwei weitere Commits Artefakte berührt haben, auf die die ADR sich stützt.
- **`LH-*`:** `LH-QA-01` (kein Gate liest, nach welcher Fassung ein Durchgang lief),
  `LH-QA-02` (der Tag als Reproduzierbarkeits-Klammer).
- **Referenzierte ADRs:** ADR-0018 (`Accepted`), ADR-0031 (`Proposed`), ADR-0015 (`Accepted`),
  ADR-0016 (`Accepted`), ADR-0030 (`Accepted`), ADR-0034 (`Accepted`), ADR-0036 selbst
  (`Proposed`). Keine ist `Superseded` oder `Deprecated` — nur diese zwei verbietet
  `matrix.status` in [`.d-check.yml`](../../.d-check.yml). Selbst gemessen:
  ```sh
  for f in 0018-* 0031-* 0015-* 0016-* 0030-* 0034-* 0036-*; do
    printf '%s ' "$f"; grep -m1 '^\*\*Status:\*\*' "docs/plan/adr/$f"
  done
  ```
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (ADR ab `Accepted`
  immutabel), §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel), §3.7 (beschrieben wird die
  Stelle, nicht der Vorgang), §3.8 (Architect-Commit-Zuschnitt), §3.9 (Docker-only). Dazu
  `MR-025` Setzung 1 und 2 sowie `MR-040`.
- **Vorherige Findings am gleichen Modul:** der Vorbericht vom selben Tag (1 HIGH, 4 MEDIUM,
  3 LOW, 3 INFO) und seine als wiederkehrend markierte Klasse *„eine Aussage nennt einen Fundort,
  wo eine Fundmenge steht"* (dort dreimal).
- **Slice-Plan:** [`slice-178`](../plan/planning/done/slice-178-regierende-fassung-des-sprungs-v600.md).

**Gate-Lauf:** `make gates` → **EXIT 2**, zweimal gefahren (Docker-only, §3.9). Die Ursache liegt
außerhalb dieses Prüfgegenstands und ist unten als N-1 und N-2 aufgeschlüsselt.

---

## Teil A — Nachmessung der vier Fix-Stellen

### HIGH-1 (Zahl in Option C) — **behoben**

Der Vorbericht beanstandete `62`/`16` neben einem Kommando, das über dem Baum der Datei nie
gefallen ist. `ec3343a` setzt `77`/`16`. Über dem Baum, in dem die Zahl **steht**, gibt das
abgedruckte Kommando genau das aus:

```sh
for c in ec0862a 9ad297a ec3343a HEAD; do
  printf '%s vork=' "$c"
  git grep -oE '\]\([^)]*0018-ziel-fassung-regiert-die-migration\.md[^)]*\)' "$c" \
    -- ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
  printf '%s datei=' "$c"
  git grep -lE '\]\([^)]*0018-ziel-fassung-regiert-die-migration\.md[^)]*\)' "$c" \
    -- ':!docs/reviews' ':!docs/plan/planning/done' | wc -l
done
# -> ec0862a 62/16 · 9ad297a 80/17 · ec3343a 77/16 · HEAD 76/15
```

`MR-025` Setzung 1 (*„über dem Baum gefahren, von dem sie spricht"*) ist damit erfüllt. Dass HEAD
heute `76`/`15` liefert, ist die von Setzung 2 gedeckte Wanderung — die Datei sagt das neben der
Zahl selbst. **Kein Restbefund.**

### MEDIUM-1 (Sektions-Zuordnung der 11 Netto-Zeilen) — **halb behoben, Restbefund als M-2 unten**

Die Zahlen der Korrektur stimmen. Selbst gemessen:

```sh
git show d75cd8c^:.harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md > /tmp/ghd.alt
diff /tmp/ghd.alt .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md | grep -c '^[<>]'   # 13
diff -u /tmp/ghd.alt .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md | grep '^@@'
# -> @@ -1,5 +1,5 @@ (Herkunfts-Kommentar, 2 Zeilen) · @@ -11,7 +11,7 @@ (2 Zeilen) · @@ -292,8 +292,13 @@ (9 Zeilen)
grep -n '^### ' .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
# -> Verzeichniskonvention ab 4 · Template-Schichtung ab 26 · … · harness/conventions.md als Konventionsspeicher ab 219
```

13 roh − 2 Herkunfts-Kommentar = **11** netto; davon **2** in Zeile 14 (§Verzeichniskonvention,
4–25) und **9** in 295–301 (§harness/conventions.md als Konventionsspeicher, 219–315). Dass der
Freshness-Audit in §Verzeichniskonvention **nicht** delegiert, ist ebenfalls nachgemessen — seine
neun Verweise zeigen auf `#harnessconventionsmd-als-konventionsspeicher` (3×),
`modul-07-carveouts.md` (2+1), `modul-04-adrs.md` (1),
`#harnessreadmemd-als-einstiegspunkt` (1), `grundlagen-bootstrap.md#modus-pro-sub-area…` (1).

**Was der Fix nicht erreicht hat**, steht als M-2 in Teil B: Der Vorbericht nannte zwei Orte
(Tabelle **und** den Satz), korrigiert wurde die Tabelle — und die durch eine **angehängte
Korrekturzeile** statt durch die Zelle.

### MEDIUM-2 (Fundort in ADR-0031) — **behoben**

Die beanstandete Mehrzahl steht in ADR-0031 an drei Stellen, davon eine in §Entscheidung als
tragender Grund von Festlegung 1. Selbst gemessen:

```sh
grep -n -e 'die haben ein Delta' -e 'ein Delta haben' -e 'Delta haben' \
     docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md   # 65, 154, 215, 259
grep -n '^## ' docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md
# -> Kontext 34 · Entscheidung 143 · Verglichene Alternativen 190 · Konsequenzen 210 · … · Re-Evaluierungs-Trigger 253
```

65 → §Kontext, 154 → §Entscheidung, 215 → §Konsequenzen; 259 liegt im
§Re-Evaluierungs-Trigger und ist eine **Frage**, keine Behauptung — die „drei Stellen" der
Korrektur sind damit die richtige Menge. Das Zitat *„sie delegiert vier Fragen in Abschnitte, die
ein Delta haben"* deckt sich verbatim mit Zeile 153–154 (Umbruch nach *Delta*), also in der Form,
die [`ADR-0016`](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 als
whitespace-normalisiert festlegt. Die wortgleiche Stelle in
`BEO-ALL/regel-delta-zaehlt-herkunfts-kommentar-mit/state.md` ist mit `c296a37` mitgezogen —
gelesen und deckungsgleich. **Kein Restbefund.**

### MEDIUM-3 (Kopplungs-Feld) — **behoben**

Das Feld sagt jetzt, was da ist, statt was vor dem Commit da war. Gegengemessen am Ist-Stand:

```sh
grep -c 'ist offen' harness/conventions.md                    # 0
git show 9ad297a^:harness/conventions.md | grep -c 'ist offen' # 1
grep -n -A2 '^## Baseline' harness/conventions.md
```

§Baseline führt heute *„**Die Prozedur des Sprungs auf `v6.0.0` stellt die Ziel-Fassung** —
`ADR-0036`, einzige Festlegung, `Proposed` mit Acceptance-Trigger in der Datei"*. Die
Präsens-Aussage des Kopplungs-Feldes trifft damit zu, und sie widerspricht §Konsequenzen
(*„im selben Commit eingelöst"*) nicht mehr. **Kein Restbefund.**

### LOW-3 (gealterter Nachweis in ADR-0018) — **unverändert offen, nicht blockierend**

Nachgefahren:

```sh
git grep -cniE -e 'annehmend' -e 'Accept-Akteur' -e 'nimmt die ADR an' -e 'setzt den Status' \
  -- spec AGENTS.md CLAUDE.md harness README.md docs/plan/adr/README.md .harness/baseline
# -> 4 Dateien / 10 Zeilen: grundlagen-source-precedence.md:1 · MR-015:3 · MR-036:3 · MR-042:3
```

ADR-0018 §Geschichte zitiert *„**eine** Datei, **3** Zeilen"*; die Datei ist `Accepted` und nach
[`AGENTS.md`](../../AGENTS.md) §3.4 nicht korrigierbar. **Inhaltlich hält die Aussage**: der
Baseline-Treffer (`grundlagen-source-precedence.md:201`, *„der annehmende Akt ist die
Entscheidung, die vor der Umsetzung fällt"*) spricht vom Change-Request am Lastenheft, nicht von
der ADR-Statuszeile; die drei MR-Treffer gehören derselben Familie. Der Vorbericht hat das
richtig eingeordnet, und dieser Lauf bestätigt es. LOW bleibt LOW.

---

## Teil B — Findings dieses Laufs

### M-1 — Der einzige „lebende" Nachweis der ADR ist seit `655c2df` falsch, und §Entscheidung stützt sich darauf

- **kategorie:** MEDIUM
- **quelle:** Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.4 (der Satz wird mit dem
  Umschlag unkorrigierbar) · Klassen-Anker: Beobachtung
  `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form` (`Stand: offen`)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:180–187` (§*Die Wirkung
  ist nicht hypothetisch — sie steht heute im Konventionsspeicher*) und `:240` (§Entscheidung,
  tragender Grund 1, Schlusssatz)
- **befund:** Die Sektion behauptet im Präsens, `harness/conventions.md`
  §Modus-Deklaration pro Sub-Area *„beginnt mit dem Satz „Eine Kürzel-Spalte führt diese Tabelle
  nicht.""* und begründe ihn mit `adoptierter Stand v5.18.0`. Am Ist-Stand kommt weder der Satz
  noch die Stand-Angabe dort vor; die Sektion beginnt seit `655c2df` mit dem Gegenteil
  (*„**Die Spalte ist nicht bedingt — seit `v6.0.0` trägt sie.**"*), und die Tabelle hat die
  Kürzel-Spalte bekommen. Grund 1 der einzigen Festlegung endet mit *„der Unterschied ist an
  einer lebenden Stelle des Konventionsspeichers ablesbar"* — er ist es nicht mehr. Die ADR nennt
  weder Commit noch Tree-Operand für diese Beobachtung, anders als für ihre Baseline-Messungen
  (dort steht `d75cd8c^` daneben).
- **verifizierbar:** **nein** — kein Gate-Modul liest, was ein Satz neben einem auflösenden Pfad
  behauptet (`.d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`);
  `make comment-claims` hat keine Markdown-Datei im Prüfbereich. Reproduzierbar:
  ```sh
  git show ec3343a:harness/conventions.md | grep -c 'Eine Kürzel-Spalte führt diese Tabelle nicht'  # 1
  grep -c 'Eine Kürzel-Spalte führt diese Tabelle nicht' harness/conventions.md                     # 0
  grep -c 'adoptierter Stand' harness/conventions.md                                                # 0
  git log --oneline -1 -S'Eine Kürzel-Spalte führt diese Tabelle nicht' -- harness/conventions.md
  # -> 655c2df Rolle Architect: Modus-Deklaration bekommt die Kuerzel-Spalte (ADR-0034 Festlegung 3, Folgepflicht 2)
  git merge-base --is-ancestor 655c2df ec3343a || echo "655c2df liegt NACH dem Fix-Commit"
  ```
- **klasse:** *Präsens-Aussage über ein lebendes Artefakt in einem einzufrierenden Text* —
  deckungsgleich mit `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form`
  (heute 1×, Beleg `slice-145`).
- **Was davon nicht fällt — und warum der Befund trotzdem trägt.** Die **Festlegung** bleibt
  richtig: `655c2df` hat die Stelle in genau die Richtung gezogen, die die ADR vorhersagt
  (*„Gegen die Ziel-Fassung ist es falsch, denn dort ist die Spalte unbedingt"*), und den Ausgang
  vergeben, den die ADR ausdrücklich an
  [`ADR-0034`](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  delegiert. Der Nachweis ist also nicht widerlegt, sondern **verbraucht**. Das ist der
  Unterschied, der ihn zum Befund macht: Ein Leser, der die ADR nach dem Einfrieren an ihrer
  eigenen Adresse nachschlägt, findet den entgegengesetzten Satz und kann nicht entscheiden, ob
  die ADR irrte oder die Stelle sich bewegt hat — und §3.4 verbietet ab dann die eine Zeile, die
  das klärte. Der Vorbericht hat dieselbe Klasse an einem anderen Ort derselben Datei als
  MEDIUM-3 blockierend geführt; sie hier niedriger zu hängen wäre eine Kategorisierung nach
  Zeitpunkt statt nach Sache.

### M-2 — Die Korrektur der Zeilen-Zuordnung steht neben der Aussage, die sie widerlegt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (eine Zusage misst die Eigenschaft, nicht ihre
  Nähe) · Klassen-Anker: Beobachtung
  `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` (`Stand: geplant`, `slice-153`)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:102–104` (Tabelle
  §Stufe (b)) und `:122`
- **befund:** Zeile 104 stellt fest, **2** der 11 Netto-Zeilen lägen *„in §Verzeichniskonvention
  …, einer Sektion, in die der Freshness-Audit nicht delegiert"*. Achtzehn Zeilen später steht
  unverändert *„**Und die 11 treffen die delegierte Frage — eine Ebene tiefer, als ein Zeilen-Diff
  sie findet.**"*, und der Absatz darunter belegt sie ausschließlich mit der Kürzel-Spalten-Prosa,
  also mit den **9**. Die Datei behauptet in derselben Sektion beides. Dazu zwei Beobachtungen an
  der Korrekturzeile selbst: Die Zellen 1 und 2 tragen das beanstandete Etikett
  *„§Konventionsspeicher"* weiter, so dass die Vergangenheitsform *„nur ihr Sektions-Etikett
  **war** datei-skopiert"* über einen Text spricht, der zwei Zeilen darüber steht; und die
  Korrektur belegt als einzelne Zelle eine Zeile einer dreispaltigen Datentabelle
  (*Delegierte Frage · Zieldatei · Regel-Zeilen mit Delta*), deren beide anderen Spalten sie leer
  lässt.
- **verifizierbar:** **nein** (kein Gate liest den Wahrheitsgehalt eines Satzes; `make gates`
  meldet zu dieser Datei nichts). Reproduzierbar:
  ```sh
  grep -n -e 'Korrektur der Zeilen-Zuordnung' -e 'Und die 11 treffen' \
       docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md      # 104, 122
  git show ec3343a --stat -- docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md
  # -> 14 insertions(+), 10 deletions(-); Zeile 122 ist nicht darunter
  ```
- **klasse:** *Korrektur nennt einen Fundort, wo eine Fundmenge steht* — dieselbe Klasse, die der
  Vorbericht als wiederkehrend markiert hat (dort MEDIUM-2, LOW-1 und als Mechanismus hinter
  MEDIUM-1). Sie ist hier ein viertes Mal aufgetreten, und zwar **im Fix für sie selbst**: Der
  Vorbericht benannte für MEDIUM-1 zwei Orte (`:101` Tabelle, `:120` Satz), nachgezogen wurde
  einer.
- **Was davon nicht fällt:** Die Zahl **11** ist richtig, die Aufteilung **9/2** ist richtig, und
  Grund 1 der Festlegung ist datei-skopiert formuliert (*„die einzige der vier Zieldateien mit
  einem Regel-Delta"*) und bleibt unberührt.

---

## Negativbefunde (geprüft, ohne Befund)

- **Konsistenz gegen ADR-0018 — kein Widerspruch, selbst nachgelesen.** Festlegung 3 gibt zwei
  Fälle; ADR-0036 misst Stufe (a) an der **gepinnten** Fassung aus `d75cd8c^`, findet die
  Prozedur (§Freshness-Audit, *„sieben Eigenschaften"*, fünf Ausgänge, *„keinen stillen
  Auto-Bump"*), verwirft damit den ersten Fall und wählt den zweiten (*„die Wahl ist offen und
  wird in jenem Sprung begründet entschieden"*). Festlegung 2 (Zwei-Fassungen-Phase) ist nicht
  umgangen, sondern für beendet erklärt, und das trifft zu: `ls -1 .harness/baseline/` → genau
  `v6.0.0`, der Tausch-Slice liegt in `done/`, der Durchgang in `open/`. Festlegung 4 bleibt
  ausdrücklich unangetastet, Option C bleibt verworfen, kein `Supersedes` fällig.
- **Konsistenz gegen ADR-0031 — die Festlegungen fallen nicht.** Festlegung 1 ist auf ihren
  Sprung geschlossen und wird nicht angefasst; ihr Ergebnis trägt weiter, weil genau ein Delegat
  ein echtes Regel-Delta hat und ihr zweiter Grund unabhängig steht. Ihr erster
  Re-Evaluierungs-Trigger ist verbatim zitiert und beide Stufen sind gefahren. Festlegung 2 hat
  ihren Zielort noch (`grep -n '^## Baseline' harness/conventions.md` → 8), und die Buchung für
  `v6.0.0` steht dort in der Drei-Teile-Form (Ziel-Tag, `2026-09-04`, `slice-176`).
- **Die gesamte Messung von Stufe (a) und (b) reproduziert.** §Freshness-Audit byte-gleich
  (`123 = 123` Zeilen, `diff` leer bei Exit 0, `grep -c '^\* \*\*'` → 7); neun Verweise in der
  gemessenen Verteilung `3/2/1/1/1/1`; Delegat-Deltas `13/2 · 2/2 · 2/2 · 2/2` für diesen Sprung
  und `17/2 · 2/2 · 2/2 · 2/2` für den davor; die je zwei Zeilen bei drei Delegaten **sind**
  ausschließlich der Herkunfts-Kommentar (URL → relativer Pfad, im `diff` sichtbar); `26`
  Regelwerks-Dateien, `25` mit genau einem `<!-- Quelle:`, 8 in Zeile 2 und 17 in Zeile 3; die
  Tabellenzeile *Modus-Deklaration pro Sub-Area* in beiden Fassungen auf Zeile 236 und
  byte-gleich; die dreizehn Suchbegriffe über das vendored Delta → **0**.
- **Belegform nach ADR-0016 — erfüllt.** Die tragenden Baseline-Belege nennen Tag,
  Regelwerks-Dateinamen, Abschnittsnamen und Zitat (*„`v6.0.0`,
  `modul-02-harness-bootstrap.md`, §Freshness-Audit der vendored Baseline (Schritt 2)"*). Die 13
  Vorkommen von `.harness/baseline/v…` in der Datei stehen sämtlich als **Operand eines
  abgedruckten Kommandos**, wie es `MR-025` Setzung 1 verlangt, nicht als Beleg-Adresse; der
  Unterschied ist der, den ADR-0016 zwischen *Beleg* und *Navigations-Zeiger* zieht.
- **ADR-0030 Festlegung 3 — erfüllt.** Alle Slice-Nennungen der Datei (`slice-152`, `slice-171`,
  `slice-176`, `slice-178`, `slice-185`) stehen als Kennung in Inline-Code ohne Pfad-Adresse;
  ihre Lage im Lifecycle stimmt (`152`, `171`, `185` in `open/`; `176`, `178` in `done/`).
- **ADR-Index — gepflegt.** `docs/plan/adr/README.md` Zeile 43 führt ADR-0036 mit Titel, Status
  `Proposed` und der Bezugs-Liste.
- **Commit-Zuschnitt der zwei Fix-Commits — sauber getrennt.** `ec3343a` berührt **nur** die ADR,
  `c296a37` **nur** die Registerdatei. Das ist genau die Trennung, die
  [`AGENTS.md`](../../AGENTS.md) §3.8 für Architect-Artefakte verlangt, und es vermeidet den
  Fehler, den der Vorbericht als MEDIUM-4 am Closure-Commit gefunden hatte. Beide Messages nennen
  den auslösenden Befund und die betroffene Stelle.
- **Kein halluziniertes Gate.** §Fitness Function sagt *„Gebaut: keine"*, begründet je Kandidaten,
  warum er nicht misst, und markiert die Netto-Frage ausdrücklich als *„teilweise mechanisierbar,
  hier nicht gebaut"*. `LH-QA-01` gewahrt.
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain in diesem Lauf; alles über
  `make`, `git`, `grep`, `diff`.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — das ist
  Verifikation, getrennter Kontext, anderes Prüf-Artefakt.
- **Nicht geprüft (nicht Gegenstand):** die zwei Nebenbefunde des Vorberichts an ADR-0031
  (`39`/`13` und die ADR-0015-Zuschreibung in Option F). Träger bleibt `slice-171`.

---

## Nebenbefunde — nicht am Prüfgegenstand, aber im Gate sichtbar

`make gates` steht bei **EXIT 2**, zweimal gefahren (einmal auf `07b6503`, einmal auf `d8929ea`,
identisches Ergebnis). Die Stufe, die bricht, ist `docs-check`:
`d-check: 1607 Datei(en) geprüft, 5616 Befund(e)`. Beide Ursachen sind bereits im
Beobachtungs-Register geführt; **keine** hat mit ADR-0036 zu tun.

### N-1 — 5614 der 5616 Befunde stammen aus einem gitignorierten Agent-Worktree

- **kategorie:** LOW
- **quelle:** Klassen-Anker: Beobachtung `BEO-ALL/gate-flaeche-haengt-am-arbeitsbaum`
  (`Stand: offen`, 1×)
- **befund:** Unter `.claude/worktrees/agent-ad800744ce52af2e3/` liegt ein gesperrter zweiter
  Arbeitsbaum eines parallel laufenden Agenten. `.gitignore` Zeile 26 nimmt das Verzeichnis aus,
  aber `scan.roots: ["."]` in [`.d-check.yml`](../../.d-check.yml) liest das Dateisystem, und
  `scan.ignore` führt keinen Eintrag dafür. Der Vorbericht desselben Tages meldete `774 Dateien,
  0 Befunde`; heute sind es `1607` Dateien, weil derselbe Baum zweimal gezählt wird.
- **verifizierbar:** **ja** — genau der Gate-Lauf, der den Befund erzeugt.
  ```sh
  git worktree list                       # zweiter Baum unter .claude/worktrees/, locked
  git check-ignore -v .claude/worktrees/  # .gitignore:26
  grep -c '^\.claude/worktrees/' <gates-output>   # 5614 von 5616
  ```
- **klasse:** *Gate-Fläche hängt am Arbeitsbaum statt an einer deklarierten Fläche*
- **Warum nur LOW:** Die Beobachtung ist angelegt, ihr `state.md` benennt den Schutz als rein
  operativ (*„kein fremder Baum liegt beim Gate-Lauf im Verzeichnis"*) und die Verengung über
  `scan.ignore` als offenen Weg. Der Zustand ist also bekannt und beschrieben, nicht still.

### N-2 — Die restlichen zwei Befunde: `slice-mv` lässt die präfixlose Geschwister-Form stehen

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · Klassen-Anker: Beobachtung
  `BEO-ALL/verweise-brechen-beim-ortswechsel`, dort `Stand: verkörpert`, Zielort
  [`harness/tools/slice-mv.sh`](../../harness/tools/slice-mv.sh), Anker `seit slice-144`
- **befund:** Die Datei `slice-186-beobachtungs-kennungen-loesen-wieder-auf.md` in
  `docs/plan/planning/open/` verweist in Zeile 10 und 104 präfixlos auf
  `slice-184-register-form-im-bestand-nachziehen.md`. Die Zieldatei ist heute nach `in-progress/`
  gewandert; der begleitende Lauf `d8929ea` meldet *„7 eingehend, 0 ausgehend"* und lässt diese
  zwei stehen. Das Skript deckt nach seinem eigenen Kopf **eingehend** jede *Präfix*-Form und
  **ausgehend** die präfixlosen Ziele *innerhalb der bewegten Datei* — die präfixlose Adresse
  einer **anderen** Datei auf die bewegte fällt in keine der beiden Klassen. Genau diese Form
  nennt die Beobachtung als *„die als einzige in beide Richtungen bricht"*, und ihr Zustandsfeld
  steht auf `verkörpert`, ohne die verbleibende Richtung als Grenze zu nennen.
- **verifizierbar:** **ja** — `make docs-check` färbt rot; reproduzierbar:
  ```sh
  sed -n '10p;104p' docs/plan/planning/open/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md
  ls docs/plan/planning/*/slice-184-*   # -> in-progress/
  ```
- **klasse:** *Zustandsfeld sagt „verkörpert", die Verkörperung deckt eine der zwei genannten
  Richtungen nicht*
- **Abgrenzung:** Träger ist der Vorgang um `slice-184`/`slice-186`, nicht diese ADR. Der Befund
  steht hier, damit er nicht neu gefunden werden muss.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 2 am Gegenstand (M-1, M-2) + 1 daneben (N-2) | Präsens-Aussage im einzufrierenden Text · Korrektur nennt Fundort statt Fundmenge · Zustandsfeld „verkörpert" ohne die zweite Richtung |
| LOW | 1 (N-1) | Gate-Fläche hängt am Arbeitsbaum |
| INFO | 0 | — |

**Wiederkehrende Klasse:** *„eine Aussage nennt einen Fundort, wo eine Fundmenge steht"* — im
Vorbericht dreimal, hier ein viertes Mal (M-2), und diesmal **im Fix für einen Befund derselben
Klasse**. Die Vergabe eines Belegs gehört in die Closure, nicht in diesen Report; die passende
Kennung ist `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`.

---

## Verdikt

**Blockierender Befund: ja — M-1 und M-2, beide an der ADR selbst.**

Die vier vom Vorbericht benannten Stellen sind **drei ganz und eine halb** geschlossen: HIGH-1,
MEDIUM-2 und MEDIUM-3 sind nachgemessen behoben; MEDIUM-1 ist an der Tabelle behoben und an dem
Satz, den derselbe Befund nannte, nicht. Dazu ist zwischen dem Fix-Commit und heute der einzige
*lebende* Nachweis der ADR weggezogen, weil ein späterer Architect-Lauf den Ausgang vergeben hat,
den die ADR selbst delegiert.

**Die Entscheidung ist tragfähig.** Beide Mess-Stufen reproduzieren in diesem Lauf vollständig;
die Anwendung von ADR-0018 Festlegung 3 ist korrekt; die Abgrenzung gegen ADR-0031 stimmt in
Ergebnis und jetzt auch in der Ortsangabe; kein `Supersedes` fällig; kein Widerspruch zu einer
aktiven ADR oder einer Hard Rule in der Sache. Was blockiert, sind **zwei Sätze der Begründung,
nicht die Festlegung** — beide heute mit je einer Zeile korrigierbar, beide nach dem Umschlag von
[`AGENTS.md`](../../AGENTS.md) §3.4 gesperrt und dann nur noch über eine Folge-ADR mit
`Supersedes` erreichbar.

**Anlass, ADR-0036 vor der Annahme zu ändern: ja**, an zwei Stellen — §*Die Wirkung ist nicht
hypothetisch* samt dem Schlusssatz von §Entscheidung Grund 1 (M-1) und der Satz auf Zeile 122
samt den zwei Zellen, die die Korrekturzeile widerlegt (M-2). Das ist eine **Folge-Konsequenz für
einen Architect-Lauf**, kein Selbst-Fix: Dieser Report hat kein Artefakt außer sich selbst
angefasst.

N-1 und N-2 blockieren die Annahme **nicht** — sie halten `make gates` rot und gehören ihren
eigenen Vorgängen.

**Nicht abgedeckt:** die Verifikation (DoD, Plan-vs-Code) und der Ausgang von MEDIUM-4 des
Vorberichts (Rollen-Disziplin am Closure-Commit); der gehört in die Closure des Slice.
