#!/usr/bin/env bash
# files: internal/span/span.go
# expect: TestAgentGetsNoArgumentFields
#
# DIE ARGUMENT-ACHSE WIRD GEOEFFNET: `spawned_role` faellt auf
# `tool_input.subagent_type` zurueck, wenn das ERGEBNIS keine Rolle lieferte. Der Wert
# wird dabei direkt aus der Payload-Map gelesen, ohne `ToolInput` anzufassen — die
# Zusage „ToolInput fuehrt weiterhin genau drei Felder" bleibt also woertlich wahr,
# waehrend die Eigenschaft, die sie tragen soll, gebrochen ist. Genau darum ist B1 eine
# Aussage ueber die HERKUNFT des Wertes und nicht ueber ein Struct.
#
# DAS IST B1 des Architect-Verdikts vom 2026-07-30
# (docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md §6): `spawned_role` kommt
# aus `tool_response.agentType`, NIE aus `tool_input.subagent_type`. Auf dieser Grenze
# ruht das Verdikt „innerhalb ADR-0011 Festlegung 2" — die Argument-Achse ist die
# Flaeche, die Festlegung 2 ueberhaupt regelt. Bricht B1, faellt das Verdikt.
#
# WARUM ES DIESEN FALL BRAUCHT — Fall 131 nennt DENSELBEN Waechter und bindet B1 NICHT.
# Gemessen am 2026-07-30 (Verifier-Befund V-1, hier nachgefahren): streicht man die
# beiden B1-Zusicherungen aus `TestAgentGetsNoArgumentFields` — das `"spawned_role"` im
# `mustNotContain` und die `s.SpawnedRole != ""`-Pruefung —, bleibt der Waechter GRUEN
# (Gruen-Vorlauf gruen) und Fall 131 meldet weiter `-> TestAgentGetsNoArgumentFields
# rot`. 131 faellt naemlich an der Gegenprobe `"tool":"Agent"`, nicht an B1; Bedingung 4
# des Treibers findet den Namen und ist zufrieden. Die tragende Zusicherung durfte damit
# lautlos verschwinden — dieselbe Fehlerform wie R2-MEDIUM-1 (Fall 110 und `tool`) und
# MEDIUM-4 (Fall 127 und `model_version`), eine Ebene weiter innen.
#
# ROT WIRD GENAU EINER, und zwar an der B1-Zusicherung selbst: der Waechter faehrt eine
# Payload OHNE `tool_response` mit `subagent_type: "reviewer"`, danach steht
# `"spawned_role":"reviewer"` in der Zeile und `mustNotContain` schlaegt an. Die uebrigen
# Waechter dieser Flaeche tragen entweder gar kein `tool_input`
# (TestUnlistedResponseKeyStaysOut, TestSpawnedRoleIsNormalised,
# TestResolvedModelIsStructurallyBounded, TestOnlyAgentToolGetsResponseValues) oder
# bekommen ihre Rolle schon aus dem Ergebnis, sodass der Rueckfall nicht greift
# (TestNoResponseFreetextReachesSpan).
#
# WARUM DIE MUTATION NORMALISIERT statt den Rohwert zu nehmen: mit `roleFromAgentType`
# ergibt der Fehlschlag-Waechter TestFailedAgentCallCapturesNothing (`subagent_type:
# "nope"`) weiterhin ein leeres Feld und bleibt gruen. Ein roher Rueckfall faerbte ihn
# mit — und „132 rot" hiesse dann nicht mehr eindeutig „B1 greift in DIESEM Waechter"
# (die Lehre aus Review-Befund R2-MEDIUM-4).
#
# WARUM DER RUECKFALL HINTER die Ergebnis-Erfassung gehoert und nicht davor: davor
# ueberschreibt `p.Spawned = extractAgentResult(v)` ihn bei jedem Aufruf mit Ergebnis.
# Der realistische Fehler ist gerade der Rueckfall — „das Ergebnis sagt nichts, dann
# nehmen wir eben, was angefordert wurde" —, und er trifft genau die Faelle, in denen
# ADR-0011 Festlegung 2 zaehlt: Hintergrund-Laeufe und Fehlschlaege ohne `agentType`.
#
# GRIFFE DER ANKER NICHT, waere es kein stilles „ok": die eingefuegten Zeilen sind die
# einzige Wirkung dieses Falls, und Bedingung 2 des Treibers meldet eine Mutation, die
# die Datei nicht veraendert.
set -euo pipefail
sed -i 's@^\tp.Failed = failed(raw, p.Event)$@\tif in, ok := raw["tool_input"]; ok \&\& p.Spawned.SpawnedRole == "" {\n\t\tvar arg map[string]json.RawMessage\n\t\tif json.Unmarshal(in, \&arg) == nil {\n\t\t\tp.Spawned.SpawnedRole = roleFromAgentType(text(arg["subagent_type"]))\n\t\t}\n\t}\n\tp.Failed = failed(raw, p.Event)@' internal/span/span.go
