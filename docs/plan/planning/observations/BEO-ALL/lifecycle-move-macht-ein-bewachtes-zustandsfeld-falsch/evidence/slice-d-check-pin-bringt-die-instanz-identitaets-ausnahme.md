**Vorgang:** slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme

**Fund:** Die Closure des Vorgangs bewegt seine Plan-Datei per `git mv` nach `done/`; danach trägt
`in-progress/` keinen Slice mehr, und der Ruhe-Marker `Nichts in Arbeit.` fehlt — das
`planning`-Modul des Doku-Gates hält den Marker gegen das Verzeichnis in beide Richtungen
(Baseline-Regelwerk `modul-06-roadmap.md` §Roadmap-Struktur, die Marker-Hälfte ist die deklarierte
Redundanz). Der Marker wird im eigenen Commit nach dem Move gezogen — derselbe Ausgleichs-Schritt,
den der Eintrag als geplant führt
(`slice-ortswechsel-zieht-sein-zustandsfeld-nach`, Kennung in der `state.md`); der Schritt selbst
trägt weiter kein Werkzeug und kein Anweisungssatz.

Zählerstand nach diesem Beleg: 22
(`ls docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/evidence/ | wc -l` → 22).