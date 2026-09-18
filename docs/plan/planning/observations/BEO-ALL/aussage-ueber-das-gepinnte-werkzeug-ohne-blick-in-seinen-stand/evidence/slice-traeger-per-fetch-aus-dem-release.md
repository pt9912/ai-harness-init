**Vorgang:** slice-traeger-per-fetch-aus-dem-release
**Fund:** Der Plan (Liefer-Punkt 2 und der Closure-Trigger §5) schrieb dem
gefetchten Traeger eine Verhaltens-Aussage zu, die am Quellstand des gepinnten
Bildes nicht hielt: „archive-welle läuft mit dem gefetchten Träger" — der
Träger des gepinnten Standes `v0.1.1` führt das Unterkommando nicht, der Aufruf
startet still den Init-Pfad (gemessen, Abschnitt GRENZE der Stufe
`traeger_fetch_im_ziel` in `harness/tools/full-smoke.sh`). Die Aussage war aus
der Werkzeug-Fassung des Baums abgeschrieben, nicht am Quellstand des gepinnten
Bildes gegengelesen. Gefunden vom Review (F-2, MEDIUM, Runde 1
`docs/reviews/2026-09-18-slice-traeger-per-fetch-aus-dem-release-runde-1.md`);
die Abweichung ist nicht still — der Messbefund trägt am Lieferort (GRENZE),
und die Nachzieh-Adresse ist benannt: der Release-Schnitt
(`slice-release-schnitt-koppelt-pin-und-fassung`, ADR-0058 Festlegung 2 in der
geglätteten Fassung, Folgepflicht 3). Der laut-Bruch gilt erst ab einem Pin,
dessen Stand die Sperren im Dispatch führt.