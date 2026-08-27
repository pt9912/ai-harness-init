# Harness

## Purpose

Einstiegspunkt für Menschen und AI-Agenten. Kein Ersatz für spec/ oder
docs/. Bei Konflikt mit einer kanonischen Quelle gewinnt diese.

Strukturregeln und Adaptionen leben in [`conventions.md`](conventions.md).

## Source precedence

3-Strata-Spec (Vertrag › Technik › Sicht, [`MR-019`](conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)):

| Rang | Datei | Charakter |
|---|---|---|
| 1 | [`spec/lastenheft.md`](../spec/lastenheft.md) | vertraglich abnahmebindend |
| 2 | [`spec/spezifikation.md`](../spec/spezifikation.md) | technisch verbindlich, ohne Vertragsänderung fortschreibbar |
| 3 | [`spec/architecture.md`](../spec/architecture.md) | Komponenten/Sequenzen, meilensteinfrei |
| 4 | [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| 5 | [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) | aktuelle Welle |
| 6 | [`README.md`](../README.md) | Projekt-Überblick |
| 7 | [`AGENTS.md`](../AGENTS.md) | Agent-Briefing |
| 8 | diese Datei | Harness-Einstieg |

## Guides (Feedforward)

| Quelle | Inhalt |
|---|---|
| [`spec/lastenheft.md`](../spec/lastenheft.md) | Anforderungen, IDs, Akzeptanzkriterien |
| [`spec/spezifikation.md`](../spec/spezifikation.md) | technische Festlegungen: Defaults, Tracing-Felder, externe Fassungen |
| [`spec/architecture.md`](../spec/architecture.md) | Komponenten, Schichten, Constraints |
| [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| [`AGENTS.md`](../AGENTS.md) | Hard Rules, Source Precedence |
| [`conventions.md`](conventions.md) | Strukturregeln, MR-Block, Modus |

## Sensors (Feedback-Gates)

Nur existierende Targets (keine halluzinierten Gates):

| Target | Vertrag | Bindung |
|---|---|---|
| `make baseline-verify` | Vendored Baseline unverändert: Integrität **und** Vollständigkeit, netzlos | [`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| `make docs-check` | Doku-Referenzen grün (links/anchors/ids/codepaths), netzlos (`--network none`) | [`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert) |
| `make test` | Command-Guard-Tests (bats) + Go-Unit-Tests (Dockerfile-`test`-Stage) grün | [`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md), [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make lint` | Go-Lint (golangci-lint, Dockerfile-`lint`-Stage) grün | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make build` | Go-Binary cross-compiliert (Dockerfile-`build`-Stage) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make ci-lint` | GitHub-Actions-Workflows syntax-clean (actionlint) | [`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions) |
| `make comment-claims` | Kommentar-Behauptungen nennen ihren Sensor; genannte Tests existieren — **im Prüfbereich**, und der ist enger als der Gate-Stempel (s. u.) | [`AGENTS.md`](../AGENTS.md) §3.6 |
| `make host-bin` | Träger (Produkt-Binär) für die **Host**-Plattform gebaut und im gitignorierten Zustands-Bereich abgelegt (Docker-only, GOOS/GOARCH aus `uname`) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make span-check` | Träger vorhanden **und** sein Unterkommando `span-emit` funktionsfähig; Ablageort real `git check-ignore`-geprüft | [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 |
| `make gates` | alle aktuell lauffähigen Gates | — |

Der Dogfood-Go-Gate-Stack ist **vollständig**: `make lint` / `make build` / `make test` (Go via Dockerfile-Stages, slice-001a/b) neben `docs-check` / `shell-lint` / `baseline-verify`. **Nicht behauptet**: das Architektur-Gate (a-check, [`LH-FA-07`](../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) — der Dogfood ist **flach**, hier hätte a-check einen leeren Prüfbereich ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). **Emittiert wird es trotzdem** (slice-046, emitted-only): ein Zielrepo mit einem **schichten-tragenden** Layout — heute `--arch hexslice` (go, cpp) oder `--arch hexagonal` (go) — bekommt `.a-check.yml` + `a-check.mk` + sein Gate-Fragment und fährt a-check in seinem `make gates` mit; ein flaches Ziel bekommt keines. Welche Layouts das sind, entscheidet **keine Namensliste**, sondern die strukturelle Frage, ob das Layout eine geprüfte Schicht trägt. Belegt in `make full-smoke` (beide Richtungen + ein verbotener Import, der das emittierte Gate rot färbt), nicht hier.

**Was `comment-claims` nicht deckt — benannt, weil eine Vollständigkeits-Zeile („N Datei(en) geprueft, 0 Befund(e)") sonst mehr behauptet als sie trägt** (Review-Befund HIGH-1 vom 2026-07-30; die hier zuerst stehende Zählung „an **zwei** Stellen" war selbst zu eng und ist in Runde 2 korrigiert worden): der Prüfbereich entsteht im Rezept aus `git ls-files` und ist an **drei** Stellen enger als der Gate-Stempel, den `record-gates` über den Arbeitsbaum legt (`harness/tools/working-tree-hash.sh`: `--cached --others --exclude-standard`).

1. **Nur der Index.** `git ls-files` ohne `--others`: eine neu angelegte, noch **untrackte** Datei liegt innerhalb des bestätigten Baum-Zustands und außerhalb des Prüfbereichs — sie wird erst nach ihrem ersten `git add` geprüft.
2. **Nur vier Pfad-Muster** — `internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`. Dauerhaft draußen liegen damit u. a. `Makefile`, `harness/tools/*.awk`, `internal/emit/templates/`, `test/`, `.codex/`, `.github/` und **jede** Markdown-Datei.
3. **Test-Dateien ausgenommen** (`_test.go`) — ein Kommentar dort behauptet keine Abdeckung, sondern *ist* eine.

**Nur (1) heilt ein `git add`; (2) und (3) sind permanent.** Wie groß der Ausschnitt ist, sagt der Gate in seiner letzten Zeile selbst (am 2026-07-30: 38 Dateien, 19 Go + 19 Shell); wie groß der Stempel ist, sagt `git ls-files --cached --others --exclude-standard`. **Eine eingefrorene Gegenüberstellung steht hier bewusst nicht** — sie wäre beim nächsten Commit falsch, dieselbe Falle wie bei der Span-Zählung in [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5. Wer eine Datei **in einem der vier Muster** neu anlegt und ihre Zusagen gedeckt sehen will, lässt den Gate **nach** dem `git add` laufen; wer eine `harness/tools/*.awk`, ein `Makefile`-Rezept oder eine Vorlage unter `internal/emit/templates/` schreibt, bekommt **gar keine** Prüfung — dort trägt allein das Review.

**Ein zweites, gemessenes Loch derselben Klasse — hier benannt, nicht nebenbei geschlossen:** die Negations-Ausnahme in `harness/tools/comment-claims.sh` lässt einen Satz durch, der eine Abdeckung *verneint*; ihr Fenster ist zwölf Zeichen breit. Ein Lauf über das (außerhalb liegende) `Makefile` meldet genau einen Treffer, und dort stehen zwischen „belegte" und „nicht" **dreizehn** Zeichen — die Ausnahme verfehlt ihn um ein Zeichen. Ob das Fenster weiter gehört oder der Satz umgeschrieben, entscheidet der Slice, der den Mechanismus anfasst.

Der Mechanismus selbst ist hier **nicht** geändert (Gate-*Anheben* ist ein Steering-Loop nach [`MR-001`](conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), und er betrifft jede künftige neue Datei, nicht die Telemetrie) — er wartet auf einen eigenen Schnitt.

**CI** ([`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions), slice-027): GitHub Actions fährt `make gates` + `make smoke` + `make mutate` auf **frischem Klon** pro Push/PR — schließt die [`MR-003`](conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke (der lokale Stop-Hook gibt einen cleanen Tree ohne State frei; „CI ist dort das Netz") und gibt `make mutate` seinen mechanischen Pro-Push-Auslöser. Die **Netz-Sensoren** `regelwerk-check`/`baseline-freshness` laufen **nur nächtlich** — ein Upstream-Ausfall darf keinen Push blockieren. Die CI ruft **ausschließlich `make`-Targets** (keine zweite Gate-Definition). **Was CI nicht prüft:** nichts, was nicht in einem dieser Targets steht — ein grüner CI-Lauf ist keine Aussage über ungetestete Flächen.

**Nicht-Gate-Verify** (verfügbar, **nicht** in `make gates` — wie `regelwerk-check`/`baseline-freshness`): `make smoke` ist der Tier-2-Emit-Smoke (slice-002) — es emittiert die Doc-Gate-Baseline in ein tmp-Repo und lässt das emittierte `docs-check` real laufen (Host-Docker, ggf. Netz-Pull). `make full-smoke` ist der **Voll-E2E-Smoke** (slice-024): Bootstrap in ein tmp-Repo, dann dort der **zusammengeführte** `make gates` ([`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert): docs-check + Go-Gates in einem Lauf) — der Happy-Path-Beweis ([`LH-FA-01`](../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)), dass ein frisch gebootstrapptes Repo out-of-the-box grün fährt (die Nutzer-Sicht, die `make smoke` mit seinen getrennten Schritten nicht nimmt). **Sein Grün sagt das eine, sein Rot sagt zwei Dinge:** der Lauf fragt je Durchgang fremde Registries nach gepinnten Bildern und macht jede dieser Anfragen zur Bedingung seines Grüns. Bricht ein Abschnitt ab, nennt der Lauf in **seiner eigenen Ausgabe** den Ausgang — `AUSGANG LEITUNG`, wenn eine ausgehende Anfrage nach einem gepinnten Artefakt **nicht mit 2xx beantwortet** wurde (mit der Zeile, die das trägt), sonst `AUSGANG BAUM`: keine der geführten Formen steht in den gelesenen Zeilen, und der Fehlschlag wird dem **geprüften Baum zugerechnet**. **Der Exit-Code unterscheidet die zwei nicht** und soll es nicht — ein eigener Code lüde dazu ein, den Leitungs-Fall durchzuwinken, und das wäre die Schwellen-Senkung, die [`AGENTS.md`](../AGENTS.md) §3.5 an ein ADR bindet. **Wofür die Unterscheidung gilt, ist ein Kriterium und keine Fundstellen-Liste:** eingeordnet ist **jeder Abschnitt, der ein Bild anfordern kann**. Die Abschnitte sind mechanisch abgegrenzt — jeder führt seinen eigenen Exit-Code (**A** = `grep -cE '\|\| [a-z_0-9]+=\$\?$' harness/tools/full-smoke.sh`). Drei Formen darin fordern nachprüfbar **keines** an: der Trockenlauf (`make -n` führt kein Rezept aus), `make span-clean` (sein Rezept im Ziel ist `rm -rf` plus `echo`) und der Hook-Wrapper (ein Shell-Skript, das das Host-Binär startet und `docker` nicht nennt) — **B** = dieselbe Liste durch `grep -cE ' -n |span-clean|bash "\$wrapper"'`. Der Rest sind make-Stufen und Aufrufe des Werkzeugs (**C** = dieselbe Liste durch `grep -c 'tmpbin/ai-harness-init'`). **Jede** make-Stufe trägt eine Einordnung, dazu die zwei Werkzeug-Aufrufe, die als erste ein noch nicht lokal liegendes Bild anfordern; die Probe darauf ist eine Gleichung statt einer Zählung: **A − B − C** == `grep -cE '^[[:space:]]*einordnen "' harness/tools/full-smoke.sh` **− 2**. **Nicht** eingeordnet sind die übrigen Werkzeug-Aufrufe — sie können nur dieselben zwei Bilder anfordern (das Werkzeug hat genau **einen** Docker-Aufrufpunkt, `printMK` in `internal/emit/emit.go`), und die liegen nach den zwei Erstbezügen lokal; sie laufen unter `set -e` und brechen ohne eigene Meldung ab. Die geführten Formen, ihre Messung und ihre weiteren Grenzen — Paketquellen der C++-Kette sind **keine** gepinnten Artefakte und fallen in den Baum-Fall — stehen im Kopf von `harness/tools/full-smoke-ausgang.sh`; `test/full-smoke-ausgang.bats` fährt beide Richtungen über Ausschnitten echter Läufe. `make span-report` rechnet aus dem Span-Bestand eine **Token-Bilanz je Rolle**. Er steht **bewusst in keiner der Tabellen oben**: ein Bericht prüft nichts und färbt nichts rot, ein Gate über ihm wäre eines über leerem Prüfbereich ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Er liest den Bestand read-only und netzlos; die Ausgabe nennt ihren Nenner, den Sammelposten-Anteil und die Abdeckungszahl samt Bezugsmenge. `make mutate` ist der Mutations-Sensor zu [`AGENTS.md`](../AGENTS.md) §3.6 (slice-026): er wendet ein kuratiertes Set von Mutationen an und meldet jeden Wächter, der dabei **grün** bleibt — die Regel ist sonst nur im Feedforward-Quadranten. Je Fall läuft **nur der Sensor, dessen Rot erwartet wird** (aus der `# expect:`-Zeile; bei unklarer Erwartung beide Stufen — slice-056). Die Fälle laufen **auf mehrere Worker verteilt** (`MUTATE_JOBS`, Default im Treiber), jeder mit einer **eigenen isolierten Kopie außerhalb des Repos** — nie im Arbeitsbaum; der Lauf misst das selbst — Fingerabdruck der Mutations-Zieldateien vor, **während** und nach dem Lauf, fail-closed (nur diese Dateien, damit paralleles Arbeiten am Repo den Lauf nicht rötet). **Die Worker-Zahl ist eine Zeit-Stellschraube, keine Verdikt-Stellschraube**, und der Lauf belegt das, statt es zuzusagen: jeder Worker fährt den Grün-Vorlauf **der Modi, die er zieht**, in *seiner* Kopie, die Modi, deren Urteil an einem geteilten Docker-Tag hängt, laufen in **einer** Spur, und der zusammengeführte Bericht nennt am Ende, wie viele der Fall-Dateien ein Ergebnis haben und ob jede Fall-Nummer genau einmal gezogen wurde — weicht eines davon ab, ist der Lauf **rot**, nicht kürzer. Am Ende steht die Zeit-Aufschlüsselung je Fall und je Sensor; sie ist eine **Messung**, kein Gate ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — über ihre eigene Vollständigkeit urteilt sie aber und verweigert eine Bilanz über einer Teilmenge. Ein Abbruch lässt **im Arbeitsbaum** kein Residuum zurück; außerhalb bleiben ein Temp-Verzeichnis und, nach hartem Kill, das Lock-Verzeichnis liegen — Letzteres bewusst fail-closed. Beide gehören an DoD-Verify/CI/Wellen-Closure, nicht in den offline-schlanken `make gates`.

`make hook-overhead` **misst** den Aufschlag je Tool-Call — die Wanduhr-Zeit **eines** Träger-Aufrufs, nicht die des Tool-Calls, den er beobachtet — und hält ihn gegen die Schwelle aus [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) (*50 ms im Median*); geschuldet ist sie von [`ADR-0022`](../docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 9. Er steht **in keiner der Tabellen oben und in keiner Prerequisite-Kette**: eine Messung prüft nichts und färbt nichts rot, und ein Latenz-Gate wäre auf einem geteilten Runner rot ohne Befund und grün ohne Deckung ([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). `harness/tools/hook-overhead.sh` spielt eine **reale** Folge von Tool-Calls aus dem Span-Bestand nach — Ereignis-Art, Werkzeug-Mischung, Reihenfolge und Ergebnis-Größe je Aufruf stammen aus einem echten Strom, nachgebaut sind Kommando-Text und Ergebnis-Inhalt, die kein Span trägt; ohne Bestand bricht der Lauf ab, statt eine Folge zu erfinden. Der gemessene Stand steht mit seinen Bedingungen und seinen Kommandos im Kopf jenes Skripts, nicht hier: die Zahl gilt dem Host, auf dem sie entstand.

## Traceability

- PRs/Commits nennen mindestens eine `LH-*`- oder `ADR-*`-ID (als Link oder Inline-Code).
- Neue ADRs ergänzen den ADR-Index.

## Minimal agent workflow

1. Diese Datei lesen.
2. Relevante kanonische Quelle lesen (Source Precedence).
3. Betroffene IDs identifizieren.
4. Kleinste sinnvolle Änderung planen.
5. Engsten nützlichen Sensor laufen lassen.
6. Repo-weiten Gate-Lauf vor Handoff (`make gates`).
