# Die E2E-Stufe misst eine neue emittierte Fähigkeit nicht im Verhalten

**Sub-Area:** `*` (gesamtes Repo)

Eine neu aktivierte emittierte Fähigkeit trägt die Ruder (Erprobung · grüner Start ·
rotes Gegenbeispiel) nur teilweise zur E2E-Ebene: die `planning_im_ziel`-Stufe von
[`full-smoke`](../../../../../../harness/sensors/full-smoke.md) misst den Ruhe-Marker,
aber die Verhaltens-Klassen der Fähigkeit nennt die Abdeckungs-Deklaration
([`e2e-abdeckung.md`](../../../../../../docs/user/e2e-abdeckung.md)) ausdrücklich
„NICHT gemessen". Die Stufe bleibt zurück, bis ein Folge-Slice sie nachzieht; der
Lese-Knoten der Lücke ist die Welle-Closure (`full-smoke`-Pflicht), nicht der
aktivierende Slice.
