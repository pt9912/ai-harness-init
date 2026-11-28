#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestUmzugsStubVorDemNachziehenGesehen
# Waechter · seit slice-altbestand-stubs-voll-v1
# verify: test-go
#
# VERSCHIEBT DEN UMZUGS-STUB-WRITE HINTER DEN NACHZUG: der Nachzug liest die
# Alt-Adresse vor dem Write — sie ist bewegt, nicht lesbar — und sieht den
# Stub nie. Der Stub behaehlt danach seine eingangsschriebenen Verweise in der
# Form, die er vor dem Move hatte; der Nachzug kann ihn nicht mehr als Teil des
# Baums lesen (ADR-0112 Festlegung 1: der Stub tritt der Stub-Familie bei, die
# der Nachzug LIEST — dieselbe Ordnung wie bei schreibeStubs/schreibeReportStubs).
#
# Der Fall loest dieselbe Ordnung, die TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach
# fuer die Slice-Stubs haelt, fuer die Umzugs-Stubs ein: der Umzug
# stub-Write-Zug wird entfernt und hinter dem Nachziehen-Block neu angesetzt
# (Variable ohne Vorbelegung, das Err-Handling am neuen Ort).
set -euo pipefail
sed -i -e '/^\tumzugsStubs, err := schreibeUmzugStubs(root, b, umzuege, dateien)$/,/^\t}$/d' \
	-e 's|^\tberuehrt := make(\[\]string, 0, len(nachgezogen))$|\tumzugsStubs := []string{}\n\tif u, e := schreibeUmzugStubs(root, b, umzuege, dateien); e != nil { return e } else { umzugsStubs = u }\n\tberuehrt := make([]string, 0, len(nachgezogen))|' \
	internal/archive/anwenden.go
