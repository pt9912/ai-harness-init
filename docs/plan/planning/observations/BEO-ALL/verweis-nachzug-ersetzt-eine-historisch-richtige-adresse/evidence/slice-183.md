**Vorgang:** slice-183
**Fund:** Der Closure-Move schrieb die Mess-Operanden **in der Beleg-Datei um, die ihn
dokumentiert**. Der Beleg zu
[`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../../verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
wurde vor dem `git mv` geschrieben und maß mit drei `git grep`-Zeilen über der Präfix-Form
`../in-progress/…` bzw. `docs/plan/planning/in-progress/…`; der Nachzug desselben Move hängte zwei
dieser Operanden auf `../done/…` um und ließ den dritten stehen. Sichtbar im Nachzug-Commit selbst:

```sh
git show bf842e61 -- \
  'docs/plan/planning/observations/BEO-ALL/*/evidence/slice-183.md' | grep -c '^-git grep'   # 2
```

**Der Schaden fällt still aus, und zwar in beide Richtungen.** Die zwei umgehängten Zeilen liefern
nach der Ersetzung wieder dieselben Zahlen (4 und 13) — die Aussage *„gemessen vor dem Move"*
daneben ist trotzdem falsch, denn das Kommando liest jetzt den Baum danach. Die **nicht**
umgehängte dritte Zeile liefert `0` statt der notierten `2`; keine der drei scheitert, keine färbt
ein Gate. Aufgelöst durch eine Form ohne Pfad-Literal: Der Beleg misst seither über den
Commit-Operanden `bf842e61`, den der Nachzug nicht bewegen kann.

**Ein zweites Mal in derselben Datei-Gruppe:** Der Beleg zu
[`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../../lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
zitierte die drei Roadmap-Fundstellen, um zu zeigen, welche Form das Werkzeug **nicht** erreicht —
und genau diese Ausgabe schrieb das Werkzeug an zwei von drei Zeilen um, während die tragende
dritte stehenblieb. Ein Vorgang zählt einmal; beide Funde stehen in diesem einen Beleg.
