#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestNoResponseFreetextReachesSpan
#
# Nimmt `prompt` in die POSITIV-Liste auf — mit einem `take`, das den Rohwert
# uebernimmt statt ihn zu begrenzen.
#
# `prompt` ist das EINZIGE Feld, das ADR-0011 Festlegung 2 namentlich als das benennt,
# was nie ins Log darf ("Betrifft heute u. a. das Agenten-Werkzeug mit seinem
# Freitext-Prompt"). Und es liegt in BEIDEN Flaechen: in `tool_input` (dort schuetzt es
# der fail-closed Default am Werkzeug-Namen) und in `tool_response` (dort schuetzt es
# allein die Positiv-Liste). Genau deshalb ist das Argument "andere Flaeche, also
# unbedenklich" hier falsch — es klingt nur am bequemsten. Gemessen in slice-060 §3
# Zeilen 1 und 2, in BEIDEN Betriebsarten.
#
# WARUM DER ROH-`take`: siehe test/mutations/123 — `intoSpawnedRole` und
# `intoModelVersion` sind beide begrenzt, ein Eintrag mit ihnen waere wirkungslos.
#
# Rot wird in internal/span/response_test.go „TestNoResponseFreetextReachesSpan" — der
# Kanarienvogel `PROMPT-hunter2-bbb222` steht dann in der geschriebenen Zeile.
set -euo pipefail
sed -i 's@take: intoModelVersion},@take: intoModelVersion},\n\t\t{path: []string{"prompt"}, take: func(r *AgentResult, v json.RawMessage) { r.ModelVersion = string(v) }},@' internal/span/response.go
