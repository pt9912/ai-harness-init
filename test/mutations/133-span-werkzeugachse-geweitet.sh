#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestOnlyAgentToolGetsResponseValues
#
# DIE WERKZEUG-ACHSE WIRD GEWEITET: die Erfassung aus `tool_response` laeuft nicht mehr
# nur fuer das namentlich gelistete `Agent`, sondern fuer JEDES klassifizierte Werkzeug
# (`Bash`, `Read`, `Write`, `Edit`, …). Danach gibt jedes von ihnen, dessen Ergebnis
# zufaellig `usage`, `agentType` oder `resolvedModel` fuehrt, Zaehler, Rolle und Modell
# preis.
#
# WARUM ES DIESEN FALL BRAUCHT: `TestOnlyAgentToolGetsResponseValues` haelt die ACHSE
# fest, auf der der fail-closed Default aus ADR-0011 Festlegung 2 ruht — erfasst wird
# nach dem WERKZEUG-Namen, nicht nach der Gestalt der Antwort. Bis zum 2026-07-30 hatte
# dieser Waechter KEINEN Fall in test/mutations/ und war damit nach
# AGENTS.md §3.6 unbewacht: seine Zaehne konnten verschwinden, ohne dass `make mutate`
# etwas meldet (Verifier-Befund V-1, zweiter Teil). Es ist dieselbe Klasse wie
# Review-Befund HIGH-1 auf der Argument-Achse, an der `mcp__db__run` sein `psql`
# preisgab — nur eine Payload-Haelfte weiter.
#
# WARUM `!= classNone` UND NICHT `if true`: die realistische Fehlhandlung ist das Weiten
# einer bestehenden Bedingung, nicht ihr Wegfall. `classNone` ist der fail-closed
# Default; wer ihn als „unbekannt, also nichts" liest und daraus „alles Bekannte, also
# alles" macht, schreibt genau diese Zeile.
#
# ROT WIRD GENAU EINER: die drei Unterfaelle `Bash`, `Read` und `Write` des benannten
# Waechters bekommen ihre Zaehler und `spawned_role: reviewer`. `Task`, `mcp__x__agent`,
# `BashOutput` und `agent` bleiben auch nach der Mutation stumm (sie sind `classNone`) —
# der Waechter faellt also an der Ausweitung, nicht am fail-closed Default selbst. Der
# einzige weitere Test mit einem `tool_response` an einem fremden Werkzeug ist
# `TestDurationAndResultSize` (`Bash`); sein Ergebnis ist ein JSON-STRING, nicht ein
# Objekt, und die Positiv-Liste findet darin nichts — er bleibt gruen.
set -euo pipefail
sed -i 's@toolClass(p.Tool) == classAgent@toolClass(p.Tool) != classNone@' internal/span/span.go
