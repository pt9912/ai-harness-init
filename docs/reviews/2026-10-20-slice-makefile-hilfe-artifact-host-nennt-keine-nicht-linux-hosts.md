# Review slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts

Rolle: Reviewer. Diff: `git diff 45b5b4de..a0944093` (ein Commit, nur `Makefile`, 13+/14-). Plan: `docs/plan/planning/in-progress/slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts.md`. Normen: AGENTS.md §3.6, §3.7, §3.9, MR-025, LH-QA-03, LH-QA-04.

## Summary

0 HIGH, 0 MEDIUM, 0 LOW, 2 INFO.

## Findings

- kategorie: INFO · quelle: AGENTS.md §3.6 · pfad: Makefile:154-158 · befund: Der Kommentar über `artifact` wiederholt mit "der Host der Host-Laeufer ist Linux" einen Halbsatz der Norm in §3.9, neben dem Zeiger; die Abschrift driftet nur, wenn §3.9 sich ändert, dann ist der Zeiger maßgeblich. · verifizierbar: nein · klasse: Norm-Halbsatz neben Zeiger.
- kategorie: INFO · quelle: AGENTS.md §3.6 · pfad: Makefile:~162, ~219-221 · befund: "kein Sensor haelt diesen Text" steht bei `artifact-host` und `smoke-host`, nicht bei `full-smoke-host` (dort nur die Hilfezeile geändert); die Zusage ist für alle drei gleich wahr (siehe unten), der Kommentar nennt sie zweimal. · verifizierbar: nein · klasse: Zusage-Grenze nicht an jedem Ziel genannt.

## Mutations-CI-Probe (Schwerpunkt 5)

- `make mutate-auswahl SLICE=slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts` (gelesen: `harness/tools/mutate-auswahl.sh`, `urteil()`, `SCHWELLE=8`, `basis_commit()` = Claim-Commit-Add von `in-progress/<kennung>.md`) meldet **21** Fälle über `8bcb9c29..HEAD`, Exit 10 (make: Error 10). Mit "nur zwei Fällen" stimmt das nicht: 81 und 98 sind zwei der 21. Grund für Exit 10: n=21 > 8. Auswahl nach Datei (`# files: Makefile`), nicht nach Zeile — jeder Fall, der `Makefile` nennt, zählt.
- Anker 81 (`release-artifacts:`-Abschnitt, `@test -n .*ist Pflicht`) und 98 (`test-go:`, ` -count=1 `) liegen in Rezepten, die der Diff nicht berührt. Fälle 254/256/259 (host-bin, `archive-welle`) ebenso. Der Diff berührt nur Kommentar- und `## `-Zeilen von `artifact`, `artifact-host`, `smoke-host`, `full-smoke-host`.
- `make mutate-greift` (Anker-Probe aller Fälle gegen den neuen Stand): `762 Fall/Faelle, 762 greifen, 0 Befund(e)`. Die Mutations-CI-Probe selbst (Wächter rot?) ist nicht gefahren: kein Branch, Freigabe liegt beim Auftraggeber.

## Geprüft, ohne Befund

- Schwerpunkt 1, Diff nur Text: Zeile für Zeile gelesen; geändert sind ausschließlich `#`-Kommentarzeilen und die `## `-Teile von drei Zielzeilen. Kein Rezept, kein Zielname, keine Variable, kein `.PHONY`. Keine Tab-Zeile (Rezept) in den +/- Zeilen (`grep -nP '^[+-]\t'` leer). `make -n` für `artifact`, `artifact-host`, `smoke`, `smoke-host`, `full-smoke`, `full-smoke-host`, `host-bin` (DEST=/x) gegen `git show 45b5b4de:Makefile`: byte-gleich (`cmp`). `make help` vorher/nachher: nur die drei Hilfezeilen unterscheiden sich.
- Schwerpunkt 2, Wortlaut: Indikativ, keine Chronik, kein Plattformname als Einsatz (`git grep -nE 'Nicht-Linux|Devhost|macOS|Windows' -- Makefile` zeigt nur noch den Bestand bei host-bin). "Bauen und fahren fuer die Plattform des Hosts" trägt: `artifact-host` reicht `TARGET_OS=$(HOST_OS) TARGET_ARCH=$(HOST_ARCH)` an `docker build`, `smoke-host`/`full-smoke-host` setzen `SMOKE_ARTIFACT_TARGET=artifact-host`. "Auf einem Linux-Host faellt das zusammen" bleibt Bestand und trägt für gleiche Architektur. "Kein Sensor haelt diesen Text": `git grep -nE 'Nicht-Linux|Devhost|Hilfe ohne Anspruch|für lokale Smokes' -- test harness .d-check.yml` findet nur Prosa in `harness/README.md`, `harness/sensors/*.md`, keinen Test; wahr.
- Schwerpunkt 3, Hilfe/README: Hilfezeilen ("Hilfe ohne Anspruch, AGENTS.md §3.9") und README-Zeilen (artifact-host, full-smoke-host: "kein Gate · Hilfe ohne Anspruch … §3.9"; `harness/sensors/artifact-host.md` Z. 7) widersprechen sich nicht. Die README-Zeile von `smoke-host` trägt keine Marke (Vorgänger-Slice, nicht Gegenstand dieses Diffs).
- Schwerpunkt 4: `host-bin`-Kommentar (macOS-Host) unverändert, kein Diff dort.
- AGENTS.md §3.9: Zeiger statt Abschrift der Norm, Norm nicht angefasst. LH-QA-03/04: Produkt-Binary, Rezepte unberührt.

## Ehrlichkeit zur Plattform

Alle Läufe auf macOS (Host-GNU-make `make -n`, `make help`, `make mutate-auswahl`, `make mutate-greift`; gnu-sed im PATH). Nach AGENTS.md §3.9 sind sie kein Beleg; die Aussagen oben hängen an Text- und Rezept-Gleichheit (`make -n`, `git diff`), nicht an einem Lauf der Läufer. Beleg-Ort für `make gates` und Mutations-Probe ist CI.
