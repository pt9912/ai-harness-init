# Archiv-Vorschau rechnet im Produkt aus Dateien und bewegten Namen

**Sub-Area:** `*` (gesamtes Repo)

`archive-welle --vorschau` gibt bis zum Ende nichts aus und rechnet minutenlang: `ZaehlePraefix`
(`internal/archive/refs.go`) kompiliert seinen regulären Ausdruck je Aufruf neu, und `fundIn` ruft es
je Datei × bewegtem Namen auf. Die Laufzeit wächst mit dem Produkt aus Suchraum und `done/`-Bestand.
