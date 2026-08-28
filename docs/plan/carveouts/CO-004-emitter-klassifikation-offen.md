# CO-004: Der Emitter hat für vier neue Vorlagen keine Klasse

**Status:** Aktiv.

**Datum angelegt:** 2026-08-28. **Letzte Prüfung:** 2026-08-28 (angelegt).

**Betroffenes Gate:** `test` (bats-Stufe) und damit `gates`.

**Geltungsbereich:** **zwei benannte Fälle** in `test/courseset-fixture.bats` — *„fixture:
courseSet() bildet den realen Template-Satz vollstaendig ab"* und *„fixture: der reale Satz
liefert genau N in-scope-Templates"*. **Extensional geschlossen:** jeder weitere rote Fall in
dieser oder einer anderen Datei fällt **nicht** unter diesen Carveout und ist eine eigene
Entscheidung ([`AGENTS.md`](../../../AGENTS.md) §3.5). Der dritte Fall derselben Datei — *„die
fuenf wiederkehrenden Templates existieren real"* — ist grün und bleibt es.

**Folge-Slice:** [slice-130](../planning/open/slice-130-emitter-entscheidet-jedes-neue-template.md)
— er entscheidet je Vorlage die Klasse und löst diesen Carveout mit seinem Abschluss auf.

Regeln: Baseline-Regelwerk `modul-07-carveouts.md` §Ziel-Form: Carveout — ein
Carveout braucht immer einen Auflösungs-Trigger **und** einen Folge-Slice.

---

## Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — technische Begründung, keine
„noch nicht geschafft"-Aussagen.

**Der Wächter ist rot, weil er seine Aufgabe erfüllt.** `test/courseset-fixture.bats` hält die
Emit-Fixture am realen Template-Satz fest und stellt bei jedem Zugang eine Frage, statt ihn still
durchzulassen: *„gehoert er in scope, und wenn ja, ist er Singleton oder wiederkehrend
(`emit.isRecurring`)?"* Mit dem Baum-Tausch aus
[slice-081](../planning/in-progress/slice-081-baum-tauschen-pin-ziehen.md) sind **vier** Vorlagen
neu — `observations`, `reconciliation`, `welle-results` und der Adaptions-Eintrag
der Adaptions-Eintrag `MR-NNN-titel` —, und die in-scope-Zahl geht von 17 auf 21
(`find .harness/baseline/*/templates -type f | sed 's|.*/templates/||' | grep '\.template\.md$' | grep -v '^project-readme\.template\.md$' | wc -l`).

**Das Grün ist nicht durch Nachziehen der Fixture zu haben.** Wer die vier Pfade in `courseSet()`
einträgt, färbt beide roten Fälle grün und `TestTemplates_EmittierterBestandVollstaendig` rot —
denn `emit.inScope` ist default-true, die vier würden also als gestempelte Singletons emittiert.
Wer sie daraufhin in die Erwartungsliste aufnimmt, hat die Entscheidung getroffen, ohne sie zu
treffen. Sie ist **nachweislich falsch**: `welle-results` trüge am flachen Emissions-Ort
`](../observations.md)` und der Adaptions-Eintrag `](../conventions.md#mr-<NNN>)` samt
`<tag>`-Platzhalter — beides liest das emittierte Doku-Gate
(`internal/emit/templates/d-check.yml`: `modules: [links, anchors]`, `scan.ignore` nimmt nur
`**/*.template.md`, `.tmp/**`, `.harness/**` aus). Die Zusage aus
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), der
emittierte Stand sei *„out-of-the-box gate-sicher"*, fiele damit.

**Warum die Ausnahme und nicht der Slice.** Die Entscheidung ist ein eigener Gegenstand mit
eigener Ebene: sie ändert, was ein **gebootstrapptes Zielrepo** bekommt
([`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)), berührt mit
`internal/emit/` eine Schicht, die
[slice-081](../planning/in-progress/slice-081-baum-tauschen-pin-ziehen.md) nicht führt, und wäre
dort ein vierter Liefer-Punkt — nach Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice *„zu groß"*. Das WIP-Limit von 1 verbietet zugleich, beide Slices nebeneinander
in `in-progress/` zu halten. Übrig bleibt der Weg, den dasselbe Modul ausdrücklich offenlässt:
*„Ein Slice darf bei rotem Gate nur mit dokumentiertem Carveout (Modul 7) in `done/` landen, der
den roten Gate-Status auf Trigger schaltet."*

**Werkzeug-Wahl (Modul 7 §Werkzeug-Wahl bei Diskrepanz), beide Fragen beantwortet.**
*Granularität:* eine einzelne Diskrepanz — ein Gate, zwei benannte Fälle, eine Ursache; kein
Cluster über eine Sub-Area, also keine BF-Markierung. *Temporalität:* der Trigger ist ernst
erreichbar — er hängt an genau einem Folge-Slice, der als nächster läuft; also Carveout und keine
ADR.

## Auflösungs-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — konkret und prüfbar. „Wenn Zeit ist" ist kein Trigger.

**[slice-130](../planning/open/slice-130-emitter-entscheidet-jedes-neue-template.md) liegt in
`done/`.** Damit trägt jede der vier Vorlagen eine Klasse an der Weiche in
`internal/emit/templates.go`, `TestTemplates_EmittierterBestandVollstaendig` hält den vollen
Ist-Bestand, und `make test` ist ohne Ausnahme grün. Prüfbar ohne Rückfrage: ein `ls` über
`docs/plan/planning/done/` und ein `make gates`-Lauf ohne die Konfiguration unten.

**Was den Trigger nicht auslöst:** ein grüner Lauf, der durch Anpassen der erwarteten Zahl
entstanden ist. Der Trigger fragt nach der **Entscheidung**, nicht nach der Farbe.

## Geltungs-Konfiguration

**Die Ausnahme senkt die Strenge nicht — sie macht das Rot benannt.** Die beiden Fälle bleiben
scharf: sie vergleichen weiter den vollen Ist-Bestand und die volle Zahl. Was hinzukommt, ist die
Kennung in ihrer Fehlermeldung, damit der rote Lauf seinen Grund und seinen Folge-Slice nennt
statt nur einen Diff (Modul 7: *„Die Gate-Konfiguration nennt die `CO-<NNN>` im Gate-Output"*).
Ein Ausschluss der Fälle wäre eine Schwellen-Senkung und nach
[`AGENTS.md`](../../../AGENTS.md) §3.5 eine eigene Entscheidung — dieser Carveout erteilt sie
**nicht**.

| Datei | Zeile/Section | Wert |
|---|---|---|
| `test/courseset-fixture.bats` | Fehlermeldung des Falls *„courseSet() bildet den realen Template-Satz vollstaendig ab"* | nennt `CO-004` und den Folge-Slice; die Vergleichsmenge bleibt unverändert |
| `test/courseset-fixture.bats` | Fehlermeldung des Falls *„der reale Satz liefert genau N in-scope-Templates"* | dito; die erwartete Zahl bleibt die bisherige, bis [slice-130](../planning/open/slice-130-emitter-entscheidet-jedes-neue-template.md) sie mit der Entscheidung bewegt |

## Verifikation (nach Auflösung)


- [ ] Die `CO-004`-Nennung ist aus beiden Fehlermeldungen entfernt — die Ausnahme verschwindet mit
      ihrem Grund, statt als tote Kennung stehen zu bleiben.
- [ ] `make gates` grün ohne Ausnahme.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`).
- [ ] Index-Zeile in [`README.md`](README.md) von *Aktiv* nach *Aufgelöst* umgehängt, mit Datum und
      auflösendem Slice.
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-28 | Angelegt — der Baum-Tausch stellt dem Emitter vier unbeantwortete Klassen-Fragen | [slice-081](../planning/in-progress/slice-081-baum-tauschen-pin-ziehen.md) |
