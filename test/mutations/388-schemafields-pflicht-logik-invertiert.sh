#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestSchemaFields_PflichtIstDieDrahtform
#
# INVERTIERT DIE PFLICHT-ABLEITUNG IN SchemaFields: ein Feld gilt als Pflicht genau dann,
# wenn sein Tag `omitempty` TRAEGT — das Gegenteil der Drahtform. Der Waechter haelt
# SchemaFields() gegen den echten json.Marshal einer leeren Span-Zeile und faengt die
# Umkehr in BEIDEN Richtungen (Pflichtfeld fehlt in der leeren Zeile / optionales Feld
# steht dort).
set -euo pipefail
sed -i 's/Required: !strings\.Contains(opts, "omitempty")/Required: strings.Contains(opts, "omitempty")/' internal/span/fieldlist.go
