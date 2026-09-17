# Geplanter Slice wird nie gearbeitet

**Sub-Area:** `*` (gesamtes Repo)

Ein Slice-Plan liegt in `open/` oder `next/`, bis ein späterer Schnitt seinen Gegenstand
übernimmt — gearbeitet hat ihn niemand. Geschnitten wurde je Befund, bevor eine Implementation
den Schnitt geprüft hat; Baseline-Regelwerk `modul-05-planning-harness.md` §Regeln gegen typische
Fehlannahmen nennt das Muster *tote Slices*.

## Benannt, nicht gezählt

Fünf weitere Geber derselben Gruppierung tragen denselben Fund und bewegen den Zähler **nicht**:
`slice-091-vendored-baum-ohne-anspruch`, `slice-092-traeger-inventur`,
`slice-103-traeger-waechter-decken-was-sie-sagen`,
`slice-108-feldlisten-waechter-tragen-ihren-fall`,
`slice-110-erfassungs-waechter-fall-meldung-grenze`. Sie sind Funde **derselben** Gelegenheit —
der Gruppierung, die den Vorrat einzeln geschnittener Go-Slices zu wenigen Gruppen-Slices
zusammenfasst —, und der Zähler misst Wiederholung über Vorgänge hinweg, nicht die Zahl der Funde
(`modul-06-roadmap.md` §Das Beobachtungs-Register).
