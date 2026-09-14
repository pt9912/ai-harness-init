**Vorgang:** slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke

**Fund:** Die achtzehn Registereinträge über der 3×-Schwelle, die auf `offen` stehen, sind
**benannte Lücken in einer lebenden Ablage**: dreizehn von ihnen tragen in `state.md` die Aussage,
dass kein Wächter die Klasse fängt, und keinen der drei Ausgänge — weil *„Träger ist der Lauf, der X
schreibt"* keinen **Zielort** nennt und damit in keine der drei Zeilen paßt.

```sh
cd docs/plan/planning/observations/BEO-ALL
n=0; tl=0; gap=0; kenn=0
for d in */; do
  c=$(ls "$d"evidence 2>/dev/null | wc -l)
  [ "$c" -ge 3 ] || continue
  grep -q '^\*\*Stand:\*\* offen' "$d/state.md" || continue
  n=$((n+1))
  grep -qE 'Träger ist der Lauf' "$d/state.md" && tl=$((tl+1))
  grep -qE 'Wächter besteht nicht|kein Sensor|kein Modul|Kein Modul|Träger ist' "$d/state.md" && gap=$((gap+1))
  grep -qE 'slice-[0-9]|slice-[a-z]' "$d/state.md" && kenn=$((kenn+1))
done
printf '%s offen, %s woertlich "Traeger ist der Lauf", %s mit Luecken-Aussage, %s mit Slice-Kennung\n' "$n" "$tl" "$gap" "$kenn"
# 18 offen, 5 woertlich "Traeger ist der Lauf", 14 mit Luecken-Aussage, 3 mit Slice-Kennung
```

Die **Register-Hälfte** dieser Klasse hat der Slice entschieden: `verkörpert` trägt eine benannte
Lücke, sobald Regel **und** Aussage über die fehlende Bewachung an **einem Norm-Artefakt** stehen;
ein Lauf ist kein Zielort und gehört in den Abschnitt *Grenze der Verkörperung, benannt*
([`ADR-0049`](../../../../../../../docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md)
Festlegung 1). Die **Prosa-Hälfte** — wohin eine erledigte Grenz-Beschreibung in einem lebenden
Artefakt wieder verschwindet — bleibt unberührt und steht unverändert in dieser Beobachtung.

Träger war der Lauf, der die Regel schreibt; ein Sensor besteht für die Klasse weiterhin nicht.
