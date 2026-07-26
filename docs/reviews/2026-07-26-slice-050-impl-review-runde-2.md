# Review-Report: slice-050 (Runde 2) — 2026-07-26

**Review-Art:** Code — geprüft wird der Diff gegen **Plan + aktive ADRs + Hard Rules +
Konventionen** (Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung
(Modul 11, getrennter Kontext, anderes Prüf-Artefakt).

**Gegenstand:** der **Auflösungs-Commit `a4dac1f`** („fix(docs): slice-050 Review-Findings
aufgeloest") — drei Dateien: [`docs/user/benutzerhandbuch.md`](../user/benutzerhandbuch.md) (32 Zeilen),
[`docs/plan/planning/in-progress/roadmap.md`](../plan/planning/in-progress/roadmap.md) (1 Zeile),
[`2026-07-26-slice-050-impl-review.md`](2026-07-26-slice-050-impl-review.md) (Runde-1-Report, 334 Zeilen neu).
Der Gesamt-Diff `63236d3..0c31697` ist in Runde 1 geprüft und wird **nicht** wiederholt; geprüft wird
hier, ob die Runde-1-Findings **am Diff** real behoben sind (nicht an der Behauptung), plus neue
Befunde ausschließlich aus `a4dac1f`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26 · **Frischer Kontext**, getrennt von
Implementation und Verifikation und von Runde 1.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan: [`in-progress/slice-050-doku-nachzug-release.md`](../plan/planning/in-progress/slice-050-doku-nachzug-release.md) (§1–§6)
- berührte `LH-*`-IDs: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (samt
  §*Grenze der Messmethode*), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- aktive ADRs: keine im Diff geändert; mittelbar [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules 3.1–3.6) · Konventionen
  [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
- **Vorherige Findings am gleichen Modul (Pflicht-Punkt 5):** der
  [Runde-1-Report](2026-07-26-slice-050-impl-review.md) (1 HIGH, 3 MEDIUM, 3 LOW, 3 INFO) und die vier
  slice-049-Runden ([1](2026-07-26-slice-049-impl-review.md), [2](2026-07-26-slice-049-impl-review-runde-2.md),
  [3](2026-07-26-slice-049-impl-review-runde-3.md), [4](2026-07-26-slice-049-impl-review-runde-4.md)) —
  dominante Klasse: **„Zusage weiter als Abdeckung"** ([`AGENTS.md`](../../AGENTS.md) §3.6)
- Rollen-Vertrag: `.harness/skills/reviewer.md`, <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
  `.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md` (beide vollständig gelesen)

**Eigene Sensoren (lesend, Docker-only nach [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)):**
`make docs-check` → „d-check: 188 Datei(en) geprüft, 0 Befund(e)" (Lauf **vor** Ablage dieses Reports;
mit ihm: 189/0) · vollständig gelesen:
[`.github/workflows/release.yml`](../../.github/workflows/release.yml), [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml),
[`Makefile`](../../Makefile) (`gates`/`artifact`/`release-artifacts`), `harness/tools/full-smoke.sh`,
[`README.md`](../../README.md), [`benutzerhandbuch.md`](../user/benutzerhandbuch.md) ·
`git show a4dac1f` / `git show v0.1.0:…` / `git rev-list -n1 v0.1.0` / eigene `grep`-Sweeps (unten
protokolliert) · `gh release view v0.1.0 --json …`. **Nicht** gefahren: `make gates`, `make mutate`,
`make test` (mutierend bzw. verifizierende Rolle).

---

## Status der Runde-1-Findings

Geprüft **am Diff von `a4dac1f`**, nicht an der Commit-Message.

### F-1 (HIGH) — FAQ „Derzeit nicht" · **behoben am HEAD, offen im getaggten Stand**

Der Diff schreibt [`benutzerhandbuch.md`](../user/benutzerhandbuch.md):494–495 auf „**Ja, ab `v0.1.0`** — für sechs
Plattformen …" um; die Antwort nennt den Download als empfohlenen Weg und verweist auf §2. Am HEAD
ist der Widerspruch damit weg. **Nicht** weg ist er im veröffentlichten Stand:
`git show v0.1.0:docs/user/benutzerhandbuch.md | grep -n "Derzeit nicht"` → Zeile 486 unverändert
(`git rev-list -n1 v0.1.0` → `0c31697e…`, `a4dac1f` liegt **nach** dem Tag). Rest siehe **N-1** und §(C).

**Ursachen-Nachprüfung (eigene Suche, nicht die des Implementers).** Der Plan behauptete in §3
„Weitere Stellen gibt es nicht". Ich habe die Behauptung mit vier voneinander unabhängigen Mustern
neu gemessen — bewusst **nicht** mit dem Muster des Implementers und **nicht** mit seiner Gegenprobe
(beide sind Treffer-Listen auf genau die schon bekannten Formulierungen):

1. `grep -n -i "noch nicht\|derzeit\|bisher\|geplant\|künftig\|zukünftig\|später\|kein Binary\|keine Binaries\|Entwicklungsstand\|nicht verfügbar\|noch keine\|gibt es nicht\|steht noch\|in Arbeit\|vorgefertigt\|fertige\|selbst bauen\|aus dem Quellcode" docs/user/benutzerhandbuch.md`
   → 17 Treffer-Zeilen (4, 57, 75, 77, 116, 219, 223, 231, 283, 347, 387, 413, 434, 480, 495, 533, 550),
   **alle** aktuell.
2. `grep -n -i "installier\|Installation\|herunterlad\|Download\|command not found\|make artifact\|\./bin\|klonen\|clone\|beschaffen\|bereitstellen\|Binary\|Programm" docs/user/benutzerhandbuch.md`
   → **keine zweite Installations-Beschreibung** außerhalb §2; §7 Fehlerbehebung und §9 Glossar
   enthalten keine Beschaffungs-Aussage.
3. Vollständige Lektüre von §1, §2, §7, §8, §9, §10, §11 des Handbuchs (nicht nur Treffer-Zeilen).
4. [`README.md`](../../README.md) vollständig gelesen (83 Zeilen) plus
   `grep -n -i "noch nicht\|derzeit\|fehlt\|fehlen\|Release\|Version\|Stand\|M4\|M5\|folgt" README.md`.

**Ergebnis:** Für die Achsen *fehlender Release* und *Nur-Quellcode-Weg* ist der Allquantor jetzt
gedeckt — es gibt in beiden Dateien keine weitere solche Stelle. Für die dritte Achse *veralteter
Stand* nicht: [`README.md`](../../README.md):77 trägt eine seit `604957f` (slice-001b) unveränderte Gate-Aussage,
die heute falsch ist → **N-3**.

### F-2 (MEDIUM) — Anhang „keine Release-Versionsnummer" · **behoben am HEAD, offen im getaggten Stand**

[`benutzerhandbuch.md`](../user/benutzerhandbuch.md):533 lautet jetzt „Im Quellcode-Repository liegt **kein** eingecheckt
vorliegendes Binary und kein `run`-Ziel. Fertige Programme gibt es **an den Releases** (ab `v0.1.0`);
wer aus dem Quellcode baut, arbeitet gegen den Repo-Stand und hat dann keine Versions-Kennzeichnung."
Das ist widerspruchsfrei zu Zeile 4 (`Software-Stand: v0.1.0`) und zu den Zeilen 75 und 495: die
Nicht-Versionierung gilt nur noch für den Bau aus Quelle. Im Tag steht Zeile 524 unverändert
(`git show v0.1.0:… | sed -n '524p'`) → **N-1**.

### F-3 (MEDIUM) — Voll-Durchlauf beim Release · **behoben, jede Aussage des neuen Kastens nachgemessen**

Der neue Kasten ([`benutzerhandbuch.md`](../user/benutzerhandbuch.md):61–71) macht vier prüfbare Aussagen. Ich habe
**jede einzeln** gegen die Workflows gehalten, nicht die Korrektur als Ganzes geglaubt:

| Aussage im Kasten | Beleg | Urteil |
|---|---|---|
| „Bei jeder Änderung am Quellcode läuft der **vollständige Durchlauf** (Repo aufsetzen, Prüfungen grün)" | [`ci.yml`](../../.github/workflows/ci.yml):25–26 `on: push` + `pull_request`; Job `full-smoke` (`:58–62`) ruft `make full-smoke`; `harness/tools/full-smoke.sh` bootstrappt in ein tmp-Repo und fährt dort `make -j gates` | **trifft zu** |
| „— auf **Linux/Intel-AMD**, auf einer Maschine" | [`ci.yml`](../../.github/workflows/ci.yml):59 `runs-on: ubuntu-24.04` (x64), **ein** Job, keine `matrix`; `grep -n "runs-on" .github/workflows/ci.yml` → viermal `ubuntu-24.04`, kein arm-Runner | **trifft zu** |
| „Beim Erstellen eines Release wird auf **allen sechs** ausgelieferten Dateien geprüft, dass das Programm **startet**. Mehr nicht." | [`release.yml`](../../.github/workflows/release.yml):63–98 — `matrix.include` mit genau sechs Runner/Binary-Paaren, auf jedem derselbe Aufruf `harness/tools/start-smoke.sh`; `publish` (`:102`) hat `needs: start-smoke`, die Start-Prüfung ist also Vorbedingung der Veröffentlichung; im ganzen Workflow **kein** Voll-Smoke (nur `make release-artifacts` im Job `artifacts`) | **trifft zu** |
| „Für macOS, Windows und **Linux/ARM** ist damit belegt, dass das Programm dort **läuft** — nicht, dass ein kompletter Durchlauf dort durchläuft. Grund **für macOS und Windows**: die gehosteten Prüf-Maschinen können die benötigten Linux-Container nicht fahren." | [`release.yml`](../../.github/workflows/release.yml):71 `ubuntu-24.04-arm` → `ai-harness-init-linux-arm64` bekommt denselben Start-Smoke; die Container-Begründung ist auf macOS/Windows **eingegrenzt** und deckt sich mit [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) §Grenze der Messmethode | **trifft zu** |

Die Runde-1-Überklage („bei jedem Release auf Linux") ist damit ersetzt durch eine Formulierung, die
die zwei realen Achsen trennt — **Auslöser** (Push vs. Tag) und **Abdeckung** (Voll- vs.
Start-Prüfung). Keine Aussage des Kastens blieb unbelegt.

### F-4 (MEDIUM) — Betriebssystem- vs. Architektur-Achse · **behoben**

Der Kasten nennt jetzt beide Achsen und stellt Linux/ARM ausdrücklich zu macOS/Windows
([`benutzerhandbuch.md`](../user/benutzerhandbuch.md):69). Die Zuordnung ist gegen die Asset-Tabelle (`:83–90`) und die
`matrix` in [`release.yml`](../../.github/workflows/release.yml):68–80 widerspruchsfrei. **Folge, die der Fix sichtbar
macht:** der Kasten ist damit **enger** als die Messmethode in
[`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix), die den Voll-Smoke pauschal für „linux" zusagt → **N-2**
(kein Mangel des Kastens, sondern ein Quellen-Konflikt).

### F-5 (LOW) — `~/.local/bin` als unbedingte Zusage · **behoben**

`mkdir -p ~/.local/bin` ergänzt (`:96`), der Suchpfad zur ausdrücklichen Voraussetzung gemacht
(`:100`, inkl. der zutreffenden macOS-Aussage, dass `~/.local/bin` dort nicht im Standard-`PATH`
liegt), und das Ergebnis-Versprechen ist bedingt formuliert: „**Liegt der Ordner in Ihrem Suchpfad**,
ist das Programm … aufrufbar" (`:114`). Beide Fehlerpfade des Runde-1-Befunds sind adressiert.

### F-6 (LOW) — Kurznamen-Konvention nur in Weg A · **behoben**

`:114` lautet jetzt „**Das Handbuch verwendet ab hier diesen kurzen Aufruf** — das gilt für beide
Wege." Der Satz steht in Dokument-Reihenfolge **vor** Weg B (`:116`), und §2 hat keine
Unter-Einträge im Inhaltsverzeichnis, über die ein Leser ihn überspringen könnte. Die Rest-Reibung
(Weg B endet weiterhin mit „Kopieren Sie es **bei Bedarf** …", `:143`) wird **nicht** als neues
Finding geführt: der Geltungsbereich ist jetzt ausdrücklich benannt, der Runde-1-Befund
(„Weg-B-Leser erfahren die Konvention nicht") trifft nicht mehr zu.

### F-7 (LOW) — Systemanforderungen empfehlen zwei Plattformen · **behoben**

`:57` führt jetzt „Linux, macOS oder Windows (für alle drei gibt es fertige Programme; was auf
welcher Plattform geprüft wird, steht im Kasten unten)" — die Empfehlungs-Asymmetrie ist weg, und der
Verweis führt auf die Messgrenze, statt sie zu verschweigen. Deckt sich mit
[`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) („Erstklassig auf allen dreien ohne WSL2-Zwang").

### INFO-1 — dritte Instanz „Move-Commit lässt Inbound-Links hängen" · **eingetragen**

[`roadmap.md`](../plan/planning/in-progress/roadmap.md):44 (Kandidat *Doku- und Sensor-Wartung*, Achse 4) trägt jetzt
„**Dritte gemessene Instanz (2026-07-26, slice-050-Review INFO-1: `38b60ed` ließ dieselben zwei
Roadmap-Links hängen …)**". Die Zahl ist nachgemessen und stimmt:
`git show 38b60ed:docs/plan/planning/in-progress/roadmap.md | grep -c "open/slice-050-doku-nachzug-release.md"`
→ `2`; `git show --stat 38b60ed` → reiner Rename, 0 insertions / 0 deletions.

### INFO-2 — FAQ-Sprachliste · **korrigiert**

`:480` lautet „Derzeit `go` und `cpp` (C++)" — konsistent mit Zeile 4, `:347` und `:434`.

### INFO-3 — Änderungshistorie 1.5 · **ergänzt**

`:550` trägt eine 1.5-Zeile. Ihre Inhaltsangaben (Dateitabelle · Suchpfad-Hinweis ·
macOS-Quarantäne-Hinweis · Kasten „Was wo geprüft wird" · FAQ/Anhang/Systemanforderungen ·
`cpp`-Korrektur) sind alle im Dokument belegt; die Kurzfassung des Kastens („der vollständige
Durchlauf läuft auf Linux/Intel-AMD, beim Release wird auf allen sechs Dateien nur der **Start**
geprüft") ist mit der Workflow-Messung oben deckungsgleich — die Historien-Zeile ist keine zweite,
gröbere Zusage.

---

## Neue Findings

### N-1 — Der veröffentlichte `v0.1.0`-Stand trägt die F-1/F-2-Fehler weiter, und die Auflösung erklärt sie pauschal für „nicht reparierbar"

- `kategorie`: MEDIUM
- `quelle`: Hard Rule 3.6 ([`AGENTS.md`](../../AGENTS.md) §3.6) · Slice-Plan §1 Ziel und §3 Reihenfolge
  („der Tag wird **aus diesem Commit** geschnitten, damit der veröffentlichte Stand die richtige Doku trägt")
- `pfad`: `a4dac1f` Commit-Message („OFFEN UND NICHT REPARIERBAR") gegen
  `git show v0.1.0:docs/user/benutzerhandbuch.md` Zeilen 486 und 524
- `befund`: Der Tag zeigt weiter auf `0c31697` (`git rev-list -n1 v0.1.0`), der getaggte Stand
  verneint in der FAQ den Release, den dasselbe Dokument in Zeile 4 führt. Die Auflösung stuft den
  Punkt als „nicht reparierbar" ein und verweist auf Closure-Notiz bzw. ein späteres `v0.1.1`; die
  Einstufung ist **breiter als das, was sie belegt** — unbeweglich ohne Force-Operation ist der
  **Tag**, nicht der **Release-Text**: `gh release view v0.1.0 --json body` liefert heute genau
  `**Full Changelog**: …/commits/v0.1.0`, und diese Seite ist der Landepunkt, auf den
  [`README.md`](../../README.md):43 und [`benutzerhandbuch.md`](../user/benutzerhandbuch.md):81 mit `releases/latest` zeigen. Der einzige
  unforcierte Korrektur-Kanal ist damit ungeprüft geblieben, statt abgewogen zu werden — dieselbe
  Klasse wie F-1 (Aussage weiter als ihre Messung), diesmal in der Auflösung selbst.
- `verifizierbar`: ja — `git show v0.1.0:docs/user/benutzerhandbuch.md | sed -n '486p;524p'` zeigt
  beide Sätze im veröffentlichten Stand; `gh release view v0.1.0 --json body` zeigt den
  unkorrigierten Release-Text. Kein Gate deckt es (`make docs-check` sieht nur den Arbeitsbaum,
  nie einen Tag).

### N-2 — Der korrigierte Kasten ist enger als die Messmethode, die [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) für `linux` zusagt

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) §Messmethode ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · Source Precedence ([`AGENTS.md`](../../AGENTS.md) §1)
- `pfad`: [`spec/lastenheft.md`](../../spec/lastenheft.md) §LH-QA-04 („**linux:** **Voll-Smoke**") gegen
  [`benutzerhandbuch.md`](../user/benutzerhandbuch.md):65 und [`ci.yml`](../../.github/workflows/ci.yml):59
- `befund`: Die Messmethode staffelt nach Betriebssystem und sagt für `linux` einen Voll-Smoke zu;
  die §*Grenze der Messmethode* nennt als Ausnahme nur macOS und Windows. Real fährt den Voll-Smoke
  ausschließlich `ubuntu-24.04` (amd64) — `linux/arm64` bekommt in
  [`release.yml`](../../.github/workflows/release.yml):71 denselben Start-Smoke wie die macOS-/Windows-Assets, obwohl der
  `ubuntu-24.04-arm`-Runner Linux-Container fährt, die dort genannte Begründung also **nicht**
  greift. Der Kasten aus `a4dac1f` sagt das erstmals korrekt; damit widerspricht die niederrangige
  Nutzer-Doku der höherrangigen Quelle, und der Widerspruch geht zu Lasten der höherrangigen. Der
  Diff ist **nicht** die Ursache — er macht die Lücke sichtbar.
- `verifizierbar`: ja — `grep -n "runs-on" .github/workflows/ci.yml` (viermal `ubuntu-24.04`, kein
  arm-Runner) gegen `.github/workflows/release.yml`:71 und den `linux`-Aufzählungspunkt in
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix). Failure-Szenario: eine arch-abhängige Regression im Bootstrap (etwa
  ein gepinntes Gate-Image ohne `arm64`-Manifest) bleibt von allen Sensoren unentdeckt —
  [`ci.yml`](../../.github/workflows/ci.yml) fährt den Bootstrap nur auf amd64, [`release.yml`](../../.github/workflows/release.yml) prüft auf `arm64`
  nur `--help` —, während das Lastenheft für `linux` einen Bootstrap-Nachweis behauptet und das
  Asset `ai-harness-init-linux-arm64` ausgeliefert wird.

### N-3 — Die Gate-Zeile des [`README.md`](../../README.md) behauptet einen veralteten Stand

- `kategorie`: LOW
- `quelle`: Maintainability (Doku-Drift) · [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) · Lastenheft-CR 0.11.0
  („Zielrepo-Fokus (nicht ai-harness-init selbst), a-check emitted-only")
- `pfad`: [`README.md`](../../README.md):77
- `befund`: Die Zeile schließt mit „(Das arch-Gate a-check **folgt** mit dem Go-Code.)" — der
  Go-Code ist längst da (M4 am 2026-07-25 erreicht), und a-check ist per CR 0.11.0 **emitted-only**
  für Zielrepos; `grep -rn "a-check" Makefile harness/mk/` findet in diesem Repo **keinen**
  Gate-Eintrag, und `gates:` ([`Makefile`](../../Makefile):222) enthält keinen. Dieselbe Zeile zählt außerdem
  fünf Gates auf (`docs-check`, `test`, `lint`, `build`, `shell-lint`), während `make gates` acht
  Prerequisites fährt — `baseline-verify` und `ci-lint` fehlen. Beide Aussagen fallen in die Achse
  *veralteter Stand*, die der Slice-Plan mit „Weitere Stellen gibt es nicht" mit abgedeckt glaubte;
  sie stehen außerhalb des Diffs und außerhalb der DoD.
- `verifizierbar`: ja, statisch — `grep -n "^gates:" Makefile` gegen [`README.md`](../../README.md):77.
  Failure-Szenario: ein Beitragender liest die Zeile, um zu erfahren, was `make gates` fährt, und
  hält `baseline-verify`/`ci-lint` für nicht existent, während er zugleich auf ein arch-Gate für
  dieses Repo wartet, das per Lastenheft nie kommt. Kein Gate hält die README-Liste gegen den
  Makefile — genau die Lücke, die der Roadmap-Kandidat *Regeln ohne Feedback-Quadrant schließen*
  für [`AGENTS.md`](../../AGENTS.md) §4 und `harness/README.md` §Sensors führt; das README ist die **dritte**, dort
  noch nicht genannte kuratierte Liste. Keine Eskalation in den Gate-Pfad: der Diff lockert kein
  Gate, und kein Gate meldet still grün.

---

## (C) Urteil zum offen gemeldeten Punkt: Tag `v0.1.0` trägt die F-1/F-2-Fehler

**Die Ablehnung des Re-Tags ist tragfähig — die Einstufung „nicht reparierbar" ist es nicht.**

*Warum der Re-Tag zu Recht unterbleibt.* Ein bewegter Tag auf einem veröffentlichten Release ist
eine Force-Operation mit Außenwirkung: die unter demselben Tag ausgelieferten Quell-Archive änderten
ihren Inhalt bei gleichbleibender URL, jeder Pin auf `v0.1.0` bekäme rückwirkend einen anderen Stand.
Das kollidiert direkt mit [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (gleiche Eingabe → gleiches Ergebnis) und
mit der Setzung des Slice-Plans §6, ein Tag sei „nach außen wirkend und schlecht umkehrbar … eine
bewusste Nutzer-Operation. Vor dem Push ist die Zustimmung einzuholen" — was für den Push gilt, gilt
erst recht für das Überschreiben. Der Schaden wäre zudem asymmetrisch: die sechs Binaries sind von
den Doku-Fehlern **nicht** betroffen (reiner Markdown-Diff, `git show --stat a4dac1f` nennt drei
`.md`-Dateien), und der Fehler im getaggten Stand ist eine **Unter**-, keine Überklage — der Leser
wird über einen existierenden Download informiert, es gebe ihn nicht, nicht umgekehrt. Dass der
Implementer das nicht allein entscheidet, ist rollenkonform.

*Warum daraus trotzdem ein Finding wird (N-1).* Die Auflösung springt von „kein Re-Tag" direkt auf
„nicht reparierbar" und von dort in die Closure-Notiz. Dazwischen liegt ein ungeprüfter Kanal: der
**Release-Text** ist ohne jede Force-Operation änderbar und trägt heute nur
`**Full Changelog**: …/commits/v0.1.0` — und genau diese Seite ist der Landepunkt, auf den beide
Nutzer-Dokumente mit `releases/latest` zeigen. Ob man ihn nutzt, ist eine Nutzer-Entscheidung; dass
er ungenannt blieb, macht „nicht reparierbar" zu einer Zusage, die breiter ist als ihre Prüfung —
dieselbe Klasse, die diesen Slice schon F-1 gekostet hat. Ein Punkt, der ohne Abwägung seiner
Optionen in eine Notiz wandert, ist vertagt, nicht entschieden.

**Failure-Szenario (konkret, nicht hypothetisch).** Ein Adopter pinnt das Werkzeug auf `v0.1.0` und
liest die Dokumentation an diesem Tag — über das Quell-Archiv des Release, über die GitHub-Ansicht
`tree/v0.1.0` oder nach `git checkout v0.1.0`. Er trifft in §8 auf „Gibt es ein fertiges
Download-Binary? — **Derzeit nicht**" und im Anhang auf „daher **keine** Release-Versionsnummer",
klont daraufhin das Repo und baut über `make artifact DEST=./bin` aus der Quelle — während sechs für
ihn gebaute Binaries an genau dem Release hängen, aus dem er den Stand bezogen hat. Es ist das
Gegenbeispiel, das die DoD des Slice selbst benennt („ein Leser, der die Doku des getaggten Standes
liest und keinen Download findet"), und es ist am veröffentlichten Artefakt weiterhin rot. Nichts am
Release korrigiert es, obwohl der Korrektur-Kanal offensteht.

---

## Negativbefunde

- geprüft, ohne Befund: **jede einzelne Aussage des neuen Kastens** gegen
  [`ci.yml`](../../.github/workflows/ci.yml) und [`release.yml`](../../.github/workflows/release.yml) — vier Aussagen, vier Belege, Tabelle unter
  F-3. Insbesondere hängt `publish` über `needs: start-smoke` **wirklich** an allen sechs
  Start-Prüfungen (`fail-fast: false` verdeckt nichts — ein roter Matrix-Job lässt `start-smoke`
  scheitern und `publish` entfallen), und `ci.yml` trägt **keinen** arm-Runner.
- geprüft, ohne Befund: **die sechs Asset-Namen und ihre Runner-Zuordnung** in
  [`benutzerhandbuch.md`](../user/benutzerhandbuch.md):83–90 gegen [`release.yml`](../../.github/workflows/release.yml):68–80 und gegen
  `gh release view v0.1.0 --json assets` (exakt sechs, zeichengleich, `draft: false`,
  `prerelease: false`) — vom Diff nicht angefasst, erneut gegengelesen, weil der Kasten jetzt auf
  sie verweist.
- geprüft, ohne Befund: **Weg A nach dem F-5-Fix** — `chmod` → `mkdir -p` → `mv` → PATH-Prüfung →
  `--help` ist in sich vollständig; der macOS-Quarantäne-Hinweis (`:110`) und der Windows-Satz
  (`:102`) stehen unverändert und passen zur neuen Schrittfolge.
- geprüft, ohne Befund: **Weg B unberührt** — der Diff fasst die Zeilen 116–145 nicht an; Klonen,
  `make artifact DEST=./bin`, `./bin/ai-harness-init --help` und der `DEST`-Pflichthinweis stehen
  vollständig.
- geprüft, ohne Befund: **[`spec/lastenheft.md`](../../spec/lastenheft.md) unberührt** — `a4dac1f` nennt drei Dateien, keine
  in `spec/`; [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) gewahrt. (Der in **N-2** gemeldete Konflikt ist genau deshalb ein
  CR-Thema und keine stille Nachbesserung.)
- geprüft, ohne Befund: **Hard Rules 3.1/3.2/3.3/3.4/3.5** — der Diff berührt weder
  [`Makefile`](../../Makefile) noch `harness/mk/`, `.d-check.yml`, Gate-Skripte oder Workflows (kein Gate benannt,
  gelockert oder hinzugefügt); kein `//nolint`, kein `# shellcheck disable`; kein `git mv`; kein ADR
  unter [`docs/plan/adr/`](../plan/adr/0003-go-native-binaries.md). Reine Markdown-Änderung.
- geprüft, ohne Befund: **Prozess-Vokabular in `docs/user/`** (Slice-Plan §6) — die 32 geänderten
  Zeilen enthalten keine Slice-/Welle-ID, keinen Gate-Namen und keinen Workflow-Namen; der Kasten
  spricht durchgehend Nutzer-Sprache („vollständiger Durchlauf", „Start", „Prüf-Maschinen").
- geprüft, ohne Befund: **Roadmap-Änderung** — eine Zeile (Kandidat *Doku- und Sensor-Wartung*),
  additiv; die vorhandene Zweit-Instanz bleibt erhalten, M5 bleibt plan-konform auf **offen** (§3
  legt die Fortschreibung in den Closure-Schritt), alle Links im Endzustand auflösbar.
- geprüft, ohne Befund: **Ablage des Runde-1-Reports im selben Commit** — entspricht der geübten
  Praxis dieses Repos (`d38db74` und `3a1e37a` legten die slice-049-Reports ebenfalls zusammen mit
  der Auflösung ab); kein Konventions-Anker verlangt einen eigenen Commit.
- geprüft, ohne Befund: **Doku-Gate** — `make docs-check`: „d-check: 188 Datei(en) geprüft,
  0 Befund(e)". Die Zahl ist gegenüber Runde 1 (187) um genau die neu abgelegte Report-Datei
  gewachsen; die vom Implementer genannte Zahl ist damit unabhängig reproduziert. Nach Ablage
  dieses Reports: 189 Datei(en), 0 Befund(e) — die neuen Verweise lösen alle auf.
- geprüft, ohne Befund: **`.harness/baseline/`** — im Diff nicht enthalten, kein Regelwerks- oder
  Template-Byte berührt.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 1 |
| INFO | 0 |

**Zur wiederkehrenden Klasse.** Alle sieben Runde-1-Findings sind am Diff real behoben; die Klasse
„Zusage weiter als Abdeckung" ist im **Artefakt** damit geschlossen. Sie tritt in dieser Runde nur
noch an einer Stelle auf — in der **Auflösung selbst** (N-1: „nicht reparierbar" ist breiter als
geprüft). Nach Skill §Kontext-Eskalation ist die erneute Wiederholung derselben Klasse innerhalb
dieser Sitzungsreihe ein **Steering-Loop-Signal**: nicht ein weiteres Einzel-Finding, sondern ein
Hinweis, dass die Regel „jede Ist-Aussage nennt ihr Messkommando" bislang nur für Ist-Messungen im
Plan gilt — nicht für **Unmöglichkeits**-Aussagen in Commit-Messages und Closure-Notizen.

## Verdikt

**NICHT KONFORM.**

**Merge-blockierend:** ja — zwei MEDIUM. Die Begründung ist ausdrücklich **nicht**, dass `a4dac1f`
mangelhaft wäre: der Auflösungs-Commit behebt alle sieben Runde-1-Findings real, und jede der vier
Aussagen des neu gefassten Kastens ist gegen die Workflows belegbar — geprüft, nicht geglaubt. Der
Block hängt an zwei Punkten, die **außerhalb** des Diffs entschieden werden müssen und deshalb die
MEDIUM-Definition „vor Merge zu klären" wörtlich treffen:

1. **N-1** — der veröffentlichte `v0.1.0`-Stand trägt das von der DoD selbst benannte Gegenbeispiel
   weiterhin, und die Einstufung „nicht reparierbar" ist ungeprüft breiter als ihr Beleg. Das ist
   eine Nutzer-Entscheidung (Release-Text korrigieren · `v0.1.1` · bewusst hinnehmen) — sie muss
   **getroffen und begründet abgelegt** werden, nicht per Notiz vertagt.
2. **N-2** — die Messmethode in [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) sagt für `linux` mehr zu, als real läuft.
   Auflösbar nur über einen CR ([`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) oder über einen zweiten Voll-Smoke-Runner —
   in beiden Fällen nicht im Rahmen dieses Diffs, aber vor dem Abschluss eines Slice zu klären,
   dessen erklärtes Ziel die Wahrheit über die Plattform-Abdeckung ist.

**N-3** (LOW) blockiert nicht und ist ausdrücklich als Fund **außerhalb** des Slice-Gegenstands
markiert; er gehört zum Roadmap-Kandidaten *Regeln ohne Feedback-Quadrant schließen* (dritte
kuratierte Liste ohne Sensor).

**Nicht bestritten wird:** die vollständige Auflösung aller Runde-1-Findings, die Belegbarkeit jeder
Aussage des neuen Kastens, die Erhaltung von Weg B, die Unberührtheit von
[`spec/lastenheft.md`](../../spec/lastenheft.md) und der Gate-Fläche sowie die korrekte Übernahme der dritten
Move-Instanz in die Roadmap — alle in den Negativbefunden belegt.

**Übergabe:** N-1 geht als Entscheidungsvorlage an den Nutzer (nicht an die Implementation — die
Rolle darf sie nicht treffen), N-2 als CR-Vorlage an die Auftraggeber-Rolle
([`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)), N-3 an die Roadmap. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität
prüft der Verifier separat (Modul 11).

---

## Nachtrag der Implementation (2026-07-26) — Auflösung der Runde-2-Findings

- **N-3 (LOW) — bestätigt, behoben.** `README.md`:77 listete fünf von sieben `gates:`-Prerequisites
  (`baseline-verify` und `ci-lint` fehlten) und trug die seit CR 0.11.0 überholte Aussage „(Das
  arch-Gate a-check folgt mit dem Go-Code.)" — a-check ist **emitted-only**, im Dogfood hätte es
  einen leeren Prüfbereich. Beides korrigiert; die Formulierung folgt jetzt `AGENTS.md` §4 und
  `harness/README.md` §Sensors. **Gegenprobe gefahren** (Mengen-Vergleich der `make …`-Nennungen in
  der README-Zeile gegen die `gates:`-Prerequisites im `Makefile`, `record-gates` ausgenommen):
  identisch, sieben Gates, kein fehlendes und kein zusätzliches.
- **N-1 (MEDIUM) — bestätigt, meine Einstufung war zu breit; die Abhilfe geht an den Nutzer.**
  Nachgemessen: `gh release view v0.1.0 --json body` enthält nur die automatisch erzeugte Zeile
  „Full Changelog"; `README.md`:43 und `docs/user/benutzerhandbuch.md`:81 zeigen beide auf
  `releases/latest`. Der Reviewer hat recht: **unbeweglich ohne Force ist der Tag, nicht der
  Release-Text.** „Nicht reparierbar" war damit eine Aussage über den falschen Kanal — dieselbe
  Klasse „Zusage/Einstufung weiter als ihr Beleg", diesmal in einer Ablehnungs-Begründung.
  Korrigiert wird die Einstufung hier; die Handlung selbst (Release-Text ergänzen) ist eine
  **veröffentlichende Operation** und damit keine Implementer-Entscheidung — sie liegt dem Nutzer
  vor.
- **N-2 (MEDIUM) — bestätigt, und ausdrücklich NICHT hier behoben.** `LH-QA-04` §Messmethode sagt
  für **linux** einen Voll-Smoke zu; real läuft er nur auf `ubuntu-24.04` (amd64), `linux/arm64`
  bekommt nur den Start-Smoke — und die im Lastenheft benannte Grenzbegründung („die gehosteten
  Runner tragen kein Linux-Container-Runtime") trägt für einen Linux-ARM-Runner **nicht**. Das ist
  eine Lücke zwischen Anforderung und Realität, also ein **Vertragsthema**: nach
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) darf
  **kein Slice** `LH-*` ändern. Der Punkt geht als Change-Request-Vorschlag an den Nutzer und in die
  Closure-Notiz; ihn hier zu „reparieren" wäre genau der Vollzugs-Fehler, den slice-049 verankert
  hat. Positiv festzuhalten: sichtbar wurde er erst, weil der korrigierte Kasten die Achsen trennt.
