**Vorgang:** slice-194
**Fund:** Der Verweis-Nachzug des Closure-Move hat **drei** eingefrorene Artefakte geschrieben —
ein Zeitdokument unter `done/` und zwei Rollen-Reports, darunter den Verifikations-Report dieses
Slice selbst, der damit nach seiner eigenen Abgabe byte-geändert ist. Die vierte berührte Datei
ist lebend. Die Verweise bleiben auflösbar; das ist der Preis, den
[`AGENTS.md`](../../../../../../../AGENTS.md) §3.4 an dieser Stelle zahlt, und die
Ausnahmeliste von `make slice-mv` nimmt beide Bäume bewusst nicht aus.
