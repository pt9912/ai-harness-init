**Vorgang:** slice-123
**Fund:** Der Implementer-Lauf an diesem Slice las **123 von 151** Lese-Zugriffen (81 %) auf
Hintergrund-Ausgabedateien; die Arbeit am Slice steht mit **27** Schreib-Zugriffen daneben.
Zwanzig Aufrufe desselben Stroms wurden an der Zeit-Vorgabe des Bash-Werkzeugs
abgeschnitten. Das Werkzeug, das für genau diesen Zweck da ist — `BashOutput` —, kommt im
**gesamten** verbliebenen Bestand **null** Mal vor: Der Lauf hat nicht das falsche Mittel
gewählt, sondern gar keines.

**Messung, nicht Erwartungswert** — der Bestand ist gitignored, maschinenlokal und seit dem
2026-09-08 auf drei Tage beschnitten; auf einem anderen Checkout gibt es ihn nicht
([`spec/spezifikation.md`](../../../../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
§5). Stand 2026-09-08, aus `.harness/state/spans/`:

```sh
for f in *-a*.jsonl; do
  R=$(grep -c '"tool":"Read"' "$f"); [ "$R" -lt 10 ] && continue
  P=$(grep '"tool":"Read"' "$f" | grep -c '/tasks/[a-z0-9]*\.output'); [ "$P" -lt 10 ] && continue
  echo "$R $P $((P*100/R))% $(date -r "$f" '+%m-%d %H:%M')"
done                                                    # 151 123 81% 09-06 11:32
grep -h -oE '"tool":"BashOutput"' *.jsonl | wc -l       # 0, ueber 104 Stroeme
```

**Die Zuordnung zu diesem Slice ist gemessen, nicht aus Pfad-Indizien geschlossen.** Das
Feld `commit` des Stroms führt `5319f79f` — den `slice-mv`-Commit dieses Slice nach
`in-progress/` — und `bdc96e8d`, seinen ersten Implementer-Commit; die geschriebenen Pfade
des Stroms sind die Lieferung dieses Slice, bis hin zu den zwei `implement-slice.md`-Dateien,
die §7 unter (b) als im Diff stehend benennt.
