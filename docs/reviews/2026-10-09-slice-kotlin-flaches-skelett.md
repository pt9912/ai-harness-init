# Review-Report: slice-kotlin-flaches-skelett — 2026-10-09

**Review-Art:** Code — Diff gegen Plan, ADR und Hard Rules (die DoD prüft der Verifier).

**Gegenstand:** Commit `17c80593` (Implementer, Welle `welle-kotlin-skelett`).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-09

**Eingangs-Kontext:**

- Slice-Plan `slice-kotlin-flaches-skelett` (Stand `17c80593`), Welle-Plan `welle-kotlin-skelett` §6
- [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (Accepted)
- [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
  [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules)

**Summary:** 0 HIGH · 2 MEDIUM · 2 LOW · 2 INFO — Klassen: *Plan-Zeile vom Implementer selbst gegen
eine Welle-Abgrenzung eingetragen* · *emittiertes Gate am gemischten Root läuft das Dockerfile
einer anderen Sprache* · *Abdeckungs-Aussage nennt mehr, als der Lauf misst* · *Teilstring-Prüfung
trifft fremde Wörter*.

## Findings

### MEDIUM-1 — Handbuch-Nachzug gegen die Abgrenzung der Welle

- `quelle`: Welle-Plan `welle-kotlin-skelett` §6; [`AGENTS.md`](../../AGENTS.md) §3.10
- `pfad`: `docs/user/benutzerhandbuch.md:482`; Slice-Plan §3, Zeile `docs/user/benutzerhandbuch.md`
- `befund`: Ja, ein Widerspruch: §6 der Welle schließt den „Handbuch-Nachzug" aus („gehört in den
  Release-Schnitt"), der Diff schreibt die Zeile `SKEL_KOTLIN_VERSION` trotzdem. Die §3-Zeile im Slice-Plan,
  die das deckt, hat der Implementer im selben Commit selbst eingetragen (`git show 17c80593 --
  docs/plan/planning/in-progress/slice-kotlin-flaches-skelett.md` → vier `+`-Zeilen in §3). Das
  Planner-Artefakt wurde also nicht vorab geändert. Failure-Szenario: Das Handbuch nennt einen Knopf, den das letzte Release
  (`v0.5.0`) nicht kennt; wer danach handelt, ruft `add-lang kotlin` gegen ein Binär ohne
  Kotlin-Profil.
- `verifizierbar`: nein — kein Gate hält einen Diff gegen die Abgrenzung der Welle.
- `klasse`: Plan-Zeile vom Implementer selbst gegen eine Welle-Abgrenzung eingetragen

Entscheiden muss der Planner. Entweder wird die Zeile in den Release-Schnitt verschoben, oder er hebt §6 der Welle ausdrücklich auf. Die Begründung „öffentlicher Vertrag"
(Workflow Schritt 7) steht gegen eine ausdrückliche Abgrenzung; das löst nicht der ausführende Lauf.

### MEDIUM-2 — Kotlin-Gate am gemischten Root baut das Go-Dockerfile, im Ziel ungenannt

- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 3
- `pfad`: `internal/gen/kotlin.go` (`kotlinMixedMkFragmentTmpl`); `harness/tools/full-smoke.sh:2812`
- `befund`: Bei `add-lang kotlin .` an einem Go-Root bleibt das Go-`Dockerfile` liegen
  (skip-if-present). Das Ziel `test-kotlin` meldet in seiner Hilfe „Kotlin-Tests (gradle test,
  test-Stage)", baut aber mit `docker build --target test -t kotlin:test .` die Go-Stage. Im Ziel
  wird also weder `Main.kt` kompiliert noch detekt gefahren, und `make gates` meldet trotzdem grün. Die
  Kurzbeschreibung der full-smoke-Stufe nennt diese Grenze am selben Ort (die Abdeckungs-Aussage nach
  §3.6 hält also). Weder das emittierte Fragment noch die Ausgabe von `add-lang` nennt sie aber, und
  kein Eintrag im Beobachtungs-Register führt sie (`ls docs/plan/planning/observations/BEO-ALL/ | grep
  -iE 'gemischt|mixed|root'` → leer). Das Muster stammt aus dem cpp-Bestand und ist für Kotlin neu
  verdrahtet.
- `verifizierbar`: ja — die Stufe selbst belegt es (Marker `-t kotlin:` aus dem Go-Dockerfile).
- `klasse`: emittiertes Gate am gemischten Root läuft das Dockerfile einer anderen Sprache

### LOW-1 — Stufe 13 behauptet den Guard gegen „die Host-Toolchain", gemessen ist `gradle`

- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (emittierte Abdeckungs-Aussage)
- `pfad`: `harness/tools/full-smoke.sh:2717`, `docs/user/e2e-abdeckung.md` Stufe 13
- `befund`: Die Kurzbeschreibung lautet „… und dem Guard gegen die Host-Toolchain". Der Lauf schickt genau ein
  Kommando (`gradle build`) durch den Guard; die übrigen neun Einträge von `blocked/kotlin` misst im Ziel
  nichts. `TestBlockedFragment_CoversAllGenProfiles` hält nur, dass ein Eintrag existiert.
- `verifizierbar`: ja — eine Mutation, die `java` aus der Liste streicht, lässt die Stufe grün.
- `klasse`: Abdeckungs-Aussage nennt mehr, als der Lauf misst

### LOW-2 — `TestUsage_NenntJedeSpracheUndIhrenKnopf` misst „go" nicht

- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `cmd/ai-harness-init/main_test.go` (neuer Test)
- `befund`: `strings.Contains(addLangUsage, "go")` trifft auch „hexa**go**nal" in derselben Hilfe
  (drei Zeilen der Konstante `addLangUsage` enthalten `go`, nur eine
  ist die Sprachliste). Fällt „go" aus der Sprachliste, bleibt der Test grün; sein Name sagt „jede
  Sprache" zu. Für `kotlin` und `cpp` trägt er.
- `verifizierbar`: ja — `go, ` aus der Zeile `<sprache>` streichen, der Test bleibt grün.
- `klasse`: Teilstring-Prüfung trifft fremde Wörter

### INFO-1 — Mutationsfall 306 geht über den Plan hinaus, die Erwartung ist nicht verwässert

- `quelle`: [MR-071](../../harness/conventions.md#mr-071)
- `pfad`: `test/mutations/306-rollenachse-emit-aufruf-entfernt.sh`
- `befund`: Die §3-Zeile nennt nur 54 und 56. 306 folgt der Stufe, die den leeren `.claude/agents/`
  jetzt zuerst meldet (`harness/tools/handbuch-baum.sh:115`). Die neue Erwartung ist enger als die
  alte und trifft dieselbe Verdrahtung. Die Prüfung „Rollen-Typ fehlt" (`full-smoke.sh:316`) bindet
  dabei weiter Fall 305. 54 und 56 erweitern das `sed`-Muster nur um die gofmt-Leerzeichen und
  löschen dieselbe Zeile wie vorher.
- `verifizierbar`: ja
- `klasse`: —

### INFO-2 — Pins per Tag, LH-QA-02-Restlücke wie bei cpp

- `quelle`: [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 2
- `pfad`: `internal/gen/kotlin.go`
- `befund`: `gradle:9.8.1-jdk21` ist per Tag gepinnt, Kotlin-Plugin `2.4.21` und detekt `1.23.8` per Version,
  es gibt keinen Wrapper und keinen Digest. Das entspricht der ADR. Transitive Maven-Abhängigkeiten
  sind ohne Lockfile gepinnt, also nur über die Plugin-Versionen. Das ist dieselbe Lage, die
  `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` für cpp führt; der Plan §8 notiert sie.
- `verifizierbar`: nein
- `klasse`: —

## Gefahrene Proben

```text
$ make mutate MUTATE_CASES='618-kotlin-stage-match 619-kotlin-blocked-kopplung 620-kotlin-hilfe-knopf'
mutate: 3 ok, 0 Befund(e)
```

Gegenprobe zur Exklusivität (Kopie unter dem Scratchpad, Mutation angewandt, nur der benannte
Test mit `t.Skip`, `make test-go`). Bei 618, 619 und 620 ist der Lauf grün (rc=0): Jeder benannte Test
bindet allein.

621 und 622 (`verify: full-smoke`, Netz) wurden nicht gefahren. Statisch geprüft: Beide `sed`-Anker
treffen genau die Quellzeile, die der Aufrufer nutzt. Das ist `kotlin.go`, die `println`-Zeile in
`kotlinMain`, und `main.go:486` in `codeGateFragmentFor`. Unter 622 bleibt
`--target test -t app:` aus dem überschreibenden Kotlin-Rezept stehen, und `-t kotlin:` fehlt. Damit greift die
erwartete Meldung vor der Prüfung auf Rezept-Überschreibung.

## Negativbefunde (geprüft, ohne Befund)

- **Guard-Liste:** `java`, `jar` und `jshell` sind JDK-Werkzeuge im Sinn von ADR-0088 Festlegung 5 („JDK-Werkzeuge"). Das passt zur Docker-only-Regel im Ziel (wie `go` bei go). Kein Befund.
- **Fragment ↔ Stages:** Alle drei Fassungen rufen nur `test`, `lint` und `build`. Das Dockerfile führt diese drei Stages; 618 bindet das allein.
- **Schnitt ADR-0088 Festlegung 1/4:** `settings.gradle.kts` ohne `include`, `langArchs` kotlin nur `flat`, Paket == Verzeichnis (`app/Main.kt`, `package app`).
- **Hard Rules §3.2/§3.3/§3.4/§3.7:** keine Inline-Suppression, kein Move, keine ADR berührt; die neuen Kommentare beschreiben den Zustand.
- **Hilfetext/Knopf:** `SKEL_KOTLIN_VERSION` → `gen.DefaultVersion("kotlin")`; 620 bindet die Haupthilfe.
