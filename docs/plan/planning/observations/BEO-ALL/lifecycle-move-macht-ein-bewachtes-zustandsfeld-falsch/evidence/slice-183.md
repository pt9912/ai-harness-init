**Vorgang:** slice-183
**Fund:** Beide Lifecycle-Moves dieses Slice machen ein Zustandsfeld der Roadmap falsch, und die
zwei Hälften des Abschnitts *Offene Wellen* fallen dabei auseinander.

Der Move `next/` → `in-progress/` stellte den **Ruhe-Marker** gegen den Inhalt von
`docs/plan/planning/in-progress/` — `make docs-check` meldete den Grund-Code `planning-drift`; die
Rückführung nach `next/` hob ihn wieder auf. Der Closure-Move trifft die andere Hälfte: Die Zeile
*„In Arbeit:"* nennt den Slice **präfixlos**, und genau diese Form zieht das Werkzeug nicht nach.
Der Nachzug-Commit `bf842e61` zeigt beides in einer Datei — zwei Zeilen umgehängt, die dritte nicht:

```sh
git grep -o -n '[^ (]*slice-183-ausloeser-der-wellenlosen-archivierung[^) ]*' bf842e61 \
  -- docs/plan/planning/in-progress/roadmap.md
# :23  slice-183-ausloeser-der-wellenlosen-archivierung.md          praefixlos, steht noch
# :155 ../done/slice-183-ausloeser-der-wellenlosen-archivierung.md  nachgezogen
# :156 ../done/slice-183-ausloeser-der-wellenlosen-archivierung.md  nachgezogen
```

Das ist die dritte der drei gemessenen Grenzen von `make slice-mv`
([`harness/README.md`](../../../../../../../harness/README.md): *„eine präfixlose Referenz auf die
bewegte Datei aus einer anderen, unbewegten Datei erkennt es nicht"*) — der Zustandssatz bleibt
nach dem Move stehen und zeigt auf einen Ort, an dem die Datei nicht mehr liegt. Nachgezogen hat
ihn ein eigener Commit dieser Closure, den kein Artefakt vorschreibt: Der bewegende Lauf muss
wissen, dass er ihn braucht.
