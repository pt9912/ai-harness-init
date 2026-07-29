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
#
# ANKER NACHGEZOGEN am 2026-07-29: die Reparatur von Review-Runde-3-F-2 ersetzte
# `os.Remove` durch `syscall.Rmdir` (os.Remove unlinkt auch DATEIEN und koennte die
# frische Lock-Datei eines anderen Emitters treffen). Dieser Fall zeigte danach ins
# Leere — gefunden von der fail-closed Bedingung 2 des Treibers ("Mutation aendert die
# Datei NICHT -> Befund"), nicht von mir. Ohne sie haette er weiter "ok" gemeldet.
set -euo pipefail
sed -i 's@if rmErr := syscall.Rmdir(path); rmErr != nil {@if rmErr := os.Chmod(path, 0o700); rmErr != nil {@' internal/span/emit.go
