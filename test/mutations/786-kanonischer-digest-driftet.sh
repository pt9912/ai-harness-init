#!/usr/bin/env bash
# files: d-check.mk
# expect: TestDefaultDigest_MatchesCanonical
#
# Der kanonische Digest der d-check-Pin-Kette (LH-QA-02) driftet auf einen anderen
# sha256-Wert: TestDefaultDigest_MatchesCanonical liest DCHECK_DIGEST aus d-check.mk
# und haelt emit.DefaultDigest dagegen — der Lauf waere danach ungewiss. Match generisch
# auf den Wert ([0-9a-f]{64}), damit der Fall bei jedem Pinzug greift.
set -euo pipefail
sed -i -E 's/^DCHECK_DIGEST \?= sha256:[0-9a-f]{64}$/DCHECK_DIGEST ?= sha256:0000000000000000000000000000000000000000000000000000000000000000/' d-check.mk
