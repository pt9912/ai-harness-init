**Vorgang:** slice-225
**Fund:** Der Closure-Move von `slice-224` nach `done/` machte eine **Stand-Zelle** in
[`harness/conventions.md`](../../../../../../../harness/conventions.md) §Baseline falsch, und
nichts zog sie nach: Zwei Zeilen meldeten weiter *ausstehend*, was in `done/` lag.

```sh
grep -n 'Delta-Nachweis in slice-224' harness/conventions.md
# 30:  **auf `v6.5.0`:** 2026-09-07, Delta-Nachweis in slice-224;
# 31:  **auf `v6.7.2`:** 2026-09-12, Delta-Nachweis in slice-224.
```

Der Befund kam aus dem Review dieses Slice, nicht aus einem Wächter — das Feld ist keines der
Zustandsfelder, die das Modul `planning` hält, und
[`make slice-mv`](../../../../../../../harness/sensors/slice-mv.md) zieht nach eigener Zusage
*Pfade nach, keine Zustandssätze* (Grenze 1 im Skriptkopf).

Die Zelle ist dieselbe Klasse wie der Ruhe-Marker der Roadmap und die Zeiger-Liste, nur ohne
Sensor: Ein Move in einem Baum macht ein Feld in einem anderen falsch, und welcher Schritt es
nachzieht, schreibt kein Artefakt vor, das der bewegende Lauf liest. Hier kam erschwerend hinzu,
dass der bewegende Lauf und der schreibende Lauf **verschiedene Slices** waren: `slice-224`
bewegte, `slice-225` fand — der Abstand zwischen Ursache und Befund ist eine Closure.
