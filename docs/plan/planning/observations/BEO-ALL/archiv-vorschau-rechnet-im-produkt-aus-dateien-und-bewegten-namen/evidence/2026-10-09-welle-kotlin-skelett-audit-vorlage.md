**Vorgang:** 2026-10-09-welle-kotlin-skelett-audit-vorlage
**Fund:** Die Vorschau für `welle-kotlin-skelett` lief nach 75 s ohne Ausgabe bei ~98 % CPU; der Stack per `SIGQUIT` zeigt `ZaehlePraefix` → `regexp.FindAllStringIndex` bei 3545 Dateien × 203 bewegten Namen, je Aufruf neu kompiliert.
