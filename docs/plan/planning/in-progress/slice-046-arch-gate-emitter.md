# Slice slice-046: konditionaler Arch-Gate-Emitter (a-check)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-07-arch-achse](../welle-07-arch-achse.md).

**Bezug:** [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [ADR-0009](../../adr/0009-hexslice-arch-realisierung.md), [ADR-0008](../../adr/0008-arch-achse-emittiertes-skelett.md).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-25.

---

## 1. Ziel

Der Bootstrap emittiert das **Architektur-Gate** — `.a-check.yml` (Schicht-Config) +
`a-check.mk` (aus `a-check --print-mk`, Image digest-gepinnt) + ein Gate-Fragment, das
`a-check` an `GATE_CHECKS` hängt — **genau dann**, wenn das Modul ein schichten-tragendes
Layout trägt (`--arch hexslice`). Bei `flat` liegt **kein** a-check-Artefakt im Ziel
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Damit ist [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)
erfüllt und **M4** erreicht.

## 2. Definition of Done

- [x] **Wellen-Vorbedingung belegt (Schritt 0, vor Code):** a-check ist real — Image-Digest
      `sha256:6425c93a…` (v0.15.0) gegen die Registry verifiziert, `--print-mk` liefert ein
      Fragment, ein Lauf gegen das hexSlice-Skelett ist Exit 0. Ergebnis im Slice notiert;
      fällt der Beleg, greift der Welle-§5-Re-Scope (Carveout statt Emission).
- [x] [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) **Happy Path:** `add-lang <sprache> <pfad> --arch hexslice` → `<pfad>/.a-check.yml`
      + `a-check.mk` + `harness/mk/arch-<modul>.mk` liegen im Ziel, `make gates` fährt das
      Arch-Gate mit und ist Exit 0 (real in `make full-smoke`, nicht nur behauptet).
- [x] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) **konditional:** `--arch flat` (bzw. ohne `--arch`) emittiert **kein**
      `.a-check.yml`/`a-check.mk`/Arch-Fragment; `make gates` bleibt grün ohne a-check. Test +
      full-smoke-Assertion (Abwesenheit).
- [x] **Zähne belegt:** ein verbotener Import im emittierten Skelett (Domain → Adapter) färbt
      das emittierte Gate **rot** — einmal real gesehen (full-smoke), nicht behauptet.
- [x] **Kopplung Config ↔ Skelett** ([ADR-0009](../../adr/0009-hexslice-arch-realisierung.md) Fitness-Function): ein `go test` bindet die Schicht-Globs
      der emittierten `.a-check.yml` an die real generierten Rollen-Pfade; eine Drift färbt rot.
- [x] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): das emittierte `a-check.mk` ist auf den Digest gepinnt, der es **erzeugt
      hat** (nicht auf den vom Tool selbst gedruckten, der nachhinken kann) — Test.
- [x] `make gates` grün · `make mutate` grün mit je rot gesehener Mutation für die neuen
      Wächter (konditionale Emission · Digest-Pin · Config↔Skelett-Kopplung).
- [x] `make full-smoke` belegt **beide** Richtungen (hexslice → Gate läuft; flat → kein Gate).
- [x] Doku-Nachzug: [`harness/README.md`](../../../../harness/README.md) §Sensors / [`AGENTS.md`](../../../../AGENTS.md) §4 — a-check ist **emitted-only**,
      kein Dogfood-Gate (der Dogfood bleibt flach, welle-07 §6).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

Vor Code den Ist-Stand messen: `internal/emit/emit.go` (das d-check-Muster `--print-mk` →
`AdaptMK` → schreiben, samt Idempotenz-Klassen), `internal/gen/{arch,golang}.go` (die realen
hexSlice-Rollen-Pfade, aus denen die Schicht-Globs folgen), `cmd/…/main.go` (`wireLang` als
der EINE Verdrahtungs-Kern beider Eintrittspunkte) und `harness/tools/full-smoke.sh`.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/arch.go` | update | `ArchGateConfig(lang, arch)` — die `.a-check.yml` gehört zum Layout-Wissen (dieselbe Quelle wie die Rollen-Pfade); `flat`/nicht-getragen → kein Config |
| `internal/gen/*_test.go` | neu | Kopplungstest: jede Schicht-Glob deckt genau die real generierten Rollen-Dateien ([ADR-0009](../../adr/0009-hexslice-arch-realisierung.md)-Fitness) |
| `internal/emit/archgate.go` | neu | `ArchGate(...)`: `.a-check.yml` (skip-if-present, Adopter-Boden) + `a-check.mk` (konvergent, `--print-mk` + Digest-Re-Pin) + `harness/mk/arch-<modul>.mk` (konvergent) — Muster `DocGate` |
| `cmd/ai-harness-init/main.go` | update | `wireLang` bekommt `arch` und ruft `ArchGate` **konditional**; `A_CHECK_IMAGE`/`A_CHECK_DIGEST` als bewusste Env-Overrides |
| `internal/fetch/baseline.go` | update | die vendored Baseline landet heute mit **0700** im Ziel (`MkdirTemp`) — ein read-only Nicht-Root-Container (a-check) kann sie nicht traversieren → Exit 2 beim Root-Modul. 0755 wie ein frischer Klon |
| `harness/tools/full-smoke.sh` | update | beide Richtungen + Zähne (verbotener Import → rot) + Abwesenheit bei `flat` |
| `test/mutations/NN-*.sh` | neu | rot färbende Mutationen: konditionale Emission · Digest-Pin · Config↔Skelett |

## 4. Trigger

<!--
Wann beginnt dieser Slice? (`next` → `in-progress`: Implementer beginnt.)
Beispiele: "Wenn Welle X done." / "Wenn Carveout CO-NN aufgelöst."

Auch die zwei Rückführungen vorab benennen — unter welcher Bedingung
geht dieser Slice zurück?
- `in-progress` → `next`: zu groß, zurück zur Zerlegung.
- `in-progress` → `open`: blockiert (Carveout? siehe Modul 7).
(kanonische Definition: [`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.1/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine))
-->

- **Beginn (`open` → `in-progress`):** slice-045b **done** — die `--arch`-Achse ist verdrahtet
  und emittiert real ein schichten-tragendes Layout, also existiert der Prüfbereich, den das
  Gate braucht.
- **`in-progress` → `next` (zu groß):** falls der Mono-Repo-Fall (mehrere hexSlice-Module in
  einem Ziel) eigene Mechanik verlangt — dann Einzel-Modul-Emission liefern und den
  Mono-Repo-Fall abtrennen.
- **`in-progress` → `open` (blockiert):** falls der a-check-Beleg (Schritt 0) fällt — dann
  Carveout nach Welle §5 (die Welle liefert 044+045a+045b, die Emission wird vertagt).

## 5. Closure-Trigger

DoD vollständig, `make gates` + `make mutate` + `make full-smoke` grün mit rot gesehenen
Mutationen **und** rot gesehenem emittierten Gate (Zähne), Review konform + Verifier bestätigt
die DoD, Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Gate über leerem Prüfbereich (die Kern-Gefahr, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).** Eine Schicht-Config, deren
  Globs nichts treffen, meldet leer grün. Die kanonische Referenz warnt zusätzlich: ein
  Wildcard-in-der-Mitte-Glob (`…/**/ports/**`) macht die Slice-Regeln (`lateral-slice`,
  `port-locality`) **still inert**. Gegenmittel: literale Verzeichnis-Präfixe je Area/Slice
  **und** der Zähne-Beleg (verbotener Import → rot).
- **Verortung des Prüfbereichs (Mono-Repo).** Ein Modul unter `<pfad>` trägt seine Schichten
  unter `<pfad>/internal/…`. Entweder die Config trägt den Pfad-Präfix (Root-Config, kollidiert
  bei zwei Modulen) oder Config **und** Gate-Lauf sind modul-scoped (Muster slice-037:
  Root byte-identisch, Subdir scoped). Die Wahl gehört in den Plan, nicht in den Code.
- **Doppel-`include` des Tool-Fragments.** Tragen zwei Module das Arch-Gate, würde
  `include a-check.mk` zweimal greifen (`overriding recipe`-Warnung). Include-once-Wächter nötig.
- **Docker im `add-lang`-Pfad.** `--print-mk` ist ein Docker-Lauf; `add-lang` war bisher
  netzlos/Docker-frei. Die Abhängigkeit entsteht **nur** auf dem hexSlice-Pfad — der
  `flat`-Pfad muss unverändert netzlos bleiben (sonst regressiert slice-037).
- **Digest-Drift des Tool-Fragments.** `a-check --print-mk` druckt einen im Binary gebackenen
  `A_CHECK_IMAGE`-Pin, der nicht zwingend der Digest des laufenden Images ist (gemessen: er
  weicht ab). Ungeprüft übernommen wäre der emittierte Pin eine stille Unwahrheit
  ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

## 7. Closure-Notiz (nach `done/`)

**Schritt 0 — der a-check-Beleg (die Wellen-Vorbedingung), hier festgehalten statt nur in
der Commit-Message:** `ghcr.io/pt9912/a-check:v0.15.0` → Manifest-Digest
`sha256:6425c93a9a4359ef28c4da231a2d1db6f421fdaa8f96877ac89d201827c42d09`, per
`imagetools inspect` gegen die Registry verifiziert. `--print-mk` liefert real ein Fragment
(Exit 0). Ein Lauf gegen das generierte hexSlice-Skelett: **0 Befunde, Exit 0**; mit einem
eingeschmuggelten `domain → adapters`-Import: **Exit 1, `core-impurity`**. Die Vorbedingung
ist damit eingelöst, der Welle-§5-Re-Scope (Carveout) entfiel.

**Geliefert.** Der Bootstrap emittiert das Architektur-Gate **genau dann**, wenn ein Modul
Schichten trägt: `<pfad>/.a-check.yml` (skip-if-present), `a-check.mk` (konvergent, aus
`a-check --print-mk`) und `harness/mk/arch-<modul>.mk` (konvergent, **modul-scoped** nach dem
slice-037-Muster — Root hängt das Tool-Target an `GATE_CHECKS`, ein Unterverzeichnis bekommt
`a-check-<modul>`, das nur sein Modul mountet). `flat` bekommt nichts
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Damit ist
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) erfüllt und **M4 erreicht**.
Sensoren real: `make gates` grün (170 Dateien, 0 Befunde) · `make mutate` **67 ok/0** (Fälle
65–71 je rot gesehen) · `make full-smoke` **Exit 0**, 11 OK-Zeilen, Zähne- und Zwei-Modul-Beleg
sichtbar im Lauf-Output. Review Runde 1 NICHT KONFORM (5 MEDIUM) → Runde 2 **KONFORM**;
Verifier **DoD BESTÄTIGT**.

**Anders als geplant.** Zwei Befunde kamen aus dem Beleg-Lauf selbst, nicht aus dem Plan:
(1) `a-check --print-mk` druckt einen im Binary gebackenen Pin, der dem laufenden Image
**nachhinkt** — ungeprüft übernommen wäre der emittierte Pin eine stille Unwahrheit
([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); der Emitter pinnt auf die erzeugende Referenz um.
(2) Die emittierte Baseline landete mit **0700** im Ziel (`MkdirTemp`-Default) — die Gates
laufen als Nicht-Root über einem read-only Mount, a-check brach dort mit „permission denied"
ab. Beides war im Plan nicht vorgesehen und wurde mit Test + Mutation nachgezogen.

**Steering-Loop-Einträge:**

- **Ein Marker muss messen, was der Lauf ausgibt — nicht, was man ihm gedanklich zuschreibt.**
  Der erste full-smoke-Marker prüfte den Target-*Namen* `a-check-apps-hex` im Lauf-Output.
  `make` druckt aber die **Recipe**, und die trägt den Target-Namen nirgends — anders als bei
  den Go-Gates, deren Recipe zufällig `-t apps-hex:lint` enthält. Der Sensor war rot, das Gate
  war grün. **Regel: den Marker aus einer real gesehenen Ausgabezeile ziehen, nicht aus dem
  Namen des Dings, das man prüfen will.**
- **Eine gefundene Fehler-KLASSE ist erst erledigt, wenn alle ihre Instanzen gesucht wurden.**
  Review F-5 meldete eine `| grep -q`-unter-`pipefail`-Stelle; ich habe genau diese eine
  behoben — Runde 2 fand die **zweite Instanz im selben Slice** (`| head -2`), ausgerechnet in
  der Zeile, die den Zähne-Beleg druckt. **Regel: bei einem Klassen-Befund `grep` über das
  ganze Artefakt, nicht nur die genannte Zeile fixen.** (Die Klasse ist im Repo dokumentiert —
  [`printf|grep-q EPIPE`](../../../../harness/tools/full-smoke.sh) trägt sie im Kopf.)
- **Ein Fix an einer überdehnten Zusage kann eine neue überdehnte Zusage sein.** Der F-3-Fix
  ersetzte „der Präfix hält die Regeln scharf" durch „a-check meldet die vergessene Slice" —
  wahr nur, wenn sie eine Schicht importiert. Runde 2 fing es (N-2). **Regel: nach dem Fix die
  neue Formulierung gegen denselben Maßstab prüfen wie die alte; Truth-Accuracy-Fixes sind
  selbst Zusagen.** Der Präzedenz-Wert der zweiten Runde ([ADR-0007](../../adr/0007-bootstrap-phasen.md) NEU-H1) bestätigt sich
  damit auf Slice-Ebene, nicht nur bei ADRs.
- **Rollen-Trennung, gemessen:** Reviewer und Verifier fanden **unabhängig** denselben
  Kern-Defekt (F-1 == R-1: der include-once-Wächter keyte auf den dokumentierten
  Adopter-Override und schaltete das Gate ab, wenn man ihn benutzt). Zwei Rollen, ein Befund —
  dasselbe Signal wie in slice-038.

**Benannte Restrisiken (kein Folge-Slice, bewusst offen):**

- **F-9:** schlägt `--print-mk` fehl, hat das Modul sein Skelett und Code-Gate-Fragment, aber
  kein `blocked/<sprache>`-Fragment; ein Re-Lauf heilt. Atomarität ist im Emit-Pfad nirgends
  zugesagt.
- **F-10:** `harness/mk/arch-<modul>.mk` kollidiert mit dem Code-Gate-Fragment eines Moduls
  unter dem Pfad `arch/<sprache>`. Braucht einen so benannten Modul-Pfad, um real zu werden.
- **N-3:** der Sentinel verschiebt die F-1-Klasse auf einen tool-privaten Namen, tilgt sie
  nicht — ein gesetztes `ARCH_GATE_MK_INCLUDED` in der Umgebung reißt den `include` weiterhin
  weg. Der Restfall ist **fail-loud** (Abbruch), nicht fail-open.
- **N-5:** der Rot-Pfad des include-once-Sensors ist bauartbedingt nicht von `make mutate`
  erreichbar (mutate fährt `make test`/`make smoke`, nicht `full-smoke`).
- **Vertical-Slice-Regeln:** `lateral-slice`/`port-locality` können mit der **einen**
  generierten Slice noch nicht feuern. Die literalen Glob-Präfixe halten sie scharf, sobald der
  Adopter eine zweite Slice anlegt und einträgt; real rot gesehen wurde bisher nur die
  Richtungsprüfung (`core-impurity`).

**Folge-Slices:** keine neuen. `welle-07` kann schließen — 044, 045a, 045b, 046 sind done.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): additive Emission
(ein neuer Emitter neben `DocGate`, ein konditionaler Aufruf im bestehenden `wireLang`-Kern)
auf der bereits etablierten Fragment-Assembly. Der `flat`-Pfad bleibt unberührt — kein
Diskrepanz-Risiko. Die einzige Änderung an Bestehendem ist der Verzeichnis-Modus der
emittierten Baseline (0700 → 0755), eine Korrektur ohne Verhaltens-Alternative.
