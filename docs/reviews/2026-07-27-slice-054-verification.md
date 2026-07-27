# Verifier-Report slice-054 — Das cpp-Arch-Gate hat Zähne

Rolle: **Verifier (Modul 11)**, getrennt von Implementation und Review. Prüfgegenstand ist die
**DoD-Behauptung**, nicht die Code-Qualität. Eine DoD-Verletzung ist eine Verifier-only-Klasse.

**Datum:** 2026-07-27. **Slice:** `docs/plan/planning/in-progress/slice-054-cpp-archgate-zaehne.md`.
**Range:** `7aafe35..HEAD` plus Arbeitsbaum-Stand vor der Closure.

**Grenze:** kein frischer Kontext (Modul 8); kompensiert durch Kommandos statt Erinnerung. Alle
drei Sensoren liefen **auf dem Endstand**, nach dem Ergänzen von Mutations-Fall 96.

## Was ich selbst erhoben habe

| DoD-Punkt | Kommando / Beleg | Ergebnis |
|---|---|---|
| (1) Arch-Gate rot gesehen | `make full-smoke`, Block „C++-Arch-Gate-Zaehne" | **rot** — `src/hexagon/domain/example/greeting.hpp:1: core-impurity: Kern importiert src/adapters/outbound/notify/stdout.hpp`; danach zurückgenommen |
| (1) rot aus dem **richtigen** Grund | derselbe Block prüft `core-impurity\|wrong-direction` | Richtungs-Befund vorhanden — kein Compiler-Rot |
| (2) Root-One-Shot | `--lang cpp --arch hexslice` in ein fünftes tmp-Repo | fünf erwartete Artefakte da (`.a-check.yml`, `a-check.mk`, `harness/mk/arch-cpp.mk`, `src/hexagon/domain/example/greeting.hpp`, `src/main.cpp`), `make gates` Exit 0, Arch-Gate-Mount im Lauf |
| (2) Vorab-Gegenprobe isoliert | eigenes Probe-Repo außerhalb des `full-smoke` | `make a-check` Exit 0, `make build` Exit 0 |
| (3) Doku | `grep -rn "nur der Go-Renderer" docs/user/benutzerhandbuch.md README.md` | **0 Treffer**; Handbuch-Version **1.9**, §11-Zeile hält die Reihenfolge fest |
| Gates | `make gates` | **Exit 0** — d-check 208/0, comment-claims 31/0, 0 `not ok` |
| Mutate | `make mutate` | **92 ok, 0 Befunde**; Fall **96** rot gesehen |
| Voll-E2E | `make full-smoke` | **Exit 0** |

## DoD-Stand

**Bestätigt:** alle drei slice-eigenen Punkte, `make gates`, `make mutate`, `make full-smoke`,
Doku-Update. **Offen:** Closure-Notiz (Planner).

**Keine DoD-Verletzung.** Eine Beobachtung zur Reihenfolge, weil der Slice sie ausdrücklich zur
Bedingung gemacht hat: die Doku-Aussage fiel **nach** den beiden Sensoren, nicht mit dem Renderer.
Das ist am Ablauf belegbar — der `full-smoke`-Lauf mit dem Arch-Gate-Zahn lief vor dem
Handbuch-Patch, und die §11-Zeile schreibt diese Reihenfolge fest, statt sie zu behaupten.

## Zu den Review-Findings

F-2 (unbewachte cpp-Kante) war die einzige blockierende Lücke und ist mit Fall 96 geschlossen —
aus Verifier-Sicht der wichtigste Fund des Slice, weil er eine **stille** Regression ermöglicht
hätte: die Kante zu streichen hätte kein Repo-Gate geröret, aber jedes frisch gebootstrappte
C++-Ziel out-of-the-box rot gemacht.

F-1 (Kommentar ohne Sensor) ist bemerkenswert als **Wirkungsnachweis** des Vortags-Gates, nicht
als Mangel dieses Slice.

F-4 (`mutate`-Laufzeit) berührt keinen DoD-Punkt und ist als Folge-Vorgang gesetzt.

## Verdikt

**DoD bestätigt (alle prüfbaren Punkte).** Keine Rückkante zur Implementation. Damit ist auch
das Closure-Kriterium der welle-08 erfüllt: beide Slices abnahmefähig, die drei Sensoren grün,
der verbotene Import **rot gesehen**, und die alte Exit-2-Zusage nachweislich umgeschrieben
statt danebengestellt.
