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

**Dieser Slice ist der unsicherste der Welle, und das ist gemessen — nicht geahnt.** Für die drei
anderen Module ließ sich beim Schnitt je ein Rot herstellen; **für `vcs` nicht.** Gegen eine Kopie
außerhalb des Repos (Stand `1f5741f`, netzlos, `:ro`, Image `v0.65.0` per Digest), Flags aus
[`d-check.mk`](../../../../d-check.mk), wurde in einem Wegwerf-Klon ein Kernsatz an eine ADR mit
`**Status:** Accepted` angehängt und committet. Ergebnis in **allen vier** Formen
`425 Datei(en) geprüft, 0 Befund(e)`, **Exit 0**:

| Lauf | Config | Ergebnis |
|---|---|---|
| `--range HEAD~20..HEAD` | ohne `vcs:`-Block (heutiger Stand) | 0 Befunde, Exit 0 |
| `--range <base>..HEAD` über den Änderungs-Commit | **mit** dem `vcs:`-Block aus `--print-config` | 0 Befunde, Exit 0 |
| `--range <c>^..<c>` genau über den Änderungs-Commit | derselbe Block | 0 Befunde, Exit 0 |
| `--staged` mit gestagter Kern-Änderung | derselbe Block | 0 Befunde, Exit 0 |

**Was das heißt und was nicht.** Es heißt **nicht**, dass das Modul kaputt ist — die naheliegenden
Ursachen sind eine Config, die danebenzielt (Kopfzeilen-Form, `paths`-Glob, Kern-Begriff), oder
eine Range-Semantik, die anders gemeint ist als hier geraten. Es heißt: **die Zusage dieses Slice
hat beim Schneiden kein Gegenbeispiel bekommen**, und nach
[`AGENTS.md`](../../../../AGENTS.md) §3.6 ist sie damit nicht fertig, sondern offen. Der erste
Schritt der Umsetzung ist deshalb **nicht** die Konfiguration, sondern die Herstellung genau dieses
Rots — notfalls gegen die Quelle des Moduls im lokalen d-check-Klon.

**Der Default-Vorschlag ist der Ausgangspunkt, nicht die Antwort.** `--print-config` schlägt
`immutable-when: '^\*\*Status:\*\* Accepted'` und
`head-allow: '^\*\*Status:\*\* (Accepted|Superseded by ADR-[0-9]{4})'` vor; die geprüfte ADR trägt
`**Status:** Accepted` wörtlich (`grep -m1 '^\*\*Status:\*\*'`), und trotzdem blieb der Lauf grün.
Welche Abschnitte als „nicht zum Kern" gelten, ist ebenfalls offen —
[`.d-check.yml`](../../../../.d-check.yml) führt für `matrix` bereits
`exclude-sections: [Historie, "7. Historie", Geschichte]`, und ob `vcs` dieselbe Liste braucht, ist
zu prüfen, nicht zu übernehmen.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Eine Änderung am Kern einer angenommenen ADR färbt den Lauf rot.** **Dieser Punkt ist
      der Ausgang des Slice, nicht sein Abschluss** — beim Schneiden ließ er sich in vier Formen
      **nicht** herstellen (§1). Ist er nicht herstellbar, ist der Slice nicht erfüllt, und die
      Rückführung greift.
      **Rot:** in einem Wegwerf-Klon einen Satz im Kern einer `Accepted`-ADR ändern und committen →
      der Lauf über diese Range fällt und nennt Datei und Befund. Der Lauf über denselben Bereich
      **ohne** diese Änderung bleibt grün. Beide gehören in den Umsetzungs-Commit.
- [ ] **(2) Der erlaubte Supersede-Übergang bleibt grün, und das ist belegt.** `head-allow` und
      `exclude-sections` sind gegen den **realen** ADR-Bestand gesetzt, nicht gegen den
      Default-Vorschlag.
      **Rot:** einen `Accepted` → `Superseded by ADR-NNNN`-Übergang commiten → der Lauf muss **grün**
      bleiben. Wird er rot, ist die Konfiguration falsch und der Gate blockiert genau die
      Korrektur-Form, die [`AGENTS.md`](../../../../AGENTS.md) §3.4 vorschreibt.
- [ ] **(3) Der Lauf fällt, wenn ihm die Range fehlt — statt grün zu melden.** Die Kopplung an
      [slice-123](slice-123-ci-sieht-die-historie.md) ist hergestellt und einmal gesehen.
      **Rot:** denselben Lauf in einem Klon der Tiefe 1 fahren → Exit ≠ 0 mit einer Meldung über die
      fehlende Historie. Ohne diese Hälfte ist der Sensor in CI fail-open, und ein fail-open Sensor
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

- **Die Muster sind ungemessen, und darauf steht der ganze Slice.** `immutable-when` und
  `head-allow` sind hier aus `--print-config` übernommen, nicht gegen den Bestand geprüft. Trifft
  das Muster die Kopfzeile nicht, ist das Modul **still** — die stille-Grün-Klasse, diesmal nicht
  durch eine fehlende Config, sondern durch eine, die danebenzielt. Erste Handlung der Umsetzung
  ist deshalb eine Messung, keine Konfiguration.
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
- **Das Rot ist herstellbar — gemessen, aber über ein anderes Modul.** `immutable` ist das
  hermetische Geschwister von `vcs`: es hasht den normalisierten Kern einer Datei gegen einen
  Marker in ihr, ohne `.git` und ohne Range. Gegen eine Kopie außerhalb des Repos
  (`git archive aa32e1f`, netzlos, Mount `:ro`, Image `v0.65.0` per Digest) meldet ein absichtlich
  falscher `immutable: sha256:0000…`-Marker auf
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) **`core-drift`** — ein Befund,
  wo `vcs` in vier Formen null lieferte (§1). Das **ersetzt die Zusage dieses Slice nicht**: der
  Gegenstand hier ist der Commit, der eine angenommene ADR ändert, nicht ein Marker, den jemand
  von Hand pflegt, und `immutable` bräuchte in jeder ADR einen gesetzten und nachgezogenen Hash.
  Es engt aber die Ursachensuche ein: die Immutabilitäts-Fähigkeit des Images ist vorhanden und
  wird rot — offen ist die **Range-Achse**, nicht die Fähigkeit. Herkunft der Messung:
  [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §6.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
ADR-Ablage ist konventionell dicht: [`AGENTS.md`](../../../../AGENTS.md) §3.4 setzt die
Immutabilität, §5 die Index-Pflicht, und
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
die Supersede-Behandlung im Doku-Gate.
