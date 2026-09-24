# Review-Report: slice-program-feld-nennt-weder-operator-noch-wertfragment — 2026-09-24

**Review-Art:** Diff — Review gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist
der Verifier).

**Gegenstand:** Commit `2efaa979` (Rolle Implementer, lokal, nicht gepusht) — 5 Dateien:
`internal/span/span.go` (`commandProgram`, `isSegmentEnd`, `unsureValueChars`, `valueEdgeKnown`),
`internal/span/span_test.go`, `test/mutations/404-*.sh`, `test/mutations/405-*.sh`,
`spec/spezifikation.md` (`SPEC-031`).

**Plan-Bezug:** `docs/plan/planning/done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md`
(§1 Verhaltenstabelle und Ausschlüsse, §2 nur als Referenz, §6 Risiken, §7 leer).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-24

**Eingangs-Kontext:** Diff · Slice-Plan · `LH-FA-10` · `ADR-0011` (Festlegung 2: Werte nie im Span) ·
`ADR-0022` (Träger) · `MR-019` · `MR-071` · `spec/spezifikation.md` SPEC-021/-031 · `AGENTS.md` §3 ·
Baseline-Module 5, 8, 10, 11, 13 (Bezug)

**Eigene Sensor-Läufe dieses Laufs:**

- Sonde über `make test-go` in einer **Kopie** des Commits (`git archive HEAD` im Scratchpad, dort
  eine zusätzliche Test-Datei, die die 46 Eingaben durch die **unveränderte** `commandProgram`
  schickt und das Ergebnis über `t.Errorf` ausgibt). Kein Host-Go, der Arbeitsbaum des Repos blieb
  unberührt. Die Ausgabe ist die Grundlage von F-1, F-2 und der Negativbefunde.
- `grep -c` der zwei `sed`-Anker aus 404/405 gegen `internal/span/span.go` → je `1`.
- `git show --stat 2efaa979`; Lesen der Fall-Dateien gegen `129-span-modellschranke-kuerzt.sh`.
- `make mutate` **nicht** gefahren (Auftrag: der Implementer meldet 393 ok / 0 Befunde).
- `make gates` — siehe Ende des Reports.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Die Wert-Grenze setzt voraus, dass der Wert an **Go-Leerraum** endet, wo die Shell ihn an Leerzeichen/Tab/Newline endet. `strings.Fields` teilt auch an NBSP (U+00A0), U+2003, U+3000, U+0085 sowie an `\r`, `\v`, `\f`; die Shell führt sie als Teil des Worts. Gemessen an der unveränderten Funktion: `A=b<U+00A0>SECRET cmd` → `program="SECRET"`, argc 1; ebenso `A=b<U+2003>SECRET cmd`, `A=b<U+3000>SECRET cmd`, `A=b<U+0085>SECRET cmd`, `A=b\rSECRET cmd`, `A=b\vSECRET cmd`. Das Bruchstück des Werts steht als `program` im Span — die Leck-Klasse, gegen die der Slice steht (§1 Ziel: „nie ein Bruchstück eines Zuweisungs-Werts"; SPEC-031 sagt: „der Wert und jedes seiner Bruchstücke bleiben aus dem Span"). `valueEdgeKnown` prüft das Feld nur auf die Zeichen aus `unsureValueChars`; Leerraum, den `Fields` trennt, ohne dass die Shell trennt, steht nicht darin. Weder `TestCommandProgramNeverEmitsAssignmentValueFragments` noch ein Fall aus 405 enthält eine solche Eingabe; die Zusage im Test-Namen („Never") hat für diese Klasse kein Gegenbeispiel. (Korrekt getrennt werden `\t` und `\n`: dort ist auch die Shell-Grenze.) | ADR-0011 Festlegung 2 · AGENTS.md §3.6 | internal/span/span.go:266 (`strings.Fields`), :303-306 (`valueEdgeKnown`); internal/span/span_test.go (`TestCommandProgramNeverEmitsAssignmentValueFragments`); spec/spezifikation.md SPEC-031 | ja — Fall `A=b<NBSP>SECRET cmd` im Wert-Wächter; über `Derive` und die geschriebene Zeile | Wert-Grenze beruht auf dem Leerraum-Modell der Zerlegung, nicht dem der Shell |
| F-2 | MEDIUM | Die Zusage „ein Programm oder NICHTS" (Funktionskommentar) und „nie einen Shell-Operator" (§1 Ziel) tragen nicht. Nach einer Zuweisung erscheinen als `program`: `\|&` (`A=b \|& cmd`), `;;`, `>f`, `>`, `2>&1`, `<<<hunter2` (ein Here-String mit **Klartext-Literal**), `!`, `(cmd`, `{`, `#SECRET` (`A=b #SECRET cmd`), und mit `A=b # SECRET` `#`. Gemessen an der unveränderten Funktion. Die Verhaltenstabelle nennt nur vier Operatoren, und `isSegmentEnd` führt genau diese; ohne Zuweisung ist das Verhalten Bestand („erstes Token"). Der Kommentar über der Funktion und Plan §1 Ziel sprechen aber allgemeiner, und die Tests binden nur die vier. | AGENTS.md §3.6/§3.7 · Plan §1 Ziel | internal/span/span.go:246-256, :283-287 | ja — Fälle `A=b \|& cmd`, `A=b >f cmd`, `A=b <<<x cmd` über `Derive` | Zusage im Kommentar weiter als der Code |
| F-3 | LOW | Sechs Zeichen aus `unsureValueChars` (`)`, `}`, `<`, `>`, `&`, `\|`) haben in keinem Fall des Wert-Wächters einen **eigenen** Zahn: jede Testeingabe trägt daneben ein anderes Zeichen der Menge (`(`, `{`, `"`, `;`, …). Entfiele eines dieser sechs aus der Menge, bliebe die Suite grün; 405 mutiert die ganze Prüfung, nicht ihre Mitglieder. Was fehlte, wäre kein Leck (die Zeichen erzeugen kein Feld), aber die Zuordnung `A=b\|cmd x` würde `x` als Programm nennen. | AGENTS.md §3.6 | internal/span/span.go:300; internal/span/span_test.go (Wert-Wächter) | ja — Mutation je Zeichen | Zeichensatz-Mitglied ohne eigenes rotes Gegenbeispiel |
| F-4 | INFO | `SPEC-031` zählt als nicht bestimmbare Ränder „Anführungszeichen, Befehlssubstitution, Klammern, Backslash"; der Code führt zusätzlich `{ } ; & \| < >`. Die Aufzählung liest sich abschließend und ist enger als die Menge im Code (Spec-Zeile und Code stimmen sonst wörtlich überein, Fälle 404/405 und die beiden Test-Namen sind korrekt genannt). | LH-FA-10 · MR-019 | spec/spezifikation.md:132 | ja — Wortvergleich Spec/Code | Aufzählung in Spec enger als die Code-Menge |
| F-5 | INFO | `SPEC-021` sagt weiter „erstes Token und Argument-Anzahl"; für `A=b && cmd` ist das erste Token `A=b`. Das ist die vom Plan bewusst gelassene Ungenauigkeit (§1: `SPEC-021` „bleibt wahr"; die Feldliste gehört `slice-109`), hier nur als Beobachtung: die zwei Zeilen SPEC-021/SPEC-031 sagen jetzt Verschiedenes über `program`. | MR-019 | spec/spezifikation.md:114 vs. :132 | nein | Zwei Spec-Zeilen zum selben Feld mit verschiedener Fassung |

---

## Geprüft, ohne Befund

- **Wert-Leck ohne Leerraum-Trick:** `A=b\ SECRET cmd`, `A=$'x SECRET' cmd`, `A=x${IFS}SECRET cmd`,
  `A=b&&cmd`, `A=b;cmd`, `A+=b cmd` → jeweils **nichts** (fail-closed). `export A=SECRET cmd` und
  `env A=b cmd` → `program` = `export` / `env`, nie der Wert; `argc` zählt nur (2). `A=$SECRET cmd`
  → `cmd`, der Wert wird übersprungen. `A= SECRET cmd` → `SECRET` (in der Shell leere Zuweisung, dann
  Programm `SECRET`; korrekt). `argc` trägt als Nebenkanal keinen Wert.
- **Segment-Tabelle Zeile für Zeile:** `A=b && cmd x` / `; ` / `|` / `&` → `cmd`, 1; `A=b; cmd x` → `cmd`;
  `A=1 B=2 && make gates`, `A=b && C=d && make` → `make`; `A=b || cmd`, `A=b &&`, `A=b ;`, `&& cmd`,
  `A=b && && cmd`, `A=b ; ; cmd`, `(A=b; cmd)`, `A=b B=c` → nichts. `A=b; A2=c; cmd` → `cmd`.
  Alle Zeilen der §1-Tabelle stimmen mit dem Ist überein; die Abweichungen stehen in F-1/F-2.
- **Regression:** `ls -l`, `  ls -l`, `cd /x`, `git status`, `grep a=b file`, `make gates`, `cd /x && A=b cmd`
  → unverändertes Ergebnis (erstes Token, `argc` = Felder danach). Neu ist nur, dass ein **führender**
  Operator (`&&`, `;`, `|`, `&`, `||`) nichts statt des Operators liefert (Tabellen-Zeile `&& cmd`).
- **Emit-Seite:** `Derive` gibt bei `ok=false` `Derived{}`; `Program` (`omitempty`) und `Argc` (`*int`,
  nur bei `HasArgc`) fehlen dann in der Zeile — derselbe Zweig, den die `=`-Rest-Regel schon
  vor dem Diff nutzte. SPEC-021 führt beide Felder als *Optional*. `span-check.sh:122` und
  `full-smoke.sh:1310` prüfen `"program":"make"` an einer Zeile ohne Zuweisung: unberührt.
- **Nicht-Gegenstand:** kein Diff in `internal/emit/`, `internal/span/fieldlist.go`, `emit.go`, kein
  Tokenizer, keine `cd`/`set`-Überspringung, `argc` unverändert (`A=b && cd /x` → `cd`, 1, weiter
  slice-204). Die JSON-`&`-Schreibweise ist unberührt.
- **Slice/Register:** `git show --stat` nennt fünf Dateien, keine Plan-, Register- oder Roadmap-Datei;
  Slice liegt weiter in `in-progress/`, §6-Ausgänge und §7 sind unberührt (§3.10 gewahrt). Die
  Spec-Zeile schreibt der Implementer ohne Zuständigkeits-Aussage (Frage bleibt bei slice-151/§7).
- **§3.6 Tests:** beide Test-Namen führen die Eigenschaft; die Wächter laufen über `Derive` **und** über
  Emit→geschriebene Zeile (`bashSpanLine`), der Wert-Wächter prüft `SECRET` in der **ganzen** Zeile,
  nicht nur im Feld. `TestCommandProgramSkipsAssignments` unverändert.
- **Mutations-Fälle 404/405:** Format wie `129-*` (`# files:`, `# expect:`, Kopfkommentar, `set -euo pipefail`,
  ausführbar). Jedes `sed`-Muster trifft im Quell-Bestand genau eine Zeile (`grep -c` → 1/1; MR-071).
  404 färbt die Tabelle des Segment-Wächters rot (`&&` wird Programm; nebenbei auch den Wert-Wächter,
  `expect` nennt den richtigen); 405 nur den Wert-Wächter (in `TestCommandProgramNamesAProgramNotAnOperator`
  steht kein Wert mit einem unsicheren Zeichen), und sein Kommentar benennt den stillen Pfad.
- **§3.7/§3.2:** Kommentare im Indikativ, Klassen Zusage/Kopplung/Abgrenzung/Grenze, keine
  Befund-Kennung, keine Chronik; keine Lint-Suppression im Diff.

## Übergabe

Kein Rollen-Konflikt-Pfad nötig: F-1 ist ein HIGH ohne Widerspruch des Implementers. Die Frage, ob die
Wert-Grenze auf „ein Wert enthält ausschließlich Zeichen, die die Shell **und** `strings.Fields`
gleich behandeln" gestellt wird, entscheidet der Implementer; der Reviewer kategorisiert.

## Gesamturteil

**Nach Korrektur** (F-1 blockiert; F-2 vor Merge zu klären).

## Gate-Lauf

`make gates` wird nach dem Commit dieses Reports gefahren; das Ergebnis steht im Handback an den Aufrufer, nicht hier.
