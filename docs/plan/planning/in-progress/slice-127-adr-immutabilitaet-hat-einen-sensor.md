# Slice slice-127: Hard Rule 3.4 bekommt ihren Sensor — eine angenommene ADR, die sich ändert, wird rot

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Achse (2) des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. **Hängt an
[slice-123](../done/slice-123-ci-sieht-die-historie.md)**: das Modul liest eine Commit-Range.

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

**Verantwortlich:** Implementer (pt9912).

---

## 1. Ziel

**Ein Commit, der den Kern einer angenommenen ADR ändert, färbt rot — und der erlaubte
Supersede-Übergang bleibt grün.**

### Der Anlass: die Hard Rule hat keinen Träger

[`AGENTS.md`](../../../../AGENTS.md) §3.4 setzt ADRs nach *Accepted* immutabel. Geprüft wird das von
nichts — der Roadmap-Kandidat misst es mit `grep -rl immutable test/` → **kein Treffer**, und
[`.d-check.yml`](../../../../.d-check.yml) führt sieben Module, von denen keines einen Commit
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

- [x] **(1) Eine Änderung am Kern einer angenommenen ADR färbt den Lauf rot — und eine Änderung in
      einem ausgenommenen Abschnitt nicht.** Beide Hälften gehören zusammen: die zweite ist der
      Grund, warum die naheliegende Probe grün blieb (§1), und ohne sie wüsste niemand, wie weit
      die Zusage reicht.
      **Rot:** in einem Wegwerf-Klon einen Satz in `## Entscheidung` einer `Accepted`-ADR ändern
      und committen → der Lauf über diese Range fällt mit `core-drift-vcs` und nennt Datei und
      Zeile. Derselbe Satz in `## Geschichte` bleibt grün, und der Lauf über den unveränderten
      Bereich ebenfalls. Alle drei gehören in den Umsetzungs-Commit.
- [x] **(2) Der erlaubte Supersede-Übergang bleibt grün, und das ist belegt.** `head-allow` und
      `exclude-sections` sind gegen den **realen** ADR-Bestand gesetzt, nicht gegen den
      Default-Vorschlag — der die gelebte Klammer-Form nachweislich rot färbt (§1).
      **Rot:** einen Übergang auf die gelebte Form
      `**Status:** Superseded by [ADR-NNNN](NNNN-titel.md)` commiten → der Lauf muss **grün**
      bleiben. Wird er rot, blockiert der Gate genau die Korrektur-Form, die
      [`AGENTS.md`](../../../../AGENTS.md) §3.4 vorschreibt.
- [x] **(3) Der Lauf fällt, wenn seine Range nichts hergibt — statt grün zu melden.** Die Kopplung
      an [slice-123](../done/slice-123-ci-sieht-die-historie.md) ist hergestellt und einmal gesehen. **Die
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

**Ihr Stand bei der Closure, einzeln — einer davon ist im Wortlaut nicht erfüllt:**

- `make gates` grün — **erfüllt**, von der Verifikation zweimal unabhängig gefahren (isolierte
  Kopie auf dem Arbeits-Stand **und** Arbeitsbaum auf dem tatsächlichen `HEAD`), beide Male
  Exit 0.
- Doku-Update — **erfüllt**: [`harness/README.md`](../../../../harness/README.md) trägt den
  `vcs`-Absatz; zwei der drei zunächst offen gelassenen Grenzen sind in der Behebungs-Runde
  entschieden statt benannt worden.
- Closure-Notiz mit Steering-Loop-Lerneintrag — **erfüllt**, §7.
- `make mutate` ohne Befund — **im Wortlaut nicht erfüllt.** Der volle Satz meldet
  `269 ok, 1 Befund(e)`; der eine ist `221-ignore-refs-restbreite`, ein vorbestehender Fall aus
  `slice-197`, dessen Wächter gemessen intakt ist und dessen `# expect:`-Zeile lediglich den alten
  Titel dieses Wächters zitiert. Kein Fall dieses Slice ist betroffen.

**Warum dieser Punkt eine Adresse bekommt und keinen Carveout.** Das Instrument, das einen roten
Status auf einen Trigger schaltet, ist nach Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln der Carveout — und es bindet an ein **Gate**. `make mutate` ist
keines: [`harness/README.md`](../../../../harness/README.md) führt es unter *Nicht-Gate-Verify*,
und `make gates` ruft es nicht. Ein Carveout darauf wäre die Fehlanwendung des Instruments, nicht
seine Anwendung. Getragen wird der Punkt deshalb zweifach: durch den Folge-Slice `slice-206`
(*Der Mutations-Fall `221` nennt wieder den Titel seines Wächters*), der die Buchhaltung des Falls
repariert und `0 Befund(e)` zur eigenen DoD macht, und durch den Registereintrag
[`BEO-ALL/roter-nicht-gate-sensor-ohne-instrument`](../observations/BEO-ALL/roter-nicht-gate-sensor-ohne-instrument/observation.md),
der die **Form**-Lücke zählt, statt sie mit diesem Slice als erledigt auszugeben.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | der `vcs:`-Block (`paths`, `immutable-when`, `exclude-sections`, `status-line`, `head-allow`). **`vcs` gehört NICHT in `modules:`** — es braucht eine Range und liefe im hermetischen `docs-check` ins Leere |
| [`Makefile`](../../../../Makefile) | update | das Ziel, das den Range-Lauf fährt; wird es behauptet, zieht [`AGENTS.md`](../../../../AGENTS.md) §4 mit |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | update | der Schritt, der das Ziel über die PR-Range fährt — mit der Tiefe aus [slice-123](../done/slice-123-ci-sieht-die-historie.md) |
| [`docs/plan/adr/`](../../adr/) | **prüfen, nicht ändern** | Kopfzeilen-Form und Abschnitts-Namen des Bestands entscheiden die Muster in DoD (2). Eine ADR anzupassen, damit der Sensor grün wird, wäre der Verstoß gegen die Regel, die er bewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| `test/` | neu | die Fälle zu DoD (1)/(2) plus ihr `test/mutations/`-Zahn |
| [`harness/README.md`](../../../../harness/README.md) | update | was der Sensor prüft, über welche Range, und was er **nicht** sieht |
| [`AGENTS.md`](../../../../AGENTS.md) §3, [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | Architect-Eigentum (§3.8). §3.4 bekommt einen Träger; ob ihr Text das erwähnt, entscheidet der Architect |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet, [slice-123](../done/slice-123-ci-sieht-die-historie.md) liegt in `done/`, und das WIP-Limit
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

Sechs Risiken, sechs Ausgänge — jeder genau einer aus der geschlossenen Menge *eingetreten ·
entfallen · weiter offen* (Baseline-Regelwerk `modul-05-planning-harness.md` §Offene Risiken werden
bei Closure aufgelöst).

- **Von den drei Mustern ist eines gemessen, eines widerlegt, eines offen.** `immutable-when`
  trifft die Kopfzeile (§1: das Rot entsteht), `head-allow` in der Default-Form trifft die gelebte
  Supersede-Zeile **nicht** (§1: sie färbt rot), und `paths` ist über genau eine Datei geprüft, nicht
  über die Klasse. Ein Muster, das die Kopfzeile nicht trifft, macht das Modul **still** — die
  stille-Grün-Klasse, nicht durch eine fehlende Config, sondern durch eine, die danebenzielt.
  — **Ausgang: entfallen.** Alle drei Muster sind entschieden **und** einzeln bewacht: `paths` über
  `test/mutations/282-vcs-paths-klasse-verfehlt`, `immutable-when` über `283-…-verfehlt-kopfzeile`,
  `head-allow` über `277`/`280`/`284`. Die Fehlform, vor der das Risiko warnt — eine Config, die
  danebenzielt und das Modul still macht —, färbt seitdem einen Fall rot, statt unbemerkt zu
  bleiben; sie kann nicht mehr unentdeckt eintreten.
- **Der Kern-Begriff ist eine Entscheidung über `## Geschichte`, und sie schneidet in beide
  Richtungen.** Ohne `exclude-sections: [Geschichte]` würde jede Fortschreibung einer angenommenen
  ADR rot; mit ihr ist ein Absatz, der dort statt in einer neuen ADR landet, unbewacht. Welche der
  beiden Fehlformen dieses Repo lieber trägt, gehört aufgeschrieben — der Sensor entscheidet es
  sonst stillschweigend.
  — **Ausgang: entfallen.** Das Risiko verlangte, dass die Wahl *aufgeschrieben* wird; sie ist es,
  samt der Messung, die sie trägt: [`harness/README.md`](../../../../harness/README.md) führt beide
  Fehlformen gegeneinander (die ungeschützte Fläche mit dem Kommando, das sie ausgibt — 8,0 % im
  Schnitt, bis 28,1 % je Datei — gegen 100 % Fehlalarme bei `exclude-sections: []` und **null**
  normativen Sätzen im Geschichte-Abschnitt heute). Der Sensor entscheidet damit nichts mehr
  stillschweigend.
- **Die legitime Supersede-Lineage darf nicht zum Fehlalarm werden.**
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  hält fest, dass sie über Inline-Code + `d-check:ignore` gelöst ist — das deckt `ids`, **nicht**
  `vcs`. Für `vcs` ist `head-allow` der vorgesehene Weg, und DoD (2) ist der Beleg, dass er greift.
  — **Ausgang: entfallen.** DoD (2) ist erfüllt und unabhängig reproduziert: der gelebte
  Link-Übergang bleibt grün, gehalten gegen die zwei realen superseded ADRs. Die Messung ergab
  dabei mehr als erwartet und schärft statt zu lockern — `ids` prüft bare Kennungen **nicht**
  innerhalb ihres eigenen Zieldateibaums `docs/plan/adr/`, `head-allow` ist an dieser Stelle also
  die einzige Durchsetzung der Link-Form und kein redundanter zweiter Schutz.
- **Die Range-Wahl entscheidet, worüber der Gate urteilt.** Über einen PR ist die Basis klar; über
  einen Push auf `main` ist sie es nicht. Eine falsch gewählte Range prüft entweder zu wenig
  (fail-open) oder wiederholt alte Commits (dauerhaft rot über einem Bestand, den niemand mehr
  ändern kann — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  — **Ausgang: entfallen.** Beide Fehlrichtungen sind geschlossen: Der Job bestimmt die Range
  ereignisabhängig (PR: Base gegen Head; Push: `github.event.before` gegen den neuen Stand) und
  **überspringt** einen Push ohne vorherigen Stand, statt eine Basis zu erfinden — damit wiederholt
  er keine alten Commits. Und die fail-open-Richtung fängt der vorgeschaltete
  `history-range-guard`: eine auflösbare, aber leere Range bricht mit Exit 2 ab, statt grün zu
  melden (DoD (3)).
- **Hard Rule 3.3 und dieser Sensor treffen sich.** Ein reiner `git mv` einer ADR-Datei ist eine
  Änderung in der Range, ohne dass der Kern sich bewegt. Ob das Modul das trennt, ist **nicht
  gemessen** — es ist eine Frage an die Umsetzung und steht hier als offener Punkt, nicht als
  Annahme.
  — **Ausgang: entfallen.** Das Risiko war das fehlende Wissen, und das ist beschafft: Das Modul
  trennt **nicht**, es zählt Pfad-Stabilität zur Immutabilität und meldet mit eigenem Grund-Text
  (*„immutable Datei geloescht oder umbenannt"*) — gemessen im Review, in der Verifikation
  unabhängig reproduziert und mit dem Kommando in
  [`harness/README.md`](../../../../harness/README.md) hinterlegt. Operativ folgenlos, weil
  ADR-Pfade ortsfest sind: [`AGENTS.md`](../../../../AGENTS.md) §3.11 nimmt sie ausdrücklich von
  der wandernden Klasse aus. Was bliebe, wenn eine ADR doch einmal umzöge, steht als benannte
  Bedingung neben derselben Messung und nicht mehr als Risiko dieses Slice.
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
  — **Ausgang: entfallen.** Der Ausweichpfad wurde nicht gebraucht: `vcs` ist aktiviert, hat in
  beide Richtungen rot **und** grün gezeigt und hängt an keinem von Hand gepflegten Marker. Ein
  Ausweichpfad, dessen Anlass nicht eingetreten ist, ist kein offenes Risiko; träte er künftig ein,
  wäre das ein neuer Vorgang mit eigener Messung — der Vergleich hier ist gegen `v0.65.0` gefahren
  und trüge nicht ungeprüft in einen anderen Stand.

## 7. Closure-Notiz (nach `done/`)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register
(vorhandene Kennungen **zitieren** statt neu formulieren) · `grundlagen-traceability.md`
§Herkunfts-Anker (das Feld `liegt in` steht **nur**, wenn wirklich etwas verkörpert wurde).

- **Was hat funktioniert:** Die Probe, die ihren eigenen Ort variiert. Vier Läufe hatten `0
  Befund(e)` gemeldet und die Diagnose *„das Modul feuert über diesem Bestand nicht"* getragen —
  alle vier hängten den Prüfsatz **ans Dateiende**, und jede ADR dieses Repos endet mit
  `## Geschichte`, das `exclude-sections` aus dem Kern nimmt. Erst derselbe Satz an einer
  **anderen Stelle** trennte die zwei Erklärungen *„der Sensor ist stumpf"* und *„die Probe hat ihn
  nie erreicht"*. Das ist die Bewegung, die den Slice überhaupt möglich machte; ohne sie wäre er
  als Carveout geschlossen worden, mit einer Begründung, die falsch gewesen wäre.
- **Was ging anders als geplant:** §1 erklärte eine Frage für beantwortet, **bevor** die Arbeit
  begann — *„das Modul ist scharf, die Config zielt richtig"*. Der erste Teil hielt, der zweite
  nicht. Gemessen zielte die Config an drei Stellen daneben: `head-allow` war **ohne End-Anker**
  geschrieben und ließ damit ausgerechnet die Status-Zeile frei fortschreiben, um die
  [`AGENTS.md`](../../../../AGENTS.md) §3.4 geht — die eine Zeile der Datei, die der neue Sensor
  nicht schützte, während derselbe Text an jeder anderen Stelle rot färbte. Dazu war das
  zugelassene Vokabular an zwei Werten zu eng, und der fünfte Schlüssel des Blocks
  (`status-line`), auf dem die zweite Zusage ruht, war von keinem Wächter gehalten. **Die Lehre
  ist der Satz selbst:** Eine Plan-Zeile, die eine Prüfung vorwegnimmt, nimmt sie nicht vorweg,
  sondern **ersetzt** sie — und was sie ersetzt, prüft danach niemand mehr. Zweitens: Alle drei
  Befunde fand erst der Review, keiner die Umsetzung; und zwei der drei „offenen Grenzen", die die
  erste Runde in [`harness/README.md`](../../../../harness/README.md) ablegte, waren mit je einem
  Kommando zu beantworten — eine benannte Grenze ist kein Ersatz für eine Messung, die eine Zeile
  kostet.
- **Steering-Loop-Eintrag:** **Benannte Spec-Lücke** (nicht verkörpert): Für einen **roten
  Nicht-Gate-Sensor** hat die Closure keine Form. Der Standard-Punkt der DoD-Vorlage nennt
  `make mutate` absolut (*„ohne Befund"*) und kennt keinen Ausgang für einen bekannten, andernorts
  verorteten Vorbefund; das Instrument, das einen roten Status auf einen Trigger schaltet, ist der
  Carveout, und der bindet nach Baseline-Regelwerk `modul-05-planning-harness.md` §Closure- und
  Lerneintrag-Regeln an ein **Gate**. Übrig bleiben zwei falsche Wege — still abhaken oder
  unerfüllt stehen lassen, ohne dass irgendwo steht, warum das den Abschluss nicht hindert. Diese
  Closure ist den dritten gegangen (Folge-Slice **plus** Registereintrag) und hat damit zwei
  Behelfe statt einer Form. Auslöser:
  [`BEO-ALL/roter-nicht-gate-sensor-ohne-instrument`](../observations/BEO-ALL/roter-nicht-gate-sensor-ohne-instrument/observation.md)
  — Zähler **1×**, also **unter** der Schwelle. Der Eintrag ist damit *gezählt, nicht verkörpert*:
  Die Teil-Zeile `— liegt in …` entfällt, und welche Form die Lücke schlösse, ist eine Norm-Frage
  für den **Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8), nicht für diese Closure.
- **Beobachtungs-Register (`../observations/`):** sechs Belege, davon **vier** in bestehende
  Verzeichnisse ergänzt und **zwei** Verzeichnisse neu angelegt. Zähler als Dateizahl abgelesen
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
  Erwartungswerte**):
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  **6×** ·
  [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  **5×** ·
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  **10×** ·
  [`hintergrund-lauf-wird-gepollt-statt-abgewartet`](../observations/BEO-ALL/hintergrund-lauf-wird-gepollt-statt-abgewartet/observation.md)
  **2×** (die `observation.md` hatte diesen Slice unter *Benannt, nicht gezählt* geführt und den
  Beleg ausdrücklich auf seinen Abschluss vertagt — mit dem `git mv` ist die Lage-Bedingung
  erfüllt) · neu:
  [`roter-nicht-gate-sensor-ohne-instrument`](../observations/BEO-ALL/roter-nicht-gate-sensor-ohne-instrument/observation.md)
  **1×** und
  [`mutations-fall-ueberlebt-die-umbenennung-seines-waechters`](../observations/BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters/observation.md)
  **1×**, Letzterer mit dem Beleg `slice-197` — dem Vorgang, in dem die Umbenennung geschah, nicht
  dem, der sie fand.

  **Was diese Closure ausdrücklich *nicht* tut: den Lese-Schritt.** Dieses Repo führt
  Wellen-Betrieb — `welle-09` und `welle-13` stehen offen, dieser Slice gehört zu `welle-13` —, und
  damit liegt der Lese-Schritt bei der **Welle-Closure**, nicht hier (Baseline-Regelwerk
  `modul-05-planning-harness.md` §Lifecycle als State Machine: *„vom Lese-Schritt (Welle-Closure;
  in einem Repo ohne Wellen-Betrieb löst ihn die Slice-Closure selbst aus)"*; ebenso
  `modul-06-roadmap.md` §Das Beobachtungs-Register). Diese Closure **zählt**, sie **entscheidet
  nicht**. Als Übergabe an `welle-13` steht der Rückstand hier gemessen: **acht** Einträge stehen
  bei ≥ 3× und weiter auf `offen`, zwei davon durch diesen Slice bewegt (6× und 5×) —

  ```sh
  for d in docs/plan/planning/observations/BEO-ALL/*/; do
    n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l)
    s=$(grep -m1 '^\*\*Stand:\*\*' "$d"state.md | sed 's/\*\*Stand:\*\* //')
    [ "$n" -ge 3 ] && [ "$s" = "offen" ] && printf '%3s  %s\n' "$n" "$(basename "$d")"
  done | sort -rn
  ```

  Dass der Rückstand acht statt zwei zählt, ist selbst ein Befund und keine Buchführung: Das
  Regelwerk lässt einen Eintrag, der eine Closure ohne Ausgang übersteht, nicht zu, und die
  Klasse dafür führt das Register bereits als
  [`schwellen-uebertritt-ohne-zustaendige-rolle`](../observations/BEO-ALL/schwellen-uebertritt-ohne-zustaendige-rolle/observation.md)
  (**2×**). Ihn hier abzuarbeiten hieße, den Lese-Schritt einer Welle in einer Slice-Closure zu
  fahren — der Rollen-Kurzschluss, den dieselbe Klasse beschreibt.
- **Folge-Slices:** `slice-206` (*Der Mutations-Fall `221` nennt wieder den Titel seines
  Wächters*) — ist eine Datei in `open/`, geprüft mit
  `find docs/plan/planning -name 'slice-206-*.md'` (eine Zeile). Ohne Pfad genannt: Diese Sektion
  friert mit dem `git mv` ein, und `slice-206` steht am Anfang seines Lifecycle
  ([`AGENTS.md`](../../../../AGENTS.md) §3.11).
- **Risiken aus §6:** sechs Risiken, sechs Ausgänge — **alle sechs *entfallen*, jeder mit
  Begründung**; siehe §6. Dass keines eingetreten und keines weiter offen ist, ist nicht
  Glättung, sondern die Folge des Reviews: Er hat die drei Fragen, die der Plan als offen führte,
  einzeln messen lassen, und die Antworten stehen seitdem als **entschiedene Grenzen** in
  [`harness/README.md`](../../../../harness/README.md) statt als Risiko in diesem Plan. Was an
  Rest bleibt, ist dort benannt (ein reiner `git mv` einer ADR färbt rot, folgenlos nur solange
  ADR-Pfade ortsfest sind) und ist keine Zusage dieses Slice mehr.
- **Drei Paarungen:** **nicht dieser Closure geschuldet** — im Repo **mit** Wellen-Betrieb trägt
  sie die nächste Welle-Closure, auch für Slices ohne Wellen-Zugehörigkeit (so die Ziel-Form des
  Slice-Plans in `slice.template.md` §2, letztes Item). Als Übergabe dennoch gefahren, mit
  Ergebnis: **(a) Anker** — der Steering-Loop-Eintrag trägt kein Feld `liegt in`, die Paarung hat
  keinen Gegenstand. **(b) Folge-Slice** — `slice-206` ist eine Datei im Lifecycle (Kommando oben).
  **(c) Register** — jede hier zitierte Kennung löst als Verzeichnis auf; die zweite Hälfte *„jede
  Registerzeile trägt mindestens einen Beleg"* meldet unverändert **einen** Eintrag ohne
  `evidence/`, `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`. Das ist **kein** Rückstand
  und derselbe Fall, den die Closure von `slice-201` bereits benannt hat: Der Eintrag führt sein
  einziges Vorkommen unter *Benannt, nicht gezählt*, und ein Vorkommen ohne abgeschlossenen Vorgang
  bekommt nach Baseline-Regelwerk `modul-06-roadmap.md` ausdrücklich keinen Beleg — die
  maschinelle Hälfte der Paarung und diese Regel widersprechen einander für genau diese Klasse.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
ADR-Ablage ist konventionell dicht: [`AGENTS.md`](../../../../AGENTS.md) §3.4 setzt die
Immutabilität, §5 die Index-Pflicht, und
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
die Supersede-Behandlung im Doku-Gate.
