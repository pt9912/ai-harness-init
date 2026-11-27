#!/usr/bin/env bash
# files: .github/workflows/ci.yml
# expect: kein Inventar-Soll-Wert steht literal in den drei Workflows
# verify: test-bats
#
# Hardpinnt die Toolchain im Workflow: der ci-runner-setup-Aufruf im gates-Job
# der ci.yml wird durch eine go-Download-Zeile mit festem Version-Literal
# ersetzt — die "eine Quelle"-Zusage des Setups (Soll-Spalte aus dem Inventar,
# ci-runner-setup.sh EINE QUELLE) bricht damit an der Soll-Nennungs-Bindung.
# Die Bindung liest die Werkzeug-Menge aus der realen Inventar-Datei; das
# Version-Literal im Fall (1.30.0) ist die Drift-Form eines künftigen
# Pin-Werts, nicht die heutige Fassung — derselbe Muster-Anker fängt jeden Wert.
# Rot faerbt test/ci-runner-ohne-docker.bats, Fall 6. GRENZE (Vorbestand): der
# gruen-vorlauf faehrt make test-bats auf der Kopie und bricht an den
# vorbestehenden bats-Klassen (158/281), bevor der Fall faehrt — die kuratierte
# Rot-Form trägt der Lauf nach dem Vorbestand-Fix (Welle); am Vorlaufs-Bestand
# ist der Fall durch den Fall 158/281 gebunden, nicht still.
set -euo pipefail
sed -i '0,/^          make ci-runner-setup$/{s@^          make ci-runner-setup$@          curl -fsSL "https://go.dev/dl/go1.30.0.linux-amd64.tar.gz" | tar -xzf - -C .harness-ci@}' .github/workflows/ci.yml
