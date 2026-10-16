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
# rollen_typen_im_ziel und haelt den Bestand frischer Ziele gegen genau diesen Baum. Kuerzte
# nur CanonicalRoles, fiele der Lauf dort mit „FEHLER — Handbuch-Baum" und erreichte den
# Meldungs-Zweig „Rollen-Typ fehlt" nie. Mit dem Handbuch im Gleichschritt bleibt die Stufe
# gruen; der einzige Vergleich, der die Rolle dann noch sieht, ist rollen_typen_im_ziel —
# dessen erwartete Liste kommt aus der Quelle statt aus dem Ziel (ein Lesen aus dem Ziel
# waere zirkulaer und saehe eine fehlende Rolle nie).
set -euo pipefail
sed -i 's@return \[\]string{"planner", "architect", "implementer", "reviewer", "verifier", "validator"}@return []string{"planner", "architect", "implementer", "reviewer", "verifier"}@' internal/span/emit.go
sed -i '/^│       └── validator\.md$/d' docs/user/benutzerhandbuch.md
