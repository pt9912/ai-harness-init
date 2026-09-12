# `make mutate` — Mutations-Sensor zu AGENTS.md §3.6

## Vertrag

Wendet ein kuratiertes Set von Mutationen an (Mutation → erwartet rot färbender Test) und
meldet jeden Wächter, der dabei **grün** bleibt — die Regel ist sonst nur im
Feedforward-Quadranten. Kein Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
der Grund ist die Laufzeit: je Fall ein voller Sensor-Lauf.

## Grenze — was das Grün nicht abdeckt

**Vor dem Fall-Satz prüft der Lauf einen Beleg**
([`ADR-0035`](../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)):
war der letzte Lauf über demselben Prüfgegenstand vollständig grün, gibt dieser Lauf diesen
Beleg aus statt den Fall-Satz erneut zu fahren — `MUTATE_FORCE=1` erzwingt den vollen Lauf.
Die Fälle laufen auf mehrere, dynamisch zugeteilte Worker verteilt (`MUTATE_JOBS`), jeder mit
einer eigenen isolierten Kopie außerhalb des Repos; das Verdikt hängt nicht an der
Worker-Zahl (Zeit-, keine Verdikt-Stellschraube). Der Lauf begrenzt seine eigene Stille
(`MUTATE_STALL_SECONDS`) und wird rot, wenn kein Worker mehr zieht oder abschließt.

**Was er nicht deckt, steht im Treiber:** beendet wird der Worker, nicht dessen Kinder, und
ein Hänger im Vorwärmlauf vor dem Fork liegt außerhalb. Ein Abbruch lässt im Arbeitsbaum kein
Residuum zurück; außerhalb bleiben ein Temp-Verzeichnis und, nach hartem Kill, das
Lock-Verzeichnis liegen (bewusst fail-closed). Isolation, Beleg-Mechanik, Bezugsmenge des
Schlüssels (`isolation_key_files`, **nicht** `harness/tools/working-tree-hash.sh`) und jede
weitere Bedingung stehen im Kopf von `harness/tools/mutate.sh`.

## Bindung

[`AGENTS.md`](../../AGENTS.md) §3.6; slice-026; kein Gate-Versprechen, aber mechanischer
Pro-Push-Auslöser in CI.
