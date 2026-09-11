**Vorgang:** slice-104
**Fund:** Fünf Fälle in **einem** Vorgang, darum ein Beleg. Die Umbenennung von
`roleFromAgentType` zu `RoleFromAgentType` und der Umbau von `limitAgentGuard` entwaffneten sie auf
**zwei** Wegen: vier ankerten auf dem alten Symbol und mutierten nichts mehr (No-Op,
Treiber-Bedingung 2), einer **fügte** Code mit dem alten Symbol ein — dort greift der Patch, aber
der mutierte Baum übersetzt nicht, und der erwartete Test fällt aus einem anderen Grund
(Bedingung 4, *falscher Grund*). Die tragende Bezugsmenge ist damit das umbenannte **Symbol**, nicht
die berührte Datei: `grep -l -E 'roleFromAgentType|canonicalRoles|limitAgentGuard'
test/mutations/*.sh` nennt über dem Baum vor der Arbeit genau diese fünf, während eine Sichtung
entlang der `# files:`-Zeilen der berührten Dateien den einfügenden Fall verfehlt — seine Zeile
nennt eine Datei, die der Vorgang nie anfasst.
