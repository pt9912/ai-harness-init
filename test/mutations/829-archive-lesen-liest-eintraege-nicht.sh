#!/usr/bin/env bash
# files: cmd/ai-harness-init/archive_lesen.go
# expect: TestArchiveLesen_VerletzterEintragBrichtAb
# verify: test-go
#
# ENTHEMMT DIE LESUNG DES TRAEGER-UNTERKOMMANDOS archive-lesen: der Lauf liest
# jeden Eintrag mit einer Null-Laenge statt bis zum Ende — der CRC-Vergleich, der
# am Ende des Lesens liegt, sieht nie einen Eintrag-Inhalt. Die Namensliste aus
# dem zentralen Verzeichnis bleibt voll verkuendigt, das Archiv oeffnet noch.
#
# Waechter ist TestArchiveLesen_VerletzterEintragBrichtAb: er verfaelscht das
# letzte Inhalts-Byte eines STORED-Eintrags am echten Zip-Layout (Kopfzeile und
# Verzeichnis unberuehrt, das Archiv oeffnet und listet noch) und haelt fest,
# dass nur die bis-zum-Ende-Lesung den Befund "Eintrag a.txt nicht lesbar"
# liefert. Ein Lauf, der nur die Existenz der Eintraege haelt, bleibt gruen.
#
# Rot-Zug: der Lesung-Aufruf zieht mit einer Null-Laenge; der verletzte Inhalt
# liest nie.
set -euo pipefail
sed -i 's|_, lesefehler := io.Copy(io.Discard, leser)|_, lesefehler := io.Copy(io.Discard, io.LimitReader(leser, 0))|' cmd/ai-harness-init/archive_lesen.go
