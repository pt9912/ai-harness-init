# Slice slice-022b: Embed raus — gefetchte Baseline ist einzige Template-Quelle

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md), [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

Das Embed-Duplikat **abräumen**: `internal/emit` bezieht die Templates aus der von
[slice-022a](slice-022a-baseline-fetch.md) gefetchten Baseline, `internal/emit/skel`
(15 Dateien) wird **gelöscht**, und der Drift-Wächter `test/skel-drift.bats` entfällt
**ersatzlos** — er bewachte genau die Doppelung, die es dann nicht mehr gibt. Damit ist
die Folgepflicht aus [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) („Embed entfernen") eingelöst und es bleibt
**eine** Quelle.

## 2. Definition of Done

- [x] `internal/emit/skel` ist **entfernt** (15 Dateien) und `//go:embed skel` aus `internal/emit/templates.go` verschwunden — **kein** zweiter Template-Pfad bleibt zurück.
- [x] [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) weiterhin erfüllt: die zweiklassige Ablage (Singletons → `.md` mit gestripptem Hinweis-Block und gestempeltem Namen; Wiederkehrende → verbatim `.template.md`; Set-Index-README nie emittiert) entsteht **unverändert**, nur aus der gefetchten Quelle. Kein Verhaltensverlust gegenüber slice-003 — die bestehenden `templates_test.go`-Fälle bleiben gültig.
- [x] `test/skel-drift.bats` ist **gelöscht** und in [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Manier als bewusst entfernt behandelt: die Referenzen darauf sind bereinigt — **kein** `codepath-missing`, aber auch kein stiller Tombstone. *(Korrigiert 2026-07-20: die Erstfassung verlangte zusätzlich eine `codepaths.ignore-refs`-Deklaration. Diese Prämisse war **falsch** — `codepaths.roots` ist `[spec, docs, harness]`, `test/` wird nicht gescannt, ein Eintrag wäre wirkungslos gewesen. Selbst gemessen und vom Verifier mit Positiv-/Negativkontrolle bestätigt. Die Korrektur senkt keine Latte, sie streicht eine unwirksame Forderung; die verbliebene — keine stillen Referenzen — ist erfüllt: `welle-02` ins Perfekt gesetzt, die übrigen Nennungen sind historisch erklärend.)*
- [x] [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): das Binary wird um den eingebetteten Baum kleiner; der Bootstrap braucht weiterhin nur `git + docker`.
- [x] `make gates` grün — insbesondere `make test` **ohne** die drei entfallenen Drift-Tests, ohne dass ein anderer Test ersatzlos Deckung verliert.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | Quelle: `embed.FS` → `fs.FS` über die gefetchte Baseline; `planTemplates` walkt den realen Baum |
| `internal/emit/skel` | entfernt | Embed-Duplikat; Folgepflicht [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) |
| `test/skel-drift.bats` | entfernt | bewachte die Doppelung, die entfällt — ersatzlos, kein Nachfolge-Sensor nötig |
| ~~`.d-check.yml`~~ | **entfällt begründet** | Der Tombstone wäre wirkungslos: `codepaths.roots` ist `[spec, docs, harness]`, `test/` und `internal/` werden gar nicht gescannt — nach dem Löschen gemessen (d-check 0 Befunde) und vom Verifier mit Positiv-/Negativkontrolle bestätigt. Ein `ignore-refs`-Eintrag für etwas, das das Gate nicht prüft, wäre die breite unbelegte Liste, vor der [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) warnt |
| Emit-Tests | update | Fixture-Baum statt Embed; die [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Fälle bleiben inhaltlich unverändert |

**Nachgeführt 2026-07-20 (aus der Review-Runde).** Modul 9 macht diese Tabelle zum
*Protokoll*; drei Artefakte kamen dazu:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/main.go` | update | Signatur-Folge (`fs.FS`-Quelle) + Wurzelung; das Ziel-Layout liegt jetzt in `baselineDir`/`templatesDir` an einer Stelle statt inline |
| `test/courseset-fixture.bats` | neu | Der Wegfall des Drift-Wächters ließ ein **neues** Drift-Paar entstehen (handgebaute Fixture vs. realer Satz) und nahm `make gates` die einzige Berührung mit `.harness/baseline/*/templates`. Der Fall hält beides — und meldet ein neu hinzugekommenes Upstream-Template, das `isRecurring` klassifizieren müsste |
| `internal/emit/templates.go` | update | `checkRoot`: positive Prüfung der Wurzelung. Der Leer-Guard allein deckt sie nicht — eine Vorfahren-Wurzelung ist **nicht** leer und emittierte zu viel |

## 4. Trigger

[slice-022a](slice-022a-baseline-fetch.md) in `done/` — vorher gibt es keine gefetchte
Quelle, aus der `emit` lesen könnte. Bis dahin **blockiert**.

Rückführungen: `in-progress → next`, wenn Umverdrahtung und Test-Umbau getrennt gehören.
`in-progress → open`, wenn sich zeigt, dass die gefetchte Baseline die von
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) verlangte In-Scope-Abgrenzung nicht hergibt (die heutige
Vollständigkeits-Achse von `skel-drift.bats` nimmt `project-readme.template.md` und
`.harness/skills/*` ausdrücklich aus — diese Grenze muss die neue Quelle ebenso ziehen).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Deckungsverlust beim Löschen des Drift-Wächters:** seine *Gleichheits*-Achse wird
  gegenstandslos (keine zwei Quellen mehr), seine *Vollständigkeits*-Achse aber prüfte,
  ob ein bei einem Baseline-Bump **neu** hinzugekommenes Template auch emittiert wird.
  Diese Frage überlebt die Umstellung — sie wandert in die Emit-Tests, statt ersatzlos zu
  verschwinden. Das ist der Punkt, an dem „entfällt ersatzlos" zu billig wäre.
- Der Embed ist heute **gate-relevant**: `make test` fährt drei bats-Fälle darüber. Fallen
  sie, muss der Ersatz benannt sein — sonst sinkt die Prüftiefe unbemerkt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Geist: kein stilles Grün).
- Die `.dockerignore`-Grenze (`.harness` ist im Go-Build-Kontext **nicht** sichtbar, darum
  lief der Drift-Test in bats) gilt weiter: liest `emit` zur Laufzeit aus der gefetchten
  Baseline, ist das unkritisch — ein *Test*, der den Baum braucht, gehört weiter nach bats.

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** `internal/emit/skel` (15 Dateien) und `//go:embed skel` sind entfernt;
`emit.Templates` liest aus einem injizierten `fs.FS`, das `cmd` auf die von
[slice-022a](slice-022a-baseline-fetch.md) gefetchte Baseline wurzelt. Der Kurs ist
damit einzige Quelle für Regelwerk **und** Doc-Templates — die
[`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md)-Folgepflicht ist eingelöst. Unabhängig verifiziert: das Binary ist
**57.344 Bytes** kleiner, und ein Bootstrap mit dem **Vor-Slice**-Binary erzeugt einen
`diff -r`-**identischen** Ziel-Baum — null Verhaltensänderung, empirisch statt argumentiert.

**Der eigentliche Inhalt war die Filterregel, nicht das Löschen.** Der vendored Satz
trägt 21 Dateien, der Embed trug 15; die Differenz war handkuratiert und **nirgends im
Code** — ihre einzige Formulierung stand im Wächter, den derselbe Slice löscht. Sie steht
jetzt als **Regel** in `emit.inScope`, nicht als Allowlist: ein upstream neu
hinzugekommenes Template fließt automatisch mit, die Klasse „Baseline gebumpt, Emit nicht
nachgezogen" kann strukturell nicht mehr entstehen.

**Was anders lief.** Zwei Review- und zwei Verifikations-Runden. Der erste Review fand ein
HIGH (mein „Kern des Slice"-Test war **inert** — er prüfte Quell- statt transformierte
Ziel-Namen und konnte unter keiner Mutation rot werden), das Re-Review ein zweites (der
`len(plan)==0`-Guard war **toter Code**, weil `checkRoot`s Anker selbst in-scope ist — und
der Test dazu sicherte im Rumpf das Gegenteil seines Namens zu). **Beide neuen Blocker
entstanden in der Reparatur**, nicht im ursprünglichen Wurf.

### Steering-Loop-Eintrag — neuer Sensor

Die 022a-Closure trug als Lerneintrag eine **geschärfte Regel** („eine Zusage ist erst
fertig, wenn ihr Gegenbeispiel rot gesehen wurde"). Sie wurde als
[`AGENTS.md`](../../../../AGENTS.md) §3.6 Hard Rule. **Sie hat nicht getragen** — Befund
N-1 ist eine Instanz genau dieser Klasse, entstanden **einen Commit nach** ihrer
Formulierung und von `make gates` (EXIT=0) nicht bemerkt.

Der Grund ist benennbar und steht im Regelwerk: 3.6 lag nur im **Feedforward**-Quadranten.
Modul 9: *„Hard Rule nur in einem Quadranten ist halb durchgesetzt … **Beides ist
Pflicht.**"* 3.1–3.5 hängen je an einem Gate; 3.6 an keinem — und 3.6 ist zugleich die
einzige, die am ruhenden Baum **nicht** prüfbar ist: ein Test mit Zähnen und einer ohne
sehen identisch aus.

**Der Eintrag ist deshalb kein weiterer Regel-Text, sondern ein Sensor:**
[slice-026](slice-026-mutations-sensor.md) (`make mutate`, kuratiertes Mutations-Set +
Schritt-18-Haken). Die Eskalations-Stufe ist selbst die Lehre — *geschärfte Regel* →
*neuer Sensor*, weil die erste Stufe messbar nicht gehalten hat.

**Zweite Beobachtung, kleiner aber gleicher Art:** beim Schließen eines Drift-Paars
(Embed vs. vendored) habe ich ein neues aufgemacht (Fixture vs. vendored). Aufgefangen von
`test/courseset-fixture.bats` — aber die Bewegung „Duplikat beseitigt, Duplikat erzeugt"
ist einen Blick wert, wenn der nächste Slice eine Quelle ersetzt.

### Was diese Closure NICHT behauptet

- **N-3** (der `emit.Templates`-Aufruf in `run()` ist von keinem Gate beobachtet) und
  **N-4** (`checkRoot` hängt an *einem* hart verdrahteten Dateinamen) sind **offen** und
  [slice-026](slice-026-mutations-sensor.md) zugewiesen, weil sie dieselbe Fläche berühren.
- **N-5** (INFO): die Begründung von §3.6 enthält mit *„jede Stelle mit Zähne-Beweis hielt,
  ausnahmslos"* eine unfalsifizierbare Universalaussage — in der Begründung einer
  Falsifizierbarkeits-Regel. Nicht korrigiert; benannt.
- Ein DoD-Punkt trug eine **falsche Prämisse** (`ignore-refs` nötig) und ist sichtbar
  korrigiert statt passend gemacht — s. §2.

### Folge-Slices

- [slice-026](slice-026-mutations-sensor.md) — neu aus diesem Slice: der fehlende Quadrant zu §3.6, plus N-3/N-4.
- [slice-025](slice-025-bootstrap-preflight.md) — unverändert offen; die Kette 025 → 023 → 004b folgt.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
