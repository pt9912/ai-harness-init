**Vorgang:** slice-073
**Fund:** Erstauftreten. Der `matrix`-Block der Emissions-Vorlage trägt nach diesem Slice an vier
Positionen eine Form, die dieses Repo im eigenen Gate nicht fährt: die zwei Lifecycle-Klassen im
`token:`-Modus, die zwei Regeln `{from: adr, to: …}`, die Richtungs-Prüfung innerhalb der
Spec-Straten und den engeren Wert von `exclude-sections`. Sichtbar wird die Differenz mit zwei
Kommandos:

```sh
grep -n 'exclude-sections' internal/emit/templates/d-check.yml
sed -n '194p' .d-check.yml
```

Erprobt ist die Form über **beiden** Bäumen — grün ohne Verletzung, rot mit Verletzung, grün ohne
die Regel —, was fehlt, ist die Dauerhaftigkeit im eigenen Gate. **Die vier laufen unterschiedlich
ein:** Drei holt `slice-072` ein; bei der vierten ist offen, **ob** sie je eingeholt wird, weil ein
frisches Ziel keine CR-Historie hat, die auf ADRs zeigt, und dieses Repo sie führt — dort kann die
Abweichung die richtige Dauerform sein. Entschieden wird das in `slice-208`.
