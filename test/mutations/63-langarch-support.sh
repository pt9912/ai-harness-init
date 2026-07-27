#!/usr/bin/env bash
# files: internal/gen/gen.go
# expect: TestRun_AddLangUnknownArchRejected
#
# Entfernt die ARCH-VALIDIERUNG von GenerateArch — beide Stufen, weil sie sich seit
# slice-053 gegenseitig decken: seit go UND cpp beide Architekturen rendern, faengt die
# sprach-spezifische Stufe jede unbekannte Architektur ebenso wie die globale. Wer nur
# eine Stufe mutiert, sieht deshalb nichts (die andere haelt) — die bewachte EIGENSCHAFT
# ist "eine nicht getragene Architektur wird abgelehnt, und es entsteht kein Artefakt",
# und genau die nimmt diese Mutation weg: `add-lang cpp <pfad> --arch onion` schreibt dann
# still ein Geruestung-only-Skelett (Exit 0) statt Exit 2.
#
# Bis slice-053 hing dieser Fall an `cpp --arch hexslice`; die Zusage ist gewandert, nicht
# entfallen (slice-032-Lehre: eine wandernde Grenze wird umgeschrieben).
set -euo pipefail
sed -i 's/if archLayout(arch) == nil {/if false {/' internal/gen/gen.go
sed -i 's/if !archSupported(lang, arch) {/if false {/' internal/gen/gen.go
