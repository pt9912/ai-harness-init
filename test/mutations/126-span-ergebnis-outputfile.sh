#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestNoResponseFreetextReachesSpan
#
# Nimmt `outputFile` in die POSITIV-Liste auf — mit einem `take`, das den Rohwert
# uebernimmt statt ihn zu begrenzen.
#
# `outputFile` ist ein PFAD, und Pfade sehen erfassbar aus: der Span fuehrt fuer
# Datei-Werkzeuge ohnehin ein `path`. Der Unterschied ist die Herkunft — dieser Pfad
# kommt aus dem ERGEBNIS eines fremden Werkzeugs und zeigt AUSSERHALB des Repos, in
# denselben Bereich wie der `transcript_path`, dessen Erfassung spec/spezifikation.md §5 Abweichung 1
# ausdruecklich zurueckgenommen hat. Ein Zeiger auf fremden Gespraechsinhalt legt eine
# Aufloesung nahe, die niemand genehmigt hat. Gemessen in slice-060 §3 Zeile 2.
#
# WARUM DER ROH-`take`: siehe test/mutations/123 — `intoSpawnedRole` und
# `intoModelVersion` sind beide begrenzt, ein Eintrag mit ihnen waere wirkungslos.
#
# Rot wird in internal/span/response_test.go „TestNoResponseFreetextReachesSpan" — der
# Kanarienvogel `/tmp/OUTPUTFILE-ddd444.md` steht dann in der geschriebenen Zeile.
set -euo pipefail
sed -i 's@take: intoModelVersion},@take: intoModelVersion},\n\t\t{path: []string{"outputFile"}, take: func(r *AgentResult, v json.RawMessage) { r.ModelVersion = string(v) }},@' internal/span/response.go
