# Review-Report: slice-lifecycle-move-schreibt-in-reports-nur-die-link-form — 2026-09-26

**Review-Art:** Werkzeug-, Test- und Doku-Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff bc96ec5a..HEAD` (HEAD `83044cc4`, Baum sauber). Produktiv-Diff: `0c875623` (`harness/tools/slice-mv.sh`:
`rewrite_incoming_links_in_file`, `rewrite_incoming_nach_baum`, Pfad-Zweig in `main()`, Kommentar an der Ausnahmeliste; sechs neue bats-Fälle
in `test/slice-mv.bats`; `TestSliceMvEchtSchreibtInReportsNurDieLinkForm`), `92970e0e` (Anker des Falls 313), `e6cd870e` (Mutations-Fälle 459 bis
462), `6d5bb55b` (`harness/sensors/slice-mv.md`), `83044cc4` (Formen-Probe als Funktion). Move-/Marker-Commits: `f9f089f4` (`make slice-mv`,
reiner Move `next/` → `in-progress/`), `cb0638e4` (`make slice-mv`, ein Nachzug, berührt nur die Slice-Datei — gelesen: der Pfad in der
Adress-Messung des Plans wandert von `next/` nach `in-progress/`), `9840d434` (Ruhe-Marker der Roadmap entfernt, drei Zeilen).

**Plan-Bezug:** Slice `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` (Ziel, §1 Abgrenzung, §3, §4 Rückführung KERN, §6 Risiken, §8) —
Kennung, nicht Pfad: der Plan wandert mit dem Lifecycle (`AGENTS.md` §3.11). **Constraint:** `ADR-0070` (`Accepted`, Festlegungen 1 bis 3, Fitness-Zeilen
1 bis 6, Trigger 1 und 4 bis 7, §Nicht gebaut), `ADR-0042` Festlegung 1, `MR-071`, `AGENTS.md` §3.3, §3.6, §3.7, §3.9, §3.10, §3.11.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-26

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0070` (Entscheidung, Konsequenzen, Fitness, Trigger) · `MR-071` · `AGENTS.md` §3 · `harness/tools/slice-mv.sh`
vollständig · `test/slice-mv.bats` · `cmd/ai-harness-init/slice_mv_echt_test.go` · `test/mutations/313`, `315`, `316`, `346`, `363-*`, `459` bis
`462` · `harness/sensors/slice-mv.md` · `.d-check.yml`. Der Implementer-Bericht lag dem Lauf **nicht** vor.

**Eigene Sensor-Läufe dieses Laufs** — bats und Kopien in Scratchpad-Kopien von `git archive HEAD` (kein `.git`), Docker-only im bats-Bild des
Makefiles (`docker run --rm --network none -v <Kopie>:/code:ro … test/slice-mv.bats`); zwei Fälle als Teillauf im Repo
(`make mutate MUTATE_JOBS=1 MUTATE_CASES='462-… 313-…'`), kein voller `make mutate`, kein Push, keine Host-Toolchain.

| Lauf | Ergebnis |
|---|---|
| unverändert, `test/slice-mv.bats` | `1..19`, kein `not ok` |
| Fall 459 (Form-Regel entfällt), frische Kopie | rot: Fall 12 (Nicht-Link-Formen, Byte-Gleichheit), 13, 15 |
| Fall 460 (Link-`sed` entfällt), frische Kopie | rot: Fall 12, 14, 15 |
| Fall 461 (Regel auf `done/` ausgedehnt), frische Kopie | rot: Fall 16 (`# expect:` „done: jede Form wird weiter ersetzt" steht im Namen) |
| Fall 462 (`main()` umgeht den Pfad-Zweig), Kopie, `make test-go` | rot: `TestSliceMvEchtSchreibtInReportsNurDieLinkForm`, Meldung gelesen: `Report: nur der Link darf nachgezogen sein` — Ist trägt `next/` in Span und Operand, Erwartung `open/` |
| Fall 462 und 313, Teillauf im Repo | `2 ok, 0 Befund(e)`; Beleg-Slot `.harness/state/mutate-passed.key` **vorher nicht vorhanden, nachher nicht vorhanden** (`TEILLAUF 2 von 450 — kein Beleg`) |
| Bestand 316, 346, 363-slice-mv (bats), 363-ziel-e2e (bats) am HEAD-Stand, je frische Kopie | Anker trifft (Kopie unterscheidet sich), je der `# expect:`-Fall rot; 315 (Go, Kopie): rot mit `ADR wurde nachgezogen, sollte unberuehrt bleiben`; 343 (Fragment der emittierten Fassung, berührt `slice-mv.sh` nicht) nicht gefahren |
| eigene Schwächung M-a: Wortgrenze im Präfix entfällt (`[^)#]` statt `[^A-Za-z0-9_)#-]`) | rot: Fall 14 (`sibling-open/`) |
| eigene Schwächung M-b: Ende-Anker `[)#]` entfällt | rot: Fall 14 (`.mdx`) |
| eigene Schwächung M-c: Träger, der nur den unmittelbaren Backtick-Kontext ausnimmt (Gegenbeispiel des Plans §6) | rot: Fall 12 (Operand, Block, Fließtext werden umgeschrieben) |
| Gegenprobe „Zusicherung entfernen, Mutation bleibt": Gleichheitszeile aus Fall 12 entfernt, unter 459 und unter 460 | Fall 12 wird **grün** — die Byte-Gleichheit bindet allein; 459 bleibt über 13 und 15, 460 über 14 und 15 rot (zweiter Fänger) |
| Gegenprobe: Zählzeile aus Fall 16 entfernt, unter 461 | Fall 16 bleibt rot (dann ist die `!`-Zeile die letzte und bindet) |
| Probe der Regel an Sonderfällen (Basis `slice-a+b.md`; sechs Links in drei Zeilen, ein Titel-Link, ein Code-Span-Zitat, ein Link am Zeilenende, ein Name mit gleichem Suffix) | Zähler `6`; ersetzt: `[a]`, `[b]` mit Anker, `[c]` im Code-Span-Zitat, `[e]`, `[g]`, `[j]` (hinter einem Code-Span, ohne Leerzeichen); unverändert: der reine Pfad im Span, `sliceXa+b.md`, der Fließtext-Pfad, der Titel-Link `[f](… "titel")` |
| `set -e` im `\|\|`-Kontext (Scratch, Funktion aus dem Skript, 0200-Datei unter `done/`) | bare Aufruf (Stand vor dem Diff): Abbruch, Exit 2; Aufruf mit `\|\| …` (Stand am HEAD): weiter, Datei danach **0 Byte** (vorher 37) |
| Spuren des Datei-Anlegens (`slice_mv_echt_test.go`) | `git status --short` leer, keine CR-Zeichen (`grep -c` je Datei `0`), Modus `100644`, keine Fremddatei in `cmd/ai-harness-init/` |

## Findings

### R-1 — LOW — `|| continue` schaltet `set -e` im Nachzug aller Bäume ab; ein fehlgeschlagenes Schreiben leert die Datei

- `kategorie`: LOW
- `quelle`: Maintainability (Skript-Kopf: `set -euo pipefail`, `AGENTS.md` §3.6 für die Zusage „Abbruch statt stilles Weiterlaufen")
- `pfad`: `harness/tools/slice-mv.sh:348` (Aufruf `rewrite_incoming_nach_baum … || continue`), `:270-278` (die Funktion), `:141-148` (`psed_i`: `sed >tmp`, dann `cat tmp >ziel`)
- `befund`: Vor dem Diff lief die Ersetzung als bloßer Aufruf, und ein Fehler im `sed` brach `main()` ab (bare Aufruf im Scratch: Exit 2). Im `|| continue` gilt
  `set -e` **im ganzen Funktionsrumpf nicht mehr** (bash), das betrifft auch den Zweig `*)` für `done/` und alle anderen Bäume, obwohl der Diff dort nichts ändern
  wollte: `psed_i` führt nach einem gescheiterten `sed` das `cat "$tmp" >"$ziel"` aus. Gemessen: unlesbare Datei (Modus 0200) unter `done/` — Aufruf im
  `||`-Kontext liefert Status 0 und lässt die Datei mit 0 Byte zurück (vorher 37); `main()` würde sie als „nachgezogen" zählen, `git add`en und committen.
  Schreibgeschützte Datei (0444): `cat` scheitert, der Status bleibt 0, der Link bleibt stehen, das Werkzeug meldet Erfolg.
- Failure-Szenario: ein getrackter Text im Nachzug-Suchraum, den der Lauf nicht lesen oder schreiben kann (fremder Eigentümer, `chmod`), macht aus einem lauten
  Abbruch ein stilles „ok" oder einen Commit mit geleerter Datei. Die Vorbedingung ist eng (git-Checkout erzeugt diese Modi nicht), die Ursache liegt in
  `psed_i`; der Diff aktiviert sie über die Aufrufform, und kein Fall bindet den Abbruch.
- `verifizierbar`: ja (Scratch-Probe wie oben; ein bats-Fall braucht einen Nicht-Root-Nutzer)
- `klasse`: Fehlerabbruch durch Aufruf im `||`-Kontext entwaffnet (`set -e` gilt in Funktionen dort nicht)

### R-2 — INFO — zwei Link-Formen liegen außerhalb der Regel und stehen nicht unter den benannten Lücken

- `kategorie`: INFO
- `quelle`: `ADR-0070` Festlegung 1 (die Regel: „unmittelbar hinter `](`" bis „`)` oder `#`"), Trigger 7
- `pfad`: `harness/tools/slice-mv.sh:257` (Regex), `harness/sensors/slice-mv.md:84-90` (benannte Lücken: Code-Block-Zitat, Referenz-Definition)
- `befund`: Ein Inline-Link mit Titel (`](ziel "titel")`) und die Spitzklammer-Form (`](<ziel>)`) enden nicht unmittelbar an `)` oder `#`; die Regel lässt sie stehen (gemessen: Titel-Link bleibt
  unverändert). Das ist mit dem Wortlaut der ADR vereinbar und **laut**, nicht still — ein unterbliebener Link-Nachzug färbt `make docs-check` mit `target-missing`. Bestand:
  `git grep -nE '\]\(<?[^)]*(open|next|in-progress|done)/[^)]* "' -- docs/reviews | wc -l` → `0`, `git grep -nE '\]\(<[^)]*(open|next|in-progress|done)/' -- docs/reviews | wc -l` → `0`.
  Die Sensor-Doku zählt „fünf gemessene Grenzen" und nennt diese zwei nicht; sie sind eine Untermenge der Zusage „nur hinter `](` bis `)` oder `#`", keine Abweichung.
- `verifizierbar`: ja (`make docs-check` nach einem Move mit einem solchen Link)
- `klasse`: Regel-Rand ohne benannte Lücke, im Bestand leer

### R-3 — INFO — die Regel-Ausprägungen „mehrere Links je Zeile" und „Link direkt hinter einem Code-Span" sind gemessen, aber nicht von einem Fall gehalten

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.6 (Deckung), `ADR-0070` Fitness-Zeile 1
- `pfad`: `test/slice-mv.bats` (Fälle 12 bis 17)
- `befund`: Fall 14 trägt je Zeile einen Link, Fall 15 einen Code-Span mit Link plus einen reinen Pfad. Die Ausprägung „drei Links in einer Zeile" und der Link unmittelbar hinter einem
  Code-Span (`` `x`[j](…) ``) sind im Scratch gemessen (6 von 6 erwarteten Ersetzungen, s. Tabelle) und **kein** Fall bindet sie; die Schwächung, die das Muster von `[^)#]*` auf `.*`
  (gierig über `)` hinweg) ändert, färbte laut Analyse den Mehrfach-Fall, nicht aber Fall 12 bis 17 — nicht gefahren, darum hier als Beobachtung.
- `verifizierbar`: ja (ein Fall mit einer Zeile, drei Links)
- `klasse`: Regel-Ausprägung ohne Fall

### R-4 — INFO — die emittierte Fassung führt die Regel bewusst nicht; die Kopplung hält, das Ziel-Repo behält den alten Nachzug

- `kategorie`: INFO
- `quelle`: Slice §1 (Ausschluss „Die emittierte Fassung"), §4 (Rückführung KERN), `ADR-0070` §Was diese Entscheidung nicht tut
- `pfad`: `internal/emit/templates/enforce/slice-mv.sh` (unverändert: `git diff bc96ec5a..HEAD --stat -- internal` leer), `test/slice-mv.bats:337` (`KERN`)
- `befund`: Die zwei neuen Funktionen liegen außerhalb der Liste `KERN` (`re_escape rewrite_incoming_in_file rewrite_incoming_bare_in_file rewrite_outgoing_bare_in_file`), Fall 19
  („kopplung: … wortgleich") ist grün. Der Plan schließt die emittierte Fassung mit Grund aus (die Regel gilt für dieses Repo, die Tool-Ebene entscheidet ein anderer Vorgang), und die
  Sensor-Doku sagt es (`harness/sensors/slice-mv.md:188-191`). Ein gebootstrapptes Ziel behält damit den Nachzug in jeder Form auch in Reports. Der emittierte Startzustand von `.d-check.yml`
  führt `codepaths` auskommentiert (`internal/emit/templates/d-check.yml:18`) und nimmt `docs/reviews/**` dort nur aus `matrix` aus — die Gate-Begründung aus `ADR-0070` Festlegung 3
  würde dort also tragen, wenn ein Ziel `codepaths` aktiviert. Nur benannt, nicht über den Slice hinaus bewertet.
- `verifizierbar`: ja (`git diff … --stat -- internal`)
- `klasse`: bewusster Ausschluss, Ziel-Repo behält alte Regel

### R-5 — INFO — zwei Kleinigkeiten ohne Wirkung

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `test/slice-mv.bats` (Fall 16, Zeile `! grep -q 'open/slice-999-x\.md' …`); `test/mutations/459` bis `462` (Modus `100644`)
- `befund`: (a) Die `!`-Zeile in Fall 16 steht nicht am Ende des Falls; in bash löst ein `!`-Pipeline dort kein `errexit` aus. Bindend ist die Zählung `-eq 5` in der letzten Zeile, aus der die Aussage schon
  folgt (die Probe trägt genau fünf Vorkommen) — die `!`-Zeile ist redundant, nicht falsch (Gegenprobe oben: ohne Zählzeile bindet sie als letzte Zeile). (b) Die vier neuen Fälle sind `100644` wie `455` bis
  `458`; der Bestand ist gemischt (`git ls-files -s test/mutations | awk '{print $1}' | sort | uniq -c` → `124` × `100644`, `326` × `100755`). `harness/tools/mutate.sh` ruft `bash "$case_file"`, der Modus
  hat keine Wirkung.
- `verifizierbar`: nein (keine Wirkung)
- `klasse`: —

**Kein HIGH, kein MEDIUM.**

## Geprüft, ohne Befund

- **Regel (Punkt 1), Zeichen für Zeichen** — `(\]\(([^)#]*[^A-Za-z0-9_)#-])?)$from/$esc_base([)#])`: Gruppe 1 = `](` samt optionalem Präfix, Gruppe 2 = innere Gruppe, Gruppe 3 = Ende; `\1…\3` trifft die Gruppen richtig, `[^)#]*` kann kein `)` überqueren (mehrere Links je Zeile bleiben getrennt), das letzte Präfix-Zeichen ist die Wortgrenze (Bindestrich, Buchstabe, Ziffer, Unterstrich schließen aus: `sibling-open/`), `[)#]` verlangt das Namensende (`.mdx`, längerer Name). Tiefen `../`, `../../`, präfixlos, mit `#anker`, Code-Span als Link-Text, Link am Zeilenende: Fall 12 und 14 plus Scratch-Probe. Byte-Gleichheit aller anderen Formen (reiner Span, Operand, Code-Block, Fließtext): Fall 12, Byte-Vergleich der ganzen Datei gegen ein Literal.
- **Quoting und Sonderzeichen** — `$esc_base` läuft durch `re_escape` (`.`, `+`, `[`, `]` maskiert; Basis mit `+` in der Probe korrekt), `$from` ist ein Lifecycle-Name (`open`, `next`, `in-progress`, `done`), Trennzeichen `@` kommt in Slice-Namen nicht vor. `sed -E`/`grep -oE`/`psed_i` sind dieselben Mittel wie die übrigen Funktionen; das Skript bindet BSD-Portabilität über `psed_i` bereits, der neue Code ergänzt nichts Nicht-Portables (`\]`, `\(`, `(…)?`, Backreferenzen). ADR-0070 und der Slice äußern sich zur Host-Portabilität nicht; nichts zu bewerten.
- **`main()`: `touched`/`in_count`, Meldung, Commit-Entscheidungen** — für andere Bäume (`done/`, Carveouts) rückgabewert-gleich (`rewrite_incoming_in_file` endet mit dem Status von `rm -f`, also 0), Meldung `… (N eingehend, …)` unverändert in der Form; unter `docs/reviews/` zählt nur eine Datei mit ersetztem Link. Eine Report-Datei mit nur Span/Operand fällt aus dem Inhalts-Commit; Commit 1 bleibt der reine Move, Commit 2 entsteht nur bei `touched` > 0 — ein leerer Commit ist nicht möglich, ein Verweis, der über die Regel hinaus stehen bliebe, ist nur die Nicht-Link-Form (Absicht) oder R-2 (laut). Die einzige Verhaltensänderung außerhalb des Auftrags ist R-1.
- **Ausnahmeliste und Kommentar** — `eingehend_ausgenommene_pfade()` unverändert (`:!.harness/baseline`, `:!docs/plan/adr`); der Kommentar zitiert `ADR-0070` Festlegung 2 (Liste bleibt, `docs/reviews/**` ist kein Eintrag) und die Link-Form, gegen die ADR gelesen; `ADR-0033` Abnahme-Kriterium 1 steht dort nicht mehr für den Nachzug (Festlegung 4 der ADR). Skriptkopf: Zusage (Zeilen 22-23), `usage` (156), Grenze (5) (113-121) sind wahr; „bindet die Span-Hälfte" trifft Fall 15, „besteht, solange `.d-check.yml` unter `codepaths` `docs/reviews/**` ausnimmt" trifft `.d-check.yml:373-384`.
- **KERN (Punkt 2)** — siehe R-4; `git diff bc96ec5a..HEAD --stat -- internal` leer, Fall 19 grün.
- **Tests (Punkt 3)** — Erwartungen stammen aus Literalen bzw. aus der Fixture (`strings.Replace` auf der Probe, nicht auf der Ausgabe); jede der Assertions ist unter einer eigenen Mutation rot gesehen (459/460/461/462, M-a/M-b/M-c). Fall 15 misst die Grenze (Zitat im Span wird ersetzt, der reine Pfad daneben nicht) und färbt unter 459/460 rot; unter einer Kontext-Erkennung fiele er absichtlich (Trigger 6). Fall 16 hält `done/` (Zählung 5). Fall 17 ist eine Kontrolle der Probe (jede Form wird vom allgemeinen Ersetzer erfasst). `83044cc4`: Funktion statt Paket-Variable, Rückgabewert und Verwendung gleich (Echt-Test grün unter 315 und 462 auf demselben Stand).
- **Mutations-Fälle 459 bis 462 (Punkt 4)** — Köpfe `# files:`/`# expect:`/`# verify:` vorhanden und mit dem Namen des rot werdenden Falls deckungsgleich; die vier `sed`-Anker treffen im Quell-Bestand genau eine Stelle (`grep -c '^    docs/reviews/\*)$'`, `grep -c 'psed_i -E "s@[$]{ziel}'`, `grep -c 'rewrite_incoming_nach_baum "[$]rf"'` → je `1`), `\x24`/`[$]`-Konvention gehalten; `make shell-lint` läuft im Gate-Lauf unten. Fall 313: der bats-Fall hieß mit `ADR-0033 Abnahme-Kriterium 1` eine Quelle, die diese Frage nicht regelt (`ADR-0070` Festlegung 4) — die Umbenennung war nötig, der Anker zitiert jetzt den neuen Namen (Teillauf: `ok … rot`).
- **Sensor-Doku (Punkt 5)** — „Fünf gemessene Grenzen", die Span-Hälfte gebunden (Fall 15), Code-Block-Zitat und Referenz-Definition als benannte Lücken (Trigger 6/7), „in zwei Stufen gedeckt" (459 bis 461 → bats, 462 → Go-Test; je rot gesehen), „ein Kopplungs-Test führt dieses Werkzeug noch nicht" (stimmt gegen §1 des Plans) — jede Aussage gegen Code/Läufe belegt. Zustandsform, keine Chronik, keine Slice-Adresse als Pfad (§3.11), keine Messzahl ohne Kommando (die „Fünf" zählt die Aufzählung).
- **Abgrenzung (Punkt 6)** — `internal/archive` unberührt (Geschwister-Slice), `.d-check.yml` unberührt, keine ADR/Hard Rule/MR berührt (`git diff bc96ec5a..HEAD --stat` nennt nur Werkzeug, Tests, Fälle, Sensor-Doku, Roadmap-Marker, die Slice-Datei); `cb0638e4` berührte nur die Slice-Datei. §3.3: Move und Inhalt getrennt (`f9f089f4` Move, `cb0638e4` Nachzug). §3.9: keine Host-Toolchain in den Belegen des Diffs. §3.10: der Diff schließt nicht ab (kein `done/`, §7 des Plans leer). §3.11: kein einfrierendes Artefakt nennt den Plan als Pfad.
- **HIGH-Liste des Skills** — keine Verstöße gegen eine aktive ADR/Hard Rule; keine Gate-Lockerung; kein Stilles-Grün-Pfad in einem Gate (das Werkzeug ist kein Gate; R-1 ist die nächste Klasse, LOW); kein halluziniertes Gate (`make slice-mv` steht in `harness/README.md` §Werkzeuge); keine superseded ADR referenziert; keine Norm im Template-Kommentar; Kommentare tragen Klassen (Zusage, Kopplung, Grenze) im Indikativ, ohne verworfene Alternative und ohne Vorgangs-Kennung; keine Zustandsfelder berührt.

## Summary

0 HIGH · 0 MEDIUM · 1 LOW (R-1) · 4 INFO (R-2 bis R-5). Klassen für §7: R-1 *Fehlerabbruch durch Aufruf im `||`-Kontext entwaffnet*, R-2 *Regel-Rand ohne benannte Lücke*, R-3 *Regel-Ausprägung ohne Fall*.

## Übergaben

- **Implementer:** R-1 (die Aufrufform im `||`-Kontext neu fassen oder `psed_i` gegen das Weiterlaufen nach einem gescheiterten `sed` härten; die Gegenprobe ist die 0200-Datei unter `done/`, die den Abbruch wiederbringen muss); R-3 (ein Fall mit drei Links in einer Zeile) optional.
- **Verifier:** die Rot-Belege der DoD-Punkte sind hier gefahren und in der Tabelle mit der gelesenen Meldung genannt (459 bis 462, 313, 315, 316, 346, 363-slice-mv, 363-ziel-e2e); nachzutragen ist nur, was der Verifier gegen die DoD selbst prüft (Politik-D-Messung §5 Punkt 2 mit `make docs-check` in einer Kopie ist hier nicht gefahren).
- **Planner:** keine Änderung der Abnahme; R-2 und R-4 sind für die Closure-Notiz/§7 benennbare Grenzen (Titel-Link, Spitzklammer-Form; Ziel-Repo behält den alten Nachzug); Klassen-Kandidaten oben.
- **Architect:** keine. Kein HIGH, darum kein Konflikt-Pfad.
