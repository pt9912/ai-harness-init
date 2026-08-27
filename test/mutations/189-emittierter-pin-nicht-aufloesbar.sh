#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: AUSGANG LEITUNG
# verify: full-smoke
#
# STELLT DEN GEMESSENEN VORFALL NACH: das emittierte Dockerfile zeigt auf einen Tag,
# den die Registry nicht kennt. Der Lauf stellt dieselbe Anfrage wie am 2026-08-25 und
# bekommt dieselbe Klasse von Antwort — non-2xx statt Manifest.
#
# WAS DIESER FALL MISST, UND DIE ZWEI ANDEREN NICHT: dass full-smoke den Einordner
# WIRKLICH RUFT. test/mutations/187 und 188 messen den Einordner fuer sich; ob seine
# Ausgabe im Lauf ankommt, entscheidet die Verdrahtung, und die gibt es nur hier. Ein
# Lauf ohne Einordnung bliebe rot und saehe aus wie ein roter Baum — genau die
# Verwechslung, um die es geht.
#
# ER MISST AUCH DIE RICHTUNG: erhoben wird der LEITUNGS-Ausgang in dem Zustand, fuer
# den er die Erklaerung ist, nicht in einem anderen. Der Baum ist dabei unversehrt.
#
# BRAUCHT NETZ, wie jeder full-smoke-Lauf. Ohne erreichbare Registry ist schon der
# Gruen-Vorlauf rot, und der Treiber bricht mit seiner eigenen Meldung ab.
#
# PREIS: ein zusaetzlicher full-smoke-Lauf. Er bricht frueh ab (an der ersten
# make-gates-Stufe des ersten Ziels) und ist damit kuerzer als der Gruen-Vorlauf; die
# Groessenordnung steht im Kopf von harness/tools/mutate.sh.
set -euo pipefail
sed -i "s|^FROM golang:\${GO_VERSION} AS deps\$|FROM golang:9.99.9-gibt-es-diesen-tag-nicht AS deps|" internal/gen/golang.go
