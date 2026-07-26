# Verifier-Report slice-050 — Doku-Nachzug zum ersten Release (M5 Schritt 2)

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Rolle** | Verifier (Modul 11, [`modul-11-verification.md`](../../.harness/baseline/v3.5.2/regelwerk/modul-11-verification.md)) — frischer Kontext, getrennt von Implementation und Review |
| **Prüfachse** | **nicht** Stil/Qualität (Review-Achse), sondern: hält die **DoD-Behauptung**? „Behauptung ohne Bestätigung ist die häufigste Verifier-Lücke" |
| **Gegenstand** | [`slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md) §2 (DoD, 8 Punkte) · §3 (Plan) · §5 (Closure-Trigger) · §6 (Risiken) |
| **Range** | `63236d3..HEAD`, `HEAD` = `9326b2a` — **zwölf** Commits, davon **acht slice-eigen** (`813418c` `38b60ed` `0c31697` `a4dac1f` `321b849` `3780d21` `85e3c26` `9326b2a`) und **vier** Lastenheft-CR-/Korrektur-Commits nach `MR-015` (`30f0fcd` `614351e` `7314b7c` `9964041`) |
| **Git-externes Artefakt** | GitHub-Release `v0.1.0` — annotiertes Tag auf `0c31697`, Lauf `30193450074`, sechs Assets, Release-Text |
| **Review-Stand** | fünf Runden; Runde 5 **KONFORM** (0 HIGH, 0 MEDIUM, 4 LOW, 2 INFO), die vier LOW danach aufgelöst (`9326b2a` = T-1/T-2/T-3, `9964041` = T-4) |
| **Baseline** | Agents-Regelwerk `v3.5.2`, committet vendored (`make baseline-verify`: „v3.5.2 OK — 42 Dateien") |
| **Datum / Modell** | 2026-07-26 · Claude Opus 5 (1M context) |
| **Grenzen eingehalten** | Docker-only ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md)) — nur `make`-Targets, dazu lesende `git`/`gh`-Aufrufe. Kein Produktivcode, keine Doku außer diesem Report geändert; nichts committet. |

**Was ich selbst erhoben habe** (statt die Behauptungen nachzuerzählen):

- **Eigene** Suchmuster über [`README.md`](../../README.md) und `docs/user/` — vier Muster-Familien,
  bewusst *nicht* das §3-Kommando (dessen Allquantor in Runde 1 an der FAQ gebrochen ist).
- **Dreifacher Mengenvergleich** der Asset-Namen (Workflow-`matrix` ↔ Handbuch ↔ `gh release view`)
  maschinell, als Set-Gleichheit — nicht als Sichtprüfung.
- **Den getaggten Stand `v0.1.0` selbst gelesen** (`git show v0.1.0:…`), nicht nur `HEAD`.
- **Job-Zählung** des Release-Laufs und **Asset-Zählung** über die `gh`-API.
- **`make gates`** und **`make full-smoke`** selbst gefahren, beide Exit 0.
- **Jede Aussage des Release-Textes** gegen eine Quelle geprüft, inklusive seines Messbefehls.
- **Jeden der vier Lastenheft-Commits** einzeln gegen `MR-015` Setzung 2 und 3 gemessen.

---

## DoD Punkt für Punkt

| # | DoD-Punkt (§2, gekürzt) | Urteil | Beleg, den **ich** erhoben habe |
|---|---|---|---|
| 1 | Die vier gemessenen Falschaussagen sind weg; das §3-Kommando liefert keinen Treffer mehr, der einen fehlenden Release behauptet | **BESTÄTIGT** (Stand `HEAD`) | §3-Kommando: **ein** Treffer, Handbuch:4 — und der *bejaht* den Release. Dazu **vier eigene Muster-Familien** über [`README.md`](../../README.md) + `docs/user/` (beide Dateien): (A) `noch (nicht\|keine)\|derzeit (nicht\|kein)\|gibt es (noch )?(nicht\|keine)\|nicht verfügbar\|kein(e)? (fertige\|vorgefertigte\|Release\|Download\|Binar)` → **kein Treffer**; (B) Nur-Quellcode-Weg → 6 Treffer, **alle** ordnen den Bau als *zweiten* Weg ein; (C) `Entwicklungsstand\|M4\|Meilenstein\|unveröffentlicht\|prerelease\|geplant` → **kein Treffer**; (D) Versions-/Stand-Aussagen → alle auf `v0.1.0` bezogen. `docs/user/` enthält genau zwei Dateien, beide geprüft. |
| 2 | Download-Weg als **erster** Weg im Installations-Abschnitt, mit den **sechs Asset-Namen exakt aus der `matrix`** | **BESTÄTIGT** | Reihenfolge: Handbuch:77 „Weg A — fertiges Programm herunterladen (empfohlen)" **vor** :116 „Weg B — aus dem Quellcode bauen"; :75 nennt den Download ausdrücklich als empfohlen, Weg B bleibt erhalten. Namen: **Set-Gleichheit dreifach**, maschinell gerechnet — `matrix.include[].bin` in [`release.yml`](../../.github/workflows/release.yml):69–79 (6) **==** Handbuch-Tabelle :80–86 (6) **==** `gh release view v0.1.0 --json assets` (6). Symmetrische Differenz jeweils **leer**. |
| 3 | „Keine Zusage vor ihrem Beleg" ([`AGENTS.md`](../../AGENTS.md) §3.6); Gegenbeispiel: ein Leser der Doku **des getaggten Standes**, der keinen Download findet | **TEILWEISE** | *Haupt-Zusage hält:* kein Satz — weder auf `HEAD` noch im Tag — behauptet einen Release, den es nicht gibt; alle Aussagen sind auf `ab v0.1.0` bezogen; der Tag steht (`git tag` → `v0.1.0`). *Das eigene Gegenbeispiel ist im veröffentlichten Artefakt aber **rot**:* `git show v0.1.0:docs/user/benutzerhandbuch.md` → :486 „**Gibt es ein fertiges Download-Binary?** — *Derzeit nicht.*" und :524 „daher **keine Release-Versionsnummer**". Ein Leser des getaggten Standes, der über die FAQ oder den Anhang einsteigt, findet genau **keinen** Download. Behoben ist das erst in `a4dac1f`, also **nach** dem Tag. Näheres unter Abweichungen A-1. |
| 4 | Handbuch-Kopf `Software-Stand` von „Entwicklungsstand M4" auf den veröffentlichten Stand | **BESTÄTIGT** | Handbuch:3 `Handbuch-Version: 1.5`, :4 `**Software-Stand:** `v0.1.0` — erstes Release mit vorgefertigten Programmen für sechs Plattformen …`, :5 `Stand: 2026-07-26`. Gegenprobe: `grep -i "Entwicklungsstand\|M4"` über [`README.md`](../../README.md) + `docs/user/` → **kein Treffer**. §11-Historie trägt die Zeile `1.5`. |
| 5 | **Kein Commit DIESES Slice** ändert `spec/lastenheft.md`; geprüft über die volle Range bis Closure | **BESTÄTIGT** für `HEAD` = `9326b2a` — mit benannter Operationalisierungs-Lücke | Der **im DoD genannte** Befehl `git log --format='%h %s' 63236d3..HEAD -- spec/lastenheft.md` liefert **vier** Zeilen, alle mit `spec:`-Präfix (`9964041` `7314b7c` `614351e` `30f0fcd`). **Er misst die zugesagte Eigenschaft aber nur mittelbar** — er listet *alle* Commits, die die Datei berühren, und überlässt die Einordnung „Slice-Commit ja/nein" dem Leser, der das `spec:`-Präfix als Klassifikator nimmt. Ein Präfix ist eine Selbstauskunft, kein Messwert. Ich habe deshalb die **stärkere** Messung gefahren: `git log --name-only 63236d3..HEAD` über **alle zwölf** Commits — die acht slice-eigenen berühren `README.md`, `docs/user/`, `docs/plan/`, `docs/reviews/`, **keiner** `spec/`; die vier `spec:`-Commits ändern **ausschließlich** `spec/lastenheft.md` (`git show --stat`: 1 file changed, je Commit). Damit hält die Eigenschaft *unabhängig vom Präfix*. Einschränkung: die Range endet an `HEAD`; die noch ausstehenden Closure-Commits (Move nach `done/`, Closure-Notiz, Link-Reconciliation) sind **nicht** mitgemessen — der Punkt ist erst am Closure-Stand endgültig entscheidbar. `LH-QA-04` selbst ist im Diff `63236d3..HEAD` **inhaltlich** nur in der Messmethode berührt, und zwar ausschließlich durch die vier CR-Commits. |
| 6 | Tag `v0.1.0` gesetzt, `release`-Lauf grün über **alle acht Jobs**, **sechs** Assets — gezählt | **BESTÄTIGT** | `git tag` → `v0.1.0` (annotiert, zeigt auf `0c31697`). `gh run list --workflow=release.yml` → Lauf `30193450074`, `event: push`, `headBranch: v0.1.0`, `conclusion: success`. `gh run view 30193450074 --json jobs` → **Anzahl Jobs: 8**, **alle `success`**: `artifacts`, sechs `start-smoke`-Jobs (je einer pro Runner/Binary: `ubuntu-24.04`, `ubuntu-24.04-arm`, `macos-26-intel`, `macos-26`, `windows-2025`, `windows-11-arm`), `publish`. `gh release view v0.1.0 --json assets` → **6** Assets, alle `state: uploaded`, `isDraft: false`, `isPrerelease: false`, `publishedAt: 2026-07-26T07:50:44Z`. |
| 7 | `make gates` grün | **BESTÄTIGT** — selbst gefahren | `make gates` → **Exit 0**. Alle acht Prerequisites aus [`Makefile`](../../Makefile):222 real gelaufen: `baseline-verify` („v3.5.2 OK — 42 Dateien, netzlos"), `docs-check` (d-check `@sha256:fede3d0…`, **192 Datei(en) geprüft, 0 Befund(e)**), `lint`, `build`, `test` (bats 107 Tests + `go test ./...` über fünf Pakete, alle `ok`), `shell-lint` (shellcheck), `ci-lint` (actionlint), `record-gates`. |
| 8 | Closure-Notiz mit Steering-Loop-Lerneintrag | **NOCH NICHT FÄLLIG — ausdrücklich kein Befund** | Der Slice liegt in `in-progress/`; §7 trägt noch den Template-Kommentar „Erst nach Abschluss füllen". Die Notiz entsteht per Definition **nach** dem `git mv` nach `done/` (§5). Ein „nicht erfüllt" wäre hier eine Fehlmessung des Lifecycles, kein Befund. **Erwartung an den Closure-Schritt:** die Notiz muss A-1 (Doku-Defekte im veröffentlichten Tag) und den Steering-Loop-Eintrag tragen; die Roadmap-Zeile M5 steht heute korrekt noch auf **offen** (Roadmap:56) — das Umsetzen auf *erreicht* ist laut §3 der Closure-Schritt. |

**Zusammenfassung der Punkte:** 6 × BESTÄTIGT · 1 × TEILWEISE (Punkt 3) · 1 × nicht fällig (Punkt 8) ·
0 × WIDERLEGT.

---

## Sensor-Entscheidungen

**Die Auslassungs-Begründung des Implementers** — „reiner Doku-Slice — kein Wächter neu/geändert,
Emit-Pfad unberührt" für `make mutate`, `make smoke`, `make full-smoke` — habe ich **gegen den
realen Diff** geprüft, nicht gegen die Prosa.

| Prüfung | Ergebnis |
|---|---|
| `git diff --name-only 63236d3..HEAD` | **zehn** Dateien, **Endung `.md` ausnahmslos** (Zählung über `sed 's/.*\.//' \| sort \| uniq -c` → `10 md`) |
| Trifft die Range einen Code-, Guard-, Emit- oder Workflow-Pfad? | `grep -E "\.go$\|\.sh$\|Makefile\|\.mk$\|internal/\|cmd/\|test/\|\.yml$"` über die Dateiliste → **KEIN Treffer**. Insbesondere unberührt: `internal/emit/templates/**` (der Emit-Pfad), `.claude/hooks/**` und `harness/tools/**` (die Wächter), `.d-check.yml`, `.github/workflows/**`, `.harness/baseline/**` |
| Ist eine der zehn `.md`-Dateien selbst emittiertes Material? | Nein — es sind [`README.md`](../../README.md), [`docs/user/benutzerhandbuch.md`](../user/benutzerhandbuch.md), `spec/lastenheft.md`, die Roadmap, die Slice-Datei und fünf Review-Reports. Keine liegt unter `internal/emit/templates/` oder `.harness/baseline/` |

**Urteil: die Begründung trägt.** `make mutate` färbt gelistete Wächter rot und prüft, ob die Gates
das melden — kein Wächter und keine Gate-Konfiguration ist in der Range angefasst. `make smoke` und
`make full-smoke` prüfen den Emit-/Bootstrap-Pfad — auch der ist unberührt. Die Auslassung ist damit
**kein** „Sensor übersprungen, weil unbequem", sondern eine an der Datei-Menge belegte Nicht-Betroffenheit.

**Zusätzliche Abdeckung, die ich unabhängig festgestellt habe:** die CI hat die ausgelassenen Sensoren
auf zwei Ständen dieses Slice real gefahren — Lauf `30193505981` auf `0c31697` und Lauf `30196597680`
auf `3780d21`, jeweils vier Jobs `gates` · `smoke` · `full-smoke` · `mutate`, **alle `success`**.

**Die Lücke, die dennoch blieb, und wie ich sie geschlossen habe.** `origin/main` steht auf `3780d21`
(`git ls-remote origin refs/heads/main` bestätigt: identisch mit dem realen Remote) — die drei
jüngsten Commits `85e3c26`, `9964041`, `9326b2a` sind **nicht gepusht**, also hat **kein CI-Lauf den
Stand `HEAD` je gesehen**. Das Delta ist zwar wieder `.md`-only (Slice-Datei, zwei Review-Reports,
`spec/lastenheft.md`), aber „wahrscheinlich folgenlos" ist keine Messung. Ich habe deshalb selbst
gefahren:

| Sensor | Entscheidung | Ergebnis auf `HEAD` = `9326b2a` |
|---|---|---|
| `make gates` | **gefahren** — DoD-Punkt 7 verlangt ihn, und er deckt den ungepushten Stand ab | **Exit 0**, d-check 192 Datei(en) / 0 Befund(e) |
| `make full-smoke` | **gefahren** — der Happy-Path-Beweis zu `LH-FA-01`; er ist der teuerste der drei und deckt `make smoke` in der Sache mit ab (Bootstrap + emittiertes `make gates` real). Damit ist der Stand, den die CI nie gesehen hat, mit dem stärksten verfügbaren Sensor belegt | **Exit 0** — zehn OK-Zeilen: Bootstrap grün out-of-the-box, sprachloser Init doc-only grün, Gate-Nachweis-Kreis, Command-Guard greift, Guard-Boden + `blocked/`-Union, `add-lang` wiederholbar (Mono-Repo), zweite Sprache `cpp`, Arch-Achse `hexslice`, Arch-Gate konditional **mit rot gesehenem Gegenbeispiel** (verbotener Domain→Adapter-Import färbt a-check rot), Idempotenz |
| `make smoke` | **nicht gefahren**, begründet | Echte Teilmenge von `full-smoke` in dem, was hier zu belegen war (Emit + emittiertes `docs-check`); `full-smoke` lief grün. Ein zweiter Lauf hätte keine Aussage hinzugefügt, die `full-smoke` nicht schon trägt |
| `make mutate` | **nicht gefahren**, begründet | Sein Prüfgegenstand — die Wächter-Dateien und ihre Rot-Färbbarkeit — ist in der **gesamten** Range nachweislich unberührt (Tabelle oben), und die CI hat ihn auf `0c31697` und `3780d21` grün gefahren. Ein Lauf hier prüfte eine Fläche, die dieser Slice nicht anfasst; die Kosten (ein voller `make test`-Zyklus je Mutation) stünden gegen null Erkenntnisgewinn |

---

## Prüfung des Release-Textes (git-extern, viermal überarbeitet)

Gelesen mit `gh release view v0.1.0 --json body`. **Jede** Aussage einzeln gegen eine Quelle:

| Aussage im Release-Text | Quelle, die ich geprüft habe | Urteil |
|---|---|---|
| „Erstes Release: vorgefertigte Programme für **sechs** Plattformen (Linux · macOS · Windows × amd64 · arm64)" | `gh release view v0.1.0 --json assets` → 6 Assets; Namen zeichengleich mit `matrix.include[].bin` ([`release.yml`](../../.github/workflows/release.yml):69–79); Set-Gleichheit maschinell | **trifft zu** |
| „Der vollständige Durchlauf (Repo aufsetzen, Prüfungen grün) läuft auf **linux/amd64**." | [`ci.yml`](../../.github/workflows/ci.yml):58–62 — Job `full-smoke`, **ein** Job, `runs-on: ubuntu-24.04`, **keine** Matrix | **trifft zu** |
| „Für alle sechs ausgelieferten Dateien ist geprüft, dass das Programm auf seiner Plattform **startet** — mehr nicht." | `gh run view 30193450074 --json jobs` → sechs `start-smoke`-Jobs, alle `success`; [`release.yml`](../../.github/workflows/release.yml):93–98 ruft ausschließlich `harness/tools/start-smoke.sh`; `publish` (:113–116) lädt genau das Artefakt hoch, das die sechs geprüft haben. Kein `full-smoke`-Schritt im Release-Workflow | **trifft zu**, inklusive des einschränkenden „mehr nicht" |
| „Die sechs Binaries sind das Produkt dieses Release und **von allem Folgenden nicht betroffen**." | `git diff --name-only v0.1.0 HEAD` → **zehn Dateien, ausnahmslos `.md`**; Gegenprobe `grep -v '\.md$'` → **KEINE**. Kein Go-Code, kein Workflow, kein Makefile seit dem Tag | **trifft zu** |
| „Die mitgelieferte Dokumentation dieses Tags ist an mehreren Stellen **überholt** — die Nutzer-Dokumentation ebenso wie das Lastenheft. Maßgeblich ist der Stand auf `main`." | selbst gelesen: `git show v0.1.0:docs/user/benutzerhandbuch.md` und `git show v0.1.0:spec/lastenheft.md` gegen die `HEAD`-Fassungen | **trifft zu** — und es ist die **richtige** Richtung: der Text sagt weniger zu, als der Tag hergibt, statt mehr |
| Messbefehl `git diff v0.1.0 origin/main -- '*.md'` | verbatim gefahren: acht Dateien, 1295 Insertions / 18 Deletions, darunter [`README.md`](../../README.md), [`docs/user/benutzerhandbuch.md`](../user/benutzerhandbuch.md) (32 Zeilen) und `spec/lastenheft.md` (23 Zeilen) | **läuft und trägt.** Die Pathspec `'*.md'` deckt die Aussage („die Dokumentation") vollständig — die Verengung auf zwei Dateien, die Runde 5 als T-3 fand, ist gezogen |
| „die FAQ antwortet noch ‚Gibt es ein fertiges Download-Binary? — Derzeit nicht'" | `git show v0.1.0:…benutzerhandbuch.md`:485–486 — **wörtlich so** | **trifft zu** |
| „der Anhang sagt ‚keine Release-Versionsnummer'" | ebd. :524 — **wörtlich so** | **trifft zu** |
| „der Kasten im Installations-Abschnitt sagt den vollständigen Durchlauf ‚bei jedem Release auf Linux' zu" | ebd. :60–65 — **wörtlich so**; real läuft `full-smoke` in [`ci.yml`](../../.github/workflows/ci.yml) am Push, nicht am Release | **trifft zu** |
| „`spec/lastenheft.md` steht im Tag noch auf **0.13.0** mit derselben undifferenzierten Zusage ‚linux: Voll-Smoke'" | `git show v0.1.0:spec/lastenheft.md`:3 → `**Version:** 0.13.0`; :263 → „**linux:** **Voll-Smoke**" | **trifft zu** |
| „(real: pro Quellcode-Änderung, nur linux/amd64 …; auf `main` als **0.14.1** präzisiert)" | `spec/lastenheft.md`:3 auf `HEAD` → `0.14.1`; :263 → „**linux/amd64:** **Voll-Smoke**". `origin/main` (= `3780d21`) trägt `0.14.1` ebenfalls — die Aussage hält auch für den Stand, den ein externer Leser sieht | **trifft zu** |
| „im Download-Weg fehlt ein `mkdir -p` vor dem `mv` nach `~/.local/bin`, während das Ergebnis die Aufrufbarkeit **unbedingt** zusagt" | `git show v0.1.0:…benutzerhandbuch.md`:86–91 → `chmod +x` / `mv …` **ohne** `mkdir -p`; das „Ergebnis" dort unbedingt formuliert. Auf `HEAD` :96 `mkdir -p ~/.local/bin` + Suchpfad-Hinweis + bedingtes Ergebnis | **trifft zu** |
| „**Full Changelog**: …/commits/v0.1.0" | automatisch erzeugte Zeile | trifft zu |

**Gesamtergebnis Release-Text: keine Aussage geht weiter als ihr Beleg.** Bemerkenswert für die
§3.6-Achse: der Text nennt die Defekte des eigenen Tags **von sich aus**, mit Messbefehl statt
Aufzählung — das ist die Form, die `AGENTS.md` §3.6 verlangt, angewandt auf ein Artefakt, das sich
nicht mehr korrigieren lässt.

---

## `MR-015`-Konformität der vier Lastenheft-Commits

Geprüft gegen [`harness/conventions.md`](../../harness/conventions.md) `MR-015` Setzung 2 (eigener
Commit, ausschließlich diese Datei) und Setzung 3 (Verweis-Spalte = annehmende Instanz,
Änderungs-Spalte = Anlass). Cutoff der Setzung: ab dem Commit, der `MR-015` trägt — alle vier liegen
danach, sind also erfasst.

| Commit | Setzung 2 — eigener Commit, nur `spec/lastenheft.md` | Setzung 3 — Spalten-Zuordnung | Urteil |
|---|---|---|---|
| `30f0fcd` — CR 0.13.0 → **0.14.0** | `git show --stat` → **1 file changed**, `spec/lastenheft.md`. Commit-Body nennt die annehmende Instanz („Nutzer-Entscheidung 2026-07-26, wörtlich …") und den Anlass („slice-050-Review Runde 2, Befund N-2") getrennt | Zeile `0.14.0`: **Verweis-Spalte** = „Nutzer-Entscheidung 2026-07-26"; **Änderungs-Spalte** endet auf „Anlass: slice-050-Review N-2" (maschinell über Spalten-Split geprüft) | **konform** |
| `614351e` — Korrektur 0.14.0 → **0.14.1** | `git show --stat` → **1 file changed**, 9 Insertions / 5 Deletions, nur `spec/lastenheft.md` | Zeile `0.14.1`: **Verweis-Spalte** = „Nutzer-Entscheidung 2026-07-26"; **Änderungs-Spalte** endet auf „Anlass: slice-050-Review Runde 3, R-1/R-3". Der Commit zieht ausdrücklich den in Runde 3 gefundenen Spalten-Fehler (R-3: Anlass stand im Verweis) | **konform** |
| `7314b7c` — Historie-Zeilen 0.14.0/0.14.1 präzisiert | `git show --stat` → **1 file changed**, 2 Insertions / 2 Deletions, nur `spec/lastenheft.md` | Beide Zeilen behalten ihre Spalten-Zuordnung (nachgemessen nach dem Edit, nicht angenommen) | **konform**; kein Versions-Bump — bewusst, s. Runde-5-INFO-2 |
| `9964041` — Klammer-Zusatz der 0.14.0-Zeile | `git show --stat` → **1 file changed**, 1 Insertion / 1 Deletion, nur `spec/lastenheft.md` | Spalten unverändert; der Zusatz sagt jetzt, was er tut („ordnet ein", „wird **nicht** revidiert") statt sich im Vollzug zu widerlegen | **konform** |

**Setzung 2 hat hier aber eine Teil-Bedingung, die nicht erfüllt *werden konnte*.** Ihr Wortlaut
verlangt, der CR-Commit liege „**vor** dem `open → in-progress`-Move des umsetzenden Slice". Alle
vier liegen **nach** `38b60ed` (slice-050 `open → in-progress`). Das ist **kein Verstoß**, sondern
eine Lücke der Setzung, und ich stufe sie so ein:

- slice-050 ist **nicht** der „umsetzende Slice" dieser CRs — er setzt nichts aus ihnen um; seine DoD
  hält `spec/lastenheft.md` ausdrücklich unberührt, und das habe ich unter DoD-Punkt 5 unabhängig
  belegt. Die Änderung ist in sich abgeschlossen: das Lastenheft **ist** hier das Artefakt, nicht die
  Vorgabe für ein Artefakt.
- Ein umsetzender Slice existiert nicht — `30f0fcd` sagt das in seinem Body selbst („die Präzisierung
  beschreibt, was bereits läuft").
- Die Reihenfolge-Klausel adressiert den Fall „Vertragsänderung *vor* ihrer Implementierung". Der Fall
  hier ist ein anderer: **ein CR entsteht aus dem Review eines laufenden Slice**. Dafür hat `MR-015`
  keine Regel — die Substanz der Setzung (Entscheidung getrennt von Umsetzung, am Commit ablesbar)
  ist gewahrt, ihre Ordnungs-Klausel greift ins Leere.

Das ist ein **Steering-Loop-Kandidat**, kein Befund gegen diesen Slice (Abweichung A-4).

---

## Abweichungen

**A-1 — Der veröffentlichte Tag trägt eine Doku, die sich selbst widerspricht.** *(materiell, nicht
mehr reparierbar; DoD-Punkt 3.)* `v0.1.0` zeigt auf `0c31697`. Dort führt §2 den Download-Weg mit
allen sechs Dateien, während die FAQ (:486) „Derzeit nicht" antwortet und der Anhang (:524) „keine
Release-Versionsnummer" behauptet. Genau das ist das in DoD-Punkt 3 **selbst benannte**
Gegenbeispiel, und es ist im veröffentlichten Artefakt eingetreten. Ursache ist ein realer
Plan-Defekt: §3 behauptete „Weitere Stellen gibt es nicht" als Allquantor auf Basis eines
Suchmusters, das die FAQ-Formulierung unter keiner Variante treffen konnte — der Review fand sie erst
in Runde 1, **nach** dem Tag-Push. **Mildernd und belegt:** die sechs Binaries sind nicht betroffen
(`git diff --name-only v0.1.0 HEAD` → nur `.md`), und der Release-Text nennt die Defekte von sich aus
samt Messbefehl. **Erwartung:** gehört in die Closure-Notiz und als Kandidat in die Roadmap (`v0.1.1`
oder ein Sensor, der die Doku-Wahrheit vor einem Tag misst statt danach).

**A-2 — Drei Commits sind nicht gepusht; kein CI-Lauf hat `HEAD` gesehen.** `origin/main` =
`3780d21` (gegen `git ls-remote` verifiziert), `HEAD` = `9326b2a`. Betroffen: `85e3c26`, `9964041`,
`9326b2a` — Delta ausschließlich `.md`. Folgen: (a) die CI-Sensoren `smoke`/`mutate`/`full-smoke`
decken den Endstand nicht — **von mir durch eigene `make gates` + `make full-smoke`-Läufe auf `HEAD`
geschlossen** (beide Exit 0); (b) der Messbefehl im Release-Text löst gegen `origin/main` auf und
zeigt deshalb den Stand `3780d21`. Materiell folgenlos: alle inhaltlichen Doku-Korrekturen (FAQ,
Anhang, Kasten, `mkdir -p`) liegen in `a4dac1f` und damit **vor** `3780d21`, und die
Lastenheft-Version ist dort schon `0.14.1`. Der Push gehört vor die Closure.

**A-3 — Der Messbefehl aus DoD-Punkt 5 misst die zugesagte Eigenschaft nur mittelbar.** Er listet
alle Commits, die `spec/lastenheft.md` berühren, und lässt die entscheidende Unterscheidung
(„Slice-Commit oder Nutzer-Entscheidung?") am `spec:`-Präfix hängen — einer Selbstauskunft der
Commit-Message. Ein `impl:`-Commit, der sich `spec:` nennt, bliebe unsichtbar. Die Eigenschaft
**hält** (mit `--name-only` über alle zwölf Commits unabhängig belegt), aber der Befehl ist die
schwächere Operationalisierung. Modul 11 §„Fitness Function ohne Standard-Tool" beschreibt genau
diesen Schritt: `git log --name-only 63236d3..HEAD` und die Prüfung „ändert ein Commit
`spec/lastenheft.md` **gemeinsam mit** anderen Dateien?" ist mechanisierbar — und `MR-015`
§Durchsetzung sagt selbst, dass dieser Sensor nicht gebaut ist. Steering-Loop-Kandidat.

**A-4 — `MR-015` Setzung 2 hat keine Regel für CRs, die aus dem Review eines laufenden Slice
entstehen.** Ihre Ordnungs-Klausel („vor dem `open → in-progress`-Move des umsetzenden Slice") ist
für alle vier Commits leer, weil kein umsetzender Slice existiert. Substanz gewahrt, Klausel
unanwendbar — Formulierung nachziehen oder den Fall ausdrücklich ausnehmen. Steering-Loop-Kandidat.

**A-5 — Roadmap-M5 steht noch auf „offen".** Roadmap:56. Das ist **korrekt** — §3 weist die
Fortschreibung ausdrücklich dem Closure-Schritt zu. Hier nur als offener Punkt für die Closure
notiert, nicht als Befund.

---

## Gesamt-Urteil

**DoD TEILWEISE BESTÄTIGT.**

Sieben der acht DoD-Punkte sind erfüllt bzw. nicht fällig, und zwar mit Belegen, die ich unabhängig
erhoben habe — eigene Suchmuster statt des Plan-Kommandos, maschinelle Set-Gleichheit statt
Sichtprüfung, eigene Job- und Asset-Zählung, eigene Gate-Läufe. Der Release-Text hält jeder seiner
Aussagen stand, inklusive seines Messbefehls. Die vier Lastenheft-Commits sind `MR-015`-konform.

**Punkt 3 ist TEILWEISE**, und zwar aus einem Grund, den nur diese Prüfschicht sieht: die
DoD-Behauptung selbst hat ihr Gegenbeispiel benannt, und das Gegenbeispiel ist im **veröffentlichten**
Artefakt eingetreten. Der Tag trägt eine FAQ und einen Anhang, die den eigenen Release verneinen. Das
ist keine Review-Frage (der Diff gegen den Plan ist sauber) und kein Test-Befund — es ist die
Verifier-Klasse: Differenz zwischen DoD-Punkt und tatsächlichem Artefakt-Stand.

**Kein Punkt ist WIDERLEGT.** Die Closure ist aus Verifier-Sicht möglich, sobald drei Dinge stehen:
(1) A-2 aufgelöst — die drei Commits gepusht, damit die CI-Sensoren den Endstand decken; (2) die
Closure-Notiz trägt A-1 als Lerneintrag **und** den Steering-Loop-Eintrag zu A-3/A-4; (3) DoD-Punkt 5
wird am tatsächlichen Closure-Stand nachgemessen, nicht an `9326b2a` — die Closure-Commits liegen
außerhalb meiner Range.
