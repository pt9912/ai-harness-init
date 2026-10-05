**Vorgang:** slice-emittierte-archivierung-kennt-den-altbestand
**Fund:** Die E2E-Stufe `archivierung_im_ziel` fährt `make archive-welle WELLE=altbestand` über einem
synthetischen Altbestand (ein Slice, kein Review-Report) und gegen den Träger aus dem Arbeitsbaum. Ob
der gepinnte Release-Träger `v0.2.6` den Schlüssel schreibt und ob ein gewachsener Bestand eines
Adopters ihn trägt, misst keine Stufe und kein Test; nie beobachtet (Verifikation 2026-10-05, L3).
