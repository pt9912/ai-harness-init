#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: der Traeger lehnt die Kombination mit Exit 2 und 'unbekannte Architektur' ab
# verify: full-smoke
#
# DER TRAEGER NENNT IN DER ABLEHNUNG DIE ARCHITEKTUR SELBST ALS GETRAGEN: die Liste
# `verfuegbar:` der Meldung "unbekannte Architektur" fuer eine nicht von der Sprache getragene
# Kombination (`cpp --arch hexagonal`) fuehrt die abgelehnte Architektur mit. Die Meldung
# widerspricht sich damit selbst — abgelehnt und zugleich verfuegbar —, und die Kennungs-Form-
# Stufe von full-smoke wertet sie als irrige Ablehnung einer getragenen Kombination statt als
# Nicht-Fall.
#
# WARUM `full-smoke` DIE SCHMALSTE AUSREICHENDE STUFE IST: die Stufe (kennungs_form_im_ziel)
# liest die Liste je Kombination aus der Meldung des gebauten Traegers; kein Go-Test fuehrt
# diese Stufe, und `cpp hexagonal` ist die einzige Kombination, die sonst keine Stufe
# bootstrappt. Ohne den Vergleich der Architektur mit der Liste derselben Meldung bliebe der
# Lauf unter dieser Mutation gruen. Der Preis des Modus steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i 's|Available: archsForLang(lang)}|Available: append(archsForLang(lang), arch)}|' internal/gen/gen.go
