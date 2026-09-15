**Vorgang:** slice-226-implementer-anweisungssatz-zieht-nach
**Fund:** Die Register-Paarung (c), zweite Hälfte, über dem Baum nach dem Closure-Move gefahren:
genau ein Verzeichnis führt kein `evidence/`.

```sh
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  [ "$n" -ge 1 ] || echo "$n $d"
done
# 0 docs/plan/planning/observations/BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/
```

**Kein Erwartungswert** — die Zahl wandert mit der Ablage. Der Fund ist
[`BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../../einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md),
und sein `observation.md` nennt den Grund selbst: *„Aufgefallen in einer Koordinations-Sitzung,
nicht in einem abgeschlossenen Vorgang."* Der Eintrag ist damit **benannt, nicht gezählt** und
steht unter der Norm-Frage, die diese Beobachtung registriert. Die Paarung hat ihn gefunden, wie
ihre `state.md` es zusagt; **kein** Verzeichnis wurde angelegt, um ihn zu schließen.
