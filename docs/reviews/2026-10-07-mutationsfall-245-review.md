# Review — Mutationsfall 245 ankert wieder auf den Move-Commit

* Gegenstand: Commit `2f27337c` (`test/mutations/245-archive-welle-go-move-commit-entfaellt.sh`, sed-Muster)
* Bezug: [`ADR-0041`](../plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md), [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand), [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7
* Rolle: Reviewer, frischer Kontext

## Findings

### INFO-1 — Fallkopf nennt einen Test, die Mutation färbt fünf

- `kategorie`: INFO
- `quelle`: Reviewer-Skill §LOW/INFO mit Eskalation („Mutations-Fall nennt einen Test, die Mutation färbt mehrere")
- `pfad`: `test/mutations/245-archive-welle-go-move-commit-entfaellt.sh:3`
- `befund`: Unter der Mutation werden neben `TestAnwendenTrenntMoveVonInhalt` vier weitere Tests rot — `TestAnwendenOhneVorlageNenntDenRueckweg`, `TestAnwendenBrichtBeiVerletzterStubFormAb` (beide `internal/archive`), `TestArchiveWelleEchtArchiviertUndSetztZweiCommits` und `TestArchiveWelleAltbestandSchreibtDieMengeDerVorschau` (beide `cmd/ai-harness-init`, letzterer der Altbestand-Pfad). Der Kopf nennt nur den ersten. Kein Exklusivitäts-Anspruch im Kopf; der benannte Test bindet als einziger die **Reihenfolge** der git-Aufrufe (Move-Commit vor `rm`/`add`), die übrigen zählen Commits — struktureller Nebeneffekt der einen `g.Commit`-Stelle, keine Redundanz. Die Kopfzeile „die [Commit-Folge] liest kein Gate" (Bestand, vom Diff nicht berührt) ist enger zu lesen, als sie dasteht: `make test` liest sie über diese fünf Tests.
- `verifizierbar`: ja (Mutation in Kopie anwenden, `make test-go`)
- `klasse`: Mutations-Fall nennt einen Test, die Mutation färbt mehrere

### INFO-2 — Beobachtung: der veraltete Patch war zwei Nächte unbemerkt

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (Haltbarkeit der Zähne)
- `pfad`: `harness/tools/mutate.sh:811` (Meldung „Mutation hat nicht gegriffen … Patch veraltet?")
- `befund`: `b64b75b1` änderte die Zeile, die der Fall per `# files: internal/archive/anwenden.go` ankert; erkannt wurde das erst im Nachtlauf, und dort erst nach zwei roten Nächten. Früher gezeigt hätte es eine statische Anwendbarkeits-Prüfung je Fall (Muster trifft genau eine Zeile, ohne Testlauf) in `make gates`, oder ein Teil-Lauf der Fälle, deren `# files:` der Commit berührt — keins von beiden existiert (`grep -n '^record-gates:' Makefile`: kein mutate-Bezug). Die Verzögerung zwischen rotem Nachtlauf und Reaktion hängt an keinem Träger. Nur Beobachtung, Zuordnung beim Planner.
- `verifizierbar`: nein
- `klasse`: veralteter Mutations-Patch erst im Nachtlauf sichtbar

## Geprüft, ohne Befund

- **(a) MR-071:** Das Muster trifft im Quellbestand genau eine Zeile — `grep -rnF` des Zeilenrumpfs über `*.go` → nur `internal/archive/anwenden.go:112`. Die Ersetzung `if false {` entfernt genau den Move-Commit (`g.Commit("… (reiner Move" + kennungSuffix(b) + ")")`); `return err` darunter bleibt unerreichbar und kompiliert. Gemessene Wirkung: `git-Aufrufe = [mv mv mv rm add commit], want [mv mv mv commit rm add commit]` — die Zusage „Move-Commit getrennt vom Inhalts-Commit", nichts anderes.
- **(b) Fall gefahren:** `make mutate MUTATE_CASES=245-archive-welle-go-move-commit-entfaellt` → `ok … -> TestAnwendenTrenntMoveVonInhalt rot`, `1 ok, 0 Befund(e)`.
- **(c) Fallkopf §3.6/§3.7:** Kopf beschreibt die Stelle im Indikativ, ohne Chronik; `# expect:` nennt einen real rot werdenden Test (Weiteres INFO-1).
- **Gate:** `make gates` einmal am Ende über dem Baum mit diesem Report.
