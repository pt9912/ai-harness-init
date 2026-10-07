#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestCacheStatusIsMarkedNotKnown
#
# SETZT DIE CACHE-ZAEHLER AUF 0, SOBALD `usage` EXISTIERT: ein `usage`-Objekt ohne die
# zwei Cache-Schluessel liefert die Zaehler nicht, die Zeile traegt dann die Kennzeichnung
# (SPEC-087). Die Mutation belegt beide Felder vor der Positiv-Liste mit 0, wenn `usage`
# vorhanden ist; die Liste ueberschreibt sie nur dort, wo ein Schluessel steht. Der Fall
# bindet den Teilfall "Agent mit usage ohne Cache-Schluessel" des
# Kennzeichnungs-Waechters (SPEC-024).
set -euo pipefail
sed -i 's@^\tvar res AgentResult$@\tvar res AgentResult; if _, ok := obj["usage"]; ok { z := int64(0); res.CacheCreationInputTokens = CacheCount{\&z}; res.CacheReadInputTokens = CacheCount{\&z} }@' internal/span/response.go
