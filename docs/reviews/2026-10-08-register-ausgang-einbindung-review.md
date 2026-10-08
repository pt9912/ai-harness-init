# Review: `register-ausgang` hängt an `record-gates` — Einbindung in `make gates`

**Rolle:** Reviewer (Modul 10), Skill `.harness/skills/reviewer.md` 2.3.0. **Datum:** 2026-10-08.
**Review-Art:** Code — gegen Plan und ADR, nicht gegen die DoD.
**Gegenstand:** Commit `a5495478` gegen den Slice-Plan
`slice-register-ueber-der-schwelle-bekommt-seinen-waechter` (§3, Umsetzungsstand).
**Bezug:** [ADR-0085](../plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md)
(`Accepted`), [ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md),
[ADR-0069](../plan/adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md),
[`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
[`AGENTS.md`](../../AGENTS.md) §3.1/§3.6/§3.7. Frühere Runde: `2026-10-08-register-ausgang-review`.

Bruchproben liefen in einer Kopie (`git archive HEAD`) unter dem Scratchpad. Der Baum blieb unberührt.
`make gates` wurde laut Auftrag nicht gefahren.

## Findings

Keine.

## Geprüft, ohne Befund

- **Einbindung, fail-closed:** `register-ausgang` steht als Voraussetzung an `record-gates`
  (`Makefile:656`), und `gates` hängt an `record-gates`. Das Skript endet mit Exit 1 bei Befund und
  mit Exit 2 bei fehlender Wurzel oder leerem `BEO-*/*/`. Beide Codes sind ungleich null, deshalb
  baut make `record-gates.sh` nicht, und es entsteht kein Stempel. Realer Lauf
  `bash harness/tools/register-ausgang.sh`: 233 Einträge, 66 über der Schwelle, 0 Befunde, rc=0.
  Damit ist die Bedingung „bereinigter Bestand“ aus ADR-0085 erfüllt, und der Satz im Plan
  „keinen Befund“ stimmt.
- **README §Sensors-Zeile:** Die Zusage (≥ 3 `evidence/*.md`, eine eindeutige Stand-Zeile,
  einer der drei Ausgänge, Exit 2 bei leerem Prüfbereich) deckt sich mit den Zweigen des Skripts:
  Zählung `[ -f ]` über `*.md`, `grep -c` > 1 ergibt Befund, Fall-Liste der drei Wörter, Exit 2.
  Sie behauptet nicht, dass der Ausgang trägt. Diese Grenze steht im Skriptkopf. Die Zeile ist aus
  §Werkzeuge entfernt und nicht doppelt geführt. Die Bindungs-Zelle fällt in die Klasse ADR der
  Zusatzklassen-Deklaration.
- **`exempt-targets` und Kommentarzahl:** `register-ausgang` ist aus der Liste und aus der
  Aufzählung von Gruppe (a) gestrichen. Die Gruppe nennt jetzt 24 Ziele. Gemessen tragen 20 davon
  „NICHT in gates“ im `## `-Hilfetext (Schleife über die 24 Namen gegen `Makefile`/`*.mk`). Das
  stimmt mit „20 von 24“ überein, die übrigen vier sind die namentlich genannten.
- **`test/gate-nachweis-kante.bats` und Fall 213:** Die Erwartungsliste ist unter `LC_ALL=C sort`
  richtig einsortiert. Der Kopf von Fall 213 nennt „Zehn Checks“. Das ist richtig, denn die Kante
  hat 11 Voraussetzungen und die Kürzung behält eine.
- **Mutations-Fall 582 (MR-071, Bindung):** In der Kopie trifft `sed` genau die `record-gates`-Zeile,
  und das Ziel `register-ausgang:` bleibt stehen. Mit `BATS_TARGET=test/gate-nachweis-kante.bats`
  wird nur `not ok 4 … genau die erwarteten Checks` rot, aus dem richtigen Grund: in `ist` fehlt
  `register-ausgang`. Die Fälle 1, 2, 3 und 5 bleiben `ok`, wie der Kopf es zusagt. Für die
  Gegenprobe wurde `skip` ausschließlich in diesen Test gesetzt, die Mutation blieb angewandt, und
  die volle Suite lief mit `test/` (498 Fälle). Danach bleibt nur
  `not ok 225 driver: die Kopie traegt den Sensor-Bedarf inklusive .git` rot. Dieser Test braucht
  `.git`, das in der `git archive`-Kopie fehlt, und hängt nicht an der Mutation. Der benannte Test
  bindet die Kante also allein, und die Aussage „allein“ im Fallkopf stimmt.
- **§3.7 in geänderten Kommentaren:** Der Makefile-Kommentar (`:270–274`), der Skriptkopf (ohne
  „Proposed“), `.d-check.yml` und die Fallköpfe 213/582 beschreiben den Zustand, ihre Kopplung oder
  ihre Zusage. Sie beschreiben keine verworfene Alternative und keinen abwesenden Text. In nicht
  archivierten Artefakten steht kein Rest „NICHT in gates“ oder „Proposed“ mehr zu
  `register-ausgang` (`git grep register-ausgang` außerhalb von `docs/reviews` und `done/`).

## Summary

0 HIGH · 0 MEDIUM · 0 LOW · 0 INFO.
**Finding-Klassen dieses Laufs:** keine.

## Verdikt

**Merge-blockierend:** nein.
