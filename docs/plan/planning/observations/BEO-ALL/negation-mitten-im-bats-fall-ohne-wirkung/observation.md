# Negation mitten im bats-Fall ohne Wirkung

**Sub-Area:** `*` (gesamtes Repo)

Ein `bats`-Fall führt eine Negation (`! grep …`) nicht als letztes Kommando. Unter `set -e` bricht ein
invertiertes Kommando nicht ab, und das Ergebnis des Falls bestimmt nur sein letztes Kommando: die
Zusicherung ist grün, gleich was sie findet. Die Fehlerrichtung ist *die Eigenschaft gilt*, wo der Fall
sie nie gemessen hat; sichtbar wird sie erst, wenn jemand die Mutation fährt, die die Zusicherung
fangen soll.

## Benannt, nicht gezählt

**Bestand in den anderen `bats`-Dateien.** `grep -nE '^\s+! ' test/*.bats | grep -v tap-nachzug | wc -l`
→ **46**, in **15** Dateien (`… | cut -d: -f1 | sort -u | wc -l`), gemessen 2026-09-25 — keine
Erwartungswerte. Gezählt sind Zeilen, die mit `!` beginnen; **wie viele davon mitten im Fall stehen und
darum wirkungslos sind, ist nicht gemessen**: ein `!` als letztes Kommando eines Falls wirkt.
`test/tap-nachzug.bats` führt keine (`grep -nE '^\s+! ' test/tap-nachzug.bats | wc -l` → 0).
