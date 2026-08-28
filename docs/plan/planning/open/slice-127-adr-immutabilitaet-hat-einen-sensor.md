# Slice slice-127: Hard Rule 3.4 bekommt ihren Sensor — eine angenommene ADR, die sich ändert, wird rot

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Achse (2) des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. **Hängt an
[slice-123](slice-123-ci-sieht-die-historie.md)**: das Modul liest eine Commit-Range.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die ADRs **dieses** Repos
([`docs/plan/adr/`](../../adr/)). Was ein emittiertes Repo an Immutabilitäts-Prüfung bekommt,
entscheidet der Slice, der die Tool-Ebene entscheidet — und die Frage ist dort nicht dieselbe: ein
frisch gebootstrapptes Ziel hat keine angenommene ADR und keine Historie.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (der Gegenstand: *„ADRs sind nach Accepted immutable"* —
Korrekturen entstehen als neue ADR mit Supersedes),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Modul ohne Config-Block meldet 0 Befunde und prüft nichts — der Ist-Zustand, §1),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop; sie nennt zugleich die legitime Supersede-Lineage, die dieser
Slice nicht rot färben darf),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(Setzung 3, *blind und grün* — hier über die Range),
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (Move und Rewrite sind zwei Commits — eine Range-Prüfung
über ADR-Dateien trifft genau diese Trennung),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Ein Commit, der den Kern einer angenommenen ADR ändert, färbt rot — und der erlaubte
Supersede-Übergang bleibt grün.**

### Der Anlass: die Hard Rule hat keinen Träger

[`AGENTS.md`](../../../../AGENTS.md) §3.4 setzt ADRs nach *Accepted* immutabel. Geprüft wird das von
nichts — der Roadmap-Kandidat misst es mit `grep -rl immutable test/` → **kein Treffer**, und
[`.d-check.yml`](../../../../.d-check.yml) führt sechs Module, von denen keines einen Commit
entgegennimmt.

### Das Modul, und der Ist-Zustand seines Ziels

`vcs` (`DC-FA-VCS-001`) prüft git-Diff-Immutabilität über eine Range: `paths` grenzt die geschützte
Datei-Klasse ab, `immutable-when` markiert ab welcher Kopfzeile der **Base**-Stand unveränderlich
ist, `exclude-sections` nimmt nicht zum Kern zählende Abschnitte heraus, und `head-allow` erlaubt
genau den Status-Übergang `Accepted` → `Superseded by ADR-NNNN`.

**Die naheliegende Probe erreicht den Sensor nicht, und das ist gemessen — nicht geahnt.** Gegen
eine Kopie außerhalb des Repos (Stand `1f5741f`, netzlos, `:ro`, Image `v0.65.0` per Digest), Flags
aus [`d-check.mk`](../../../../d-check.mk), wurde in einem Wegwerf-Klon ein Kernsatz an eine ADR mit
`**Status:** Accepted` angehängt und committet. Ergebnis in **allen vier** Formen
`425 Datei(en) geprüft, 0 Befund(e)`, **Exit 0**:

| Lauf | Config | Ergebnis |
|---|---|---|
| `--range HEAD~20..HEAD` | ohne `vcs:`-Block (heutiger Stand) | 0 Befunde, Exit 0 |
| `--range <base>..HEAD` über den Änderungs-Commit | **mit** dem `vcs:`-Block aus `--print-config` | 0 Befunde, Exit 0 |
| `--range <c>^..<c>` genau über den Änderungs-Commit | derselbe Block | 0 Befunde, Exit 0 |
| `--staged` mit gestagter Kern-Änderung | derselbe Block | 0 Befunde, Exit 0 |

### Das Rot ist herstellbar, und die Ursache ist `exclude-sections`

Die vier grünen Läufe hängen an **einer** Eigenschaft der Probe: der Kernsatz wurde jeweils **ans
Dateiende** angehängt. Jede ADR dieses Repos endet mit `## Geschichte` — gemessen über alle
Kandidaten (`ls docs/plan/adr/[0-9]*.md | wc -l` → **23**; davon mit `## Geschichte` als letzter
`##`-Überschrift: **23**, gezählt über `grep -E '^## ' <datei> | tail -1` je Datei). Der
Default-Block nimmt genau diesen Abschnitt mit `exclude-sections: [Geschichte]` aus dem Kern.
**Angehängt wurde also außerhalb dessen, was das Modul schützt** — die Probe hat den Sensor nie
erreicht.

Gemessen in einem Wegwerf-Klon außerhalb des Repos (`git clone <repo> <klon>`, Stand `fccc627`),
netzlos, Mount `:ro`, Image `v0.65.0` per Digest, Config aus `--print-config` mit
`paths: ["docs/plan/adr/[0-9]*.md"]`, je Lauf
`docker run --rm --network none -v <klon>:/repo:ro ghcr.io/pt9912/d-check@<digest> --config <profil> --enable vcs --range <base>..<head>`:

| Commit in der Range | Ergebnis |
|---|---|
| ein Satz **ans Dateiende** von `0003-go-native-binaries.md` (Abschnitt `## Geschichte`) | `417 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| **derselbe Satz in `## Entscheidung`** | **1** × `core-drift-vcs` auf `docs/plan/adr/0003-go-native-binaries.md:3`, Exit 1 |

**Damit ist die offene Frage dieses Slice beantwortet, bevor er beginnt:** das Modul ist scharf,
die Config zielt richtig, und der Carveout-Pfad aus
[welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §3 wird für `vcs` nicht gebraucht.

### Und der Default-Vorschlag färbt die erlaubte Korrektur rot

`--print-config` schlägt `head-allow: '^\*\*Status:\*\* (Accepted|Superseded by ADR-[0-9]{4})'`
vor. Die gelebte Form dieses Repos ist ein **Link**, keine bare Kennung: die zwei superseded ADRs
tragen `**Status:** Superseded by [ADR-0003](0003-go-native-binaries.md)` bzw. dieselbe Form mit
[`ADR-0005`](../../adr/0005-ziel-repo-distribution.md)
(`grep -h -m1 '^\*\*Status:\*\*' docs/plan/adr/0*.md | sort | uniq -c` →
**19** × `Accepted`, **2** × `Proposed`, je **1** × der zwei Supersede-Zeilen). Im selben Klon
gemessen: ein Commit, der `**Status:** Accepted` auf die gelebte Klammer-Form dreht, meldet mit dem
Default-`head-allow` **1** × `core-drift-vcs`; mit
`head-allow: '^\*\*Status:\*\* (Accepted|Superseded by \[ADR-[0-9]{4}\])'` meldet derselbe Commit
**0 Befunde**. **Der Default blockiert also genau die Korrektur-Form, die
[`AGENTS.md`](../../../../AGENTS.md) §3.4 vorschreibt** — das ist der Gegenstand von DoD (2), und
er ist jetzt ein gefahrener Beleg statt einer Vermutung.

**Was offen bleibt.** Ob `vcs` dieselbe `exclude-sections`-Liste braucht, die
[`.d-check.yml`](../../../../.d-check.yml) für `matrix` führt
(`exclude-sections: [Historie, "7. Historie", Geschichte]`), ist zu prüfen und nicht zu übernehmen:
`Geschichte` auszunehmen ist die Voraussetzung dafür, dass der Sensor überhaupt anschlägt, wo er
soll — es ist zugleich der Abschnitt, in dem eine ADR ihre Fortschreibung führt. Was dort stehen
darf, ohne die Immutabilität zu verletzen, entscheidet dieser Slice mit.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Eine Änderung am Kern einer angenommenen ADR färbt den Lauf rot — und eine Änderung in
      einem ausgenommenen Abschnitt nicht.** Beide Hälften gehören zusammen: die zweite ist der
      Grund, warum die naheliegende Probe grün blieb (§1), und ohne sie wüsste niemand, wie weit
      die Zusage reicht.
      **Rot:** in einem Wegwerf-Klon einen Satz in `## Entscheidung` einer `Accepted`-ADR ändern
      und committen → der Lauf über diese Range fällt mit `core-drift-vcs` und nennt Datei und
      Zeile. Derselbe Satz in `## Geschichte` bleibt grün, und der Lauf über den unveränderten
      Bereich ebenfalls. Alle drei gehören in den Umsetzungs-Commit.
- [ ] **(2) Der erlaubte Supersede-Übergang bleibt grün, und das ist belegt.** `head-allow` und
      `exclude-sections` sind gegen den **realen** ADR-Bestand gesetzt, nicht gegen den
      Default-Vorschlag — der die gelebte Klammer-Form nachweislich rot färbt (§1).
      **Rot:** einen Übergang auf die gelebte Form
      `**Status:** Superseded by [ADR-NNNN](NNNN-titel.md)` commiten → der Lauf muss **grün**
      bleiben. Wird er rot, blockiert der Gate genau die Korrektur-Form, die
      [`AGENTS.md`](../../../../AGENTS.md) §3.4 vorschreibt.
- [ ] **(3) Der Lauf fällt, wenn seine Range nichts hergibt — statt grün zu melden.** Die Kopplung
      an [slice-123](slice-123-ci-sieht-die-historie.md) ist hergestellt und einmal gesehen. **Die
      unauflösbare Range ist dabei nicht der Fall, der zählt:** sie bricht schon heute fail-closed
      ab (`--range HEAD~1..HEAD` in einem Klon der Tiefe 1 → `d-check: error: Range-Basis "HEAD~1"
      nicht auflösbar: object not found`, Exit 2). Der gefährliche Fall ist die **auflösbare, aber
      leere** Range — `--range HEAD..HEAD` meldet im selben Klon `0 Befund(e)`, Exit 0.
      **Rot:** den Lauf mit einer leeren Range fahren → Exit ≠ 0 mit einer Meldung, dass die Range
      keinen Commit enthält. Ohne diese Hälfte ist der Sensor fail-open, und ein fail-open Sensor
      ist schlechter als keiner, weil er eine Zusage trägt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | der `vcs:`-Block (`paths`, `immutable-when`, `exclude-sections`, `status-line`, `head-allow`). **`vcs` gehört NICHT in `modules:`** — es braucht eine Range und liefe im hermetischen `docs-check` ins Leere |
| [`Makefile`](../../../../Makefile) | update | das Ziel, das den Range-Lauf fährt; wird es behauptet, zieht [`AGENTS.md`](../../../../AGENTS.md) §4 mit |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | update | der Schritt, der das Ziel über die PR-Range fährt — mit der Tiefe aus [slice-123](slice-123-ci-sieht-die-historie.md) |
| [`docs/plan/adr/`](../../adr/) | **prüfen, nicht ändern** | Kopfzeilen-Form und Abschnitts-Namen des Bestands entscheiden die Muster in DoD (2). Eine ADR anzupassen, damit der Sensor grün wird, wäre der Verstoß gegen die Regel, die er bewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| `test/` | neu | die Fälle zu DoD (1)/(2) plus ihr `test/mutations/`-Zahn |
| [`harness/README.md`](../../../../harness/README.md) | update | was der Sensor prüft, über welche Range, und was er **nicht** sieht |
| [`AGENTS.md`](../../../../AGENTS.md) §3, [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | Architect-Eigentum (§3.8). §3.4 bekommt einen Träger; ob ihr Text das erwähnt, entscheidet der Architect |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet, [slice-123](slice-123-ci-sieht-die-historie.md) liegt in `done/`, und das WIP-Limit
ist frei.** Die Kante zu 123 ist **tragend**: ohne sie ist DoD (3) nicht herstellbar, weil es genau
die Tiefen-Prüfung ist, die 123 baut.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: der ADR-Bestand trägt die Kopfzeilen-Form **nicht** einheitlich, sodass
  vor der Aktivierung eine Bestands-Angleichung nötig wäre. Die ist ein eigener Schnitt — und ein
  heikler, weil das Angleichen angenommener ADRs genau die Regel berührt, um die es geht.
- `in-progress` → `open`: die Range-Wahl ist in diesem Repo nicht bestimmbar (PR-Basis gegen
  `main`-Push gegen `--staged`), sodass der Sensor je nach Auslöser über verschiedene Mengen
  urteilt. Dann ist die Range-Semantik der Gegenstand und dieser Slice hängt an ihr — als Carveout
  nach Modul 7 aufzuschreiben.
- `in-progress` → `open`, **der wahrscheinlichste Weg nach der Messung in §1**: DoD (1) bleibt auch
  nach ernsthaftem Versuch unherstellbar — das Modul feuert über diesem Bestand in keiner Form. Dann
  ist die Lage ein Carveout und **kein** aktiviertes Modul: ein `vcs` in der Konfiguration, das
  niemand hat rot sehen können, wäre die Zusage ohne Gegenbeispiel, gegen die
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 steht — und zugleich das stille Grün, gegen das
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) steht.
  **Die Welle darf mit diesem Carveout schließen; sie darf nicht mit einem stillen `vcs` schließen.**

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make ci-lint` grün,
`make mutate` ohne Befund, Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden
Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Von den drei Mustern ist eines gemessen, eines widerlegt, eines offen.** `immutable-when`
  trifft die Kopfzeile (§1: das Rot entsteht), `head-allow` in der Default-Form trifft die gelebte
  Supersede-Zeile **nicht** (§1: sie färbt rot), und `paths` ist über genau eine Datei geprüft, nicht
  über die Klasse. Ein Muster, das die Kopfzeile nicht trifft, macht das Modul **still** — die
  stille-Grün-Klasse, nicht durch eine fehlende Config, sondern durch eine, die danebenzielt.
- **Der Kern-Begriff ist eine Entscheidung über `## Geschichte`, und sie schneidet in beide
  Richtungen.** Ohne `exclude-sections: [Geschichte]` würde jede Fortschreibung einer angenommenen
  ADR rot; mit ihr ist ein Absatz, der dort statt in einer neuen ADR landet, unbewacht. Welche der
  beiden Fehlformen dieses Repo lieber trägt, gehört aufgeschrieben — der Sensor entscheidet es
  sonst stillschweigend.
- **Die legitime Supersede-Lineage darf nicht zum Fehlalarm werden.**
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  hält fest, dass sie über Inline-Code + `d-check:ignore` gelöst ist — das deckt `ids`, **nicht**
  `vcs`. Für `vcs` ist `head-allow` der vorgesehene Weg, und DoD (2) ist der Beleg, dass er greift.
- **Die Range-Wahl entscheidet, worüber der Gate urteilt.** Über einen PR ist die Basis klar; über
  einen Push auf `main` ist sie es nicht. Eine falsch gewählte Range prüft entweder zu wenig
  (fail-open) oder wiederholt alte Commits (dauerhaft rot über einem Bestand, den niemand mehr
  ändern kann — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Hard Rule 3.3 und dieser Sensor treffen sich.** Ein reiner `git mv` einer ADR-Datei ist eine
  Änderung in der Range, ohne dass der Kern sich bewegt. Ob das Modul das trennt, ist **nicht
  gemessen** — es ist eine Frage an die Umsetzung und steht hier als offener Punkt, nicht als
  Annahme.
- **Das hermetische Geschwister bleibt eine Alternative, keine Notlösung mehr.** `immutable` hasht
  den normalisierten Kern einer Datei gegen einen Marker in ihr, ohne `.git` und ohne Range; gegen
  eine Kopie außerhalb des Repos (`git archive aa32e1f`, netzlos, Mount `:ro`, Image `v0.65.0` per
  Digest) meldet ein absichtlich falscher `immutable: sha256:0000…`-Marker auf
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) **`core-drift`**
  ([welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §6). Der Gegenstand ist ein **anderer**:
  hier der Commit, der eine angenommene ADR ändert, dort ein Marker, den jemand von Hand setzt und
  nachzieht — in **23** Dateien (`ls docs/plan/adr/[0-9]*.md | wc -l`). Wird `vcs` in der Umsetzung
  aus einem anderen Grund untragbar, ist `immutable` der benannte Ausweichpfad und nicht ein
  spontaner.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
ADR-Ablage ist konventionell dicht: [`AGENTS.md`](../../../../AGENTS.md) §3.4 setzt die
Immutabilität, §5 die Index-Pflicht, und
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
die Supersede-Behandlung im Doku-Gate.
