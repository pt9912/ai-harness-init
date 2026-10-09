#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestEmittierteDateienTragenNurImZielAufloesendeKennungen
# verify: test-go
#
# DIE EMITTIERTE FELDLISTE NENNT WIEDER IHRE QUELLE IN DER SPEZIFIKATION DIESES WERKZEUGS —
# ohne Kennung, als Prosa ("Quelle: Spezifikation von ai-harness-init, §5"). Der Waechter
# liest harness/erfassung-feldliste.md im Ziel und meldet:
#   harness/erfassung-feldliste.md: emittiert Prosa: Spezifikation von ai-harness-init
# Gegenprobe: ohne prosaVerweisMuster bleibt der Fall gruen (LH-QA-01).
set -euo pipefail
sed -i 's|^\t"wiederverwendet, mischt zwei Läufe in einer Datei\.\\n"$|&+\n\t"Quelle: Spezifikation von ai-harness-init, §5.\\n"|' internal/span/fieldlist.go
grep -q 'Quelle: Spezifikation von ai-harness-init' internal/span/fieldlist.go
