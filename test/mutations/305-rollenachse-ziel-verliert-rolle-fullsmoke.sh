#!/usr/bin/env bash
# files: internal/span/emit.go docs/user/benutzerhandbuch.md
# expect: FEHLER — Rollen-Typ fehlt
# verify: full-smoke
#
# EINE ROLLE GEHT AUF DEM WEG ZUM ZIEL VERLOREN, UND DAS HANDBUCH FOLGT IHR: CanonicalRoles
# fuehrt nur noch fuenf Namen, also schreibt der Bootstrap nur fuenf Typ-Dateien unter
# .claude/agents/, und der Baum in §6 des Benutzerhandbuchs nennt die sechste nicht mehr. Die
# QUELLE dieses Repos (internal/emit/templates/agents/*.md) traegt die sechste Datei
# weiterhin — sie wird nur nicht mehr emittiert.
#
# WARUM BEIDE DATEIEN: die Stufe Handbuch-Baum steht in harness/tools/full-smoke.sh VOR
# rollen_typen_im_ziel und haelt den Bestand frischer Ziele gegen genau diesen Baum. Zwei
# Dateien aendern sich im Gleichschritt, damit diese Stufe gruen bleibt; unter den Stufen von
# full-smoke.sh sieht dann nur rollen_typen_im_ziel die fehlende Rolle — dessen erwartete
# Liste kommt aus der Quelle statt aus dem Ziel (ein Lesen aus dem Ziel ist zirkulaer und
# sieht eine fehlende Rolle nie). Die Aussage gilt fuer full-smoke.sh: unter `make test`
# faerbt dieselbe Kuerzung auch internal/emit/agents_test.go und
# internal/emit/rollen_kopplung_test.go.
set -euo pipefail
sed -i 's@return \[\]string{"planner", "architect", "implementer", "reviewer", "verifier", "validator"}@return []string{"planner", "architect", "implementer", "reviewer", "verifier"}@' internal/span/emit.go
sed -i '/^│       └── validator\.md$/d' docs/user/benutzerhandbuch.md
