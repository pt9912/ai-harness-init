# Verifier-Report slice-053 — `cppRole` rendert die hexSlice-Schichten

Rolle: **Verifier (Modul 11)**, getrennt von Implementation und Review. Prüfgegenstand ist **nicht**
die Code-Qualität (Modul 10), sondern die **DoD-Behauptung** und die Plan-vs-Artefakt-Übereinstimmung.
Kanonische Rollen-Definition: `.harness/baseline/v3.5.2/regelwerk/modul-11-verification.md` —
*„Behauptung ohne Bestätigung ist die häufigste Verifier-Lücke"*; eine DoD-Verletzung ist eine
**Verifier-only-Klasse**.

**Datum:** 2026-07-27. **Slice:** `docs/plan/planning/in-progress/slice-053-cpp-hexslice-renderer.md`.

**Range:** `8d3d5cf..c64da88`. Slice-eigen: `e416711` (DoD-Kürzung) → `004d4af` (Move) → `58e890d`
(Link-Reconciliation) → `8d3d5cf` (CR 0.16.0) → `bf7e0ec` (Impl) → `f3de87e` (Review-Auflösung) →
`c64da88` (Review-Report).

**Grenze dieses Laufs — dieselbe wie beim Review:** kein frischer Kontext (Modul 8). Kompensiert,
nicht ersetzt: jede Zeile unten trägt ihr Kommando, und die Sensoren liefen **auf dem Endstand**,
nicht auf einem Zwischenstand.

## Was ich selbst erhoben habe

| DoD-Punkt | Kommando / Beleg | Ergebnis |
|---|---|---|
| (1) Modul wird angelegt | `add-lang cpp mod --arch hexslice` in ein frisch gebootstrapptes Repo | **Exit 0**, 15 Dateien: fünf Rollen unter `src/hexagon/**` + `src/adapters/**`, Composition Root, `tests/`, `.a-check.yml`, Gerüstung |
| (1) Achse + Config gekoppelt | `make test` (`TestArchGateConfig_CoversEveryLayeredCombo`) | grün — die Kombination trägt eine Config, der slice-046-Wächter ist erfüllt |
| (1) Config bildet die Schichten ab | `TestArchGateConfig_CppMatchesSkeleton`, `TestArchGateConfig_CppAllowsAdapterToPorts` | grün; Mutation **93** nimmt die Config weg → rot gesehen |
| (2) Skelett baut real | `make -j gates` im gebootstrappten Ziel (full-smoke) | **Exit 0**; Marker `apps-cpphex:build`, `apps-cpphex:lint`, a-check-Mount `apps/cpphex":/src:ro` alle belegt |
| (2) Build **sieht** die Schichten | Zahn: `static_assert(false, …)` in die Domain-Schicht, `make build-apps-cpphex` | **rot** — `greeting.hpp:32: error: static assertion failed`; danach zurückgenommen |
| (2) Lint **sieht** die Schichten | Zahn: `bugprone-branch-clone` in die Domain-Schicht, `make lint-apps-cpphex` | **rot** — `greeting.hpp:29: error: if with identical then and else branches`; danach zurückgenommen |
| (3) Exit-2-Zusage gewandert | `grep -rn "AddLangCppHexsliceRejected" --include=*.go --include=*.sh .` | **kein Treffer** — die alte Fassung existiert nirgends mehr |
| (3) Neue Grenze bewacht | `TestRun_AddLangUnknownArchRejected`; Mutation **63** (beide Validierungsstufen entfernt) | rot gesehen; full-smoke prüft zusätzlich real (`--arch onion` → rc 2, kein Artefakt) |
| (3) Rollen-Abdeckung bewacht | Mutationen **91** (Rolle entfernt) und **92** (Include-Form verkürzt) | beide rot gesehen |
| Gates | `make gates` | **Exit 0** — d-check 203/0, 0 `not ok` |
| Mutate | `make mutate` | **89 ok, 0 Befunde** |
| Voll-E2E | `make full-smoke` | **Exit 0** |

Alle drei Sensor-Läufe wurden **nach** dem letzten Commit auf dem Endstand gefahren.

## DoD-Stand

**Bestätigt:** (2) vollständig · (3) vollständig · `make gates` grün · `make mutate` ohne Befund ·
kein Doku-Update an Handbuch/README.

**(1) bestätigt mit einer benannten Abweichung — die Verifier-only-Klasse dieses Slice:**
Der DoD-Punkt (1) verlangt als Gegenprobe, `--arch flat` bleibe **byte-identisch**. Das ist
**nicht mehr erfüllt** und **kann** es nicht sein: das flache C++-Skelett unterscheidet sich vom
Stand vor dem Slice um genau drei Zeilen —

```
+target_include_directories(app PRIVATE ${CMAKE_SOURCE_DIR})        # CMakeLists.txt
+target_include_directories(app_test PRIVATE ${CMAKE_SOURCE_DIR})   # tests/CMakeLists.txt (hexslice-Rolle)
-HeaderFilterRegex: '^src/'   +HeaderFilterRegex: '(^|/)src/'       # .clang-tidy
```

Der **Datei-Satz** ist unverändert (`TestGenerate_CppProfile` grün), die Gate-Targets sind
unverändert, und für ein flaches Layout sind beide Zeilen wirkungslos (es hat keine Header unter
`src/`). Genau diese Abweichung deckt **CR 0.16.0**: die AC sagt seit dem 2026-07-27 „funktional
unverändert … im Inhalt weicht es **allein** um dieses Minimum ab" statt „byte-identisch".

**Bewertung:** keine DoD-Verletzung, sondern eine **veraltete DoD-Formulierung**. Der DoD-Text
wurde vor dem CR geschrieben; der Vertrag, gegen den abgenommen wird, ist die Anforderung, nicht
die Slice-Prosa. Die Abweichung ist damit **gedeckt und belegt** — sie gehört aber in die
Closure-Notiz, sonst liest der nächste Leser den DoD-Punkt und findet ihn unerfüllt.

**Offen:** Closure-Notiz mit Steering-Loop-Eintrag (Planner).

## Zu den Review-Findings (Modul-11-Sicht)

F-1 und F-2 sind aufgelöst, und die Auflösung ist **belegt statt behauptet**: der Lint-Zahn
existiert im `full-smoke` und wurde rot gesehen; die beiden Regeln stehen in
[`spec/architecture.md`](../../spec/architecture.md) §5. Bemerkenswert aus Verifier-Sicht: F-1 war
eine **DoD-nahe** Lücke — die Zusage „Code-Gates über dem Schichten-Code" wäre formal grün gewesen
(der lint-Gate lief ja), inhaltlich aber leer. Dass sie der Review und nicht der Verifier fand,
liegt nur daran, dass der Review zuerst lief.

F-4 bis F-6 bleiben offen und sind im Report begründet; keiner berührt einen DoD-Punkt.

## Verdikt

**DoD bestätigt (5 von 6; der sechste ist die Closure-Notiz und Planner-Sache).** Keine
Rückkante zur Implementation. Die eine Abweichung — „byte-identisch" im DoD-Text gegen
„funktional unverändert" in der Anforderung — ist gemessen, gedeckt und gehört in die
Closure-Notiz.
