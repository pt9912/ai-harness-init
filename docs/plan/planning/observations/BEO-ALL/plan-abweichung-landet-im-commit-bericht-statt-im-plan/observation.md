# Plan-Abweichung landet im Commit-Bericht statt in §3 des Plans

**Sub-Area:** `*` (gesamtes Repo)

Ein ausführender Lauf nimmt eine Datei mit, die §3 des Slice-Plans nicht führt, und legt die
Abweichung nur in der Commit-Message offen. Der Plan lebt in §3 — als die Quelle, die Review und
Verifikation gegen den Code halten (Baseline-Regelwerk `modul-09-implementierung.md`
§Rücksprungkanten-Regeln); der Bericht danach wird über Läufe hinweg nicht gelesen, und der
Planungs-Lauf, der denselben Plan als Nächstes liest, sieht die Abweichung nicht.