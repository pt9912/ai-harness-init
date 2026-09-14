**Vorgang:** slice-vorlauf-waechter-geht-ins-ziel
**Fund:** Die zugesagte Ordnung *„der Wächter läuft VOR dem Modul-Lauf"* gilt **beiden**
gebundenen Zielen, der Sensor urteilt sie nur über eines. Der Smoke liest die Kette beider Ziele,
berechnet die Ordnungs-Zeilen (`z_guard`/`z_docker`) aber allein aus der `doc-immutable`-Kette und
prüft für `doc-commits` nur die **Nennung** des Wächters — eine Drift, die `doc-commits` nennt und
nach dem Modul laufen lässt, fällt dort nicht auf. Dieselbe Schlagseite trägt die zweite Hälfte
derselben Zusage: der blinde Grün-Fall („OHNE den Wächter meldet dasselbe Modul grün") ist nur für
`doc-immutable` gefahren. Beide Hälften sind mit diesem Vorgang am emittierten Fragment
**beidseitig gemessen** — die Zusage trägt —, der dauerhafte Zahn bleibt einseitig:

```sh
grep -nE 'z_guard|z_docker' harness/tools/full-smoke.sh
```

Der Ort ist die Kette des Smoke, nicht die Zusage: die Zusage steht im Slice-Plan und im
Sensor-Vertrag und deckt beide Ziele zu Recht.
