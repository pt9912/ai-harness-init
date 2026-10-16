# Review: slice-release-schnitt-v080-liefert-die-baseline-v6181

**Range:** Implementer `90001439` (Makefile, `traeger.mk`, `test/traeger-fetch.bats`, Handbuch) plus die Planner-Commits am Slice
(`9abe4903`, die `slice-mv`-Commits `10d22368`/`658b301a` und ihre Nachzüge) · **Plan:** `slice-release-schnitt-v080-liefert-die-baseline-v6181` ·
**Bezug:** LH-QA-02, LH-QA-04, ADR-0058, ADR-0059, ADR-0064 · Prozedur `docs/user/releasing.md` · Reviewer-Skill (Stand HEAD).
Die im Auftrag genannte Range `8c8a6023..9abe4904` löst nicht auf (`git log 8c8a6023^..9abe4904` → unknown revision); gelesen sind die Commits, die `git log` an den Pfaden des Slice nennt.

**Summary:** 0 HIGH · 0 MEDIUM · 0 LOW · 3 INFO — annahmereif für den Tag-Push, vorbehaltlich Verifier und der Freigabe des Auftraggebers.

## Findings

### INFO-1 — Der reale `Makefile`-Digest bleibt ungebunden; das Rot an der realen Quelle fällt aus

- `kategorie`: INFO
- `quelle`: AGENTS.md §3.6 (Fixture gegen reale Quelle, Lücke benennen), ADR-0059 Folgepflicht 2
- `pfad`: `Makefile:45-51`; `test/traeger-fetch.bats:120-130`
- `befund`: `TRAEGER_SHA256_LINUX_AMD64` im realen `Makefile` von `6d89…` auf `0d89…` (weiter 64 Hex) verfälscht: `make test-bats BATS_TARGET=test/traeger-fetch.bats` bleibt grün (2 Läufe, 0 `not ok`); der Fall `pin-kopplung` prüft für die sechs Digests nur Vorhandensein und Länge 64. Die Lücke steht im Slice §2 L1 und §6 und im Kommentar `Makefile:42-44` („im netzlosen Gate unprüfbar, benannt"), sie ist nicht durch Fixture-Grün verdeckt. Den Pin gegen das Asset hält erst `make traeger-fetch` nach der Publikation. Ein einzelner erster Lauf nach der Verfälschung färbte `pin-kopplung` (und `fehlt-fall`) rot, die Wiederholung nicht; Fall 1 kann die Ursache nicht tragen (er liest nur Länge und Vorhandensein), ich führe es auf den frisch geänderten Read-only-Mount zurück und zähle es nicht als Wächter.
- `verifizierbar`: ja (Kommando oben; Rücksetzen per `git checkout Makefile`, Baum sauber)
- `klasse`: Wächter misst die Fixture statt der realen Quelle (bekannt, Register-Eintrag `waechter-misst-die-fixture-statt-der-realen-quelle`)

### INFO-2 — Bestand-Messung des Implementers: reproduziert, mit zwei Randnotizen

- `kategorie`: INFO
- `quelle`: `docs/user/releasing.md` Schritt 5 §Bestand
- `pfad`: Release-Text (liegt außerhalb des Repos); Slice §2 L3
- `befund`: Nachgemessen mit dem Träger `v0.7.0` (aus einem Worktree des Tags gebaut: `make release-artifacts … TRAEGER_VERSION=v0.7.0`, Digest `ec3ef089…` = der alte Makefile-Pin, der Bau ist reproduzierbar) gegen den Träger `v0.8.0` (`dist/`, Digest = neuer Pin) über sechs Optionssätze (`--lang go`, `go`+`hexslice`, `go`+`hexagonal`, `kotlin`, `cpp`, `cpp`+`hexslice`; ohne `.harness/baseline/`): in jedem derselbe Satz an Abweichungen — `AGENTS.md`, `harness/conventions.md`, `.harness/skills/reviewer.md`, `.harness/skills/closure-note-reviewer.md` (zweite Klasse, wie vom Implementer genannt) sowie `harness/mk/traeger.mk` (erste Klasse, der Tag) und `.harness/state/bin/ai-harness-init` (der Träger selbst); `.d-check.yml` und `harness/README.md` gleich. Der Abschnitt **Bestand** ist damit verlangt (`releasing.md`: zweite Klasse ändert sich), und Slice §2 L3 verlangt ihn unter dieser Bedingung. Die Formulierung „mit `v0.7.0` oder früher aufgesetzt" deckt das Gemessene für `v0.7.0`; „oder früher" ist nicht gemessen, folgt aber aus der Lage — die vier Texte tragen den Stand `v6.18.1`, den kein früherer Tag emittiert. Der „älteste Tag, dessen Fassung abweicht", den `releasing.md` verlangt, ist damit eine Grenze, nicht der gemessene älteste Tag. Der Implementer zählt „fünf Dateien"; ich zähle sechs Pfade (die zwei Nicht-zweite-Klasse-Pfade sind der Tag und der Träger); die Zahl der zweiten Klasse (vier) stimmt.
- `verifizierbar`: ja (Aufbau oben; `diff -rq -x .git <alt> <neu>`)
- `klasse`: Messung ohne Erwartungswert, Grenze statt Minimum

### INFO-3 — Der Release-Text steht nicht im Repo; die Vorgaben des Slice decken die Inhalte

- `kategorie`: INFO
- `quelle`: Slice §2 L3, `releasing.md` Schritt 5 und 8
- `pfad`: Slice §2 L3 (Stand, Assets, Grenze, Gegenstände aus §1, Abschnitt Bestand)
- `befund`: Der Entwurf lag mir nicht vor und ist nicht reviewt; Slice §2 L3 und §1 (Gegenstände: `1d79137b`, `26ef8f20`) verlangen alle fünf Bestandteile der Prozedur. Gesetzt wird er erst nach der Publikation (`gh release edit`), er ist damit Teil von Schritt P, nicht dieses Diffs.
- `verifizierbar`: nein
- `klasse`: Artefakt außerhalb des Repos

## Schwerpunkte, Negativbefund

- **(a) Handbuch:** geprüft, ohne Befund. Der Diff ändert nur Zeilen 3, 4, 81 (Stand `v0.8.0`, Datum, „aktuell ausgeliefert"). Zeile 202 (Baseline `v6.18.1`) deckt `fetch.DefaultTag` und `BASELINE_TAG`; die Ausgabe `Bootstrap (Baseline v6.18.1 …)` ist am Träger `v0.8.0` und `v0.7.0` real gelesen (`v6.18.1` bzw. `v6.18.0`). Zeile 729: Ziel mit `v0.6.0` oder früher trägt `DC-FA-TGT-001` (Treffer in `v0.5.0` und `v0.6.0`, 0 in `v0.7.0`) und den Pin `v0.84.0` (`DefaultImage` in `v0.5.0`/`v0.6.0`; `v0.7.0` und HEAD `v0.86.1`); der Satz bleibt wahr am Tag-Baum. Zeile 739: Pin `v0.86.x`, fünf Schlüssel hinter `done-dir`/`reviews-dir` gegen den Kommentar in `internal/emit/templates/d-check.yml` (Z. 35-58 „alle fuenf Schluessel"). Sprachen und Bauformen (Zeilen 328, 459): `cpp`/`kotlin` mit `hexagonal` enden mit Exit 2, `go` mit Exit 0 am Träger `v0.8.0`; alle drei Sprachen emittieren. Keine Chronik, kein „früher stand", §3.7 gewahrt; `README.md` nennt keinen Tag oder Baseline-Pin.
- **(b) Pins:** geprüft, bis auf INFO-1 ohne Befund. `TRAEGER_TAG` steht in `Makefile`, `traeger.mk` und beiden bats-Asserts auf `v0.8.0` (Kopplung, `traeger-fetch.bats` 10/10 grün, zweimal). Die sechs `TRAEGER_SHA256_*` gleich den sechs Zeilen von `dist/SHA256SUMS` (Vergleich je Plattform, identisch), `release-sums.sh verify dist` Exit 0 (sechs OK). Dass `dist/` aus dem Commit gebaut ist, der den Tag trägt, belegt der Verifier unabhängig.
- **(c) Release-Text und Bestand:** siehe INFO-2 und INFO-3.
- **(d) Commit-Zuschnitt:** geprüft, ohne Befund. `90001439` berührt vier Implementer-Artefakte (kein Norm-Artefakt nach §3.8, kein Closure-Artefakt nach §3.10); Lifecycle-Moves über `slice-mv` (reiner Move, Nachzug getrennt, §3.3); Planner-Commit `9abe4903` ändert nur die Roadmap. Messages tragen Rolle und Kennungen.
- **(e) Tag und Push:** geprüft, ohne Befund. Kein Tag am HEAD, jüngster Tag `v0.7.0`; `main` liegt 36 Commits vor `origin/main` (kein Push); der Freigabe-Vermerk in §3 Punkt 4 steht auf „ausstehend".
- **Kommentare (§3.7):** die Kommentarzeilen des Diffs sind unverändert; kein Befund.
- **Gates:** `make gates` am Ende dieses Laufs ohne Fehlerzeile (Ende bei `span-check`); `git status` danach sauber, die Bruchprobe (`Makefile`) ist zurückgesetzt, der Tag-Worktree entfernt.
