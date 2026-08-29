#!/usr/bin/env bash
# files: internal/emit/readme.go
# expect: TestTemplates_KeinPlatzhalterLinkImEmittiertenSatz
#
# Die Root-README geht am zweiten Aufrufpunkt der Neutralisierung vorbei. Sie
# stammt aus demselben vendored Kurs-Satz wie die Singletons und landet im
# selben geprueften Bereich des Zielrepos — ein Platzhalter-Link ist dort
# derselbe tote Verweis, nur an einer Stelle, die der Singleton-Emit nicht sieht.
set -euo pipefail
sed -i '/body = NeutralizePlaceholderLinks(body)/d' internal/emit/readme.go
