# Review-Report: slice-057 — 2026-07-27

**Review-Art:** Code — geprüft wird der fertige Diff gegen **Plan + Konventionen**
(Modul 10 §Drei Review-Arten). Nicht geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-057 (Go-Kompilat-Cache teilen, Test-Ergebnisse nicht), Arbeitsbaum vor
der Closure: `Dockerfile`, `test/dockerfile-teststufe.bats`,
`test/mutations/98-teststufe-count.sh`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Grenze dieses Laufs:** kein frischer Kontext (Modul 8); jedes Finding trägt sein Kommando.

**Eingangs-Kontext:**

- Slice-Plan: `docs/plan/planning/in-progress/slice-057-go-kompilat-cache.md` (§2 DoD drei Punkte, §3 Ist-Messung, §4 Rückführungen, §6 Risiken)
- Berührte Verträge: [`AGENTS.md`](../../AGENTS.md) §3.6 und §3.1, [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only)
- Vorgänger: slice-056 (Hebel A, 19m01s → 10m54s)

---

## Findings

### F-1 — Das geplante Vehikel wurde ersetzt, der Plan-Text nicht

- `kategorie`: MEDIUM
- `quelle`: Plan §1/§2 („Cache-Mount **plus** `-count=1`")
- `pfad`: `docs/plan/planning/in-progress/slice-057-go-kompilat-cache.md`, `Dockerfile`
- `befund`: Geliefert wird **nicht** der geplante `--mount=type=cache`, sondern eine **Vorwärm-Stufe** (`FROM deps AS warm` mit vorübersetzter Standardbibliothek, `FROM warm AS test`). Das **Ziel** ist identisch (Übersetzung teilen, Ergebnisse nicht), das Mittel ein anderes — auf Nutzer-Vorschlag, nachdem die Messreihe das geplante Mittel ausgeschlossen hatte. Titel, §1 und §3 nennen weiterhin den Mount; ohne Korrektur liest ein späterer Leser einen Plan, der so nicht ausgeführt wurde.
- `verifizierbar`: ja — `grep -n "mount=type=cache" Dockerfile` → kein Treffer; `grep -n "AS warm" Dockerfile` → Treffer.
- **Status:** in der Closure-Notiz aufzulösen (Plan-Text nachziehen, Messreihe als Befund festhalten).

### F-2 — Eine bauartbedingt sichere Zusage hängt jetzt an einem Flag

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `Dockerfile` (`test`-Stufe)
- `befund`: Vor diesem Slice startete jeder Build mit **kaltem** Kompilat-Cache — „die Tests sind wirklich gelaufen" war ohne Zutun wahr. Mit der Vorwärm-Stufe ist der Cache warm, und ohne `-count=1` übersprünge das Test-Werkzeug unveränderte Pakete mit `(cached)`. Der Lauf bliebe **schnell und grün** und meldete gecachte Ergebnisse als bestandene Tests — eine Regression, die wie ein Erfolg aussieht.
- `verifizierbar`: ja — Mutation **98** entfernt `-count=1` und färbt den zugehörigen bats-Fall rot (im Lauf belegt: `94 ok, 0 Befunde`).
- **Status:** aufgelöst — zwei bats-Fälle + Mutations-Fall; der Umbau hat seinen Wächter **im selben Zug** bekommen, nicht später.

### F-3 — Die Ursache des Mount-Verhaltens bleibt offen

- `kategorie`: INFO
- `quelle`: Messreihe dieses Slice
- `pfad`: —
- `befund`: Der Cache-Mount ist in dieser Umgebung **aktiv** (eigenes Dateisystem im Build: Geräte-Nummer `66308` gegen `133`; ein Eintrag in `/proc/mounts`), der Lauf schreibt **2060** Einträge an den Mount-Pfad — und der nächste Build startet bei **0**. Vier Erklärungen wurden gemessen und **alle vier widerlegt**: generelle Nicht-Persistenz (busybox-Probe 3→4→5→6), `--no-cache-filter` als Ursache (dieselbe Probe mit Flag: 5→6), wechselnde Cache-ID (explizites `id=`: weiterhin 0), inaktiver Mount (s. o.). Die Ursache liegt unterhalb dieser Ebenen.
- `verifizierbar`: ja — die vier Proben sind reproduzierbar.
- **Status:** als Befund festzuhalten, damit ein späterer Anlauf sie nicht wiederholt. **Kein** offener Punkt für dieses Repo: die Vorwärm-Stufe liefert das Ziel ohne den Mount.

### F-4 — Nur die `test`-Stufe wurde gewärmt

- `kategorie`: INFO
- `quelle`: Plan §4 (Rückführung: „falls der Cache-Mount weitere Stufen betrifft")
- `pfad`: `Dockerfile` (`lint`, `build`)
- `befund`: `lint` und `build` erben weiterhin direkt von `deps` und übersetzen die Standardbibliothek je Lauf neu. Für `make gates` ist das ein realer, ungenutzter Rest; für den Mutations-Sensor irrelevant (er fährt nur `test-go`/`test-bats`). Bewusst nicht mitgenommen — der Plan sieht dafür einen eigenen Zuschnitt vor.
- `verifizierbar`: ja — `grep -n "^FROM deps AS" Dockerfile`.

## Negativbefunde

- geprüft, ohne Befund: **kein `(cached)` im Testlauf** — über drei Läufe gezählt, jeweils 0; die Tests laufen trotz warmem Cache wirklich.
- geprüft, ohne Befund: **Wirkung gemessen, nicht behauptet** — `make test-go` 7,2 s → **3,1 s** (stabil über zwei Folgeläufe; erster Lauf 9,8 s inklusive Vorwärmen); `make mutate` **10m54s → 7m18s**.
- geprüft, ohne Befund: **Aussage des Mutations-Laufs unverändert** — `94 ok, 0 Befunde`; der einzige neue Fall ist 98, alle übrigen färben denselben Wächter wie zuvor.
- geprüft, ohne Befund: **`--no-cache-filter test` bleibt** — es erzwingt die Neuausführung der Schicht, `-count=1` die der Tests; beide Ebenen sind im `Dockerfile` unterschieden und je bewacht.
- geprüft, ohne Befund: **Determinismus** ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) — die Vorwärm-Stufe übersetzt nur die Standardbibliothek; sie ändert kein Ausgabe-Byte, nur die Dauer. Das Modul hat keine externen Abhängigkeiten (`go.mod` ohne `require`, keine `go.sum`).
- geprüft, ohne Befund: **Docker-only** ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md)) — die Änderung ist eine zusätzliche Dockerfile-Stufe; kein Host-Werkzeug, kein neues Volumen-Konzept.
- geprüft, ohne Befund: **`make shell-lint`** Exit 0 inklusive des neuen Mutations-Skripts.
- geprüft, ohne Befund: **`make gates`** Exit 0 mit den beiden neuen bats-Fällen.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 0 |
| INFO | 2 |

## Verdikt

**Merge-blockierend:** nein — F-2 ist im selben Zug aufgelöst (Wächter existieren und greifen),
F-1 wird in der Closure-Notiz aufgelöst (Plan-Text an das gelieferte Vehikel ziehen). F-3 und F-4
sind Befunde bzw. bewusste Abgrenzungen.

**Der bemerkenswerte Teil ist der Weg:** das geplante Vehikel wurde durch **Messung** ausgeschlossen
— vier Hypothesen, vier Widerlegungen —, und der Slice stand vor der Rückführung nach `open`. Der
Wechsel auf eine Vorwärm-Stufe kam als **Nutzer-Vorschlag**. Ohne die vorherige Messreihe wäre er
nicht belegbar gewesen; ohne den Vorschlag wäre der belegte Gewinn liegengeblieben.

**Übergabe:** Findings gehen an die Implementation. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
