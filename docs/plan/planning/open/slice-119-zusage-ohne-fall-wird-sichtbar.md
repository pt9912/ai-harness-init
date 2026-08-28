# Slice slice-119: Eine fail-closed Zusage ohne Fall wird sichtbar — der Sensor zählt, was er nicht bewacht, und nennt seine Bezugsmenge

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Zähl-Schritt am bestehenden Sensor. **(2) Gemeinsames
Closure-Kriterium?** Nein. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: der
Steering-Loop-Eintrag aus [slice-117](../done/slice-117-lauf-ohne-ende-faerbt-rot.md) §7. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap.

**Ebene: Dogfood, nicht emittiert.** `grep -rln 'mutate' internal/emit/templates/ | wc -l` → **0**.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (der Gegenstand: *„wer keinen Fall in `test/mutations/`
hat, ist unbewacht"* — die Regel steht, ihr Träger fehlt),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (die Cutoff-Begründung, die hier wörtlich zutrifft: ein
Maßstab über dem Bestand wäre dauerhaft rot und entwertete die Regel, statt sie zu tragen),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate über leerem oder dauerhaft rotem Prüfbereich senkt seine eigene Aussage),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Sensor-Mechanik dieses Repos),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**Ein Wächter, den kein `test/mutations/`-Fall nennt, ist zählbar — mit seiner Bezugsmenge und
einem Schnitt, der entschieden ist, statt dass ein Maßstab über dem Bestand dauerhaft rot steht.**

### Der gemessene Anlass

`make mutate` prüft die **Haltbarkeit** der Zähne, die in `test/mutations/` **gelistet** sind. Über
eine Stelle **ohne** Fall sagt er nichts — und genau diese Lage ist in
[slice-117](../done/slice-117-lauf-ohne-ende-faerbt-rot.md) dreimal in einem Commit eingetreten:
drei Reparaturen ohne Fall, jede einzeln neutralisiert, und die bats-Ebene blieb jedes Mal
vollständig grün (**187 ok / 0 not ok**, in
[Review](../../../reviews/2026-08-27-slice-117-review-runde2.md) §2 B-1 und in
[Verifikation](../../../reviews/2026-08-27-slice-117-verify-runde2.md) §4.2/§4.3 **unabhängig
voneinander** gemessen). **Gefunden hat sie jedes Mal eine zweite Rolle, nie der schreibende Lauf.**

### Die Fläche, mit ihrer Eigenschaft vor der Zahl

Die Eigenschaft: *ein bats-Titel, den keine `# expect:`-Zeile eines Falls nennt*. Gezählt über den
Bestand — bats-Titel aus
`grep -h '^@test' test/*.bats | sed 's/^@test *"//; s/" *{ *$//' | sort -u`, `# expect:`-Ziele aus
`grep -h '^# expect:' test/mutations/*.sh | sed 's/^# expect: *//' | sort -u`, verglichen mit
`comm -23`:

| Menge | Kommando | Stand |
|---|---|---|
| bats-Titel (eindeutig, alle `test/*.bats`) | `… \| wc -l` über der Titel-Liste | **189** |
| davon **ohne** Fall | `comm -23 <titel> <expects> \| wc -l` | **167** |
| in `test/mutate-driver.bats` allein | dieselbe Rechnung über nur dieser Datei | **33** von **48** |

**Die Bezugsmenge hat zwei Schichten, und die Tabelle oben misst nur eine.** `make mutate` bindet
seine Fälle über `# expect:` an **beide** Stufen — die bats-Stufe (`not ok N`) und die Go-Stufe
(`--- FAIL:`). Von den `# expect:`-Zielen ist die Mehrheit gar kein bats-Titel:
`grep -h '^# expect:' test/mutations/*.sh | sed 's/^# expect: *//' | sort -u | wc -l` → **171**
eindeutige Ziele, davon `… | grep -c '^Test'` → **109** Go-Testnamen. Über der Go-Stufe gerechnet —
Funktionen aus
`git grep -h '^func Test' -- '*_test.go' | sed 's/^func \(Test[A-Za-z0-9_]*\).*/\1/' | sort -u`,
verglichen per `comm -23` mit denselben Zielen:

| Menge | Kommando | Stand |
|---|---|---|
| Go-Testfunktionen (eindeutig, im Index) | `… \| wc -l` über der Funktions-Liste | **226** |
| davon **ohne** Fall | `comm -23 <gotests> <expects> \| wc -l` | **117** |

**Der gemessene Anlass für diese zweite Schicht liegt in
[slice-122](../done/slice-122-d-check-pin-v0650.md)**, und er ist die unbequeme Sorte: der
Wächter, an dem dessen DoD (1) ihr Rot holt — die Kopplung des gelebten d-check-Pins an den
emittierten Default —, hat selbst keinen Fall.
`grep -rn 'MatchesCanonical' test/mutations/` → leer (Exit 1), während **drei** Geschwister
derselben Klasse je einen führen
(`grep -rln 'PinsMatchRepo\|MatchesMakefile\|PinsProducingRef' test/mutations/` →
`01-baseline-pin-kopplung.sh`, `18-gen-pin-drift.sh`, `66-archgate-pin.sh`). Zwei Rollen haben ihn
unabhängig gemeldet ([Review](../../../reviews/2026-08-28-slice-122-review.md) MEDIUM-4,
[Verifikation](../../../reviews/2026-08-28-slice-122-verify.md) V-8); die Lücke ist **älter als
jener Slice** und hat drei Pin-Sprünge überlebt. Ein Wächter, der nur bats-Titel zählt, hätte sie
in keinem der drei gemeldet — **deshalb steht sie hier und nicht als eigener Schnitt**: ein
einzelner nachgereichter Fall schlösse diese eine Stelle und ließe die übrigen der **117**
unsichtbar. Die Zahl ist eine **mitwandernde**: jeder neue Go-Test hebt sie, ohne dass am
Gegenstand etwas bricht — sie taugt als Fläche, nicht als Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Welche der zwei Schichten der Sensor trägt, ist damit Teil der Entscheidung aus DoD (2)** und
keine Formulierungsfrage: DoD (1) unten nennt die bats-Schicht, weil sie zuerst gemessen war. Die
Asymmetrie der zwei Bestände gehört in die Abwägung — **167** von **189** auf der bats-Stufe gegen
**117** von **226** auf der Go-Stufe.

**Ein Maßstab über diesem Bestand wäre dauerhaft rot** — und eine Regel, deren Maßstab dauerhaft
rot ist, trägt nicht, sie wird umgangen. Dieselbe Begründung trägt den Cutoff in
[`AGENTS.md`](../../../../AGENTS.md) §3.7. Der Schnitt ist deshalb **Gegenstand** dieses Slice und
nicht seine Voraussetzung.

### Was dieser Slice nicht ist — drei Nachbarn, gegen die er abgegrenzt ist

- [slice-069](../open/slice-069-zahn-bindet-zusicherung.md) fragt, ob ein vorhandener Fall die
  **Zusicherung** bindet statt nur einen Wächter-**Namen** — Richtung Fall → Eigenschaft.
- [slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md) führt eine **benannte,
  kleine Menge** von Assertions (Träger-Wächter) und verlangt für jede *rot gesehen oder mit Grund
  als unbewacht ausgesprochen*.
- Dieser Slice fragt die **Abdeckungs-Richtung** über den **ganzen** Bestand: welche Wächter hat
  gar kein Fall, und wie groß ist die Menge, über die das gesagt wird.

Die drei sind verwandt und **nicht** dasselbe; ob sie zusammengelegt gehören, entscheidet die
Priorisierung, nicht dieser Plan.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Der Sensor nennt die unbewachten Wächter mit ihrer Bezugsmenge — als Messung, nicht als
      Urteil über den Bestand.** Die Ausgabe sagt *„N von M bats-Titeln nennt kein
      `test/mutations/`-Fall"* und listet die N; sie nennt ihren Nenner in derselben Zeile
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):
      eine Zahl ohne Bezugsmenge ist kein Befund).
      **Rot:** ein Titel, den ein Fall nennt, wird umbenannt — er muss danach in der Liste stehen;
      und ein `test/mutations/`-Fall über dem Sensor selbst färbt einen benannten Wächter rot.
- [ ] **(2) Der Schnitt ist ENTSCHIEDEN, nicht angefangen.** Drei Wege stehen offen: **(a)** nur
      Titel, die nach einem Stichtag entstehen (Cutoff wie
      [`AGENTS.md`](../../../../AGENTS.md) §3.7), **(b)** nur Titel, deren Kommentar eine
      fail-closed-Zusage führt, **(c)** ein reiner Vollständigkeits-Zähler ohne Schwelle. Die Wahl
      steht **mit ihrer Begründung im Plan** und, falls sie eine Adaption wird, als Übergabe an den
      Architect — nicht im Skript-Kommentar.
      **Rot:** eine Fassung ohne entschiedenen Schnitt ist über dem heutigen Bestand rot
      (**167** von **189**) und damit ein Gate, das nichts trägt.
- [ ] **(3) Der Sensor ist ein Schritt am bestehenden Werkzeug, kein neues Gate mit eigenem Namen.**
      Er hängt an einem vorhandenen `make`-Ziel; kein `make`-Ziel kommt hinzu, dessen Prüfbereich
      erst noch entstehen müsste
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
      [`AGENTS.md`](../../../../AGENTS.md) §3.1).
      **Rot:** `git diff --name-only` über dem Commit enthält `Makefile` mit einer neuen
      `.PHONY`-Zeile — dann ist der Schnitt falsch.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update **oder** unverändert | der Treiber kennt beide Mengen bereits (`# expect:`-Ziele und die bats-Dateien); ob der Zähl-Schritt dorthin gehört oder in ein eigenes Werkzeug neben ihm, ist Frage A |
| [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) | update | die Sensor-Ebene; `grep -c '^@test' test/mutate-driver.bats` → **48** beim Anlegen dieses Plans |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | der Zahn aus DoD (1); Nummern im Anschluss an die höchste vergebene (`ls -1 test/mutations/*.sh \| sed -n 's#.*/\([0-9]*\)-.*#\1#p' \| sort -n \| tail -1` → **205**, beim Anlegen neu auszuzählen) |
| [`harness/README.md`](../../../../harness/README.md) | update | der Nicht-Gate-Verify-Absatz beschreibt, was `make mutate` prüft; kommt eine Zählung hinzu, sagt er, worüber sie zählt und worüber nicht |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nur als Übergabe** | wird der Schnitt aus DoD (2) eine Adaption, schreibt sie der Architect in einem eigenen Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)) |
| [`docs/plan/adr`](../../adr) | **unverändert** | die Änderung **hebt** eine Zusage an und senkt keine Schwelle ([`AGENTS.md`](../../../../AGENTS.md) §3.5) |

**Drei Fragen, die vor dem Code zu beantworten sind — die Antworten gehören in diesen Plan.**

| # | Frage — und warum sie den Schnitt entscheidet |
|---|---|
| A | **Wo sitzt die Zählung — im Treiber oder daneben?** Im Treiber liest sie beide Mengen ohne zweiten Leser, läuft dann aber nur, wenn der teure Lauf läuft (letztes Protokoll: **751,98 s**, `tail -1`). Daneben ist sie billig und in `make gates` tragbar, braucht aber einen zweiten Parser für dieselben zwei Formate |
| B | **Was ist der Schnitt aus DoD (2), und was kostet er?** (a) Stichtag heißt: der Bestand von **167** bleibt unberührt und die Regel bindet nur Neues — prüfbar nur gegen `git`. (b) Fail-closed-Zusage heißt: eine Eigenschaft im Kommentar wird zum Kriterium, und wer sie erkennt, muss sie messen können. (c) Reiner Zähler heißt: kein Rot, nur eine Zahl — dann ist der Träger die Sichtbarkeit, nicht die Sperre |
| C | **Welche bats-Dateien gehören in die Bezugsmenge?** Heute **189** Titel über **17** Dateien (`ls test/*.bats \| wc -l`), von denen einige Wächter über Fremd-Werkzeugen führen. Eine Menge, die zu breit ist, macht die Zahl unbrauchbar; eine, die zu eng ist, verschweigt genau die Stellen, an denen die Klasse zuletzt aufgetreten ist |

## 4. Trigger

**Beginn (`open` → `next`): nichts blockiert.**

**Die Reihenfolge gegenüber [slice-069](../open/slice-069-zahn-bindet-zusicherung.md),
[slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md) und
[slice-118](../open/slice-118-vorwaermlauf-endet-von-selbst.md):** alle vier berühren den
Mutations-Sensor oder seine Fall-Menge. Das ist eine Beobachtung, keine Reihenfolge. **Was hier
ausdrücklich nicht behauptet wird:** dass sie zusammengehören.

**Rückführung `in-progress` → `next`:** wenn Frage B zeigt, dass der Schnitt eine eigene Messung
über dem Bestand braucht (welche Kommentare tragen eine fail-closed-Zusage, und ist das mechanisch
erkennbar) — dann ist die Messung ein eigener Schnitt.

**Rückführung `in-progress` → `open` (blockiert):** wenn jeder tragfähige Schnitt eine Adaption in
[`harness/conventions.md`](../../../../harness/conventions.md) verlangt. Die schreibt der Architect
([`AGENTS.md`](../../../../AGENTS.md) §3.8), und dann wartet der Slice auf sie statt sie zu
schreiben.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; die Zählung ist **einmal gegen einen hergestellten
Zustand rot gesehen** (ein Fall, dessen `# expect:`-Ziel nicht mehr existiert); Frage A, B und C
sind mit ihrer Begründung **im Plan** beantwortet; mindestens eine der drei Instanzen aus
[slice-117](../done/slice-117-lauf-ohne-ende-faerbt-rot.md) ist nachgestellt und wird von der neuen
Zählung **benannt** — ein Sensor, der seine eigene Fund-Geschichte nicht reproduziert, ist unbelegt;
Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün; `make mutate` ohne
Befund; `git mv` nach `done/` als eigener Move-Commit; Closure-Notiz mit Steering-Loop-Eintrag.

**Ausdrücklich nicht Teil des Closure-Triggers: dass der Bestand von 167 kleiner wird.** Der Slice
liefert die **Sichtbarkeit** und den **Schnitt**, nicht die Nacharbeit; wer beides verlangt,
schneidet einen Slice, der in einer Review-Sitzung nicht prüfbar ist (Modul 5 §Ziel-Form).

## 6. Risiken und offene Punkte

- **Ein Zähler ohne Schwelle ist leicht zu ignorieren.** Genau das ist der Preis von Weg (c) in
  Frage B, und er gehört benannt statt umgangen: eine Zahl, die niemanden aufhält, ist ein
  Feedforward-Posten, kein Feedback-Sensor.
- **Ein Schnitt gegen `git` altert.** Weg (a) prüft gegen die Historie; ein `git`-abhängiger Sensor
  bricht in jeder Kopie ohne `.git` — der Treiber hat dafür schon einen eigenen bats-Fall
  (`grep -c 'inklusive .git' test/mutate-driver.bats`).
- **Der Sensor kann selbst zur Klasse gehören.** Er trägt eine Zusage über Zusagen; ohne eigenen
  Fall in `test/mutations/` ist er genau das, was er misst. Das ist DoD (1), zweiter Halbsatz.
- **Die Zahl 167 ist eine Momentaufnahme.** Sie wandert mit dem Bestand
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) und ist beim Anlegen neu zu erheben; ihr Kommando steht in §1.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

### Sub-Area: Mutations-Sensor (`harness/tools/` + `test/mutations/` + die bats-Ebene)

Eine Sub-Area: der Sensor, seine Fall-Menge und die Wächter, über die er urteilt.

- **Modus:** GF. Der Sensor ist in diesem Repo entstanden (slice-026) und seither gegen den Kurs
  geführt.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.6 definiert seinen Zweck
  **und** benennt seine Grenze (*„Es prüft die Haltbarkeit vorhandener Zähne, nicht die Entstehung
  neuer"*); genau an dieser Grenze setzt der Slice an.
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  trägt seine Einbettung.
- **Phase-Reife:** Phase 5 (Betrieb). **198** Fälle
  (`ls -1 test/mutations/*.sh | wc -l`), **189** bats-Titel über **17** Dateien.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für die Zahl (sie ist mit ihrem Kommando erhoben),
  **mittel für den Schnitt**: welche der 167 Titel eine fail-closed-Zusage führen, ist heute nicht
  gemessen — das ist Frage B und der Grund für die Rückführung in §4.
- **Reconciliation-Aufwand:** gering für DoD (1) und (3), **offen für DoD (2)**. Graduation-Trigger
  entfällt; die Sub-Area ist bereits GF.
