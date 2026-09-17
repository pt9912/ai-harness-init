# Verifikation `slice-mv-zieht-praefixlose-geschwister-verweise-nach`: DoD 1 bis 3 bestätigt, zwei Textstellen vor der Closure

**Rolle:** Verifier · **Datum:** 2026-09-17 · **Geprüfter Stand:** `f6ae7ffd`. Vor diesem Bericht
war der Arbeitsbaum sauber (`git status --short | wc -l` → `0`). Geprüft ist die Umsetzung
`da1f3419` und `7348e55c` gegen die Basis `0ea7e148`, den letzten Commit vor der Umsetzung.
**Verifikations-Art:** DoD- und ADR-Konformität gegen den tatsächlichen Baum
(`v6.9.0` · `regelwerk/modul-11-verification.md`). Das ist kein Review.

**Eingang:**

- der Slice-Plan `slice-mv-zieht-praefixlose-geschwister-verweise-nach`, §1 bis §8, im Stand unter
  `in-progress/`;
- die zwei Umsetzungs-Commits mit ihren Messangaben;
- die zwei Review-Reports vom 2026-09-17: Runde 1 mit F-1 bis F-5, Runde 2 mit dem Verdikt
  „bereit". F-2 und F-4 gehen an den Planner und werden hier nur eingeordnet. F-5 geht an diese
  Rolle (§3);
- `ADR-0042`, Festlegung 1 und 2;
- `AGENTS.md` §3.3, §3.6 und §3.10.

---

## 1. Ergebnis je DoD-Punkt

| DoD-Punkt | Status | Beleg |
|---|---|---|
| **1** — `harness/tools/slice-mv.sh` zieht die präfixlosen Geschwister-Verweise nach | **erfüllt in der Sache**. Die Stand-Angabe der Sensor-Datei ist falsch (V-1). | Die Ersetzung steht in `rewrite_incoming_bare_in_file`, `main()` ruft sie für die flachen, getrackten Dateien in `$from` auf. Die Ausgabe-Zeile `eingehend:` zählt die Links mit. Die Neumessung beider Kanten ist in §2 wiederholt: je Kante Exit 0, der Move-Commit ist ein reiner Rename, es gibt keinen `target-missing`. Die Zahlen mit Kommando stehen im Commit `da1f3419`. |
| 1, Grenze 3 im Skriptkopf | **erfüllt** | Jede Aussage ist gegen den Code gehalten (§4). Die Wendung „der drei Ausgangsverzeichnisse" hängt an F-2 (§5). |
| **2** — die emittierte Fassung ist gleichgezogen, der Rumpf-Vergleich deckt sie | **erfüllt** | `KERN` in `test/slice-mv.bats` nennt `rewrite_incoming_bare_in_file`. Der neue `main()`-Block steht in beiden Fassungen wortgleich im Diff. `make test` ist grün als Teil von `make gates` (unten). Zwischen `da1f3419` und `HEAD` ändern sich in beiden Skripten nur Kommentarzeilen: Der Diff, gefiltert auf Zeilen ohne führendes `#`, ist leer. |
| **3** — Fall in `test/slice-mv.bats` | **erfüllt** | Der Fall *„eingehend praefixlos: …"* ruft die Funktion ohne Repository in beiden Fassungen auf. Er vergleicht den vollständigen Ist-Bestand der Probe: zwei ersetzte Links (einer mit Anker) und einen dritten, dazu unverändert einen Code-Span und einen Tree-Operanden mit demselben Namen, einen Präfix-Verweis, `.mdx` und einen fremden Namen. Er prüft auch den Zähler `3`. |
| 3 — Mutation, „mit `make mutate` gesehen, die Meldung ist gelesen" | **erfüllt** (§3) | `make mutate` → EXIT 0, `mutate: 349 ok, 0 Befund(e)`. Der Lauf meldet `mutate: ok 363-slice-mv-eingehend-verliert-geschwister-ersetzung -> eingehend praefixlos: jeder Link auf die bewegte Datei bekommt ../ZIEL/ rot`, ebenso 346 mit der neuen `expect`-Zeile. Die Meldung selbst haben der Implementer und Review-Runde 1 gelesen. |
| `make gates` grün | **erfüllt** | `make gates` über dem sauberen Stand `f6ae7ffd` → EXIT 0, `d-check: 1550 Datei(en) geprüft, 0 Befund(e)`, bats `1..311` |
| Review durchgeführt, Report liegt vor | **erfüllt** | zwei Reports vom 2026-09-17 unter `docs/reviews/`, das Verdikt von Runde 2 lautet „bereit" |
| Doku-Update in `harness/sensors/slice-mv.md` §Kanten | **erfüllt, bis auf V-1** | Die neue Messung steht in der Tabelle. `grep -c 'von Hand' harness/sensors/slice-mv.md` → `0`, `grep -c 'Adresse der Lücke' harness/sensors/slice-mv.md` → `0` |
| Closure-Notiz, Register, Risiko-Ausgänge, Paarungen | **offen, Planner** | Das sind Closure-Pflichten (`AGENTS.md` §3.10). §7 steht auf „offen bis zur Closure". |
| Reconciliation-Register | entfällt | wie im Plan begründet |

## 2. Eigene Messung: Neumessung beider Kanten und bewusstes Brechen

**Aufbau.** Es gibt zwei Wegwerf-Kopien im Scratch-Verzeichnis dieser Sitzung, beide aus
`git archive HEAD` (`f6ae7ffd`). Jede Kopie hat `git init`, eine lokale Identität und kein
`core.hooksPath` (`git config core.hooksPath` → leer).

- **K1** bleibt unverändert und trägt den Blob `7e53bd7` (`git rev-parse --short HEAD:harness/tools/slice-mv.sh`).
- **K0** trägt stattdessen den alten Blob: `git cat-file -p d1bda5b4 > harness/tools/slice-mv.sh`.

In jeder Kopie laufen nacheinander `make slice-mv SLICE=slice-070-comment-claims-pruefbereich TO=done`
und `make slice-mv SLICE=slice-103-traeger-waechter-decken-was-sie-sagen TO=done`. Nach jedem
Wechsel folgt `make docs-check`. Vor dem ersten Wechsel zeigen beide Kopien
`d-check: 1550 Datei(en) geprüft, 0 Befund(e)`, `make` Exit 0.

**Warum `7e53bd7` und nicht `7eaeb0df`.** Der Auftrag nennt `7eaeb0df`, den Blob am Stand
`da1f3419`. `HEAD` trägt `7e53bd7f`. Der Unterschied zwischen beiden besteht nur aus
Kommentarzeilen (§1, DoD 2). Die Messung an `7e53bd7` prüft also das Werkzeug, wie es heute
steht. Zugleich ist sie die Neumessung, die die Sensor-Datei für jede Änderung des Werkzeugs
verlangt (V-1).

Vor dem Wechsel zählt
`cat docs/plan/planning/<von>/*.md | grep -oE '\]\(<slice>\.md[)#]' | wc -l`
die präfixlosen Links: `6` unter `open/` in `5` Dateien und `3` unter `next/` in `2` Dateien
(`grep -lE … | wc -l`).

| Kopie · Kante | `slice-mv` | Move-Commit (`git show --numstat --format= -M`) | Zeile `eingehend:` | präfixlos danach / `../done/` danach | `docs/plan/adr` berührt | `make docs-check` |
|---|---|---|---|---|---|---|
| K1 · `open → done` | EXIT 0 | `0 0`, `{open => done}` | 17 Datei(en), darin 6 präfixlose Links; ausgehend 2 | 0 / 6 | 0 Dateien | `make` Exit 2; 1 Befund, **0** `target-missing` |
| K1 · `next → done` | EXIT 0 | `0 0`, `{next => done}` | 6 Datei(en), darin 3; ausgehend 0 | 0 / 3 | 0 Dateien | `make` Exit 2; 1 Befund, **0** `target-missing` |
| K0 · `open → done` | EXIT 0 | `0 0` | 12 Datei(en) (alte Zeile ohne Zähler) | 6 / 0 | 0 Dateien | 7 Befunde, **6** `target-missing` |
| K0 · `next → done` | EXIT 0 | `0 0` | 4 Datei(en) | 3 / 0 | 0 Dateien | 10 Befunde, **9** `target-missing` |

Die präfixlosen Zahlen gibt `cat docs/plan/planning/<von>/*.md | grep -oE '\]\(<slice>\.md[)#]' | wc -l`
aus, die Zahlen für `../done/` dasselbe Kommando mit `\]\(\.\./done/<slice>\.md[)#]`.

**Das Rot hat die behauptete Ursache.** In K0 steht jede der neun Meldungen in einer
unbewegten Geschwister-Datei des Ausgangsverzeichnisses. Das Linkziel ist jeweils der blanke
Dateiname des bewegten Slice:

- nach `open → done`: `open/slice-069-zahn-bindet-zusicherung.md:48` und `:141`,
  `open/slice-072-adr-verweist-nicht-auf-lifecycle.md:195`,
  `open/slice-078-verdrahtung-hat-waechter.md:178`, `open/slice-079-exit-code-vertrag.md:144`,
  `open/slice-101-norm-postens-bekommen-einen-termin.md:173`, jeweils mit dem Ziel
  `slice-070-comment-claims-pruefbereich.md` und `target-missing`;
- nach `next → done` kommen drei hinzu: `next/slice-108-feldlisten-waechter-tragen-ihren-fall.md:114`
  und `:193`, `next/slice-110-erfassungs-waechter-fall-meldung-grenze.md:63`, mit dem Ziel
  `slice-103-traeger-waechter-decken-was-sie-sagen.md`.

Die Zahl der Meldungen ist je Kante gleich der Vorzählung (6, dann 6 + 3). Auch die
Datei-Zählung passt: K1 zieht je Kante genau die Geschwister-Dateien zusätzlich nach
(17 − 12 = 5, 6 − 4 = 2).

**Der eine Befund in K1** ist in beiden Läufen derselbe:
`done/slice-070-comment-claims-pruefbereich.md:220 … closure-note-thin`. Die Kopie setzt keinen
Stilllegungs-Inhalt, und die Sensor-Datei nennt genau diesen Befund. Er gehört nicht zum
Gegenstand dieses Slice. Der Zählwert `1550` ist höher als die `1548` im Umsetzungs-Commit, weil
der Baum inzwischen die zwei Review-Reports trägt.

**Ergebnis:** Die Neumessung bestätigt die Tabelle in `harness/sensors/slice-mv.md` §Kanten Zelle
für Zelle, jetzt für den Blob `7e53bd7`. Die Gegenprobe an `d1bda5b` bestätigt auch den
Rot-Satz darunter (6, dann 9).

## 3. F-5: Trägt der Handlauf DoD 3?

**Allein nicht, und zwar dem Wortlaut nach.** Mit dem Handlauf ist zweimal gezeigt, dass die
Mutation 363 den Fall 275 aus dem richtigen Grund rot färbt. Implementer und Review-Runde 1 haben
dazu die unersetzten Links in der Meldung gelesen. Für das bewusste Brechen nach
`v6.9.0` · `regelwerk/modul-11-verification.md` genügt das. Der DoD-Punkt nennt aber den Sensor
`make mutate`, und der Handlauf deckt drei Dinge nicht ab, die nur dieser Sensor prüft:

- dass der Fall in `test/mutations/` gefunden und über seine Kopfzeilen geparst wird
  (`files:`, `expect:`, `verify:`);
- dass seine `expect:`-Zeile den Mechanismus von `harness/tools/mutate.sh` trifft;
- den Grün-Vorlauf in einer Kopie mit `.git`. Ohne `.git` fiel im Handlauf zusätzlich Fall 188,
  und dieses Rot hatte eine andere Ursache.

**Nachgeholt.** `make mutate` über dem sauberen Stand `f6ae7ffd` (Start 08:06:08, Ende 08:49:37,
`MUTATE_JOBS` Default 4) → EXIT 0, `mutate: 349 ok, 0 Befund(e)`. Aus dem Protokoll:

```text
mutate: ok      346-lifecycle-ersetzung-nur-in-einer-fassung -> die Funktionen der Liste KERN sind in beiden Fassungen wortgleich rot
mutate: ok      363-slice-mv-eingehend-verliert-geschwister-ersetzung -> eingehend praefixlos: jeder Link auf die bewegte Datei bekommt ../ZIEL/ rot
```

**Urteil:** DoD 3 ist erfüllt. Der Sensor aus dem DoD-Punkt ist gelaufen und hält den Fall. Die
Meldung ist aus dem Handlauf gelesen, und ihr Inhalt, die unersetzten Links `[a]`, `[b]` und
`[f]`, belegt die behauptete Ursache. Eine eigene Wiederholung des Handlaufs war nicht nötig:
Seit Runde 1 hat sich keine Zeile außerhalb eines Kommentars geändert (§1, DoD 2).

## 4. Zusagen in Sensor-Datei und Skriptkopf gegen das Verhalten

| Zusage | Ort | Beleg | Status |
|---|---|---|---|
| Ersetzt wird der präfixlose Markdown-Link, auch mit Anker, in getrackten Dateien flach im Ausgangsverzeichnis, unter derselben Ausnahmeliste | `slice-mv.md` §Grenze; Skriptkopf ZUSAGE und Grenze 3 | Code: `git grep -l … -- ":(glob)$PLANNING/$from/*.md" "${in_pathspec[@]}"`, `sed` auf `[]]\(<base>[)#]`; §2: 6 und 3 Links ersetzt, die ADR bleibt unberührt | gehalten |
| Andere Schreibweisen (`](./…)`, `](<…>)`, Referenz-Definition) bleiben stehen; Link-Syntax in einem Code-Span wird mitersetzt | dieselben Stellen | Das Regex verlangt den Namen direkt nach `](`. Das Mitersetzen im Code-Span hat Review-Runde 1 gesehen. Das Zählkommando aus Grenze 3 gibt `0` aus. | gehalten |
| Ohne Repository gedeckt: beide Fassungen, ganzer Dateiinhalt, Code-Span, Tree-Operand, Präfix-Verweis, längerer Name | `slice-mv.md` §Grenze | Fall *„eingehend praefixlos: …"* in `test/slice-mv.bats` | gehalten |
| `test/mutations/363-…` nimmt das `sed` und färbt diesen Fall rot | `slice-mv.md` §Grenze | §3 | gehalten |
| Welche Dateien `main()` übergibt, fährt keine bats-Stufe; das misst die Tabelle §Kanten | `slice-mv.md`; Skriptkopf Grenze 3 | F-4 aus Review-Runde 1 (Gegenmutation grün); §2 misst die Übergabe | gehalten, als Grenze deklariert |
| Die Tabelle der Kanten mit ihren Zellen und der Rot-Satz über `d1bda5b` (6, dann 9) | `slice-mv.md` §Kanten | §2 | gehalten |
| **„Gemessen am Blob `7eaeb0d` … (`git rev-parse --short HEAD:harness/tools/slice-mv.sh`)"** | `slice-mv.md` §Kanten | Das Kommando gibt an `HEAD` `7e53bd7` aus, nicht `7eaeb0d`. Die Datei sagt selbst: „Wer `harness/tools/slice-mv.sh` ändert, misst sie neu." `7348e55c` hat das Skript geändert, nur in Kommentaren, und die Angabe stehen lassen. | **nicht gehalten, V-1** |
| **„Aus den Geschwister-Dateien bleibt nach dem Wechsel kein Befund stehen"** | `harness/sensors/docs-check.md`, Absatz zu den Stilllegungs-Kanten | Die Aussage gilt ohne Einschränkung. Das Werkzeug erkennt aber nur die Link-Form (Grenze 3). Ein `](./slice-….md)` im Geschwister bliebe als `target-missing` stehen. Am heutigen Bestand zählt das Kommando aus Grenze 3 `0` solche Formen, deshalb trifft der Satz heute zu. Er sagt aber mehr zu, als der Code hält (`AGENTS.md` §3.6). | **breiter als der Code, V-2** |
| Ausgabe- und Commit-Zeile nennen die präfixlosen Links | Skriptkopf, `usage()` | §2: `darin 6 praefixlose(r) Link(s) aus Geschwistern unter open/`, Commit-Betreff `(17 eingehend, 2 ausgehend, 6 praefixlos aus open/)` | gehalten |
| Eine Datei mit beiden Formen zählt in `$in_count` nur einmal | Kommentar in `main()` | Hier nicht nachgemessen: In §2 trägt keine Geschwister-Datei beide Formen. Review-Runde 1 hat es im Mini-Repo gesehen. Kein Zahn, siehe F-4. | in Runde 1 gesehen, unbewacht |

## 5. Plan-vs-Code-Diff

**Gebaut und geplant.** `git diff --stat 0ea7e148 7348e55c` nennt neben dem Review-Report zehn
Dateien. Der Plan ist eine davon, die übrigen neun stehen alle in der Datei-Tabelle §3. Fünf
davon standen dort vor der Umsetzung. Die Zeile für die Mutation trug den Platzhalter
`<nnn>-slice-mv-…` und hat in `da1f3419` ihren Namen `363-…` bekommen. Vier Zeilen hat derselbe
Commit nachgetragen: `test/mutations/346-…`, die zwei `implement-slice.md`-Fassungen und
`harness/sensors/docs-check.md`. Der Plan-Diff dieses Commits berührt nur diese Tabelle
(`git diff 0ea7e148 da1f3419 -- <plan> | grep -E '^[-+]'` → eine entfernte und fünf neue Zeilen,
alle in §3). Das Fortschreiben von §3 ist nach `.claude/commands/implement-slice.md` Aufgabe der
ausführenden Rolle („Der Plan lebt in §3 des Slice-Plans"). DoD, §1, §5 und §6 sind unverändert
geblieben (`AGENTS.md` §3.10).

**Geplant, aber nicht gebaut:** nichts. Alle drei Liefer-Punkte sind vorhanden.

**Gebaut, aber nicht geplant:**

1. **Die Ersetzung läuft auch bei `from=done`** (F-2). `main()` nimmt `done` als
   Ausgangsverzeichnis an, und die präfixlose Ersetzung schreibt dann in flache
   `done/`-Geschwister. Plan §6, Risiko 4, knüpft den Ausgang *entfallen* aber an eine
   Beschränkung auf `open/`, `next/` und `in-progress/`. Diese Beschränkung baut der Code nicht.
   Grenze 3 im Skriptkopf spricht von „drei Ausgangsverzeichnissen". Das ist eine Aussage über
   die Kanten des Prozesses, nicht über die Eingaben, die das Werkzeug annimmt. Nach
   `ADR-0042` Festlegung 1 ist `done/` ein Zeitdokument, in dem die Adresse ersetzt wird. Die
   Präfix-Ersetzung schreibt schon vor diesem Slice dorthin. Einen Verstoß gegen die ADR sieht
   diese Rolle nicht, wohl aber eine offene Plan-Bedingung. **Adressat: Planner**, mit dem
   Ausgang von Risiko 4. Legt der Planner einen anderen Ausgang fest, folgt daraus womöglich eine
   Änderung am Wortlaut von Grenze 3.
2. **Der Commit-Betreff des Nachzugs trägt den Zähler `… praefixlos aus <von>/`.** Der Plan nennt
   nur die Ausgabe-Zeile. Beide Fassungen setzen den Betreff gleich. Er trägt weiter keine
   Kennung, wie `harness/README.md` §Traceability für die Werkzeug-Commits festhält. Kein Befund.
3. **Die Mutation 346 hat einen neuen `expect:`-Text und einen umformulierten Kommentar.** Der
   Plan hat das in §3 nachgetragen. `make mutate` hält den Fall (§3). Kein Befund.

## 6. ADR- und Hard-Rule-Konformität

| Regel | Beleg | Status |
|---|---|---|
| `ADR-0042` Festlegung 2: Eine `Accepted`-ADR bekommt keinen Byte-Nachzug | Die präfixlose Suche übergibt dieselbe Ausnahmeliste. §2: `git diff --name-only HEAD~2 HEAD -- docs/plan/adr \| wc -l` → `0` für beide Kanten in beiden Kopien | gehalten |
| `ADR-0042` Festlegung 1 | §5, Punkt 1 | kein Verstoß; die Plan-Bedingung geht an den Planner |
| `AGENTS.md` §3.3: Move und Inhalt stehen in zwei Commits | §2: Move-Commit `0 0` mit Rename, der Inhalt im zweiten Commit (`18 files changed, 26 insertions(+), 26 deletions(-)` bzw. `6 files changed, 13 insertions(+), 13 deletions(-)`) | gehalten |
| `AGENTS.md` §3.6 | §3; V-2 | eine Zusage breiter als der Code (V-2) |
| `AGENTS.md` §3.9 | Die Messung nutzt `git`, `tar`, `make` und `bash`, wie das Rezept von `make slice-mv` selbst (`@bash harness/tools/slice-mv.sh`). `docs-check` läuft im gepinnten Image. | gehalten |

## 7. Risiken aus §6: Stand für die Closure

Die Ausgänge setzt der Planner. Hier stehen nur die Belege zu den Bedingungen, die der Plan
nennt.

1. **Ersetzung trifft Tree-Operand oder Code-Span.** Der Plan nennt als Bedingung für
   *entfallen*: Nur die Link-Form wird ersetzt, und DoD 3 prüft die zwei Gegenformen. Beides ist
   erfüllt (§1, §4). Link-Syntax innerhalb eines Code-Spans wird mitersetzt, das steht als Grenze
   im Skriptkopf.
2. **Rumpf-Vergleich sieht die neue Funktion nicht.** Die Bedingung für *entfallen*, DoD 2, ist
   erfüllt: Die Funktion steht in `KERN`, und die Mutation 346 hält den Vergleich (§3).
3. **Die Gruppierung läuft vorher.** Die Umsetzung berührt diese Bedingung nicht. Den Stand
   prüft der Planner zur Closure.
4. **Ein Geschwister im Ausgangsverzeichnis ist eingefroren.** Die Bedingung für *entfallen*,
   die Beschränkung auf drei Verzeichnisse, ist **nicht** erfüllt (§5, Punkt 1).

## 8. Vor der Closure fehlt

| ID | Was | Adressat |
|---|---|---|
| V-1 | `harness/sensors/slice-mv.md` §Kanten: Die Blob-Angabe `7eaeb0d` passt nicht mehr zum Kommando daneben, das an `HEAD` `7e53bd7` ausgibt. Richtig ist `7e53bd7`. Die Werte der Tabelle bleiben, denn §2 dieses Berichts hat sie an genau diesem Blob gemessen. | Implementer |
| V-2 | `harness/sensors/docs-check.md`: Der Satz „Aus den Geschwister-Dateien bleibt nach dem Wechsel kein Befund stehen" ist auf das einzuschränken, was das Werkzeug erkennt, also den präfixlosen Markdown-Link nach Grenze 3. | Implementer |
| — | Ausgang von Risiko 4 samt Begründung (F-2, §5 Punkt 1) und, falls nötig, der Wortlaut „drei Ausgangsverzeichnisse" | Planner |
| — | F-4: Die Übergabe in `main()` hat keinen Zahn. Die Adresse ist `slice-mv-kanten-nach-done-sind-bewacht` | Planner |
| — | Closure-Notiz §7 mit Lerneintrag, Beobachtungs-Register (Kandidaten nach Plan §8: `verweise-brechen-beim-ortswechsel`, `verweis-nachzug-bricht-tree-operand`, `zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`), Ausgänge aller vier Risiken, drei Paarungen, `git mv` nach `done/` | Planner |

V-1 und V-2 sind reine Textkorrekturen und brauchen keine neue Verifikation. Der Planner prüft
V-1 zur Closure mit `git rev-parse --short HEAD:harness/tools/slice-mv.sh`: Die Ausgabe muss
gleich der Angabe in der Sensor-Datei sein. Solange das Skript unverändert bleibt, bleibt die
Angabe stabil.

## 9. Offengelegt

- Gemessen ist am Blob `7e53bd7` statt am Blob `7eaeb0df` aus dem Auftrag. Der Grund steht in §2.
- Den Exit-Code von d-check selbst hat diese Rolle nicht getrennt erhoben. Gesehen ist
  `make` Exit 2 bei 1 Befund bzw. Exit 0 bei 0 Befunden.
- Nicht wiederholt sind die Mini-Repo-Läufe aus Review-Runde 1 (`from=done`, Einfach-Zählung
  einer Datei mit beiden Formen) und die Gegenmutation am Aufruf (F-4).
- `make smoke` und `make full-smoke` sind nicht einzeln gefahren. `make mutate` hat die
  zugehörigen Fälle in seiner seriellen Spur gefahren und `0 Befund(e)` gemeldet.
- Die Kopien und das `make mutate`-Protokoll liegen im Scratch-Verzeichnis dieser Sitzung und
  nicht im Repo.

## 10. Verdikt

**DoD 1, 2 und 3 sind bestätigt**, jeweils mit eigenem Beleg:

- die Neumessung beider Kanten am heutigen Werkzeug;
- das bewusste Brechen am alten Blob, mit der behaupteten Ursache in allen neun Meldungen;
- `make mutate` mit 349 ok und 0 Befund(en);
- `make gates` mit EXIT 0.

**Closure-bereit nach V-1 und V-2** (Implementer, Textkorrekturen) sowie nach den
Closure-Pflichten des Planners, darunter der Ausgang von Risiko 4 (F-2), dessen
*entfallen*-Bedingung der Code nicht erfüllt.

**Übergabe:** Dieser Bericht geht an den Planner, V-1 und V-2 gehen zusätzlich an den
Implementer. Er ist ein Lauf-Beleg und ersetzt weder die Closure noch einen Review.
