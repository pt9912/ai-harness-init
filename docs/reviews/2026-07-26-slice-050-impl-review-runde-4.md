# Review-Report: slice-050 (Runde 4) — 2026-07-26

**Review-Art:** Code — geprüft wird gegen **Plan + aktive ADRs + Hard Rules + Konventionen**
(Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung (Modul 11, getrennter Kontext,
anderes Prüf-Artefakt).

**Gegenstand — eng und abschließend. Alles vor `321b849` ist in den Runden 1–3 geprüft und wird
nicht wiederholt.** Drei Artefakte:

1. **`614351e`** („spec: Korrektur Lastenheft 0.14.0 -> 0.14.1") — Auflösung von **R-1 (HIGH)** und
   **R-3 (LOW)**; eine Datei ([`spec/lastenheft.md`](../../spec/lastenheft.md), +9/−5).
2. **`3780d21`** („fix(docs): slice-050 Review-Runde-3-Findings") — Auflösung von **R-2 (MEDIUM)**
   und **INFO-1**; zwei Dateien
   (`in-progress/slice-050-doku-nachzug-release.md` +5/−1,
   [`2026-07-26-slice-050-impl-review-runde-3.md`](2026-07-26-slice-050-impl-review-runde-3.md) 524 Zeilen neu).
3. **Der Release-Text von `v0.1.0`** — ein Artefakt **außerhalb von git**, per
   `gh release view v0.1.0 --json body` gelesen.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-26 · **Frischer Kontext**, getrennt von
Implementation und Verifikation und von den Runden 1–3.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan: `in-progress/slice-050-doku-nachzug-release.md` (§1 Ziel, §2 DoD, §3 Dateitabelle, §5 Closure-Trigger)
- berührte `LH-*`-IDs: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Anforderung, Messmethode, **beide** Grenz-Notizen),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- aktive ADRs: keine im Diff geändert; mittelbar [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules 3.1–3.6, vollständig gelesen) und §4 (Quality Gates) ·
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) (vollständig gelesen — adoptierter Wortlaut, Setzungen 1/2/3, Cutoff, Durchsetzung)
- **Vorherige Findings am gleichen Modul (Pflicht-Punkt 5):** [Runde 1](2026-07-26-slice-050-impl-review.md)
  (1 HIGH, 3 MEDIUM, 3 LOW, 3 INFO), [Runde 2](2026-07-26-slice-050-impl-review-runde-2.md)
  (0 HIGH, 2 MEDIUM, 1 LOW), [Runde 3](2026-07-26-slice-050-impl-review-runde-3.md)
  (1 HIGH, 1 MEDIUM, 1 LOW, 1 INFO) **inkl. Nachtrag der Implementation** — dominante Klasse:
  **„Zusage weiter als Abdeckung"** ([`AGENTS.md`](../../AGENTS.md) §3.6)
- Rollen-Vertrag: `.harness/skills/reviewer.md`, <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad) -->
  `.harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md` (beide vollständig gelesen)

**Eigene Sensoren (lesend, Docker-only nach [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)):**
`make docs-check` (Ausgabe unten) · **`docker manifest inspect --verbose`** gegen vier gepinnte
Images (lesende Registry-Abfrage, keine mutierende Docker-Operation) ·
`gh release view v0.1.0 --json body,assets,tagName,isDraft,isPrerelease,publishedAt` ·
`git show 614351e 3780d21` / `git show v0.1.0:docs/user/benutzerhandbuch.md` /
`git diff v0.1.0 HEAD -- docs/user/benutzerhandbuch.md` / `git log -S… -- …` ·
vollständig gelesen: [`Makefile`](../../Makefile) (Target `gates`, Image-Pins), `d-check.mk`,
`harness/tools/full-smoke.sh`, [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml),
[`.github/workflows/release.yml`](../../.github/workflows/release.yml),
[`spec/lastenheft.md`](../../spec/lastenheft.md) §LH-QA-04 + §7 Historie,
[`harness/conventions.md`](../../harness/conventions.md) §MR-015, [`AGENTS.md`](../../AGENTS.md) §3.
**Nicht** gefahren: `make gates`, `make mutate`, `make test`, `make full-smoke` (mutierend bzw.
verifizierende Rolle).

---

## (A) Status der Runde-3-Findings

Geprüft **am Artefakt und an eigener Messung**, nicht an der Behauptung des Nachtrags.

### R-1 (HIGH) — ungemessene `arm64`-Auflösungs-Zusage · **behoben; unabhängig nachgemessen**

Die neue Notiz ([`spec/lastenheft.md`](../../spec/lastenheft.md):284–289) trägt fünf prüfbare Aussagen. Ich habe
**jede einzeln** gegen eine eigene Messung gehalten — nicht gegen den Nachtrag:

| Aussage der neuen Notiz | Eigene Messung | Urteil |
|---|---|---|
| „das gepinnte d-check-Image ist ein **Single-Arch-`amd64`-Manifest**" | `docker manifest inspect --verbose ghcr.io/pt9912/d-check@sha256:fede3d02…` → **ein** `Descriptor`, `platform.architecture: amd64`, `platform.os: linux`, **kein** `manifests[]`-Feld | **trifft zu** |
| „(`application/vnd.docker.distribution.manifest.v2+json`, Config `architecture: amd64`)" | derselbe Lauf: `Descriptor.mediaType` ist **zeichengleich** `application/vnd.docker.distribution.manifest.v2+json`; `SchemaV2Manifest` trägt einen Config-Blob, kein `manifest.list` | **zeichengleich, nicht paraphrasiert** |
| „das **gepinnte** Image" (nicht: der Tag) | `d-check.mk`:15/16 — `DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.51.1`, `DCHECK_DIGEST ?= sha256:fede3d02…`; `d-check.mk`:20–25 lässt den **Digest den Tag stechen**, `docs-check` (`d-check.mk`:29) fährt `$(DCHECK_REF)` | **trifft zu** — gemessen wurde genau der Ref, den `docs-check` benutzt |
| „`docs-check` ist ein `gates`-Prerequisite" | [`Makefile`](../../Makefile):222 → `gates: baseline-verify docs-check lint build test shell-lint ci-lint record-gates` | **trifft zu** |
| „der Voll-Smoke bräuchte dort also zuerst arm64-fähige Gate-Image**s**" (Plural) | `harness/tools/full-smoke.sh` bootstrappt und fährt im Ziel-Repo `make gates`; das emittierte `d-check.mk` trägt denselben Digest (`internal/emit/emit.go`:34), und `ghcr.io/pt9912/a-check@sha256:6425c93a…` (`internal/emit/archgate.go`:22) ist **ebenfalls** Single-Arch-`amd64` (eigene Messung) | **trifft zu** — der Plural ist gedeckt, nicht rhetorisch |

**Die Gegenprobe-Behauptung des Implementers — eigenständig nachgefahren, nicht übernommen.**
`docker manifest inspect --verbose` auf die drei fremden Pins:

| Pin | Pin-Ort | Architekturen im Index | Manifest-Liste? |
|---|---|---|---|
| `bats/bats@sha256:e8f18e0a…` | [`Makefile`](../../Makefile):8 | 386 · amd64 · arm (2×) · **arm64** · ppc64le · s390x | **ja** |
| `koalaman/shellcheck@sha256:bb596a0d…` | [`Makefile`](../../Makefile):9 | amd64 · arm · **arm64** · riscv64 | **ja** |
| `rhysd/actionlint@sha256:b1934ee5…` | [`Makefile`](../../Makefile):10 | amd64 · **arm64** | **ja** |

Die Gegenprobe **trägt**: alle drei sind Multi-Arch-Indizes mit `arm64`; der Befund ist auf die
selbst veröffentlichten `ghcr.io/pt9912/*`-Images eingegrenzt und nicht pauschal behauptet.

**Enthält die Notiz irgendeine weitere, ungemessene Aussage?** — **Nein.** Der Rest des
Aufzählungspunkts ist entweder gemessen (der Voll-Smoke als **einzelner** Job auf `ubuntu-24.04`,
[`ci.yml`](../../.github/workflows/ci.yml):58–62) oder eine ausdrückliche **Nicht**-Zusage („Was diese Grenze auflöst, ist
damit **offen und nicht zugesagt**"). Der aus `0.14.0` stehengebliebene Halbsatz „ein Linux-ARM-Runner
fährt Linux-Container und *könnte* den Voll-Smoke **prinzipiell** tragen" bleibt tragfähig: er ist
durch „prinzipiell" auf die *Runtime-Klasse* beschränkt und wird im selben Absatz durch den
gemessenen Satz eingeschränkt. **Kein Rest-Befund an der Notiz.**

### R-3 (LOW) — Spalten-Zuordnung nach [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 3 · **behoben, in beiden Zeilen**

Setzung 3 verbatim ([`harness/conventions.md`](../../harness/conventions.md):703–705): „Künftige Zeilen tragen im Verweis den
annehmenden Akt (`Nutzer-Entscheidung YYYY-MM-DD`), nicht den umsetzenden Slice; der Anlass (ein
ADR, ein Slice-Befund) bleibt in der Änderungs-Spalte."

| Zeile | Änderungs-Spalte (Anlass) | Verweis-Spalte (annehmende Instanz) | Urteil |
|---|---|---|---|
| `0.14.0` ([`spec/lastenheft.md`](../../spec/lastenheft.md):325) | endet auf „**Anlass: slice-050-Review N-2**" | „Nutzer-Entscheidung 2026-07-26" — **nur** noch der annehmende Akt | **konform** |
| `0.14.1` ([`spec/lastenheft.md`](../../spec/lastenheft.md):326) | endet auf „**Anlass: slice-050-Review Runde 3, R-1/R-3**" | „Nutzer-Entscheidung 2026-07-26" | **konform** |

Beide Zeilen tragen den Anlass in der Änderungs-, die annehmende Instanz in der Verweis-Spalte;
der **umsetzende Slice** steht in keinem Verweis (das ausdrückliche Verbot der Setzung). Dass
`614351e` die `0.14.0`-Zeile **mitkorrigiert** hat, ist zulässig: der Schutz „Die bestehenden 13
Zeilen werden **NICHT** umgeschrieben" gilt den Zeilen `0.1.0`…`0.13.0` — die 13 sind im Diff
unangetastet (gemessen: `git show 614351e` weist nur die Zeilen 325/326 als Hunk aus).

### R-2 (MEDIUM) — Release-Text · **NICHT behoben; die Zusage wurde verengt, nicht wahr gemacht** → **S-1**

Der Text wurde umgeschrieben und ist in drei von vier Achsen besser. Aber die von R-2 beanstandete
Konstruktion — eine **positive Unbetroffenheits-Zusage** über Teile des getaggten Handbuchs — steht
weiter drin, nur enger gefasst, und sie ist an derselben Messung falsch. Details unten als **S-1**.

### INFO-1 — DoD-Range · **im Kern behoben, mit einem Restdefekt** → **S-2**

Die Range ist jetzt genannt **und stimmt** (eigene Messung unten). Der begleitende Erklärsatz
zählt die Lastenheft-Commits falsch. Details unten als **S-2**.

---

## (B) Prüfung von `614351e` gegen [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) und die Versionierung

### Setzung 2 — eigener Commit, ausschließlich `spec/lastenheft.md`

| Kriterium (Wortlaut MR-015) | Messung | Urteil |
|---|---|---|
| „in einem **eigenen Commit**" | `git show --name-only --format="" 614351e` → **eine** Zeile: `spec/lastenheft.md` | **erfüllt** |
| „der **ausschließlich** `spec/lastenheft.md` ändert" | genau diese eine Datei, `1 file changed, 9 insertions(+), 5 deletions(-)` | **erfüllt** |
| „und **vor** dem `open → in-progress`-Move des umsetzenden Slice liegt" | ein *umsetzender* Slice existiert nicht — die Korrektur **nimmt zurück**, sie beauftragt nichts | **leer erfüllt** (kein Bezugsobjekt), wie schon bei `30f0fcd` |
| „mechanisch beantwortbar: `git log -- spec/lastenheft.md` + `git show --stat`" | genau so gemessen, ohne Prosa | **erfüllt** |
| Cutoff („geprüft wird ab dem Commit, der diesen Eintrag trägt") | `614351e` liegt weit nach der MR-015-Einführung | **im Geltungsbereich** |

**Setzung 2 ist gewahrt.** Bemerkenswert und richtig: die vier Runde-3-Findings wurden **getrennt**
aufgelöst — die zwei Lastenheft-Findings in `614351e`, die zwei übrigen in `3780d21`. Ein Bündel
hätte Setzung 2 im Vollzug widerlegt.

### Fußabdruck und Versions-Stufe

| Fußabdruck-Element (Baseline-Wortlaut, verbatim in MR-015) | Messung | Urteil |
|---|---|---|
| „ein Version-Bump des Lastenhefts" | Kopfzeile `**Version:** 0.14.0` → `0.14.1`, im selben Commit ([`spec/lastenheft.md`](../../spec/lastenheft.md):3) | **vorhanden** |
| „eine Zeile in dessen `## Historie`" | Zeile `0.14.1` ([`spec/lastenheft.md`](../../spec/lastenheft.md):326) — vierspaltig wie alle Vorgänger, Tabelle bleibt wohlgeformt (15 Zeilen) | **vorhanden** |
| „und die geänderten `LH-*` selbst" | [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) §Grenze der Messmethode, zweiter Grenz-Punkt ([`spec/lastenheft.md`](../../spec/lastenheft.md):284–289) | **vorhanden** — und genau darum ist die Selbstbeschreibung der Zeile schief, s. **S-3** |
| kein `CR-*`-ID-Schema, keine CR-Datei, kein Gate | der Commit legt keine Datei an, ändert kein Target | **konform** |

**Ist die Patch-Stufe sachlich begründet?** — **Im Ergebnis ja, in ihrer Begründung nicht.**
Sachlich trägt sie: `614351e` fasst weder den **Anforderungs**-Absatz noch die zwei
**Messmethoden**-Aufzählungspunkte an (beide sind kein Hunk, byte-identisch); geändert ist allein
eine **Grenz-Notiz** *über* die Messmethode. Das unterscheidet den Fall real von `0.13.0` und
`0.14.0`, die beide die Messmethode selbst umschrieben und dafür eine Minor bekamen. Die Zeile
`0.14.1` benennt aber **nicht** diesen Unterschied, sondern „keine Vertragsänderung, keine
Anforderungs-ID berührt" — ein Kriterium, das auf `0.13.0` und `0.14.0` genauso zutrifft (beide
sagen wörtlich „Die **Anforderung** … bleibt unverändert") und deshalb nicht trennt. → **S-3**.

---

## (C) Prüfung des realen Release-Textes von `v0.1.0`

Gemessen: `gh release view v0.1.0 --json body`. Vier Absätze. **Jede** prüfbare Aussage einzeln:

| Aussage im Release-Text | Beleg | Urteil |
|---|---|---|
| „vorgefertigte Programme für sechs Plattformen (Linux · macOS · Windows × amd64 · arm64)" | `--json assets` → **sechs**, Namen zeichengleich mit [`release.yml`](../../.github/workflows/release.yml):69–80 | **trifft zu** |
| „Der vollständige Durchlauf (Repo aufsetzen, Prüfungen grün) läuft auf **linux/amd64**." | [`ci.yml`](../../.github/workflows/ci.yml):58–62 — Job `full-smoke`, **ein** Job, `runs-on: ubuntu-24.04`, keine Matrix; [`Makefile`](../../Makefile):116 ruft `harness/tools/full-smoke.sh` (Bootstrap → `make gates` im Ziel) | **trifft zu** |
| „Für alle sechs ausgelieferten Dateien ist geprüft, dass das Programm auf seiner Plattform **startet** — mehr nicht." | [`release.yml`](../../.github/workflows/release.yml):63–98 — `matrix.include` mit sechs Einträgen, auf allen derselbe `start-smoke.sh`-Aufruf | **trifft zu** |
| „(er läuft **pro Quellcode-Änderung**, und nur auf linux/amd64 — siehe oben)" | [`ci.yml`](../../.github/workflows/ci.yml):20–26 — `on: push` **und** `pull_request`, keine `paths`-Filter | **trifft zu** |
| „die FAQ („Gibt es ein fertiges Download-Binary? — Derzeit nicht")" | im Tag Zeile 486, wörtlich getroffen | **trifft zu** |
| „der Anhang („keine Release-Versionsnummer")" | im Tag Zeile 524, wörtlich getroffen | **trifft zu** |
| „und der Kasten im Installations-Abschnitt, der den vollständigen Durchlauf „bei jedem Release auf Linux" zusagt" | im Tag Zeile 62, wörtlich getroffen — die in Runde 3 geforderte dritte Stelle ist **nachgetragen** | **trifft zu** |
| „**Die sechs Binaries sind davon nicht betroffen**" | `git show --stat a4dac1f` → drei `.md`-Dateien, kein Go-Code, kein Workflow | **trifft zu** |
| „**ebenso wenig die Download- und Installationsschritte selbst**" | `git diff v0.1.0 HEAD -- docs/user/benutzerhandbuch.md` → `a4dac1f` ändert **Weg A Schritt 2** (fügt `mkdir -p ~/.local/bin` und den Suchpfad-Absatz ein) und den **Ergebnis**-Block | **trifft NICHT zu** → **S-1** |
| „Der mitgelieferte Quellstand beschreibt an mehreren Stellen …" (Aufzählung von drei Stellen) | derselbe Diff nennt **sieben** geänderte Stellen im Tag | **unvollständig** → **S-1** |

**Der Kanal ist weiter der richtige, und der Tag ist unbewegt** (Negativbefunde unten). Was bleibt,
ist eine Aussage im Text, nicht der Weg, auf dem er entstand.

---

## (D) Neue Findings

### S-1 — Der neue Release-Text spricht die Installationsschritte des getaggten Handbuchs frei, die `a4dac1f` nachweislich korrigiert hat

- `kategorie`: **MEDIUM**
- `quelle`: Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6 („Keine Zusage ohne rot gesehenes Gegenbeispiel";
  „**Richtig:** die Zusage auf das einschränken, was der Code hält") · Slice-Plan
  `in-progress/slice-050-doku-nachzug-release.md`:39–42 DoD (das dort benannte Gegenbeispiel) ·
  Runde-1-Findings F-5/F-6/F-7 · Runde-3-Finding R-2 (**derselbe Satzbau, enger gefasst**)
- `pfad`: `gh release view v0.1.0 --json body`, Absatz 3, letzter Satz („**Die sechs Binaries sind
  davon nicht betroffen**, ebenso wenig die Download- und Installationsschritte selbst.")
- `befund`: Der Absatz zählt **drei** veraltete Stellen auf (FAQ · Anhang · Kasten) und spricht die
  „Download- und Installationsschritte selbst" ausdrücklich frei. `git diff v0.1.0 HEAD --
  docs/user/benutzerhandbuch.md` zeigt **sieben** nach dem Tag geänderte Stellen, alle aus
  `a4dac1f` (`git log --oneline v0.1.0..HEAD -- docs/user/benutzerhandbuch.md` nennt genau diesen
  einen Commit). Zwei davon sind **die Installationsschritte selbst**: (a) im Tag Zeile 90 —
  `mv ai-harness-init-linux-amd64 ~/.local/bin/ai-harness-init` **ohne** vorheriges `mkdir -p` und
  ohne Suchpfad-Hinweis (`a4dac1f` fügt beides ein, `git log -S'mkdir -p ~/.local/bin'` → nur
  `a4dac1f`); (b) im Tag Zeile 105 — „Das Programm ist unter dem kurzen Namen `ai-harness-init`
  aufrufbar" als **unbedingte** Zusage (`a4dac1f` macht daraus „**Liegt der Ordner in Ihrem
  Suchpfad**, ist das Programm …"). Zwei weitere ungenannte Stellen: im Tag Zeile 57
  („Ein Betriebssystem mit Docker (Linux oder macOS werden empfohlen)" bei sechs ausgelieferten
  Binaries, darunter zwei Windows-Binaries) und im Tag Zeile 471 (FAQ-Sprachliste „Derzeit `go`",
  seit `cpp` falsch). Die Aufzählung ist damit nicht nur unvollständig — der Freispruch benennt
  **genau die zwei Stellen als unbetroffen, die betroffen sind**.
- `verifizierbar`: **ja, statisch** — `git diff v0.1.0 HEAD -- docs/user/benutzerhandbuch.md` gegen
  `gh release view v0.1.0 --json body`. **Kein Gate deckt es**: `make docs-check` sieht nur den
  Arbeitsbaum, nie einen Tag und nie einen Release-Text; `make mutate` erreicht git-externe
  Artefakte per Konstruktion nicht.
- **Failure-Szenario (konkret, unverändert der F-5-Pfad).** Ein Adopter öffnet
  `releases/latest` — die Seite, auf die [`README.md`](../../README.md) und das
  [Benutzerhandbuch](../user/benutzerhandbuch.md) beide zeigen —, liest „die Download- und
  Installationsschritte selbst sind nicht betroffen", entnimmt daraus, dass er der getaggten
  Anleitung folgen kann, und arbeitet §2 Weg A auf einer frischen Linux-Maschine ohne
  `~/.local/bin` ab: `chmod +x` läuft, `mv … ~/.local/bin/ai-harness-init` bricht mit
  `No such file or directory` ab. Auf macOS gelingt das `mv`, und `ai-harness-init --help` endet
  mit `command not found`, weil `~/.local/bin` dort nicht im Standard-`PATH` liegt. Er sucht den
  Fehler bei sich, weil der Release-Text ihm diesen Teil ausdrücklich als in Ordnung zugesichert
  hat. Das ist **wörtlich das Gegenbeispiel**, das die DoD selbst benennt („ein Leser, der die
  Doku des getaggten Standes liest und keinen Download findet") — nur eine Stufe später im
  Ablauf.
- **Warum weiterhin MEDIUM, nicht HIGH und nicht LOW:** kein Gate-Pfad, kein stilles Grün, keine
  ADR-/Gate-Berührung — die Skill-Regel §Kontext-Eskalation greift nicht. Basis-Anker bleibt
  MEDIUM („Bezug-/Abdeckungslücke" gegenüber dem von der DoD benannten Gegenbeispiel). Eine
  Milderung auf LOW, weil „die Formulierung ja schon enger geworden ist", wäre genau die
  Inkonsistenz-Belohnung, die Modul 10 §„Gegen: bei zwei Kategorisierungen die mildere"
  ausschließt: die Zusage ist **enger**, aber nicht **wahrer**.

### S-2 — Der reparierte DoD-Punkt zählt die Lastenheft-Commits falsch; die Commit-Message sagt das Gegenteil zu

- `kategorie`: **LOW**
- `quelle`: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 · Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6
  (die Regel führt „**Commit-Message**" ausdrücklich als Zusage-Träger)
- `pfad`: `in-progress/slice-050-doku-nachzug-release.md`:47
- `befund`: Der Punkt lautet: „seit `30f0fcd` liegt **ein** **Change-Request-Commit** am Lastenheft
  im Repo". Zum Zeitpunkt von `3780d21` (11:18:11) lagen **zwei** Commits an dieser Datei
  (`git log --oneline 30f0fcd~1..HEAD -- spec/lastenheft.md` → `614351e`, `30f0fcd`); `614351e`
  war 23 Sekunden vorher entstanden und ist im selben Report-Nachtrag beschrieben, den derselbe
  Commit ablegt. Die Commit-Message von `3780d21` sagt beides selbst — „während seit `30f0fcd`
  **zwei** Lastenheft-Commits im Repo liegen" und „benennt die **CR-Commits**" (Plural) —, während
  das Artefakt nur einen benennt. Die genannte Range selbst ist korrekt und leer (unten als
  Negativbefund gemessen); der Defekt liegt im Erklärsatz, der die Range einordnen soll.
- `verifizierbar`: **ja, statisch** — `git log --oneline 30f0fcd~1..3780d21 -- spec/lastenheft.md`
  (zwei Commits) gegen den Wortlaut der Zeile. Kein Gate deckt es;
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Durchsetzung sagt selbst, die Regel lebe „allein im
  **inferential-feedforward**-Quadranten".
- **Failure-Szenario (konkret).** Die Verifikation fährt beim Abschluss
  `git log 63236d3..HEAD -- spec/lastenheft.md`, findet **zwei** Commits, geht zum DoD-Punkt, der
  genau dafür die Auflösung liefern soll — und findet dort **einen** erklärt. Sie muss nun
  entscheiden, ob `614351e` ein zweiter, nicht dokumentierter Change Request ist oder ein
  Slice-Commit, der die DoD-Zusage bricht. Das ist die Mehrdeutigkeit, die INFO-1 beseitigen
  sollte; sie ist von der Range auf den Erklärsatz gewandert. Ein Verifier, der stattdessen die
  Commit-Message heranzieht, bekommt eine dritte Version („die CR-Commits", Plural) — drei
  Artefakte, drei Zählungen.

### S-3 — Die Begründung der Patch-Stufe `0.14.1` trennt nicht, und der zugesagte „in der Zeile selbst begründet"-Beleg steht nicht in der Zeile

- `kategorie`: **LOW**
- `quelle`: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) §Fußabdruck („und die geänderten `LH-*`/`HSM-*` **selbst**") ·
  Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage-Träger „Commit-Message")
- `pfad`: [`spec/lastenheft.md`](../../spec/lastenheft.md):326, Klammer am Zeilenanfang („keine Vertragsänderung, **keine
  Anforderungs-ID berührt**")
- `befund`: Zwei Beobachtungen an derselben Klammer. (1) **„Keine Anforderungs-ID berührt" ist an
  der eigenen Fußabdruck-Sprache falsch:** MR-015 zählt „die geänderten `LH-*` selbst" als
  Fußabdruck-Element, und `614351e` ändert sechs Zeilen **innerhalb** von
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) ([`spec/lastenheft.md`](../../spec/lastenheft.md):284–289). Der Runde-3-Report hat für `0.14.0`
  exakt dieses Element mit demselben Maß als „vorhanden" abgehakt. (2) **Das Kriterium trennt
  nicht:** „keine Vertragsänderung / Anforderung unberührt" trifft wörtlich auch auf `0.13.0` und
  `0.14.0` zu (beide Zeilen sagen „Die **Anforderung** … bleibt unverändert") — und beide bekamen
  eine **Minor**. Der real trennende Grund (die **Messmethode** selbst ist diesmal nicht berührt,
  nur eine Notiz über ihre Grenze) steht nirgends. Die Commit-Message von `614351e` und der
  Nachtrag in [`2026-07-26-slice-050-impl-review-runde-3.md`](2026-07-26-slice-050-impl-review-runde-3.md):507–511 sagen beide zu, „die
  Abweichung ist in der Historie-Zeile selbst begründet" — die Zeile erwähnt die Abweichung vom
  `X.Y.0`-Muster mit keinem Wort.
- `verifizierbar`: **ja, statisch** — `git show 614351e -- spec/lastenheft.md` (Hunk 2 liegt im
  `LH-QA-04`-Block) und ein Wortlaut-Vergleich der Zeilen `0.13.0`/`0.14.0`/`0.14.1`. Kein Gate
  deckt es: es gibt keinen Sensor auf die Versions-Stufung dieses Dokuments.
- **Failure-Szenario (konkret).** Der nächste Fall dieser Art — eine Zeile im Lastenheft ist
  sachlich falsch und wird zurückgenommen — greift `0.14.1` als Präzedenz. Der Autor liest das
  angegebene Kriterium („keine Vertragsänderung, keine Anforderungs-ID berührt"), stellt fest,
  dass es auf seinen Fall ebenso passt wie auf `0.13.0`/`0.14.0`, und kann daraus nicht ableiten,
  ob eine Patch- oder eine Minor-Stufe fällig ist. Wählt er Patch, weil die Klammer so klingt,
  verliert die Versionsreihe des Lastenhefts ihre Aussage über die Änderungs-Tiefe — genau die
  Aussage, wegen der `0.13.0` und `0.14.0` eine Minor trugen. Zusätzlich: ein Reviewer, der die
  Commit-Message-Zusage nachprüft („in der Historie-Zeile selbst begründet"), findet die
  Begründung nicht und muss sie sich aus dem Diff rekonstruieren.

### S-4 — Die Historie-Zeile `0.14.0` behauptet im Präsens weiter genau die Auflösung, die `0.14.1` zurücknimmt

- `kategorie`: **LOW**
- `quelle`: Hard Rule [`AGENTS.md`](../../AGENTS.md) §3.6 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (Zusage, die kein Lauf einlöst) ·
  Skill-Anker LOW („Doku-Drift, veraltete Beispiele")
- `pfad`: [`spec/lastenheft.md`](../../spec/lastenheft.md):325 („die zweite Grenze steht deshalb als eigener Punkt und
  **nennt ihre Auflösung** (Voll-Smoke zusätzlich auf einem Linux-ARM-Runner fahren)")
- `befund`: Der Halbsatz steht im **Präsens** und beschreibt den *aktuellen* Zustand des
  Dokuments — der ist seit `614351e` ein anderer: der Grenz-Punkt nennt keine Auflösung mehr,
  sondern weist sie als „offen und **nicht zugesagt**" aus. Die Zeile ist damit die einzige Stelle
  in [`spec/lastenheft.md`](../../spec/lastenheft.md), die die von R-1 als ungemessen und falsch belegte Auflösung
  („Voll-Smoke zusätzlich auf einem Linux-ARM-Runner fahren") noch **affirmativ** trägt. Sie ist
  kein unangetasteter Alt-Bestand: **`614351e` hat genau diese Zeile umgeschrieben** (Setzung-3-Fix)
  und den Satz dabei stehen lassen. Entlastend und ausdrücklich benannt: die unmittelbar
  darunterliegende Zeile `0.14.1` widerspricht ihm explizit, und eine `## Historie` ist
  konventionell ein chronologischer Bestand — deshalb LOW und nicht höher.
- `verifizierbar`: **ja, statisch** — `sed -n '325p;326p' spec/lastenheft.md` gegen
  [`spec/lastenheft.md`](../../spec/lastenheft.md):284–289. Kein Gate deckt es; `make docs-check` prüft Referenzen,
  keine Sachaussagen (eigener Lauf unten: grün).
- **Failure-Szenario (konkret).** Jemand sucht die Entwicklung der Plattform-Grenze und greift
  dafür — wie in diesem Repo üblich — auf `## Historie` zu, weil die Zeilen dort die Begründungen
  tragen. Er liest `0.14.0` („nennt ihre Auflösung: Voll-Smoke zusätzlich auf einem
  Linux-ARM-Runner fahren"), nimmt das als Stand des Dokuments und schneidet den Slice „Voll-Smoke
  auf `ubuntu-24.04-arm` ergänzen" — denselben Slice, dessen Verwerfen R-1 verhindern sollte.
  Der Lauf bricht in `docs-check` mit `no matching manifest for linux/arm64/v8` ab.

---

## Negativbefunde

- geprüft, ohne Befund: **Die Single-Arch-Aussage über das gepinnte d-check-Image** —
  `docker manifest inspect --verbose ghcr.io/pt9912/d-check@sha256:fede3d02…` liefert **einen**
  `Descriptor` mit `mediaType: application/vnd.docker.distribution.manifest.v2+json` und
  `platform.architecture: amd64` / `platform.os: linux`, **kein** `manifests[]`. Die Notiz gibt
  Medientyp und Architektur **zeichengleich** wieder und paraphrasiert nicht.
- geprüft, ohne Befund: **Der gemessene Ref ist der benutzte Ref** — `d-check.mk`:20–25 lässt
  `DCHECK_DIGEST` den Tag von `DCHECK_IMAGE` stechen; `docs-check` (`d-check.mk`:29) fährt
  `$(DCHECK_REF)`. Gemessen wurde damit exakt das Image, das das Gate startet, nicht der Tag.
- geprüft, ohne Befund: **`docs-check` als `gates`-Prerequisite** — [`Makefile`](../../Makefile):222
  `gates: baseline-verify docs-check lint build test shell-lint ci-lint record-gates`. Die
  Kausalkette der Notiz (arm64-Runner → `make gates` → `docs-check` → amd64-Image) trägt.
- geprüft, ohne Befund: **Die Voll-Smoke-Kette bis ins Ziel-Repo** —
  [`Makefile`](../../Makefile):116 ruft `harness/tools/full-smoke.sh`; das Skript bootstrappt ein
  tmp-Repo und fährt dort `make gates` (Zeilen 4–6, 53). Das emittierte `d-check.mk` trägt
  denselben Digest (`internal/emit/emit.go`:34). Der Plural „Gate-Image**s**" ist zusätzlich
  gedeckt: `ghcr.io/pt9912/a-check@sha256:6425c93a…` (`internal/emit/archgate.go`:22) ist
  **ebenfalls** Single-Arch-`amd64` (eigene Messung).
- geprüft, ohne Befund: **Die Gegenprobe-Behauptung des Implementers** — `bats/bats`,
  `koalaman/shellcheck` und `rhysd/actionlint` sind an ihren gepinnten Digests **Manifest-Listen**
  mit `arm64` (eigene `docker manifest inspect --verbose`-Läufe, Tabelle in (A)). Der Befund ist
  korrekt eingegrenzt statt pauschal behauptet.
- geprüft, ohne Befund: **Die Anforderung und die Messmethode in
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix)** — `git show 614351e` weist weder den Anforderungs-Absatz noch
  die beiden Messmethoden-Aufzählungspunkte (`linux/amd64: Voll-Smoke` /
  `linux/arm64 · macos · windows: Start-Smoke`) als Hunk aus; sie sind byte-identisch. Auch die
  **erste** Grenz-Notiz (macOS/Windows, aus `0.13.0`) ist unangetastet.
- geprüft, ohne Befund: **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 3 in beiden neuen Zeilen** — Anlass in der
  Änderungs-, `Nutzer-Entscheidung 2026-07-26` in der Verweis-Spalte; kein umsetzender Slice im
  Verweis. R-3 ist nicht nur an der neuen, sondern auch an der beanstandeten `0.14.0`-Zeile
  behoben.
- geprüft, ohne Befund: **Die 13 Zeilen `0.1.0`…`0.13.0`** — von `614351e` nicht angefasst
  (Hunk 3 umfasst nur die Zeilen 325/326). MR-015 („Die bestehenden 13 Zeilen werden **NICHT**
  umgeschrieben") ist gewahrt; die Tabelle bleibt vierspaltig und wohlgeformt (15 Zeilen).
- geprüft, ohne Befund: **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 an `614351e`** — `git show --name-only` nennt
  **ausschließlich** `spec/lastenheft.md`. Die vier Runde-3-Findings wurden bewusst auf zwei
  Commits **getrennt** statt gebündelt; ein Bündel hätte die Setzung im Vollzug widerlegt.
- geprüft, ohne Befund: **Die DoD-Range selbst** — `git diff 63236d3..321b849 -- spec/lastenheft.md`
  liefert **null Zeilen**; die fünf Commits der Range (`813418c`, `38b60ed`, `0c31697`, `a4dac1f`,
  `321b849`) sind genau die Slice-Commits. Range und Messkommando im DoD-Punkt sind korrekt;
  **S-2** betrifft allein den erklärenden Nachsatz.
- geprüft, ohne Befund: **Der Release-Kanal und der Tag** — `git rev-list -n1 v0.1.0` →
  `0c31697e…` (unbewegt), `isDraft:false`, `isPrerelease:false`, `publishedAt` unverändert
  `2026-07-26T07:50:44Z`, sechs Assets mit unveränderten Namen/URLs. `gh release edit` hat erneut
  nur `body` berührt — **keine** Force-Operation,
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) bleibt gewahrt.
- geprüft, ohne Befund: **Die dritte, in Runde 3 geforderte Doku-Stelle im Release-Text** — der
  Kasten („bei jedem Release auf **Linux**") ist nachgetragen, samt Korrektur in derselben Klammer
  („er läuft pro Quellcode-Änderung, und nur auf linux/amd64"). Der Selbstwiderspruch zum dritten
  Absatz, den R-2 benannt hatte, ist damit aufgelöst.
- geprüft, ohne Befund: **Die vier Abdeckungs-Aussagen des Release-Textes** — sechs Assets, ein
  `full-smoke`-Job auf `ubuntu-24.04`, sechs Start-Smokes über eine Matrix, `on: push` +
  `pull_request` ohne `paths`-Filter. Alle vier gegen
  [`ci.yml`](../../.github/workflows/ci.yml)/[`release.yml`](../../.github/workflows/release.yml) belegt.
- geprüft, ohne Befund: **Hard Rules 3.1–3.5** — beide Commits fassen weder
  [`Makefile`](../../Makefile) noch `harness/mk/`, `.d-check.yml`, `d-check.mk`, Gate-Skripte oder
  Workflows an (kein Gate benannt, gelockert oder hinzugefügt); kein `//nolint`, kein
  `# shellcheck disable`; kein `git mv`; kein ADR unter
  [`docs/plan/adr/`](../plan/adr/0003-go-native-binaries.md) berührt. Reine Markdown-Änderungen.
- geprüft, ohne Befund: **`.harness/baseline/`** — in beiden Commits nicht enthalten, kein
  Regelwerks- oder Template-Byte berührt.
- geprüft, ohne Befund: **Ablage des Runde-3-Reports in `3780d21`** — 524 Zeilen inklusive
  Nachtrag, neue Datei statt Überschreibung (Modul 10 §Ablage); entspricht der geübten Praxis
  (`321b849`, `a4dac1f`, `d38db74`, `3a1e37a`).
- geprüft, ohne Befund: **Eigener Gate-Lauf** — `make docs-check` →
  `d-check: 190 Datei(en) geprüft, 0 Befund(e)`, Exit 0, gegen den Arbeitsbaum bei `3780d21`.
  Er deckt **keines** der Findings dieser Runde ab: `docs-check` prüft Referenzen, nicht
  Sachaussagen, und sieht weder einen Tag noch einen Release-Text.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 3 |
| INFO | 0 |

### Zur wiederkehrenden Klasse — vierte Runde, und der Steering-Loop ist noch nicht geschlossen

| Runde | Träger der Zusage | Befund |
|---|---|---|
| 1 | Nutzer-Doku ([`benutzerhandbuch.md`](../user/benutzerhandbuch.md)) | F-1/F-3 |
| 2 | Commit-Message / Ablehnungs-Begründung | N-1 |
| 3 | [`spec/lastenheft.md`](../../spec/lastenheft.md) · veröffentlichter Release-Text | R-1/R-2 |
| 4 | **veröffentlichter Release-Text (erneut)** · Slice-Plan-DoD · Historie-Zeile · Commit-Message | S-1/S-2/S-3/S-4 |

Beobachtbar ist etwas Schärferes als in Runde 3: die Klasse tritt jetzt **im selben Artefakt
erneut** auf, nachdem es korrigiert wurde. Der Release-Text hat die beanstandete
Unbetroffenheits-Zusage nicht gestrichen, sondern **verengt** — und die engere Fassung ist an
derselben Messung ebenfalls falsch. Das ist ein anderes Muster als „zweimal dieselbe Klasse an
zwei Orten": es ist eine Korrektur, die die Form der Aussage übernimmt statt ihre Deckung zu
prüfen. Gemeinsame Ursache bleibt die aus Runde 3: [`AGENTS.md`](../../AGENTS.md) §3.6 zählt
„Doc-Kommentar, Test-Name, DoD-Punkt, Commit-Message" als Zusage-Träger — **git-externe Artefakte**
(Release-Text) und **`spec/`** stehen nicht in der Liste, und `make mutate` erreicht per
Konstruktion keines von beiden. Drei der vier Findings dieser Runde liegen in genau diesem
sensorlosen Bereich. Das ist ein Regel-/Sensor-Befund für den Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen* und wird hier nur benannt, nicht gelöst
(kein Lösungsvorschlag im Finding, Skill §Anti-Pattern).

---

## Verdikt

**NICHT KONFORM.**

**Merge-blockierend: ja — ein MEDIUM.**

**S-1 (MEDIUM)** — der Release-Text von `v0.1.0` hat die dritte Doku-Stelle korrekt nachgetragen und
seinen Selbstwiderspruch beseitigt, spricht im selben Satz aber „die Download- und
Installationsschritte selbst" frei. `git diff v0.1.0 HEAD -- docs/user/benutzerhandbuch.md` zeigt,
dass `a4dac1f` genau diese Schritte geändert hat (`mkdir -p`, Suchpfad-Hinweis, bedingtes
Ergebnis) — die Zusage ist gegenüber R-2 **enger**, aber nicht **wahrer**, und das
Failure-Szenario ist unverändert der F-5-Pfad.

**S-2/S-3/S-4 (LOW)** blockieren nicht. **S-3** und **S-4** hängen an derselben Historie-Tabelle wie
R-3 und sollten mit ihr entschieden werden, bevor die nächste Zeile das Muster kopiert.

**Nicht bestritten wird — gemessen und belegt, nicht geglaubt:**

- **R-1 (HIGH) ist vollständig und korrekt behoben.** Ich habe die Notiz nicht gegen den Nachtrag,
  sondern gegen vier eigene `docker manifest inspect --verbose`-Läufe, `d-check.mk`,
  [`Makefile`](../../Makefile):222, `harness/tools/full-smoke.sh` und `internal/emit/` geprüft:
  **jede** ihrer fünf Aussagen trägt, Medientyp und Architektur sind zeichengleich wiedergegeben,
  der Plural „Gate-Images" ist durch das ebenfalls single-arch gepinnte `a-check` gedeckt, und die
  Notiz zieht **keine** neue Zusage nach — die Auflösung ist ausdrücklich „offen und nicht
  zugesagt". Die Gegenprobe (`bats`/`shellcheck`/`actionlint` sind Manifest-Listen) ist ebenfalls
  nachgemessen und trägt. Das ist die Stelle, an der zwei Runden gebrochen sind; sie hält jetzt.
- **R-3 (LOW) ist behoben — in beiden Zeilen.** Anlass in der Änderungs-, annehmende Instanz in der
  Verweis-Spalte, kein umsetzender Slice im Verweis.
- **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2 trägt im zweiten realen Fall** — `614351e` ändert
  ausschließlich `spec/lastenheft.md`, und die vier Findings wurden bewusst auf zwei Commits
  getrennt statt gebündelt.
- **Die Patch-Stufe `0.14.1` ist im Ergebnis sachlich richtig** — weder Anforderung noch
  Messmethode sind berührt, nur eine Notiz über deren Grenze. Beanstandet ist ihre **Begründung**
  (S-3), nicht die Stufe.
- **INFO-1 ist im Kern behoben** — die Range `63236d3..321b849` ist genannt, korrekt und
  nachgemessen leer.
- **Der Kanal bleibt sauber** — Tag unbewegt, unforciert, sechs Assets unverändert,
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) gewahrt.

**Übergabe:** S-1 als veröffentlichende Operation an den Nutzer (git-externes Artefakt, kein Slice
und kein Gate erreicht es). S-3 und S-4 an die Auftraggeber-Rolle — beide liegen in
[`spec/lastenheft.md`](../../spec/lastenheft.md) und sind nur über
[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) änderbar. S-2 an die Slice-Plan-Pflege. Das
Steering-Loop-Signal (§3.6 erreicht `spec/` und git-externe Artefakte nicht) gehört an die
Roadmap. Der Report ersetzt **keine** Verifikation — DoD-/Spec-Konformität prüft der Verifier
separat (Modul 11).

---

## Nachtrag der Implementation (2026-07-26) — Auflösung der Runde-4-Findings

- **S-1 (MEDIUM) — bestätigt, und diesmal die Bauform der Aussage geändert statt nur ihres
  Inhalts.** Nachgemessen: `git diff v0.1.0 HEAD -- docs/user/benutzerhandbuch.md` zeigt **sieben**
  geänderte Stellen, der Release-Text nannte drei. Zweimal hintereinander habe ich an derselben
  Stelle eine **entlastende Zusage** über eine Menge geschrieben, die ich nicht vollständig
  gemessen hatte („der Installations-Abschnitt ist korrekt" → „ebenso wenig die Download- und
  Installationsschritte selbst"). Eine dritte, engere Fassung wäre derselbe Fehler mit kleinerem
  Radius. Der Text trägt jetzt **den Messbefehl** (`git diff v0.1.0 origin/main -- …`) statt einer
  Aufzählung, die vollständig sein müsste, plus die inhaltlich wichtigsten Abweichungen —
  ausdrücklich als Auswahl gekennzeichnet. Die einzige verbliebene Entlastungs-Aussage betrifft die
  **sechs Binaries**, und die ist belegt (Asset-Mengenvergleich gegen `release.yml` und
  `gh release view`). Das ist die Steering-Loop-Lehre dieser Sitzung, angewandt: *ein Allquantor
  über einen Repo-Zustand trägt den Befehl, der ihn misst, neben sich.*
- **S-2 (LOW) — bestätigt, behoben.** Der DoD-Punkt sagte „ein Change-Request-Commit", real waren
  es bei `3780d21` bereits zwei (`30f0fcd`, `614351e`) und inzwischen drei. Eine Zahl an dieser
  Stelle veraltet konstruktionsbedingt; der Punkt nennt jetzt **keine Zahl**, sondern die Regel
  („jeder Lastenheft-Commit liegt außerhalb der Range") und den Messbefehl
  `git log --format=%h --no-merges 63236d3..321b849 -- spec/lastenheft.md` — **selbst gefahren:
  0 Zeilen.**
- **S-3 / S-4 (LOW) — bestätigt, in `7314b7c` getrennt behoben** (eigener Lastenheft-Commit,
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) Setzung 2). S-4: die 0.14.0-Zeile
  beschrieb im Präsens einen Satz, den 0.14.1 zwei Zeilen darunter zurückgenommen hatte — sie wird
  jetzt **eingeordnet statt umgeschrieben**. S-3: die Patch-Begründung nennt jetzt das reale
  Unterscheidungsmerkmal (0.13.0/0.14.0 änderten die **Messmethode**, 0.14.1 nimmt eine falsche
  Tatsachen-Aussage **zurück**), und die zugesagte Begründung der `X.Y.0`-Abweichung steht **in der
  Zeile** statt nur in der Commit-Message.
- **Zur Klassen-Beobachtung des Reviewers** („vierte Runde derselben Klasse, erstmals als Rückfall
  im selben Artefakt nach Korrektur"): angenommen, ohne Relativierung. Sie ist der stärkste Beleg
  für den Roadmap-Kandidaten *Regeln ohne Feedback-Quadrant schließen* — drei der vier Findings
  liegen in `spec/` und in einem **git-externen** Artefakt, also dort, wo weder
  [`AGENTS.md`](../../AGENTS.md) §3.6 sie aufzählt noch `make mutate` sie erreicht. Der Release-Text
  fügt dem Kandidaten eine Achse hinzu, die er noch nicht hatte: **veröffentlichte Artefakte
  außerhalb von git**. Das geht unverändert in die Closure-Notiz.
