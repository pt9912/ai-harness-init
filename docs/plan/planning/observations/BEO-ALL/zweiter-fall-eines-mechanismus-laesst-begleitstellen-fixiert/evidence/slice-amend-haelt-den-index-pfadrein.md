**Vorgang:** slice-amend-haelt-den-index-pfadrein

**Fund:** Der Review (`docs/reviews/2026-09-28-slice-amend-haelt-den-index-pfadrein.md`) fand die
Klasse dreifach innerhalb desselben Diffs, gezählt als **eine** Gelegenheit
(Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register: „Zwei Funde im selben Vorgang
sind eine Gelegenheit, kein zweites Auftreten"):

- **F-1** (MEDIUM): `make hooks-install` prüfte/setzte das Ausführ-Bit nur für `.githooks/commit-msg`,
  nicht für den neu hinzugekommenen `.githooks/pre-commit`.
- **F-2** (MEDIUM): Die Werkzeuge-Tabelle in `harness/README.md`, der Makefile-Zielkommentar und die
  Laufzeit-`printf`-Meldung beschrieben `make hooks-install` weiterhin nur als Aktivierung des
  ursprünglichen `commit-msg`-Trägers.
- **F-4** (LOW): Der Kommentar zur Einzel-Nennung ohne `.sh`-Endung im `shell-lint`-Rezept wurde nicht
  erweitert, als `.githooks/pre-commit` aus demselben Grund einzeln dazukam.

Alle drei **im selben Slice behoben** (Commit `c08ad58e`) — die Beobachtung bleibt trotzdem stehen:
Der Zähler misst Wiederholung über Vorgänge hinweg, nicht ob ein Fund im eigenen Vorgang schon
korrigiert wurde.
