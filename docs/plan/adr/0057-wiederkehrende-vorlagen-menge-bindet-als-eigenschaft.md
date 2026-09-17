# ADR-0057: Die wiederkehrende Vorlagen-Menge bindet als Eigenschaft gegen den vendored Satz — die Aufzählung in Rang 1 ist Gegenstand eines Change Requests, nicht eines Wächters

**Status:** Proposed

**Datum:** 2026-09-17

**Autor:** Architect (pt9912)

**Bezug:** [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0005](0005-ziel-repo-distribution.md), [ADR-0020](0020-emittierte-modul-15-regeln.md),
[ADR-0013](0013-technik-stratum-als-zielort.md),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md),
[`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
[`MR-019`](../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)

**Schärft:** — Prozess- und Emissions-Entscheidung ohne Zielelement im Technik-Stratum:
[`spec/spezifikation.md`](../../../spec/spezifikation.md) führt keine Sektion über den
Vorlagensatz (`grep -nE '^#{2,3} ' spec/spezifikation.md`). Die Entscheidung bindet die
Dispositions-Weichen in `internal/emit/templates.go` und den Wächter darüber; sie ändert
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) **nicht** —
das darf keine interne Quelle.

---

## Kontext

[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) beschreibt die
zweiklassige Ablage und nennt die wiederkehrende Klasse in einer Klammer; der Code führt dieselbe
Klasse in einer Weiche. Beide Mengen sind gemessen, **keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — sie wandern mit Vertrag und Bestand:

```sh
sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
  | grep -o 'Wiederkehrende\*\* Vorlagen ([^)]*)'
# -> Wiederkehrende** Vorlagen (ADR · slice · welle · carveout · review-report)   [5 Glieder]
awk '/^func isRecurring/,/^}/' internal/emit/templates.go \
  | grep -o '"[A-Za-z-]*\.template\.md"' | sort -u | wc -l        # 11
grep -cE '^func (isRecurring|isDerivativeIndex|isBrownfieldOnly)\(' internal/emit/templates.go  # 3
grep -c 'die fünf wiederkehrenden Vorlagen' docs/plan/adr/0020-emittierte-modul-15-regeln.md    # 1
```

Die Differenz ist keine Schlamperei, sondern **Alterung mit Ursache**: Die Klammer zählt die
Vorlagen-Arten, die der Kurs bei der Vertragsfassung führte; seither hat jeder Baseline-Sprung
Arten hinzugefügt (Archiv-Stubs, Beobachtung, Welle-Ergebnis …), und jede davon ist wiederkehrend
aus demselben Grund wie die ersten fünf — sie wird **je Vorgang kopiert und ausgefüllt**
([`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
[ADR-0005](0005-ziel-repo-distribution.md)). Eine Aufzählung in Rang 1 altert bei jedem Sprung
weiter; die **Eigenschaft** dahinter nicht.

**Die vierte Zahl oben misst, dass die Alterung bereits eingetreten ist.** Die Begründung zu
Festlegung (e) von [ADR-0020](0020-emittierte-modul-15-regeln.md) spricht von *„den fünf
wiederkehrenden Vorlagen"*, und der Code führt elf — die Aussage ist **heute** unrichtig, ohne dass
irgendein Vorgang sie dazu gemacht hätte. Die Datei ist `Accepted` und wird nicht nachgezogen
([`AGENTS.md`](../../../AGENTS.md) §3.4); der Ausgang für diese bestehende Differenz steht unten als
Festlegung 4 und hängt an keinem künftigen Akt.

**Der Dispatch, an dem die Entscheidung greift, führt drei Weichen und einen Default.**
`internal/emit/templates.go` überspringt eine Vorlage, wenn eine von `isRecurring`,
`isDerivativeIndex` oder `isBrownfieldOnly` zutrifft, und emittiert sie **sonst** als Singleton —
der Kopfkommentar dort sagt es wörtlich: *„Wer hier eine Vorlage nicht einträgt, entscheidet
`Singleton` — das ist die Voreinstellung."* Genau das ist die stille Stelle: Eine Vorlagen-Art, die
ein Baseline-Sprung mitbringt, fällt ohne Entscheidung in den Default und wird ins Ziel gestempelt,
ohne dass irgendetwas rot wird.

Der Plan, der diese Deckung herstellen will, bindet einen Wächter **bidirektional an die Klammer in
Rang 1** und macht darum den angenommenen Change Request zur Vorbedingung seines Starts. Damit
hängt eine Werkzeug-Zusage an einer Vertragsänderung, deren Gestalt niemand vorgeschlagen hat, und
die zweite Gestalt — die Klammer auf elf Glieder zu erweitern — altert beim nächsten Sprung erneut.

**Dieselbe ADR trägt den Präzedenzfall für den Ausweg.** Für den benachbarten Satz — die
Dokumente, die das Werkzeug dem Ziel als eigene schreibt — hält
[ADR-0020](0020-emittierte-modul-15-regeln.md) ausdrücklich fest: *„Welcher Satz das ist, ist eine
Regel und keine Aufzählung … Was driften kann, sind die Zahlen unten, nicht die Bedingung."* Für die
wiederkehrende Klasse ist bislang keine solche Setzung getroffen; die Frage steht offen, und ohne
Antwort ist der Wächter nicht schneidbar.

**Annahme, an der die Entscheidung hängt:** Der vendored Vorlagen-Baum ist auf jedem Checkout
vollständig und byte-verifiziert präsent
([`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
Kippt sie, kippt die Prüfbarkeit der Eigenschaft gegen den Satz.

## Entscheidung

Wir wählen **B — die Menge bindet als Eigenschaft gegen den vendored Satz**, in vier Festlegungen.

**Festlegung 1 — der Wächter führt **vier** Dispositionen positiv und hält sie gegen den vendored
Satz.** Neben den drei Weichen des Dispatchs (`isRecurring`, `isDerivativeIndex`,
`isBrownfieldOnly`) führt der Wächter die **Singleton-Menge als benannte Liste** in seinem eigenen
Prüfbereich — sie ist im Emitter der Default und damit dort keine Aussage, hier aber die vierte
Disposition. Geprüft wird gegen den in-scope-Teil des vendored Satzes, in zwei Richtungen:

- **Vollständigkeit:** Jede Vorlage des Satzes steht in genau einer der vier Mengen. Eine, die in
  **keiner** steht, färbt den Wächter rot, und die Meldung nennt ihren Pfad — das ist die
  Rot-Bedingung, die der Default im Emitter nicht hat.
- **Disjunktheit:** Keine Vorlage steht in **zwei** Mengen. Heute ist das unsichtbar, weil `||` im
  Dispatch kurzschließt; der Wächter sieht es, weil er jede Menge einzeln auswertet.

**Der Dispatch selbst behält seinen Default** — die Entscheidung verlangt keinen Umbau am Emitter.
Was sie verlangt, ist die **deklarierte Redundanz**: eine gepflegte Liste neben einem abgeleiteten
Bestand, deren Abweichung der Wächter meldet. Der Preis ist ein Eintrag je neuer Vorlagen-Art; er
ist repo-intern und keine Vertragsänderung, und er ist der Zweck der Übung — die Entscheidung wird
erzwungen, statt still getroffen zu werden.

**Festlegung 2 — die Aufzählung in Rang 1 bleibt Gegenstand eines Change Requests, und dieser CR
ist keine Vorbedingung für Festlegung 1.** Die Klammer sagt heute über den Bestand etwas, das nicht
gilt; das ist eine Vertragsfrage und gehört dem Auftraggeber
([`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline),
Baseline-Regelwerk `grundlagen-source-precedence.md` §Spec-Stratifizierung: weder ADR noch Slice
dürfen `LH-*` ändern). Der Wächter aus Festlegung 1 ist davon unabhängig lieferbar — er bezieht
seine Sollmenge aus dem Satz, nicht aus dem Vertrag.

**Festlegung 3 — die empfohlene CR-Gestalt ist die Eigenschaft, nicht die längere Liste.** Diese
ADR empfiehlt, die Klammer durch die Eigenschaft zu ersetzen und die Beispiele als Beispiele zu
kennzeichnen; sie **setzt** das nicht. Der Grund ist nachprüfbar: Eine erweiterte Liste ist beim
Tag ihrer Annahme richtig und altert beim nächsten Baseline-Sprung erneut — dieselbe Bewegung, die
die heutige Differenz erzeugt hat, nur eine Runde später.

**Festlegung 4 — die Zahl in der Begründung zu [ADR-0020](0020-emittierte-modul-15-regeln.md)
Festlegung (e) ist eine datierte Messung, kein Bestandteil der Entscheidung; sie wird nicht
nachgezogen, und diese ADR ist die Adresse ihrer geltenden Lesart.** *„Die fünf wiederkehrenden
Vorlagen"* nennt den Stand, den der Satz bei Abfassung jener Datei hatte; die Festlegung, die sie
stützt, sagt über die Zahl nichts — sie schließt den vendored Baum aus dem geprüften
Dokument-Satz aus, und dieser Ausschluss gilt unverändert für fünf wie für elf. Maßgeblich für die
**Menge** ist ab hier allein, was der Wächter aus Festlegung 1 gegen den vendored Satz hält.
**Kein `Supersedes`, und kein zweiter Träger:** Abgelöst wird keine Festlegung, sondern eine Zahl
in einer Begründung gelesen; und die Lesart steht **hier und nur hier** — ein zusätzlicher
Glossar-Eintrag in [`harness/conventions.md`](../../../harness/conventions.md) wäre eine zweite
Fassung derselben Aussage, und zwei Fassungen driften.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Wächter bindet die Klammer aus Rang 1 bidirektional (Plan-Stand) | die Vertrags-Aussage wird mechanisch gehalten; die Deckung zeigt auf Rang 1 | jede neue Baseline-Vorlage wird zur **Vertragsänderung**; der Wächter ist ohne angenommenen CR nicht schneidbar; die Alterung wiederholt sich beim nächsten Sprung |
| **B — vier positiv geführte Dispositionen gegen den vendored Satz, fail-closed (gewählt)** | die Sollmenge wandert mit dem Satz; eine neue Vorlagen-Art fällt nicht mehr still in den Singleton-Default, sondern färbt rot; die Disjunktheit wird überhaupt erst sichtbar; folgt dem Präzedenzfall aus [ADR-0020](0020-emittierte-modul-15-regeln.md) Festlegung (e) | eine gepflegte Liste neben einem abgeleiteten Bestand — ein Eintrag je neuer Vorlagen-Art, und die Rang-1-Aussage bleibt vorerst unrichtig, bis der CR sie einholt |
| C — nichts tun | kein Aufwand | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene über dem Gate: eine Anforderung sagt eine Deckung zu, die niemand prüft, und der nächste Zuwachs landet wieder im Default |
| D — Aufzählung in Rang 1 streichen, ohne Ersatz | die Alterung endet sofort | streichen ist selbst eine Vertragsänderung und braucht denselben CR; ohne Eigenschaft im Text verliert der Vertrag die Klasse, statt sie zu schärfen |
| E — Liste ins Technik-Stratum verschieben | fortschreibbar ohne Vertragsänderung ([`MR-019`](../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence), [ADR-0013](0013-technik-stratum-als-zielort.md)) | die Liste des Wächters aus B liegt bereits im Prüfbereich; eine zweite im Technik-Stratum wäre eine dritte Fassung derselben Menge, und Kopien driften |

## Konsequenzen

- **Positiv:** Der Wächter ist ohne fremde Vorbedingung lieferbar; ein Baseline-Sprung mit neuer
  Vorlagen-Art wird laut statt still; die stille Default-Stelle des Dispatchs bekommt einen Zeugen.
- **Positiv:** Die Vertragsfrage bleibt sichtbar offen und beim Auftraggeber, statt in einem
  Werkzeug-Slice mitentschieden zu werden; die bestehende Differenz in
  [ADR-0020](0020-emittierte-modul-15-regeln.md) hat ihren Ausgang, ohne dass eine eingefrorene
  Datei angefasst wird.
- **Negativ:** Zwischen dieser Entscheidung und dem angenommenen CR trägt Rang 1 weiter eine
  Aufzählung, die den Bestand nicht trifft. Das ist eine **benannte** Lücke, kein stilles Grün —
  aber sie ist eine.
- **Negativ:** Die Singleton-Liste ist Pflege-Aufwand und kann für sich falsch stehen: Sie sagt
  *entschieden*, nicht *richtig entschieden*.
- **Negativ:** *Kopiert-und-ausgefüllt je Vorgang* ist am Dateibaum nicht direkt messbar; prüfbar
  sind **Vollständigkeit und Disjunktheit** der Zuordnung, nicht die Richtigkeit jeder einzelnen
  Zuordnung. Diese Grenze gehört in die Meldung des Wächters, nicht in einen Kommentar daneben.
- **Folgepflicht 1:** Der umsetzende Plan trennt die zwei Hälften — Eigenschafts-Wächter
  (lieferbar) von Aufzählungs-Nachzug (CR-abhängig) — und führt den CR nicht mehr als
  Start-Trigger des ganzen Slice.
- **Folgepflicht 2:** Wählt der Auftraggeber die längere Liste statt der Eigenschaft, trägt der
  CR-Vorgang selbst, dass die neue Aufzählung ihren Mess-Stand nennt; für
  [ADR-0020](0020-emittierte-modul-15-regeln.md) folgt daraus nichts mehr — Festlegung 4 hat ihre
  Lesart gesetzt.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test über `internal/emit` | **Vollständigkeit:** jede in-scope-Vorlage des vendored Satzes steht in genau einer der vier geführten Mengen (wiederkehrend · derivativer Index · brownfield-only · Singleton-Liste des Wächters); eine Vorlage in keiner Menge bricht den Test fail-closed, und die Meldung nennt ihren Pfad | `make test` |
| Go-Test über `internal/emit` | **Disjunktheit:** keine Vorlage steht in zwei Mengen — jede Menge wird einzeln ausgewertet, nicht über die kurzschließende `||`-Kette des Dispatchs | `make test` |
| `test/mutations/` | **Rot 1:** ein Fall legt eine Vorlage in den geprüften Satz, die in keiner der vier Mengen steht — der Wächter fällt mit ihrem Pfad in der Meldung. **Rot 2:** ein Fall trägt einen Namen der Singleton-Liste **zusätzlich** in `isRecurring` ein — der Wächter fällt an der Disjunktheit. **Rot 3:** ein Fall **tauscht** einen Namen in `isRecurring` gegen einen anderen aus dem Satz — der Wächter fällt zweifach, an Vollständigkeit und Disjunktheit, und nicht an einer Zahl | `make mutate` |

**Drei Rot-Bedingungen, alle am heutigen Dispatch herstellbar** — keine verlangt einen Umbau des
Emitters, weil die vierte Menge beim Wächter liegt und nicht im `else`-Zweig.
**Was die Funktion nicht misst, und das gehört dazu:** ob eine Zuordnung *inhaltlich* richtig ist.
Eine Vorlage, die fälschlich in der Singleton-Liste steht, ist zugeordnet und bleibt grün. Diese
Grenze bleibt Urteil beim Schreiben — ein Sensor, der sie behauptete, wäre
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene
tiefer.

## Re-Evaluierungs-Trigger

- Der Change Request zu
  [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ist
  angenommen — dann ist zu prüfen, ob Festlegung 2 noch einen Gegenstand hat und ob Festlegung 3
  ihre Folgepflicht ausgelöst hat.
- Ein Baseline-Sprung bringt eine Vorlagen-Art, die in keine der vier Mengen sinnvoll fällt —
  dann ist die Dispositions-Achse selbst neu zu schneiden statt die Liste zu erweitern.
- [ADR-0020](0020-emittierte-modul-15-regeln.md) wird aus anderem Anlass durch eine Folge-ADR mit
  `Supersedes` abgelöst — dann ist zu prüfen, ob Festlegung 4 noch einen Gegenstand hat.
- Das Technik-Stratum bekommt aus anderem Anlass eine Sektion über den Vorlagensatz — dann ist
  Option E erneut zu wägen, weil ihr Contra (weitere Fassung) dann nicht mehr zuträfe.

### Acceptance-Trigger

**Eine erneute Runde der prüfenden Rolle bestätigt, dass die blockierenden Befunde der ersten Runde
behoben sind** — Reviewer-Runde zur Gruppierung der dreizehn Go-Slices, zweiter Durchgang. Die
Nachmessung durch den Kontext, der die Befunde aufgelöst hat, ist ausdrücklich **kein** Beleg
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2). Die
Accept-Zeile der §Geschichte nennt diese Runde bei ihrer Kennung.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-17 | Proposed | Architect-Verdikt zur Gruppierung der Go-Slices, Rolle Architect |
| 2026-09-17 | Befunde der ersten Review-Runde eingearbeitet (Festlegung 1 neu gefasst, Festlegung 4 ergänzt, Fitness Function auf herstellbare Rot-Bedingungen gezogen), Status bleibt `Proposed` | Review-Runde zur Gruppierung der dreizehn Go-Slices, erster Durchgang |
