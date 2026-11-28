#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestAnwendenBrichtBeiVerletzterUmzugStubFormAb
# verify: test-go
#
# ENTHEMMT DIE FORM-VERDRAHTUNG DES UMZUGS-ZWEIGS: umzugForm kehrt immer nil
# zurueck, der Lauf schreibt den form-widrigen Umzugs-Stub und committet ihn.
#
# Der Fall ist NICHT 243 (Slice-Stubs) und NICHT 819 (Report-Stubs): die
# Slice-Vorlage und die Report-Vorlage sind unveraendert, ihre Stubs bestehen,
# und der Umzugs-Zweig bricht an der verletzten VORLAGE archive-stub-umzug —
# nur diese Haelfte enthemmt der Fall. Ein Umzugs-Stub mit Umzugs-Zeiger und
# vollem Text waere der Umzug, der nicht stattfand (ADR-0112 Festlegung 2).
set -euo pipefail
sed -i 's/^func umzugForm(inhalt string) error { return FormOKUmzug(inhalt) }$/func umzugForm(inhalt string) error { return nil }/' \
	internal/archive/anwenden.go
