# Retirierter Adaptions-Eintrag als lebende Begründung zitiert

**Sub-Area:** `*` (gesamtes Repo)

Ein **lebendes** Artefakt stützt eine Entscheidung auf einen Adaptions-Eintrag, der nach
[`MR-020`](../../../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
aufgelöst ist und nur noch Kopf und Zeiger trägt: Die zitierte Aussage steht dort nicht mehr, und
der ablösende Eintrag trägt sie oft ebenfalls nicht. Wer der Kette folgt, landet bei einem Stub und
findet die Begründung nirgends. **Kein Gate sieht das** — der Anker `#mr-NNN--…` bleibt in der
Index-Tabelle stehen, damit Verweise gerade *nicht* brechen, und `links`/`anchors` bleiben dauerhaft
grün über einem toten Zitat.

Die Fehlerrichtung ist *die Begründung trägt*: Der Satz liest sich belegt, und die Belegstelle ist
leer. Teuer wird die Klasse im Zusammenspiel mit dem Lifecycle — ein Slice-Plan, der seine Zitate
bei der Niederschrift korrekt setzt, altert im Lifecycle gegen den Adaptions-Block und friert die
tote Adresse beim `git mv` nach `done/` ein.

Die Nachbarklasse
[`abgeschaffte-kennung-in-unveraenderlichem-artefakt`](../abgeschaffte-kennung-in-unveraenderlichem-artefakt/observation.md)
ist eine andere: dort steht das Zitat in einem Artefakt, das man **nicht mehr ändern darf**, und die
Frage ist, wie ein eingefrorener Text mit einer toten Kennung umgeht. Hier steht es in einem
lebenden, und die Frage ist, dass niemand es bemerkt.

## Benannt, nicht gezählt

Der Bestand ist gemessen, nicht geschätzt — **keine Erwartungswerte**, die Zahl wandert mit dem
Baum:

```sh
git grep -ln 'MR-016' -- '*.md' ':!.harness/baseline' ':!docs/plan/planning/done' \
  ':!docs/reviews' ':!harness/conventions' | wc -l
```

Er umfasst offene und priorisierte Slice-Pläne, zwei Welle-Pläne, die laufende Roadmap, die
`README.md` des Beobachtungs-Registers selbst und eine nach
[`AGENTS.md`](../../../../../../AGENTS.md) §3.4 eingefrorene ADR. Diese Vorkommen sind **kein**
abgeschlossener Vorgang und bewegen den Zähler nicht; ob und wie sie nachgezogen werden, ist eine
Frage für den Architect und nicht für eine Slice-Closure.
