**Stand:** verkörpert

Zielort: [`AGENTS.md`](../../../../../../AGENTS.md) §5 (Requirement- und ADR-IDs in PRs/Commits
referenzieren) und [`harness/README.md`](../../../../../../harness/README.md#traceability)
§Traceability — dort steht die Zusage samt ihren **zwei Trägern** und der Reichweiten-Tabelle, die je
Commit-Klasse sagt, welcher Träger sie erreicht und welche Grenze er hat. Ein zweiter Herkunfts-Anker
steht nicht: der Zielort trägt seine eigene Adresse.

**Grenze der Verkörperung, benannt.** Die Zusage ist **nicht** vollständig bewacht, und das steht an
denselben zwei Orten: die Aktivierung des git-eigenen Trägers reist nicht mit dem Klon
(`core.hooksPath` ist lokale Konfiguration), `--no-verify` umgeht ihn, und der Agenten-Kanal erreicht
strukturell weder einen Commit aus einem Repo-Werkzeug noch einen Commit außerhalb eines Agenten-Laufs.
Zwei Hälften des Eintrags sind benannt und **nicht** geschlossen — die Bezugseinheit *jeder Commit*
gegen *die Änderung als ganze* liegt bei
[`slice-121`](../../../open/slice-121-commit-message-nennt-was-es-gibt.md), die vier Werkzeug-Formen
bei [`slice-werkzeug-commits-tragen-eine-kennung`](../../../done/slice-werkzeug-commits-tragen-eine-kennung.md).
Träger der Wirkung bleibt der Commit-Pfad selbst; die Kennungs-Erkennung, die ihn liest, ist der
Gegenstand von
[`slice-kennungs-erkennung-traegt-die-zugelassenen-formen`](../../../open/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md).
