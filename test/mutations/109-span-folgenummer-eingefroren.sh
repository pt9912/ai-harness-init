#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestSeqIsAssignedNotDerived
#
# Friert den Zaehler ein: die Folgenummer wird zwar noch vergeben, aber nicht mehr
# fortgeschrieben — jeder Span bekommt wieder 1.
#
# Damit ist eine LUECKE fuer den Leser unsichtbar, und das ist der ganze Zweck des
# Feldes (ADR-0011 Folgepflicht 4). Der Emitter ist fail-open; er darf seinen eigenen
# Span verlieren, aber der Leser muss den Verlust SEHEN koennen, ohne Zutun des
# Schreibers. Die Vorgaenger-Fassung leitete die Nummer aus dem Bestand ab
# (`wc -l + 1`) und war deshalb immer dicht 1..N — Vollstaendigkeit, wo Spans fehlten
# (Review-Befund HIGH-3). Diese Mutation faehrt dieselbe Eigenschaft von der anderen
# Seite an.
set -euo pipefail
sed -i 's@strconv.Itoa(s.Seq)@strconv.Itoa(0)@' internal/span/emit.go
