# Gegenprobe-Bericht: slice-program-feld-nennt-weder-operator-noch-wertfragment — 2026-09-24

**Rolle:** Verifier (Modul 8/11), gezielte Nach-Verifikation nach
[`modul-11-verification.md`](../../.harness/baseline/v6.9.0/regelwerk/modul-11-verification.md)
§Bewusstes Brechen für DoD-Testbehauptungen. Frage: *Bindet jeder Zahn seine Zusicherung?*

**Gegenstand:** DoD Liefer-Punkt 2, Haken 3 des geschlossenen Slice
`slice-program-feld-nennt-weder-operator-noch-wertfragment` (Closure `278c342f`): *„Ein Fall, der bei
geschwächter Zusicherung noch rot wird, deckt einen anderen Zweig."* Die Closure-Notiz §7 nennt die wörtliche
Gegenprobe **nicht gefahren**; der Haken ist gesetzt. Der Chat-Bericht des Implementers ist kein Beleg — dieser
Bericht fährt sie selbst. Der Verifikationsbericht
`2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-verify.md` bleibt unangetastet.

**Bezug:** `LH-FA-10` · `ADR-0011` (Werte nie im Span) · `SPEC-031` (`spec/spezifikation.md` §5) ·
`AGENTS.md` §3.6. Slice, Code, DoD, ADRs: **nicht geändert**, kein Häkchen gesetzt oder entfernt
(`AGENTS.md` §3.10). Nichts gepusht.

**Methode:** Stand `HEAD` = `278c342f` (`git rev-parse HEAD`), `git archive HEAD | tar -x` in eine
Arbeitskopie im Scratchpad — **nicht** im Repo-Baum, kein `git worktree` angelegt. Je Lauf eine frische Kopie
der Basis; die Mutation ist das **unveränderte** `test/mutations/<n>-*.sh` (`bash` im Kopie-Wurzelverzeichnis).
Sensor: `make test-go` (Dockerfile-`test`-Stage, Docker-only); der `narrow_sensor` aus `harness/tools/mutate.sh`
wählt für jeden der fünf Fälle `test-go` (`# expect:` beginnt mit `Test[A-Z]`). `make mutate` **nicht**
gestartet, kein `MUTATE_FORCE`. Basislauf der Kopie: `make test-go` → Exit 0, `ok …/internal/span`.

**Lösch-Verfahren der Gegenprobe:** je Fall eine Nadel-Liste exakter Tabellenzeilen aus
`internal/span/span_test.go`; ein Hilfsskript löscht jede Nadel im Rumpf der benannten Testfunktion und **bricht
ab, wenn eine Nadel nicht genau einmal trifft**. Die Nadeln sind die Zeilen, deren Subtests im Rot-Lauf
`--- FAIL` meldeten (Menge aus dem Log, nicht geraten). Die Vollständigkeit belegt der grüne Lauf selbst
(kein weiterer Subtest rot) und die Zählung: `git diff --no-index --numstat <Basis>/internal/span/span_test.go
<Kopie>/internal/span/span_test.go`. Polarität: **grün = bindet**.

---

## Gesamturteil

**Die Zusage von Haken 3 ist für alle fünf Fälle (404 bis 408) gesehen: Mutation aktiv, Zusicherung im Test
abgeschwächt, `make test-go` grün — jeder Zahn bindet, kein anderer Zweig fängt die Mutation ab.** Ebenso für
die sechs verlangten Randzeichen von F-3 (`)`, `}`, `<`, `>`, `&`, `|`): Zeichen aus `unsureValueChars` entfernt
→ nur der eigene Subtest rot; Eintrag aus der Testliste entfernt → grün. **Kein Befund mit Schweregrad.** Zwei
Beobachtungen (INFO) unten. Ob der Haken stehen bleibt, entscheidet der Planner; die Closure-Notiz §7 nennt die
Gegenprobe noch „nicht gefahren" — dieser Bericht ist der Beleg, den sie nachreicht.

---

## Fälle 404 bis 408

Rot-Richtung: `make test-go` mit der Mutation. Gegenprobe: dieselbe Mutation, Zeilen entfernt.

| Fall | Mutation (unverändert) | Rot in (gelesene Meldung) | Entfernte Zeilen (Kommando: `--numstat`) | Gegenprobe | Urteil |
|---|---|---|---|---|---|
| 404 | `isSegmentEnd` → `return false` | `TestCommandProgramNamesAProgramNotAnOperator`, 9 Subtests, z. B. `Derive: program = "", erwartet "cmd" (Zeile "A=b && cmd x")`; dazu **1** Subtest in `…NeverEmitsAssignmentValueFragments` (`TOKEN=SECRETVALUE && gh pr create`) | 10 (`0 10`): 9 in `…NamesAProgram…` (`&&`/`;`/`\|`/`&` mit `cmd x`, `cmd x y`, `A=1 B=2 && make gates`, `A=b && C=d && make`, `TOKEN=x && gh pr create`, `&& cmd`) + 1 in `…Fragments` | `ok …/internal/span`, Exit 0 | **bindet** |
| 405 | `valueEdgeKnown` → `return true` | `…NeverEmitsAssignmentValueFragments`, 8 Subtests, z. B. `Wert oder Wert-Bruchstueck im Span fuer "TOKEN=\"abc SECRET\" gh pr create"` und `program = "cmd", erwartet "" (Zeile "A=x;SECRET cmd")`; dazu alle **13** Subtests von `…WithholdsProgramForEachUnsureValueChar` (`program = "cmd" … erwartet: nichts`) | 9 (`1 9`): 8 Wert-Bruchstück-Zeilen in `…Fragments` + die Liste der 13 Randzeichen in F-3 auf `[]string{}` (1 Zeile ersetzt) | `ok`, Exit 0 | **bindet** |
| 406 | `splitWords(cmd)` → `strings.Fields(cmd)` | `…NamesAProgram…`: `Derive: program = "SECRET", erwartet "cmd" (Zeile "A=b SECRET cmd x")`; `…Fragments`: 7 Subtests, `Wert oder Wert-Bruchstueck im Span fuer "A=b SECRET cmd"` u. a. | 8 (`0 8`): 1 in `…NamesAProgram…` + 7 Leerraum-Zeilen (` `, ` `, `　`, `\u0085`, `\r`, `\v`, `\f`) in `…Fragments` | `ok`, Exit 0 | **bindet** |
| 407 | `if strings.IndexByte(shellMetaStart, field[0]) >= 0` → `if false` | `…NamesAProgram…`, 7 Subtests: `Derive: program = "\|&", erwartet "" (Zeile "A=b \|& cmd")`, `;;`, `!`, `(cmd`, `{`, `}`, `&& (cmd`; `…Fragments`, 3 Subtests: `Wert oder Wert-Bruchstueck im Span fuer "A=b #SECRET cmd"`, `program = "#", erwartet ""` | 10 (`0 10`): 7 in `…NamesAProgram…` + 3 (`#SECRET cmd`, `# SECRET`, `&& #SECRET cmd`) in `…Fragments` | `ok`, Exit 0 | **bindet** |
| 408 | Ziffernregel: `return true` statt Prüfung auf `<`/`>` | `…NamesAProgram…`, genau 3 Subtests: `Derive: program = "2>&1", erwartet "" (Zeile "A=b 2>&1 cmd")`, `12>f`, `3<f` | 3 (`0 3`): `A=b 2>&1 cmd`, `A=b 12>f cmd`, `A=b 3<f cmd` | `ok`, Exit 0 | **bindet** |

Jede Mutation trifft im Quell-Bestand genau eine Stelle: `git diff --no-index --stat` Basis gegen Kopie →
`1 file changed`, je 1 Zeile ersetzt (405/407: `\n` im Ersatz, daher 2 Einfügungen). Die Gegenprobe-Läufe
kamen **erst nach** dem Rot-Lauf desselben Falls; die Rot-Menge der Subtests deckt sich mit der Lösch-Menge
(Ausnahme: siehe INFO-1).

**Zu 404:** Die Mutation färbt den Fall nicht mehr mit dem Feld `&&`, sondern mit *nichts* (erwartet `cmd`,
bekommt `""`) — die Wortlaut-Differenz, die der Verifikationsbericht als V-2 führt; die Meldung nennt Zeile und
Erwartung und trägt die behauptete Ursache (Segment-Grenze).

**Zu 408:** `>f` und `<<<x` bleiben unter der Mutation grün (die Metazeichen-Menge fängt sie); die
Ziffer-Zeilen sind die einzigen Subtests, die rot werden — der Zahn ist damit die Ziffernregel allein, nicht
Fall 407.

## F-3 — `TestCommandProgramWithholdsProgramForEachUnsureValueChar`

(a) Zeichen aus `unsureValueChars` entfernt (`const`-Zeile in `internal/span/span.go`) → `make test-go`;
(b) zusätzlich Eintrag dieses Zeichens aus der Testliste entfernt (`for _, c := range []string{…}`) →
`make test-go`. Die Gegenprobe der verlangten sechs Zeichen; die übrigen fünf einfach vorkommenden Zeichen
liefen mit (`"` und `\` nicht — beide stehen mehrfach in der `const`-Zeile, das Hilfsskript entfernt nur ein
Vorkommen).

| Zeichen | (a) Rot | (b) Gegenprobe | Urteil |
|---|---|---|---|
| `)` | genau **ein** Subtest: `…/A=x)y_cmd_z` (`Derive: program = "cmd" (argc true) fuer "A=x)y cmd z", erwartet: nichts`) | `ok`, Exit 0 | **bindet** |
| `}` | genau ein Subtest: `…/A=x}y_cmd_z` (`program = "cmd"`) | `ok`, Exit 0 | **bindet** |
| `<` | genau ein Subtest: `…/A=x<y_cmd_z` (`program = "cmd"`) | `ok`, Exit 0 | **bindet** |
| `>` | genau ein Subtest: `…/A=x>y_cmd_z` (`program = "cmd"`) | `ok`, Exit 0 | **bindet** |
| `&` | genau ein Subtest: `…/A=x&y_cmd_z` | `ok`, Exit 0 | **bindet** |
| `\|` | genau ein Subtest: `…/A=x\|y_cmd_z` | `ok`, Exit 0 | **bindet** |
| `(` | eigener Subtest **und** `…Fragments/T=$(date_SECRET);_make` | rot nur noch in `…Fragments/T=$(date_SECRET);_make`; der eigene Subtest ist grün | eigener Zahn **bindet**; zweites Wächter-Paar, s. INFO-1 |
| `{` | eigener Subtest **und** `…Fragments/A=${A:-x_SECRET}_cmd` | rot nur noch in diesem Fragments-Subtest | eigener Zahn **bindet**, s. INFO-1 |
| `;` | eigener Subtest **und** `…Fragments/A=x;SECRET_cmd` | rot nur noch in diesem Fragments-Subtest | eigener Zahn **bindet**, s. INFO-1 |
| `'` | eigener Subtest **und** `…Fragments/TOKEN='abc_SECRET'_gh_pr_create` | rot nur noch in diesem Fragments-Subtest | eigener Zahn **bindet**, s. INFO-1 |
| `` ` `` | eigener Subtest **und** `…Fragments/A=`x_SECRET`_cmd` | rot nur noch in diesem Fragments-Subtest | eigener Zahn **bindet**, s. INFO-1 |

Bei jedem Lauf zeigt der Diff der Kopie genau die Änderung: eine `const`-Zeile mit einem Zeichen weniger (a)
bzw. zusätzlich die Testlisten-Zeile mit einem Eintrag weniger (b).

---

## Beobachtungen

**INFO-1 — Die wörtliche Gegenprobe braucht mehr als den benannten Test.** Bei 404, 405, 406 und 407 färbt
die Mutation **zwei** Testfunktionen rot, das `# expect:` des Falls nennt eine. Grün wird der Fall erst, wenn in
**beiden** die geschützten Zeilen fehlen (404: 9 + 1, 405: 8 + die F-3-Liste, 406: 1 + 7, 407: 7 + 3). Nur den
benannten Test abzuschwächen ließe den Fall rot — abgeleitet aus den Rot-Läufen oben (die Zweit-Subtests sind
dort aufgeführt), **nicht** als eigener Lauf gefahren. Das ist kein „anderer Zweig": beide Tests binden
dieselbe Quell-Stelle. Die Aussage in der DoD („ein Fall, der bei geschwächter Zusicherung noch rot wird, deckt
einen anderen Zweig") trifft auf diese Lage nicht zu, sie lässt sich aber auch nicht am einzelnen Test
ablesen. Ebenso F-3: für `(`, `{`, `;`, `'`, `` ` `` deckt zusätzlich ein Fragments-Subtest dasselbe Zeichen;
grün wird die Testlisten-Abschwächung dort erst, wenn auch diese Zeile fehlt (nicht gefahren; die verlangten
sechs Zeichen sind davon nicht betroffen).

**INFO-2 — `<`/`>`: kein äquivalenter Mutant am Test.** Der Reviewer Runde 2 hat vermerkt, `<`/`>` seien
äquivalente Mutanten wegen der Ziffernregel. Am gefahrenen Lauf bestätigt sich das **nicht**: entfernt man `<`
bzw. `>` aus `unsureValueChars`, liefert `commandProgram` für `A=x<y cmd z` bzw. `A=x>y cmd z` das Programm
`cmd`; der eigene Subtest wird rot, und nach dem Entfernen des Listen-Eintrags ist der Lauf grün — die Zeichen
sind allein von F-3 bewacht (kein anderer Test wird rot). Wo die Ziffernregel greift (`namesProgram`, Wort
**nach** einer Zuweisung, Fall 408), ist eine andere Stelle. Was das für die Spec-Aussage bedeutet (die Shell
führt `A=x<y cmd` als Zuweisung samt Redirect aus, `cmd` liefe also), ist eine Deutung und gehört nicht in
diesen Bericht; benannt ist nur: die zwei Zeichen tragen im Test und im Code eine Wirkung.

Kein Befund, kein DoD-Verstoß.

---

## Was nicht gefahren wurde

`make mutate` (Beleg-Slot, V-1 des Verifikationsberichts), `make test-bats`, `make gates` in der Arbeitskopie.
Die zwei Zeichen `"` und `\` aus F-3. Der Lauf der Gegenprobe mit **nur** dem benannten Test abgeschwächt
(INFO-1, abgeleitet). Der Repo-Baum blieb unberührt; die Arbeitskopien liegen im Scratchpad.
