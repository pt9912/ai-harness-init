**Vorgang:** slice-c2-template-renames-und-kennungs-formen-v7-0-0

**Fund:** Der `WELLE=`→`WAVE=`-Formzug am emittierten Archivierungs-Fragment
zog die Kopfzeilen (`internal/emit/templates/enforce/archivierung.mk`,
Kopfzeilen 14/19/23/40) und die Sensor-Prosa; die Rezept-Zeile 42 übergab
weiter `"$(WELLE)"`, und die Dogfood-Make-Variable trug
`WELLE=<welle-id>` — `make archive-welle WAVE=<id>` verlor die Kennung an
ein leeres Positionsargument (Review-Report
[`docs/reviews/2026-11-25-slice-c2-template-renames-und-kennungs-formen-v7-0-0.md`](../../../../../../../docs/reviews/2026-11-25-slice-c2-template-renames-und-kennungs-formen-v7-0-0.md),
F-1 HIGH / F-2 MEDIUM; der Text-Sensor `internal/emit/archivierung_test.go`
hielt die Kopfzeile als Text und blieb grün).

Lauf-Beleg des Heilausgangs (Vorher/Nachher, Implementer-Übergabe im
Slice-Plan §7, Commit `e20d8e7c`):

| Stand | Kommando | Ausgabe |
|---|---|---|
| vor dem Fix | `make -n archive-welle WAVE=wave-reviews-somesh-probe` | `.harness/state/bin/ai-harness-init archive-welle  ""` |
| nach dem Fix | `make -n archive-welle WAVE=wave-reviews-somesh-probe` | `.harness/state/bin/ai-harness-init archive-welle  "wave-reviews-somesh-probe"` |
| nach dem Fix | `make -n archive-welle WAVE=altbestand KENNUNG=…` | `… --kennung "…" "altbestand"` |

Zahn-Grenze (benannt, [`AGENTS.md`](../../../../../../../AGENTS.md) §3.6): kein
Wächter in `make gates` hält den Kennungs-Pass-through der
Rezept-/Makefile-Zeile — die Test-Stelle
`cmd/ai-harness-init/archive_welle_test.go` misst den Binär-Parser, die
Mutations-Anker greifen auf Quelltext-Niveau; der Aufruf selbst läuft erst im
realen Ziel (`make full-smoke`).

**Facetten desselben Zugs** — die sechs Finding-Klassen des Reviews, ein
Beleg, kein Zähler je Facette: Interface-Formzug ohne Rezept-Nachziehung
(F-1, geheilt `e20d8e7c`) · Target-Konfig-Form im Sensor-Text ohne Träger im
Bestand (F-2, geheilt `e20d8e7c`) · Emittiertes Kommentar trägt die alte
Kennungs-Form (F-3, Kommentar-Stelle ohne Verhaltenseffekt) ·
Begründungs-Zusatz im angenommenen Eintrag ohne datierte Fundstelle (F-4,
Inhalt vom Plan DoD (3) getragen) · Zustands-Prosa neben dem Ruhe-Marker
ohne Nachzug (F-5, healed im Paarungen-Commit der Slice-Closure) · Doppelte
Kennung in Commit-Message (F-6, Commit `0a080df5`, Betreffzeile).
