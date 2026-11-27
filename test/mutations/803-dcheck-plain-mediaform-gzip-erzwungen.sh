#!/usr/bin/env bash
# files: harness/tools/dcheck-fetch.sh
# expect: mediaform plain: ein v1.tar-Layer (ohne gzip) zieht
# verify: test-bats
#
# Erzwingt den gzip-Zweig auf plain-Layern (N-1, Review-Addendum): `*v1.tar)
# zflag=""` wird zu `zflag="z"` — ein Layer mit v1.tar-Media-Type (UNVERDICHTET,
# praktisch erreichbar an einer plain-Rotation der Registry) würde als gzip
# gelesen und für Fehldiagnose brechen, statt zu ziehen und abzulegen. ROT,
# vollstaendige Menge (Hand-Mutation an der realen Datei, gemessen): Test 7
# "mediaform plain: ein v1.tar-Layer (ohne gzip) zieht und legt ab" von
# test/dcheck-fetch.bats — die übrigen Fälle bleiben grün, weil die gzip-Kette
# an dieser Stelle keinen Zweig wechselt. GRENZE, benannt nicht geschlossen:
# der sonst-Zweig der Verzweigung (fremder Media-Type bricht mit nennender
# Meldung) trägt bats-Deckung (Test 8) und KEINE Mutations-Anlage — sein Zahn
# misst die Meldung mit dem gelesenen Media-Type; eine Anlage darüber wäre eine
# gedrehte Meldungs-Kopplung, keine Bedingung.
set -euo pipefail
sed -i 's/\*v1\.tar) zflag=""/\*v1.tar) zflag="z"/' harness/tools/dcheck-fetch.sh
