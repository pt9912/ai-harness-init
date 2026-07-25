# Review-Report: slice-048 — Impl-Review (Release-Artefakte / Plattform-Matrix) — 2026-07-25

**Review-Art:** Code — geprüft gegen den Slice-Plan (§2 DoD, §3 Plan, §6 Risiken),
`AGENTS.md` Hard Rules (3.2 Lint-Suppression-Verbot, 3.6 keine Zusage ohne rot
gesehenes Gegenbeispiel) und `harness/conventions.md` MR-014 (Setzungen 1–4).
**Nicht** gegen die DoD-Erfüllung als solche — das ist Verifier-Rolle (Modul 11).

**Gegenstand:** vier Commits, Vor-Stand `14e3455`:

1. `5c4930b` — CR `spec/lastenheft.md` 0.12.0 → 0.13.0 (Messmethode LH-QA-04 abgestuft)
2. `dfca6c6` — `Dockerfile` build-Stage + `Makefile` `release-artifacts` + `test/release-matrix.bats` + `test/mutations/78..81`
3. `4219db9` — `.github/workflows/release.yml` (Jobs `artifacts`, `start-smoke`, `publish`)
4. `067e928` — Fix: Release anlegen-oder-ergänzen, Vorab-Tag als `--prerelease`, Inline-Suppression entfernt

Nicht Gegenstand: `2abda63` (Reichweiten-Korrektur `harness/conventions.md`) und
`b39f7b6` (Benutzerhandbuch) — im selben Zeitraum, außerhalb des Slice; berührt den
Slice nicht (siehe Negativbefunde).

**Skill:** `.harness/skills/reviewer.md` @ `067e928` · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-25

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- `docs/plan/planning/in-progress/slice-048-release-artefakte.md` (§2 DoD, §3 Plan, §6 Risiken)
- `AGENTS.md` §3 Hard Rules (3.1, 3.2, 3.6), §4 Quality Gates
- `harness/conventions.md` MR-014 (Setzungen 1–4, Nachtrag 2026-07-24)
- `spec/lastenheft.md` LH-QA-04, LH-QA-03, LH-QA-02, LH-QA-01 · ADR-0003
- `.harness/baseline/v3.5.1/regelwerk/modul-10-review-harness.md` (Kategorien, Negativbefund-Pflicht)

**Mess-Grundlage dieses Laufs** (READ-ONLY, kein `make`, keine Host-Toolchain):

| Frage | Messung |
|---|---|
| `gh` ohne Repo-Kontext | hermetische Sonde in leerem Verzeichnis, `GH_TOKEN=dummy`: `gh release view v0.0.0` und `gh release create v0.0.0 --generate-notes` brechen beide mit `failed to run git: fatal: Kein Git-Repository`, Exit 1 — vor jedem API-Aufruf (gh 2.45.0) |
| `gh help environment` | `GH_REPO`: „specify the GitHub repository … for commands that otherwise operate on a local repository"; kein Fallback auf `GITHUB_REPOSITORY` dokumentiert |
| `set -e` + `[ … ] && ext=".exe"` | hermetische Sonde in `dash` (`/bin/sh`): Schleife überlebt beide Iterationen, `ext` korrekt gesetzt/leer — die AND-Liste bricht das Recipe **nicht** ab |
| Reichweite der LH-Kopplung | Sonde auf einer Kopie von `spec/lastenheft.md`: Anforderung um `· freebsd` erweitert → `lh_platforms` liefert unverändert die fixen sechs Kombinationen, Wächter bliebe grün |
| `# expect:`-Abdeckung | `test/release-matrix.bats` trägt **sechs** `@test`; `test/mutations/78..81` nennen vier `expect:`-Ziele (Tests 1, 3, 5, 6) |
| Mutations-Zieldateien | `grep '^# files:' test/mutations/*.sh`: `Dockerfile` kommt in **keinem** Fall vor; `.github/workflows/ci.yml` in Fall 10 (`verify: ci-lint`) |
| Inline-Suppression | `grep -rn 'shellcheck disable\|nolint'` über `.github/`, `Makefile`, `Dockerfile`, `test/`, `harness/`: **0 Treffer** |
| `--help`-Vertrag | `cmd/ai-harness-init/main.go:34-66` Usage auf stdout, Exit 0 (`main_test.go:91`); Marker `ai-harness-init` (Zeile 34) und `add-lang` (Zeile 38) real enthalten |
| Fenster der LH-Kopplung | `grep -A4 'LH-QA-04 — Plattform-Matrix'` deckt `spec/lastenheft.md:255-259`, also genau die Anforderung — die neue Messmethoden-Prosa ab `:261` liegt außerhalb |

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
[Kurs Modul 10 §Output-Schema](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/04-qualitaet/modul-10-review-harness.md#worked-example-eine-reviewer-skill-datei-schreiben).

<!-- Kein Fließtext, kein Lösungsvorschlag im Befund. -->

### F-1 — `publish`-Job: `gh` hat keinen Repo-Kontext, der Upload-Pfad bricht sicher ab

- `kategorie`: HIGH
- `quelle`: Slice-Plan §2 (DoD „Release-Workflow … lädt die Artefakte ans Release"), LH-QA-04
- `pfad`: `.github/workflows/release.yml:100-133` (Job ohne `actions/checkout`, Step-`env` nur `GH_TOKEN`, `:127`, `:128`, `:130`, `:132`)
- `befund`: Der `publish`-Job checkt das Repo nicht aus und setzt weder `GH_REPO` noch `-R`; `gh release view/upload/create` ermitteln ihr Basis-Repo aus den git-Remotes des Arbeitsverzeichnisses. Hermetisch gemessen (gh 2.45.0, leeres Verzeichnis, `GH_TOKEN=dummy`): beide Kommandos brechen mit `failed to run git: fatal: Kein Git-Repository` und Exit 1 ab, bevor irgendein API-Aufruf stattfindet — `gh release view` läuft dabei in den `>/dev/null 2>&1`-Zweig, der Lauf fällt also auf `gh release create` und scheitert dort. Damit ist genau der Pfad, den `067e928` gegen einen „sicheren Fehlschlag" härten sollte, weiterhin ein sicherer Fehlschlag, aus einer zweiten Ursache. `gh help environment` nennt `GH_REPO` als den Mechanismus für Kommandos, „die sonst auf einem lokalen Repository operieren"; ein Fallback auf `GITHUB_REPOSITORY` ist dort nicht dokumentiert.
- `verifizierbar`: ja — kein lokaler Gate deckt ihn (`ci-lint` prüft Syntax, nicht Verhalten); beobachtbar am ersten Vorab-Tag-Lauf (`v0.1.0-RC`), den §6 des Slice genau dafür vorsieht. Gegenprobe lokal: die obige Sonde. **Grenze:** gemessen mit gh 2.45.0; die Runner tragen eine neuere gh-Version — ein undokumentierter Fallback in einer neueren Version ist nicht ausgeschlossen, wäre als Grundlage des einzigen sensorlosen Pfads aber selbst ein Befund.

### F-2 — Wächter „Windows-Artefakte tragen .exe" misst die Implementierung, nicht die Eigenschaft

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` Hard Rule 3.6 („ein Test, dessen Name eine Eigenschaft behauptet, muss die Eigenschaft messen, nicht ihre heutige Implementierung")
- `pfad`: `test/release-matrix.bats:66-69` · `Makefile:81` · `Makefile:89`
- `befund`: Der Test prüft zwei Quell-Literale (`ext=".exe"` und die `[ "$$os" = "windows" ]`-Bedingung), aber nirgends, dass der Zielname der Kopie `$$ext` überhaupt trägt: `$$ext` kommt in `test/release-matrix.bats` nicht vor. Entfällt `$$ext` im `docker cp`-Ziel (`Makefile:89`), bleiben alle sechs `@test` grün, während beide Windows-Artefakte ohne Endung im `DEST` landen — genau der Fehler, den der Test-Kommentar `:64-65` als „erst beim Anwender sichtbar" beschreibt. Umgekehrt röte eine verhaltensgleiche Umschreibung (z. B. `case "$os" in windows)`) den Wächter, ohne dass sich die Eigenschaft ändert.
- `verifizierbar`: ja — ein Mutations-Fall `sed -i 's|-\$\$arch\$\$ext|-\$\$arch|' Makefile` liefe heute grün durch (`make mutate` meldete ihn als Befund „Sensor bleibt grün").

### F-3 — Wächter „build-Stage nimmt eine Zielplattform entgegen" ist unbewacht (kein Fall trifft das `Dockerfile`)

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` Hard Rule 3.6 („wer keinen Fall in `test/mutations/` hat, ist unbewacht"); Slice-Plan §2 („rot gesehene Mutation je neuem Wächter … Cross-Compile-Verdrahtung")
- `pfad`: `test/release-matrix.bats:71-75` · `test/mutations/78..81` (alle `# files: Makefile`) · `Dockerfile:56-61`
- `befund`: Die vier neuen Fälle mutieren ausschließlich das `Makefile`; `Dockerfile` ist in keinem der 81 Fälle ein `# files:`-Ziel. Die Dockerfile-Hälfte der Cross-Compile-Verdrahtung (`ARG TARGET_OS`/`ARG TARGET_ARCH`, `GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH}`) hat damit keinen rot gesehenen Gegenbeispiel-Lauf. Fällt `GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH}` weg, ignoriert `docker build` die beiden `--build-arg` still (Exit 0), und `make release-artifacts` schriebe sechs identische linux/amd64-Binaries unter plattform-tragenden Namen ins `DEST` — sichtbar wäre das erst am Start-Smoke auf einem fremden Runner oder beim Anwender.
- `verifizierbar`: ja — `make mutate` mit einem Fall `# files: Dockerfile`, der `GOOS=${TARGET_OS}` entfernt; erwartet rot an `release: die build-Stage nimmt eine Zielplattform entgegen`.

### F-4 — Zusage „in BEIDE Richtungen" der LH-Kopplung ist breiter als der Wächter

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` Hard Rule 3.6 („die Zusage auf das einschränken, was der Code hält")
- `pfad`: `test/release-matrix.bats:26-29` (Kommentar) · `:30-46` (`lh_platforms`)
- `befund`: Der Kommentar sagt zu: „Fällt dort eine Plattform weg **oder kommt eine hinzu**, ohne dass das Makefile mitzieht, ist das ein Befund — in beide Richtungen." `lh_platforms` prüft aber nur die **Anwesenheit** der drei OS- und zwei Arch-Token im 4-Zeilen-Fenster und druckt danach eine **fest verdrahtete** Sechser-Liste. Gemessen an einer Kopie von `spec/lastenheft.md`: Anforderung auf `**linux · macos · windows · freebsd**` erweitert → Token-Prüfung passiert, erwartete Liste unverändert, Wächter grün. Gedeckt ist allein die Weg-Richtung (leere Ausgabe → `[ -n "$erwartet" ]` fällt). Dieselbe Klasse, die `2abda63` einen Commit zuvor in `harness/conventions.md` korrigiert hat.
- `verifizierbar`: ja — Sonde oben; ein Mutations-Fall `# files: spec/lastenheft.md`, der die Anforderung um eine Plattform ergänzt, bliebe heute grün.

### F-5 — MR-014 Setzung 1: `release.yml` erfüllt den Wortlaut nicht, der Kopf behauptet es dennoch

- `kategorie`: MEDIUM
- `quelle`: `harness/conventions.md` MR-014 Setzung 1 („nur `make`-Targets, keine zweite **Gate**-Definition … Die Workflow-Steps rufen **ausschließlich** `make <target>` auf")
- `pfad`: `.github/workflows/release.yml:10-12` (Kopf-Zusage) · `:47`, `:50`, `:84-96`, `:111-133` (vier Nicht-`make`-Steps)
- `befund`: Der Kopf schreibt „MR-014 Setzung 1 (nur make-Targets, keine zweite **Build**-Definition) gilt weiter" — die Konvention verbietet die zweite **Gate**-Definition, nicht nur die Build-Definition. `ci.yml` und `upstream-drift.yml` halten den Wortlaut buchstäblich (jeder Step ist ein `make`-Aufruf); `release.yml` hat vier Steps, die es nicht sind, und einer davon (`start-smoke`, `:84-96`) ist nicht Mechanik, sondern der LH-QA-04-**Nachweis** selbst — ein Sensor, dessen Definition allein im Workflow liegt und lokal nicht ausführbar ist. Die Begründung „Upload/Download und der Release-Upload sind Workflow-Mechanik" trägt für `:47/:50/:111-133`, deckt aber den Start-Smoke nicht ab; die engere Wortwahl macht die Abweichung im Kopf unsichtbar, und MR-014 trägt keinen Nachtrag dazu.
- `verifizierbar`: nein (Konventions-/Zusagen-Ebene, kein Gate misst es) — beobachtbar am Vergleich der drei Workflow-Dateien.

### F-6 — `workflow_dispatch` auf einem Tag-Ref veröffentlicht, entgegen der Zusage im Kopf

- `kategorie`: LOW
- `quelle`: `AGENTS.md` Hard Rule 3.6 (Doc-Kommentar auf das einschränken, was der Code hält)
- `pfad`: `.github/workflows/release.yml:98-102` · Slice-Plan §6 („`workflow_dispatch` deckt die Stufe davor … ohne jeden Upload")
- `befund`: `if: startsWith(github.ref, 'refs/tags/')` prüft den Ref, nicht das Event. Der „Run workflow"-Dialog (und `POST /actions/workflows/…/dispatches`) akzeptiert einen **Tag** als Ref; in dem Fall ist `github.ref` = `refs/tags/…`, `publish` läuft und legt ein Release an. Die Zusage „Ein workflow_dispatch-Lauf baut und smoked, lädt aber NICHTS hoch" gilt damit nur für einen Branch-Ref. Die eigentliche Invariante („kein Release ohne Tag") bleibt gewahrt; die im Slice §6 beschriebene Probier-Stufe „ohne jeden Upload" ist es nicht.
- `verifizierbar`: nein lokal — beobachtbar beim ersten Dispatch auf ein Tag.

### F-7 — Vorab-Erkennung `case "$tag" in *-*` klassifiziert nach irgendeinem Bindestrich

- `kategorie`: LOW
- `quelle`: Maintainability / Slice-Plan §6 („SemVer-Vorab-Tag")
- `pfad`: `.github/workflows/release.yml:125-126`
- `befund`: Das Muster trifft jeden Bindestrich an beliebiger Stelle: `v1.0.0+build-1` (Build-Metadaten, laut SemVer **keine** Vorabversion) und ein Datums-Tag wie `v2026-07-25` würden als `--prerelease` veröffentlicht; umgekehrt gibt es keine Prüfung, dass der Tag überhaupt SemVer-förmig ist. Für den dokumentierten Gebrauch (`v0.1.0-RC`) trifft die Heuristik zu, die Kommentar-Zuschreibung „SemVer-Präreleasetag (…, erkannt am Bindestrich)" ist aber breiter als die SemVer-Regel (Vorabteil steht zwischen erstem `-` und einem etwaigen `+`).
- `verifizierbar`: nein lokal — beobachtbar an einem Tag der genannten Form.

### F-8 — Historie-Tabelle: Zeile 0.13.0 steht vor 0.12.0

- `kategorie`: LOW
- `quelle`: `spec/lastenheft.md` §7 (aufsteigend geführte Versions-Historie)
- `pfad`: `spec/lastenheft.md:310` (0.13.0) vor `:311` (0.12.0)
- `befund`: Der CR-Commit `5c4930b` hat die neue Zeile hinter 0.11.0 eingefügt; die Tabelle lief bis dahin durchgehend aufsteigend (0.1.0 … 0.12.0). `docs-check` deckt Reihenfolge nicht, der Lauf blieb grün (177 Dateien, 0 Befunde).
- `verifizierbar`: ja — Sichtprüfung der Tabelle; kein Gate misst es.

### F-9 — `Dockerfile`: zwei identische Stage-Banner für eine Stage

- `kategorie`: LOW
- `quelle`: Maintainability
- `pfad`: `Dockerfile:42-55` (`# ---- build ----` in `:42` und erneut `:48`)
- `befund`: Der neue Kommentarblock bringt einen zweiten `# ---- build ---------…`-Banner mit, obwohl der bestehende Block direkt darüber dieselbe Stage einleitet. Die übrigen Stages (`deps`, `compile`, `lint`, `test`) tragen je genau einen Banner.
- `verifizierbar`: ja — Sichtprüfung; kein Gate misst es.

### F-10 — keine Kopplung Workflow ↔ Usage-Text und Workflow ↔ Target-Name

- `kategorie`: LOW
- `quelle`: `AGENTS.md` Hard Rule 3.6 (Zusage/Abdeckung), Muster `test/sources-pin.bats`
- `pfad`: `.github/workflows/release.yml:95-96` (Marker) gegen `cmd/ai-harness-init/main.go:34,38` · `:48` (`make release-artifacts`) gegen `Makefile:77`
- `befund`: Die beiden Marker-Strings und der Target-Name sind im Workflow dupliziert, ohne den Kopplungs-Wächter, den `test/release-matrix.bats` für Makefile ↔ Lastenheft gerade etabliert. Verschwindet `add-lang` aus dem Usage-Text oder wird das Target umbenannt, bleiben `make gates` und `ci-lint` grün; der Bruch zeigt sich erst im Tag- oder Dispatch-Lauf. (Die Marker selbst sind heute korrekt — `main.go:34` und `:38` enthalten beide Strings, `--help` geht auf stdout mit Exit 0.)
- `verifizierbar`: ja — ein bats-Wächter analog `release-matrix.bats` würde es messen; heute misst es nichts.

### F-11 — Action-Pins: Kommentar-Granularität uneinheitlich, SHAs offline nicht prüfbar

- `kategorie`: INFO
- `quelle`: `harness/conventions.md` MR-014 Setzung 4
- `pfad`: `.github/workflows/release.yml:51`, `:80`, `:107` (`# v4`) gegenüber `:46` (`# v5.1.0`)
- `befund`: Setzung 4 ist erfüllt (alle Runner benannt: `ubuntu-24.04`, `ubuntu-24.04-arm`, `macos-26-intel`, `macos-26`, `windows-2025`, `windows-11-arm`; kein `-latest`; alle drei Actions per Commit-SHA). Der etablierte Repo-Stil kommentiert den SHA mit der **vollen** Version (`# v5.1.0`); `upload-artifact`/`download-artifact` tragen nur `# v4`, womit der Pin ohne Upstream-Abgleich nicht gegen ein Release prüfbar ist. Die SHAs selbst sind in dieser READ-ONLY-Rolle netzlos nicht verifizierbar.
- `verifizierbar`: nein lokal — der Freshness-Kandidat „Vollständigkeits-Wächter für kuratierte Listen" (Roadmap) adressiert die Klasse.

### F-12 — Plattform-Annahmen jenseits der benannten Runner-Label-Grenze

- `kategorie`: INFO
- `quelle`: LH-QA-04 Messmethode (Grenze), MR-014 („nicht lokal rot-sehbar")
- `pfad`: `.github/workflows/release.yml:14-18`, `:80`, `:88-96`
- `befund`: Der Kopf benennt die Runner-Label-Grenze. Zwei weitere Annahmen desselben Typs sind nicht benannt: (a) die per SHA gepinnten `download-artifact`-Node-Runtimes müssen auf `ubuntu-24.04-arm` und `windows-11-arm` laufen; (b) das cross-kompilierte, mit `-s -w` gestrippte darwin/arm64-Binary muss die auf Apple Silicon verlangte (ad-hoc-)Signatur tragen, damit `./…-darwin-arm64 --help` überhaupt startet. Beides entscheidet sich erst im ersten realen Lauf.
- `verifizierbar`: nein lokal.

### F-13 — Wächter „die Matrix trägt sechs Kombinationen" ohne eigenen Fall

- `kategorie`: INFO
- `quelle`: `AGENTS.md` Hard Rule 3.6 (kuratierte Fall-Liste)
- `pfad`: `test/release-matrix.bats:60-62` · `test/mutations/78-release-matrix-unvollstaendig.sh`
- `befund`: Kein `# expect:` nennt diesen Test; Fall 78 färbt ihn faktisch mit rot, adressiert aber Test 1. Die Eigenschaft ist von Test 1 (exakter Mengenvergleich) bereits impliziert — der Test ist redundant statt ungedeckt. Anders als F-3, wo keine andere Zusage die Fläche trägt.
- `verifizierbar`: ja — `make mutate` listet ihn nicht; Fall 78 rötet ihn nebenbei.

### F-14 — `make help`: Spaltenbreite reicht für den neuen Target-Namen nicht

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `Makefile:44-45` (`printf "  %-14s %s\n"`) · `:77` (`release-artifacts`, 17 Zeichen)
- `befund`: Der neue Target-Name überschreitet die Spaltenbreite der `help`-Ausgabe; die Beschreibung rutscht für diese Zeile aus der Flucht.
- `verifizierbar`: ja — `make help`; kein Gate misst Formatierung.

## Negativbefunde

<!--
Eine Zeile pro betrachtetem Bereich. Ohne diesen Block ist "keine
Findings" nicht von "nicht geprüft" unterscheidbar (Modul 10
§Reviewer berichtet auch, was er nicht gefunden hat).
-->

- geprüft, ohne Befund: **`AGENTS.md` 3.2 (Lint-Suppression-Verbot).** `grep -rn 'shellcheck disable\|nolint'` über `.github/`, `Makefile`, `Dockerfile`, `test/`, `harness/`: 0 Treffer. Das in `067e928` entfernte `# shellcheck disable` ist real weg; die Verzweigung `:127-133` kommt ohne unquotierten Flag-String aus, also auch ohne Anlass zur Unterdrückung.
- geprüft, ohne Befund: **Byte-Identität des Default-Pfads (`Dockerfile:56-61`).** `ARG TARGET_OS=`/`ARG TARGET_ARCH=` mit leerem Default → `GOOS= GOARCH= go build`. Der `go`-Befehl behandelt eine **leere** Umgebungsvariable wie eine ungesetzte (`envOr`-Semantik: leerer Wert → Default aus dem Build-Kontext); ein Fall, in dem leer ≠ ungesetzt wirkt, ist in diesem Aufruf nicht erkennbar. Zusätzlich empirisch belegt (sha256 gegen den `git stash`-Vorstand identisch), und der Wächter `test/release-matrix.bats:80-96` sichert die Ursache ab (`build`-Recipe reicht keine Args durch), inkl. rot gesehenem Fall 80. Die Kombination aus textuellem Wächter **und** gemessener Byte-Gleichheit trägt; der textuelle Wächter allein täte es nicht.
- geprüft, ohne Befund: **`set -e`-Verhalten im Matrix-Recipe (`Makefile:79-91`).** `[ "$$os" = "windows" ] && ext=".exe"` bricht die Schleife nicht ab — in `dash` (`/bin/sh`) hermetisch gemessen: die fehlschlagende Bedingung ist nicht das letzte Glied der AND-Liste, `set -e` greift nicht. Trap-Führung je Iteration (`trap … EXIT` … `docker rm -f` … `trap - EXIT`) lässt keinen Container zurück, auch nicht beim Abbruch mitten in der Schleife.
- geprüft, ohne Befund: **`start-smoke` ist kein Gate über leerem Bereich.** Das Binary wird real gestartet; `out="$(…)"` unter `set -euo pipefail` bricht bei Exit ≠ 0 ab (Zuweisung übernimmt den Status der Kommando-Substitution), Usage geht laut `cmd/ai-harness-init/main.go:102-104` und `main_test.go:91` auf **stdout** mit Exit 0, beide Marker stehen real im Usage-Text. Eine „irgendeine Ausgabe + Exit 0"-Fassade fiele am Marker-Grep durch; ein Nicht-Ausführen des Binaries kann den Step nicht grün lassen. (Kopplungs-Lücke der Marker: F-10.)
- geprüft, ohne Befund: **MR-014 Setzung 4 (Pins).** Alle sechs Runner-Labels benannt, kein `-latest`; alle drei Actions per 40-stelligem Commit-SHA; `checkout` auf dem im Repo etablierten `fbc6f399…`. Nur die Kommentar-Granularität weicht ab (F-11).
- geprüft, ohne Befund: **MR-014 Setzung 2 (Sensor-Klassen).** Eigene Datei statt `ci.yml`-Erweiterung; `ci.yml` bleibt bei vier `ubuntu-24.04`-Jobs, `upstream-drift.yml` unberührt; `concurrency`-Gruppe eigen und `cancel-in-progress: false` mit benanntem Grund. Kein Release-Job läuft pro Push.
- geprüft, ohne Befund: **MR-014 Setzung 3 (`ci-lint` deckt den neuen Workflow).** `.d-check.yml`/actionlint greifen per Glob über `.github/workflows/`; `test/mutations/10-ci-workflow-syntax.sh` (`verify: ci-lint`) belegt die Zähne dieses Gates bereits generisch — ein eigener Fall für `release.yml` wäre Dopplung, kein zusätzlicher Nachweis.
- geprüft, ohne Befund: **Fail-closed-Kette des Workflows.** `if-no-files-found: error` beim Upload; `needs: start-smoke` vor `publish` (ein roter Plattform-Smoke verhindert die Veröffentlichung trotz `fail-fast: false`); `permissions` top-level `contents: read`, `contents: write` nur im `publish`-Job.
- geprüft, ohne Befund: **Mutations-Fälle 78–81 als Fälle.** Jeder trägt `# files:`/`# expect:`, jeder Anker ist im `Makefile` eindeutig (`--target build -t ai-harness-init:build .` einmalig; die Pflicht-Meldung im `release-artifacts`-Bereich einmalig), die `$`-Behandlung in Fall 81 ist escaped (SC2016-Lehre aus slice-040/042 eingehalten). `make mutate` 77 ok/0 mit je rot gesehenem eigenem Wächter ist damit plausibel gedeckt — die Lücke liegt nicht in den Fällen, sondern in der Wächter-Menge (F-2, F-3).
- geprüft, ohne Befund: **CR-Reihenfolge (Doc führt).** `5c4930b` (Lastenheft 0.13.0) liegt vor `dfca6c6`/`4219db9`/`067e928`; die Anforderung selbst ist unverändert, präzisiert wurde die Messmethode, und die Grenze steht benannt in `spec/lastenheft.md:267-276` statt als stille Auslassung — genau die LH-QA-01-Klasse, die der Slice §6 als Risiko führt. Inhaltlich einziger Befund: die Zeilenposition in der Historie (F-8).
- geprüft, ohne Befund: **Slice-Plan-Nachführung.** `§2`/`§3`/`§6` sind mit den Verortungs- und Probe-Entscheidungen nachgezogen; der Plan behauptet an keiner Stelle mehr, als die Commits liefern (`ci.yml`-Zeile aus der Plan-Tabelle entfernt statt stehen gelassen).
- geprüft, ohne Befund: **`ADR-0003`/LH-QA-03 (Docker-only).** `release-artifacts` ruft ausschließlich `docker`; keine Host-Toolchain, kein `actions/setup-go`; die sechs Builds laufen im selben gepinnten `GO_VERSION`-Image.
- geprüft, ohne Befund: **`2abda63` und `b39f7b6`** (nicht Slice-Gegenstand) — angesehen, kein Bezug zum Slice-Diff: die Korrektur betrifft die Reichweiten-Aussage des Drift-Jobs, das Benutzerhandbuch die Bauform-Achse; beide berühren `Dockerfile`/`Makefile`/`release.yml` nicht.
- **nicht geprüft (Rollen-Grenze):** DoD-Erfüllung als solche, Reproduzierbarkeits- und Byte-Identitäts-**Messungen** (real gelaufen, hier nur als gemeldete Sensor-Ausgabe verwendet), Closure-Notiz.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 4 |
| LOW | 5 |
| INFO | 4 |

## Verdikt

**NICHT KONFORM.**

**Merge-blockierend:** ja — F-1 (HIGH) macht den Upload-Pfad, den dieser Slice
liefern soll, zu einem sicheren Fehlschlag; F-2/F-3/F-4 sind drei Instanzen der
Hard-Rule-3.6-Klasse (Wächter misst Implementierung statt Eigenschaft · neuer
Wächter ohne Fall · Zusage breiter als Abdeckung), die den Vorgänger-Slice bereits
mehrfach getroffen hat; F-5 ist eine Konventions-Zusage, deren Wortlaut der Diff
nicht hält. LOW/INFO blockieren nicht.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
