# Verifikation: slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo — 2026-09-19

**Rolle:** Verifier (Modul 11) — frischer Kontext. **Prüffrage:** „Bauen wir es richtig?"
— der DoD des Slice-Plans gegen den Stand, nicht der Review-Diff (der liegt in zwei
Runden unter `docs/reviews/` vor; beide sind hier nur Eingabe der Rollen-Abfolge,
kein Prüfgegenstand).

**Eingabe:** Slice-Plan
`docs/plan/planning/done/slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo.md`
(Verortung von `a247fc89`, Flags-vor-Ziel-Form) · [ADR-0058](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
(`Accepted`) · [ADR-0059](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(`Accepted`) · der Code-Stand am Kopf `4ce1aa9a`.

**Stand laut Auftrag:** `make gates` grün, `make docs-check` 1731/0, `make smoke`
und `make full-smoke` EXIT 0 — nicht wiederholt; dieser Lauf fährt die Prozess- und
Mutations-Belege, die über das Grün hinaus tragen.

## Sensor- und Prozess-Messungen dieses Laufs

Träger: `make host-bin` (Docker-only, [ADR-0003](../plan/adr/0003-go-native-binaries.md))
→ `.harness/state/bin/ai-harness-init`, frisch gebaut am Stand `4ce1aa9a`.

**1. Unfall-Vektor am Prozess** (Träger ohne Argument, gestanden im
Repo-Wurzel-Verzeichnis eines stehenden Git-Repos im Wegwerf-Verzeichnis):

```sh
BIN=.harness/state/bin/ai-harness-init
git init "$S/stehend" && printf 'include harness/mk/*.mk\n' > Makefile && git commit
( cd "$S/stehend" && "$BIN" )                     # EXIT=2
wc -c < "$S/stdout"                               # 0
find "$S/stehend" -mindepth 1 -not -path '*/.git/*' -not -name .git   # vorher 1, nachher 1
git -C "$S/stehend" status --porcelain | wc -l    # vorher 0, nachher 0
```

stderr trägt `Fehler: kein Zielordner angegeben — der Init-Bootstrap loest sein Ziel
aus dem Argument, nicht aus dem Arbeitsverzeichnis.` gefolgt von der Usage
(`Verwendung: ai-harness-init [--lang <sprache>] [--arch <arch>] [--name <name>]
<zielordner>`). Laut, nichts geschrieben, das stehende Repo unverändert —
**`ADR-0058` Festlegung 2 ist am gepinnten Bau laut gemessen** (der argumentlose
Aufruf endet mit Usage, Exit 2, fail-closed).

**2. Der Zielordner am realen Bootstrap** (`--lang go`, Flags vor dem Ziel,
Aufruf-Verzeichnis vom Ziel getrennt):

```sh
( cd "$S/aufruf-dir" && "$BIN" --lang go --name "X" "$ZIEL" )   # EXIT=0
ls -A "$S/aufruf-dir" | wc -l                                   # 0 — das Aufruf-Verzeichnis bleibt leer
ls "$ZIEL/.harness/baseline/"                                   # v6.9.0
```

Exit 0; das Skelett und die Emission liegen im **genannten** Zielordner
(`go.mod`, `cmd/app`, `harness/`, `.harness/baseline/v6.9.0` unter `$ZIEL`), der
CWD bleibt unangetastet — dieselbe Ziel-Auflösung, die die Go-Stufe
`TestZielordner_AusDemArgument` am injizierten `targetDir` misst.

**3. Ziel ohne `.git`** am realen Träger:

```sh
( cd "$S/aufruf" && "$BIN" --lang go "$ZOHNE_GIT" )   # EXIT=2
head -1 stderr                                        # "Fehler: Zielordner … ist kein bestehendes Git-Repo"
ls -A "$ZOHNE_GIT" | wc -l                            # 0 — nichts geschrieben
```

**4. `ADR-0059` Festlegung 2 am Binary** (die geschärfte Sonde, am frischen Bau):

```sh
grep -oaE 'TRAEGER_SHA256[A-Z_]*=[0-9a-f]{64}' "$BIN" | wc -l   # 0
grep -oaE 'TRAEGER_TAG \?= v[0-9.]*' "$BIN"                     # TRAEGER_TAG ?= v0.2.1
grep -c 'TRAEGER_SHA256' internal/emit/templates/enforce/traeger.mk   # 0
```

**5. Rote Gegenproben, selbst gefahren** (gezielte Go-Stufe im gepinnten
`golang:1.27.0@sha256:65b6f280…`-Image, `--network none`, `-run
TestUnfallVektor_OhneArgumentImRepoWurzel`; unmutierter Vorlauf: `ok`):

- **Mutation 377** (`test/mutations/377-init-argumentlos-stiller-init.sh`,
  `fs.NArg() == -1`): **rot** — `main_test.go:814` (*„Exit 1 ohne Argument, want 2
  (fail-closed)"*), `:817` („stderr nennt den fehlenden Zielordner nicht"), `:820`
  („stderr fuehrt die Usage nicht"); der Aufruf fällt durch die inert gestellte
  Leer-Sperre in `bootstrap("", …)` und versucht den Baseline-Fetch — der stille
  Init-Pfad ist offen, und der Fall fängt ihn. Danach zurückgenommen (`git
  checkout`, Arbeitsbaum 0 Änderungen).
- **Mutation 378** (`test/mutations/378-init-argumentlos-bricht-aber-schreibt.sh`,
  die geschwächte Zusicherung „bricht, aber schreibt"): unter `--network none`
  **grün geblieben** — siehe Finding V-1. In der Gate-Umgebung (`make test-go` =
  `docker build` **mit** Netz) bindet der Zahn: die Review-Runde 2 hat ihn dort rot
  gefahren und die Meldung gelesen (*„das stehende Repo wurde angefasst: vorher
  [.git Makefile], nachher [.git .harness Makefile]"*, allein an
  `main_test.go:827`) — der Exit-Code/Meldungen-Teil der Zusicherung bleibt auch
  unter der Mutation richtig, gefangen wird allein die Verzeichnis-Prüfung.

**6. Kennungs- und Zuschnitt-Scan** über die zwei Code-Commits:

```sh
git show 0acdf385 399c17f1 | grep '^+' | grep -oE 'ADR-[0-9]{4}|MR-[0-9]{3}|BEO-[A-Z]+/…|welle-[a-z-]+|LH-…' | sort -u
```

Nur eigene Kennungen (`LH-FA-*`, `LH-QA-*`, `welle-go-init-pfad-positionsargument`);
keine Kennung eines fremden Repos. Commit-Zuschnitt: die zwei Reviewer-Commits
berühren nur ihren Report, der Planner-Commit `a247fc89` nur die Plan-Datei, der
CR-Commit `4ce1aa9a` nur `spec/lastenheft.md` + `spec/architecture.md`.

---

## DoD Punkt für Punkt

| DoD-Punkt | Urteil | Beleg |
|---|---|---|
| **L1 — Dispatch mit Zielordner** (Flags vor dem ersten Positionsargument, Ziel als letztes Positionsargument; ohne Argument laut mit Usage, fail-closed; kein-Git-Repo-Ziel bricht laut) | **erfüllt** — mit Rest am DoD-Text, siehe V-2 | Code: `cmd/ai-harness-init/main.go` — `fs.Parse` stoppt am ersten Positionsargument, `fs.NArg() == 0` → Usage + Exit 2 (Zeile 207), `> 1` → „unbekanntes Argument" + Exit 2, `istGitRepo(ziel)` → Exit 2; Prozess: Bootstrap EXIT 0 in den genannten Zielordner (Messung 2 oben), argumentlos EXIT 2 mit Usage (Messung 1), kein-Git-Repo EXIT 2 ohne Schreiben (Messung 3). Rote Gegenprobe **rot gesehen** (Mutation 377, eigene Messung) — aber am Träger Go-Stufe, nicht am im DoD-Text genannten bats-Negative-Fall (V-2) |
| **L2 — der Unfall-Vektor ist zugenommen** (Träger ohne Argument im Repo-Wurzel-Verzeichnis: laut, ohne Schaden; Go-Stufe `TestUnfallVektor_OhneArgumentImRepoWurzel`) | **erfüllt** | Go-Stufe existiert und misst am Prozess (Test liest Exit 2, Meldung, Usage, stdout leer, `sameEntries(vorher, nach)`); **eigene Prozess-Messung am realen Träger** (Messung 1 oben) mit demselben Ergebnis; Rote Gegenprobe: 377 von mir rot gefahren, 378 in der Gate-Umgebung von Runde 2 rot gefahren (`main_test.go:827`, `.harness` im stehenden Repo) — meine netzlose Umgebung zeigt die Grenze (V-1) |
| **L3 — Deckung:** die vier Dispatch-Fälle unberührt, keine Sperren-Lücke | **erfüllt** | Vorher/Nachher-Lektüre des Switches (`git show 0acdf385^:cmd/ai-harness-init/main.go`): die vier Fälle tragen vor und nach dem Slice identische Körper (`spanEmit(os.Stdin)` / `spanReport(os.Args[2:], …)` / `archiveWelle(os.Args[2:], …)` / `vendorBaseline(os.Args[2:], …)`); der Fall-through übergibt `""` statt des `Getwd()`-Werts, und die drei Sperren stehen in `run()` vor `bootstrap()` (`test/zielordner.bats` Fall 2/3, Anker-gebunden). Die geschützten Festlegungen (eigenes Fragment, eigenes Target, kein Prerequisite) sind von keinem Slice-Commit berührt — `internal/emit/templates/enforce/traeger.mk` und die Fetch-Werkzeuge tragen keinen Diff. Rote Gegenprobe: die konditionale Form („bindet eine Mutation einen der vier Fälle …") hat keinen konkreten Fall im Set — keine Mutation bindet die vier an das Zielordner-Verhalten; die bestehenden Zähne des Routings (154, `test/unterkommando-kopplung.bats`) liefen in `make gates` grün. Grenze benannt: die Gegenprobe blieb ungefahren, weil ihr Auslöser nicht existiert |
| `make gates` grün | **erfüllt** (übernommen) | Auftrag: Kopf `4ce1aa9a`, `make gates` EXIT 0, `docs-check` 1731/0 — nicht wiederholt (MR-025: die Zahlen stehen im Auftrag, nicht hier) |
| Review durchgeführt, Report unter `docs/reviews/` | **erfüllt** | `docs/reviews/2026-09-19-slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo-runde-1.md` (drei HIGH) und `…-runde-2.md` (Verdikt: merge-blockierend nein, Weg frei) |
| Doku-Update für die neue Aufruf-Form | **erfüllt** | `README.md:21` und Handbuch tragen `… --name "Mein Projekt" <zielordner>` (Flags vor dem Ziel, 12 Stellen-Zensus der Runde 2); `docs/user/e2e-abdeckung.md` als Generator-Ausgabe mitgezogen (`make e2e-abdeckung` unverändert, Runde 2); die Spec trägt CR 0.22.0 (unten) |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **offen — Planner** | Die Datei liegt in `in-progress/`, §7 ist Vorlage; der Abschluss ist Planner-Arbeit (AGENTS.md §3.10), nicht des laufenden Kontexts |
| Beobachtungs-Register fortgeschritten | **offen — Planner** | `BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad` steht bei **1×** (`evidence/` führt den Unfall-Beleg), Stand `offen` — der Beleg dieses Slice (Closure) kommt bei der Closure hinzu |
| Risiko-Ausgänge aus §6 | **offen — Planner** | Vier Risiken, alle als *weiter offen* vorab benannt; ihre Ausgänge trägt die Closure |
| Drei Paarungen | **offen — Planner** | Suchen in `done/` — nach dem `git mv` |

## Plan-vs-Code-Diff (beide Richtungen)

**Geplant und gebaut:** `cmd/ai-harness-init/main.go` (Zielordner am Dispatch,
Usage-Sperre, Git-Repo-Prüfung, Mehrfach-Sperre; die CWD-Zentralität der Zeilen
572/582 abgelöst — `Getwd` steht jetzt nur noch im `add-lang`-Zweig, der
Fall-through übergibt `""`), `test/zielordner.bats` (neu, 5 Deckungs-Fälle,
Kopf trägt die Deckungs-Teilung), die Go-Stufe `TestUnfallVektor_OhneArgumentImRepoWurzel`
plus die Geschwister-Fälle in `main_test.go`, `docs/user/benutzerhandbuch.md` (Form
gezogen), README.

**Gebaut, nicht in §3 der Plan-Tabelle** — alle mechanische Folge der neuen
Aufruf-Form, von den Review-Runden bereits so eingestuft (Runde 1 F-8, Runde 2
Negativbefund „Diff-Umfang gegen §3"), keine §1-Grenze verletzt:

- `harness/tools/full-smoke.sh` / `harness/tools/smoke.sh` — die E2E-Aufrufe tragen
  die Ziel-am-Ende-Form, die tmp-Ziele werden vor dem Bootstrap als Git-Repo
  angelegt (F-2-Fix; der `git init`-Nachlauf-Rest ist F-9 der Runde 2, LOW, offen
  beim Planner);
- `test/mutations/377-…` und `378-…` (neu), `253-…` (expect auf den neuen
  Test-Namen umgestellt);
- `README.md`, `docs/user/e2e-abdeckung.md` (Generator-Ausgabe).

**Code, den der Plan so nicht beschreibt, aber der Änderung unterliegt:** der
`add-lang`-Fall steht jetzt als **fünfter** Fall im Switch in `main()` (vorher
erreichte ihn der immer-`Getwd`-Durchfall über `run()`); sein Getwd zog mit in den
Fall. Das ist die Träger-Mechanik der geplanten Ablösung der CWD-Zentralität — der
Plan sagt „löst die CWD-Zentralität ab", ohne den add-lang-Umzug zu benennen;
Semantik unverändert (`<pfad>` bleibt der Modul-Pfad, `addLangUsage`-Form
`add-lang <sprache> <pfad>` unverändert). **Keine Grenze aus §1 berührt.**

**Plan-Text, den der Code so nicht hält** (Rest aus derselben Klasse wie Runde 1
F-4, das `a247fc89` zum Teil gezogen hat):

- LP1 nennt als Test `test/zielordner.bats (Happy … · Negative: argumentlos →
  Usage · kein-Git-Repo-Ziel → laut)` — der bats-File führt **keinen** Happy- und
  keinen Negative-Verhaltensfall; seine fünf Fälle sind Deckung (Struktur), und
  sein eigener Kopf verortet das Verhalten in der Go-Stufe
  (`TestZielordner_AusDemArgument`, `TestRun_OhneZielordnerBrichtLaut`,
  `TestRun_KeinGitRepoZielBrichtLaut`, `TestUnfallVektor_OhneArgumentImRepoWurzel`).
  Die Deckung selbst ist vollständig — sie liegt nur in der anderen Stufe, als die
  DoD-Zeile sagt. Dasselbe gilt für die LP1-Rote-Gegenprobe („färbt der
  Negative-Fall des bats-Tests rot"): rot gefärbt hat die **Go-Stufe** (377,
  eigene Messung); der genannte bats-Negative-Fall existiert nicht.
- LP1 nennt als bats-Negative auch den kein-Git-Repo-Fall — ebenfalls Go-Stufe.

## Spec-Änderung (Commit `4ce1aa9a`, CR 0.22.0)

Konsistent: die zwei Happy-Path-AC von `LH-FA-01` und der Ablauf in
`spec/architecture.md` tragen dieselbe Form
(`ai-harness-init --lang go --name "X" <zielordner>` bzw. `--name "X" <zielordner>`),
Flags vor dem Ziel — deckungsgleich mit der Usage des Werkzeugs und mit den 12
dokumentierten Aufruf-Stellen (Zensus Runde 2). Die History-Zeile 0.22.0 nennt den
laut-Bruch und die unberührte `add-lang`-Semantik; die passt zum Code (`<pfad>`
bleibt der Modul-Pfad, Usage-Zeile unverändert). `spec/spezifikation.md` ist vom
CR nicht berührt — die `TRAEGER_SHA256`-Zusage wohnt dort nicht (sie steht in
[ADR-0059](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 2, oben gemessen).

## ADR-Konformität

- **ADR-0058 Festlegung 2 (laut-Bruch):** der argumentlose Aufruf endet laut mit
  der Usage, Exit 2, fail-closed — am gepinnten Bau gemessen (Messung 1). Der
  Fall-through für unbekannte Namen bleibt, bricht aber an den Sperren laut; die
  Re-Evaluierungs-Gefahr (stiller Start am gepinnten Stand) ist durch das Feature
  geschlossen. Der Switch führt jetzt **fünf** Fälle (`add-lang` zog als Fall vor
  das Flag-Parsing) — die „vier Fälle"-Beschreibung der Festlegung war
  Entscheidungs-Messung; die geschützten Festlegungen 3/5 und `ADR-0059` Festlegung
  3 (eigenes Fragment, eigenes Target, kein Prerequisite) sind unberührt.
- **ADR-0059 Festlegung 2:** `TRAEGER_SHA256[A-Z_]*=[64hex]` → **0** am Binary,
  `TRAEGER_TAG ?= v0.2.1` eingebettet, Vorlagen-Sonde → 0 — gemessen (Messung 4).
- **Abgrenzung §1:** kein separater Schutz-Slice (der Defekt ist im
  Zielordner-Feature geschlossen), kein Re-Publish (die zwei Code-Commits berühren
  kein Release-Artefakt), keine Emissions-Struktur-Änderung
  (Vorlagen-Klassifikation und Fragment-Orte unberührt), kein zweiter Fetch-Weg
  (`internal/fetch` unberührt), `add-lang` unberührt (oben).

## Findings des Verifier-Laufs

| ID | Kategorie | Befund |
|---|---|---|
| V-1 | LOW | **Der 378-Zahn bindet nur in einer Umgebung mit Netz.** Unter `--network none` bleibt `TestUnfallVektor_OhneArgumentImRepoWurzel` unter der Mutation 378 grün (`ok … 0.319s`): die geschwächte Zusicherung ruft `bootstrap("", …)`, dessen Baseline-Fetch vor jedem Schreiben abbricht — Exit-Code, Meldung und Verzeichnis-Prüfung bleiben korrekt. Der Zahn bindet genau dann, wenn Phase 2 (Fetch) bis zum Schreiben kommt — das tut er in `make test-go` (`docker build` ohne `--network none`, Netz vorhanden), wo Runde 2 ihn rot gemessen hat (`main_test.go:827`, `.harness` im stehenden Repo). Kein DoD-Bruch: der gelistete Träger (`# verify: test-go`) hat Netz; benannt ist die Grenze — in einer netzlosen test-Go-Umgebung schweigt der Verzeichnis-Zahn, während 377 netzlos an 814/817/820 bindet. |
| V-2 | LOW (an den **Planner**, Rest derselben Klasse wie Runde 1 F-4) | Die DoD-Zeile von L1 verortet Happy- und Negative-Verhaltensfälle sowie ihre rote Gegenprobe im **bats-Lauf**; der Träger beider ist die **Go-Stufe** (der bats-File führt sie nicht und sagt es in seinem Kopf). Die Deckung ist vollständig, nur die Verortung im Plan-Text ist halb überholt — `a247fc89` zog LP2 und die §3-Tabelle, LP1 blieb stehen. Plan-Korrektur vor der Closure, kein Code-Zwang. |
| V-3 | INFO | Commit `0acdf385` trägt die Rolle als **„Rolle Implementation"**, die übrigen Slice-Commits „Rolle Implementer" — die Rollen-Achse der Telemetrie sortiert nach dem Namen im Typ; hier ist der Typ korrekt, die Message-Variante ist Kosmetik des ersten Commits. |

## Spec-Lücken

Keine neue. Die Rest-Vektoren am Dispatch (falsch-positionierte Argumente,
unbekannte Flags) bleiben wie im Plan §6 als offenes Risiko benannt — die
Sperren decken Leer- und Mehrfach-Fall und das fehlende `.git`; ein
*einzelnes* Positionsargument, das zufällig ein Git-Repo benennt, wird als
Zielordner gelesen (Abgrenzung im Code-Kommentar, dokumentiert, nicht geprüft).

## Übergabe an den Planner (§3.10)

Die vier Closure-Pflichten sind offen und liegen beim Planner: Closure-Notiz §7
mit Lerneintrag, Beobachtungs-Register-Beleg (`evidence/…` in
`BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad`), Risiko-Ausgänge für
§6, die drei Paarungen — und vor dem `git mv` die Plan-Korrektur V-2. F-9 (LOW,
Runde 2) bleibt mit Träger offen.

## Verdikt

**Kein DoD-Bruch.** Die drei Liefer-Punkte sind am Stand `4ce1aa9a` erfüllt und —
anders als eine Behauptung — gemessen: der Dispatch trägt den Zielordner (realer
Bootstrap EXIT 0 ins genannte Ziel, Aufruf-Verzeichnis leer), der argumentlose
Aufruf bricht laut und schadefrei (Messung am stehenden Repo), das Nicht-Repo-Ziel
bricht laut ohne Schreiben, die Sonde von `ADR-0059` Festlegung 2 liest 0 am
frischen Binary. Die roten Gegenproben sind rot gesehen (377 eigene Messung; 378
am Gate durch Runde 2, Grenze in V-1 charakterisiert). Die Closure-Pflichten
stehen beim Planner. Der Weg zur Closure ist frei.