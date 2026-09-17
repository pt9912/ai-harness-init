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

Der Plan, der diese Deckung herstellen will, bindet heute den Wächter an die **Aufzählung** und
macht darum den angenommenen Change Request zur Vorbedingung seines Starts. Damit hängt eine
Werkzeug-Zusage an einer Vertragsänderung, deren Gestalt niemand vorgeschlagen hat, und die zweite
Gestalt — die Klammer auf elf Glieder zu erweitern — trifft eine `Accepted`-ADR: Die Begründung zu
Festlegung (e) von [ADR-0020](0020-emittierte-modul-15-regeln.md) nennt *„die fünf wiederkehrenden
Vorlagen"*. Ein überschreibender Nachzug dort ist ausgeschlossen
([`AGENTS.md`](../../../AGENTS.md) §3.4).

**Dieselbe ADR trägt den Präzedenzfall für den Ausweg.** Für den benachbarten Satz — die
Dokumente, die das Werkzeug dem Ziel als eigene schreibt — hält sie ausdrücklich fest: *„Welcher
Satz das ist, ist eine Regel und keine Aufzählung … Was driften kann, sind die Zahlen unten, nicht
die Bedingung."* Für die wiederkehrende Klasse ist bislang keine solche Setzung getroffen; die
Frage steht offen, und ohne Antwort ist der Wächter nicht schneidbar.

**Annahme, an der die Entscheidung hängt:** Der vendored Vorlagen-Baum ist auf jedem Checkout
vollständig und byte-verifiziert präsent
([`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
Kippt sie, kippt die Prüfbarkeit der Eigenschaft gegen den Satz.

## Entscheidung

Wir wählen **B — die Menge bindet als Eigenschaft gegen den vendored Satz**, in drei Festlegungen.

**Festlegung 1 — der Wächter hält die Weichen gegen den vendored Vorlagen-Satz, nicht gegen die
Klammer in Rang 1.** Geprüft wird **vollständige und disjunkte** Zuordnung: Jede `*.template.md`
des vendored Satzes fällt unter genau eine der drei Dispositions-Weichen oder wird als Singleton
emittiert; eine Vorlage, die keine Weiche fasst, färbt den Wächter **fail-closed** rot. Er misst
damit die **Eigenschaft** (wird je Vorgang kopiert-und-ausgefüllt statt einmalig gestempelt) am
tatsächlich vorhandenen Satz und nicht eine Namensliste, deren Länge mit jedem Baseline-Sprung
wandert.

**Festlegung 2 — die Aufzählung in Rang 1 bleibt Gegenstand eines Change Requests, und dieser CR
ist keine Vorbedingung für Festlegung 1.** Die Klammer sagt heute über den Bestand etwas, das nicht
gilt; das ist eine Vertragsfrage und gehört dem Auftraggeber
([`MR-036`](../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline),
Baseline-Regelwerk `grundlagen-source-precedence.md` §Spec-Stratifizierung: weder ADR noch Slice
dürfen `LH-*` ändern). Der Wächter aus Festlegung 1 ist davon unabhängig lieferbar — er bezieht
seine Sollmenge aus dem Satz, nicht aus dem Vertrag.

**Festlegung 3 — die empfohlene CR-Gestalt ist die Eigenschaft, nicht die längere Liste.** Diese
ADR empfiehlt, die Klammer durch die Eigenschaft zu ersetzen und die Beispiele als Beispiele zu
kennzeichnen; sie **setzt** das nicht. Die Empfehlung hat zwei nachprüfbare Gründe: Eine erweiterte
Liste altert beim nächsten Sprung erneut, und sie stellt die Zahl-Aussage in
[ADR-0020](0020-emittierte-modul-15-regeln.md) still auf falsch, was dort nur über eine Folge-ADR
mit `Supersedes` oder eine Umdeutung im Glossar von
[`harness/conventions.md`](../../../harness/conventions.md) aufzulösen wäre. Wird trotzdem die
längere Liste gewählt, ist dieser Nachzug eine **Folgepflicht des CR**, kein Nebeneffekt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Wächter bindet die Klammer aus Rang 1 bidirektional (Plan-Stand) | die Vertrags-Aussage wird mechanisch gehalten; die Deckung zeigt auf Rang 1 | jede neue Baseline-Vorlage wird zur **Vertragsänderung**; der Wächter ist ohne angenommenen CR nicht schneidbar; die Zahl-Aussage in einer `Accepted`-ADR wird still falsch |
| **B — Eigenschaft gegen den vendored Satz, fail-closed (gewählt)** | die Sollmenge wandert mit dem Satz, ohne dass jemand eine Liste nachzieht; ein Sprung, der eine unklassifizierte Vorlage bringt, färbt laut rot statt still durchzulassen; folgt dem Präzedenzfall aus [ADR-0020](0020-emittierte-modul-15-regeln.md) Festlegung (e) | die Rang-1-Aussage bleibt vorerst unrichtig, bis der CR sie einholt — die Lücke steht offen und benannt statt geschlossen |
| C — nichts tun | kein Aufwand | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene über dem Gate: eine Anforderung sagt eine Deckung zu, die niemand prüft, und niemand merkt den nächsten Zuwachs |
| D — Aufzählung in Rang 1 streichen, ohne Ersatz | die Alterung endet sofort | streichen ist selbst eine Vertragsänderung und braucht denselben CR; ohne Eigenschaft im Text verliert der Vertrag die Klasse, statt sie zu schärfen |
| E — Liste ins Technik-Stratum verschieben | fortschreibbar ohne Vertragsänderung ([`MR-019`](../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence), [ADR-0013](0013-technik-stratum-als-zielort.md)) | eine geführte Liste neben dem vendored Satz ist eine **zweite Fassung** derselben Menge, und Kopien driften; der abgeleitete Wächter aus B braucht sie nicht |

## Konsequenzen

- **Positiv:** Der Wächter ist ohne fremde Vorbedingung lieferbar; ein Baseline-Sprung mit neuer
  Vorlagen-Art wird laut statt still; keine neue geführte Liste entsteht.
- **Positiv:** Die Vertragsfrage bleibt sichtbar offen und beim Auftraggeber, statt in einem
  Werkzeug-Slice mitentschieden zu werden.
- **Negativ:** Zwischen dieser Entscheidung und dem angenommenen CR trägt Rang 1 weiter eine
  Aufzählung, die den Bestand nicht trifft. Das ist eine **benannte** Lücke, kein stilles Grün —
  aber sie ist eine.
- **Negativ:** *Kopiert-und-ausgefüllt je Vorgang* ist am Dateibaum nicht direkt messbar; prüfbar
  ist die **Vollständigkeit und Disjunktheit** der Zuordnung, nicht die Richtigkeit jeder einzelnen
  Zuordnung. Diese Grenze gehört in die Meldung des Wächters, nicht in einen Kommentar daneben.
- **Folgepflicht 1:** Der umsetzende Plan trennt die zwei Hälften — Eigenschafts-Wächter
  (lieferbar) von Aufzählungs-Nachzug (CR-abhängig) — und führt den CR nicht mehr als
  Start-Trigger des ganzen Slice.
- **Folgepflicht 2:** Wählt der Auftraggeber die längere Liste, gehört der Ausgang für die
  Zahl-Aussage in [ADR-0020](0020-emittierte-modul-15-regeln.md) in denselben Vorgang —
  Folge-ADR mit `Supersedes` oder Umdeutung im Glossar von
  [`harness/conventions.md`](../../../harness/conventions.md); überschrieben wird die `Accepted`-ADR
  nicht ([`AGENTS.md`](../../../AGENTS.md) §3.4).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test über `internal/emit` | Jede `*.template.md` des vendored Satzes ist genau einer Disposition zugeordnet (wiederkehrend · derivativer Index · brownfield-only · Singleton); eine unklassifizierte Vorlage bricht den Test fail-closed, und die Meldung nennt ihren Pfad | `make test` |
| `test/mutations/` | Ein Fall **tauscht einen Namen** in der Weiche (statt einen zu entfernen) — der Wächter fällt; ein zweiter legt eine neue Vorlage in den geprüften Satz — der Wächter fällt mit ihrem Pfad in der Meldung | `make mutate` |

**Was diese Funktion nicht misst, und das gehört dazu:** ob eine Zuordnung *inhaltlich* richtig
ist. Eine Vorlage, die fälschlich als Singleton geführt wird, ist zugeordnet und bleibt grün. Diese
Grenze bleibt Urteil beim Schreiben — ein Sensor, der sie behauptete, wäre
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene
tiefer.

## Re-Evaluierungs-Trigger

- Der Change Request zu
  [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ist
  angenommen — dann ist zu prüfen, ob Festlegung 2 noch einen Gegenstand hat und ob Festlegung 3
  ihre Folgepflicht ausgelöst hat.
- Ein Baseline-Sprung bringt eine Vorlagen-Art, die keine der drei Weichen fasst, **und** die
  richtige Antwort ist eine vierte Klasse statt einer Zuordnung — dann ist die Dispositions-Achse
  selbst neu zu schneiden.
- Das Technik-Stratum bekommt aus anderem Anlass eine Sektion über den Vorlagensatz — dann ist
  Option E erneut zu wägen, weil ihr Contra (zweite Fassung) dann nicht mehr zuträfe.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-17 | Proposed | Architect-Verdikt zur Gruppierung der Go-Slices, Rolle Architect |
