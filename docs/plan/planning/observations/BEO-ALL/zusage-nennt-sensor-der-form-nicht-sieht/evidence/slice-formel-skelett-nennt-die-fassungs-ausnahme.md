**Vorgang:** slice-formel-skelett-nennt-die-fassungs-ausnahme
**Fund:** Der Kopf des Tests in `test/release-matrix.bats` sagte zu, er sehe die `-X`-Operanden in
Dockerfile, Makefile und den Workflows; sein Muster `-X [A-Za-z0-9_./]+=` erkannte vier gültige
Formen nicht (`-X=…`, `-X '…'`, `-X "…"`, Tab statt Leerzeichen). Ein zweiter injizierter Wert in
einer dieser Formen ließe den Skelett-Satz überbreit stehen, und der Test bliebe grün (Review F-1,
HIGH, im Slice geschlossen: die Erkennung liest die vier Formen und meldet jede unlesbare
`-X`-Zeile fail-closed; Mutations-Fälle 612 und 613).
