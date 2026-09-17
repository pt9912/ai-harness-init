**Vorgang:** slice-d-check-pin-liest-fremde-packs-und-loest-jede-range
**Fund:** Der Ablösungs-Beleg in `MR-066` stand auf `grep -c 'Praefix .pack-. oder .loose-.' .d-check.yml` → **1**; das Kommando liefert **0**, weil der zitierte Kommentar nach dem Wort *oder* umbricht und `grep` zeilenweise liest (Review F-1).
