**Vorgang:** slice-c7-adaptions-nachzuege-v7-0-0

**Fund:** die Rezept-Zeile des emittierten Archivierungs-Fragments
(`internal/emit/templates/enforce/archivierung.mk`) reichte den Träger-Aufruf
mit dem entstellt gebliebenen Schlüssel `"1001 27 1000 1001WAVE)"` weiter statt
der Zielform `"$(WAVE)"` (Make-Aufruf `WAVE=<wave-id>`,
[`ADR-0090`](../../../../../../plan/adr/0090-altbestand-commit-traegt-die-kennung-des-aufrufers.md)) —
`make full-smoke` (Abschnitt Archivierung im Ziel) brach an drei Sperren statt
der geplanten zwei. Die Text-Prüfschicht über die Kopfzeilen blieb grün
(`internal/emit/archivierung_test.go` hielt andere Zellen); der Bruch zeigte
sich nur im reellen Lauffall. Heilung Commit `7c750972`: Zeile zurück auf
`"$(WAVE)"`, Wächter `TestArchivierungFragment_RezeptRuftMitWaveKeying`
(Herkunfts-Anker `seit slice-c7-adaptions-nachzuege-v7-0-0`, Grenze: der reale
Lauf in `full-smoke` trägt die Kette), Rot-Beleg am mutate-once
(`"$(WELLE)"` → `FAIL internal/emit`); Fundlisten je Kommando im Plan-§7b
(R3-Trail, *eingetreten*).

**Klass-Fassung (C2, zweites Auftreten):** Form-Zug/Zustands-Drift am
Emissions-Interface zieht die Rezept-Zeile nicht mit; kein Sensor liest die
Rezept-Zeile gegen den Lauf — der Zahn liegt je [`slice-c2-template-renames-und-kennungs-formen-v7-0-0`](../../../../done/slice-c2-template-renames-und-kennungs-formen-v7-0-0.md)
§7 beim Grenz-Vermerk, der reale Lauf trägt die Kette ([`AGENTS.md`](../../../../../../../AGENTS.md)
§3.6, Fassung „Wirkung im Ziel“).
