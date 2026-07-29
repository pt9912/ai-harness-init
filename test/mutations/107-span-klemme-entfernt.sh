#!/usr/bin/env bash
# files: cmd/span-emit/main.go
# expect: TestClampSurvivesBrokenPayload
#
# Nimmt dem Emitter die KLEMME — das `defer clamp()` in main().
#
# Die Klemme ist tragend, nicht dekorativ: emit() laesst jeden Fehlschlag als panic
# hochkommen, statt ihn an Ort und Stelle zu schlucken. Ohne die Zeile endet ein
# kaputtes JSON auf stdin mit Exit 2 — genau dem Wert, mit dem ein Hook den Tool-Call
# BLOCKT. Fail-open kippte damit zu fail-closed (ADR-0011 Festlegung 6): der
# Beobachter legte den Lauf still, den er nur beobachten soll.
#
# Die Vorgaenger-Fassung dieses Falls mutierte die bash+awk-Fassung; ihre erste
# Runde ersetzte nur die Subshell, `exit 0` ueberlebte, und die Exit-Klemme blieb
# unbewacht (Review-Befund HIGH-5 zu slice-059). In Go ist die Klemme EINE Zeile, und
# ihr Fehlen ist eine Prozess-Eigenschaft, die der Waechter als Prozess misst.
set -euo pipefail
sed -i '/^\tdefer clamp()$/d' cmd/span-emit/main.go
