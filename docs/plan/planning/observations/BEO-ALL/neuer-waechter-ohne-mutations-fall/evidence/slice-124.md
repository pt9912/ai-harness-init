**Vorgang:** slice-124
**Fund:** `test/targets-modul-wiring.bats` kam als neuer Wächter mit sieben `@test` hinzu, und
kein Fall in `test/mutations/` nennt die Datei in seiner `# files:`-Zeile
(`grep -l 'targets-modul-wiring' test/mutations/*.sh` → kein Treffer). Zwei der sieben zitieren die
Fälle `301`/`302` in deren `# expect:`-Zeile und fallen damit auf, wenn sie ihre Zähne verlieren;
die übrigen fünf und die zwei Extraktionsfunktionen, über die alle sieben lesen, sind gegen ihre
eigene Rücknahme ungeschützt — beide Fassungen der Extraktion liefern über dem heutigen Baum
dieselben Mengen (11 = 11 und 36 = 36), also fällt kein `@test`.
