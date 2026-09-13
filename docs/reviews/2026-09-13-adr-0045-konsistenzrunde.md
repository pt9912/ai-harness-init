# Konsistenzrunde ADR-0045 — der `authority`-Wechsel senkt eine Richtung

**Rolle:** Reviewer · **Datum:** 2026-09-13 · **Typ:** ADR-Konsistenzrunde (kein Slice-Review) ·
**Gegenstand:** [`ADR-0045`](../plan/adr/0045-authority-wechsel-senkt-eine-richtung.md),
Status `Proposed`, Commit `ede6b7fb` ·
**Stand des Baums:** `f9b3c60f` (Implementer, Festlegung 3 ausgeführt), `git status --porcelain` leer ·
**Auslöser:** [`2026-09-13-slice-225-gate-index-steht-einmal.md`](2026-09-13-slice-225-gate-index-steht-einmal.md) HIGH-1 ·
**Constraints:** [`ADR-0043`](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) ·
[`ADR-0044`](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) ·
[`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) ·
[`AGENTS.md`](../../AGENTS.md) §3.4 · §3.5 · §3.6 · §3.7 · §3.9 ·
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)

**Schnitt dieses Laufs.** Geprüft sind die drei Sonden des Acceptance-Triggers, die Konsistenz
gegen die zwei Nachbar-ADRs und §3.5, die sechs Re-Evaluierungs-Trigger und die Abgrenzungen unter
§Was diese Entscheidung nicht tut. Alle Sonden sind **selbst gefahren**, gegen `git archive`-Kopien
außerhalb des Repos, netzlos, Mount `:ro`, über den in [`d-check.mk`](../../d-check.mk) gepinnten
Digest; die Kopien sind nach dem Lauf entfernt. Im Arbeitsbaum liefen nur lesende Kommandos, er ist
unverändert. Alle Zahlen stehen neben dem Kommando, das sie liefert — **keine Erwartungswerte**.

---

## Sonden des Acceptance-Triggers — alle drei reproduzieren

Gemeinsamer Aufbau, in jeder Kopie identisch: ein neues Rezept `probe-tool` mit `##`-Hilfetext ans
Ende des `Makefile`, eine Tabellenzeile dafür, **kein** `exempt-targets`-Eintrag.

```sh
git archive <ref> | tar -x -C <kopie>          # 99bfd1c5^ | fae7b7d1
printf '\nprobe-tool: ## Sonde\n\t@true\n' >> Makefile
REF="ghcr.io/pt9912/d-check@$(sed -n 's/^DCHECK_DIGEST ?= //p' d-check.mk)"
docker run --rm --network none -v "$PWD":/repo:ro "$REF" --config /repo/.d-check.yml --enable targets
```

**Sonde 1 — Tabellenzeile in der Werkzeuge-Tabelle von `harness/README.md`, über beiden Bäumen.**

```text
99bfd1c5^  (authority: AGENTS.md)          1231 Datei(en) geprüft, 1 Befund(e)   EXIT 1
           Makefile:429  probe-tool  gate-undocumented
           "Makefile-Regel `probe-tool` ohne Deklaration in der Autoritäts-Doku AGENTS.md"
fae7b7d1   (authority: harness/README.md)  1232 Datei(en) geprüft, 0 Befund(e)   EXIT 0
```

Reproduziert, einschließlich der Datei-Zahlen und des Grund-Codes. **Die Senkung ist real:** ein
Zustand, den der Gate vorher zurückwies, geht jetzt durch. Festlegung 1 trägt.

**Sonde 2 — dieselbe Zeile, aber in der Gate-Tabelle `AGENTS.md` §4, über dem alten Baum.**

```text
99bfd1c5^  (authority: AGENTS.md)          1231 Datei(en) geprüft, 0 Befund(e)   EXIT 0
```

Reproduziert. **Der Review-Vorschlag *„ein Nicht-Gate steht nicht in §Sensors"* ist damit
widerlegt:** Das Modul hat nie zwischen Gate und Nicht-Gate unterschieden, ein solcher Wächter
stellte nichts wieder her, und er träfe die Senkung auch nicht — das durchgelassene Rezept steht in
§Werkzeuge. Die Zurückstellung unter §Was diese Entscheidung nicht tut ist belegt, nicht behauptet.

**Sonde 3 — der repo-eigene Wächter, heutige Fassung, in vier Ausprägungen.** Gefahren wurde
`make test-bats` (gepinntes `bats`-Bild, `--network none`, `:ro`) über je einer Kopie von
`f9b3c60f` (Regel-Menge, Festlegung 3 ausgeführt) und `ede6b7fb` (`.PHONY`-Menge, Fassung der ADR);
Sonden-Rezept jeweils mit Werkzeuge-Zeile und ohne `exempt-targets`-Eintrag.

| Baum / Bindung | Sonde | Ergebnis |
|---|---|---|
| `f9b3c60f` — Makefile-Regel-Namen | `probe-tool` **mit** `.PHONY` | `not ok 262 jede Makefile-Regel ohne Tabellenzeile …` |
| `f9b3c60f` — Makefile-Regel-Namen | `probe-no-phony` **ohne** `.PHONY` | `not ok 262 jede Makefile-Regel ohne Tabellenzeile …` |
| `ede6b7fb` — `.PHONY`-Namen | `probe-tool` **mit** `.PHONY` | `not ok 262 jedes .PHONY-Target ohne Tabellenzeile …` |
| `ede6b7fb` — `.PHONY`-Namen | `probe-no-phony` **ohne** `.PHONY` | `ok 262` — **blind** |

Die heutige Fassung fängt **beide** Fälle: den, den das Modul durchlässt, und den, für den die
Fassung der ADR blind war. Festlegung 2 und Festlegung 3 tragen, und der gemessene Rest ist
geschlossen. Unbeprobt grün ist der Wächter im Bestand:

```sh
docker run --rm --network none -v "$PWD":/code:ro -w /code <BATS_IMAGE> test/targets-modul-wiring.bats
# 1..7 — alle ok, EXIT 0
```

*Nebenbefund ohne Bezug zur ADR:* In allen vier Vollläufen fällt zusätzlich
`test/mutate-driver.bats:103` (`[ -e "$dest/.git" ]`) — eine `git archive`-Kopie trägt kein `.git`.
Kopie-Artefakt, kein Befund.

---

## Findings

### MEDIUM-1 — Die ADR adressiert dreimal einen Abschnitt, den `ADR-0043` nicht führt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.4 (ab `Accepted` immutabel); [`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1 (auflösbarer Zeiger)
- **pfad:** `docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md:10`, `:272`, `:379`
- **klasse:** Sektions-Adresse in einem einfrierenden Artefakt löst nicht auf

`ADR-0045` nennt an drei Stellen *„[ADR-0043] §Was diese Entscheidung nicht tut"*. `ADR-0043` führt
diesen Abschnitt nicht und hat ihn nie geführt:

```sh
grep -n 'Was diese Entscheidung nicht tut\|Was beide Festlegungen nicht tun' \
  docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md
# 428:### Was beide Festlegungen nicht tun
git log --oneline -S'### Was diese Entscheidung nicht tut' -- docs/plan/adr/0043-*.md   # leer
grep -c 'Was diese Entscheidung nicht tut' docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md   # 5
```

Zwei der fünf Treffer (`:157`, `:235`) meinen den **eigenen** Abschnitt und sind richtig; die
anderen drei zeigen auf `ADR-0043`. Der zitierte Wortlaut selbst steht dort verbatim
(`0043-…md:444-447`) — falsch ist allein die Adresse, und sie steht unter anderem **im
Acceptance-Trigger**, also in dem Satz, der diese Runde beauftragt.

**Failure-Szenario:** Ein späterer Lauf — etwa der Retirement-Check zu Festlegung 2 — sucht in
`ADR-0043` nach dem genannten Abschnitt, findet ihn nicht und kann nicht unterscheiden, ob der
Rückverweis falsch ist oder die zurückgestellte Frage nie gestellt wurde. Nach `Accepted` friert
§3.4 den Trigger-Abschnitt und die §Geschichte-Zeile mit ein; die Korrektur kostet dann eine
Folge-ADR mit `Supersedes` statt dreier Wörter.

- **verifizierbar:** nein — kein Modul der [`.d-check.yml`](../../.d-check.yml) hält eine
  Prosa-`§`-Nennung gegen die Überschriften der genannten Datei (`links`/`anchors` greifen an
  Link-Fragmenten, und diese drei Nennungen tragen keines). Nachprüfbar durch die Kommandos oben.

### MEDIUM-2 — §Kontext und §Fitness Function zitieren einen Testnamen, den Festlegung 3 vor dem Accept abgeschafft hat

- **kategorie:** MEDIUM
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6); [`AGENTS.md`](../../AGENTS.md) §3.4
- **pfad:** `docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md:161-162`, `:173`, `:338`
- **klasse:** eingefrorene Zusage, die die eigene Festlegung vor dem Accept aufhebt

Die §Fitness-Function-Tabelle führt unter *„Gebaut: einer"* den Wächter mit dem Testnamen
*„jedes .PHONY-Target ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in
exempt-targets"*. Festlegung 3 derselben ADR verlangt den Umstieg auf die Regel-Menge; `f9b3c60f`
hat ihn ausgeführt und den Test dabei umbenannt:

```sh
grep -c 'jedes .PHONY-Target ohne Tabellenzeile' test/targets-modul-wiring.bats   # 0
grep -n '^@test' test/targets-modul-wiring.bats | sed -n '6p'
# 90:@test "jede Makefile-Regel ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets" {
grep -c 'kein exempt-targets-Eintrag ist zugleich eine Sensors-Tabellenzeile' test/targets-modul-wiring.bats   # 1
```

Zeile 2 der Tabelle löst also auf, Zeile 1 nicht. Dasselbe gilt für die §Kontext-Stellen: der
Sonden-Block bei `:170-176` zeigt für die Ausprägung *ohne* `.PHONY` ein `ok` — über `f9b3c60f`
liefert dieselbe Sonde `not ok` (Sonde 3 oben).

**Failure-Szenario:** Die §Fitness-Function-Tabelle ist die Stelle, an der ein Lauf nachsieht,
**welcher** Sensor eine Festlegung hält. Wer den dort genannten Testnamen sucht, findet nichts und
liest die Zeile als halluzinierten Gate — dieselbe Klasse, gegen die `LH-QA-01` steht. Nach
`Accepted` ist die Zeile eingefroren.

- **verifizierbar:** nein — `make comment-claims` prüft genannte Sensoren nur in seinem
  Prüfbereich (`internal/**`, `cmd/**`, `harness/tools/*.sh`, `.claude/hooks/*.sh`), keine
  Markdown-Datei und kein `test/*.bats`. Nachprüfbar durch die Kommandos oben.

### MEDIUM-3 — Re-Evaluierungs-Trigger 2 feuert auch im Gegenzustand

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-06-roadmap.md` §Roadmap-Regeln (*„Ein Trigger ist
  beobachtbar dann, wenn ein anderer Mensch ohne Rückfrage sagen kann, ob er eingetreten ist"*);
  [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md:360-362`
- **klasse:** Observable eines Triggers deckt den Gegenzustand mit ab

Trigger 2 lautet *„Wenn `harness/README.md` nur noch eine `make X`-Tabelle trägt (beobachtbar
daran, dass die §Sensors-Zeilenzahl und die Datei-Zeilenzahl der beiden `grep -c`-Kommandos oben
gleich sind): … die Senkung wäre weg, Option D faktisch eingetreten"*. Heute sind die zwei Zahlen
28 und 11. Gleich werden sie in **zwei** Zuständen, und der zweite ist das Gegenteil des
beschriebenen: Der Abschnitts-Scope des Wächters endet an der nächsten Überschrift
(`test/targets-modul-wiring.bats:56`, das `exit` ihrer `awk`-Zeile). Die Ziel-Form `v6.7.2` führt
die Werkzeuge-Tabelle **ohne** Überschrift — als fette Zeile:

```sh
awk 'NR>=67 && NR<=154 && /^#/' .harness/baseline/v6.7.2/templates/harness/README.template.md
# ## Sensors (Feedback-Gates)
# ## Traceability rules            <- kein ### dazwischen
grep -nE '^#{1,3} ' harness/README.md | sed -n '5,6p'
# 40:## Sensors (Feedback-Gates)
# 60:### Werkzeuge (kein Gate)      <- dieses ### traegt die Kompensation
```

Gegenprobe an einer Kopie, in der allein dieses `###` die Ziel-Form-Gestalt annimmt: beide
`grep -c`-Zahlen werden **28 = 28**, also „Trigger eingetreten", während die Werkzeuge-Tabelle
unverändert in der Autoritäts-Datei steht und die Senkung fortbesteht.

**Failure-Szenario:** Ein Lauf, der die Pflichtgliederung der regierenden Fassung weiter übernimmt
(`ADR-0044`, Vorgabe *vollständig übernehmen*), liest den Trigger als eingetreten und schließt
*„die Senkung ist an der Wurzel weg"* — während sie in Wahrheit unkompensiert ist. Nach `Accepted`
ist der Trigger eingefroren.

**Was den Schaden begrenzt, und es steht nicht in der ADR:** In genau diesem Zustand färbt der
Wächter rot, und zwar laut — gefahren an derselben Kopie:

```text
not ok 6 jede Makefile-Regel ohne Tabellenzeile im Sensors-Abschnitt steht genau einmal in exempt-targets
not ok 7 kein exempt-targets-Eintrag ist zugleich eine Sensors-Tabellenzeile
```

Der Zustand kann also nicht still eintreten. Falsch bleibt die **Schlussfolgerung**, die der
Trigger aus seiner eigenen Messung zieht.

- **verifizierbar:** ja, in einer Richtung — `make test` färbt im beschriebenen Zustand rot
  (Ausgabe oben). Dass der Trigger ihn dennoch als Option-D-Eintritt liest, liest kein Gate.

### MEDIUM-4 — Festlegung 2 belastet eine Stelle, die von ihrer Belastung nichts weiß (nicht blockierend)

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Rang-Zeiger*; der Kommentar schreibt an
  den, der die Stelle ändert)
- **pfad:** `test/targets-modul-wiring.bats:49-54` (Kommentar über `authority_table_targets()`, `:55`)
- **klasse:** feedforward-Norm ohne Zeiger an der belasteten Stelle

Festlegung 2 erklärt den §Sensors-Scope von `authority_table_targets()` zum Träger der Senkung und
sein Entfernen oder Verbreitern zu einem eigenen §3.5-Fall. Der Kommentar über genau dieser
Funktion begründet den Scope unverändert allein damit, dass der Test sonst gegen die eigene
Werkzeuge-Tabelle liefe. `f9b3c60f` hat drei Nachbar-Stellen erreicht und diese eine nicht:

```sh
grep -n 'ADR-0045' test/targets-modul-wiring.bats harness/sensors/docs-check.md
# test/targets-modul-wiring.bats:9      — Dateikopf, Festlegung 3 (Zielmengen-Wechsel)
# harness/sensors/docs-check.md:139     — Festlegung 1/2
grep -c 'ADR-0045\|3\.5' test/targets-modul-wiring.bats   # 1 (nur die Zeile 9)
```

**Failure-Szenario:** Wer die Datei ändert, liest den Funktionskommentar, hält den Scope für eine
Bequemlichkeit und verbreitert ihn. `make gates` bleibt grün — Trigger 5 der ADR sagt das
ausdrücklich zu —, und Festlegung 2 ist still gebrochen. Der einzige Träger, den die ADR nennt, ist
der Rollen-Wechsel vor der Änderung; an der Stelle selbst löst ihn nichts aus.

**Warum nicht blockierend.** Die Belastung einer bestehenden Stelle durch eine ADR ist normativ
**legitim**: Die ADR steht auf Rang 4 der Source Precedence, der Kommentar auf keinem
([`AGENTS.md`](../../AGENTS.md) §3.7, *ein Kommentar sitzt in keinem davon*). Eine Änderung an der
Stelle ist deshalb nicht Voraussetzung der Wirksamkeit, sondern ihres Wirkungsgrads. Und die ADR
**verschweigt die Lücke nicht**: §Konsequenzen führt sie als benannten Negativposten samt
`LH-QA-01`-Bezug, Trigger 5 nennt sie feedforward. Genau das verlangt `LH-QA-01` — benennen statt
behaupten. Der Befund bleibt als Abdeckungslücke stehen, nicht als Widerspruch.

- **verifizierbar:** nein — kein Modul und kein `make`-Ziel liest den Prüfbereich eines bats-Tests;
  die ADR stellt das selbst fest.

### LOW-1 — „Rot gesehen, in beiden Ausprägungen" über einem Block, der ein Rot und ein Grün zeigt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (beschreibt, was da ist)
- **pfad:** `docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md:167`
- **klasse:** Überschrift eines Belegblocks widerspricht seinem Inhalt

Der Satz kündigt zwei rote Ausprägungen an; der Block darunter zeigt `not ok` für die
`.PHONY`-Variante und `ok` für die andere — Letzteres ist der **Beleg für den Rest**, den
Festlegung 3 schließt, und damit das Gegenteil von rot. Gemeint ist erkennbar *„in beiden
Ausprägungen gefahren"*.

- **verifizierbar:** nein.

### LOW-2 — „ändert keine Datei außer sich selbst und dem ADR-Index" gegen den eigenen Bezug-Vermerk

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md:330` gegen `:16-18`
- **klasse:** Footprint-Zusage steht neben einer Folgepflicht, die sie ausschließt

Das Bezug-Feld vermerkt zu [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
*„die Korrektur eines Zustandsfelds dort ist Folgepflicht, keine Festlegung"* — gemeint ist
§Baseline von `harness/conventions.md`. §Konsequenzen schließt dieselbe Datei aus. Der Commit
`ede6b7fb` hat sie geändert:

```sh
git show --stat --format= ede6b7fb | sed -n '2,5p'
# docs/plan/adr/README.md          | 1 +
# harness/conventions.md           | 5 +-
# harness/conventions/MR-057-…     | 2 +
# harness/conventions/MR-058-…     | 91 +++++
```

Die drei zusätzlichen Dateien sind Architect-Artefakte und der Commit-Zuschnitt nach
[`AGENTS.md`](../../AGENTS.md) §3.8 ist damit korrekt (kein Finding); die Nachbar-ADR `ADR-0043`
formuliert denselben Satz an derselben Stelle vollständig (*„… , dem ADR-Index und §Baseline von
`harness/conventions.md`"*, `0043-…md:539-540`).

- **verifizierbar:** nein.

### LOW-3 — Das Bezug-Feld sagt „fordert", wo §Kontext „empfiehlt" misst

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) (Aussage neben ihrer Messung); [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md:14-15` gegen `:88-92`
- **klasse:** Feld überzeichnet die Stärke der eigenen Messung

Das Bezug-Feld schreibt, die Ziel-Form *„fordert"* den Wechsel. Gemessen ist ein **auskommentierter**
Vorschlagsblock:

```sh
grep -n 'authority: harness/README.md' .harness/baseline/v6.7.2/templates/.d-check.yml
# 31:#   authority: harness/README.md    # dieselbe Datei — es gibt nur einen Index
```

§Kontext sagt darum korrekt *„empfiehlt"*. Die drei tragenden Gründe der ADR (Tabelle in
`AGENTS.md` §4 gestrichen · Schlüssel nimmt eine Datei · Auftraggeber-Vorgabe) hängen an dieser
Wortwahl nicht — die Alternativlosigkeit bleibt belegt.

- **verifizierbar:** nein.

### INFO-1 — Trigger 4 ist mit `f9b3c60f` gegenstandslos geworden, und zwar korrekt

Trigger 4 (*„Wenn eine Makefile-Regel ohne `.PHONY`-Eintrag entsteht, **solange Festlegung 3 offen
ist**"*) trägt seine Vorbedingung im Text und schaltet sich damit selbst ab, nachdem Festlegung 3
ausgeführt ist. Das ist die richtige Bauart für einen Trigger, der einfriert — im Unterschied zu
MEDIUM-2, wo dieselbe Zeitachse **ohne** Vorbedingung formuliert ist. Kein Befund, als Kontrast
notiert.

### INFO-2 — Die Kompensation hängt an einer Überschriftenebene, die die Ziel-Form nicht führt

Der Träger aus Festlegung 2 funktioniert nur, solange `harness/README.md` die Werkzeuge-Tabelle
unter einem eigenen `###` führt (Messung in MEDIUM-3). Die ADR argumentiert gegen Option D mit
*„die Ziel-Form setzt beide Tabellen in §Sensors"* — dieselbe Ziel-Form setzt dort **keine**
Zwischenüberschrift. Der Zustand ist laut (Wächter rot, MEDIUM-3), also keine stille Falle; die
Abhängigkeit steht in der ADR aber an keiner Stelle.

### INFO-3 — Beim Prüfen der `ignore-refs`-Abgrenzung gemessen: die Zahl in `AGENTS.md` §3.11 ist gewandert

**Außerhalb des Gegenstands dieser Runde, nicht verdikt-relevant** — `ADR-0045` fasst
[`.d-check.yml`](../../.d-check.yml) nicht an. Beim Nachfahren der Abgrenzung fiel auf:

```sh
grep -c '^  - in: ' .d-check.yml                 # 7
grep -n "grep -c '\^  - in: '" ../../AGENTS.md   # 458:  … # 4
```

`AGENTS.md` §3.11 führt die Zahl mit Mess-Stand und nach
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2 ausdrücklich als wandernden Wert neben ihrem Kommando; die begründende Aussage
(*„jedes weitere Paar bleibt eine Senkung nach §3.5 mit eigener ADR"*) hängt nicht an ihr. Notiert,
weil ein späterer Lauf sonst denselben Weg zweimal geht — die Stelle gehört dem Architect.

---

## Negativbefunde (geprüft, ohne Befund)

- **Die drei Sonden des Acceptance-Triggers.** Selbst gefahren, alle drei reproduzieren
  einschließlich Datei-Zahlen und Grund-Code (Abschnitt oben). Die geforderte Runde ist damit
  geleistet; die Nachmessung des auflösenden Kontexts ist nach
  [`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
  nicht ersetzt worden, sondern unabhängig wiederholt.
- **Festlegung 1 trägt.** Die Senkung ist rot-gegen-grün belegt, und der dritte Weg
  (*„Mengen-Differenz leer, also kein §3.5-Fall"*) ist ausdrücklich verworfen. `AGENTS.md` §3.5
  verlangt für eine Senkung eine ADR — genau das ist diese Datei. Kein Widerspruch zu §3.5, und
  §3.5 bekommt keine zweite Fassung (`git show ede6b7fb --stat` berührt `AGENTS.md` nicht).
- **Festlegung 2 und 3 kompensieren vollständig.** Die Zielmenge des Wächters und die des Moduls
  sind jetzt dieselbe: `grep -hE '^[a-zA-Z][a-zA-Z0-9._-]*:' Makefile d-check.mk` gegen
  `makefiles: [Makefile, d-check.mk]`. Der Test ist eine **Gleichheit** (`diff undocumented exempt`)
  und fängt beide Richtungen; die Disjunktheits-Prüfung fängt die dritte. Sonde 3 belegt
  den Fall, den das Modul durchlässt, in beiden `.PHONY`-Ausprägungen.
- **Der gemessene Rest ist wirklich leer.** `comm -23` über Regel-Menge gegen `.PHONY`-Menge ist
  leer, beide zählen **48** (`| wc -l` auf dieselben zwei Pipelines); der Umstiegs-`diff` aus
  Festlegung 3 ist leer. Beide am Stand `f9b3c60f` nachgefahren.
- **Alle §Kontext-Messungen reproduzieren.** 4 Schlüssel im `targets`-Block, 0 Treffer auf
  `heading|section|scope` (Exit 1); ``git show 99bfd1c5^:AGENTS.md | grep -cE '^\| `make '`` → 11;
  ``grep -cE '^\| `make ' AGENTS.md`` → 0; README gesamt 28, §Sensors 11; `exempt-targets` 37;
  Schnitt 17; Vorlagen-Kommentar 1; Ziel-Form-Überschriften 67 · 140 · 154. **Keine
  Erwartungswerte** — alle am Stand `f9b3c60f` bzw. am gepinnten Digest gefahren.
- **Konsistenz gegen `ADR-0043`.** Dessen `### Was beide Festlegungen nicht tun` stellt die Frage
  wörtlich zurück (*„… entscheidet der Durchgang bzw. die ADR, die er auslöst"*, `:444-447`) und
  führt die Architect-Folgepflicht (`:535-538`). `ADR-0045` beantwortet beide. `ADR-0043` misst
  allein, dass der Deckungs-Rest null ist, und zieht daraus **keine** §3.5-Folgerung — Festlegung 1
  widerspricht ihm also nicht, sie schließt die Lücke. Inhaltlich kein Konflikt; der Adressfehler
  ist MEDIUM-1.
- **Konsistenz gegen `ADR-0044`** (`Accepted`). Dessen `### Was beide Festlegungen nicht tun`
  stellt dieselbe Frage zurück und trennt sauber *„**Dass** die Pflichtgliederung übernommen wird"*
  (Auftraggeber) von *„**wie** `targets.authority` … nachgezogen wird"* (der auslösenden ADR).
  `ADR-0045` bleibt in der zweiten Hälfte und lässt die regierende Fassung `v6.7.2` unberührt.
- **Die sechs Re-Evaluierungs-Trigger, einzeln gemessen.** 1 — Heading-Scoping: `0` Treffer im
  Schema, nicht eingetreten. 2 — Ein-Tabellen-Zustand: 28 gegen 11, nicht eingetreten (Observable
  aber defekt, MEDIUM-3). 3 — `authority` nimmt mehrere Dateien: Schema führt einen Wert, nicht
  eingetreten. 4 — Regel ohne `.PHONY` bei offener Festlegung 3: Vorbedingung entfallen, kann nicht
  mehr eintreten (INFO-1). 5 — Scope entfernt/verbreitert: `authority_table_targets()` steht
  unverändert, nicht eingetreten. 6 — Gate in §Sensors ohne `gates`-Bindung: der `diff` aus Option F
  gibt genau `> record-gates` aus, nicht eingetreten. **Keiner der sechs ist heute eingetreten.**
- **Die vier Abgrenzungen sind Abgrenzungen, keine verdeckten Lieferungen.** *Bindung an den
  `gates`-Abschluss* — nichts geändert, der Griff steht mit Messung und wandert als Trigger 6 in
  die Zukunft; der `diff` ist nachgefahren. *Werkzeuge-Tabelle herausziehen* — `harness/README.md`
  trägt beide Tabellen unverändert, der Ausschluss ist mit der Ziel-Form begründet. *Emittierte
  Ebene* — `internal/emit/**` ist im Diff nicht berührt, `MR-054` bleibt zuständig. *`ignore-refs`* —
  `git show ede6b7fb --stat --format= -- .d-check.yml` ist leer — die ADR fasst die Gate-Config
  nicht an, die Aufnahme-Grenzen bleiben wie `AGENTS.md` §3.11 sie führt. Der
  Cutoff-Punkt unter derselben Überschrift ist eine Nichtrückwirkungs-Aussage und dort richtig
  platziert.
- **Kein neues Gate, keine Gate-Lockerung ohne ADR.** Die `modules:`-Liste ist unverändert
  (`links, anchors, ids, matrix, codepaths, spans, planning, targets`), `exempt-targets` hat 37
  Einträge wie vor dem Wechsel, und der einzige Strengeverlust ist der gebuchte. Festlegung 3 ist
  eine **Verschärfung** des repo-lokalen Wächters und braucht nach §3.5 keine eigene ADR.
- **ADR-Form und Index.** `docs/plan/adr/README.md:52` führt `ADR-0045` mit Titel, Status
  `Proposed` und Bezügen. Pflichtabschnitte der Ziel-Form sind vollständig (Kontext · Entscheidung ·
  Verglichene Alternativen · Konsequenzen · Fitness Function · Re-Evaluierungs-Trigger ·
  Geschichte); acht Optionen A–H sind verglichen, die gewählte ist markiert.
- **`AGENTS.md` §3.9 Docker-only.** Alle Sonden liefen über `make`-Ziele bzw. den gepinnten Digest,
  `--network none`, Mount `:ro`; keine Host-Toolchain in Befehlsposition.
- **Arbeitsbaum unberührt.** `git status --porcelain` vor und nach den Sonden leer, HEAD
  unverändert `f9b3c60f`; alle Kopien lagen außerhalb des Repos und sind entfernt.
- **Nicht geprüft, ausdrücklich:** `make gates` als Ganzes (fährt der Auftraggeber) · `make mutate`,
  `make full-smoke`, `make smoke` · die DoD-Abhakung und die Slice-Closure von `slice-225`
  (Verifier bzw. Planner) · die emittierte Ebene (`internal/emit/**`) · `MR-058` als Eintrag für
  sich (er löst MEDIUM-1 des Vorgänger-Reports und ist nicht Gegenstand dieser Runde) · die drei
  Folgepflichten der ADR auf ihre Fälligkeit hin · ob `harness/sensors/docs-check.md` nach
  `f9b3c60f` in **allen** Aussagen trägt (geprüft ist allein die `authority`-Passage) · die
  Alternativen A–G einzeln auf Vollständigkeit ihrer Contra-Spalten.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 4 | Sektions-Adresse löst nicht auf · eingefrorene Zusage, die die eigene Festlegung aufhebt · Observable deckt den Gegenzustand · feedforward-Norm ohne Zeiger an der belasteten Stelle |
| LOW | 3 | Überschrift widerspricht dem Belegblock · Footprint-Zusage gegen eigene Folgepflicht · Feld überzeichnet die eigene Messung |
| INFO | 3 | selbstabschaltender Trigger (Kontrast) · undeklarierte Abhängigkeit von einer Überschriftenebene · gewanderte Zahl außerhalb des Gegenstands |

---

## Verdikt

**Der Beleg für den Accept-Übergang trägt noch nicht — blockierend wegen MEDIUM-1, MEDIUM-2 und
MEDIUM-3.**

**Die Substanz trägt.** Alle drei Sonden des Acceptance-Triggers sind unabhängig gefahren und
reproduzieren exakt: Die Senkung ist real (1 gegen 0 Befunde über den beiden Bäumen), der
naheliegende Gegengriff ist widerlegt (ein Nicht-Gate in der Gate-Tabelle war **vorher schon**
grün), und der repo-eigene Wächter fängt in seiner heutigen Fassung beide Fälle — den, den das
Modul durchlässt, und den, für den er gestern blind war. Festlegung 1 bucht richtig, Festlegung 2
bindet einen Träger, der läuft und rot wird, Festlegung 3 ist ausgeführt und schließt den Rest. Zu
`ADR-0043`, `ADR-0044` und `AGENTS.md` §3.5 besteht **kein** inhaltlicher Widerspruch, keiner der
sechs Trigger ist eingetreten, und die vier Abgrenzungen liefern nichts verdeckt.

**Blockierend ist nicht der Inhalt, sondern was einfrieren würde.** Drei Aussagen der Datei sind
heute falsch: eine Sektions-Adresse, die `ADR-0043` nie trug und die ausgerechnet im
Acceptance-Trigger steht; ein Testname in der §Fitness-Function-Tabelle, den die eigene Festlegung 3
vor dem Accept abgeschafft hat; und ein Trigger-Observable, das im gemessenen Gegenzustand ebenfalls
zutrifft. Solange die Datei `Proposed` ist, kosten alle drei zusammen wenige Zeilen; nach
`Accepted` friert `AGENTS.md` §3.4 sie ein, und jede Korrektur ist eine Folge-ADR mit `Supersedes`.
Diese Asymmetrie ist der Grund für das Verdikt — nicht die Schwere der einzelnen Stelle.

**MEDIUM-4 blockiert ausdrücklich nicht:** Eine ADR darf eine bestehende Stelle belasten, ohne sie
anzufassen, und die Lücke ist in §Konsequenzen und Trigger 5 offen benannt statt verschwiegen.

**Kennung dieses Reports** für die Accept-Zeile nach
[`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1:
`2026-09-13-adr-0045-konsistenzrunde`. Den Übergang vollzieht der Architect, nicht dieser Lauf.
