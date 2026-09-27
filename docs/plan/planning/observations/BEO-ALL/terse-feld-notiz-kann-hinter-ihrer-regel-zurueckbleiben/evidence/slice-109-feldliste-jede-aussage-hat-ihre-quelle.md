**Vorgang:** slice-109-feldliste-jede-aussage-hat-ihre-quelle
**Fund:** Die neue `program`-Notiz („das erste Wort des ausgeführten Segments, nie das der ganzen
Kommandozeile") ist terser gehalten als SPEC-021 und gegen drei Randfälle aus slice-204 geprüft
(Verifikations-Report 2026-09-27), ohne Vollständigkeit zuzusagen. §6-Risiko 3 des Slice hält
fest, dass eine künftige `commandProgram()`-Änderung sie wieder zu kurz greifen lassen kann, ohne
dass ein bestehender Wächter das automatisch fängt.
