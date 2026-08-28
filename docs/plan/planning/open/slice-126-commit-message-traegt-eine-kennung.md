# Slice slice-126: Eine Commit-Message ohne Kennung wird rot — vor dem Commit, und damit steht der Träger, den auch slice-121 braucht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Achse (3) des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. **Hängt an
[slice-123](slice-123-ci-sieht-die-historie.md)**, sobald der Sensor eine Commit-Spanne liest.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Commit-Messages **dieses** Repos. Im
Emissions-Baum kommt der Gegenstand nicht vor
(`git grep -lni 'commit-msg\|COMMIT_EDITMSG' -- internal/emit/templates/ | wc -l` → **0**, gemessen
für [slice-121](slice-121-commit-message-nennt-was-es-gibt.md) und hier übernommen).

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §5 (*„Requirement- und ADR-IDs in PRs/Commits referenzieren"* —
die Zusage, die hier ihren Sensor bekommt),
[`harness/README.md`](../../../../harness/README.md) §Traceability (dieselbe Zusage, zweiter Ort),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate
über einem Bestand, den niemand mehr ändern kann, senkt seine eigene Aussage — daraus folgt der
Cutoff in DoD (2)),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel nennt die **Commit-Message** ausdrücklich als
Zusage-Träger),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Hook- und Nachweis-Mechanik dieses Repos — sie entscheidet, wo ein Vor-Commit-Sensor hängt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
(`doc-commits` ist eines der elf advisory-Ziele; wird es behauptet, zieht Setzung 2 mit).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Eine Commit-Message ohne Traceability-Kennung färbt rot, bevor der Commit steht — und der Ort,
an dem das geschieht, ist danach ein benannter, wiederverwendbarer Träger.**

### Der Anlass: eine Zusage an zwei Orten, ohne einen Sensor

[`AGENTS.md`](../../../../AGENTS.md) §5 und
[`harness/README.md`](../../../../harness/README.md) §Traceability sagen zu, dass PRs und Commits
mindestens eine `LH-*`/`ADR-*`-Kennung nennen. Gelesen wird eine Commit-Message von nichts:
`git grep -lnE 'git (log|show|cat-file).*(%B|--format=.%s)|commit-msg|COMMIT_EDITMSG' -- Makefile d-check.mk .d-check.yml harness/tools/ .claude/hooks/ .codex/ .github/ test/`
→ kein Treffer (Exit 1).

### Das Modul, und was es wirklich prüft — gemessen, nicht aus dem Namen geschlossen

Gegen eine Kopie außerhalb des Repos (Stand `1f5741f`, netzlos, `:ro`, Image `v0.65.0` per Digest),
Flags aus [`d-check.mk`](../../../../d-check.mk):

| Lauf | Ergebnis |
|---|---|
| `doc-commits`-Flags, `--range HEAD~20..HEAD`, **ohne** `commits:`-Block (heutiger Stand) | `425 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |
| dieselben Flags, **mit** `commits:`-Block (`id-patterns` für `ADR-`/`LH-`/`MR-`/`slice-`) | **2 Befunde** `commit-untraceable`, Exit 1 |
| `--commit-msg <datei>` auf eine Message **ohne** jede Kennung | **1 Befund** `commit-untraceable` auf einem Pseudo-Commit `pending`, Exit 1 |

**Drei Dinge folgen daraus.**

1. **`doc-commits` ist heute ein stilles Grün** — ohne `commits:`-Block ist das Modul inert und
   meldet trotzdem Exit 0. Dieselbe Klasse wie bei `targets` und `planning`.
2. **Der Träger existiert schon, und er ist kein Nachbau.** `--commit-msg <datei|->` nimmt eine
   Message-Datei entgegen, **bevor** ein Commit existiert, und meldet gegen einen Pseudo-Commit
   `pending`. Dieses Repo committet über `git commit -F <datei>`; die Datei ist also da, wenn der
   Sensor sie braucht.
3. **Das Modul prüft die Anwesenheit einer Kennung, nicht die Wahrheit einer Aussage.** Eine
   Message, die den nicht auflösbaren Hash `0f8d1a1` **und** eine gültige Kennung trägt, geht mit
   **Exit 0** durch — gemessen mit derselben `--commit-msg`-Form.

### Warum das [slice-121](slice-121-commit-message-nennt-was-es-gibt.md) nicht ersetzt, aber trägt

Die zwei Slices prüfen **verschiedene Eigenschaften** derselben Zeichenkette:
`commits` fragt *„steht hier eine Kennung?"*,
[slice-121](slice-121-commit-message-nennt-was-es-gibt.md) fragt *„bezeichnet dieses Hex-Token ein
Objekt dieses Repos?"*. Messung 3 ist der Beleg, dass die eine die andere nicht abdeckt: der tote
Hash passiert `commits` ungehindert.

**Gemeinsam ist ihnen der Träger**, und der ist die teure Hälfte.
[slice-121](slice-121-commit-message-nennt-was-es-gibt.md) §6 hält fest, ein Vor-Commit-Sensor habe
*„in diesem Repo keinen Präzedenzfall"*, und §3 führt den Ort als **offen**. Nach diesem Slice ist
er es nicht mehr. Daraus folgt die Arbeitsteilung: **dieser Slice entscheidet und baut den Ort**,
[slice-121](slice-121-commit-message-nennt-was-es-gibt.md) hängt seine Eigenschaft dort an, statt
einen zweiten Ort zu erfinden. Zusammenlegen wäre falsch — sechs slice-eigene DoD-Punkte, und Modul 5
§Ziel-Form nennt das nicht *„eine längere DoD"*, sondern *„der Schnitt ist falsch"*.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Eine Message-Datei ohne Kennung wird rot, bevor der Commit steht.** Der Sensor läuft an
      einem benannten Ort und nennt in der Meldung, **welche** Eigenschaft er prüft.
      **Rot:** eine Message-Datei ohne `ADR-`/`LH-`/`MR-`/`slice-`-Kennung → Exit ≠ 0 mit
      `commit-untraceable`; dieselbe Datei mit Kennung → Exit 0. Beide Läufe gehören in den
      Umsetzungs-Commit.
- [ ] **(2) Der Prüfbereich ist entschieden und trägt seinen Cutoff.** Zu entscheiden sind die
      `id-patterns` (welche Kennungen dieses Repo als Traceability zählt), die `exempt-pattern`
      (Merge/Revert) und **ob neben dem Vor-Commit-Lauf eine Range in CI läuft — und ab welchem
      Commit**.
      **Rot:** ein Maßstab über der ganzen Historie. Er wäre an einem Bestand rot, den niemand mehr
      ändern kann, und fiele damit unter
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) —
      dieselbe Cutoff-Begründung wie in
      [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).
      Mechanisch rot: der gewählte Range-Lauf meldet über dem Bestand **vor** dem Cutoff einen
      Befund.
- [ ] **(3) Der Träger ist als Träger dokumentiert, nicht nur als Ziel.** In
      [`harness/README.md`](../../../../harness/README.md) steht, wo ein Message-Check hängt, was er
      bekommt (Datei gegen Range) und was er **nicht** prüft — ausdrücklich: **nicht** die Wahrheit
      der Aussagen, nur die Anwesenheit einer Kennung.
      **Rot:** `make mutate` meldet **BEFUND** auf den `test/mutations/`-Fall, der die
      Kennungs-Prüfung entfernt — der Zahn muss die Stelle treffen, die der Aufrufer benutzt, sonst
      misst er sich selbst.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | der `commits:`-Block (`id-patterns`, `exempt-pattern`). **`commits` gehört NICHT in `modules:`** — es braucht eine Range bzw. eine Message-Datei und liefe im hermetischen `docs-check` ins Leere |
| [`Makefile`](../../../../Makefile) | update | das Ziel, das den Vor-Commit-Lauf fährt (`--commit-msg`), und ggf. das Range-Ziel für CI. Ein neues behauptetes Ziel zieht [`AGENTS.md`](../../../../AGENTS.md) §4 mit |
| [`.claude/hooks/`](../../../../.claude/hooks) | offen | falls der Ort ein Hook-Griff auf `git commit -F` ist; dann berührt der Slice [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) und die vom Guard selbst benannte Grenze |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | update | nur falls DoD (2) eine Range in CI entscheidet — dann ist [slice-123](slice-123-ci-sieht-die-historie.md) **Voraussetzung**, sonst ist der Lauf dort blind und grün |
| `test/` | neu | der bats-Fall, den DoD (3) mit einem `test/mutations/`-Fall belegt |
| [`harness/README.md`](../../../../harness/README.md) | update | der Träger und seine Grenze (DoD (3)) |
| [`slice-121`](slice-121-commit-message-nennt-was-es-gibt.md) | **nicht durch diesen Slice** | dessen §3/§4/§6 sind mit der Träger-Messung nachgezogen; die **Eigenschaft** bleibt seine |
| [`AGENTS.md`](../../../../AGENTS.md) §3, [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8); §4 darf der Slice anfassen, §3 nicht |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet, das WIP-Limit ist frei — und
[slice-123](slice-123-ci-sieht-die-historie.md) liegt in `done/`, falls DoD (2) eine Range in CI
entscheidet.** Der Vor-Commit-Zweig allein braucht keine Historie und könnte früher laufen; weil die
Entscheidung aber **Teil** der DoD ist und nicht vor ihr steht, wartet der Slice.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: DoD (2) endet mit **zwei** Läufen (Vor-Commit **und** Range), die je
  eigene Zähne, eigene Doku und eigene Ausnahmen brauchen. Dann sind es zwei Slices, kein vierter
  DoD-Punkt.
- `in-progress` → `open`: der einzige tragfähige Ort erweist sich als agenten-gebunden — ein
  Hook, den nur **ein** Klient fährt ([`.codex/hooks.json`](../../../../.codex/hooks.json) führt
  allein den SessionStart-Injektor). Dann ist der Sensor ein Stolperdraht für einen Klienten und
  keine Repo-Zusage; die Lage gehört als Carveout nach Modul 7 aufgeschrieben. **Dieselbe
  Rückführung steht in [slice-121](slice-121-commit-message-nennt-was-es-gibt.md) §4** — sie
  betrifft den Träger, und der ist geteilt.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund,
Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7
mit Steering-Loop-Eintrag **und** der ausdrücklichen Feststellung, ob
[slice-121](slice-121-commit-message-nennt-was-es-gibt.md) den Träger nun übernehmen kann.

## 6. Risiken und offene Punkte

- **Der Name des Moduls verspricht mehr, als es hält.** `doc-commits` heißt in
  [`d-check.mk`](../../../../d-check.mk) *„Commit-Message-Traceability"*; geprüft wird die
  **Anwesenheit** eines Kennungs-Musters. Ein Ziel, das *„Commit-Message geprüft"* ausgibt,
  behauptet mehr als es misst — dieselbe Falle, die
  [slice-121](slice-121-commit-message-nennt-was-es-gibt.md) §6 für seinen eigenen Sensor benennt.
  Die Meldung muss die Eigenschaft nennen, nicht den Gegenstand.
- **Ein Vor-Commit-Sensor kann umgangen werden, und das ist keine Ausrede, sondern eine Grenze.**
  Wer ohne den Hook committet, wird nicht gesehen. Was der Sensor deckt, hängt am Klienten; was er
  nicht deckt, gehört in dieselbe Zeile wie das, was er deckt.
- **Zwei Läufe über denselben Gegenstand driften.** Läuft der Check vor dem Commit **und** über
  eine Range in CI, müssen beide dieselbe Config lesen — sonst ist grün vor dem Commit und rot in
  CI möglich, und die Ursache liegt in der Konfiguration statt im Befund.
- **Der Cutoff ist der Punkt, an dem dieser Slice sich selbst entwerten kann.** Die zwei
  `commit-untraceable`-Befunde aus §1 stammen aus `HEAD~20..HEAD` — also aus dem **jüngsten**
  Bestand, nicht aus grauer Vorzeit. Ein Cutoff, der sie ausschließt, schließt genau die Fälle aus,
  für die der Sensor gebaut wird; einer, der sie einschließt, macht den Gate ab Tag eins rot. Diese
  Spannung ist echt und gehört in DoD (2) entschieden, nicht hier weggewunken.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Für einen
hermetischen Sensor mit `Makefile`-Ziel, bats-Fall und `test/mutations/`-Zahn ist
`make comment-claims` der Präzedenzfall; für den Hook-Ort ist es
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks).
