# Slice slice-053: `cppRole` rendert die hexSlice-Schichten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-08-cpp-hexslice](../welle-08-cpp-hexslice.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (die Arch-Achse
komponiert `lang × arch`; „weitere Sprachen folgen sprach-agnostisch über je einen Renderer"),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (das emittierte
Skelett baut, kein Gate über Nichts), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(`--arch flat` bleibt **byte-identisch**), [`ADR-0009`](../../adr/0009-hexslice-arch-realisierung.md)
(HexSlice-Realisierung: welche Rollen, welche Richtung).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-27.

---

## 1. Ziel

`add-lang cpp <pfad> --arch hexslice` legt ein **geschichtetes C++-Modul** an, das mit der
emittierten CMake-Verdrahtung **baut** und clang-tidy-clean ist — statt wie heute mit **Exit 2**
abzulehnen.

## 2. Definition of Done

<!-- Drei slice-eigene Punkte + die drei Standard-Zeilen der Vorlage — Modul 5
§Ziel-Form: Slice („≤ 3 DoD-Punkte"). Der erste Entwurf dieses Slice trug elf
Punkte, davon sieben slice-eigene; die Kürzung am 2026-07-27 war eine
Konformitäts-Korrektur, keine Scope-Reduktion: die gestrichenen Punkte waren
Messungen und Belege und stehen jetzt dort, wo sie hingehören (§3 und §6). -->

- [ ] **(1) `add-lang cpp <pfad> --arch hexslice` legt das geschichtete Modul an** — Exit 0 statt
  heute Exit 2. Das umfasst untrennbar: die fünf Rollen in `cppRole`
  (`roleDomain`/`rolePorts`/`roleAppSlice`/`roleAdapters`/`roleCompositionRoot`, dieselben, die
  `archLayout(hexslice)` liefert), die geöffnete Achse (`langArchs()["cpp"]`) **und** die
  cpp-`.a-check.yml` (`archGateConfigs()`). Die drei sind **eine Landung**, weil
  `TestArchGateConfig_CoversEveryLayeredCombo` (aus slice-046) sie koppelt — Beleg in §3, Zeile 5.
  Gegenprobe: `--arch flat` bleibt **byte-identisch**
  ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] **(2) Das Skelett baut real — und der Build sieht die Schichten.** Im gebootstrappten Ziel ist
  `make gates` grün inklusive der cpp-Code-Gates über dem Schichten-Code. Ein grüner Build allein
  belegt das **nicht** (§6, erster Punkt), darum als **Zahn**: ein Fehler in einer Schicht-Datei
  färbt den Modul-Build rot, einmal gesehen und zurückgenommen
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] **(3) Die Exit-2-Zusage ist umgeschrieben, nicht danebengestellt.** Ihre drei Fundstellen
  (§3, Zeile 6) zeigen danach auf eine weiterhin **nicht getragene** Kombination; der Zweig bleibt
  bewacht. Dazu der neue `test/mutations/`-Fall für die Rollen-Abdeckung, rot gesehen. Messbefehl
  im Abschluss, kein Durchsehen (Lehre slice-032).
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] **Kein Doku-Update in diesem Slice** — die Aussage „`hexslice` liefert derzeit nur der
  Go-Renderer" (Handbuch-Kopf, README) fällt erst mit slice-054s Zähnen. Sie hier zu ändern hieße,
  eine Fähigkeit zu bewerben, deren Zusage noch keinen Sensor hat.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Ist-Messung (2026-07-27, live — Kommando neben jeder Aussage):**

| # | Aussage | Kommando / Beleg |
|---|---|---|
| 1 | cpp trägt heute nur `flat` | `grep -n '"cpp"' internal/gen/gen.go` → `"cpp": {archFlat}` (Zeile 132) |
| 2 | `cppRole` kennt zwei Rollen | `grep -n "case role" internal/gen/cpp.go` → `roleEntrypoint`, `roleTest` |
| 3 | Der Go-Renderer ist die Form-Vorlage | `grep -n "case role" internal/gen/golang.go` → fünf Rollen (Zeilen 53-79) |
| 4 | a-check versteht C++ | Fixture gegen das gepinnte Image: verbotener `domain → adapters`-Include → `core-impurity`, Exit 1; legaler Import still (Welle-Trigger, §2 der Welle) |
| 5 | **Achse und Arch-Gate-Config sind gekoppelt** (Plan-Korrektur 2026-07-27) | `sed -n '250,270p' internal/gen/archgate_test.go` → `TestArchGateConfig_CoversEveryLayeredCombo` leitet die Kombinationen aus dem realen Generator ab (`strings.Contains(rel, "hexagon/domain/")`) und meldet „rendert Schichten, hat aber keine Arch-Gate-Config". Öffnet dieser Slice die Achse ohne Config, ist der Wächter rot |
| 6 | Die Exit-2-Zusage hängt an derselben Kante | `grep -rn "cpp.*hexslice" cmd/ai-harness-init/main_test.go harness/tools/full-smoke.sh test/mutations/` → drei Fundstellen (`main_test.go:474`, `full-smoke.sh:308-317`, `test/mutations/63-langarch-support.sh`); sie fallen **mit** dem Öffnen der Achse, also hier — nicht in slice-054 |

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/cpp.go` | update | die fünf Rollen rendern (Header/Quellen je Schicht, Composition Root in `cmd/`) |
| `internal/gen/cpp.go` (Gerüstung) | update | `CMakeLists.txt` muss die Schichten-Quellen erfassen — die Gerüstung ist arch-invariant, ihr **Inhalt** darf es nicht blind sein |
| `internal/gen/gen.go` | update | `langArchs()["cpp"] += archHexslice` |
| `internal/gen/cpp_test.go`, `hexslice_test.go` | update | Rollen-Abdeckung + Byte-Identität des flachen Zweigs |
| `harness/tools/full-smoke.sh` | update | die Exit-2-Assertion wandert auf eine weiterhin nicht getragene Kombination; neuer Positiv-Beleg für cpp+hexslice inkl. grüner Code-Gates |
| `test/mutations/` | neu | Rollen-Abdeckung `cppRole` |
| `internal/gen/arch.go` (`archGateConfigs`) | update | der cpp-Eintrag — **nachgezogen** (Zeile 5 der Ist-Messung); Rollen-Vokabular, `archLayout` und `archLayered` bleiben **unberührt**, wer die anfasst, ändert die Achse statt einen Renderer |
| `internal/gen/archgate_test.go` | update | `TestArchGateConfig_OnlyLayered` führt `{"cpp","hexslice", false}` — die Erwartung dreht sich auf `true` |
| `cmd/ai-harness-init/main_test.go`, `test/mutations/63-langarch-support.sh` | update | die Exit-2-Zusage wandert auf eine weiterhin nicht getragene Kombination |

## 4. Trigger

**`open` → `in-progress`:** die Trigger der [welle-08](../welle-08-cpp-hexslice.md) sind erfüllt
(welle-07 in `done/`, a-check-C++-Fähigkeit gemessen, keine konkurrierende aktive Welle). Dieser Slice
ist der **erste** der Welle und braucht keinen Vorgänger.

Rückführungen:

- `in-progress` → `next`: falls die CMake-Verdrahtung der Schichten sich als eigener Zuschnitt
  erweist (etwa weil das Ziel-Layout mehrere Bibliotheks-Targets statt eines braucht) — dann trennt
  ein Re-Slice „Rollen rendern" von „Build verdrahten", statt beides in einem DoD zu bündeln
  (Präzedenz slice-022 → 022a/022b, slice-034s Option A).
- `in-progress` → `open`: falls sich zeigt, dass das gerenderte C++-Layout mit der heutigen
  arch-invarianten Gerüstung **nicht** baubar ist, ohne die Achse selbst zu ändern
  (`internal/gen/arch.go`) — das wäre eine Architektur-Entscheidung mit eigenem ADR-Bedarf, kein
  Renderer-Slice.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) — **ein Verdikt muss ausgestellt sein**, nicht nur
Findings aufgelöst; Verifikation bestätigt die DoD (Modul 11); `make gates` und `make mutate` grün,
`make full-smoke` grün mit dem neuen cpp+hexslice-Beleg; Slice per `git mv` nach `done/` (eigener
Move-Commit, Link-Reconciliation im Folge-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **OFFENE ENTSCHEIDUNG (Nutzer, 2026-07-27): die Welle-Grenze hat sich verschoben.** Die
  Ist-Messung (§3 Zeilen 5-6) zeigt, dass Achse, Arch-Gate-Config **und** die wandernde
  Exit-2-Zusage **eine** Landung sind. Der Plan oben ist auf **Variante A** korrigiert:
  slice-053 = Renderer + Achse + Config + Unit-Belege; slice-054 = die **end-to-end-Zähne**
  (a-check läuft real im `full-smoke`, verbotener Include rot gesehen), die Mutationen dazu und
  der Doku-Nachzug. Die Welle bleibt damit zweiteilig und ihr gemeinsames Closure-Kriterium
  (§3 der Welle) bleibt bei slice-054.
  **Variante B** wäre, alles in **einen** Slice zu ziehen. Dann entfällt slice-054 — und mit ihm
  die Welle: nach [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  Frage 1/2 wäre `cpp × hexslice` kein Bündel mehr und hätte kein Closure-Kriterium jenseits des
  einen DoD. Das ist keine Formalie: [welle-08](../welle-08-cpp-hexslice.md) und die Roadmap
  wären zurückzunehmen.
- **Ein grüner Build belegt nicht, dass die Schichten übersetzt werden.** Die arch-invariante
  `CMakeLists.txt` erfasst heute nur `src/main.cpp`; eine Schicht-Datei, die keine
  Übersetzungseinheit erreicht, wäre still tot — und das Gate bliebe **grün**. Diese Klasse hat
  slice-024 schon einmal gefangen („still grün über einer Teilmenge"). Deshalb steht der Beleg in
  DoD (2) als Zahn und nicht als Behauptung.
- **C++ hat keine Interface-Erfüllung wie Go.** Der Go-Renderer kommt ohne
  `adapters → ports`-Kante aus, weil Outbound-Adapter die Ports **strukturell** erfüllen. In C++
  erfüllt ein Adapter ein Port-Interface durch **Vererbung** — also mit `#include` des Port-Headers.
  Die Kanten-Menge der cpp-Config wird daher **nicht** die des Go-Moduls sein. Das betrifft
  slice-054, ist aber **hier** zu berücksichtigen: das gerenderte Layout muss die Kante tragen,
  die a-check später erlauben soll. Wer das Layout ohne diesen Gedanken rendert, baut sich in
  slice-054 einen Widerspruch.
- **Die Gerüstung ist arch-invariant, ihr Inhalt nicht.** `CMakeLists.txt` muss die Schichten-Quellen
  erfassen. Fasst sie nur `src/main.cpp`, kompiliert das Layout nie — und `make gates` bliebe **grün**,
  weil nichts Neues gebaut wird. Genau diese Klasse „still grün über einer Teilmenge" hat slice-024
  schon einmal gefangen; der `full-smoke`-Beleg muss deshalb zeigen, dass die Schichten-Quellen
  **im Build vorkommen**, nicht nur, dass `make gates` Exit 0 meldet.
- **Der Exit-2-Zweig darf nicht wächterlos werden.** `cpp × hexslice` fällt als Negativ-Fall weg;
  bleibt keine andere nicht getragene Kombination im Sensor, ist der Zweig ungeprüft (die Klasse
  „entfernte Mutation = entfernte Deckung" aus slice-034-F-1).
- **Kein Carveout absehbar.** Sollte die C++-Toolchain im gepinnten Image eine Schicht-Datei nicht
  übersetzen können, ist das ein Renderer-Fehler, keine Gate-Lockerung.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Alle berührten Sub-Areas GF** (siehe Kurs Modul 5 §Worked Mini-Example): die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt `*` (gesamtes Repo) als
**Greenfield**. Die berührte Sub-Area *Generator* (`internal/gen/`) ist in diesem Repo entstanden,
vollständig bekannt und trägt ihre Konventionen im Code selbst (Rollen-Vokabular, Kopplungs-Tests).
Der Vollblock entfällt damit laut Template.
