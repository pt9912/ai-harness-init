#!/usr/bin/env bash
# files: internal/emit/fieldlist.go
# expect: TestFeldliste_Konvergent
# verify: test-go
#
# DIE FELDLISTE WIRD SKIP-IF-PRESENT STATT KONVERGENT ABGELEGT.
#
# Danach bleibt eine einmal geschriebene Fassung fuer immer stehen: die erste
# Schema-Aenderung laesst das Ziel eine Erfassung beschreiben, die es nicht mehr gibt —
# und der Satz IM DOKUMENT („Ein erneuter Lauf des Werkzeugs schreibt diese Datei
# kanonisch neu.") waere eine Zusage, die der Code nicht haelt.
#
# WARUM DIESE FEHLHANDLUNG UND KEINE ANDERE: skip-if-present ist im selben Paket der
# Nachbar-Schreiber und die Klasse der Rollen-Typen und Commands. Wer die Feldliste fuer
# adopter-adaptierbaren Text haelt, greift genau danach.
#
# WARUM `test-go` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Zusage ist „ein erneuter Lauf
# schreibt kanonisch neu", und ein erneuter Lauf ist ein zweiter Aufruf von Enforce ueber
# demselben Verzeichnis — den fuehrt der Go-Waechter vollstaendig aus. `full-smoke` faerbt
# derselbe Eingriff ebenfalls rot (Idempotenz-Block), kostet dafuer aber einen Bootstrap
# samt Docker-Gates; der Preis steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i 's@return writeFileMode(targetDir, FieldListPath, \[\]byte(doc), 0o644)@return writeSkipIfPresent(targetDir, FieldListPath, []byte(doc), 0o644)@' internal/emit/fieldlist.go
