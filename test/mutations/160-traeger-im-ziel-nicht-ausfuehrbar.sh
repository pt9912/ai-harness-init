#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: der Traeger fehlt oder ist nicht ausfuehrbar
# verify: full-smoke
#
# LEGT DEN TRAEGER OHNE AUSFUEHRUNGSRECHT AB (0644 statt 0755).
#
# Im Ziel liegt danach eine Datei mit dem richtigen Namen am richtigen Ort, die kein
# Hook starten kann: der Wrapper prueft auf ausfuehrbar, findet nichts und schweigt —
# das Ziel erfasst still nichts, bei gruenem Bootstrap und gruenem `make gates`.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Zusage ist „der Traeger
# SCHREIBT im Ziel", und das kann nur ein Lauf mit dem echten Produkt-Binaer zeigen. Im
# Go-Testlauf ist das laufende Bild das Test-Binary; es als Traeger zu starten hiesse,
# den Testlauf erneut zu starten. Der Preis dieses Modus steht im Kopf von
# harness/tools/mutate.sh.
set -euo pipefail
sed -i 's/^const carrierMode fs.FileMode = 0o755$/const carrierMode fs.FileMode = 0o644/' internal/emit/enforce.go
