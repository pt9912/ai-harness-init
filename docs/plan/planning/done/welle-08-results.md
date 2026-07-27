# welle-08-cpp-hexslice — Results-Notiz

**Welle:** [welle-08-cpp-hexslice](welle-08-cpp-hexslice.md). **Abschluss-Beleg statt Datum:** beide
Slices in `done/`, `make gates` Exit 0 (d-check 208 Dateien / 0 Befunde, `comment-claims` 31 / 0,
0 `not ok`), `make mutate` **92 ok / 0** (die neuen Renderer-, Config- und Kanten-Wächter je rot
gesehen), `make full-smoke` Exit 0 mit dem verbotenen Import **rot gesehen** —
`greeting.hpp:1: core-impurity: Kern importiert src/adapters/outbound/notify/stdout.hpp` —, dieser
Beleg-Text.

---

## 1. Geliefert

Die Architektur-Achse trägt seit dieser Welle eine **zweite Sprache**. `add-lang cpp <pfad> --arch
hexslice` legt ein geschichtetes C++-Modul an, das baut, lintet, testet — und dessen Schichten das
Architektur-Gate **wirklich sieht**.

- **[slice-053](slice-053-cpp-hexslice-renderer.md) — Renderer, Achse und Gate-Config.** `cppRole`
  rendert die fünf hexSlice-Rollen (header-only unter `src/hexagon/**` und `src/adapters/**`),
  `langArchs()["cpp"]` trägt `hexslice`, und die cpp-`.a-check.yml` kommt mit — die drei sind **eine
  Landung**, weil der Wächter aus slice-046 sie koppelt. Belegt sind Build und Lint über dem
  Schichten-Code, je mit rot gesehenem Gegenbeispiel.
- **[slice-054](slice-054-cpp-archgate-zaehne.md) — Zähne und Doku.** Das emittierte Arch-Gate ist
  rot gesehen (mit Richtungs-Befund, nicht nur Exit-Code), der Root-One-Shot `--lang cpp --arch
  hexslice` ist belegt, und **erst danach** sagt die Nutzer-Doku, dass `hexslice` nicht mehr nur der
  Go-Renderer liefert.

## 2. Was funktioniert hat

- **Messen vor dem Schnitt.** Die Vorbedingung „a-check versteht C++" wurde **vor** dem
  Welle-Schnitt gegen das gepinnte Image gemessen, nicht angenommen. Ohne diese Messung wäre die
  Welle auf eine Fähigkeit gebaut worden, die niemand geprüft hatte.
- **Die Reihenfolge Prüfbereich → Gate → Doku.** slice-053 schuf den Prüfbereich, slice-054 die
  Zähne, und erst dann fiel die Doku-Aussage. Jede andere Reihenfolge hätte eine Zusage ohne Sensor
  erzeugt.
- **Additive Erweiterung schützt Bestehendes.** Der Go-Zweig blieb unberührt; das flache C++-Skelett
  weicht um genau drei Zeilen ab, alle von einem Change Request gedeckt.

## 3. Was anders lief als geplant

- **Die Welle-Grenze verschob sich vor dem ersten Code-Edit.**
  `TestArchGateConfig_CoversEveryLayeredCombo` leitet die Kombinationen aus dem realen Generator ab
  und färbt rot, sobald eine schichten-tragende Kombination **ohne** Config existiert. Achse und
  `.a-check.yml` mussten damit in **eine** Landung; slice-054 behielt den Beleg, nicht das Artefakt.
- **Zwei Change Requests wurden nötig** ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)),
  beide aus Messungen: Lastenheft **0.15.0** (§5 trug überholte Herkunfts-Aussagen) und **0.16.0**
  (die AC „Bau-Gerüstung unverändert … `flat` byte-identisch" war für C++ **nicht einlösbar**, weil
  ein Schicht-Layout den Modul-Root im Include-Pfad braucht).
- **Der erste `full-smoke`-Lauf war rot** — und das war sein Wert: das C++-Skelett übersetzte nicht
  (Test-Include-Pfad auf `src/` statt Modul-Root; `ports::…` löste innerhalb der Slice auf den
  slice-lokalen Namensraum auf). Kein Unit-Test hätte das gefangen.
- **Die DoD-Größe wurde korrigiert.** slice-053 startete mit elf Punkten und wurde auf **drei**
  slice-eigene gekürzt, nachdem der Nutzer die Drift gegen Modul 5 §Ziel-Form benannte.

## 4. Steering-Loop

- **Was das Gate sehen kann, bestimmt das Layout — nicht umgekehrt.** a-check löst **nur
  modul-root-relative** Referenzen auf; relative und präfixlose Includes sind ihm unsichtbar. Ein
  anders geschriebenes Layout übersetzt und ist dem Gate **still** unsichtbar. Verankert in
  [`spec/architecture.md`](../../../spec/architecture.md) §5, belegt durch zwei Zähne im
  Voll-E2E-Smoke.
- **Die Kanten-Menge ist sprach-abhängig, das Layout nicht.** Go erfüllt Ports strukturell (keine
  `adapters → ports`-Kante), C++ durch Vererbung (Kante **erforderlich**). Eine solche Abweichung
  sieht in jedem Review wie ein Fehler aus — **nur ein Mutations-Fall** macht aus „das ist Absicht"
  eine Aussage, die fällt, wenn jemand sie aufhebt (Fall 96, rot gesehen).
- **Ein Kommentar trägt keine Zusage.** In slice-053 behauptete ein Doc-Kommentar Lint-Abdeckung,
  die der Header-Filter verhinderte — gemessen blieb der Gate grün. Daraus entstand außerhalb dieser
  Welle das `comment-claims`-Gate; es landete in slice-054 prompt seinen ersten Fremd-Treffer.
- **Ein grüner Build belegt nicht, dass er die Schichten sieht.** Die arch-invariante `CMakeLists`
  übersetzt eine Übersetzungseinheit; eine Schicht-Datei, die keine erreicht, wäre still tot bei
  grünem Gate. Deshalb hängt die Zusage an einem Zahn, nicht an einer Konstruktion.

## 5. Verifikation (Belege aus Schritt 1)

| Beleg | Ergebnis |
|---|---|
| Beide Slices in `done/` | `slice-053-cpp-hexslice-renderer.md`, `slice-054-cpp-archgate-zaehne.md`; `in-progress/` trägt nur die Roadmap |
| `make gates` | Exit 0 — d-check 208/0, `comment-claims` 31/0, 0 `not ok`, `baseline-verify` v3.5.2 OK |
| `make mutate` | **92 ok, 0 Befunde** |
| `make full-smoke` | Exit 0; Arch-Gate-Zahn `core-impurity` rot gesehen, Schicht- und Lint-Zahn ebenso, Root-One-Shot belegt |
| Alte Exit-2-Zusage umgeschrieben | `grep -rn "AddLangCppHexsliceRejected" --include=*.go --include=*.sh .` → **0 Treffer** |
| Carveout-Audit | [`CO-001`](../carveouts/CO-001-bats-shell-lint.md) aktiv, Trigger **nicht** erfüllt (neue `.bats`-Datei: 0 Verzweigungen); Prüfvermerk und die stale Anzahl korrigiert. **Keine weiteren Carveouts, keine neuen aus dieser Welle.** |

## 6. Folge-Slices

- **`make mutate`-Laufzeit** (Nutzer-Beobachtung, entschieden als eigener Slice **nach** dieser
  Closure): 92 Fälle sequenziell, jeder zahlt **beide** Sensoren (bats **und** vollen `go test`-Build),
  obwohl 60 Fälle einen Go-Test und 32 einen anderen erwarten; dazu fehlt dem Go-Build ein
  Kompilat-Cache. Der Umbau kam bewusst nicht vor die Closure — er beträfe genau das Werkzeug, das
  ihre Belege liefert.
- **Weitere Sprach-Renderer** (`python`, `kotlin`, `java`, `csharp`) — je ein eigener Zuschnitt,
  hängen nicht an dieser Welle.
- **Drei ältere Anforderungs-ID-Leaks** im emittierten flachen C++-Skelett (aus slice-039): bewusst
  nicht mitgefixt, weil sie `flat`-Bytes ändern.
- **`test/**` im Prüfbereich des `comment-claims`-Gates** — heute ausgenommen.
