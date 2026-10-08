#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestAgentRoleFromKnownTypes
#
# agentRole schreibt bei unbekannter Rolle "" statt der Kennzeichnung
# `nicht bekannt: agent_type` (SPEC-010, SPEC-087). Der Anker steht repo-weit genau einmal.
set -euo pipefail
sed -i 's@return NotKnown(SourceAgentType)@return ""@' internal/span/emit.go
