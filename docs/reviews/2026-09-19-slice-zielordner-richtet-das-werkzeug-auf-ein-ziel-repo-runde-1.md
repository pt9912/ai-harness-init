# Review-Report: slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo — 2026-09-19 (Runde 1)

**Review-Art:** Code — geprüft gegen den Slice-Plan, die im Kopf genannten ADRs und
`AGENTS.md` §3 (Modul 10 §Drei Review-Arten).

**Gegenstand:** Diff `66fcdfb1..0acdf385` — ein Commit, `0acdf385` („Rolle
Implementation: … der Dispatch traegt den Zielordner …“), 10 Dateien, +576/−133.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 ·
**Modell:** GLM (claude-agent-sdk, Typ `reviewer`) · **Datum:** 2026-09-19

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo`
  (Stand `docs/plan/planning/in-progress/` am 2026-09-19)
- ADR-0058 (Festlegung 2 — laut-Bruch/Kopplung, Festlegung 3 — eigenes Fragment,
  eigenes Target, kein Prerequisite) · ADR-0059 (Festlegung 3 — Dogfood-Hälfte,
  Festlegung 4 — Transport im gepinnten Docker-Bild), beide `Accepted`
- `LH-FA-01` · `LH-QA-02` · `LH-QA-03`
- `AGENTS.md` §3 (Hard Rules)

**Sensor-Läufe dieses Laufs** (Wegwerf-Klon bei `0acdf385`, gepinnte Images):
`make artifact` + vier Prozess-Proben (drei Sperren-Negative, eine Doku-Form-Probe) ·
`make test-go` dreimal unter Mutation (377 · 253 · geschwächte Zusicherung, von Hand
eingesetzt) mit gelesenen Failure-Zeilen · `make e2e-abdeckung` (Regeneration:
unverändert, 19 Stufen) · Zählungen der Aufruf-Formen in README/Handbuch
(`git show 0acdf385:… | grep -c`, README zielordner-vor-Flags **1**, Handbuch **11**,
alte Form **0** · **0**). `make gates`, `test-bats` und der Mutations-Listenstand
wurden vom Implementer berichtet und hier nicht wiederholt.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | README (1 Stelle) und Benutzerhandbuch (11 Stellen) dokumentieren `ai-harness-init <zielordner> --lang go --name …` — Flags NACH dem ersten Positionsargument. Das Standard-flag-Paket parst Flags nur vor dem Positionsargument (die Usage des Werkzeugs sagt es selbst); fs.Parse liefert NArg=4 → „unbekanntes Argument“, Exit 2. Am gepinnten Bau von `0acdf385` gemessen: rc=2, Meldung gelesen. Jede dokumentierte Happy-Path-Einladung bricht. | `LH-FA-01` + Slice-Plan §2 DoD („Doku-Update für die neue Aufruf-Form“) | `README.md:17` · `docs/user/benutzerhandbuch.md` (11 Stellen) | ja — Prozess-Probe an `0acdf385` (Exit 2, „unbekanntes Argument“); `make smoke` zeigt es an Stufe 2 | Doku-Beispiel-Form widerspricht der Parser-Semantik (Flags nach dem Positionsargument) |
| F-2 | HIGH | Die 8 geänderten Init-Aufrufstellen in `smoke.sh`/`full-smoke.sh` tragen dieselbe gebrochene Flag-Form — und bootstrappen zusätzlich Nicht-Git-Verzeichnisse: `tmprepo="$(mktemp -d)"` ohne `git init` vor dem Aufruf (`full-smoke` initisiert bei Zeile 390/2087/2482/2525/3035 erst NACH dem Bootstrap). Die neue `istGitRepo`-Sperre bricht jede Stelle (Exit 2, gemessen). Beide E2E wurden zum Commit nicht gefahren; der Bericht nennt sie nicht. | `LH-FA-01` · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) | `harness/tools/smoke.sh:29,40` · `harness/tools/full-smoke.sh:372,2079,2481,2524,2737,2800,3030` | ja — Sperre-3-Probe („kein bestehendes Git-Repo“, Exit 2); `make smoke` / `make full-smoke` brechen an Stufe 2 | Neue Vorbedingung ohne Nachzug an den eigenen E2E-Aufrufstellen |
| F-3 | HIGH | Der Test-Kommentar trägt den Beleg der zweiten Rot-Gegenprobe als Lauf-Protokoll: „Beide von Hand gefahren.“ (Perfekt, Vorgang) — keine der fünf Kommentar-Klassen, und der Satz ist der einzige Träger der geschwächten-Zusicherung-Probe im Bestand. Kein Gate fängt das. | `AGENTS.md` §3.7 (Hard Rule) | `cmd/ai-harness-init/main_test.go` (Kommentar über `TestUnfallVektor_OhneArgumentImRepoWurzel`) | ja — die Zusage selbst ist wahr (dieser Lauf sah die Verzeichnis-Prüfung rot, F-5); der Kommentar trägt statt eines Sensors ein Protokoll | Beleg-Klasse eines Gegenbeispiels ist Lauf-Protokoll statt Sensor |
| F-4 | MEDIUM | Der Unfall-Vektor-Case steht in der Go-Stufe (`TestUnfallVektor_OhneArgumentImRepoWurzel` baut den Träger im Test), die Verhaltens-Negative von LP1 ebenso (`TestRun_OhneZielordnerBrichtLaut`) — der Plan schrieb beide nach `test/zielordner.bats` am gepinnten Träger (§2 LP1/LP2, §5), und der Plan-Text ist nicht geändert. Das Wiegen trägt die Richtung: das bats-Image mountet read-only und führt keine Go-Toolchain (ein Prozess-Fall dort verlangte eine Build-Abhängigkeit des `test-bats`-Targets), und ein Vektor am gepinnten Träger ist vor dem nächsten Release-Schnitt konstruktiv unmessbar — der Go-Lauf misst genau den Stand, der zum nächsten Schnitt wird. Es bleibt eine Plan-Abweichung, die der Plan-Text so nicht hergibt (Plan-Korrektur vor der Closure, Planner). | Slice-Plan §2 LP1/LP2, §5 · `LH-FA-01` | `test/zielordner.bats` (nur Deckung) · `cmd/ai-harness-init/main_test.go` | ja — Plan-Text gegen Test-Stand; die Deckungshälften (bats Struktur/Kopplung, Go Verhalten) sind im bats-Kopf dokumentiert | Verortung der Verhaltens-Deckung gegen den Plan-Text verschoben, Plan nicht korrigiert |
| F-5 | MEDIUM | Die geschwächte-Zusicherungs-Gegenprobe des Unfall-Vektors („bricht, aber schreibt“) trägt keinen Fall in `test/mutations/` — nach §3.6 ist die Klasse damit unbewacht. Eigener Lauf der Probe im Wegwerf-Klon: `TestUnfallVektor_OhneArgumentImRepoWurzel` fällt genau an `main_test.go:826` (Verzeichnis-Prüfung), Exit-Code, Meldung, Usage und stdout halten — der Zahn bindet, aber er ist nur von Hand wiederholbar. | `AGENTS.md` §3.6 | `test/mutations/` (keine Datei der Klasse) · `cmd/ai-harness-init/main_test.go:826` | ja — `make mutate` fährt die Klasse nicht (kein Fall); der Zahn selbst wurde hier rot gesehen | Rot-Gegenprobe ohne gelisteten Mutations-Fall |
| F-6 | MEDIUM | Der Happy-Pfad des Lastenhefts (Rang 1) und die Architektur-Sicht tragen die alte Aufruf-Form ohne Ziel-Argument (`ai-harness-init --name X`, `--lang go --name X`, Sequenz `ai-harness-init --name X`) — diese Formen enden ab `0acdf385` mit Exit 2 (gemessen). Öffentlicher Vertrag berührt; Spec-Pflege ist Planner-/Architect-Arbeit (CR nach `MR-015`/`MR-042`, Anlass in der Closure-Notiz). | `LH-FA-01` | `spec/lastenheft.md:46,47` · `spec/architecture.md:121` | ja — die Lastenheft-Form am gepinnten Bau → Exit 2 | Spec-Happy-Path hinter dem Feature (CR-Bedarf) |
| F-7 | LOW | Der Test-Name `TestInitPfadNimmtKeinPositionsargument` behauptet eine Eigenschaft, die der Code seit diesem Slice nicht mehr hält — der Init-Pfad nimmt genau ein Positionsargument. Der gemessene Inhalt (Mehrfach-Sperre, Git-Repo-Tür) trägt der Kommentar darüber; der Name liest sich gegen den Bestand. | Maintainability | `cmd/ai-harness-init/main_test.go` (Funktionsname) | ja — Name gegen Verhalten | Test-Name behauptet eine überholte Eigenschaft |
| F-8 | INFO | Die §3-Tabelle des Plans nennt 3 Dateien, der Diff berührt 10 (smoke.sh, full-smoke.sh, README.md, e2e-abdeckung.md, main_test.go, zwei Mutations-Dateien). Keine §1-Grenze ist verletzt — die Mehrarbeit ist mechanische Folge der neuen Aufruf-Form; die Ausgänge stehen in den Übergaben 2–4. | Slice-Plan §3 (Plan-Form) | `docs/plan/planning/done/slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo.md` | ja — `git show --stat` gegen die Tabelle | Plan-Tabelle hinter dem Diff ohne Grenzverletzung |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Die vier Dispatch-Fälle (`span-emit`, `span-report`, `archive-welle`, `vendor-baseline`) | geprüft, ohne Befund — Körper im Commit unverändert; `add-lang` kam als fünfter Fall hinzu (die CWD-Auflösung steht nur dort, Verhalten unverändert); ADR-0058 Festlegung 3 / ADR-0059 Festlegung 3 unberührt; der bats-Deckungs-Fall hält die Menge (genau 5 `case`-Zeilen, je einmal) |
| Sperren-Reihenfolge und drei Negative am gepinnten Bau | geprüft, ohne Befund — kein Ziel → Meldung „kein Zielordner angegeben“ (rc=2, nichts geschrieben); zwei Ziele → „unbekanntes Argument“ mit Token; Ziel ohne `.git` → „kein bestehendes Git-Repo“ (rc=2, Ziel unangetastet); Reihenfolge Leer→Mehrfach→Git-Repo→Bootstrap im bats-Deckungs-Fall 3 verankert |
| Mutation 253 (Polarität) | geprüft, ohne Befund — rot an der Meldung („stderr nennt den Mehrfach-Fall nicht“) für alle drei vertippten Namen mit Extra-Argument; der Fall ohne Extra-Argument bleibt grün (Git-Repo-Tür von der Mutation unberührt) — die Sperre ist die Form des Abbruchs, nicht irgendein Abbruch |
| Mutation 377 (Polarität) | geprüft, ohne Befund — rot am Prozess; die Verzeichnis-Prüfung (826) ist unter der geschwächten Zusicherung die einzige rote Assertion (F-5) |
| e2e-abdeckung.md als Generator-Ausgabe | geprüft, ohne Befund — `make e2e-abdeckung` im Wegwerf-Klon: „unverändert“ (19 Stufen, 19 Deklarationen) |
| §3.7 der README-/Handbuch-Änderungen (Zustands-Form) | geprüft, ohne Befund — Indikativ über den Zustand, keine Chronik; keine alte Aufruf-Form übrig (README 0, Handbuch 0) |
| Commit-Zuschnitt, Fremd-Kennungen | geprüft, ohne Befund — ein Commit, 10 Dateien, alle zum Slice gehörig; Message trägt `LH-FA-01` + ADR-0058 Festlegung 2; keine Kennungen fremder Repos, keine Baseline-Dateien berührt |
| bats-Deckung (Fälle 2/3/4: Getwd-Zählung, Sperren-Ordnung, Usage-Zeile) | geprüft, ohne Befund — die Zählungen sind Anker-gebunden (leere Treffermenge färbt rot), die Usage-Zeile trägt die Zielordner-Form am Zeilenende |

**Kontext außerhalb des geprüften Diffs:** der Arbeitsbaum trägt uncommittete
Korrekturen an `harness/tools/smoke.sh` und `harness/tools/full-smoke.sh`
(Zielordner ans Ende der Aufrufe, `git init -q` vor den Stellen) — sie bestätigen
F-1/F-2, sind aber nicht Teil des geprüften Commits; README und Benutzerhandbuch
tragen die gebrochene Form auch im Arbeitsbaum weiter.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 3 |
| MEDIUM | 3 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Doku-Beispiel-Form widerspricht der
Parser-Semantik (Flags nach dem Positionsargument) · Neue Vorbedingung ohne Nachzug
an den eigenen E2E-Aufrufstellen · Beleg-Klasse eines Gegenbeispiels ist
Lauf-Protokoll statt Sensor · Verortung der Verhaltens-Tests gegen den Plan-Text
verschoben, Plan nicht korrigiert · Rot-Gegenprobe ohne gelisteten Mutations-Fall ·
Spec-Happy-Path hinter dem Feature (CR-Bedarf) · Test-Name behauptet eine überholte
Eigenschaft · Plan-Tabelle hinter dem Diff ohne Grenzverletzung

## Verdikt

**Merge-blockierend:** ja — F-1 und F-2 brechen jede dokumentierte bzw. jede
E2E-Aufrufstelle der neuen Form (gemessen, nicht gefolgert); F-3 bricht eine Hard
Rule. F-4 und F-6 sind Plan-/Spec-Seite (Planner), F-5 ist eine Ergänzung am
Mutationssatz.

**Übergabe:** F-1, F-2, F-3, F-5 an den Implementer (Fix im Slice, nicht als
uncommittete Randnote); F-4 und F-6 an den Planner (Plan-Korrektur, Lastenheft-CR);
die Finding-Klassen gehen in die Slice-Closure §7 und von dort in den Zähler. Dieser
Report ist Lauf-Beleg — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).