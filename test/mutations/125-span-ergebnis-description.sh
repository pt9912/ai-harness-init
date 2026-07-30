#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestNoResponseFreetextReachesSpan
#
# Nimmt `description` in die POSITIV-Liste auf — mit einem `take`, das den Rohwert
# uebernimmt statt ihn zu begrenzen.
#
# `description` ist das harmlos aussehende der vier: eine kurze Zeile, vom Aufrufer
# frei formuliert. Genau darin liegt der Fall — sie ist der Kandidat, den eine
# Erfassung "als Etikett" mitnimmt, weil sie kurz ist. Kurz ist keine Schranke: der
# Aufrufer bestimmt den Inhalt, und was er hineinschreibt, entscheidet nicht dieses
# Repo. Gemessen in slice-060 §3 Zeile 2 (Hintergrund-Lauf).
#
# WARUM DER ROH-`take`: siehe test/mutations/123 — `intoSpawnedRole` und
# `intoModelVersion` sind beide begrenzt, ein Eintrag mit ihnen waere wirkungslos.
#
# Rot wird in internal/span/response_test.go „TestNoResponseFreetextReachesSpan" — der
# Kanarienvogel `DESCRIPTION-token-ccc333` steht dann in der geschriebenen Zeile.
set -euo pipefail
sed -i 's@take: intoModelVersion},@take: intoModelVersion},\n\t\t{path: []string{"description"}, take: func(r *AgentResult, v json.RawMessage) { r.ModelVersion = string(v) }},@' internal/span/response.go
