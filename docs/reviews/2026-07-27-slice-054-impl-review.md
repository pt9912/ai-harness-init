# Review-Report: slice-054 — 2026-07-27

**Review-Art:** Code — geprüft wird der fertige Diff gegen **Plan + Konventionen**
(Modul 10 §Drei Review-Arten). Nicht geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-054 (Das cpp-Arch-Gate hat Zähne — und die Doku sagt es),
Arbeitsbaum-Stand vor der Closure: `harness/tools/full-smoke.sh`,
`docs/user/benutzerhandbuch.md`, `test/mutations/96-cpp-archgate-adapterport-kante.sh`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Grenze dieses Laufs:** kein frischer Kontext (Modul 8) — derselbe Kontext, der den Code
schrieb; jedes Finding trägt daher sein Kommando.

**Eingangs-Kontext:**

- Slice-Plan: `docs/plan/planning/in-progress/slice-054-cpp-archgate-zaehne.md` (§2 DoD drei Punkte, §3 Ist-Messung, §6 Risiken)
- Welle: `docs/plan/planning/welle-08-cpp-hexslice.md` §3 — dieser Slice macht ihr Closure-Kriterium wahr
- Berührte IDs: [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0009`](../plan/adr/0009-hexslice-arch-realisierung.md)
- [`AGENTS.md`](../../AGENTS.md) §3 Hard Rules
- Vorherige Findings: slice-053 F-5 (Root-One-Shot ungetestet — dieser Slice löst ihn ein), welle-07 (Zahn-Form für Go), slice-055 (das `comment-claims`-Gate, das hier sofort zuschlug)

---

## Findings

### F-1 — Ein frischer Kommentar behauptete Abdeckung ohne Sensor

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · das Gate aus slice-055
- `pfad`: `harness/tools/full-smoke.sh` (Kopf des Root-One-Shot-Blocks)
- `befund`: Der neue Block trug „Der Pfad war plausibel korrekt und ungeprueft; hier wird er **belegt**." — eine Abdeckungs-Behauptung ohne Sensor-Nennung, geschrieben kurz nach dem Gate, das genau das verbietet. `make gates` wurde dadurch rot.
- `verifizierbar`: ja — `make comment-claims` meldete `full-smoke.sh:560`.
- **Status:** aufgelöst (umformuliert auf „dieser Block prüft ihn"), Gate wieder grün. **Der Fund ist der erste Fremd-Treffer des neuen Gates** und belegt seinen Nutzen unmittelbar.

### F-2 — Die cpp-eigene Kante war unbewacht

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („wer keinen Fall in `test/mutations/` hat, ist unbewacht")
- `pfad`: `internal/gen/cpp.go` (`cppHexArchConfig`, Kante `adapters → ports`)
- `befund`: Die Kante ist für C++ **erforderlich** (der Outbound-Adapter erbt vom Port und bindet dessen Header ein), sieht aber wie ein Copy-Paste-Überschuss aus, weil die Go-Fassung sie bewusst nicht hat. Gedeckt war sie nur durch `TestArchGateConfig_CppAllowsAdapterToPorts` — **ohne** Mutations-Fall. Ein späterer „Aufräumer" hätte sie streichen können; das Ziel-Repo wäre dann out-of-the-box **nicht grün** ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- `verifizierbar`: ja — `grep -rln "AllowsAdapterToPorts" test/mutations/` war leer.
- **Status:** aufgelöst — Fall **96** ergänzt, rot gesehen (`make mutate` 92 ok / 0).

### F-3 — Der Root-One-Shot kostet einen weiteren vollen C++-Build

- `kategorie`: INFO
- `quelle`: Plan §6 (dort vorab benannt)
- `pfad`: `harness/tools/full-smoke.sh` (fünftes tmp-Repo)
- `befund`: Der Beleg für [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)s One-Shot am Root zieht eine komplette apt-Toolchain und einen vollen CMake-Build nach sich. Das ist der Preis dafür, dass die Aussage belegt statt plausibel ist — die Alternative wäre gewesen, slice-053-F-5 offen zu lassen.
- `verifizierbar`: ja — Laufzeit des `full-smoke` gegenüber dem Vorlauf.

### F-4 — `make mutate` läuft über 15 Minuten

- `kategorie`: INFO
- `quelle`: Maintainability (Nutzer-Beobachtung 2026-07-27)
- `pfad`: `harness/tools/mutate.sh`, `Makefile` (`test`-Target)
- `befund`: 92 Fälle, strikt sequenziell, und **jeder** Fall zahlt beide Sensoren — den bats-Container (113 Tests) **und** den vollen `go test`-Build —, obwohl 60 Fälle einen Go-Test und 32 einen anderen Sensor erwarten. Der Go-Build läuft zudem ohne Kompilat-Cache (`GOCACHE` als `ENV`, kein Cache-Mount). Dieser Slice hat den Zustand nicht verursacht, aber sichtbar gemacht.
- `verifizierbar`: ja — `sed -n 's/^# expect: //p' test/mutations/*.sh` (60/32), `sed -n '/^test:/,+2p' Makefile`, Dockerfile-`test`-Stage.
- **Status:** eigener Slice nach der Welle-Closure (Nutzer-Entscheidung); **nicht** hier, weil der Umbau genau das Werkzeug beträfe, das die Closure-Belege liefert.

## Negativbefunde

- geprüft, ohne Befund: **Plan-Treue** — genau die drei DoD-Punkte; die Reihenfolge „Doku erst nach den Sensoren" ist eingehalten.
- geprüft, ohne Befund: **der Zahn ist rot aus dem richtigen Grund** — `full-smoke` prüft den Befundtext (`core-impurity|wrong-direction`), nicht nur den Exit-Code; real: `greeting.hpp:1: core-impurity: Kern importiert src/adapters/outbound/notify/stdout.hpp`.
- geprüft, ohne Befund: **der eingeschmuggelte Include ist modul-root-relativ** — andernfalls sähe a-check ihn nicht und der Zahn wäre still grün (die slice-053-Messung).
- geprüft, ohne Befund: **Aufräumen nach dem Zahn** — `.orig`-Kopie vor der Mutation, `mv` zurück unmittelbar nach dem Lauf; derselbe Ablauf wie beim Go-Zahn und bei den beiden cpp-Zähnen aus slice-053.
- geprüft, ohne Befund: **Root-Fall isoliert vorab gemessen** — eigenes tmp-Repo, alle fünf erwarteten Artefakte, `make a-check` Exit 0, `make build` Exit 0; im `full-smoke` zusätzlich `make gates` grün plus Arch-Gate-Mount im Lauf.
- geprüft, ohne Befund: **Doku-Aussagen** — „nur der Go-Renderer" ist an beiden Stellen weg (`grep` → 0 in Handbuch und README), Handbuch-Version 1.8 → 1.9, §11-Zeile hält die Reihenfolge fest.
- geprüft, ohne Befund: **`make shell-lint`** Exit 0 inklusive des neuen Mutations-Skripts (SC2016-frei).
- geprüft, ohne Befund: **kein Eingriff in `internal/gen`** — dieser Slice ändert keinen Renderer; wäre der Zahn nicht rot geworden, wäre das laut Plan §4 eine Rückkante in den Renderer-Slice gewesen, kein Doku-Nachzug.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 2 |

## Verdikt

**Merge-blockierend:** nein — **nach Auflösung**. F-2 war blockierend und ist mit Fall 96
aufgelöst (rot gesehen), F-1 ebenfalls. F-3 und F-4 sind benannte Kosten bzw. ein
Folge-Vorgang.

**Beobachtung für den Steering-Loop:** F-1 ist der erste Treffer des `comment-claims`-Gates
auf Code, den es nicht selbst mitgebracht hat — und dieser Code war ein Kommentar, den
derselbe Autor kurz nach dem Gate schrieb. Das ist das stärkste verfügbare Argument dafür,
dass die Regel einen Sensor brauchte und nicht Disziplin.

**Übergabe:** Findings gehen an die Implementation. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
