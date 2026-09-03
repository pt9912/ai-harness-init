#!/usr/bin/env bash
# files: internal/archive/anwenden.go
# expect: TestZuStagenNenntNurArchivStubsUndNachgezogene
# verify: test-go
#
# ADR-0033 Abnahme-Kriterium 2, schreibende Haelfte: ersetzt die aufgezaehlte
# Staging-Liste durch den ganzen Baum. Aus `git add -- <archiv> <stubs>
# <nachgezogene>` wird `git add -- .`.
#
# Der Inhalts-Commit ist der Wave-Self-Close-Punkt, den ein Audit liest. Traegt
# er fremden Inhalt — eine untrackte Datei, die neben dem Lauf im Baum lag —,
# ist die Zusage "der Archivierungs-Commit bezeugt die Vollstaendigkeit"
# gebrochen, ohne dass irgendetwas rot wird: der Lauf meldet weiter "ok", und
# der Diff sieht nur groesser aus. Die Vorpruefung faengt den Fall nicht, denn
# sie ist eine ANDERE Zusage und kann zwischen ihr und dem Commit verfallen.
set -euo pipefail
sed -i '/^func ZuStagen(/,/^}/ s|^\treturn out$|\treturn []string{"."}|' internal/archive/anwenden.go
