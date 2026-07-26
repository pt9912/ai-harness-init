# Review-Report: slice-050 — 2026-07-26

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + aktive ADRs + Hard Rules +
Konventionen** (Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung
(Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Gegenstand:** slice-050 „Doku-Nachzug zum ersten Release (M5 Schritt 2)", Commit-Range
`63236d3..HEAD` — drei Commits: `813418c` (Plan geschnitten), `38b60ed` (reiner
Lifecycle-Move `open → in-progress`, 0 Insertions/0 Deletions), `0c31697` (Implementation:
`README.md` 11 Zeilen · `docs/user/benutzerhandbuch.md` 56 Zeilen ·
`docs/plan/planning/in-progress/roadmap.md` 4 Zeilen). Der Tag `v0.1.0` zeigt auf `0c31697`
(`git rev-list -n1 v0.1.0` → `0c31697e…`), das Release ist veröffentlicht und trägt sechs
Assets.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26 · **Frischer Kontext**, getrennt von
Implementation und Verifikation.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf
nicht reproduzierbar):

- Slice-Plan: [`in-progress/slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md)
  (§1 Ziel, §2 DoD, §3 Plan, §4 Trigger, §5 Closure, §6 Risiken)
- berührte `LH-*`-IDs: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
  (samt §*Grenze der Messmethode*), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- aktive ADRs: keine im Diff geändert; mittelbar berührt
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (native Binaries, Docker-only)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules 3.1–3.6) — vollständig gelesen
- Konventionen: [`harness/conventions.md`](../../harness/conventions.md) — `MR-014`, `MR-015`
- **Vorherige Findings am gleichen Modul (Pflicht-Punkt 5):** die vier slice-049-Runden
  ([Runde 1](2026-07-26-slice-049-impl-review.md), [Runde 2](2026-07-26-slice-049-impl-review-runde-2.md),
  [Runde 3](2026-07-26-slice-049-impl-review-runde-3.md), [Runde 4](2026-07-26-slice-049-impl-review-runde-4.md))
  — dominante Klasse: **„Zusage weiter als Abdeckung"** ([`AGENTS.md`](../../AGENTS.md) §3.6),
  viermal in Prosa-Ist-Aussagen; dazu Runde-1-F-3 (Move-Commit mit hängenden Inbound-Links)
- Rollen-Vertrag: `.harness/skills/reviewer.md`, <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
  `.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md` (beide vollständig gelesen)

**Eigene Sensoren (lesend, Docker-only nach [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)):**
`make docs-check` (d-check: 187 Datei(en), 0 Befund(e)) · `make baseline-verify`
(„v3.5.2 OK — 42 Dateien") · `git show`/`git diff --stat`/`grep -n`/`sed -n` ·
`gh release view v0.1.0` · `gh run view 30193450074` (release) und `30193450047` (ci auf dem
Tag). **Nicht** gefahren: `make mutate`, `make gates`, `make test` (mutierend bzw.
verifizierende Rolle).

---

## Beurteilung der beiden ausdrücklich gestellten Fragen

**(1) Ist der über den Plan hinausgehende Kasten „Was wo geprüft wird" gerechtfertigt?**
**Ja, dem Grunde nach** — er ist keine unbelegte Scope-Ausweitung, sondern der einzige Ort,
an dem die neu beworbene Windows-/macOS-Auslieferung ihre Messgrenze mitliefert. Die DoD
verlangt „Keine Zusage vor ihrem Beleg" (§2, [`AGENTS.md`](../../AGENTS.md) §3.6), §6 benennt
die Doku-Überklage als Hauptrisiko, und §6 verbietet Prozess-Vokabular in `docs/user/` — der
Kasten hält alle drei ein (keine Slice-/Welle-ID, keine Gate-Namen, reine Nutzer-Sprache).
Die Herabstufung für macOS/Windows gibt [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
§*Grenze der Messmethode* korrekt wieder (Start-Smoke ≠ Bootstrap-Durchlauf; Begründung
„keine Linux-Container" deckt beide Runner-Fälle der Anforderung).
**Aber:** die **Linux-Hälfte** desselben Kastens trägt genau die Überklage, die er verhindern
soll — F-3 und F-4.

**(2) Bleibt Weg B (Bau aus Quelle) korrekt und vollständig?** **Ja** — Klonen,
`make artifact DEST=./bin`, `./bin/ai-harness-init --help`, `DEST`-Pflichthinweis stehen
unverändert und vollständig ([`benutzerhandbuch.md`](../user/benutzerhandbuch.md):107–136);
inhaltlich änderte sich nur der Schlusssatz des Ergebnis-Absatzes (F-6).

---

## Findings

### F-1 — Die FAQ des veröffentlichten Handbuchs verneint den Release, den derselbe Commit bewirbt

- `kategorie`: HIGH
- `quelle`: Hard Rule 3.6 ([`AGENTS.md`](../../AGENTS.md) §3.6) · Slice-Plan §1 Ziel
  („sagen die Wahrheit über den Auslieferungsweg") · §3 Ist-Messung
- `pfad`: `docs/user/benutzerhandbuch.md:485–486` (im Tag: `git show v0.1.0:docs/user/benutzerhandbuch.md`, Zeile 486)
- `befund`: §8 FAQ antwortet unverändert **„Gibt es ein fertiges Download-Binary? — Derzeit
  nicht. Sie bauen das Programm einmalig aus dem Quellcode"**, während §2 desselben Dokuments
  sechs Download-Assets als empfohlenen Weg führt und `gh release view v0.1.0` sechs Assets
  meldet. Der Plan hatte in §3 gemessen: „Ergebnis: **vier** Treffer … **Weitere Stellen gibt
  es nicht**" — das dort protokollierte Kommando
  (`grep -n "Fertige Binaries\|vorgefertigte\|Entwicklungsstand M4\|noch keine" …`) kann diese
  Stelle unter keiner Formulierung treffen, weil keiner der vier Suchbegriffe in ihr vorkommt.
  Die Allquantor-Aussage „weitere Stellen gibt es nicht" ist damit ungeprüft (dieselbe Klasse
  wie slice-049 F-1/F-4/R-1: Ist-Behauptung breiter als ihre Messung); das rot färbende
  Gegenbeispiel, das die DoD selbst benennt („ein Leser, der die Doku des getaggten Standes
  liest und keinen Download findet"), tritt an dieser Stelle real ein.
- `verifizierbar`: ja — `git show v0.1.0:docs/user/benutzerhandbuch.md | grep -n "Derzeit nicht"`
  liefert Zeile 486 im veröffentlichten Stand; kein Gate deckt es (`make docs-check` prüft
  Verweise/Anker, keine Aussagen-Konsistenz), der Nachweis ist statisch.

### F-2 — Der Anhang sagt „keine Release-Versionsnummer", während der Kopf `v0.1.0` als Software-Stand führt

- `kategorie`: MEDIUM
- `quelle`: Hard Rule 3.6 ([`AGENTS.md`](../../AGENTS.md) §3.6) · Slice-Plan §1 Ziel
- `pfad`: `docs/user/benutzerhandbuch.md:524`
- `befund`: §10 „Grenzen und Hinweise" führt weiterhin „Es gibt **kein** eingecheckt
  vorliegendes Binary und kein `run`-Ziel; Sie bauen das Werkzeug aus dem Quellcode (daher
  **keine Release-Versionsnummer** — maßgeblich ist der Quellcode-Stand des Repos)".
  Derselbe Commit `0c31697` schreibt in Zeile 4 „**Software-Stand:** `v0.1.0`" — das Dokument
  widerspricht sich innerhalb einer Datei, und die im Anhang genannte Begründung („daher
  keine Versionsnummer") ist mit dem Tag hinfällig. Auch diese Stelle liegt außerhalb der
  Reichweite des in §3 protokollierten Such-Kommandos.
- `verifizierbar`: ja — `git show v0.1.0:docs/user/benutzerhandbuch.md | sed -n '4p;524p'`
  zeigt beide Sätze im selben veröffentlichten Stand; kein Gate deckt es.

### F-3 — Der Ehrlichkeits-Kasten schreibt dem Release einen Voll-Durchlauf zu, den der Release-Workflow nicht fährt

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) §Messmethode ·
  Hard Rule 3.6 ([`AGENTS.md`](../../AGENTS.md) §3.6)
- `pfad`: `docs/user/benutzerhandbuch.md:61–62` („Der vollständige Durchlauf (Repo aufsetzen,
  Prüfungen grün) wird **bei jedem Release** auf **Linux** gefahren")
- `befund`: [`.github/workflows/release.yml`](../../.github/workflows/release.yml) — der
  einzige tag-getriebene Workflow — enthält **keinen** Voll-Smoke: seine acht Jobs sind
  `artifacts`, sechsmal `start-smoke` (auf **allen** sechs Runnern derselbe Aufruf
  `harness/tools/start-smoke.sh`, auch auf den beiden Linux-Runnern) und `publish`; `publish`
  hängt allein an `start-smoke`. Der Voll-Durchlauf lebt in
  [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml) (Job `full-smoke`, pro Push)
  und ist keine Vorbedingung der Veröffentlichung. Am ersten Release gemessen: `publish`
  endete 2026-07-26T07:50:46Z, der `full-smoke`-Job des zugehörigen ci-Laufs erst
  07:51:02Z — das Release war 16 Sekunden **vor** dem Ende des Durchlaufs veröffentlicht, den
  der Kasten dem Release zuschreibt. Ein roter `full-smoke` hätte die Veröffentlichung nicht
  aufgehalten.
- `verifizierbar`: ja — `gh run view 30193450074 --json jobs` (Release: acht Jobs, kein
  full-smoke) gegen `gh run view 30193450047 --json jobs` (ci auf dem Tag, `full-smoke`
  `completedAt` 07:51:02Z); strukturell zusätzlich `publish.needs: [start-smoke]` in
  `release.yml`.

### F-4 — Der Kasten trennt nach Betriebssystem, das Angebot direkt darunter nach Architektur

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) §Grenze der
  Messmethode · Hard Rule 3.6 ([`AGENTS.md`](../../AGENTS.md) §3.6)
- `pfad`: `docs/user/benutzerhandbuch.md:61–65` gegen `docs/user/benutzerhandbuch.md:80`
  (Tabellenzeile „Linux, ARM | `ai-harness-init-linux-arm64`")
- `befund`: Der Kasten sagt den vollständigen Durchlauf pauschal „auf **Linux**" zu und stellt
  ihm nur macOS und Windows als start-geprüft gegenüber. Gemessen läuft `make full-smoke`
  ausschließlich auf `ubuntu-24.04` (amd64, [`ci.yml`](../../.github/workflows/ci.yml) Job
  `full-smoke`); das in der Tabelle 19 Zeilen später angebotene Asset
  `ai-harness-init-linux-arm64` erhält auf `ubuntu-24.04-arm` denselben **Start**-Smoke wie
  die macOS-/Windows-Assets. Ein Leser mit Linux/ARM ordnet sich der Zeile zu, die volle
  Abdeckung zusagt, obwohl für seine Datei nur „das Binary läuft" belegt ist — genau die
  Unterscheidung, für die der Kasten existiert.
- `verifizierbar`: ja — `grep -n "runs-on" .github/workflows/ci.yml` (viermal `ubuntu-24.04`,
  kein arm-Runner) gegen die `matrix`-Zeile `runner: ubuntu-24.04-arm` in `release.yml:71`.

### F-5 — Weg A macht `~/.local/bin` zur Voraussetzung, sagt das Ergebnis aber unbedingt zu

- `kategorie`: LOW
- `quelle`: Maintainability (Nutzer-Doku-Treue) · Hard Rule 3.6 ([`AGENTS.md`](../../AGENTS.md) §3.6)
- `pfad`: `docs/user/benutzerhandbuch.md:86–91` und `:105`
- `befund`: Schritt 2 schreibt `mv ai-harness-init-linux-amd64 ~/.local/bin/ai-harness-init`
  ohne Hinweis darauf, dass das Zielverzeichnis existieren und im Suchpfad liegen muss; der
  Ergebnis-Absatz sagt danach unbedingt „Das Programm ist unter dem kurzen Namen
  `ai-harness-init` aufrufbar". Auf einem Konto ohne `~/.local/bin` bricht der `mv` mit „No
  such file or directory" ab, auf macOS liegt das Verzeichnis auch bei Existenz nicht im
  Standard-`PATH`, sodass Schritt 3 (`ai-harness-init --help`) mit „command not found"
  endet — während Weg B für denselben Schritt korrekt „bei Bedarf … an eine Stelle auf Ihrem
  Pfad" formuliert.
- `verifizierbar`: nein — kein Gate fährt Nutzer-Doku-Schritte nach; der Befund ist am
  Wortlaut und am Standard-`PATH` der Zielsysteme belegbar, nicht durch einen Repo-Lauf.

### F-6 — Weg-B-Leser erfahren die Kurznamen-Konvention des Handbuchs nicht mehr

- `kategorie`: LOW
- `quelle`: Maintainability (Nutzer-Doku-Treue) · Slice-Plan §2 („Der Bau aus Quelle bleibt
  **erhalten** (kein Ersatz)")
- `pfad`: `docs/user/benutzerhandbuch.md:105` gegen `:134`
- `befund`: Der Satz „Das Handbuch verwendet ab hier den kurzen Aufruf `ai-harness-init`"
  stand vor dem Diff im (einzigen) Installationsweg und steht jetzt nur noch am Ende von
  **Weg A**; Weg B endet mit „Kopieren Sie es **bei Bedarf** an eine Stelle auf Ihrem Pfad".
  Ein Leser, der Weg B nimmt (der Text schickt ihn ausdrücklich an Weg A vorbei), erhält die
  Kopie damit als optional und trifft ab §3 Schnelleinstieg auf Kommandos der Form
  `ai-harness-init --lang go …`, die ohne die Kopie „command not found" liefern.
- `verifizierbar`: nein — Wortlaut-Befund, kein Gate deckt Nutzer-Doku-Kohärenz.

### F-7 — Systemanforderungen empfehlen zwei Plattformen, das Angebot desselben Kapitels führt drei

- `kategorie`: LOW
- `quelle`: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) („Erstklassig auf
  allen dreien ohne WSL2-Zwang") · Maintainability
- `pfad`: `docs/user/benutzerhandbuch.md:57` gegen `:83–84`
- `befund`: §2 Systemanforderungen führt unverändert „Ein Betriebssystem mit Docker (Linux
  oder macOS werden **empfohlen**)", während dasselbe Kapitel 26 Zeilen später zwei
  Windows-Assets als regulären Download anbietet und die Anforderung Windows ausdrücklich als
  erstklassige Plattform führt. Ein Windows-Leser bekommt in einem Kapitel beide Aussagen —
  „nicht empfohlen" und „hier ist Ihre Datei" — ohne Auflösung.
- `verifizierbar`: nein — Wortlaut-Befund; kein Gate prüft Aussagen-Konsistenz.

### INFO-1 — Dritte gemessene Instanz: Lifecycle-Move mit hängenden Inbound-Links

- `kategorie`: INFO
- `quelle`: Hard Rule 3.3 ([`AGENTS.md`](../../AGENTS.md) §3.3) · Roadmap-Kandidat
  „Doku- und Sensor-Wartung" Achse 4 · slice-049-Review F-3/R-1
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:22` und `:56` im Zustand von `38b60ed`
- `befund`: `38b60ed` verschiebt die Slice-Datei `open/ → in-progress/` als reinen Move
  (0 Insertions/0 Deletions — Hard Rule 3.3 sauber erfüllt) und lässt die zwei
  Roadmap-Links `../open/slice-050-doku-nachzug-release.md` auf dem Zwischenstand ins Leere
  zeigen; repariert werden sie erst im Inhalts-Commit `0c31697`. Das ist nach slice-049 die
  **dritte** gemessene Instanz der Klasse. **Bewusst milder kategorisiert als slice-049 F-3
  (MEDIUM), mit Begründung statt still:** dort war die Reparatur weder angekündigt noch an
  einer Konvention ausgerichtet; hier nennt die Commit-Message die geschriebene Auflösung
  ([`.claude/commands/close-welle.md`](../../.claude/commands/close-welle.md) Schritt 4:
  Move-Commit, danach eigener Link-Reconciliation-Commit) und verweist den Widerspruch selbst
  an den bestehenden Roadmap-Kandidaten. Nach Skill §Kontext-Eskalation ist die dritte
  Wiederholung ein **Steering-Loop-Signal** (Konvention/Sensor nachziehen), kein weiteres
  Einzel-Finding.
- `verifizierbar`: ja — `git checkout 38b60ed && make docs-check` färbt rot (links-Modul);
  statisch belegt durch `git show 38b60ed:docs/plan/planning/in-progress/roadmap.md | grep -n "\.\./open/slice-050"`.

### INFO-2 — Zweite veraltete FAQ-Antwort in derselben Datei, außerhalb des Slice-Gegenstands

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `docs/user/benutzerhandbuch.md:470–471`
- `befund`: §8 FAQ antwortet „Welche Sprachen werden unterstützt? — Derzeit `go`", während
  Kopfzeile 4 und §2 seit Handbuch-Version 1.3 `go` **und** `cpp` führen. Der Befund gehört
  **nicht** zu slice-050 (kein Release-Bezug, nicht im Diff) und wird nur gemeldet, weil er
  dieselbe Wurzel wie F-1/F-2 hat: die FAQ- und Anhang-Abschnitte werden bei Nachzügen
  systematisch übersehen. Rollen-Verweis: eigener Doku-Slice, nicht dieser Diff.
- `verifizierbar`: nein — kein Gate prüft Aussagen-Konsistenz.

### INFO-3 — Handbuch-Version 1.5 ohne Eintrag in der eigenen Änderungshistorie

- `kategorie`: INFO
- `quelle`: Maintainability (Konvention des Dokuments selbst)
- `pfad`: `docs/user/benutzerhandbuch.md:3` gegen §11 (Tabelle, jüngste Zeile `1.4 | 2026-07-25`)
- `befund`: Der Kopf wird auf „Handbuch-Version: 1.5 / Stand: 2026-07-26" gezogen, §11
  Änderungshistorie führt aber weiterhin 1.0–1.4; jede der fünf Vorgänger-Versionen hat dort
  eine Zeile. Der veröffentlichte Stand nennt damit eine Version, deren Änderung das Dokument
  selbst nicht ausweist. Der Slice-Plan §3 listet §11 in seiner Änderungs-Tabelle nicht auf —
  die Lücke ist Plan-konform entstanden, nicht gegen den Plan.
- `verifizierbar`: nein — kein Gate prüft die Historien-Tabelle.

---

## Negativbefunde

- geprüft, ohne Befund: **`spec/lastenheft.md` unberührt über die ganze Range** —
  `git diff --stat 63236d3..HEAD -- spec/` liefert leere Ausgabe;
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Anforderung wie
  Messmethode) steht unverändert seit CR 0.13.0. Kein verdeckter Lastenheft-Nachzug,
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) gewahrt.
- geprüft, ohne Befund: **die sechs Asset-Namen** in
  [`benutzerhandbuch.md`](../user/benutzerhandbuch.md):79–84 stimmen zeichengenau mit der
  `matrix` in [`release.yml`](../../.github/workflows/release.yml):70–80 **und** mit den
  real veröffentlichten Assets überein (`gh release view v0.1.0 --json assets` → exakt
  `ai-harness-init-{linux,darwin}-{amd64,arm64}` + `-windows-{amd64,arm64}.exe`, sechs
  Stück). Auch die System-Zuordnung ist korrekt (`darwin` → macOS, `arm64` → Apple Silicon).
  Keine „plausible Form statt gemessener Form".
- geprüft, ohne Befund: **der Aufruf `ai-harness-init --help`** (Schritt 3 in Weg A und
  Weg B) ist quellenbelegt — `harness/tools/start-smoke.sh` führt real `"$bin" --help` aus
  und prüft die Usage auf die Marker `ai-harness-init` und `add-lang`; der Aufruf lief auf
  allen sechs Runnern des Release-Laufs grün. Kein halluziniertes Kommando.
- geprüft, ohne Befund: **der macOS-Quarantäne-Hinweis** (`:101`) — `xattr -d
  com.apple.quarantine <datei>` ist die zutreffende Operation für das beschriebene Symptom
  und als Hinweis, nicht als Zusage, formuliert.
- geprüft, ohne Befund: **der Link auf `releases/latest`** (README:43,
  Handbuch:75) — `gh release view v0.1.0` meldet `prerelease: false, draft: false`, das
  Ziel löst damit auf den v0.1.0-Release auf; der frühere `v0.1.0-RC`-Prerelease ist
  entfernt (slice-048 §Nachtrag).
- geprüft, ohne Befund: **Weg B vollständig und korrekt erhalten** —
  `git clone` → `make artifact DEST=./bin` → `./bin/ai-harness-init --help` →
  `DEST`-Pflichthinweis unverändert (`:113–136`); kein Ersatz durch Weg A, die Begründung
  („Stand ohne Versions-Kennzeichnung") trifft zu, weil ein Asset nur an einem Tag entsteht.
- geprüft, ohne Befund: **Hard Rule 3.3** — `38b60ed` ist ein reiner Move
  (`git show --stat`: 1 file changed, 0 insertions, 0 deletions, Rename-Detection greift);
  Inhalt und Move sind getrennt committet. (Die *Inbound*-Link-Frage ist INFO-1, sie ist
  nicht Gegenstand von 3.3.)
- geprüft, ohne Befund: **Hard Rule 3.4** — kein `docs/plan/adr/` im Diff
  (`git diff --stat 63236d3..HEAD` nennt vier Dateien, keine ADR); kein accepted ADR
  berührt, [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only) nur mittelbar,
  keine Host-Toolchain in einer der neuen Nutzer-Anweisungen (`chmod`/`mv`/`xattr` sind
  keine Build-Toolchain).
- geprüft, ohne Befund: **Hard Rule 3.1 / 3.5** — der Diff berührt weder `Makefile` noch
  `harness/mk/`, `.d-check.yml`, Gate-Skripte oder Workflows; kein Gate benannt, gelockert
  oder hinzugefügt. `make gates`-Fläche unverändert.
- geprüft, ohne Befund: **Hard Rule 3.2** — kein `//nolint`, kein
  `# shellcheck disable` im Diff (reine Markdown-Änderung).
- geprüft, ohne Befund: **README-Änderung** (`:41–50`) — die zwei gemessenen
  Falschaussagen sind weg, der Download steht als erster Weg, der Bau aus Quelle bleibt mit
  seinem `make artifact DEST=./bin`-Aufruf erhalten, „Was heute noch fehlt" behält die
  Sprachen und verliert nur die Release-Binaries. Kein Prozess-Vokabular (keine Slice-/
  Welle-ID) ins Nutzer-Dokument gewandert.
- geprüft, ohne Befund: **Roadmap-Nachzug** (`:22`, `:56`) — beide Links auf
  `slice-050-doku-nachzug-release.md` zeigen im Endzustand auf die reale Datei in
  `in-progress/`, die Zustandsangabe in der Zelle ist von `open/` auf `in-progress/`
  mitgezogen. M5 steht weiterhin auf **offen** — plan-konform, weil §3 die
  M5-Fortschreibung ausdrücklich in den Closure-Schritt legt.
- geprüft, ohne Befund: **Doku-Gate und Baseline** — `make docs-check`: „187 Datei(en)
  geprüft, 0 Befund(e)"; `make baseline-verify`: „v3.5.2 OK — 42 Dateien"; Arbeitsbaum clean
  (`git status --short` leer).
- geprüft, ohne Befund: **`.harness/baseline/`** — im Diff nicht enthalten, kein
  Regelwerks-/Template-Byte berührt.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 3 |
| LOW | 3 |
| INFO | 3 |

**Wiederkehrende Klasse:** F-1, F-2, F-3, F-4 (und im Kleinen F-5) sind alle „Zusage weiter
als Abdeckung" ([`AGENTS.md`](../../AGENTS.md) §3.6) — dieselbe Klasse, die in slice-049
viermal auftrat. Muster diesmal: **ein Such-Kommando, dessen Trefferbereich enger ist als die
Aussage, die es belegen soll** (F-1/F-2), und **eine Abdeckungs-Zusage, die eine Ebene
gröber formuliert ist als das, was gemessen wird** (F-3: Release vs. Push; F-4: Betriebssystem
vs. Architektur). Zusammen mit INFO-1 ist das der zweite Steering-Loop-Auslöser dieser
Sitzungsreihe.

## Verdikt

**NICHT KONFORM.**

**Merge-blockierend:** ja — ein HIGH (F-1) und drei MEDIUM (F-2, F-3, F-4). Erschwerend
gegenüber einem gewöhnlichen Doku-Befund: F-1 und F-2 stehen **im getaggten Stand `v0.1.0`**
und sind damit bereits veröffentlicht; der Slice-Plan macht in §1 „sagen die Wahrheit über
den Auslieferungsweg" zum Ziel und in §2 die Widerspruchsfreiheit zur DoD-Bedingung — beides
ist an zwei Stellen desselben Dokuments nicht erreicht. F-3/F-4 betreffen ausgerechnet den
Kasten, der die Überklage verhindern soll.

**Nicht bestritten wird:** der Schnitt (Doku vor Tag), die Quellen-Treue der sechs
Asset-Namen, die Unberührtheit von `spec/lastenheft.md`, die Erhaltung von Weg B und die
saubere Move-Trennung — alle in den Negativbefunden belegt.

**Übergabe:** Findings gehen an die Implementation (Rückkante Review → Plan bei Plan-Defekt;
F-1 hat einen Plan-Anteil: die §3-Ist-Messung trug einen Allquantor, den ihr Kommando nicht
decken kann). Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der
Verifier separat (Modul 11).
