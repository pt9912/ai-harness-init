#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestEnforce_IdempotenzKlasseJePfad
# verify: test-go
#
# STELLT DIE IDEMPOTENZ-KLASSE VON repo.mk AUF KONVERGENT UM.
#
# Danach schreibt jeder Re-Lauf den Startinhalt ueber die Targets des Repos, und sie sind
# nach dem naechsten Bootstrap still weg (ADR-0080 Festlegung 2). Der Test haelt die
# Klasse des Pfades gegen die Festlegung, nicht nur gegen die gefahrene Richtung.
set -euo pipefail
sed -i 's|dst: RepoMkPath, mode: 0o644, class: SkipIfPresent|dst: RepoMkPath, mode: 0o644, class: Konvergent|' internal/emit/enforce.go
