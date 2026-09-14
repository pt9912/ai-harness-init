**Vorgang:** welle-13

**Fund:** Der Lese-Schritt der Wellen-Closure hat die Register-Paarung (c) gefahren und **einen**
Eintrag gefunden, dessen Verzeichnis kein `evidence/` trägt — er fällt durch beide Leser des
Registers:

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  [ "$n" -ge 1 ] || echo "$n $d"
done
```

**Kein Erwartungswert** — die Zahl wandert mit der Ablage. Der Fund ist
[`BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../../einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md),
und sein `observation.md` nennt den Grund selbst: *„Aufgefallen in einer Koordinations-Sitzung,
nicht in einem abgeschlossenen Vorgang."* Der Eintrag ist damit **benannt, nicht gezählt** und
steht unter der Norm-Frage, die diese Beobachtung registriert — welche der zwei Lesarten trägt.
Die Paarung hat ihn gefunden, wie ihre `state.md` es zusagt: Der Lauf benennt den Fund, statt ihn
als grün zu zählen; **kein** Verzeichnis wurde angelegt, um ihn zu schließen.
