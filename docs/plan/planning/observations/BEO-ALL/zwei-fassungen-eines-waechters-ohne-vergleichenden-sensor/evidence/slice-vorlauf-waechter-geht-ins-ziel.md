**Vorgang:** slice-vorlauf-waechter-geht-ins-ziel
**Fund:** Erstauftreten. Die Entscheidungslogik des Wächters liegt zweimal im Repo — als
lauffähige Dogfood-Fassung `harness/tools/history-range-guard.sh` (bats-getestet, mit den zwei
`--decide`-Einstiegen) und als Textanker der Emissions-Vorlage
`internal/emit/templates/enforce/history-range-guard.sh` (Go-Textanker und E2E). Kommentar-bereinigt
sind sie bis auf die zwei Einstiege identisch:

```sh
diff <(grep -vE '^\s*#|^\s*$' harness/tools/history-range-guard.sh) \
     <(grep -vE '^\s*#|^\s*$' internal/emit/templates/enforce/history-range-guard.sh)
```

Kein Sensor vergleicht die zwei Fassungen: jede Suite fährt ihre eigene, eine einseitige Änderung
an `decide()` ließe beide grün und die Zusage „die Entscheidung ist dieselbe Funktion" still
falsch werden.
