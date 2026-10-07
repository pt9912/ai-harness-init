**Stand:** offen

Schwelle erreicht (3×,
`ls docs/plan/planning/observations/BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/evidence/*.md | wc -l`,
gelesen 2026-10-07, keine Erwartung). `offen` steht zwischen dem dritten Beleg und dem Lese-Schritt der
nächsten Welle-Closure, der den Ausgang zuweist (Baseline-Regelwerk `modul-06-roadmap.md` §Das
Beobachtungs-Register). Ein Wächter besteht nicht: Kein Feld des Span-Schemas trägt eine Fassung, und
der Bestand wird nicht nachgezogen. Betroffen sind `program`, `argc` und die zwei Cache-Zähler
(`SPEC-024`). Den Cache-Status liest kein Leser über die Zeit; `harness/tools/hook-overhead.sh` und
`span-report` lesen die betroffenen Felder nicht als Zeitreihe.
