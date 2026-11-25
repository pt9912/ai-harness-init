#!/usr/bin/env bash
# files: d-check.mk
# expect: TestDefaultImage_MatchesCanonical
#
# Die kanonische Tag-Referenz der d-check-Pin-Kette (LH-QA-02) driftet auf einen anderen
# Tag: TestDefaultImage_MatchesCanonical haelt emit.DefaultImage gegen DCHECK_IMAGE —
# Tag-Drift zwischen beiden Pin-Leben bliebe sonst unbemerkt. Match generisch auf den
# Wert (v[0-9.]*), damit der Fall bei jedem Pinzug greift.
set -euo pipefail
sed -i -E 's/^DCHECK_IMAGE \?= ghcr\.io\/pt9912\/d-check:v[0-9.]+$/DCHECK_IMAGE ?= ghcr.io\/pt9912\/d-check:v0.0.1/' d-check.mk
