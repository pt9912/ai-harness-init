#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestRun_AddLangUnknownArchRejected
#
# Entfernt die ARCH-VALIDIERUNG von GenerateArch — beide Stufen. Fuer eine UNBEKANNTE
# Architektur (`onion`) decken sie sich gegenseitig: die globale Stufe faengt sie, die
# sprach-spezifische ebenso. Wer nur eine mutiert, sieht deshalb nichts (die andere
# haelt). Die hier bewachte EIGENSCHAFT ist "eine nicht getragene Architektur wird
# abgelehnt, und es entsteht kein Artefakt", und genau die nimmt diese Mutation weg:
# `add-lang cpp <pfad> --arch onion` schreibt dann still ein Geruestung-only-Skelett
# (Exit 0) statt Exit 2.
#
# NICHT verwechseln (seit slice-058): die sprach-spezifische Stufe hat wieder einen
# EIGENEN Fall — `cpp --arch hexagonal` ist eine Architektur, die es GIBT, die dieser
# Renderer aber nicht traegt (TestGenerateArch_LangSpecificArchRejected). Zwischen
# slice-053 und slice-058 war sie von aussen unerreichbar; dass beide Stufen sich decken,
# gilt also nur fuer den unbekannten Wert, nicht allgemein.
#
# Bis slice-053 hing dieser Fall an `cpp --arch hexslice`; die Zusage ist gewandert, nicht
# entfallen (slice-032-Lehre: eine wandernde Grenze wird umgeschrieben).
set -euo pipefail
sed -i 's/if archLayout(arch) == nil {/if false {/' internal/gen/gen.go
sed -i 's/if !archSupported(lang, arch) {/if false {/' internal/gen/gen.go
