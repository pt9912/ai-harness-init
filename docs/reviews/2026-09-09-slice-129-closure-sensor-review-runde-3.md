# Review — slice-129: Die Closure-Notiz-Pflicht bekommt ihren Sensor (Runde 3)

**Rolle:** Reviewer (Modul 10, frischer Kontext) · **Datum:** 2026-09-09
· **Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) v1.7.0

## Eingangs-Kontext (die fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Wert |
|---|---|
| **Diff/Commit-Range** | `9d27866d..f25d5504` — der Behebungs-Commit zu Runde 2, eng umrissen auf die vier dort gemeldeten Befunde. Geprüft wird, ob jeder von ihnen **trägt**, und ob die Behebung selbst neue trägt. |
| **Slice-Plan** | [`docs/plan/planning/done/slice-129-closure-notiz-hat-einen-sensor.md`](../plan/planning/done/slice-129-closure-notiz-hat-einen-sensor.md) |
| **`LH-*`** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| **Aktive ADRs im Bezug** | **keine.** Die zwei im Umfeld genannten — ADR-0033 (Werkzeug in Bau, im README-Absatz) und ADR-0035 (Beleg-Mechanik von `make mutate`) — stehen beide auf `Proposed` (`grep -m1 '^\*\*Status' docs/plan/adr/0033-*.md docs/plan/adr/0035-*.md`). Sie werden hier als **Zeiger auf gebauten Mechanismus** zitiert, nicht als normative Stütze; die operative Quelle für die Beleg-Aussage ist `harness/tools/mutate.sh` selbst. Keine superseded ADR referenziert. |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.3, §3.5, §3.6, §3.7, §3.9, §3.10 sowie §5 (Traceability) |
| **Vorherige Findings am gleichen Modul** | [Runde 1](2026-09-09-slice-129-closure-sensor-review.md) (2 HIGH / 2 MEDIUM / 2 LOW / 3 INFO) · [Runde 2](2026-09-09-slice-129-closure-sensor-review-runde-2.md) (2 HIGH / 2 MEDIUM / 0 LOW / 2 INFO) |

**Nicht Gegenstand:** die DoD-Abhakung als Konformitäts-Frage und die Bestätigung eines
Gate-Laufs — beides prüft die Verifikation. Ob die Häkchen **von wem** gesetzt sind, bleibt
dagegen eine Hard-Rule-Frage und steht hier.

## Prüfmittel und Sonden

Alle Messungen netzlos gegen **Kopien außerhalb des Repos** (`git archive HEAD | tar -x`),
Mount `:ro`, mit dem in [`d-check.mk`](../../d-check.mk) gepinnten Digest
(`sha256:e31a372b…`, `v0.74.1`). Das Sonden-Kommando ist byte-gleich mit dem
`docs-check`-Rezept. Der Arbeitsbaum wurde für keine Sonde angefasst
(`git status --porcelain` vor und nach dem Lauf leer). **Die Werte aus Runde 2 sind nicht
übernommen, sondern neu erhoben** — der ausführende Lauf hat sie seinerseits nur abgeschrieben.

| Sonde | Kommando (gekürzt) | Ergebnis |
|---|---|---|
| Basis | `docker run --rm --network none -v <kopie>:/repo:ro d-check@<digest>` | `1010 Datei(en) geprüft, 0 Befund(e)`, EXIT **0** |
| Mutation 288 | dieselbe Kopie, `bash test/mutations/288-*.sh` davor | **45** `closure-note-thin`, EXIT **1** |
| Mutation 289 | dto. | **1** Befund, `closure-note-missing`, Text `… fehlt oder ist unlesbar (fail-closed)`, EXIT **1** |
| Mutation 290 | dto. | **10** `closure-note-boilerplate`, EXIT **1** |
| Zitat MEDIUM-1 | `grep -n` in `.harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md` | Fundstelle Z. **295**; Schritt 4 reicht von Z. **252** bis Z. **300** — das Zitat liegt darin |
| DoD-Häkchen | `git diff 3b6c81af^ HEAD -- <plan>` | die drei Häkchen-Zeilen erscheinen als **Kontext**, sind also byte-identisch mit der Planner-Fassung |
| Diff-Umfang | `git show --stat f25d5504` | **5** Dateien, 15 Einfügungen, 14 Löschungen; 0 Renames |
| Mutations-Semantik | `diff <(git show f25d5504^:<datei> \| grep -vE '^#') <(grep -vE '^#' <datei>)` je Fall | für 288/289/290 **leer** — kein Nicht-Kommentar-Byte geändert |
| Zielpfad-Menge | `sed -n 's/^# files: //p' test/mutations/*.sh \| tr ' ' '\n' \| sort -u` | **60** Zielpfade; **keiner** der fünf geänderten Pfade steht darin |
| Verify-Modi | `sed -n 's/^# verify: //p' test/mutations/*.sh \| sort \| uniq -c` | `test-go` 43 · `test-bats` 13 · `full-smoke` 6 · `smoke` 1 · `ci-lint` 1 — **kein** Modus fährt `docs-check` |
| `mutate`-Beleg | `.harness/state/mutate-passed.key` gegen `isolation_key` des heutigen Baums | **abweichend**: gespeichert `55a93abb…`, aktuell `3db3d84c…` |
| Gate-Stempel | `.harness/state/gates-passed.diffsha` gegen `harness/tools/working-tree-hash.sh` | **deckungsgleich** (`f4dee87b…`) |
| `make comment-claims` | Gate selbst gefahren | `57 Datei(en) geprueft, 0 Befund(e)` |
| Traceability-IDs | `git log -1 --format=%B <commit> \| grep -oE 'LH-[A-Z]+-[0-9]+\|ADR-[0-9]{4}'` je Slice-Commit | `f25d5504`: **leer**; `2a2ceafd`, `3b6c81af`, `838cc6d6`, `02937ed3`: je mindestens eine |
| Bestands-Sensitivität | `ls docs/plan/planning/open/slice-*.md \| wc -l` | **64** Kandidaten, davon **45** mit Fund unter Mutation 288 |

**Keine Erwartungswerte** — alle Zahlen wandern mit dem Bestand
([`MR-025`](../../harness/conventions.md#mr-025)).

## Befunde aus Runde 2 — trägt die Behebung?

| Runde 2 | Verdikt Runde 3 | Beleg |
|---|---|---|
| **HIGH-1** DoD-Häkchen des ausführenden Laufs stehen weiter | **behoben** | alle drei auf `[ ]`; `grep -nE '\[[xX ]\]' <plan>` findet genau diese drei und keinen weiteren Marker. Die Zeilen sind gegen `3b6c81af^` **byte-identisch** — die Rücknahme stellt die Planner-Fassung her, statt eine neue Aussage zu setzen |
| **HIGH-2** Fall 289 behauptet `fail-open`, Fall 288 „ohne das je zu melden" | **behoben** | selbst nachgemessen: 289 → `closure-note-missing` mit dem Wort `fail-closed` in der Meldung, EXIT 1; 288 → 45 `closure-note-thin`, EXIT 1. Beide Kommentare sagen jetzt genau das (→ eine Rest-Belastung in LOW-1) |
| **MEDIUM-1** Regelwerk-Berufung ohne Mess-Tag | **behoben** | `harness/README.md:159` nennt `.harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md` im selben Absatz; das Zitat liegt real in Schritt 4 jenes Tags |
| **MEDIUM-2** Fall 290 beruft sich auf den Slice-Plan | **behoben** | die Zuschreibung ist ersatzlos entfallen, an ihrer Stelle steht eine Tatsachenbeschreibung; `grep -nE 'slice-[0-9]' test/mutations/290-*.sh` ist leer |

## Findings

### LOW-1 — Der korrigierte Kommentar von Fall 288 trägt eine Zahl, die mit dem `open/`-Bestand wandert

- `kategorie`: LOW
- `quelle`: Maintainability (latente Wartungsfalle: hart verdrahteter Wert);
  [`AGENTS.md`](../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist)
- `pfad`: `test/mutations/288-closure-dir-anderer-pfad.sh:9`
- `befund`: Der Kommentar sagt im Indikativ *„faerbt darauf 45 `closure-note-thin`-Befunde
  (EXIT 1)"*. Die Zahl ist heute richtig — selbst gemessen, 45 —, aber sie ist keine Eigenschaft
  der Stelle, sondern der Inventur: sie zählt die `slice-*.md` unter
  `docs/plan/planning/open/`, deren §7 dünn ist (64 Kandidaten, 45 Treffer). Jeder neu angelegte
  offene Slice-Plan und jeder `slice-mv` nach `next/` verschiebt sie. Weder ein Kommando noch ein
  Mess-Datum steht daneben, und kein Gate erreicht die Stelle
  (`test/` liegt außerhalb von `make comment-claims`; `make mutate` prüft die `# expect:`-Zusage,
  nicht den Satz daneben). Das Failure-Szenario ist der Vorgang, den dieser Slice gerade zweimal
  durchlaufen hat: Der nächste Lauf misst nach, bekommt eine andere Zahl und meldet den Kommentar
  erneut als falsch. **Kalibrierung gegen die Geschwister:** die übrigen Mess-Zahlen in
  `test/mutations/*.sh` sind strukturelle 0/1-Werte
  (`grep -nE '^#.*[0-9]+ (Befund|Treffer|Datei|Fundstell)' test/mutations/*.sh` → acht Zeilen,
  sieben davon `0`/`1`), und die einzige davon abweichende trägt ihr Mess-Datum
  (`92-cpp-hexslice-include-form.sh:10`, *„gemessen 2026-07-27 gegen das gepinnte Image"*). Die
  tragende Hälfte des Satzes — *der falsche Bestand wird gemeldet, nur unter der falschen
  Diagnose* — ist von der Zahl unabhängig und stimmt.
- `verifizierbar`: nein durch ein Gate — `test/` liegt dauerhaft außerhalb des Prüfbereichs von
  `make comment-claims` (vier Pfad-Muster), und `make mutate` kennt keine Fehlschlag-Form für
  einen Kommentar-Satz. Beobachtbar an der 288-Sonde gegen einen veränderten `open/`-Bestand.
- `klasse`: inventar-abhängiger Messwert im Skript-Kommentar ohne Kommando

### LOW-2 — Die Commit-Message des Behebungs-Laufs nennt als einzige der Slice-Kette weder eine `LH-*`- noch eine `ADR-*`-ID

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §5 erster Punkt (*„Requirement- und ADR-IDs in
  PRs/Commits referenzieren"*) und [`harness/README.md`](../../harness/README.md) §Traceability
  (*„PRs/Commits nennen mindestens eine `LH-*`- oder `ADR-*`-ID"*)
- `pfad`: Commit-Message `f25d5504`
- `befund`: Die Message führt `slice-129`, `AGENTS.md §3.10`, `MR-033 Setzung 1` und den Pfad des
  Runde-2-Reports, aber keine Kennung aus einem der zwei genannten Muster
  (`git log -1 --format=%B f25d5504 | grep -oE 'LH-[A-Z]+-[0-9]+|ADR-[0-9]{4}'` ist leer). Die
  vier übrigen Commits derselben Slice-Kette tragen je mindestens eine (`2a2ceafd`: `ADR-0033`,
  `LH-QA-01`; `3b6c81af` und `02937ed3`: `LH-QA-01`; `838cc6d6`: `ADR-0029`) — die Form war dem
  Lauf also verfügbar und ist in dieser Kette der Normalfall. Die Regel ist in ihrer Bezugseinheit
  nicht eindeutig: *„PRs/Commits"* liest sich sowohl als *jeder Commit* wie als *die Änderung als
  ganze*; unter der zweiten Lesart ist sie über die Kette erfüllt. Der Schaden ist deshalb
  begrenzt — die Message nennt Slice und Report, die Spur reißt nicht ab —, und er ist nach einem
  Push nicht mehr behebbar (dieselbe Eigenschaft, die
  [`MR-051`](../../harness/conventions.md#mr-051) Setzung 1 für Zahlen in Messages trägt); der
  Commit steht heute noch lokal (`git status -sb` → `[voraus 2]`).
- `verifizierbar`: nein durch ein Gate — das Modul `commits` steht nicht in `modules:` der
  [`.d-check.yml`](../../.d-check.yml), und `make mutate` kennt keine Fehlschlag-Form für eine
  Commit-Message. Beobachtbar an dem `grep` oben.
- `klasse`: Commit-Message ohne Traceability-Kennung

### INFO-1 — Die Begründung für den ausgelassenen `make mutate`-Lauf trägt in der Sache, nicht aber als Beleg-Aussage

- `kategorie`: INFO
- `quelle`: `harness/tools/mutate.sh` §*BELEG STATT LAUF* (die Mechanik selbst; die zugehörige
  ADR-0035 steht auf `Proposed`); [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `.harness/state/mutate-passed.key`
- `befund`: Die Sach-Hälfte der Begründung — *„reine Kommentar-/Häkchen-Änderung, keine Prüflogik
  berührt"* — ist gemessen richtig, und zwar dreifach: (a) für 288/289/290 ist außerhalb der
  `#`-Zeilen **kein Byte** geändert, `# files:` und `# expect:` stehen unverändert und decken
  weiterhin wörtlich je einen `@test`-Namen in `test/closure-modul-wiring.bats` (das seit
  `838cc6d6` unverändert ist); (b) **keiner** der fünf geänderten Pfade steht in der Menge der 60
  `# files:`-Zielpfade, kein `target_fingerprint` bewegt sich also; (c) **kein** Fall verifiziert
  über `docs-check`, weshalb `harness/README.md` und der Slice-Plan in gar keinem
  Mutations-Sensor-Eingang liegen. Die Beleg-Hälfte trägt dagegen nicht: der Schlüssel, gegen den
  `make mutate` einen Übersprung entscheidet, ist ein Inhalts-Hash über
  `isolation_key_files` — den **gesamten** Baum außer `.harness/state` und `.git`. Er lautet heute
  `3db3d84c…`, der gespeicherte Beleg `55a93abb…`; ein Lauf heute fährt also **voll** und stützt
  sich auf keinen Beleg. Für diesen Review ist das ohne Folge — die Verdikt-Wahrscheinlichkeit ist
  durch (a)–(c) belegt unverändert —, für die Verifikation ist es die Ausgangslage: der
  DoD-Standardpunkt *„`make mutate` ohne Befund"* ist für **diesen** Baumzustand heute durch
  nichts gedeckt. Der Gate-Stempel dagegen deckt ihn: `.harness/state/gates-passed.diffsha` ist
  mit `harness/tools/working-tree-hash.sh` deckungsgleich, `make gates` lief über genau diesem
  Stand.
- `verifizierbar`: ja — `bash -c 'source harness/tools/mutate.sh 2>/dev/null || true; isolation_key'`
  gegen `cat .harness/state/mutate-passed.key`.
- `klasse`: Beleg-Aussage über einen baum-abgeleiteten Schlüssel ohne Blick auf dessen Bezugsmenge

## Negativbefunde (geprüft, ohne Befund)

- **HIGH-1/R2 ist vollständig behoben, und die Rücknahme ist keine neue Aussage.** Alle drei
  DoD-Punkte tragen `[ ]`; `grep -nE '\[[xX ]\]' <plan>` findet im ganzen Plan genau diese drei
  Marker und keinen vierten. Der stärkste Beleg ist der Diff gegen den Stand **vor** dem
  Implementations-Commit: in `git diff 3b6c81af^ HEAD -- <plan>` erscheinen die Häkchen-Zeilen als
  Kontext, nicht als Änderung — sie sind byte-identisch mit der Fassung, die der Planner
  geschrieben hat. Der ausführende Lauf hat damit den Zustand wiederhergestellt und keinen
  gesetzt; §3.10 ist auf die Rücknahme eines unbefugt gesetzten Häkchens nicht anwendbar.
- **Am Plan wurde in diesem Commit sonst nichts angefasst.** Die Datei trägt im Diff genau drei
  Einfügungen und drei Löschungen — je ein Zeichen im Häkchen. Der Kriterien-Text, beide
  `**Rot:**`-Klauseln und die drei additiven `**Erfüllt:**`-Blöcke sind unberührt.
- **Die drei `Erfüllt:`-Blöcke bleiben zulässig.** Sie stehen additiv unter dem jeweiligen
  Kriterium und verschieben keines: der Kriterien-Text ist gegen `3b6c81af^` byte-gleich. §3.10
  bindet die Häkchen und verbietet, das eigene Abnahmekriterium **umzuschreiben** — Belege daneben
  zu berichten ist genau das Übergabe-Artefakt, das die Regel stattdessen verlangt.
- **Die §5-Tabelle des Plans ist geprüft und bleibt außerhalb.** Sie trägt seit `3b6c81af` zwei
  geänderte Zeilen (`Prüf-Profil` → `update`, `Makefile` → `unverändert`). Das ist eine
  Aufwands-/Umfangs-Zeile, kein Abnahmekriterium, kein Closure-Trigger und keine
  Out-of-Scope-Grenze — die drei Klassen, die §3.10 als *die Abnahme verschiebend* aufzählt. Runde 1
  hat den `pfad` ihres HIGH-1 ausdrücklich auf die drei DoD-Zeilen begrenzt und die Tabelle nicht
  beanstandet; Runde 3 kommt zum selben Ergebnis, statt dieselbe Stelle neu aufzurollen.
- **HIGH-2/R2: beide Kommentare sagen jetzt das Gemessene, und zwar wörtlich.** 289 zitiert die
  Meldung des Werkzeugs (`… fehlt oder ist unlesbar (fail-closed)`) samt Grund-Code und EXIT 1 —
  Teilzeichenkette der real ausgegebenen Zeile. 288 nennt Grund-Code und EXIT 1 und benennt die
  verbleibende Schwäche des lauten Pfads richtig (*falsche Diagnose*, nicht *keine Meldung*). Keiner
  der zwei behauptet noch ein stilles Versagen; die Rechtfertigung des Wächters ist auf
  *„ohne einen Docker-Lauf"* zurückgenommen, was zutrifft.
- **MEDIUM-1/R2: die Berufung ist prüfbar geworden, und ihr Inhalt stimmt.** `harness/README.md:159`
  trägt den Tag im Pfad, im selben Absatz wie die Aussage — die Form, die
  [`MR-033`](../../harness/conventions.md#mr-033) Setzung 1 verlangt. Selbst nachgeschlagen: die
  zitierte Forderung steht in Zeile 295 jener Datei und damit innerhalb von Schritt 4
  (Zeilen 252–300), wie der Absatz behauptet. Dass `codepaths` diesen Pfad nicht existenzprüft
  (Wurzel-Präfix `.harness` liegt außerhalb von `roots`, wie dieselbe Datei im nächsten Absatz
  selbst dokumentiert), ändert daran nichts — die Adresse ist von Hand nachgeprüft.
- **MEDIUM-2/R2: die neue Formulierung führt keine zweite unzulässige Quelle ein.** Fall 290 beruft
  sich jetzt auf gar nichts — der Satz beschreibt die Wirkung der Konfiguration im Indikativ
  (*„wirkt rueckwirkend auf ALLE Kandidaten"*), und die Messung stützt ihn: 10 Treffer über
  `done/`, nicht einer. Keine Slice-Nummer, keine Befund-Kennung, kein Report-Pfad, keine
  Konjunktiv-Konstruktion über die verworfene Alternative — die drei Klassen, die
  [`AGENTS.md`](../../AGENTS.md) §3.7 ausschließt. Dieselbe Prüfung über 288 und 289: ebenfalls
  frei davon.
- **Der Diff umfasst genau die fünf gemeldeten Dateien.** `git show --stat f25d5504` nennt sie und
  keine sechste; 15 Einfügungen gegen 14 Löschungen. Kein Pfad unter `docs/plan/planning/done/`,
  `docs/plan/adr/`, `.harness/baseline/` oder `docs/plan/planning/observations/` berührt.
- **Kein Artefakt einer anderen Rolle mitgenommen.** `AGENTS.md` und `harness/conventions.md`
  (§3.8, Architect) sind unberührt; das Beobachtungs-Register ebenfalls — sein letzter Commit ist
  `6e16a46c` (`Rolle Planner`), der Zähler des einschlägigen Eintrags steht unverändert bei 7
  (`ls …/fremdes-rollen-artefakt-im-implementations-kontext/evidence/*.md | wc -l`).
- **§3.3 nicht einschlägig.** Der Commit enthält keinen Rename (`git show --stat` weist keinen aus)
  — Move und Rewrite fallen nicht zusammen, weil kein Move stattfindet.
- **§3.5 nicht einschlägig.** `.d-check.yml` ist in diesem Commit gar nicht berührt: `modules:`,
  der `planning:`-Block, `ignore` und `ignore-refs` sind unverändert. Keine Schwelle bewegt.
- **§3.9 gehalten.** Weder in den drei geänderten Mutations-Dateien noch in einem Rezept steht eine
  Host-Toolchain oder ein Paketmanager in der Befehlsposition; alle Läufe dieses Reviews liefen
  über `make` bzw. das gepinnte Image.
- **Die Zahlen der Commit-Message halten.** *„docs-check 1010/0"* und *„comment-claims 57/0"* sind
  nachgefahren: der Basis-Lauf über einer Kopie außerhalb des Repos meldet `1010 Datei(en)
  geprüft, 0 Befund(e)` bei EXIT 0, `make comment-claims` meldet `57 Datei(en) geprueft,
  0 Befund(e)`. Beide nennen in der Message das Kommando, das sie ausgibt —
  [`MR-051`](../../harness/conventions.md#mr-051) Setzung 1 gehalten.
- **Die Substanz des Slice ist unverändert.** Der `closure`-Block, sein Kandidaten-Filter, die
  sechs bats-Zusicherungen und die Kopplung der drei `# expect:`-Zeilen an ihre `@test`-Namen sind
  in diesem Commit nicht angefasst; `test/closure-modul-wiring.bats` steht seit `838cc6d6`
  unverändert. Die Null des Basis-Laufs ist gemessen und nicht leer.
- **Keine superseded ADR referenziert.** Die zwei genannten ADRs stehen auf `Proposed` und werden
  als Zeiger auf gebauten Mechanismus zitiert, nicht als normative Stütze.

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 1 |

**Wiederkehrende Klassen dieses Laufs** (Modul 5 §Closure-Regeln, dritte Speisungs-Quelle):
keine der vier Klassen aus Runde 2 tritt erneut auf. Neu und je einmalig: *inventar-abhängiger
Messwert im Skript-Kommentar ohne Kommando* · *Commit-Message ohne Traceability-Kennung* ·
*Beleg-Aussage über einen baum-abgeleiteten Schlüssel ohne Blick auf dessen Bezugsmenge*. Keine
erreicht in dieser Sitzung die zweite Nennung; die Steering-Loop-Schwelle bewegt sich durch
diesen Lauf nicht.

## Verdikt

**Merge-blockierend: nein.** Kein HIGH, kein MEDIUM.

Alle vier Befunde aus Runde 2 tragen, und sie tragen **belegt statt behauptet**: Die drei
DoD-Häkchen sind byte-identisch mit der Planner-Fassung wiederhergestellt — das ist mehr als
„zurückgesetzt", es ist nachweislich keine neue Aussage. Die zwei falschen Kommentar-Begründungen
sind gegen eine **eigene, unabhängige Messung** korrigiert, die ich hier nicht aus Runde 2
übernommen, sondern neu gefahren habe (45 / 1 / 10 Befunde, je EXIT 1, gegen Kopien außerhalb des
Repos unter dem gepinnten Digest) — der ausführende Lauf hat die Werte abgeschrieben, sie stimmen
trotzdem. Die Regelwerk-Berufung nennt ihren Mess-Tag und zitiert nachgeprüft richtig. Die
Slice-Plan-Berufung ist ersatzlos entfallen, ohne eine zweite rangfremde Quelle an ihre Stelle zu
setzen.

Der Commit ist **eng geschnitten geblieben** — fünf Dateien, 15/14 Zeilen, kein Rename, keine
Gate-Konfiguration, kein fremdes Rollen-Artefakt. Die Fehler-Klasse aus Runde 2 (eine Behebung,
die neue Substanz mitbringt) tritt nicht auf; die einzige neue Substanz überhaupt ist die Zahl
`45` in Fall 288, und die ist gemessen richtig.

Was offen bleibt, blockiert nicht:

- **LOW-1** ist eine Wartungsfalle, kein Fehler: Die Zahl stimmt heute und wandert mit dem
  `open/`-Bestand. Sie trägt nichts, was die Zusage des Wächters stützt — die steht im Satz
  daneben.
- **LOW-2** ist eine Traceability-Formalie mit ambivalenter Bezugseinheit; über die Slice-Kette
  ist sie erfüllt, über den einzelnen Commit nicht. Der Commit steht noch lokal.
- **INFO-1** ist die Übergabe an die Verifikation und ausdrücklich kein Review-Befund: Die
  Sach-Begründung des ausgelassenen `make mutate`-Laufs ist dreifach belegt richtig, der
  Beleg-Slot deckt den heutigen Baum aber nicht — ein Lauf fährt voll statt überzuspringen.

**Reif für den Verifier: ja**, mit INFO-1 als benannter Ausgangslage.
