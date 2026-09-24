# Harness

## Purpose

Einstiegspunkt für Menschen und AI-Agenten. Kein Ersatz für spec/ oder
docs/. Bei Konflikt mit einer kanonischen Quelle gewinnt diese.

Strukturregeln leben in [`conventions.md`](conventions.md); die Adaptionen selbst liegen als je
eine Datei unter [`conventions/`](conventions/), und `conventions.md` ist ihr Index.

## Source precedence

3-Strata-Spec (Vertrag › Technik › Sicht, [`MR-019`](conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)):

| Rang | Datei | Charakter |
|---|---|---|
| 1 | [`spec/lastenheft.md`](../spec/lastenheft.md) | vertraglich abnahmebindend |
| 2 | [`spec/spezifikation.md`](../spec/spezifikation.md) | technisch verbindlich, ohne Vertragsänderung fortschreibbar |
| 3 | [`spec/architecture.md`](../spec/architecture.md) | Komponenten/Sequenzen, meilensteinfrei |
| 4 | [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| 5 | [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) | aktuelle Welle |
| 6 | [`docs/user/`](../docs/user/) *(falls vorhanden)* | Operations, Quality, Releasing |
| 7 | [`README.md`](../README.md) | Projekt-Überblick |
| 8 | [`AGENTS.md`](../AGENTS.md) | Agent-Briefing |
| 9 | diese Datei | Harness-Einstieg |

## Guides (Feedforward)

| Quelle | Inhalt |
|---|---|
| [`spec/lastenheft.md`](../spec/lastenheft.md) | Anforderungen, IDs, Akzeptanzkriterien |
| [`spec/spezifikation.md`](../spec/spezifikation.md) | technische Festlegungen: Defaults, Tracing-Felder, externe Fassungen |
| [`spec/architecture.md`](../spec/architecture.md) | Komponenten, Schichten, Constraints |
| [`docs/plan/adr/`](../docs/plan/adr/) | Architekturentscheidungen |
| [`AGENTS.md`](../AGENTS.md) | Hard Rules, Source Precedence |
| [`conventions.md`](conventions.md) | Strukturregeln, Index des MR-Blocks, Modus |
| [`conventions/`](conventions/) | die MR-Einträge selbst, eine Datei je Eintrag |
| [`migration.md`](migration.md) | Instanz-Register (Vorlage → Artefakt dieses Repos) und Report-Form für einen künftigen Baseline-Sprung |
| `.harness/skills/reviewer.md` | Reviewer-Skill: HIGH-Liste, Kategorien-Regeln, Negativbefund-Pflicht, Output-Schema (Modul 10) — nächste Rolle nach Schritt 8 des Minimal Agent Workflow, nicht Teil der Implementer-Eingabe |

## Sensors (Feedback-Gates)

Nur existierende Targets (keine halluzinierten Gates). Ein Gate, dessen Vertrag mehr als
einen Satz braucht, trägt seine Prosa unter `harness/sensors/<target>.md`; die Target-Zelle
wird dann zum Link auf die Datei.

| Target | Vertrag | Bindung |
|---|---|---|
| `make baseline-verify` | Vendored Baseline unverändert: Integrität **und** Vollständigkeit, netzlos | [`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| [`make docs-check`](sensors/docs-check.md) | Doku-Referenzen grün (links/anchors/ids/matrix/codepaths/spans/planning/targets/structure), netzlos (`--network none`) — im Prüfbereich seiner Module | [`MR-010`](conventions.md#mr-010--d-check-gate-fragment-tool-generiert) |
| `make test` | Command-Guard-Tests (bats) + Go-Unit-Tests (Dockerfile-`test`-Stage) grün | [`ADR-0004`](../docs/plan/adr/0004-durchsetzungs-emission.md), [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make lint` | Go-Lint (golangci-lint, Dockerfile-`lint`-Stage) grün | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make build` | Go-Binary cross-compiliert (Dockerfile-`build`-Stage) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make shell-lint` | Shell-Hooks/-Helfer lint-clean (shellcheck) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make ci-lint` | GitHub-Actions-Workflows syntax-clean (actionlint) | [`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions) |
| [`make comment-claims`](sensors/comment-claims.md) | Kommentar-Behauptungen nennen ihren Sensor; genannte Tests existieren — im Prüfbereich, enger als der Gate-Stempel | [`AGENTS.md`](../AGENTS.md) §3.6 |
| `make host-bin` | Träger (Produkt-Binär) für die **Host**-Plattform gebaut und im gitignorierten Zustands-Bereich abgelegt (Docker-only, GOOS/GOARCH aus `uname`) | [`ADR-0003`](../docs/plan/adr/0003-go-native-binaries.md) |
| `make span-check` | Träger vorhanden **und** sein Unterkommando `span-emit` funktionsfähig; Ablageort real `git check-ignore`-geprüft | [`spec/spezifikation.md`](../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 |
| `make gates` | alle aktuell lauffähigen Gates | — |

### Werkzeuge (kein Gate)

Genannt, weil ein Lauf sie braucht — kein Gate-Versprechen, darum keine `make X`-Zeile in der
Sensors-Tabelle oben nötig (kuratiert in `targets.exempt-targets`,
[`.d-check.yml`](../.d-check.yml)). Die übrigen `exempt-targets` sind reine Utility-/
Advisory-Ziele ohne Prosa-Erwähnung, deren einzige Dokumentation ihr eigener `## `-Hilfetext
ist (`make help` listet sie).

| Target | Tut was | Bindung |
|---|---|---|
| [`make smoke`](sensors/smoke.md) | Tier-2-Emit-Smoke: emittiertes `docs-check` real gegen ein tmp-Repo | kein Gate |
| [`make full-smoke`](sensors/full-smoke.md) | Voll-E2E: Bootstrap in tmp-Repo → dort `make gates` out-of-the-box grün | kein Gate · [`LH-FA-01`](../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |
| `make artifact-host` | wie `artifact`, aber für den HOST cross-kompiliert (`TARGET_OS`/`TARGET_ARCH` aus `uname`, wie `host-bin`) statt den byte-identischen Default-Pfad zu nehmen ([`LH-QA-04`](../spec/lastenheft.md#lh-qa-04--plattform-matrix)/slice-048 unberührt) — für einen lokal lauffähigen Smoke auf einem Host, dessen Kernel/Architektur vom Docker-Build-Image abweicht (macOS, Windows, abweichendes CPU-Arch) | kein Gate |
| `make smoke-host` | wie `make smoke`, mit `artifact-host` statt `artifact` | kein Gate |
| `make full-smoke-host` | wie `make full-smoke`, mit `artifact-host` statt `artifact` | kein Gate |
| `make e2e-abdeckung` | erzeugt [`docs/user/e2e-abdeckung.md`](../docs/user/e2e-abdeckung.md) aus den Stufen-Deklarationen in `harness/tools/full-smoke.sh` — liest Text, fährt keinen E2E. **Dieselbe Mechanik bekommt ein gebootstrapptes Ziel:** es fährt sein eigenes `make e2e-abdeckung` über den Stufen seines eigenen E2E, mit denselben zwei Lücken-Richtungen und derselben Spaltenfolge, ohne neue Abhängigkeit (Text lesen, kein Container, kein Netz); **seine** Kennungsspalte trägt Code-Spans statt Verweise — ein Anker ließe sich dort nur nachbilden, nicht halten; was dort ziel-spezifisch ist, steht als Marker ([`make full-smoke`](sensors/full-smoke.md) misst es am Ziel) | kein Gate; den Inhalt der erzeugten Datei hält ein Fall in [`test/e2e-abdeckung.bats`](../test/e2e-abdeckung.bats) (läuft in `make test`) · [`LH-FA-12`](../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren) · [`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`LH-FA-02`](../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) |
| [`make mutate`](sensors/mutate.md) | Mutations-Sensor: färbt jede kuratierte Mutation ihren Wächter rot? | kein Gate · [`AGENTS.md`](../AGENTS.md) §3.6 |
| [`make span-report`](sensors/span-report.md) | Token-Bilanz je Rolle aus dem Span-Bestand, read-only und netzlos | kein Gate — Bericht |
| `make span-clean` | räumt den lokalen Span-Bestand weg (ausdrücklich, kein Automatismus) | kein Gate |
| [`make hook-overhead`](sensors/hook-overhead.md) | misst den Aufschlag je Tool-Call (Median) | kein Gate · [`ADR-0011`](../docs/plan/adr/0011-telemetrie-erfassung-policy.md) |
| [`make slice-mv`](sensors/slice-mv.md) | Lifecycle-Wechsel eines Slice inklusive seiner Verweise | kein Gate · [`AGENTS.md`](../AGENTS.md) §3.3 |
| [`make archive-welle`](sensors/archive-welle.md) | archiviert die Zeitdokumente einer geschlossenen Welle | kein Gate · [`ADR-0033`](../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) |
| `make traeger-fetch` | legt den Träger (`.harness/state/bin/ai-harness-init`) per Fetch aus dem gepinnten Release (`v0.2.1`) ab — das Asset wird vor der Ablage gegen den `SHA256SUMS`-Eintrag desselben Releases verifiziert (das Dogfood-Makefile trägt daneben die sechs Einzeldigests — zwei Kanäle, [`ADR-0059`](../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Festlegung 3), Transport im gepinnten Bild, kein Prerequisite; braucht Netz an genau diesem Aufruf | kein Gate · [`ADR-0058`](../docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md), [`ADR-0059`](../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) |
| `make tap-check` | hält die Formel am Kopf des Default-Branch des Tap byte-genau gegen das Asset des Tags (`TAG=<tag>`): Exit des Skripts 0 gleich oder Vorab-Tag, 1 Formel-Unterschied auch nach dem zweiten Lesen, 2 nicht ausführbar — `make` selbst endet bei jedem Fehlschlag mit 2, und die Klasse des Skripts steht in der letzten stderr-Zeile **des Skripts** `tap-check: Exit <N>` (bei Exit 0 fehlt sie; über `make` folgt ihr dessen Meldung, die Zeile ist dort die vorletzte der Ausgabe); lesend, Transport im gepinnten Bild, braucht Netz an genau diesem Aufruf | kein Gate · [`ADR-0064`](../docs/plan/adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) |
| [`make vendor-baseline`](sensors/vendor-baseline.md) | legt den eigenen vendored Baum aus dem Release-Asset an | kein Gate · [`MR-007`](conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| [`make commit-msg-check`](sensors/commit-msg-check.md) | prüft eine Commit-Message-Datei gegen Traceability-Kennung | kein Gate — Träger ist der PreToolUse-Hook |
| `make hooks-install` | aktiviert den git-eigenen `commit-msg`-Träger in diesem Klon (`core.hooksPath .githooks`) | kein Gate · [`AGENTS.md`](../AGENTS.md) §5 |
| [`make history-range-guard`](sensors/history-range-guard.md) | Vorlauf-Wächter: angeforderte Range auflösbar **und** nicht leer | kein Gate |
| [`make adr-immutable`](sensors/adr-immutable.md) | hält den Kern einer `Accepted`-ADR über einer Range unverändert | kein Gate · [`AGENTS.md`](../AGENTS.md) §3.4 |
| [`make doc-tracked`](sensors/doc-tracked.md) | sagt, ob ein verlinktes Ziel im git-Index steht | kein Gate |
| [`make doc-structure`](sensors/doc-structure.md) | fährt die `structure`-Regeln der `.d-check.yml` allein (inert ohne `structure:`-Block) | kein Gate |
| `make regelwerk-check` | Upstream-Content-Drift des Baseline-ZIP auditieren (Netz) | kein Gate — nur nächtlich |
| `make baseline-freshness` | neueren Upstream-Tag als `BASELINE_TAG` melden (Netz, read-only) | kein Gate — nur nächtlich |
| `make record-gates` | Working-Tree-Hash-Nachweis für den Stop-Hook | kein Gate |

## Traceability

- PRs/Commits nennen mindestens eine `LH-*`- oder `ADR-*`-ID (als Link oder Inline-Code).
- Neue ADRs ergänzen den ADR-Index.

**Die Regel hat zwei Träger, und ihre Reichweiten sind verschieden.** Beide sind versioniert und
greifen an zwei Stellen desselben Commit-Pfads; welcher Träger welche Commit-Klasse erreicht, steht
darum hier und in keinem der beiden allein. Die rechte Spalte gilt für einen Klon, auf dem
`make hooks-install` gelaufen ist — die beiden letzten Zeilen trennen genau die Fälle heraus, in
denen das nicht genügt:

| Commit-Klasse | [`pretooluse-commit-msg-guard.sh`](../.claude/hooks/pretooluse-commit-msg-guard.sh) | [`.githooks/commit-msg`](../.githooks/commit-msg) |
|---|---|---|
| `git commit … -F <datei>`, vom Agenten getippt | erreicht | erreicht |
| `git commit … -m …`, vom Agenten getippt | nicht garantiert erreicht — der Matcher verlangt eine `-F`/`--file`-Form, die auch im `-m`-Text stehen kann | erreicht |
| Commit aus einem Repo-Werkzeug (`make slice-mv`, `archive-welle` committen intern) | strukturell nicht erreicht — der Kanal sieht `make slice-mv …` | erreicht, sobald die Werkzeug-Message eine Kennung trägt — **die Messages der benannten Slices ([`MR-057`](conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)) und `archive-welle` tragen keine**, und ihr Commit bricht darum am Träger, statt zu greifen (`git log --format='%s' \| grep '^slice-mv:' \| grep -vcE 'ADR-[0-9]{4}\|LH-[A-Z]{2}-[0-9]{2}\|MR-[0-9]{3}\|slice-[0-9]+'` → **44 von 411**); Adresse für die Behebung: `slice-werkzeug-commits-tragen-eine-kennung` ([`ADR-0053`](../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4) |
| Commit außerhalb eines Claude-Code-Laufs (Mensch am Terminal) | nicht erreicht — er hängt am Tool-Call-Kanal des Agenten | erreicht |
| Commit auf einem Klon, der `make hooks-install` nie gefahren hat | erreicht die `-F`-Form in einem Claude-Code-Lauf (er reist mit dem Klon) | nicht erreicht — `core.hooksPath` ist lokale Konfiguration |
| `git commit --no-verify` | erreicht — er sieht die Kommandozeile | umgangen — git ruft einen Hook mit `--no-verify` nicht auf |
| `git commit --amend` | erreicht die `-F`-Form | erreicht — er liest `$1`, die vorgeschlagene Nachricht |

**Der Index ist kein Gegenstand dieser Tabelle.** `git commit --amend` läuft durch beide Träger —
ein `commit-msg`-Hook feuert dort wie bei jedem anderen Commit —, und trotzdem kann ein `--amend`
fremde, gestagte Änderungen mitnehmen: **den Index sieht keiner der beiden.** Die Abhilfe liegt am
Aufruf, nicht am Wächter: `git commit --only <pfad>` statt `-A` oder `--amend`.

**Wie der Träger auf einen frischen Klon kommt.** [`.githooks/commit-msg`](../.githooks/commit-msg)
reist als versionierte Datei mit dem Klon; ihre **Aktivierung** tut das nicht — `core.hooksPath`
ist lokale Konfiguration. `make hooks-install` setzt sie und ist der einzige Schritt dazwischen;
seine Host-Abhängigkeit ist `git` ([`LH-QA-03`](../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
Ein Bootstrap-Schritt, der das von selbst täte, existiert nicht — die Zeile darüber nennt die
Klasse, die das kostet.

**Beide prüfen die Anwesenheit einer Kennung, nicht ihre Wahrheit** — dieselbe Grenze wie bei
`make commit-msg-check`; ein Hash oder eine Kennung, die nicht auflöst, geht durch.

**Was der `commit-msg`-Hook im Commit-Pfad tut** — reproduzierbar auf einem Klon mit gesetztem
`core.hooksPath` (`make hooks-install`). `--allow-empty` hält den Versuch ohne Baum-Änderung: der
erste Aufruf erzeugt gar keinen Commit, die übrigen einen leeren:

```sh
git commit --allow-empty -m 'Betreff ohne Kennung'
# commit-msg-traceability: keine Traceability-Kennung in der Commit-Message (AGENTS.md §5):
#             Betreff ohne Kennung
# -> Exit 1, es entsteht kein Commit
git commit --allow-empty -m 'Bezug: ADR-0004'
# -> Exit 0
git commit --allow-empty -m 'Merge branch main into feature'
# -> Exit 0 — der Merge-/Revert-Betreff, den auch das Gate kennungsfrei lässt
git commit --allow-empty --no-verify -m 'Betreff ohne Kennung'
# -> Exit 0 — die Umgehung, die git selbst anbietet
```

Die hermetische Hälfte derselben Zähne —
[`test/commit-msg-hook.bats`](../test/commit-msg-hook.bats) im gepinnten bats-Image — fährt den
Aufruf über den Hook, ohne `git`; die Kopplung an die Liste der Gate-Config steht dort als eigene
Gruppe.

**Die Konventions-Abhängigkeit entfällt für eine Hälfte.** Der PreToolUse-Zusatz greift nur bei der
Aufrufform *„Commit via Message-Datei"* (`-F`/`--file`), die nicht jeder Rollen-Anweisungssatz
nennt — für ihn läuft diese Lücke weiter
(`waechter-abdeckung-haengt-an-uninstruierter-konvention` im Beobachtungs-Register,
`docs/plan/planning/observations/`). Der `commit-msg`-Hook braucht die Form nicht: er liest eine
Message-Datei, die git ihm übergibt, gleichgültig welcher Aufruf sie erzeugt hat.

**Im gebootstrappten Ziel trägt der git-eigene Hook die Kennungs-Zusage; den PreToolUse-Zusatz für
Commit-Messages bekommt es nicht.** Seine Prüfung reist als
`tools/harness/commit-msg-traceability.sh` mit dem Klon; den Träger `.githooks/commit-msg` legt der
Lauf daneben nur an einem freien Pfad ab, und der abgelegte Träger ruft die Prüfung über sein
eigenes Verzeichnis auf. **Die zwei Nachbarn tragen zwei verschiedene Klassen**
([`ADR-0054`](../docs/plan/adr/0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1):
die Prüfung wird bei jedem Lauf kanonisch neu geschrieben — sie ist das Stück des Paares, das sich
mit der Werkzeug-Fassung ändert —, der **Träger dagegen nur dort, wo der Pfad frei ist**
(skip-if-present). Der Name ist von `git` fixiert und das Verzeichnis gehört dem Repo: führt ein
Ziel an diesem Pfad bereits seinen eigenen Träger, bleibt er unberührt, und der Lauf nennt ihm den
Pfad und die mitgelieferte Prüfung, die daneben bereitliegt. Verdrahtet wird er über
`harness/mk/hooks-install.mk` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->:
das Fragment definiert `make hooks-install`, das `core.hooksPath` auf `.githooks` setzt, und der
Aggregator des Ziels bindet es über `include harness/mk/*.mk` ein. Die Command-Vorlage des Ziels
(`.claude/commands/implement-slice.md`) nennt den Hook, den Aktivierungsschritt, seine zwei Grenzen
und die Commits, die er mitnimmt — ohne diesen Satz läge der Träger dort und schwiege. Die zwei
Grenzen sind dieselben wie hier: die Aktivierung reist nicht mit dem Klon, und `--no-verify` umgeht
ihn. **Die erste wiegt dort schwerer, weil der Agenten-Kanal fehlt:** hier fängt der
PreToolUse-Zusatz Commits in der `-F`-Form auch ohne Aktivierung, im Ziel ist jeder Commit ohne
`make hooks-install` ungeprüft.
**Er hängt dort am Commit und sieht darum auch die Commits der Repo-Werkzeuge:** `make slice-mv`
und `make archive-welle` committen intern mit dem Slice- bzw. Welle-Namen, und eine benannte
Kennung trifft kein Muster der Menge — solche Commits fallen an ihm, sobald er aktiviert ist. Ein
Ziel, das ihn aktiviert, gibt seinen Werkzeug-Messages darum eine Kennung. Wie viele Messages
dieser Klasse hier ohne Kennung sind, sagt die Tabelle oben mit ihrem Kommando — die Zahl steht
darum nicht daneben
([`MR-025`](conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)). Was
er dort ebenso wenig erreicht wie hier, steht im Fragment geschrieben: die zweite Hälfte der Zusage
— ein Doku-Update bei berührtem öffentlichem Vertrag — ist von einem Commit-Wächter nicht mechanisch
prüfbar. **Die Kennungs-Menge steht dort in der Zeile `patterns=` der Prüfung, und der Bootstrap
legt keine zweite Fassung daneben ab** — die `commits:`-Kopplung aus §Traceability bleibt eine
Eigenschaft dieses Repos, und die Prüfung des Ziels liest die Doku-Gate-Konfiguration nicht. Ihre
Fehlermeldung wiederholt die Menge nicht, sondern nennt die Zeile, in der sie steht.
Gemessen wird die ganze Kette am gebootstrappten Ziel von
[`make full-smoke`](sensors/full-smoke.md): Aktivierung, ein Commit ohne Kennung (der fällt), einer
mit Kennung (der durchgeht) und die Umgehung.

## Safety and scope boundaries

**Der Dogfood-Go-Gate-Stack ist vollständig**: `make lint` / `make build` / `make test` (Go
via Dockerfile-Stages) neben `docs-check` / `shell-lint` / `baseline-verify`. **Nicht
behauptet:** das Architektur-Gate (a-check,
[`LH-FA-07`](../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) — der Dogfood ist
**flach**, hier hätte a-check einen leeren Prüfbereich
([`LH-QA-01`](../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
**Emittiert wird es trotzdem** (emitted-only): ein Zielrepo mit einem schichten-tragenden
Layout — `--arch hexslice` (go, cpp) oder `--arch hexagonal` (go) — bekommt `.a-check.yml` +
`a-check.mk` und fährt a-check in seinem `make gates` mit; ein flaches Ziel bekommt keines.
Welche Layouts das sind, entscheidet keine Namensliste, sondern die strukturelle Frage, ob
das Layout eine geprüfte Schicht trägt. Belegt in [`make full-smoke`](sensors/full-smoke.md)
(beide Richtungen + ein verbotener Import, der das emittierte Gate rot färbt), nicht hier.

**CI** ([`MR-014`](conventions.md#mr-014--ci-auf-frischem-klon-github-actions)): GitHub
Actions fährt `make gates` + [`make smoke`](sensors/smoke.md) +
[`make full-smoke`](sensors/full-smoke.md)
auf **frischem Klon** pro Push/PR — schließt die
[`MR-003`](conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke
(der lokale Stop-Hook gibt einen cleanen Tree ohne State frei; „CI ist dort das Netz").
**Nur nächtlich** laufen zwei Klassen, jede mit eigenem Grund und eigener Workflow-Datei
(`schedule` + `workflow_dispatch`): die Netz-Sensoren `regelwerk-check`/`baseline-freshness`
in `upstream-drift.yml` — ein Upstream-Ausfall darf keinen Push blockieren — und
[`make mutate`](sensors/mutate.md) in `mutate.yml`, weil das Regelwerk die Mutationstests
der Stufe **Post-integration** zuordnet (`grundlagen-klassifikation.md` §Klassifikation:
*„nach Merge : Mutation Tests"*, *„teurer, aber tolerierbar"*). Der Preis war gemessen:
`49m54s` des `mutate`-Jobs gegen `49m58s` Gesamtdauer eines Pushes
(`gh api "repos/pt9912/ai-harness-init/actions/jobs/<job-id>/logs"`). Die CI ruft **ausschließlich `make`-Targets** (keine zweite
Gate-Definition). **Was CI nicht prüft:** nichts, was nicht in einem dieser Targets steht —
ein grüner CI-Lauf ist keine Aussage über ungetestete Flächen.

## Minimal agent workflow

1. Diese Datei lesen.
2. Relevante kanonische Quelle lesen (Source Precedence).
3. Betroffene IDs identifizieren.
4. Kleinste sinnvolle Änderung planen.
5. Engsten nützlichen Sensor laufen lassen.
6. Repo-weiten Gate-Lauf vor Handoff (`make gates`).
7. Doku/Indizes aktualisieren, falls ein öffentlicher Vertrag berührt.
8. Ausgeführte Sensors und verbleibende Risiken berichten.

Dieser Workflow deckt ausschließlich die Implementer-Rolle ab. Schritt 8
ist der Rollenwechsel, kein Abschluss: Bericht → Handoff an Reviewer
(`.harness/skills/reviewer.md`, siehe §Guides) → Verifier. Kein
Self-Review — anderer Kontext findet andere Findings, derselbe Kontext
dieselben blinden Flecken (Baseline-Regelwerk `modul-08-agentenrollen.md`).

## Leseordnung

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-harness-dateien.md`
§harness/README.md als Einstiegspunkt — die Menschen-Hälfte des Einstiegs:
drei bis fünf **geordnete** Zeiger, was ein neuer Mensch zuerst liest und was
bei Bedarf; eine Leseordnung, die alles nennt, ist keine.

1. [`AGENTS.md`](../AGENTS.md) §3 — die Hard Rules, vor jedem Lauf.
2. [`spec/lastenheft.md`](../spec/lastenheft.md) — was dieses Repo vertraglich
   liefert.
3. [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md)
   — woran gerade gearbeitet wird.
4. [`conventions.md`](conventions.md) — bei Bedarf: der Index der Adaptionen von der
   Baseline (der Eintrag selbst liegt unter [`conventions/`](conventions/)), Modus-Deklaration.
