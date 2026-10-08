**Vorgang:** slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand
**Fund:** Der Kopf von `harness/tools/handbuch-baum.sh` sagt den Vergleich *in beide Richtungen* zu;
die Fälle 614–616 banden nur *genannt, nicht angelegt* (Verifikation V-1, Gegenprobe
`nur_ziel=""` blieb grün). Im Slice durch Fall 617 gebunden; die Phase-2-Prüfungen tragen
weiter keinen Fall.
