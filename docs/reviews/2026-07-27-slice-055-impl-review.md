# Review-Report: slice-055 — 2026-07-27

**Review-Art:** Code — geprüft wird der fertige Diff gegen **Plan + Konventionen**
(Modul 10 §Drei Review-Arten). Nicht geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-055 (Ein Kommentar nennt seinen Sensor oder behauptet nichts),
Commit `6150f6b` (13 Dateien, +262/−17).

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Grenze dieses Laufs:** kein frischer Kontext (Modul 8) — derselbe Kontext, der den Code
schrieb. Kompensiert, nicht ersetzt: jedes Finding trägt sein Kommando.

**Eingangs-Kontext:**

- Slice-Plan: `docs/plan/planning/in-progress/slice-055-kommentare-nennen-ihren-sensor.md` (§2 DoD drei Punkte, §3 Ist-Messung, §6 Risiken)
- Berührte Verträge: [`AGENTS.md`](../../AGENTS.md) §3.6 (die Regel, die der Slice in den *computational-feedback*-Quadranten trägt), §3.1/§3.2, [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- Auslöser: Nutzer-Anweisung 2026-07-27 („alle Kommentare im Code, falls sie normativ sind, auf beschreibend anpassen")
- Vorherige Findings am gleichen Gegenstand: slice-053 F-1/F-2 (dieselbe Klasse, eine Ebene höher), slice-032 (Wort-Grep als falscher Sensor gegen Prosa), slice-034 (SC2016 in Mutations-Seds)

---

## Findings

### F-1 — Der Sensor-Existenz-Check bestätigte sich selbst

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (ein Wächter, der unter keiner Mutation rot wird)
- `pfad`: `harness/tools/comment-claims.sh` (Prüfung (b))
- `befund`: Die erste Fassung suchte den genannten Testnamen als **Erwähnung** über `*_test.go` **und** `*.bats`. Damit fand sie ihn in `test/comment-claims.bats` — der Fixture, die genau diesen erfundenen Namen als Gegenbeispiel führt. Der Check bestätigte sich selbst und wäre dauerhaft grün geblieben.
- `verifizierbar`: ja — der Scanner lieferte für eine Datei mit erfundenem Testnamen Exit 0 statt 1.
- **Status:** aufgelöst im selben Commit — verlangt wird die **Definition** (`^func <name>(`) in `*_test.go`.

### F-2 — Der Gate war im Container rot, lokal grün

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (das Repo kommt mit bash+git+docker aus — der Gate muss in den gepinnten Images laufen)
- `pfad`: `harness/tools/comment-claims.sh`
- `befund`: `grep --include` ist eine GNU-Option; das bats-Image ist Alpine-basiert (busybox). Der Existenz-Check schlug dort fehl und meldete jeden echten Testnamen als erfunden — `make test` rot, lokaler Lauf grün. Dieselbe Klasse wie der EPIPE-Fall aus slice-039 (umgebungs-abhängiges Rot).
- `verifizierbar`: ja — `make test` zeigte `not ok 14 Behauptung MIT Sensor-Nennung: gruen`.
- **Status:** aufgelöst — `find -print0 | xargs -0 grep`.

### F-3 — Ein bats-Fall hatte keine Zähne

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („ein Test, dessen Name eine Eigenschaft behauptet, muss die Eigenschaft messen")
- `pfad`: `test/comment-claims.bats` (Fall „Roh-String-Literal ist ausgenommen")
- `befund`: Die Fixture setzte die Behauptung auf die `const tmpl = `-Zeile. Diese beginnt nicht mit `#`, wird also nie als Kommentar gelesen — die Roh-String-Ausnahme wurde vom Test **gar nicht ausgeübt**. Der Fall war grün, egal ob die Ausnahme existiert.
- `verifizierbar`: ja — **gefunden von `make mutate`**, nicht vom Autor: Fall 95 entfernte die Ausnahme, `make test` blieb grün → `BEFUND … hat keine Zaehne mehr`.
- **Status:** aufgelöst — die Behauptung steht jetzt auf einer eigenen Zeile im Literal; beide Richtungen nachgemessen, `make mutate` danach 91 ok / 0.

### F-4 — Zwei erfundene Testnamen im Sweep selbst

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `internal/gen/gen.go`, `internal/fetch/baseline.go`
- `befund`: Beim Bereinigen wurden zwei Sensor-Nennungen erfunden; die realen heißen `TestGenerate_Deterministic` und `TestBaseline_KollidierendeEintraegeRefused`. Der Sweep hätte damit zwei neue Falschaussagen erzeugt, während er zehn alte beseitigt.
- `verifizierbar`: ja — genau dieser Fall ist jetzt Prüfung (b) des Gates.
- **Status:** aufgelöst; der Anlass ist der beste Beleg für den Sensor.

### F-5 — Der Gate prüft Form, nicht Bedeutung

- `kategorie`: INFO
- `quelle`: slice-032 (Wort-Grep ist gegen Prosa der falsche Sensor)
- `pfad`: `harness/tools/comment-claims.sh`
- `befund`: Ein Kommentar kann einen **existierenden** Test nennen, der die Behauptung inhaltlich nicht trägt — der Gate besteht. Das ist die bewusste Grenze; sie steht im Skript-Kopf und in §6 des Slice, statt weggelassen zu werden.
- `verifizierbar`: nein — per Konstruktion.

### F-6 — Der Prüfbereich ist eng gezogen

- `kategorie`: INFO
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `Makefile` (`comment-claims`-Target)
- `befund`: Gescannt werden `internal/**`, `cmd/**` (ohne `_test.go`), `harness/tools/*.sh` und `.claude/hooks/*.sh` — **nicht** `test/**`. Ein Testkommentar kann also weiter eine ungedeckte Behauptung tragen. Bewusst: Testdateien beschreiben ihre eigene Zusage, und die Ausweitung hätte den Sweep verdoppelt.
- `verifizierbar`: ja — `make comment-claims` nennt die Dateizahl (30); die Ausweitung gehört in den Backlog.

## Negativbefunde

- geprüft, ohne Befund: **Plan-Treue** — der Diff liefert genau die drei DoD-Punkte; keine Ausnahme-Liste (in §6 als alternde Lösung ausgeschlossen), keine Änderung an emittierten Artefakten.
- geprüft, ohne Befund: **Klasse A wurde nicht pauschal umformuliert** — die 19 Marker-Zeilen blieben stehen, weil sie beschreiben (`emit.go:138` steht über der Prüfung, die es erzwingt; `makefile.go:13` gibt eine make-Vorschrift wieder). Ein Sweep über Modalverben hätte Kontext vernichtet, den das Repo bewusst pflegt.
- geprüft, ohne Befund: **emittierter Inhalt unberührt** — die Roh-String-Ausnahme schützt ihn; der Diff enthält keine Änderung an `internal/gen`-Konstanten, nur an zwei Doc-Kommentaren **über** ihnen.
- geprüft, ohne Befund: **hermetisch** ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md)) — der Gate ruft weder Docker noch Netz; er gehört damit in `gates` und nicht in die Nicht-Gate-Verify-Klasse.
- geprüft, ohne Befund: **`make shell-lint`** Exit 0, inklusive der beiden neuen Mutations-Skripte; SC2016 trat auf (Mutations-`sed` mit Dollar-Verb in Single-Quotes) und wurde vor dem Commit auf einen `.*`-Anker umgestellt — die Lehre aus slice-034 hielt.
- geprüft, ohne Befund: **Gate dokumentiert** ([`AGENTS.md`](../../AGENTS.md) §3.1) — Zeile in `AGENTS.md` §4 und `harness/README.md`.
- geprüft, ohne Befund: **Mutations-Abdeckung** — zwei Fälle (94 Sensor-Erkennung, 95 Roh-String-Ausnahme), beide rot gesehen.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 3 |
| LOW | 1 |
| INFO | 2 |

## Verdikt

**Merge-blockierend:** nein — **nach Auflösung**. F-1 bis F-4 sind im selben Commit
aufgelöst und jeweils rot gesehen; F-5 und F-6 sind benannte Grenzen, keine Mängel.

**Bemerkenswert für den Steering-Loop:** drei der vier blockierenden Findings betrafen
**den Wächter selbst**, nicht den bewachten Code — und einen davon (F-3) fand `make
mutate`, nachdem `make test` grün gemeldet hatte. Ein neu gebauter Sensor ist so lange
eine Behauptung, bis er einmal rot war.

**Übergabe:** Findings gehen an die Implementation. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
