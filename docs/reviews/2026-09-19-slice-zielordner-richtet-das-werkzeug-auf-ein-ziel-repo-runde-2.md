# Review-Report: slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo — 2026-09-19 (Runde 2)

**Review-Art:** Code — geprüft gegen den Slice-Plan, die im Kopf genannten ADRs und
`AGENTS.md` §3 (Modul 10 §Drei Review-Arten). **Kein Neu-Review:** die Fixes der
Runde 1 (`docs/reviews/2026-09-19-slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo-runde-1.md`,
Commit `96883f8a`) sind der Gegenstand.

**Gegenstand:** der Commit `399c17f1` (11 Dateien, +77/−48) — die Behebung der drei
HIGH (F-1, F-2, F-3) und des F-5/F-7 aus Runde 1, plus N-3 (367-expect).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 ·
**Modell:** GLM (claude-agent-sdk, Typ `reviewer`) · **Datum:** 2026-09-19

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo`
  (`docs/plan/planning/in-progress/`, Stand am 2026-09-19)
- ADR-0058 (Festlegung 2 — laut-Bruch, `Accepted`) · ADR-0059 (Festlegung 3/4 —
  `Accepted`)
- `LH-FA-01` · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · `LH-QA-03`
- `AGENTS.md` §3 (Hard Rules)
- Runde-1-Report (oben) — die drei HIGH, zwei MEDIUM, ein LOW, ein INFO

**Sensor-Läufe dieses Laufs** (Baum bei `399c17f1`, gepinnte Images):

- Form-Zensus README/Handbuch (`grep -n` über alle `ai-harness-init`- und
  `<zielordner>`-Vorkommen, je Stelle gelesen).
- Sperren-Reihenfolge in `cmd/ai-harness-init/main.go` gelesen (Zeilen 207–235) ·
  Usage-Text (34–48) gegen die dokumentierten Formen gestellt.
- Mutations-Anker geprüft: `fs.NArg() == 0 {` und `> 1 {` je genau 1×
  (`main.go:207,212`); `baum_aussagen_im_ziel "$tmprepo_doc"` genau 1×
  (`full-smoke.sh:2087`); Message-Vorlage (`full-smoke.sh:185`, Label
  `sprachlos`) gegen die 367-expect gestellt.
- **Mutation 378 selbst gefahren** (Mutation angelegt, `make test-go` im
  gepinnten Docker-Umfang, Meldung gelesen, danach zurückgenommen):
  `TestUnfallVektor_OhneArgumentImRepoWurzel` färbt **allein an
  `main_test.go:827`** — *„das stehende Repo wurde angefasst: vorher [.git
  Makefile], nachher [.git .harness Makefile] — der Unfall fuhr wieder"*;
  Exit-Code (813), Meldung (816), Usage (819) und stdout-leer (822) bleiben unter
  der Mutation grün, nur die übrigen Pakete laufen weiter grün (`ok
  internal/…`). Der Zahn bindet die geschwächte Zusicherung an der
  Verzeichnis-Prüfung — genau die Polarität, die die Runde 1 forderte (grün bei
  der Schwächung hieße „bindet nicht“).
- **Mutation 377 selbst gefahren** (gleiche Prozedur): derselbe Fall färbt an
  `main_test.go:814/817/820` und **827** — der Fall-through hinter der inert
  gestellten Leer-Sperre erreichte `bootstrap("", …)`, schrieb `.harness` in das
  stehende Repo und brach dort (*„Exit 1 ohne Argument, want 2 … stderr:
  docker run … executable file not found“* — der Schaden ist gemessen, nicht der
  Exit-Code); daneben färbt `TestRun_OhneZielordnerBrichtLaut` an der run-Ebene.
  Auch hier: der stille Init-Pfad ist wieder offen, und der Fall fängt ihn.
  Beide Läufe danach zurückgenommen (`git checkout`), Baum sauber.
- `make e2e-abdeckung`: *„unverändert — docs/user/e2e-abdeckung.md (19 Stufen,
  19 Deklarationen)“*.
- Plan-Historie (`git log 0acdf385..HEAD -- <Plan-Datei>` → leer) ·
  Fremd-Kennungen in Added-Lines (`git show 399c17f1 | grep '^+' | grep -i …`
  → 0) · e2e-abdeckung-Diff (nur Stufen-Zeilennummern, 38 Zeilen) und
  Stichproben der Zeilen-Referenzen gegen `full-smoke.sh`.

**Nicht gefahren in diesem Lauf:** `make gates`, `make smoke`, `make full-smoke`
und die Mutationen 253/367 — sie sind im Kopf des Auftrags als Implementer-Läufe
dokumentiert (`make gates` grün, `full-smoke` EXIT 0 real mit Netz, `smoke`
EXIT 0) und wurden in Runde 1 bzw. vom Implementer gemessen; dieser Lauf prüft
die Fix-Seite und fährt die neuen Zähne selbst (oben).

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-9 | LOW | Die Vorverlagerung der Git-Init-Anlage (F-2-Fix) lässt die fünf Nachlauf-Zeilen `git init -q "$tmprepo*"` nach dem Bootstrap stehen (`full-smoke.sh:395,2092,2487,2530,3040`) — sie sind auf dem Erfolgspfad No-ops, und der einzige Kommentar zur Notwendigkeit (slice-031, Zeile 393–394) sitzt an der Nachlauf-Zeile, nicht an der tragenden Vorlauf-Blase (128–144). Ein späterer Lauf, der die Vorlauf-Blase löscht, weil "git init passiert ja später", reißt die Vorbedingung der Git-Repo-Sperre wieder ein — der Bootstrap bricht an der Sperre, nicht an einer erkennbaren Stelle. | Maintainability | `harness/tools/full-smoke.sh:395,2092,2487,2530,3040` | ja — Lesart gegen die Sperren-Reihenfolge in `cmd/ai-harness-init/main.go:207–235`; die Reihenfolge selbst hält `test/zielordner.bats` (Kopplung an 377) | Redundanter Nachlauf-Zustand nach Vorverlagerung der Git-Init-Anlage |
| F-10 | INFO | Der Plan buchstabiert die Aufruf-Form in §1 und §2 LP1 als `ai-harness-init [<zielordner>] [--lang …]` — buchstäblich gelesen wäre das die gebrochene Form (Flags nach dem Positionsargument, Exit 2). Die implementierte Form `[--lang …] <zielordner>` läuft über die "oder eine gleichwertige Form"-Klausel derselben Sätze; ein Widerspruch besteht nicht. Die anstehende Plan-Korrektur (Runde 1, F-4 — Planner) sollte die buchstabierte Form gleich mitziehen, sonst bleibt ein Beispiel stehen, das ein Nachleser wörtlich übernehmen und brechen kann. | Slice-Plan §1, §2 LP1 (Plan-Form) | `docs/plan/planning/in-progress/slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo.md` (§1 Ziel, §2 LP1) | ja — Plan-Text gegen die Parser-Semantik (die Usage des Werkzeugs sagt es selbst, `cmd/ai-harness-init/main.go:45–47`) | Plan-Beispielform hinter der Parser-Semantik |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| F-1-Nachzug: die 12 dokumentierten Aufruf-Einladungen | geprüft, ohne Befund — README 1 Stelle (`README.md:21`), Handbuch 11 Stellen (160, 202, 216, 228, 323, 337, 351, 397, 408, 454, 464); jede trägt `<zielordner>` am Ende, Flags davor; die gebrochene Form (Ziel vor Flags) ist 0×, die `\^[0-9a-f]{64}`-Hash-Form 0×; die Pflicht- und laut-Bruch-Hinweise stehen im Indikativ über den Zustand (Pflicht `.git`, ohne Zielordner Usage-Abbruch); die Usage des Werkzeugs (`main.go:37`) buchstabiert dieselbe Form samt Parser-Begründung |
| F-2-Nachzug: die 6 Git-Init-Stellen | geprüft, ohne Befund — `smoke.sh:30` (`git init -q "$tmprepo"` an der Ziel-Anlage, vor dem Bootstrap in Stufe 2) und `full-smoke.sh:128,130,132,134,144` (tmprepo, tmprepo_doc, tmprepo_hex, tmprepo_cpphex, tmprepo_selbst), jede vor ihrem Bootstrap-Aufruf (377, 2084, 2486, 2529, 3034); alle 8 Aufrufstellen tragen die Ziel-am-Ende-Form — die Redundanz der Nachlauf-Zeilen ist F-9 (LOW) |
| F-3-Nachzug: Beleg-Klasse | geprüft, ohne Befund — „Beide von Hand gefahren.“ ist 0× im Bestand (`grep -rn 'von Hand gefahren' cmd/ test/ docs/user/ README.md` → leer); der Kommentar über `TestUnfallVektor_OhneArgumentImRepoWurzel` nennt den gelisteten Zahn (`test/mutations/378-…`) als Sensor |
| F-5-Nachzug: der gelistete Zahn, rot gefahren | geprüft, ohne Befund — `test/mutations/378` existiert, ist über den `*.sh`-Glob des Mutations-Runners gelistet, trägt `# files: cmd/ai-harness-init/main.go`, `# expect: TestUnfallVektor_OhneArgumentImRepoWurzel`, `# verify: test-go`; **eigener Rot-Lauf**: der Fall färbt allein an der Verzeichnis-Prüfung (`main_test.go:827`, `.harness` erscheint im stehenden Repo), Exit-Code/Meldung/Usage/stdout bleiben grün — die expect-Form (Test-Name als `--- FAIL:`-Treffer) ist von diesem Lauf bestätigt, nicht nur gelesen |
| F-7-Nachzug: Alt-Test-Name | geprüft, ohne Befund — `TestInitPfadNimmtKeinPositionsargument` 0× in Code, Tests und lebender Doku; Restvorkommen nur in Zeitdokumenten (`docs/reviews/**`); der neue Name `TestInitPfadNimmtDenZielordnerUndSonstNurFlags` trägt Comment, Mutation 253 und `main.go:197` |
| N-3-Nachzug: 367-expect-Form | geprüft, ohne Befund — expect trägt die gerenderte Meldung: die Vorlage `full-smoke: FEHLER — $label: harness/conventions.md fehlt im Ziel — die drei Aussagen ueber den mitgelieferten Baum haetten keinen Ort.` (`full-smoke.sh:185`) mit Label `sprachlos` ergibt exakt die expect-Zeile; die Form folgt der Korpus-Logik (verify `test-go` → expect ist der Test-Name, wie 253/377; verify `full-smoke` → expect ist die Fehler-Zeile, wie 305/332) |
| 377-Form, rot gefahren | geprüft, ohne Befund — `# expect: TestUnfallVektor_OhneArgumentImRepoWurzel`, sed-Anker `fs.NArg() == 0 {` existiert genau 1×; **eigener Rot-Lauf**: unter der Mutation fällt der Aufruf durch die Git-Repo-Tür auf `bootstrap("", …)`, das stehende Repo wird angefasst (`main_test.go:827` — der gemessene Zahn) und die Meldungs-Assertions (814/817/820) färben mit; gleiche Richtung wie der von Runde 1 von Hand rot gesehene Zustand, jetzt am gelisteten Fall |
| Plan-Abweichung F-4 (Runde 1) | geprüft, ohne Befund am Zustand — die Plan-Datei ist seit `0acdf385` von keinem Commit berührt (`git log 0acdf385..HEAD -- <Plan>` → leer): die Verortung §2 LP1/LP2 steht unverändert, der Implementer hat den Plan-Text nicht still umgeschrieben; die Deckungs-Teilung ist im `test/zielordner.bats`-Kopf ausgeschrieben (Go-Stufe = Verhalten am Prozess, bats = Struktur-Deckung); der Plan-Korrektur-Zug bleibt beim Planner vor der Closure |
| Diff-Umfang gegen §3 | geprüft, ohne Befund — §3 führt 3 Zeilen, der Diff berührt 11 Dateien; `smoke.sh`/`full-smoke.sh` fehlen in der Tabelle und sind in der Commit-Message benannt (Übergabe 5 der Message, „die Bootstrap-Aufrufe … und die tmp-Ziele vor dem Bootstrap als Git-Repo angelegt“); keine §1-Grenze ist verletzt — die Stellen sind mechanische Folge der neuen Aufruf-Form, wie Runde 1 (F-8) bereits eingestuft hat |
| Fremd-Kennungen | geprüft, ohne Befund — Added-Lines des Commits enthalten keine Kennung eines fremden Repos (`d-check`, `a-check`, Kurs-Klon, `pt9912/ai-harness`); Message trägt `LH-FA-01` |
| e2e-abdeckung.md als Generator-Ausgabe | geprüft, ohne Befund — `make e2e-abdeckung` selbst gefahren: „unverändert“ (19 Stufen, 19 Deklarationen); der Commit-Diff trug ausschließlich Stufen-Zeilennummern (38 geänderte Zeilen), Stichprobe (Stufe 1–5) löst gegen die aktuellen Zeilen von `full-smoke.sh` auf |
| Sperren-Reihenfolge und Meldungen im Quellstand | geprüft, ohne Befund — `main.go:207–235`: Leer-Argument (Meldung „kein Zielordner angegeben …“, Exit 2) vor Mehrfach-Argument („unbekanntes Argument %q — der Init-Pfad nimmt den Zielordner und sonst nur Flags“) vor Git-Repo-Prüfung („kein bestehendes Git-Repo …“) vor `bootstrap(...)`; die Meldungen tragen die Zustands-Form, keine Chronik |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Redundanter Nachlauf-Zustand nach Vorverlagerung
der Git-Init-Anlage · Plan-Beispielform hinter der Parser-Semantik

## Verdikt

**Merge-blockierend:** nein — die drei HIGH der Runde 1 sind am Stand `399c17f1`
behoben: F-1 (alle 12 dokumentierten Formen tragen Flags vor dem Ziel, die
gebrochene Form ist 0×), F-2 (alle 6 Git-Init-Stellen stehen vor ihren
Bootstrap-Aufrufen, alle 8 Aufrufstellen die Ziel-am-Ende-Form), F-3 (der
Protokoll-Satz ist entfernt, der Kommentar nennt den gelisteten Zahn), F-5 (378
ist gelistet **und von diesem Lauf rot gefahren** — allein die Verzeichnis-Prüfung
färbt, der Zahn bindet die geschwächte Zusicherung), F-7 (Alt-Name 0×, neuer Name
trägt). 377 ist ebenfalls von diesem Lauf rot gefahren (der stille Init-Pfad
schreibt wieder, der Fall fängt ihn). Kein neuer blockierender Befund.

**Offen, nicht blockierend, mit Träger:** an den **Planner** vor der Closure (keine
davon implementer-seitig): die Plan-Korrektur der Verortung (Runde 1, F-4) — und
mit ihr die buchstabierte Aufruf-Form im Plan (F-10, INFO) — sowie der
Lastenheft-CR (Runde 1, F-6, Spec-Happy-Path).

**Ist der Weg zur Verifikation und Closure frei? Ja** — implementer-seitig steht
nichts mehr offen; die zwei neuen Findings sind LOW/INFO (Planner-/Lesart-Ebene,
kein Code-Zwang). Die Verifikation prüft den DoD-gegen-Stand wie in Runde 1
übergereicht; die Plan- und Spec-Posten oben sind die offenen Planner-Züge, die
vor dem `git mv` nach `done/` gezogen sein müssen. Dieser Report ist Lauf-Beleg —
DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).