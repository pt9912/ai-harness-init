**Vorgang:** slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset
**Fund:** [`ADR-0066`](../../../../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
steht auf `Proposed`; ändert sich bei ihrem Accept ein Wortlaut, ziehen Skript-Kopf,
Makefile-Kommentar, README-Zeile und die Fälle nach. Die Bedingung stand nur in §6 des Slice-Plans, der
mit der Closure zur Chronik wird; kein Anweisungssatz der Rolle, die den Accept-Übergang schreibt oder
den Nachzug ausführt, nennt sie. Die Stellen, die sie trifft: `git grep -c 'Exit <N>' --
harness/tools/tap-nachzug.sh Makefile harness/README.md test/tap-nachzug.bats` → 1, 1, 1, 2 (gemessen
2026-09-25, kein Erwartungswert), dazu die Zähne 427, 428 und 432 (`git grep -ln 'tap-<modus>: Exit' --
test/mutations`). Die Closure benennt einen Träger: der Umschnitt des Prozedur-Slice
`slice-tap-nachzug-ist-schritt-der-release-prozedur` durch den Planner nimmt den Stand der Entscheidung
als Prüfpunkt auf
(`docs/reviews/2026-09-25-verify-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`
Ü-1).
