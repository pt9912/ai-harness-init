**Vorgang:** slice-commit-traeger-wird-skip-if-present
**Fund:** Ein Umbau, der **ein** Symbol und **einen** Aufzählungs-Typ bewegt, entwaffnete vier
gelistete Fälle auf zwei Wegen — beide lautlos im Push-Pfad. `157` und `164` greifen nicht mehr (der
Anker zitiert die ersetzte Quell-Form: das positions-gebundene `enforceFile`-Literal bzw. den
`writeSkipIfPresent`-Aufruf); `50` und `354` wirken noch, ihr erwarteter Wächter fällt aber **nicht
aus seinem Grund** — beide erzeugen einen Übersetzungsabbruch statt einer `--- FAIL:`-Zeile
(`break is not in a loop, switch, or select`, weil der `return nil`-Zweig aus dem `switch` in ein
`if` wanderte; `too few values in struct literal`, weil `354` ein positions-gebundenes Element in das
jetzt keyed-Literal einfügt). Gefunden hat das die Review-Runde, nicht ein Gate: `make mutate` läuft
nächtlich und nicht am Push.

Die tragende Bezugsmenge ist die **Form des Ankers**, nicht die berührte Datei: gemessen über alle
347 Fälle (Anker-Probe, Zielliste vor/nach) und über die 32 Fälle mit Ziel in einer der 19
Diff-Dateien (Go-Stufe). Nachgezogen in `65b78423`, jeder Fall mit seinem `# expect:`-Wächter.

**Die zweite Hälfte desselben Eintrags ist mit diesem Vorgang erneut eingetreten:** die zwei
reparierten **Textanker** (`157`, `164`) greifen an der heutigen Quell-Form, je **einmal** —

```sh
grep -c '{src: "templates/enforce/span-emit.sh",' internal/emit/enforce.go   # 1
grep -c 'class: SkipIfPresent,' internal/emit/agents.go                      # 1
```

— und ein vorgelagerter Durchgang über die `sed`-Anker besteht weiterhin nicht. Fällt die Form weg,
meldet der Treiber *„Mutation hat nicht gegriffen … Patch veraltet?"*: **laut, aber erst nächtlich**
und im Push-Pfad ungewächtert.
