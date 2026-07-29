#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestLeftoverLockDirectoryDoesNotBlock
#
# Nimmt dem Emitter das Aufraeumen eines liegengebliebenen Lock-VERZEICHNISSES: das
# Verzeichnis wird nicht mehr entfernt, sondern nur noch in seinen Rechten angefasst.
#
# Der Fall ist der Nachlass der Vorgaenger-Fassung, die mit `mkdir` sperrte. `OpenFile`
# scheitert an einem Verzeichnis mit EISDIR — ohne Behandlung ist der Strom ab dem
# Wechsel DAUERHAFT und LAUTLOS tot. Genau das schliesst der Kommentar ueber `acquire`
# aus ("kein liegengebliebenes Schloss legt einen Strom still"), und genau das hat der
# Waechter bis Runde 2 nur BEHAUPTET, nicht geprueft (Review Runde 2, MEDIUM-1): er
# nannte den Fall in seinem Doc-Kommentar und fuhr ihn nie.
set -euo pipefail
sed -i 's@if rmErr := os.Remove(path); rmErr != nil {@if rmErr := os.Chmod(path, 0o700); rmErr != nil {@' internal/span/emit.go
