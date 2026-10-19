# Review: slice-release-schnitt-v0-10-0-liefert-java-python-csharp

**Rolle:** Reviewer (`.harness/skills/reviewer.md` 2.3.0) · **Datum:** 2026-10-19
**Diff:** Commit `9e60c01d` (Basis `bba122ea`), vier Dateien: `Makefile`, `internal/emit/templates/enforce/traeger.mk`, `test/traeger-fetch.bats`, `docs/user/benutzerhandbuch.md`
**Plan:** `docs/plan/planning/in-progress/slice-release-schnitt-v0-10-0-liefert-java-python-csharp.md` (wellenlos) · Prüfgrundlage `docs/user/releasing.md`, ADR-0058/0059/0064, AGENTS.md §3.6/§3.7/§3.11
**Release-Text (außerhalb des Repos):** `/private/tmp/claude-501/-Users-dburkard-Dev-pt9912-ai-harness-init/a53f3db9-533d-499d-9b47-39ae95c4c111/scratchpad/release-v0.10.0.md`

## Summary

0 HIGH · 1 MEDIUM · 2 LOW · 3 INFO. Der Pin ist vollständig und konsistent, alle sechs Digests sind aus einem eigenen, unabhängigen Neubau reproduziert, die Handbuch-Aussagen zu Sprachen, Fehlertexten und Bäumen stimmen mit einem selbst gebauten Binary überein. Der Befund mit Gewicht ist eine Zusage im Release-Text ohne Sensor (F-1).

Klassen für den Zähler: F-1 „Release-Text sagt Aktualität einer Komponente zu, die kein Sensor misst" · F-2 „unbeabsichtigte Leerzeilen-Entfernung in Prosa-Edit" · F-3 „Kommentar-Stand widerspricht Code-Tabelle".

## Findings

### F-1 — MEDIUM — Release-Text nennt `a-check` als „aktuell" gemeldet; kein Sensor des Repos misst das

- `quelle`: AGENTS.md §3.6 (Zusage ohne benannte Messung), `releasing.md` Schritt 5 (**Grenze** sagt zu, was das Release nicht zusagt)
- `pfad`: Release-Text, Abschnitt **Grenze**, Satz „Ein Aktualitäts-Hinweis-Lauf vor dem Schnitt meldete Go, golangci-lint, d-check, a-check, Baseline, C++-Basis und den gradle-Tag als aktuell"
- `befund`: Die Freshness-Ziele des Repos sind `freshness-golangci`, `freshness-dcheck`, `freshness-go`, `freshness-cpp`, `freshness-kotlin`, `freshness-digest` und `baseline-freshness` (`grep -n '^freshness[a-z-]*:' Makefile`, `.github/workflows/upstream-drift.yml`). `grep -rni 'a-check' Makefile harness/tools/*fresh* .github/workflows/upstream-drift.yml` findet a-check nur in `digest-freshness.sh` (hält Tag↔Digest gegeneinander, fragt nicht nach einem neueren Tag). „a-check aktuell" ist damit durch keinen Lauf belegt, und der Lauf selbst (Ausgabe) liegt dem Review nicht vor; gelesen ist nur die Behauptung. Ein Leser des Release liest „aktuell" als Aussage über die Version.
- `verifizierbar`: nein (kein Sensor für a-check; der Hinweis-Lauf des Implementers ist nicht im Report-Eingang)
- `klasse`: Release-Text sagt Aktualität einer Komponente zu, die kein Sensor misst

### F-2 — LOW — Leerzeile vor `### Das aufgesetzte Repository prüfen` entfernt

- `quelle`: Maintainability (Diff-Treue; Plan §3 nennt für diese Stelle nur die Streichung des Satzes zum Quellstand)
- `pfad`: `docs/user/benutzerhandbuch.md:328-329`
- `befund`: Der Edit am Absatz **Grenzen** hat die folgende Leerzeile mitgenommen (`git show 9e60c01d -- docs/user/benutzerhandbuch.md`: `-` leere Zeile, `+` Absatz); der Absatz liegt jetzt direkt über der Überschrift (`sed -n 327,329p`). CommonMark rendert die Überschrift trotzdem; jeder andere Absatz-Übergang im Handbuch führt eine Leerzeile.
- `verifizierbar`: ja (`sed -n 327,329p docs/user/benutzerhandbuch.md`)
- `klasse`: unbeabsichtigte Leerzeilen-Entfernung in Prosa-Edit

### F-3 — LOW — Release-Text „Stand" beschreibt ein Handbuch durch den Wegfall eines Hinweises

- `quelle`: AGENTS.md §3.7 (Beschreibung des Ist-Zustands, nicht eines abwesenden Textes; hier sinngemäß auf einen öffentlichen Text angewandt)
- `pfad`: Release-Text, Abschnitt **Stand**, letzter Satz „… trägt keinen Quellstand-Hinweis mehr"
- `befund`: Der Satz nennt abwesenden Text; ein Leser von `v0.10.0` hat den Hinweis nie gesehen. Das Handbuch-Statement als Zustand („beschreibt alle sechs Sprachen") steht schon im Satz davor.
- `verifizierbar`: nein
- `klasse`: Kommentar-/Textform beschreibt abwesenden Text

### F-4 — INFO — `internal/gen/gen.go`: Kommentar STAND widerspricht `langArchs()`

- `quelle`: AGENTS.md §3.7
- `pfad`: `internal/gen/gen.go`, Kommentar über `langArchs()` („python traegt flat … csharp traegt flat") gegen `langArchs()` (`python`/`csharp`: `{archFlat, archHexslice}`)
- `befund`: Nicht Teil von `9e60c01d`, aber Teil des Tag-Baums (`git diff v0.9.0..9e60c01d -- internal/gen/gen.go`); der Kommentar behauptet für `python` und `csharp` weniger als der Code trägt, und das Handbuch sagt `hexslice` für alle sechs. Der Bestand ist laut AGENTS.md §3.7 kein Arbeitsauftrag; Hinweis, weil der Tag-Baum ihn in ein Release trägt.
- `verifizierbar`: nein
- `klasse`: Kommentar-Stand widerspricht Code-Tabelle

### F-5 — INFO — Zwischen Pin und Publikation unbelegt (benannt, nicht gemessen)

- `quelle`: `releasing.md` Schritt 2, ADR-0059 Folgepflicht 2, `Makefile`-Kommentar an den Pins
- `befund`: Dass die lokal gemessenen Digests die des Workflows sind, belegt erst `make traeger-fetch` nach der Publikation. Vorher gemessen: der Workflow ruft denselben `make release-artifacts DEST=dist` mit `TRAEGER_VERSION=<Tag>` (`.github/workflows/release.yml:56,64`), der Bau-Kern steht im `Dockerfile` (`-buildvcs=false`, `-trimpath`, `-ldflags … -X main.fassung=$TRAEGER_VERSION`), also commit-unabhängig. Nicht gemessen: Abweichung durch Runner-Architektur (linux/amd64) gegenüber dem lokalen Docker-Host (arm64); für `v0.9.0` hat sich die Gleichheit nach der Publikation gehalten (Evidence `waechter-misst-die-fixture-statt-der-realen-quelle/evidence/slice-release-schnitt-v090-…md`), das ist ein Vorgänger-Beleg, kein Beleg für `v0.10.0`.
- `verifizierbar`: nein, erst nach dem Tag-Push
- `klasse`: Pin-Kopplung erst nach der Publikation belegbar

### F-6 — INFO — Realer `Makefile`-Digest weiter ungebunden

- `quelle`: AGENTS.md §3.6 (Fixture gegen reale Quelle), Beobachtung `waechter-misst-die-fixture-statt-der-realen-quelle`
- `befund`: `test/traeger-fetch.bats` hält am realen `Makefile` den Tag (`pin_wert … = v0.10.0`) und die Form (sechs Werte, je 64 Hex), nicht die Digest-Werte. Ein verfälschter Digest im realen `Makefile` färbt vor der Publikation keinen Fall; der Implementer hat die Lücke gemeldet, der Review hat sie nicht erneut gefahren (Quelle: die Beobachtung mit Evidence zu `v0.9.0`). Gegenmittel in diesem Schnitt: Digest-Nachrechnung (unten) und Verifier-Pflicht laut Plan §3.
- `verifizierbar`: nein (Lücke bekannt)
- `klasse`: Wächter misst die Fixture statt der realen Quelle

## Geprüft, ohne Befund

- **Pin-Stellen (Schwerpunkt 1):** `git grep -n 'v0\.9\.0'` außerhalb `docs/reviews`, `done/`, ADRs und Baseline trifft nur: Plan (Vorgänger-Aussagen), zwei Beobachtungs-Evidence-Dateien (Zeitdokumente), `test/tap-nachzug.bats:774-776` (Tap-Vergleichsfall `0.10.0:v0.9.0`, Vorgänger als Testdatum, gewollt) und drei Handbuch-Zeilen, die `v0.9.0` ausdrücklich als Vorgänger nennen (839, 887; Zeile 3/81 tragen `v0.10.0`). Tag-Stellen: `traeger.mk`, `test/traeger-fetch.bats` (beide Zeilen), `Makefile` (`TRAEGER_TAG` + sechs `TRAEGER_SHA256_*`) alle `v0.10.0`/neue Werte, im selben Commit. Die sechs `Makefile`-Werte sind zeilengleich mit `dist/SHA256SUMS`.
- **Digest-Herkunft (Schwerpunkt 3):** Eigener Neubau `make release-artifacts DEST=<scratchpad>/rebuild TRAEGER_VERSION=v0.10.0` am Stand `9e60c01d`; `diff <scratchpad>/rebuild/SHA256SUMS dist/SHA256SUMS` → gleich, alle sechs Digests (nicht nur einer) stimmen mit denen im `Makefile` überein. Das ist Gleichheit zweier lokaler Bauten, nicht des Workflows (F-5).
- **Handbuch (Schwerpunkt 2):** `grep -n -i 'Quellstand\|Quellbaum\|nächste Release' docs/user/*.md` → ohne Treffer, der Hinweis ist restlos entfernt, kein Verweis „siehe den Hinweis zum Quellstand" bleibt. Am eigenen Binary (`rebuild/ai-harness-init-darwin-arm64`, `--version` → `v0.10.0`): `--lang xx` → `Fehler: unbekannte Sprache "xx"; verfuegbar: cpp, csharp, go, java, kotlin, python` (Exit 2, wie Zeile 837); `--lang python|cpp|java|csharp|kotlin --arch hexagonal` → `unbekannte Architektur "hexagonal"; verfuegbar: flat, hexslice` (Exit 2; stimmt mit der Handbuch-Zeile für `python`); `--lang go --arch zzz` → `verfuegbar: flat, hexagonal, hexslice`. Der Vorgänger-Download (`gh release download v0.9.0`, sha256 gleich dem alten Pin) nennt `cpp, go, kotlin` für `xx` und `java` — die Vorgänger-Aussagen in 839/887 stimmen. Bäume echter Bootstraps (`--lang java|python|csharp`, flat und `--arch hexslice`): Dateien und Pfade der Prosa (`Main.java`/`GreetTest.java`, `src/app/main.py`/`tests/test_greet.py`, `Program.cs`/`GreetTests.cs`, `Ports/inbound`+`outbound`, `.a-check.yml`+`a-check.mk`), `pyproject.toml` ohne `[project]`, `Directory.Build.props` mit `net10.0`, kein `gradlew`, Standard-Tags (`9.8.1-jdk21`, `3.14.8-slim`, `10.0.402`) stimmen mit dem Code. Gelesen, nicht gefahren: die Prüf-Stufen der drei Ziele (`make gates` im Ziel, Docker-Läufe der Toolchain-Images) und der Sprachbaum-Abgleich der vier Schichten-Pfade im Go-Teil; den Baum-Abgleich in beide Richtungen hält `handbuch_baum_pruefen` in `full-smoke` (Wurzel-Variante, laut seiner eigenen Grenze nicht die Sprach-Prosa).
- **Release-Text (Schwerpunkt 4):** Gegen Quellen gelesen: Sprachliste, Standard-Tags, Bauformen, `--help`-Marker `ai-harness-init`/`add-lang` (`harness/tools/start-smoke.sh:48`), acht Assets (`releasing.md` Schritt 5), „Tag-Pins ohne `@sha256`" (`internal/gen/{java,python,csharp}.go` `FROM …:${…_TAG}`, `digest-freshness.sh` Kopf: Skelett-Dockerfiles führen keinen Digest). Ausnahmen: F-1, F-3. **Bestand entfällt zu Recht:** 8 Optionssätze frisch gegen frisch, Träger `v0.9.0` (Download) gegen Träger `v0.10.0` (Neubau): `go`, `go hexagonal`, `go hexslice`, `cpp`, `cpp hexslice`, `kotlin`, `kotlin hexslice`, sprachlos — `diff -rq -x .git` nennt in jedem Satz genau zwei Pfade, `harness/mk/traeger.mk` (Zeile `TRAEGER_TAG`, sonst byte-gleich) und `.harness/state/bin/ai-harness-init`. Beide werden bei einem Re-Lauf neu geschrieben (Gegenprobe: `v0.10.0` über ein mit `v0.9.0` aufgesetztes Go-Ziel setzt `TRAEGER_TAG ?= v0.10.0` und legt den neuen Träger, sha256 `046c0206…`, ab), gehören also nicht zur Klasse „nur bei fehlender Datei". Die drei neuen Sprachen kennt der Vorgänger nicht (Exit 2), kein Diff möglich. Nicht gefahren: die Sätze `--lang java|python|csharp` gegen den Vorgänger (Exit 2 des Vorgängers ist an `--lang java` belegt, die anderen zwei nicht einzeln).
- **MR-089 (Schwerpunkt 5):** Das Handbuch und der Release-Text enthalten keine Laufzeit- oder Kosten-Aussage über einen emittierten oder E2E-Lauf; die Zahlen (Tags, Digests, Exit 2, acht Assets) sind Messwerte mit Kommando oder Quelle. Der Hinweis-Lauf der Freshness-Ziele ist ein Lauf des Implementers ohne Beleg im Eingang (F-1).
- **§3.11:** der Diff nennt keinen Pfad in einem eingefrorenen Artefakt neu; der Release-Text steht außerhalb des Repos.
- **Rollenfremdes:** der Diff berührt keinen Hard-Rule-/Adaptions-Block (§3.8) und keine Closure-Artefakte (§3.10).

## Sensoren

- `make host-bin` nicht nötig (Binary aus `make release-artifacts` am selben Stand gebaut, Neubau im Scratchpad, kein Rest im Baum).
- Mutations-CI-Probe: nicht gefahren (Push verboten), vom Implementer gemeldet; dieser Diff legt keinen Mutations-Fall an.
- `make gates`: nach dem Report-Commit, Ergebnis im Handoff-Text.
