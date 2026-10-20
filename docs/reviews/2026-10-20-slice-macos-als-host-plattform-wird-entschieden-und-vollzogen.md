# Review — slice-macos-als-host-plattform-wird-entschieden-und-vollzogen

* Rolle: Reviewer (frischer Kontext), Datum 2026-10-20
* Diff: `2634a855..fca3dbf3` (harness/README.md, harness/sensors/{mutate,full-smoke,artifact-host}.md, Slice-Plan §3)
* Geprüft gegen: Slice-Plan, `AGENTS.md` §3.9 (Absatz „Host der Host-Läufer ist Linux"), §3.1/3.6/3.7, `LH-QA-03`, `LH-QA-04`, `MR-025`, Zusatzklassen-Deklaration in `harness/conventions.md`.

## Summary

0 HIGH · 0 MEDIUM · 1 LOW · 3 INFO. Die Texte zeigen auf die Norm, nennen dieselben vier Läufer, Linux-Host, CI-auf-frischem-Klon und die Umwege als Hilfen ohne Anspruch; `LH-QA-04` wird nirgends berührt.

## Findings

1. **LOW** · quelle: `AGENTS.md` §3.9 / Maintainability · pfad: `harness/sensors/artifact-host.md:5` · befund: Die unveränderte Beschreibungszeile nennt als Zweck „einen lokal lauffähigen Smoke auf einem Host … (macOS, Windows, …)" und steht direkt über dem neuen Absatz „Hilfe ohne Anspruch, ein Lauf ist kein Beleg"; der Absatz hebt die Zweckangabe für macOS nur sinngemäß auf (Zweck = lauffähig, nicht = Beleg). Für einen Leser, der nur Zeile 5 liest, bleibt macOS als vorgesehener Einsatz stehen. · verifizierbar: nein · klasse: „Bestandszeile neben neuer Norm-Aussage nicht mitgezogen".
2. **INFO** · quelle: `AGENTS.md` §3.6 · pfad: `harness/sensors/mutate.md:115-160` · befund: Die Überschrift „Lokaler Weg für `# verify: full-smoke`-Fälle auf macOS" und die gemessenen Zahlen („653 greifen, 0 Befund(e)", `mutate: 1 ok`) bleiben stehen; der neue Vorspann stellt sie als Umweg ohne Beleg-Wirkung ein. Gelesen als Hilfe-ohne-Anspruch ist das konsistent (Messung der Hilfe, nicht Beleg für den Läufer); die Zahlen stehen nicht neben ihrem Kommando in jedem Fall (MR-025), das ist Bestand und nicht Gegenstand des Diffs. Ebenso Bestand: `mutate.md:275-278` („Auf macOS … greifen alle") widerspricht der Norm nicht, nennt `AGENTS.md` §3.9 aber nur als Host-Bedarf, nicht den neuen Absatz. · verifizierbar: nein · klasse: „Messung einer Hilfe liest sich als Beleg".
3. **INFO** · quelle: `AGENTS.md` §3.9 (Auflösungs-Trigger) · pfad: `harness/README.md:58,74,75,77,80,81`, `mutate.md:115`, `full-smoke.md:13`, `artifact-host.md:9` · befund: Die Aussage steht in neun Stellen mit eigener Kurzfassung („Host Linux, macOS nicht getragen"); die Norm verlangt beim Trigger die Entfernung ihres Absatzes, nennt die Doku-Stellen aber nicht. Auffindbar sind sie nur über `git grep -n '§3.9'` bzw. diese Dateiliste; die Norm benennt selbst „Träger ist die Doku der Läufer, die auf diese Norm zeigt". Keine zweite Fassung der Aussage im Wortlaut, nur Zeiger plus Kurzform. · verifizierbar: nein · klasse: „Kurzform an mehreren Orten ohne Rückbau-Liste".
4. **INFO** · quelle: `AGENTS.md` §3.6 (Prozess) · pfad: Commit-Messages `91fa75f0`, `3d1df74d`, `fca3dbf3` · befund: Die Messages sagen nicht, dass `make gates`/`docs-check`/`mutate-auswahl` des Implementers auf macOS (mit GNU-`sed` vorn im `PATH`) liefen und nach der neuen Norm kein Beleg sind; den Handoff-Text des Implementers sah dieser Lauf nicht. Beleg-Ort laut Norm ist CI auf frischem Klon. · verifizierbar: nein · klasse: „Lauf auf Nicht-Linux-Host ohne Beleg-Vorbehalt".

## Geprüft, ohne Befund

* **Norm-Treue (Schwerpunkt 1):** vier Targets (`mutate`, `mutate-auswahl`, `mutate-greift`, `full-smoke`), Linux-Host, CI auf frischem Klon, Umwege (GNU-`sed`, `artifact-host`, `full-smoke-host`) als Hilfen ohne Anspruch stimmen mit `AGENTS.md` §3.9 überein; die Dateien zeigen auf §3.9, statt den Absatz abzuschreiben.
* **Produkt-Binary vs. Dogfood-Läufer (2):** `LH-QA-03`/`LH-QA-04` werden in `mutate.md`, `full-smoke.md`, `artifact-host.md` ausdrücklich als unberührt genannt; kein Satz schwächt die Matrix (linux · macos · windows) ab; `docs/user/benutzerhandbuch.md` (Z. 55–116, 161, 903) nennt macOS nur für das Programm, `docs/user/releasing.md` und `README.md` führen keine macOS-Läufe der Läufer als Beleg (`git grep` leer).
* **README-Form:** Spaltenform, Marke `kein Gate` bei allen Werkzeug-Zeilen, `make mutate-greift` bleibt Gate-Zeile mit Bindung `MR-071` plus Zusatz; `make docs-check` → `d-check: 2933 Datei(en) geprüft, 0 Befund(e)`; Zusatzklassen-Kommando aus `harness/conventions.md`, letzte Zeile → `0` (keine Zelle außerhalb der Klassen).
* **Kein Wächter (4):** `full-smoke.md` („Ein Wächter für diese Deklaration existiert nicht") und `mutate.md` („kein Test weist den Lauf auf einem Nicht-Linux-Host ab") benennen die Lücke am Ort; `AGENTS.md` §3.9 stützt das (`git grep uname` nennt nur Träger-Fetch/`span-check`-Meldung, keine Abweisung). Kein Fixture-Erfolg verdeckt sie.
* **Slice-Plan §3:** Dateiliste deckt die Änderungen; `docs/user/*` unverändert begründet und durch `git grep` bestätigt.
* **Formfehler (5):** `artifact-host.md` trägt vor dem neuen Absatz überzählige Leerzeilen; rein kosmetisch, kein Finding.
* **Mutation/Gegenbeispiel:** nicht anwendbar (Deklaration, keine ausführbare Zusage); als Grenze am Ort benannt.
