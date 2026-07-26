# Review-Report: slice-050 (Runde 3) — 2026-07-26

**Review-Art:** Code — geprüft wird gegen **Plan + aktive ADRs + Hard Rules + Konventionen**
(Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung (Modul 11, getrennter Kontext,
anderes Prüf-Artefakt).

**Gegenstand — drei Achsen, alle drei erstmals geprüft:**

1. **`321b849`** („fix(docs): slice-050 Review-Runde-2-Findings") — Auflösung der Runde-2-Findings;
   zwei Dateien ([`README.md`](../../README.md) 1 Zeile,
   [`2026-07-26-slice-050-impl-review-runde-2.md`](2026-07-26-slice-050-impl-review-runde-2.md) 390 Zeilen neu).
2. **`30f0fcd`** („spec: CR Lastenheft 0.13.0 -> 0.14.0") — ein **Change Request** am Lastenheft,
   **kein** slice-050-Commit; eine Datei ([`spec/lastenheft.md`](../../spec/lastenheft.md), +15/−4).
3. **Ein Artefakt außerhalb von git:** der **Release-Text** von `v0.1.0`, per `gh release edit`
   ergänzt (unforciert; Tag unbewegt).

Der Gesamt-Diff `63236d3..0c31697` (Runde 1) und `a4dac1f` (Runde 2) sind geprüft und werden **nicht**
wiederholt.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26 · **Frischer Kontext**, getrennt von
Implementation und Verifikation und von Runde 1 und 2.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan: [`in-progress/slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md) (§1 Bezug, §2 DoD, §4 Dateitabelle)
- berührte `LH-*`-IDs: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Anforderung, Messmethode, beide Grenz-Notizen),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)
- aktive ADRs: keine im Diff geändert; mittelbar [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules 3.1–3.6) und §4 (Quality Gates) ·
  [`harness/README.md`](../../harness/README.md) §Sensors · Konventionen
  [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) (vollständig gelesen — Setzung 1/2/3, Cutoff, Durchsetzung)
- **Vorherige Findings am gleichen Modul (Pflicht-Punkt 5):** [Runde 1](2026-07-26-slice-050-impl-review.md)
  (1 HIGH, 3 MEDIUM, 3 LOW, 3 INFO), [Runde 2](2026-07-26-slice-050-impl-review-runde-2.md)
  (0 HIGH, 2 MEDIUM, 1 LOW) und die vier slice-049-Runden
  ([1](2026-07-26-slice-049-impl-review.md), [2](2026-07-26-slice-049-impl-review-runde-2.md),
  [3](2026-07-26-slice-049-impl-review-runde-3.md), [4](2026-07-26-slice-049-impl-review-runde-4.md)) —
  dominante Klasse: **„Zusage weiter als Abdeckung"** ([`AGENTS.md`](../../AGENTS.md) §3.6)
- Rollen-Vertrag: `.harness/skills/reviewer.md`, <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
  `.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md` (beide vollständig gelesen)

**Eigene Sensoren (lesend, Docker-only nach [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)):**
`make docs-check` (Lauf am Ende protokolliert) · vollständig gelesen:
[`Makefile`](../../Makefile) (Target `gates`, Image-Pins), `d-check.mk`, `internal/emit/archgate.go`,
`internal/emit/emit.go`, [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml),
[`.github/workflows/release.yml`](../../.github/workflows/release.yml), [`README.md`](../../README.md),
[`AGENTS.md`](../../AGENTS.md) §3/§4, [`harness/README.md`](../../harness/README.md) §Sensors,
[`spec/lastenheft.md`](../../spec/lastenheft.md) §LH-QA-04 + §7 Historie ·
`git show 321b849 30f0fcd` / `git show v0.1.0:docs/user/benutzerhandbuch.md` /
`git diff v0.1.0 HEAD -- docs/user/benutzerhandbuch.md` ·
`gh release view v0.1.0 --json body,assets,tagName,isDraft,isPrerelease` ·
**Registry-Manifest-Abfragen (read-only HTTP GET, keine Docker-Operation, nichts Mutierendes)** gegen
`registry-1.docker.io` und `ghcr.io` für alle sieben gepinnten Gate-Images — das Messkommando zu
**R-1**, unten verbatim. **Nicht** gefahren: `make gates`, `make mutate`, `make test`,
`make full-smoke` (mutierend bzw. verifizierende Rolle).

---

## (A) Status der Runde-2-Findings

Geprüft **am Artefakt**, nicht an der Behauptung.

### N-3 (LOW) — README-Gate-Liste · **behoben, selbst nachgerechnet**

[`README.md`](../../README.md):77 lautet jetzt: „`make gates` bündelt **sieben** — `make baseline-verify` …,
`make docs-check` …, `make lint`/`make build` …, `make test` …, `make shell-lint` …, `make ci-lint` …
— alle grün. Das Architektur-Gate a-check ist **nicht** dabei: es wird in Zielrepos mit geschichtetem
Grundgerüst **emittiert**, hier hätte es einen leeren Prüfbereich."

**Eigene Gegenprobe (nicht die des Implementers).** Mengen-Vergleich der `make …`-Nennungen der Zeile
gegen die `gates:`-Prerequisites:

| Quelle | Menge |
|---|---|
| [`Makefile`](../../Makefile):222 `gates:` | `baseline-verify docs-check lint build test shell-lint ci-lint` **+ `record-gates`** |
| [`README.md`](../../README.md):77 | `baseline-verify docs-check lint build test shell-lint ci-lint` |

**Identisch, sieben.** Die Differenz ist genau `record-gates` — und dessen Ausschluss ist nicht
kuratorische Willkür, sondern steht im Makefile-Kommentar derselben Zeile („alle aktuell lauffähigen
Gates **+ Nachweis**"). Die Zahl „sieben" ist damit korrekt und trägt ihre eigene Abgrenzung.

**Konsistenz mit den beiden anderen kuratierten Listen — geprüft, deckungsgleich:**
[`AGENTS.md`](../../AGENTS.md) §4 (Tabelle: dieselben sieben Targets + `make gates`) und
[`harness/README.md`](../../harness/README.md) §Sensors (Tabelle „Nur existierende Targets": dieselben
sieben + `make gates`). Die a-check-Aussage der neuen README-Zeile ist die Kurzform des Satzes, den
beide anderen Dateien wörtlich gleich führen („**Nicht behauptet**: das Architektur-Gate … der
Dogfood ist **flach**, hier hätte a-check einen leeren Prüfbereich … **Emittiert wird es trotzdem**").
Sie sagt dasselbe, ohne den Prozess-Anker `LH-FA-07` in die Kurzfassung zu ziehen. Die
überholte Zusage „(Das arch-Gate a-check **folgt** mit dem Go-Code.)" ist ersatzlos weg. **Kein
Rest-Befund.**

### N-1 (MEDIUM) — veröffentlichter Stand · **im richtigen Kanal geschlossen; die Abhilfe trägt einen neuen Befund**

Gemessen: `gh release view v0.1.0 --json body`. Der Release-Text trägt jetzt vier Absätze statt
der einen automatischen Zeile. Jede prüfbare Aussage einzeln gehalten:

| Aussage im Release-Text | Beleg | Urteil |
|---|---|---|
| „vorgefertigte Programme für sechs Plattformen (Linux · macOS · Windows × amd64 · arm64)" | `gh release view v0.1.0 --json assets` → exakt sechs, Namen zeichengleich mit [`release.yml`](../../.github/workflows/release.yml):68–80 | **trifft zu** |
| „Die Dokumentation in diesem Tag nennt an **zwei** Stellen noch den Zustand *vor* diesem Release — die FAQ … und der Anhang …" | `git show v0.1.0:docs/user/benutzerhandbuch.md \| sed -n '486p;524p'` → genau die zwei zitierten Sätze | **die zwei genannten Stellen sind richtig** (aber nicht die einzigen → **R-2**) |
| „Beides ist auf `main` korrigiert." | `a4dac1f` schreibt beide Zeilen um; HEAD trägt „Ja, ab `v0.1.0`" bzw. „Fertige Programme gibt es **an den Releases**" | **trifft zu** |
| „Die sechs Binaries sind davon nicht betroffen." | `git show --stat a4dac1f` → drei `.md`-Dateien, kein Go-Code, kein Workflow | **trifft zu** |
| „der Installations-Abschnitt des Benutzerhandbuchs ist im Tag bereits korrekt" | §2 im Tag trägt vier in Runde 1 belegte Defekte, s. **R-2** | **trifft NICHT zu** |
| „Der vollständige Durchlauf … läuft auf linux/amd64. Für alle sechs ausgelieferten Dateien ist geprüft, dass das Programm auf seiner Plattform startet — mehr nicht." | [`ci.yml`](../../.github/workflows/ci.yml):58–62 (`full-smoke`, ein Job, `runs-on: ubuntu-24.04`, keine Matrix) und [`release.yml`](../../.github/workflows/release.yml):63–98 (`start-smoke`, sechs Matrix-Einträge, derselbe `start-smoke.sh`-Aufruf) | **trifft zu** |

**Ist das von der DoD benannte Gegenbeispiel geschlossen oder nur verschoben?** — **Für den Kanal,
auf den die Dokumentation zeigt, geschlossen.** [`README.md`](../../README.md):43 und
[`benutzerhandbuch.md`](../user/benutzerhandbuch.md):81 zeigen beide auf `releases/latest`; das ist
genau die Seite, die den Warn-Absatz jetzt **über** den Assets und über dem Quell-Archiv trägt. Der
Leser der DoD-Fallgeschichte („liest die Doku des getaggten Standes und findet keinen Download")
begegnet der Korrektur vor dem Fehler, nicht danach. Der unforcierte Kanal wurde genutzt, der Tag ist
unbewegt (`git rev-list -n1 v0.1.0` → `0c31697e…`; `isDraft:false`, `isPrerelease:false`,
`publishedAt` unverändert `2026-07-26T07:50:44Z`) — [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) bleibt gewahrt.

**Rest, der bleibt und keiner ist:** wer `git checkout v0.1.0` fährt, ohne die Release-Seite zu
öffnen, sieht die zwei Sätze weiterhin. Das ist ohne Tag-Bewegung strukturell unerreichbar und wurde
in Runde 2 ausdrücklich als tragfähige Ablehnung akzeptiert — **kein Finding**.

**Was daraus doch ein Finding wird:** die Warnung ist zu eng gefasst und behauptet zusätzlich
positiv, ein Abschnitt sei im Tag korrekt, der es nicht ist → **R-2**.

### N-2 (MEDIUM) — [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)-Widerspruch · **im Vertrag aufgelöst; die Auflösung trägt einen neuen HIGH**

Der Widerspruch selbst ist weg. Die Messmethode staffelt jetzt nach `GOOS/GOARCH` statt nach
Betriebssystem, und beide Aufzählungspunkte sind gegen die Workflows belegt:

| Neuer Wortlaut | Beleg | Urteil |
|---|---|---|
| „**linux/amd64:** **Voll-Smoke** — Bootstrap in ein tmp-Repo, dort `make gates` grün" | [`ci.yml`](../../.github/workflows/ci.yml):58–62 Job `full-smoke`, `runs-on: ubuntu-24.04` (x64), ruft `make full-smoke`; `grep -n "runs-on" .github/workflows/ci.yml` → viermal `ubuntu-24.04`, kein ARM-Runner | **trifft zu** |
| „**linux/arm64 · macos · windows:** **Start-Smoke**" | [`release.yml`](../../.github/workflows/release.yml):68–80 `matrix.include` — `ubuntu-24.04-arm`/`macos-26-intel`/`macos-26`/`windows-2025`/`windows-11-arm` (und `ubuntu-24.04`) bekommen **denselben** `start-smoke.sh`-Aufruf | **trifft zu** |
| „ein Linux-ARM-Runner fährt Linux-Container und *könnte* den Voll-Smoke **prinzipiell** tragen" | `ubuntu-24.04-arm` ist ein Linux-Runner mit Docker; die Aussage ist durch „prinzipiell" gehedged | **trägt** (die *technische Klasse* stimmt; die Begründungs-Trennung von macOS/Windows ist sachlich richtig) |
| „Diese Grenze schließt sich **ohne** neue Plattform-Runner: **es genügt**, den Voll-Smoke zusätzlich auf einem Linux-ARM-Runner zu fahren." | zwei der sieben gepinnten Gate-Images sind **Single-Arch-amd64-Manifeste** — Messung unten | **trifft NICHT zu** → **R-1** |

**Blieb die Anforderung wirklich unverändert?** — **Ja, verbatim.** `git show 30f0fcd -- spec/lastenheft.md`
zeigt vier Hunks: Header-Version, zwei Zeilen der Messmethode, ein additiver Grenz-Absatz, eine
Historie-Zeile. Der Absatz **Anforderung** („Native Binaries für **linux · macos · windows** ×
**amd64 · arm64** … Erstklassig auf allen dreien ohne WSL2-Zwang") ist **kein** Hunk — er ist
byte-identisch. Die sechs ausgelieferten Kombinationen sind unverändert; geändert hat sich allein,
**was sie belegt**. Das deckt sich mit dem, was die Historie-Zeile und die Commit-Message zusagen.

**Ist die getrennte Grenz-Notiz sachlich korrekt?** — In ihrer **Diagnose** ja, in ihrer
**Auflösungs-Zusage** nein. Die Trennung von der 0.13.0-Notiz ist sachlich zwingend: deren Begründung
(kein Linux-Container-Runtime auf den gehosteten macOS-/Windows-Runnern) trägt für einen Linux-ARM-Runner
wirklich nicht. Der Zusatz „**es genügt**" ist der neue Befund → **R-1**.

---

## (B) Prüfung des CR `30f0fcd` gegen [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)

Erste reale Anwendung der Setzungen 2 und 3. Geprüft wird jede Setzung einzeln, gegen den Commit.

### Setzung 2 — eigener Commit, ausschließlich `spec/lastenheft.md`, Lage relativ zum Slice

| Kriterium (Wortlaut MR-015) | Messung | Urteil |
|---|---|---|
| „in einem **eigenen Commit**" | `git show --stat 30f0fcd` → `1 file changed, 15 insertions(+), 4 deletions(-)` | **erfüllt** |
| „der **ausschließlich** `spec/lastenheft.md` ändert" | genau diese eine Datei | **erfüllt** |
| „und **vor** dem `open → in-progress`-Move des umsetzenden Slice liegt" | ein umsetzender Slice **existiert nicht** — die Präzisierung beschreibt, was bereits läuft; die Notiz benennt ihre Auflösung ausdrücklich als „eine eigene Entscheidung mit eigenem Trigger" | **leer erfüllt** (die Bedingung hat kein Bezugsobjekt) — die Commit-Message sagt das auch so |
| „mechanisch beantwortbar: `git log -- spec/lastenheft.md` + `git show --stat`" | genau so gemessen, ohne Prosa lesen zu müssen | **erfüllt** |
| Cutoff („geprüft wird ab dem Commit, der diesen Eintrag trägt") | `30f0fcd` liegt nach der Einführung von MR-015 (slice-049) | **im Geltungsbereich** |

**Liegt er richtig relativ zu slice-050?** — **Ja.** `30f0fcd` ist **kein** Slice-Commit: er ist weder
im Slice-Plan als Datei geführt ([`slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md) §4 nennt
`spec/lastenheft.md` ausdrücklich als **unberührt**), noch ein Lifecycle-Move, noch eine
Auflösungs-Runde. Die DoD-Aussage „**`spec/lastenheft.md` unberührt** — belegt per `git diff --stat`"
trägt für die Commits des Slice unverändert: `git diff --stat 813418c..321b849` nennt keine Datei
unter `spec/`; die drei Auflösungs-/Impl-Commits `0c31697`, `a4dac1f`, `321b849` ebenfalls nicht. Der
CR steht **hinter** dem letzten Slice-Commit und **vor** der Closure — genau die Lage, die MR-015
lesbar machen will. Eine Rest-Reibung an der **Mess-Anweisung** der DoD (kein Range genannt) ist unten
als **INFO-1** geführt, nicht als Verstoß.

### Setzung 3 — Verweis-Spalte = annehmende Instanz, Änderungs-Spalte = Anlass

Die neue Historie-Zeile (Spaltenordnung `Version | Datum | Änderung | Verweis`):

- **Verweis-Spalte:** „Nutzer-Entscheidung 2026-07-26 (Anlass: slice-050-Review N-2)"
- **Änderungs-Spalte:** „CR: Messmethode `LH-QA-04` **präzisiert** — … Grund: der 0.13.0-Wortlaut
  sagte „linux" undifferenziert zu … Die **Anforderung** … bleibt unverändert …"

Die **annehmende Instanz** steht im Verweis — der Kern von Setzung 3 ist erfüllt, und die
Abgrenzung zur Altpraxis ist sichtbar: 0.13.0 trug dort noch das Label „Messmethoden-CR
(Plattform-Matrix)" und den Urheber „Getrieben von slice-048" in der Änderungs-Spalte. Der
**umsetzende Slice** wird im Verweis nicht genannt — das ausdrückliche Verbot der Setzung ist
gewahrt. **Aber:** der **Anlass** („slice-050-Review N-2") steht mit im Verweis, während Setzung 3
schreibt, „der Anlass (ein ADR, ein **Slice-Befund**) **bleibt in der Änderungs-Spalte**" — und die
Änderungs-Spalte nennt ihn nirgends. → **R-3** (LOW).

### Fußabdruck vollständig? Ist `0.14.0` die richtige Stufe?

| Fußabdruck-Element (Baseline-Wortlaut, verbatim in MR-015) | Messung | Urteil |
|---|---|---|
| „ein Version-Bump des Lastenhefts" | Kopfzeile `**Version:** 0.13.0` → `0.14.0`, im selben Commit | **vorhanden** |
| „eine Zeile in dessen `## Historie`" | Zeile `0.14.0 \| 2026-07-26 \| … \| Nutzer-Entscheidung 2026-07-26 …` — vierspaltig wie alle 13 Vorgänger, Tabelle bleibt wohlgeformt | **vorhanden** |
| „und die geänderten `LH-*` selbst" | [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) §Messmethode (2 Zeilen) + neue Grenz-Notiz (10 Zeilen) | **vorhanden** |
| kein `CR-*`-ID-Schema, keine CR-Datei, kein Gate | der Commit legt keine Datei an, ändert kein Target | **konform** |

**Stufe.** Es gibt keine formale Semver-Regel für dieses Dokument; maßgeblich ist die geübte Praxis.
Alle 14 Historie-Zeilen sind `X.Y.0` — eine Patch-Stufe existiert im Dokument nicht, wäre also eine
Neuerfindung. Der direkte Präzedenzfall ist strukturgleich: **0.13.0** war ebenfalls eine
Messmethoden-Präzisierung bei unveränderter Anforderung und bekam eine Minor. **`0.14.0` ist die
präzedenz-konforme Stufe** — kein Befund.

**Zwei-Satz-Urteil zum CR.** *Formal ist er die erste saubere Anwendung von MR-015: ein
Ein-Datei-Commit, vollständiger Fußabdruck, die annehmende Instanz im Verweis statt des umsetzenden
Slice, die Anforderung nachweislich byte-identisch — die Setzungen 2 und 3 tragen im ersten realen
Fall.* *Inhaltlich löst er den N-2-Widerspruch korrekt auf, ersetzt ihn aber im selben Absatz durch
eine ungemessene Auflösungs-Zusage („es genügt …"), die an der Ist-Messung bricht — und
schreibt sie in die höchstrangige interne Quelle.*

---

## (C) Neue Findings

### R-1 — Die neue `linux/arm64`-Grenz-Notiz sagt eine Auflösung zu, die an den eigenen Image-Pins bricht

- `kategorie`: **HIGH**
- `quelle`: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) §Grenze der Messmethode · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6 (Klasse „Zusage ohne rot gesehenes Gegenbeispiel")
- `pfad`: [`spec/lastenheft.md`](../../spec/lastenheft.md) §LH-QA-04, letzter Aufzählungspunkt („Diese Grenze schließt sich
  **ohne** neue Plattform-Runner: es genügt, den Voll-Smoke zusätzlich auf einem Linux-ARM-Runner zu
  fahren.") — eingeführt in `30f0fcd`
- `befund`: Der Satz behauptet Hinreichendheit („es genügt"), ist aber gegen den eigenen Gate-Stack
  nicht gedeckt: `make gates` fährt `docs-check` über
  `ghcr.io/pt9912/d-check@sha256:fede3d02…` (`d-check.mk`:16), und dieser Digest ist ein
  **Single-Arch-Manifest für `linux/amd64`** — kein Manifest-Index, keine `arm64`-Variante. Dasselbe
  gilt für `ghcr.io/pt9912/a-check@sha256:6425c93a…` (`internal/emit/archgate.go`:22), das der
  `hexslice`-Zweig des Voll-Smoke im gebootstrappten Ziel-Repo fährt. Der Voll-Smoke bräuchte den
  Pin also **zusätzlich** auf beiden Seiten neu: `internal/emit/emit.go`:34 (`DefaultDigest`) schreibt
  denselben amd64-Digest in das emittierte `d-check.mk` des Ziel-Repos, sodass der Lauf sowohl im
  Host-`make gates` als auch im Ziel-`make gates` scheitert. Der Runde-2-Report hatte genau dieses
  Gegenbeispiel („etwa ein gepinntes Gate-Image ohne `arm64`-Manifest") im `verifizierbar`-Feld von
  N-2 benannt; die Zusage wurde formuliert, ohne es zu messen.
- `verifizierbar`: **ja, statisch und netz-lesend, kein Gate-Lauf nötig.** Messkommando (verbatim
  gefahren, Ergebnisse unten):

  ```
  # ghcr.io — Token holen, Manifest-Content-Type lesen
  T=$(curl -s "https://ghcr.io/token?service=ghcr.io&scope=repository:pt9912/d-check:pull" | …)
  curl -s -H "Authorization: Bearer $T" \
       -H "Accept: application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, …" \
       "https://ghcr.io/v2/pt9912/d-check/manifests/sha256:fede3d02…"
  ```

  | gepinntes Image | Pin-Ort | Manifest-Typ | Architekturen |
  |---|---|---|---|
  | `bats/bats` | [`Makefile`](../../Makefile):8 | `oci.image.index.v1+json` | 386 · **amd64** · arm · **arm64** · ppc64le · s390x |
  | `koalaman/shellcheck` | [`Makefile`](../../Makefile):9 | `oci.image.index.v1+json` | **amd64** · **arm64** · arm/v6 · riscv64 |
  | `rhysd/actionlint` | [`Makefile`](../../Makefile):10 | `oci.image.index.v1+json` | **amd64** · **arm64** |
  | `golang` | `Dockerfile`:14 | `oci.image.index.v1+json` | 386 · **amd64** · arm · **arm64** · ppc64le · riscv64 · s390x |
  | `golangci/golangci-lint` | `Dockerfile`:35 | `oci.image.index.v1+json` | **amd64** · **arm64** |
  | **`ghcr.io/pt9912/d-check`** | `d-check.mk`:16 · `internal/emit/emit.go`:34 | `docker.distribution.manifest.v2+json` (**Single-Arch**) | **nur amd64** (Config-Blob: `"architecture":"amd64"`, `"os":"linux"`) |
  | **`ghcr.io/pt9912/a-check`** | `internal/emit/archgate.go`:22 | `docker.distribution.manifest.v2+json` (**Single-Arch**) | **nur amd64** (Config-Blob: `"architecture":"amd64"`, `"os":"linux"`) |

  Fünf von sieben Pins tragen `arm64`; **die zwei selbst veröffentlichten nicht** — und ausgerechnet
  sie hängen an `docs-check`, dem ersten Nicht-Trivial-Prerequisite von
  [`Makefile`](../../Makefile):222 `gates:`. Auch der Tag `v0.51.1` selbst löst auf denselben
  Single-Arch-Digest auf (`docker-content-digest: sha256:fede3d02…`), ein Re-Pin auf den Tag hilft
  also nicht.
- **Failure-Szenario (konkret).** Jemand liest das Lastenheft als Vertrag, nimmt seine Auflösungs-Zusage
  wörtlich und schneidet einen Slice „Voll-Smoke auf `ubuntu-24.04-arm` ergänzen". Der Job wird
  hinzugefügt; `make full-smoke` bootstrappt, das Ziel-Repo fährt `make gates`, `docs-check` ruft
  `docker run … ghcr.io/pt9912/d-check@sha256:fede3d02…` und bricht mit
  `no matching manifest for linux/arm64/v8 in the manifest list entries` ab — nicht wegen einer
  arch-abhängigen Regression, die der Sensor finden sollte, sondern weil die im Lastenheft benannte
  Vorbedingung („es genügt") falsch ist. Die eigentliche Arbeit (zwei Images multi-arch bauen und
  neu pinnen, in zwei fremden Repos) steht in der Anforderung nirgends. Ergebnis: verworfener Slice
  plus eine Vertragszeile, die weiterhin eine unerreichbare Grenzschließung zusagt.
- **Warum HIGH und nicht MEDIUM** (Modul 10 §„Gegen: bei zwei Kategorisierungen die mildere"):
  Basis-Anker ist MEDIUM („Spec-Treue-Lücke einer Messmethode" — der Satz steht wörtlich in
  §Messmethode/Grenze). Die Skill-Regel **§Kontext-Eskalation** hebt eine Beobachtung im
  **Gate-Pfad** eine Stufe: die Aussage handelt davon, ob `make gates` und `make full-smoke` auf
  `arm64` überhaupt laufen können, und ist an den Gate-Image-Pins messbar falsch. → **HIGH**. Die
  Milderung „es ist ja nur ein Nebensatz" wäre genau die Inkonsistenz-Belohnung, die Modul 10
  ausschließt — zumal der Satz in der **höchstrangigen internen Quelle** steht
  ([`AGENTS.md`](../../AGENTS.md) §1 Source Precedence) und ihre Falschaussage jede niederrangige
  Quelle sticht.

### R-2 — Der ergänzte Release-Text erklärt einen Abschnitt für korrekt, der im Tag vier belegte Defekte trägt

- `kategorie`: **MEDIUM**
- `quelle`: Hard-Rule-Klasse [`AGENTS.md`](../../AGENTS.md) §3.6 · Runde-1-Findings F-3/F-4/F-5/F-7 ·
  Slice-Plan §2 DoD (das dort benannte Gegenbeispiel)
- `pfad`: `gh release view v0.1.0 --json body`, Absatz 2, letzter Satz („der Installations-Abschnitt
  des Benutzerhandbuchs ist im Tag bereits korrekt")
- `befund`: Der Warn-Absatz nennt „**zwei** Stellen" (FAQ, Anhang) und spricht den
  Installations-Abschnitt ausdrücklich frei. `git show v0.1.0:docs/user/benutzerhandbuch.md`
  zeigt, dass §2 „Installation und Zugriff" (Zeilen 53–139 im Tag) **vier** in Runde 1 belegte
  Defekte trägt, die erst `a4dac1f` — **nach** dem Tag — behoben hat: (a) `### Systemanforderungen`
  „(Linux oder macOS werden empfohlen)" bei sechs ausgelieferten Binaries (F-7); (b) der Kasten „Was
  wo geprüft wird" — „Der vollständige Durchlauf … wird **bei jedem Release** auf **Linux** gefahren"
  (F-3/F-4: falscher Auslöser *und* falscher Umfang); (c) Weg A Schritt 2 —
  `mv … ~/.local/bin/ai-harness-init` **ohne** vorheriges `mkdir -p` und ohne Suchpfad-Hinweis
  (F-5); (d) „**Ergebnis** — Das Programm ist unter dem kurzen Namen `ai-harness-init` aufrufbar" als
  unbedingte Zusage (F-5/F-6). Punkt (b) widerspricht überdies dem **dritten Absatz desselben
  Release-Textes**, der die Abdeckung korrekt mit „läuft auf linux/amd64" beschreibt: der Text
  erklärt den Abschnitt für korrekt, der die von ihm selbst korrigierte Aussage trägt.
- `verifizierbar`: **ja** — `git show v0.1.0:docs/user/benutzerhandbuch.md | sed -n '55,60p;61,66p;86,92p;104p'`
  gegen `gh release view v0.1.0 --json body`; `git diff v0.1.0 HEAD -- docs/user/benutzerhandbuch.md`
  zeigt alle vier Korrekturen als Nach-Tag-Änderungen. Kein Gate deckt es —
  `make docs-check` sieht nur den Arbeitsbaum, nie einen Tag und nie einen Release-Text.
- **Failure-Szenario (konkret).** Ein Adopter öffnet `releases/latest`, liest den Warn-Absatz,
  entnimmt ihm „nur FAQ und Anhang sind veraltet, die Installationsanleitung im Tag stimmt", und
  arbeitet die getaggte §2 auf einer frischen Maschine ohne `~/.local/bin` ab: `chmod +x` läuft,
  `mv ai-harness-init-linux-amd64 ~/.local/bin/ai-harness-init` bricht mit `No such file or
  directory` ab. Auf macOS gelingt das `mv` und `ai-harness-init --help` endet mit
  `command not found`, weil `~/.local/bin` dort nicht im Standard-`PATH` liegt — beides genau die
  zwei Fehlerpfade, die F-5 benannt hat. Er sucht den Fehler bei sich, weil der Release-Text ihm
  zugesichert hat, dieser Abschnitt sei in Ordnung.
- **Warum nicht HIGH:** kein Gate-Pfad, kein stilles Grün, keine ADR-/Gate-Berührung; die Aussage ist
  eine Unter-Berichterstattung in einem Nutzer-Artefakt. Basis-Anker MEDIUM
  („Bezug-/Abdeckungslücke" gegenüber dem von der DoD selbst benannten Gegenbeispiel), keine
  Eskalation.

### R-3 — Die erste Historie-Zeile nach [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) legt den Anlass in die Verweis-Spalte

- `kategorie`: **LOW**
- `quelle`: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 3
- `pfad`: [`spec/lastenheft.md`](../../spec/lastenheft.md) §7 Historie, Zeile `0.14.0`, Spalte *Verweis*
- `befund`: Setzung 3 teilt die zwei Spalten ausdrücklich auf — „Künftige Zeilen tragen im Verweis
  den annehmenden Akt (`Nutzer-Entscheidung YYYY-MM-DD`) …; der Anlass (ein ADR, ein **Slice-Befund**)
  bleibt in der **Änderungs-Spalte**." Die Zeile führt beides im Verweis
  („Nutzer-Entscheidung 2026-07-26 **(Anlass: slice-050-Review N-2)**"), und die Änderungs-Spalte
  nennt den Anlass nicht — sie trägt nur die technische Begründung („Grund: der 0.13.0-Wortlaut …").
  Der geschützte Kern (kein umsetzender Slice im Verweis) ist gewahrt; abgewichen ist die
  Spalten-Zuordnung im allerersten Anwendungsfall, der zum Präzedenzfall wird.
- `verifizierbar`: **ja, statisch** — `sed -n '/^| 0.14.0/p' spec/lastenheft.md` gegen den Wortlaut
  von Setzung 3. Kein Gate deckt es: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Durchsetzung sagt selbst, die Regel lebe
  „allein im **inferential-feedforward**-Quadranten".
- **Failure-Szenario (konkret).** Der Sensor, den MR-015 §Durchsetzung als Roadmap-Kandidaten
  benennt, wird gebaut und prüft — wie es die Setzung schreibt — die Verweis-Spalte gegen
  `Nutzer-Entscheidung <Datum>`. Er schlägt auf der Zeile an, die als Referenz-Anwendung gedacht war,
  oder er wird auf sie hin aufgeweicht (Freitext nach dem Datum erlaubt) und verliert damit die
  Trennschärfe, für die Setzung 3 überhaupt existiert. In der Zwischenzeit kopiert der nächste CR das
  Muster: der Verweis wächst zur zweiten Änderungs-Spalte.

### INFO-1 — Die DoD-Mess-Anweisung „belegt per `git diff --stat`" nennt keine Commit-Range

- `kategorie`: **INFO** (dokumentationswürdige, aber undokumentierte Annahme)
- `quelle`: Slice-Plan [`slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md) §2 DoD ·
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2
- `pfad`: [`slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md):45
- `befund`: Die DoD-Zeile „**`spec/lastenheft.md` unberührt** — belegt per `git diff --stat`" nennt
  kein Bezugs-Range. Seit `30f0fcd` liegt zwischen dem letzten Slice-Commit (`321b849`) und der noch
  ausstehenden Closure ein Commit, der genau diese Datei ändert. Die implizite Annahme, das Range
  ende beim letzten Slice-Commit, ist nirgends notiert.
- `verifizierbar`: ja — `git diff --stat 813418c..321b849 -- spec/` (leer) gegen
  `git diff --stat 63236d3..HEAD -- spec/` (nennt `spec/lastenheft.md`).
- **Failure-Szenario:** die Verifikation (Modul 11) fährt beim Abschluss `git diff --stat` gegen den
  Slice-Beginn, sieht `spec/lastenheft.md` und färbt die DoD-Zeile rot, obwohl kein Slice-Commit die
  Datei berührt — oder sie erklärt den Treffer per Prosa weg und entwertet damit den mechanischen
  Beleg, den MR-015 Setzung 2 gerade erst eingeführt hat. Die Rolle, die das entscheidet, ist nicht
  diese; hier steht nur die undokumentierte Annahme.

---

## Negativbefunde

- geprüft, ohne Befund: **[`README.md`](../../README.md):77 gegen [`Makefile`](../../Makefile):222** — Mengen-Vergleich der `make …`-Nennungen
  gegen die `gates:`-Prerequisites, `record-gates` (Nachweis, nicht Gate) ausgenommen: **identisch,
  sieben**, kein fehlendes und kein zusätzliches Target. Die Zahl im Text stimmt mit der Aufzählung
  überein.
- geprüft, ohne Befund: **a-check-Aussage der neuen README-Zeile gegen
  [`AGENTS.md`](../../AGENTS.md) §4 und [`harness/README.md`](../../harness/README.md) §Sensors** — beide Referenz-Fassungen sagen dasselbe
  („nicht behauptet · Dogfood flach · leerer Prüfbereich · emittiert wird es trotzdem"); die
  Kurzfassung verkürzt, ohne zu widersprechen. `grep -rn "a-check" Makefile` → kein Gate-Eintrag,
  konsistent mit „ist nicht dabei".
- geprüft, ohne Befund: **Der Release-Text gegen den Tag** — `git rev-list -n1 v0.1.0` → `0c31697e…`
  (unbewegt), `isDraft:false`, `isPrerelease:false`, `publishedAt` unverändert; `gh release edit`
  hat nur `body` berührt. **Keine Force-Operation**, [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) unberührt, keine Asset-URL
  verändert (sechs Assets, Namen zeichengleich zur [`release.yml`](../../.github/workflows/release.yml)-Matrix).
- geprüft, ohne Befund: **Die drei zutreffenden Sachaussagen des Release-Textes** — sechs
  Plattformen, die zwei genannten Doku-Stellen (Zeilen 486/524 im Tag, wörtlich getroffen), „Binaries
  nicht betroffen" (`git show --stat a4dac1f` → drei `.md`-Dateien) und die Abdeckungs-Aussage
  (linux/amd64 Voll-Durchlauf · sechs Start-Prüfungen) gegen [`ci.yml`](../../.github/workflows/ci.yml)/[`release.yml`](../../.github/workflows/release.yml).
- geprüft, ohne Befund: **Die Anforderung in [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)** — `git show 30f0fcd` weist den
  Anforderungs-Absatz **nicht** als Hunk aus; er ist byte-identisch. Die sechs `GOOS/GOARCH`-Kombinationen,
  der WSL2-Satz und die Docker-Desktop-Aussage stehen unverändert.
- geprüft, ohne Befund: **Die beiden geänderten Messmethoden-Zeilen** — `linux/amd64: Voll-Smoke`
  gegen [`ci.yml`](../../.github/workflows/ci.yml):58–62 (ein Job, `ubuntu-24.04`, keine Matrix) und
  `linux/arm64 · macos · windows: Start-Smoke` gegen [`release.yml`](../../.github/workflows/release.yml):68–80 (sechs Matrix-Einträge,
  ein gemeinsamer `start-smoke.sh`-Aufruf). Beide beschreiben, was real läuft.
- geprüft, ohne Befund: **Die Begründungs-Trennung der beiden Grenz-Notizen** — die 0.13.0-Notiz
  (kein Linux-Container-Runtime auf gehosteten macOS-/Windows-Runnern) ist im Diff unverändert und
  wird **nicht** auf `linux/arm64` ausgedehnt; die neue Notiz sagt ausdrücklich, dass sie dort nicht
  trägt. Sachlich richtig: `ubuntu-24.04-arm` ist ein Linux-Runner. Der Befund **R-1** betrifft
  ausschließlich den Auflösungs-Satz, nicht die Trennung.
- geprüft, ohne Befund: **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 am Commit** — `git show --stat 30f0fcd` → genau
  eine Datei; `git log --oneline -- spec/lastenheft.md` macht den CR ohne Prosa-Lektüre erkennbar.
  Kein `CR-*`-ID-Schema, keine CR-Datei, kein neues Target eingeführt.
- geprüft, ohne Befund: **Fußabdruck-Vollständigkeit und Versions-Stufe** — Header-Bump,
  Historie-Zeile (vierspaltig, Tabelle wohlgeformt) und die geänderte `LH-*` liegen alle im selben
  Commit; `0.14.0` folgt dem strukturgleichen Präzedenzfall 0.13.0 (alle 14 Zeilen sind `X.Y.0`).
- geprüft, ohne Befund: **Die 13 bestehenden Historie-Zeilen** — vom CR nicht angefasst; MR-015
  („Die bestehenden 13 Zeilen werden **NICHT** umgeschrieben") ist gewahrt.
- geprüft, ohne Befund: **Slice-Abgrenzung** — die DoD-Aussage „`spec/lastenheft.md` unberührt" trägt
  für die Slice-Commits: `git diff --stat 813418c..321b849` nennt keine Datei unter `spec/`. Der CR
  liegt außerhalb dieser Range.
- geprüft, ohne Befund: **Hard Rules 3.1–3.5** — beide Commits fassen weder
  [`Makefile`](../../Makefile) noch `harness/mk/`, `.d-check.yml`, Gate-Skripte oder Workflows an
  (kein Gate benannt, gelockert oder hinzugefügt); kein `//nolint`, kein `# shellcheck disable`;
  kein `git mv`; kein ADR unter [`docs/plan/adr/`](../plan/adr/0003-go-native-binaries.md) berührt. Reine Markdown-Änderungen.
- geprüft, ohne Befund: **`.harness/baseline/`** — in beiden Commits nicht enthalten, kein
  Regelwerks- oder Template-Byte berührt.
- geprüft, ohne Befund: **Ablage des Runde-2-Reports in `321b849`** — entspricht der geübten Praxis
  (`d38db74`, `3a1e37a`, `a4dac1f` legten Vorgänger-Reports ebenfalls mit der Auflösung ab); kein
  Konventions-Anker verlangt einen eigenen Commit.
- geprüft, ohne Befund: **Die fünf fremden Image-Pins** ([`Makefile`](../../Makefile):8–10, `Dockerfile`:14/35) — alle
  fünf sind Multi-Arch-Indizes **mit** `arm64`. Der Befund **R-1** ist auf die zwei selbst
  veröffentlichten `ghcr.io/pt9912/*`-Images eingegrenzt, nicht pauschal behauptet.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

### Zur wiederkehrenden Klasse — dritte Wiederholung, Steering-Loop-Signal

Die Klasse **„Zusage weiter als Abdeckung"** ([`AGENTS.md`](../../AGENTS.md) §3.6) tritt in dieser Sitzungsreihe zum
dritten Mal in Folge auf, und sie **wandert**:

| Runde | Träger der Zusage | Befund |
|---|---|---|
| 1 | Nutzer-Doku ([`benutzerhandbuch.md`](../user/benutzerhandbuch.md)) | F-1/F-3 |
| 2 | Commit-Message / Ablehnungs-Begründung („nicht reparierbar") | N-1 |
| 3 | **`spec/lastenheft.md`** (R-1) und **veröffentlichter Release-Text** (R-2) | R-1/R-2 |

Nach Skill §Kontext-Eskalation ist die dritte Wiederholung derselben Klasse in einer Sitzung
ausdrücklich **ein Steering-Loop-Signal** (Guide/Sensor nachziehen statt nur melden). Beobachtbar ist
die gemeinsame Ursache: [`AGENTS.md`](../../AGENTS.md) §3.6 zählt als Zusage-Träger „Doc-Kommentar,
Test-Name, DoD-Punkt, Commit-Message" — **`spec/lastenheft.md`** und Artefakte **außerhalb von git**
(Release-Text, Issue, Wiki) stehen nicht in der Liste, und `make mutate` kann per Konstruktion
keines von beiden erreichen. Die drei letzten Instanzen liegen alle **außerhalb** des von §3.6
aufgezählten und vom Sensor erreichbaren Bereichs. Das ist ein Regel-/Sensor-Befund, kein weiteres
Einzel-Finding — er gehört zum Roadmap-Kandidaten *Regeln ohne Feedback-Quadrant schließen* und wird
hier nur benannt, nicht gelöst (kein Lösungsvorschlag im Finding, Skill §Anti-Pattern).

---

## Verdikt

**NICHT KONFORM.**

**Merge-blockierend: ja — ein HIGH und ein MEDIUM.**

1. **R-1 (HIGH)** — der CR `30f0fcd` löst den N-2-Widerspruch korrekt auf und schreibt im selben
   Absatz eine neue, ungemessene Zusage in die **höchstrangige interne Quelle**: „es genügt, den
   Voll-Smoke zusätzlich auf einem Linux-ARM-Runner zu fahren." Gemessen ist das falsch — zwei der
   sieben gepinnten Gate-Images (`d-check`, `a-check`, beide selbst veröffentlicht) sind
   Single-Arch-`amd64`-Manifeste, und `d-check` hängt an `docs-check`, einem `gates:`-Prerequisite
   sowohl im Host- als auch im emittierten Ziel-Repo. Das Gegenbeispiel stand wörtlich im
   `verifizierbar`-Feld des Runde-2-Befunds N-2 und wurde nicht gemessen.
2. **R-2 (MEDIUM)** — der ergänzte Release-Text schließt N-1 im richtigen Kanal (unforciert, Tag
   unbewegt, auf der Seite, auf die beide Nutzer-Dokumente zeigen) und trifft fünf von sechs
   Aussagen. Die sechste spricht den Installations-Abschnitt des getaggten Handbuchs frei, der vier
   in Runde 1 belegte Defekte trägt — einer davon widerspricht dem Release-Text selbst.

**R-3 (LOW)** blockiert nicht, ist aber der **Präzedenzfall** für Setzung 3 und sollte vor der
zweiten Anwendung entschieden sein. **INFO-1** erwartet keine Aktion dieser Rolle.

**Nicht bestritten wird — geprüft und belegt, nicht geglaubt:**

- **N-3 ist vollständig behoben**; die neue README-Zeile ist mengen-identisch zu `gates:` und
  konsistent zu beiden anderen kuratierten Listen. Die dritte kuratierte Gate-Liste ist damit
  inhaltlich richtig (weiterhin ohne Sensor — Roadmap-Thema, kein Befund dieses Diffs).
- **N-1 ist als Entscheidung getroffen und veröffentlicht**, nicht vertagt: der Release-Text existiert,
  ist unforciert entstanden, der Tag ist unbewegt und [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) bleibt gewahrt.
- **N-2 ist als Vertragsthema behandelt worden, nicht still nachgebessert**: eigener CR-Commit,
  außerhalb des Slice, mit vollständigem Fußabdruck.
- **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 trägt im ersten realen Fall** — Ein-Datei-Commit, mechanisch
  auffindbar, korrekt außerhalb der Slice-Range.
- **Die Anforderung in [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ist byte-identisch geblieben** — kein Hunk, gemessen
  statt zugesagt.

**Übergabe:** R-1 geht als Vertrags-/Spec-Korrektur an die Auftraggeber-Rolle (ein Lastenheft-Satz
ist nur über [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) änderbar — kein Slice darf ihn anfassen); R-2 als
veröffentlichende Operation an den Nutzer; R-3 an die Auftraggeber-Rolle zusammen mit R-1 (dieselbe
Zeile); INFO-1 an die Verifikation. Das Steering-Loop-Signal (§3.6 erreicht `spec/` und
git-externe Artefakte nicht) gehört an die Roadmap. Der Report ersetzt **keine** Verifikation —
DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).

---

## Nachtrag der Implementation (2026-07-26) — Auflösung der Runde-3-Findings

- **R-1 (HIGH) — bestätigt, korrigiert.** Selbst nachgemessen:
  `docker manifest inspect --verbose ghcr.io/pt9912/d-check@sha256:fede3d02…` liefert
  `application/vnd.docker.distribution.manifest.v2+json` mit `"architecture": "amd64"` — ein
  **Single-Arch-Manifest**, keine Manifest-Liste. `docs-check` ist ein `gates`-Prerequisite, also
  trägt ein Linux-ARM-Runner den Voll-Smoke **nicht**. Meine Formulierung „es genügt, den
  Voll-Smoke zusätzlich auf einem Linux-ARM-Runner zu fahren" war eine **ungemessene
  Auflösungs-Zusage in der rangältesten internen Quelle** — die schwerste Ausprägung der Klasse,
  die diese Sitzung durchzieht. Ersetzt durch den gemessenen Befund; die Auflösung ist jetzt
  ausdrücklich als **offen und nicht zugesagt** ausgewiesen. Gegenprobe: `bats`, `shellcheck` und
  `actionlint` sind Manifest-Listen (multi-arch) — der Befund trifft d-check, nicht pauschal alle
  Pins.
- **R-3 (LOW) — bestätigt, korrigiert.** Der Anlass steht jetzt in der **Änderungs**-Spalte, die
  Verweis-Spalte trägt nur noch `Nutzer-Entscheidung 2026-07-26`
  ([`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 3). Der Reviewer hat recht,
  dass die **erste Anwendung Präzedenz setzt** — deshalb wurde sie nicht stehen gelassen.
- **Beides in einem eigenen Lastenheft-Commit als `0.14.1`** — Patch-Stufe, weil **keine
  Anforderung** berührt ist: die Korrektur nimmt eine falsche Aussage **zurück**, sie ändert
  keinen Vertrag. Damit ist es die erste Zeile im Repo, die kein `X.Y.0` trägt; die Abweichung ist
  in der Historie-Zeile selbst begründet. Setzung 2 gewahrt (`git show --name-only` → nur
  `spec/lastenheft.md`).
- **R-2 (MEDIUM) — bestätigt, korrigiert.** Der Satz „der Installations-Abschnitt des
  Benutzerhandbuchs ist im Tag bereits korrekt" war falsch und widersprach dem eigenen dritten
  Absatz des Release-Textes: `git show v0.1.0:docs/user/benutzerhandbuch.md` zeigt den Kasten mit
  „bei jedem Release auf **Linux**". Der Release-Text nennt jetzt **alle drei** betroffenen
  Stellen (FAQ · Anhang · Kasten), stellt die Plattform-Aussage voran und schränkt die
  Unbetroffenheits-Zusage auf das ein, was belegt ist: die sechs Binaries und die Download-/
  Installationsschritte selbst.
- **INFO-1 — behoben.** Der DoD-Punkt nennt jetzt die Range `63236d3..321b849` ausdrücklich und
  benennt `30f0fcd` als Change-Request-Commit (Nutzer-Entscheidung, kein Slice-Commit).
- **Steering-Loop-Signal übernommen.** Die Klasse ist jetzt dorthin gewandert, wo
  [`AGENTS.md`](../../AGENTS.md) §3.6 sie nicht aufzählt und `make mutate` sie nicht erreicht:
  `spec/` und **git-externe** Artefakte (der Release-Text). Das geht unverändert in die
  Closure-Notiz.
