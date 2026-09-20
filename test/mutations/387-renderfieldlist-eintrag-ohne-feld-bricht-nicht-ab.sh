#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestRenderFieldList_EintragOhneFeldBrichtAb
#
# HEBT DEN ABBRUCH AUF, DEN RenderFieldList FUER EINEN UEBERZAEHLIGEN EINTRAG VORSIEHT:
# die Bedingung wird nie wahr. Ein Eintrag des Ausdrucks ohne erfasstes Feld ergaebe dann
# ein Dokument, das eine Erfassung behauptet, die es nicht gibt.
set -euo pipefail
sed -i 's/if len(offen) > 0 {/if false \&\& len(offen) > 0 {/' internal/span/fieldlist.go
