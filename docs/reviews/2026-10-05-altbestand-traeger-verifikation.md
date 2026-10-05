# Verifikation: archive-welle altbestand, schreibender Pfad

Verifier-Lauf gegen die DoD von `slice-archive-welle-altbestand-hat-einen-schreibenden-pfad`, ADR-0041 (Festlegung 2-5), `harness/sensors/archive-welle.md`. Stand: f7583215.

## Verdikte

- **L1 (1)-(3) Lauf: bestätigt.** `make test-go` EXIT 0; `make host-bin` EXIT 0. Mini-Repo (Scratchpad, 3 wellenlose Slices, 2 passende Reports, 1 fremder Report): Vorschau `wellenlos 3`, `Review-Reports 2`; Lauf EXIT 0; `done/altbestand/` trägt 3 Slices plus `archiv.zip`; `unzip -l` = 3 Slices + 2 Reports; Stubs mit `Welle: ohne Welle`, `Archiviert mit: altbestand · Geschlossen: —`, Archiv-Zeiger; fremder Report bleibt; `git show --numstat --format= -M HEAD~1` = dreimal `0 0`; `git status --porcelain` leer; beide Commit-Nachrichten nennen ADR-0041.
- **L2 (4) zweiter Lauf: bestätigt.** Exit 3, `[archiviert]` (+ `[kein-slice]`), Porcelain leer, HEAD unverändert.
- **L2 (5) `haenger`: bestätigt.** Verweis eines fremden Reports auf einen verschwindenden Report: Exit 3, `[haenger]`, HEAD gleich, Slices flach.
- **F1 `altbestand-plan`: bestätigt.** `done/altbestand-plan.md`: Exit 3, `[altbestand-plan]`, HEAD gleich, nichts geschrieben.
- **L3 (6) `[untergrenze]`: bestätigt (Mini-Repo).** Welle-Vorschau vor dem Lauf `[untergrenze]`, nach dem Lauf `Sperren: keine`.
- **L3 Doku: bestätigt (Stichprobe).** Sensor-Doku nennt den Schlüssel; `grep kein-schreib-pfad` in internal/cmd/harness/sensors/test findet nur zwei negierende Test-Stellen in `vorschau_test.go:230/267`.
- **Rot-Belege: bestätigt.** Selbst gefahren `make mutate MUTATE_CASES="504… 506…"`: `2 ok, 0 Befund(e)`; 504 -> `TestArchiveWelleAltbestandSperrtImLaufBeiHaenger rot`, 506 -> `TestArchiveWelleAltbestandSchreibtDieMengeDerVorschau rot`; Baum danach sauber. 505/507/508 nicht gefahren (der Review fuhr alle fünf; Stichprobe).
- **Welle-Pfad unverändert: bestätigt.** Welle-Tests in `make test-go` grün; reale Welle-Vorschau zeigt weiter `[untergrenze]`, wenn nichts archiviert ist; kein `[kein-schreib-pfad]` mehr im Lauf.
- **Mutation 395: bestätigt.** `ls test/mutations | wc -l`: 491 (b64b75b1~1) -> 495; Delta +5 (504-508) -1 (395) stimmt. Die Eigenschaft von 395 (Vorschau nennt die Sperre, an der der Lauf bräche) hat ihren Gegenstand verloren; ihre Kopplung hält 508.
- **Lücken: bestätigt benannt.** Realer Bestandslauf bleibt hinter `haenger` gesperrt (Plan §6, Sensor-Doku); Stub-Tests laufen über nachgebildete Vorlage, die echte Zeile hält `test/archiv-stub-vorlagen.bats`: `make test-bats BATS_TARGET=test/archiv-stub-vorlagen.bats` EXIT 0 (4 ok).
- **`make gates`: EXIT 0** (ohne Pipe).

## Findings

Keine zu Bedeutung, Verhalten oder Zusage. Nebenbefund: der Review-Report-Match hängt an der Slice-Nummer (`slice-<nr>`), ein Slice ohne Nummer in der Kennung sammelt keinen Report ein (Verhalten wie in ADR-0033, nicht Teil dieses Slice).

## Offen für den Planner

- Untracked im Baum, nicht von diesem Lauf: `docs/plan/planning/open/slice-release-schnitt-v027-liefert-den-altbestand-pfad.md`.
- §7-Closure, Risiko-Ausgänge und Register sind noch leer (Planner).
