#!/usr/bin/env bash
# files: .github/workflows/release.yml
# expect: der artifacts-Job ruft das Host-Target
# verify: test-bats
#
# Zieht den artifacts-Job zurueck aufs gepinnte Docker-Target (b-1, ADR-0115
# Festlegung 6b, MR-014 Setzung 1): der Step ruft `make release-artifacts` statt
# des Host-Targets — die Umstellung waere still am CI-Zug entfallen. Der Waechter
# verlangt den release-artifacts-host-Aufruf in release.yml.
# MR-071: das Muster trifft den Target-Ruf des artifacts-Jobs an der realen
# Workflow-Datei dieses Commits (mutate-greift misst den Anker gegen sie).
set -euo pipefail
sed -i 's@make release-artifacts-host@make release-artifacts@' .github/workflows/release.yml
