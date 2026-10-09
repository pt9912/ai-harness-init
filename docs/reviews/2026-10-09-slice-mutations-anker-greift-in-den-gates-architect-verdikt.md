# Slice-Closure slice-mutations-anker-greift-in-den-gates — Architect-Verdikt (3b)

- **Rolle:** Architect · **an:** Planner (3c), Reviewer (Skill-Zeile) · **Eingang:** Review
  `2026-10-09-slice-mutations-anker-greift-in-den-gates`, Befunde M-2 und M-3 · **Bezug:**
  [ADR-0085](../plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md) Festlegung 1,
  [ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md),
  [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
  [`AGENTS.md`](../../AGENTS.md) §3.6/§3.9, Baseline-Regelwerk `v6.17.0`, `modul-06-roadmap.md`
  §Das Beobachtungs-Register
- **Ergebnis:** ein Eintrag *verkörpert* (Zielort gehört dem Reviewer, Text unten); M-3 bekommt keinen
  Eintrag. Keine ADR, kein `MR`, keine Hard Rule geändert.

## 1 — `teilzeichenketten-suche-bindet-einen-pfad-nicht-an-seine-grenze` (3. Beleg)

**Verdikt: verkörpert.** Zielort `.harness/skills/reviewer.md` §Klassifikation, Block *LOW/INFO mit
Eskalation*, Anker `seit slice-mutations-anker-greift-in-den-gates`. Die Zeile schreibt der Reviewer
(ADR-0028), nicht dieser Lauf.

M-2 gehört in die Klasse: `grep -F -- " $f"` bindet `a.txt` an die Grenze davor, nicht an die danach,
und trifft `a.txt.bak`. Die drei Belege teilen die Form *Zugehörigkeit per Teilzeichenkette statt per
Gleichheit oder Grenze*, gleich ob Go (`strings.Contains`) oder Shell (`grep -F`). Alle drei fand das
Review mit einer Grenz-Sonde. Der Träger trägt also, ihm fehlte nur die Zeile, die ihn bindet.

**Kein mechanischer Sensor möglich.** Ein Lint-Muster müsste entscheiden, ob der gesuchte Operand eine
Kennung oder einen Pfad meint (Grenze nötig) oder ein Textstück einer Meldung (Teilzeichenkette ist die
gewollte Zusicherung). Das trägt die Syntax nicht:

```sh
git grep -c 'strings.Contains' -- '*_test.go' | awk -F: '{s+=$2} END{print s}'   # 394
git grep -cE 'grep -[a-zA-Z]*F' -- '*.sh'       | awk -F: '{s+=$2} END{print s}'   # 208
```

(keine Erwartungswerte). Die Treffer sind überwiegend Meldungstexte. Ein Muster darüber wäre
heuristisch und brächte Fehlalarme, also ein Gate, das *manchmal* rot sein darf (Modul 13). Die drei
Behebungen zeigen zudem drei Formen (Wortgrenzen-Regex, Wortgrenze, Gleichheit über assoziatives
Array), keine gemeinsame Ersatz-API, auf die ein Lint verweisen könnte. Neue Möglichkeit wäre eine
typisierte Hilfe (`containsPath`) im Bestand, dann ließe sich `strings.Contains` mit Pfad-Operand in
Testdateien verbieten. Das ist ein akzeptiertes Negativ, kein Auftrag.

**Text der Skill-Zeile (an den Reviewer):**

> - **Zugehörigkeit per Teilzeichenkette statt per Grenze** — prüft ein Test, Wächter oder Treiber,
>   ob ein Pfad, eine Kennung oder ein Wort in einem Text oder einer Liste vorkommt, per
>   Teilzeichenkette (`strings.Contains`, `grep -F`, Präfix), ohne Grenze davor **und** danach? Der
>   Reviewer fährt die Grenz-Sonde: ein fremder Wert, der den erwarteten enthält, auf ihn endet oder
>   mit ihm beginnt (`go` in „hexagonal", `a.txt` neben `a.txt.bak`, ein vorangestelltes
>   Verzeichnis-Segment), und liest, ob das Urteil kippt. Kippt es: INFO; LOW, wenn der fremde Wert
>   im Bestand oder in der zugesagten Eingabe-Menge vorkommen kann; HIGH, wenn kein Gate die Folge
>   meldet (Stilles-Grün-Pfad). Ein Textstück einer Meldung ist kein Fall dieser Zeile. Gilt für
>   Prüfungen, die der Diff anlegt oder ändert, nicht für den Bestand. Kein Gate fängt das: ob ein
>   Operand Kennung oder Meldungstext ist, entscheidet die Syntax nicht; Träger ist dieser Review
>   ([`AGENTS.md`](../../AGENTS.md) §3.6)
>   (seit slice-mutations-anker-greift-in-den-gates)

**`state.md` für den Planner:**

```markdown
**Stand:** verkörpert

Zielort: [`.harness/skills/reviewer.md`](../../../../../../.harness/skills/reviewer.md), Eintrag *„Zugehörigkeit
per Teilzeichenkette statt per Grenze"*, Anker `seit slice-mutations-anker-greift-in-den-gates`.

**Grenze der Verkörperung, benannt.** Ein mechanischer Sensor ist nicht möglich: ob ein Operand Kennung oder
Meldungstext ist, entscheidet die Syntax nicht, und ein Muster über `strings.Contains`/`grep -F` träfe die
Meldungs-Zusicherungen als Befund (Verdikt `2026-10-09-slice-mutations-anker-greift-in-den-gates-architect-verdikt`, 1).
Träger ist der Reviewer.
```

**Reihenfolge:** Die Skill-Zeile muss stehen, bevor der Ausgang *verkörpert* in `state.md` landet,
sonst prüft die Anker-Paarung ins Leere. Steht sie zur Closure nicht, setzt der Planner *offen* nicht
fort (ADR-0085 Festlegung 3), sondern wartet mit dem Register-Commit auf den Reviewer-Commit.

## 2 — M-3 und `mess-rezept-setzt-unbenannte-host-konfiguration-voraus`

**Gehört nicht hinein; der Eintrag bleibt bei 2.** Der Eintrag beschreibt ein **Mess-Rezept**, das
eine Messung nachfahrbar machen soll und eine Host-**Einstellung** (git-Identität, `bats` im Pfad)
verschweigt, mit der Fehlerrichtung *„das Rezept ist vollständig"*. M-3 ist ein **Gate-Rezept**, das
eine Werkzeug-**Familie** (GNU `sed`/`mktemp`) voraussetzt. Gegenstand und Maßstab sind andere: M-3
misst sich an §3.9 und `LH-QA-02`, der Eintrag an der Nachfahrbarkeit einer Messung. Wer M-3
hineinzählt, dehnt die Klasse und hebt sie über eine Ähnlichkeit auf 3.

**Kein neuer Eintrag, nur benannt (akzeptiertes Negativ).** Die Voraussetzung ist im selben Slice an
beiden Orten benannt, die ein Leser des Modus liest: `MR-090` §Grenze und `harness/sensors/mutate.md`
§Grenze. Sie verschwindet also nicht spurlos. Ein eigener Eintrag hätte erst Gegenstand, wenn ein
weiteres Gate-Rezept ohne Container auf dem Host fährt. Dann gehört die Frage an §3.9 (Host-Bedarf
erweitern oder Container), nicht an einen Zähler.
