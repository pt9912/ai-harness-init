# Anweisungssatz-Nachzug ohne Wächter

**Sub-Area:** `*` (gesamtes Repo)

Der Anweisungssatz einer Rolle ist die Abschrift von Pflichten, die ein Baseline-Regelwerk-Modul
führt, und von Formen, die ein Adaptions-Eintrag setzt — nachgezogen wird die Abschrift von Hand,
gegen den committet vendored Baum. Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) hält einen Anweisungssatz gegen seine Quelle, und
[`make comment-claims`](../../../../../../harness/sensors/comment-claims.md) führt
[`.claude/commands/`](../../../../../../.claude/commands/) nicht in seinem Prüfbereich. Ein
vergessener Block und eine vergessene Notations-Stelle bleiben damit grün. Die Fehlerrichtung ist
*der Nachzug ist vollständig*.

Der Anlass wiederholt sich mit jedem Baseline-Sprung: Was das Regelwerk zwischen zwei Tags gewinnt,
erreicht den Anweisungssatz nur über einen Lauf, der beide nebeneinanderlegt.

## Benannt, nicht gezählt

Drei Nachbarklassen sind enger und decken den Fall nicht.
[`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
setzt **zwei Fassungen derselben Regel** voraus — Dogfood und Emissions-Vorlage —, die
auseinanderlaufen dürfen; hier steht eine einzige Fassung gegen ihre **Quelle**, und die Quelle ist
kein Text dieses Repos.
[`waechter-abdeckung-haengt-an-uninstruierter-konvention`](../waechter-abdeckung-haengt-an-uninstruierter-konvention/observation.md)
setzt einen Wächter voraus, den die auslösende Form **nicht erreicht**; hier erreicht die Form
keinen Wächter, weil keiner existiert.
[`benannte-luecke-ohne-ausgang`](../benannte-luecke-ohne-ausgang/observation.md) fragt, **wohin**
eine benannte Grenz-Beschreibung wieder verschwindet; hier ist offen, **dass** überhaupt etwas sie
meldet.
