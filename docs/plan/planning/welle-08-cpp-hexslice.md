# Welle welle-08: `cpp × hexslice` — die Arch-Achse trägt eine zweite Sprache

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug — M4 (Arch-Gate integriert) ist mit
[welle-07](done/welle-07-arch-achse.md) erreicht; diese Welle **verbreitert** die dort gebaute Achse
auf eine zweite Sprache, sie erreicht keinen neuen extern beobachtbaren Zustand.

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-27.

---

## 1. Welle-Ziel

`add-lang cpp <pfad> --arch hexslice` liefert ein **geschichtetes C++-Modul** — und das Arch-Gate
prüft es real. Heute endet derselbe Aufruf mit **Exit 2** (`internal/gen/gen.go:132`:
`"cpp": {archFlat}`); die Achse aus [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)
trägt bislang **eine** Sprache, obwohl sie als `lang × arch`-Komposition entworfen ist.

Die Welle ist erst geliefert, wenn beides zusammen wahr ist: das Skelett **baut** (die
C++-Toolchain-Gates bleiben grün) **und** ein verbotener `domain → adapters`-Include **färbt
a-check rot**. Ein Layout ohne Gate wäre ein Verzeichnisbaum ohne Zusage; ein Gate ohne Layout
wäre ein leerer Prüfbereich ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 2. Trigger (Welle startet)

- **[welle-07](done/welle-07-arch-achse.md) liegt in `done/`** — die Arch-Achse (Rollen-Vokabular,
  `--arch`-CLI, konditionale Gate-Emission) ist gebaut; diese Welle fügt einen Renderer hinzu,
  keine Mechanik. welle-07 hat cpp ausdrücklich ausgeklammert („cpp/andere folgen je Bedarf
  (linear, opt-in) — nicht in dieser Welle", §6).
- **a-check versteht C++ — gemessen, nicht angenommen (2026-07-27).** Gegen das gepinnte Image
  (`ghcr.io/pt9912/a-check@sha256:6425c93a…`) lief eine Fixture mit
  `languages: cpp: ["**/*.cpp", "**/*.hpp"]`: der verbotene `domain → adapters`-Include meldete
  `src/domain/bad.cpp:1: core-impurity`, Exit **1**; der legale `adapter → domain`-Include blieb
  still. Damit ist die Vorbedingung dieselbe Klasse wie die a-check-Verfügbarkeit, die
  [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) für Go verlangte
  — **belegt statt avisiert**.
- **Green-before-extend:** keine aktive Welle, `in-progress/` trägt keinen Slice, `make gates` grün.

## 3. Closure-Trigger (Welle schließt)

- Beide Slices (slice-053, slice-054) liegen in `done/`.
- `make gates` grün, `make mutate` ohne Befund.
- **Der Welle-eigene Beleg, den kein Einzel-DoD abschreibt:** `make full-smoke` fährt
  `add-lang cpp <pfad> --arch hexslice` gegen ein reales Ziel, dort ist `make gates` grün **inklusive**
  des cpp-Arch-Gates, **und** der verbotene Import wird **rot gesehen** und zurückgenommen (dieselbe
  Zahn-Form, die welle-07 für Go etabliert hat).
- **Die alte Zusage ist umgeschrieben, nicht danebengestellt:** der heutige Exit-2-Beleg für
  `cpp --arch hexslice` (`harness/tools/full-smoke.sh`, Test, Mutation) existiert **nicht mehr** als
  toter Wächter — gemessen per Suche, nicht per Durchsehen (die Lehre aus slice-032: eine wandernde
  Grenze wird umgeschrieben; ein danebengestellter Rest ist ein Selbstwiderspruch).
- Closure-Notiz `done/welle-08-results.md` mit Steering-Loop-Einträgen.

## 4. Slices in dieser Welle

<!-- Zustand jedes Slice = sein Lifecycle-Verzeichnis (open/next/in-progress/
done), hier NICHT gespiegelt — eine Status-Spalte driftete gegen die
Verzeichnisse (dieselbe zweite Wahrheit, die beim Slice retired wurde). -->

| Slice | Titel | Bezug |
|---|---|---|
| [slice-053](open/slice-053-cpp-hexslice-renderer.md) | `cppRole` rendert die hexSlice-Schichten; die Achse öffnet sich für cpp | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| slice-054 | Arch-Gate-Config für cpp + Zähne + Doku-Nachzug | [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) |

**Nur slice-053 ist geschnitten** (`open/`). slice-054 bekommt seine Datei per `cp` aus der Vorlage,
wenn er an der Reihe ist — ein leerer Slice-Platzhalter wäre eine zweite Wahrheit, die driftet
(cp-Disziplin, dieselbe Regel wie in welle-05 für die Slices 035–038).

**Warum in dieser Reihenfolge:** slice-053 schafft den **Prüfbereich**, den slice-054s Gate braucht.
Umgekehrt hätte slice-054 ein Gate über einem leeren Baum — genau die Konstellation, die
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) verbietet und
die welle-07 mit der konditionalen Emission (`archLayered`) schon einmal aufgelöst hat.

## 5. Abhängigkeiten

- **Wird blockiert von:** [welle-07](done/welle-07-arch-achse.md) (geschlossen) — Rollen-Vokabular,
  `--arch`-Achse und die konditionale Arch-Gate-Emission stammen von dort.
- **Blockiert:** nichts. Weitere Sprach-Renderer (`python`, `kotlin`, `java`, `csharp`) hängen
  **nicht** an dieser Welle; sie brauchen je einen eigenen Renderer, nicht diese Kombination.
- **Wer diese Welle ändert, bricht:** die `archGateConfigs`-Kopplung
  (`TestArchGateConfig_CoversEveryLayeredCombo` fängt eine schichten-tragende Kombination ohne
  Config) und den Exit-2-Zweig für nicht getragene `lang × arch`-Kombinationen.

## 6. Out-of-Scope für diese Welle

- **Weitere Sprachen** (`python`, `kotlin`, `java`, `csharp` aus
  [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) — je ein eigener
  Renderer, je ein eigener Zuschnitt.
- **Weitere Architekturen** über `flat`/`hexslice` hinaus — „kein spekulatives Layout" gilt
  unverändert.
- **a-check-Regeln jenseits der vier Schichten + Composition Root** (`tech`, `adapter_sink`,
  `forbidden_constructs`): die cpp-Config bildet ab, was das Skelett trägt — nicht, was a-check
  könnte.
- **Der `publish`-Sensor** und die übrigen Roadmap-Kandidaten: eigene Achse, eigener Trigger.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-08-results.md. -->
