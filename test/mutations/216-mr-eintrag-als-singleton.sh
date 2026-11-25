#!/usr/bin/env bash
# files: internal/emit/templates.go
# expect: TestTemplates_EmittierterBestandVollstaendig
#
# MR-NNN-title.template.md wird in isRecurring nicht mehr erkannt -> der Adaptions-
# Eintrag landet als harness/conventions/MR-NNN-title.md im Ziel, obwohl seine Vorlage
# "Ein Eintrag je Datei" sagt (eine je Adaption, Ziel-Pfad mit <NNN>-Platzhalter). Das
# emittierte Repo traegt dann einen Adaptions-Eintrag, den niemand beschlossen hat.
# Kompiliert weiter.
set -euo pipefail
sed -i 's/"wave-results.template.md", "MR-NNN-title.template.md":/"wave-results.template.md", "__MR-NNN-neutralisiert__.template.md":/' internal/emit/templates.go
