#!/usr/bin/env bash
# files: harness/tools/gates-fast.sh
# expect: fastpfad: fremder Hash am diffsha-Stempel -> voller Lauf (fail-closed)
# verify: test-bats
#
# MACHT AUS DEM DECKUNGS-VERGLEICH EINEN BLANKOSCHECK: die Bedingung
# `[ "$stamp_diff" = "$ist_diff" ]` wird zu `true` — entscheide() SKIPpt dann, ohne
# dass der diffsha-Stempel den Arbeitsbaum deckt (fremder Hash oder geleert gilt),
# also ohne gedecktes Paar. Genau der Luecken-Skip, den ADR-0099 Festlegung 1
# verweigert: der SKIP behauptete ein Verdikt, das kein Lauf ueber diesem Baum
# getragen hat.
#
# DIE STELLE, DIE DER AUFRUFER BENUTZT: Aufrufer ist das Make-Target `gates` ueber
# `bash harness/tools/gates-fast.sh`; die bats-Stufe faehrt `entscheide()` ueber
# `--entscheide`, denselben Einstieg, den der volle Lauf am Ende aufruft (kein Nachbau
# der Verdrahtung; die Weiterleitung selbst haengt an test/gates-fastpfad.bats,
# Zusage 5).
#
# WARUM die bats-Stufe die schmalste ausreichende ist: geprueft wird die REINE
# Entscheidung mit Fixture-Werten — bash und coreutils, kein Docker, kein `git` (das
# gepinnte bats-Image fuehrt keines, s. Kopf von test/gates-fastpfad.bats).
#
# ERWARTETER ROT-GRUND: der Test `fastpfad: fremder Hash am diffsha-Stempel -> voller
# Lauf (fail-closed)` wird rot, weil ein ungedeckter diffsha-Stempel SKIP ergibt
# (Exit 0 statt 1); die Validation-Zustaende (leer, gestutzt) fallen weiter in Exit 1
# und faerben ihre Tests nicht mit — das Rot hat genau einen benannten Grund.
set -euo pipefail
sed -i "s@\[ \"\$stamp_diff\" = \"\$ist_diff\" \] || return 1@true || return 1@" harness/tools/gates-fast.sh
