# Review-Report: slice-ci-stempel-eingecheckt-v1 — 2026-11-28

**Review-Art:** Code — geprüft gegen Slice-Plan + ADR (Modul 10 §Drei Review-Arten). DoD-/Spec-Konformität bleibt dem Verifier.

**Gegenstand:** Implementation-Commits von `slice-ci-stempel-eingecheckt-v1` (Claim `4245f924`, `git mv` nach `in-progress/`): `888b1867` (LP a: gitignore-Umstellung + Hash-Ausnahme + Anlage 821 + Fall-791-Umankerung), `150d0cd1`/`177b9f6c` (passt-Fassung + Kommentar-Nachzug), `227c24b5` (LP b/c: ci.yml-Verdrahtung + full-smoke-skip.sh + Schreiber-Zug + Anlagen 822/823), `ef999aa0`/`956c76d4` (die 13 je-Check-Keys committet), `17e8622c` (Doku-Nachzug harness/README), `9ec2020d`/`497a353b`/`7c490012`/`c64de92a`/`81c2b0e8` (Plan- und Kennungs-Nachzüge). Bestands-Kontext außerhalb des Slices, geprüft als Heut-Stand und Anlagen-Umfeld: `d94b8989` und `bdfa8de6` (Nachfolger-Slice `slice-full-smoke-jevariante-stempel-v1` je ADR-0113, der Festlegung 4 revidiert).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.3.0 · **Modell:** GLM (cloud) · **Datum:** 2026-11-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- `docs/plan/planning/in-progress/slice-ci-stempel-eingecheckt-v1.md` (§1/§2/§3)
- ADR-0111 (Festlegungen 1–6; Festlegung 4 je ADR-0113 revidiert), ADR-0113 (Teil-Revision von Festlegung 4), ADR-0108, ADR-0103, ADR-0099, ADR-0083
- `AGENTS.md` §3 (Hard Rules), §5, §6
- [`MR-003`](../../harness/conventions.md), [MR-017](../../harness/conventions.md), [MR-071](../../harness/conventions.md), [MR-090](../../harness/conventions.md) — Kennungen als Inline-Form (Zeitdokument)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | ADR-0111 §Fitness Function nennt `test/ci-stempel-committed.bats (neu)` als Träger der SKIP-/Teildrift-Klassifikation über dem committeten je-Check-Satz (Happy/Teildrift/Boundary-Zeile, auch „die zwei Gesamt-Dateien fehlen am Klon, ohne dass ein SKIP greift") — die Datei trägt die Klassifikation nicht; Träger ist das unveränderte `test/gates-fastpfad.bats` (Fälle SKIP, Teildrift, GATES_FORCE-Zwang) und der reale CI-Lauf. Deckung besteht, die Orts-Nennung der Fitness-Zeile ist abweichend; die ADR steht ab `Accepted` unveränderlich — die Naht bleibt bestehen, bis ein Folge-ADR oder ein Closure-Vermerk sie nennt. | ADR-0111 §Fitness Function | `test/ci-stempel-committed.bats` · ADR §Fitness Function Zeile 1 nennt die Datei für die SKIP/Teildrift-Zusage | ja — `grep -n '@test' test/ci-stempel-committed.bats` zeigt vier Fälle (gitignore, zwei Verdrahtung, Rezept), keinen über der je-Check-Klassifikation; SKIP/Teildrift stehen in `test/gates-fastpfad.bats` | Fitness-Zeile nennt Wächter-Ort abweichend von der Implementation |
| F-2 | LOW | Mutations-Fall 823 (durch diesen Slice in `227c24b5` angelegt, je `bdfa8de6` auf den heutigen Konsum umgeankert) und Fall 832 (Nachfolger-Slice `d94b8989`) binden dieselbe Quell-Stelle — den `mengen-hash`-case-Zweig in `full-smoke-skip.sh` — und denselben Wächter; beide Sed-Muster haben exakt einen Treffer im Quellbestand und färben denselben SKIP-Fall. Gegenprobe (Polarität ausgeschrieben): der Fall 823 bindet nichts Eigenes über 832 hinaus — nach der Umankerung dupliziert er sie. | MR-071 · MR-090 (Maintainability) | `test/mutations/823-e2e-skip-liest-fremdes-feld.sh:18` · `test/mutations/832-*.sh:18` — beiden Fällen steht dieselbe Quell-Zeile als Ziel | ja — `make mutate MUTATE_CASES=test/mutations/823-e2e-skip-liest-fremdes-feld.sh test/mutations/832-*.sh` | Mutations-Doppelanlage über dieselbe Quell-Stelle|
| F-3 | LOW | Der Negativfall „fehlt" im Slice-Wächter (`227c24b5`) fährt seine fehlende Stempel-Datei als **leere Datei** (`STAPEL` ist am Lauf leer), nicht als fehlenden Pfad — der `[ ! -f "$stempel" ]`-Zweig der Klassifikation bleibt im Wächter dieses Slices ungefahren, während der Fall-Name das Fehlen behauptet (`AGENTS.md` §3.6-Naht am Slice-Diff). Im Heut-Bestand trägt der Nachfolger-Slice den Fall an real fehlender Datei (`test/full-smoke-varianten-keys.bats` „ein Stempel fehlt"). | AGENTS.md §3.6 | `test/ci-stempel-committed.bats` (Fassung `227c24b5`) — Fall benutzt die leere `STAPEL`-Datei statt eines nicht existierenden Pfads | ja — lesend am Commit `227c24b5`; im Bestand durch den Fall des Nachfolger-Slices | Negativfall misst leeren Vertreter statt fehlender Datei |
| F-4 | LOW | Drei Commits des Slices tragen die Slice-Kennung falsch geschrieben — `slice-ci-stempel-**einte**checkt-v1` (`ef999aa0`, `7c490012`, `c64de92a`) statt `…-eingecheckt-v1` — und lösen nicht zum Slice-Plan auf; beide Commit-Wächter (`pretooluse-commit-msg-guard.sh`, `.githooks/commit-msg`) halten nur Anwesenheit einer Kennung, nicht ihre Auflösung. | AGENTS.md §5 · MR-057 | `git log --format='%s'` — Zeilen der drei Commits tragen die abweichende Form | ja — `git log --format='%s' \| grep -c eintecheckt` → 3 | Falsch geschriebene Slice-Kennung in Commit-Message |
| F-5 | INFO | Die Polarität der CI-Bedingung (`push` **UND** `refs/heads/main` je Komponente verglichen) ist in den beiden Verdrahtungs-Fällen durch String-Vorkommen gehalten (`grep -qF 'github.event_name'`, `grep -qF 'refs/heads/main'`), nicht durch die Vergleichs-Semantik — ein invertierter oder verfälschter Vergleich (etwa nur `ref` geprüft, oder `pull_request` statt `push`) bleibt in beiden Verdrahtungs-Fällen grün. Die Grenze ist am selben Ort deklariert (bats-Kopf: „die Verdrahtung der Workflows belegt der reale CI-Lauf selbst") und die Skip-Behauptung trägt außerhalb den main-Push-Schutz — deshalb INFO, kein Stilles-Grün. | Maintainability | `.github/workflows/ci.yml` Gates- und full-smoke-Job-Bedingung · `test/ci-stempel-committed.bats` Fälle ci-verdrahtung | nein — kein Gate färbt bei der Invert-Mutation; Träger ist der reale CI-Lauf (MR-003-Form, im bats-Kopf benannt) | CI-Bedingungs-Polarität im Text-Wächter ungebunden, Grenze am Ort benannt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `.gitignore` Pflicht-Form (ADR-0111 Festlegung 1; Heut-Stand je ADR-0113 Festlegung 5 erweitert: `/.harness/state/*` + `!.harness/state/gates-passed-*.key` + `!.harness/state/full-smoke-passed-*.key`, exakte eine-Datei-Zeile entfallen) und die zwei gitignored Gesamt-Dateien (Festlegung 3) | geprüft, ohne Befund — Form trifft die Festlegung; Kopfkommentar trägt den committeten Zustand, keine Chronik |
| `harness/tools/working-tree-hash.sh` Hash-Ausnahmen fail-closed (MR-017, ADR-0103 Festlegung 2-Form): fail-closed-Zweig für nicht deklarierten getrackten/untracked Inhalt unter `.harness/state/` und `.harness/stamp/` mit Meldung und Exit 2 | geprüft, ohne Befund — Grenz-Sonden im Scratch gefahren (Suffix-Drift `gates-passed-lint.key.bak`, fremdes Unterverzeichnis `keys/`, Pfad ohne Kind, fremder Wert) fallen alle fail-closed; die deklarierten Klassen decken exakt; `working-tree-hash-abnahme.bats` fährt Rotation und fail-closed reale |
| `.github/workflows/ci.yml` Verdrahtung (ADR-0111 Festlegung 2): push-auf-`main` Gates unforced über unverändertes `make gates`; `pull_request`, Nicht-main-Push und dispatch über `GATES_FORCE=1`; `FULL_SMOKE_SKIP_KONSULT=1` nur im push-main-Zweig des Voll-E2E-Jobs; PR-Jobs fahren `make full-smoke` voll (Konsult-Umgebung ungesetzt) | geprüft, ohne Befund — beide Job-Zweige lesen exakt die Form der Festlegung 2; Fall 822 bindet die unforced-Zeile (Ziel exakt 1 Treffer) |
| Festlegung 5 (make committiert nicht): Schreiber-Züge in `full-smoke.sh`, `gates-fast.sh`, `Makefile` | geprüft, ohne Befund — kein `git commit`/`git add`-Zug in den Schreibern; die Key-Commits (`ef999aa0`, `956c76d4`) und der heutige je-Variante-Stempel-Satz sind eigene Implementer-Commits |
| SKIP-Meldungen nennen den benannten Rest je Kante (ADR-0111 Folgepflicht): `gates-fast.sh` `rest_meldung`, `full-smoke-skip.sh` `skip_meldung` (Fassung `227c24b5`; Heut-Stand je ADR-0113 je Variante) | geprüft, ohne Befund — Rest-Form je Meldung vorhanden; Doku-Nachzug `17e8622c` trägt die Bindungen an den README-Zellen |
| Mutations-Anlagen 821/822 (dieser Slice) und 832/834 (Nachfolger-Slice) an MR-071/MR-090: jedes Sed-Muster gegen den Quellbestand, Anker am Commit, `expect:` am benannten Wächter | geprüft, ohne Befund je Zielform — 821 trifft exakt die gitignore-Zeile (1 Treffer), 822 exakt die `make gates`-Zeile (1 Treffer), 832/834 ihre Zeilen je 1 Treffer ( Doppelung 823/832 als F-2 gemeldet); Exklusiv-Gegenprobe 822 gelesen: kein Mitfärben, der Fall trägt seine Klasse |
| Kommentar-Regel `AGENTS.md` §3.7 über die neuen/berührten Köpfe (`.gitignore`, `working-tree-hash.sh`, `full-smoke-skip.sh`, ci.yml-Job-Kommentare, Fall-Anlagen): keine Chronik, keine verworfenen Alternativen, Klassen Zusa-/Grenze/Kopplung | geprüft, ohne Befund — die eine Chronik-Rest-Zeile am Slice-Plan hat der Nachzug `81c2b0e8` bereits geräumt |
| Commit-Zuschnitt §3.8/§3.10: keine Slice-Commits berühren Architect-Artefakte (AGENTS.md §3, ADRs, conventions-Block) | geprüft, ohne Befund — reine Implementer-, Keys- und Doku-Züge; Plan-Nachzüge tragen die Slice-Kennung |
| Plan §3-Zuordnung: alle drei Liefer-Punkte sind im Diff (LP 1: gitignore + Hash-Ausnahme + Anlage 821 + Fall-791-Umankerung; LP 2: ci.yml + Anlage 822; LP 3: Schreiber-Zug + full-smoke-skip.sh + Anlage 823); keine Plan-Abweichung ohne Grund — Wächter-Name war im Plan ausdrücklich dem Implementer überlassen | geprüft, ohne Befund |
| Die `varianten`-Zähl-Lesart (Plan §6-3, Schreiber zählt top-level `^echo "full-smoke: OK —`): open gelegt in `497a353b`, Feld je ADR-0113 entfallen | geprüft, ohne Befund — Lesart am Schreiber-Kommentar verankert, kein stiller Rest |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 4 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Fitness-Zeile nennt Wächter-Ort abweichend von der Implementation · Mutations-Doppelanlage über dieselbe Quell-Stelle · Negativfall misst leeren Vertreter statt fehlender Datei · Falsch geschriebene Slice-Kennung in Commit-Message · CI-Bedingungs-Polarität im Text-Wächter ungebunden, Grenze am Ort benannt

## Verdikt

**Merge-blockierend:** nein — keine HIGH- oder MEDIUM-Findings; die drei LOW finden ihre Träger in der Bestands-Nachlesung (F-1 als Naht, die eine Folge-ADR oder ein Closure-Vermerk benennt; F-3 trägt der Nachfolger-Slice-Wächter; F-2 verträgt eine Fall-823-Rücknahme durch den zuständigen Zug).

**Übergabe:** Findings an den Implementer; die Finding-Klassen gehen in die Slice-Closure §7 (Beobachtungs-Register-Sichtung §8 vorschalten: kein Treffer unter der Schwelle an der berührten Ebene sichtbar). Dieser Report ist Lauf-Beleg — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
