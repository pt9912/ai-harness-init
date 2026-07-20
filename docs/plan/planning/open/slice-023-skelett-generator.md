# Slice slice-023: Go-Skelett-Generator (deterministisch)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-02-fetch-und-readme](../welle-02-fetch-und-readme.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md), [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

Das Tool **generiert** das Go-Sprachskelett — `Dockerfile`, `Makefile`, `go.mod`,
`.golangci.yml` — **deterministisch aus tool-eigenem Sprach-Wissen** statt es zu fetchen
([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nach dem CR, [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) Herkunftsklasse „Tool-als-Quelle").
Ein Layout-Profil, nachvollziehbar wie `d-check --print-mk` — **nicht aus dem Nichts**.

## 2. Definition of Done

- [ ] [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Generator-Teil) erfüllt: `--lang go` erzeugt das Skelett aus dem Layout-Profil, Test referenziert. *(Der Anker trägt historisch „Picker" — die Anforderung ist auf den Generator umgestellt, siehe Lastenheft §7 v0.7.0.)*
- [ ] [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): zwei Läufe mit gleicher Eingabe → **byte-identische** Ausgabe (kein Zeitstempel, keine Map-Iterations-Reihenfolge im Output).
- [ ] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): das generierte `Makefile` behauptet **nur lauffähige** Targets — jedes emittierte Target läuft im frischen Zielrepo.
- [ ] [`ADR-0003`](../../../../docs/plan/adr/0003-go-native-binaries.md) gewahrt: das generierte Skelett ist **Docker-only** (Stages im `Dockerfile`), keine Host-Toolchain-Annahme.
- [ ] Der Generator bleibt **sprach-agnostisch** strukturiert (ein Profil je Sprache); `go` ist das erste, die übrigen fünf aus [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) folgen ohne Umbau der Mechanik.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen` | neu | Generator-Mechanik + Go-Layout-Profil (Tool-als-Quelle) |
| `cmd/ai-harness-init` | update | `--lang go` verdrahtet den Generator statt des früheren Fetch-Pfads |
| Generator-Tests | neu | Determinismus (zwei Läufe byte-identisch), Target-Lauffähigkeit, Docker-only |

## 4. Trigger

slice-022 in `done/` (der alte Skelett-Fetch-Pfad ist dann abgeräumt und die
Template-Quelle steht). Vorher **blockiert** — sonst konkurrieren Generator und
Fetch um dieselbe Ausgabe.

Rückführungen: `in-progress → next`, wenn sich Generator-Mechanik und Go-Profil nicht in
einer Review-Sitzung prüfen lassen (dann trennen: Mechanik zuerst, Profil als Folge-Slice).
`in-progress → open`, wenn das Layout-Profil eine Architektur-Entscheidung erzwingt, die
[`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) nicht deckt (z. B. hexagonale Schichten als Pflicht-Layout — dann ADR
vor Code, Modul 4).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Determinismus ist das Kernrisiko** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): Go-Map-Iteration ist absichtlich
  ungeordnet, und ein Zeitstempel im generierten Header bräche die Byte-Gleichheit still.
  Der Test muss zwei volle Läufe vergleichen, nicht nur „Datei existiert".
- **Sprach-Generator-Wissen ist Wartungslast** — [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) §Konsequenzen nennt das
  ausdrücklich als Preis der Entscheidung. Das Profil muss klein und ablesbar bleiben,
  sonst wird jede Sprache ein eigener Wartungszweig.
- **Verdrahtung ist explizit nicht hier:** der `d-check.mk`-Include und der Init-Flow
  gehören zu slice-004b. Dieser Slice erzeugt das Skelett, er verdrahtet es nicht.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example).
