# Eine Stelle eines Wächter-Satzes hat keinen Mutationsfall, und der E2E-Zahn prüft schwächer als die Probe

**Sub-Area:** `*` (gesamtes Repo)

Ein Wächter-Satz hat Mutations-Fälle für zwei seiner drei Stellen; die dritte (hier der gefetchte
Release-Träger der drei `archiv.zip`-Prüfungen in `harness/tools/full-smoke.sh`) bleibt ohne Fall, und
der E2E-Zahn (`archiv_gueltig`) prüft Lesbarkeit und Eintragsnamen, keine Byte-Gleichheit, während
der Plan-Wortlaut „verfälscht" sagt. Benannt ist beides im Sensor-Doc und im Kopfkommentar, kein
Sensor hält den Plan-Wortlaut gegen den Zahn. Nachbar:
[`neuer-waechter-ohne-mutations-fall`](../neuer-waechter-ohne-mutations-fall/observation.md) — dort
fehlt jeder Fall, hier fehlt einer von dreien.
