#!/usr/bin/env bash
# files: internal/span/response.go
# expect: TestNoResponseFreetextReachesSpan
#
# Nimmt `content` in die POSITIV-Liste auf — mit einem `take`, das den Rohwert
# uebernimmt statt ihn zu begrenzen.
#
# `content` ist der GROESSTE Freitext-Block des ganzen Aufrufs: der vollstaendige
# Bericht des Subagenten (Architect-Befund vom 2026-07-30, §5). Er ist damit das
# Feld, dessen Aufnahme den Massen-Abfluss ueber die Telemetrie eroeffnet — genau
# das, was ADR-0011 Festlegung 2 "konstruktiv ausgeschlossen" nennt. Gemessen in
# slice-060 §3 Zeile 1.
#
# WARUM DER ROH-`take` UND NICHT `intoModelVersion`: die zwei bestehenden String-Pfade
# sind BEIDE begrenzt — `intoSpawnedRole` normalisiert gegen sechs Namen,
# `intoModelVersion` gegen Laenge und Zeichensatz. Ein Eintrag mit einem davon waere
# WIRKUNGSLOS (der Freitext fiele weg), und ein wirkungsloser Patch ist Bedingung 2 des
# Treibers, kein Zahn. Die realistische Fehlhandlung ist deshalb genau diese: wer ein
# Feld "nur mal mitnehmen" will, schreibt sich den take dazu.
#
# Rot wird in internal/span/response_test.go „TestNoResponseFreetextReachesSpan" — der
# Kanarienvogel `CONTENT-AWS_SECRET_ACCESS_KEY=aaa111` steht dann in der geschriebenen
# Zeile.
set -euo pipefail
sed -i 's@take: intoModelVersion},@take: intoModelVersion},\n\t\t{path: []string{"content"}, take: func(r *AgentResult, v json.RawMessage) { r.ModelVersion = string(v) }},@' internal/span/response.go
