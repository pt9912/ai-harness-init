**Vorgang:** slice-das-werkzeug-sagt-seine-fassung
**Fund:** Festlegung 1 von [`ADR-0063`](../../../../../../docs/plan/adr/0063-das-werkzeug-sagt-seine-fassung.md)
trägt zwei Hälften — die Injektion liest den **übergebenen** Wert, und sie liest ihn **nie aus
dem Pin-Default**. Die vier Mutations-Fälle deckten die erste Hälfte und die Fehlerrichtungen;
die Default-Hälfte trug keinen Wächter — ein späteres `TRAEGER_VERSION ?= $(TRAEGER_TAG)` hätte
den Fehlt-Fall unerreichbar gemacht, laut und still. Review-F-2
(`docs/reviews/2026-09-23-slice-das-werkzeug-sagt-seine-fassung.md`); der fünfte Fall
(`test/mutations/403-fassungs-pin-default.sh`) und der Wächter *„TRAEGER_VERSION trägt keinen
Default im Makefile"* schlossen die Lücke im selben Slice, Verifier-Befund: bindet in beide
Richtungen.