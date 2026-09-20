#!/usr/bin/env bash
# files: internal/span/fieldlist.go
# expect: TestRenderFieldList_FeldOhneEintragBrichtAb
#
# HEBT DEN ABBRUCH AUF, DEN RenderFieldList FUER EIN FELD OHNE EINTRAG VORSIEHT: die
# Bedingung wird nie wahr. Ein erfasstes Feld ohne Frage im Ausdruck des Schemas ergaebe
# dann ein Dokument statt eines Abbruchs — genau die stille Luecke, gegen die diese
# Pruefung steht.
set -euo pipefail
sed -i 's/if !beschrieben {/if false \&\& !beschrieben {/' internal/span/fieldlist.go
