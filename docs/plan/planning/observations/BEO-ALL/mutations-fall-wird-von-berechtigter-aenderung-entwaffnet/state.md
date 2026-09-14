**Stand:** verkörpert

Zielort: [`AGENTS.md`](../../../../../../AGENTS.md) §3.6 mit ihrem Träger
[`make mutate`](../../../../../../harness/sensors/mutate.md) — ein Fall, dessen Mutation nicht
greift, färbt den Lauf **fail-closed** rot; die Regel *ein gelisteter Fall mutiert den geprüften
Code* ist damit gebaut, nicht nur beschrieben. Ein zweiter Herkunfts-Anker steht nicht: Die Regel
steht seit ihrer Einführung ohne Anker, und nach derselben Regel wird keiner nachgetragen.

**Grenze der Verkörperung, benannt.** Die Regel greift erst **im** Fall-Ablauf, hinter
Isolationskopie und Grün-Vorlauf — ein vorgelagerter Durchgang über den `sed`-Anker besteht nicht.
Und sie deckt eine der zwei Bruch-Formen: ein Anker, der die verschobene Zeile sucht, verändert
nichts und wird gemeldet; ein Fall, der das alte Symbol **einfügt**, verändert die Datei, und der
erwartete Test fällt erst über den Übersetzungslauf aus einem anderen Grund. Träger beider Hälften
ist der Lauf, der einen Fall schreibt oder seinen Anker anfasst.
