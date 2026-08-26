#!/usr/bin/env bash
# files: internal/emit/templates/enforce/erfassung.mk
# expect: TestErfassungFragment_ZielUndNichtZusage
# verify: test-go
#
# LAESST EIN ZWEITES ENTFERN-KOMMANDO IN DAS REZEPT WACHSEN: ein `rmdir` neben dem `rm`.
#
# Die andere Richtung derselben Zusage, und die gefaehrlichere: ein Waechter, der die
# ENTFERN-Kommandos aufzaehlte, muesste `rmdir`, `shred`, `unlink`, `find … -delete` und
# jedes kuenftige kennen — eine Aufzaehlung ist eine Untergrenze und laesst still durch.
# Deshalb misst der Waechter den VOLLSTAENDIGEN Ist-Bestand der Rezept-Kommandos gegen
# die erwartete Menge: was hinzukommt, faellt auf, gleich wie es heisst.
set -euo pipefail
sed -i 's%rm -rf %rmdir .harness/state; rm -rf %' internal/emit/templates/enforce/erfassung.mk
