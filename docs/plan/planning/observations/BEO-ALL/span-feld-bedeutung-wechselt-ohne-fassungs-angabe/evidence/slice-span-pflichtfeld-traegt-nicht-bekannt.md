**Vorgang:** slice-span-pflichtfeld-traegt-nicht-bekannt
**Fund:** `cache_creation_input_tokens` und `cache_read_input_tokens` (`SPEC-024`) fehlen in Spans vor
diesem Slice, wo die Quelle keine Zähler liefert, und tragen danach die Zeichenkette
`nicht bekannt: <Quelle>` (`SPEC-087`); der Bestand wird nicht nachgezogen, und kein Feld trägt die Fassung.
