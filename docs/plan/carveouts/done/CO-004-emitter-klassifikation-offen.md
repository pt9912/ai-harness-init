# CO-004: Der Emitter hat für vier neue Vorlagen keine Klasse

**Status:** **Aufgelöst** — der Auflösungs-Trigger ist eingetreten: jede der vier Vorlagen trägt
eine Klasse an einer Weiche in `internal/emit/templates.go`, und die zwei Fälle des
Geltungsbereichs sind grün (`make test-bats` am 2026-08-30: `1..195`, kein `not ok`). **Der
Modul-7-Vollzug steht noch aus** und ist ein eigener Commit: der `git mv` nach
`docs/plan/carveouts/done/` und der Link-Abgleich danach — Move und Inhalt gehören getrennt
([`AGENTS.md`](../../../../AGENTS.md) §3.3). Bis dahin sagt der **Ort** noch *aktiv*, während
Status und Index *aufgelöst* sagen; welche Haken unten deshalb offen stehen, sagt der Absatz
nach der Checkliste.

**Datum angelegt:** 2026-08-28. **Letzte Prüfung:** 2026-08-30 (Auflösung durch
[slice-130](../../planning/in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md):
Klassen entschieden, Wächter grün, Sensoren gefahren — s. §Geschichte). **Vorherige Prüfung:**
2026-08-29 (Closure
[slice-133](../../planning/done/slice-133-emittierter-baum-ohne-platzhalter-links.md): Deckung
unverändert, Buchhaltung nachgezogen).

**Betroffenes Gate:** `test` (bats-Stufe) und damit `gates`.

**Geltungsbereich:** **zwei benannte Fälle** in `test/courseset-fixture.bats`, hier mit dem
Wortlaut, unter dem sie auffindbar sind (`grep -n '^@test' test/courseset-fixture.bats`) —
*„fixture: courseSet() bildet den realen Template-Satz vollstaendig ab"* (Z. 59) und *„fixture:
der reale Satz liefert genau 17 in-scope-Templates"* (Z. 77). Die **17** im Fallnamen ist der
Stand vor dem Tausch und wandert mit der Entscheidung des Folge-Slice; sie steht hier, weil sie
Teil des Namens ist, nicht als Erwartungswert. **Extensional geschlossen:** jeder weitere rote
Fall in dieser oder einer anderen Datei fällt **nicht** unter diesen Carveout und ist eine eigene
Entscheidung ([`AGENTS.md`](../../../../AGENTS.md) §3.5). Die beiden anderen Fälle derselben Datei
sind grün und bleiben es: *„fixture: die fuenf wiederkehrenden Templates existieren real"* (Z. 93)
und *„fixture: courseSet() fuehrt jede Platzhalter-Pfad-Form des realen Satzes"* (Z. 165, der
Inhalts-Wächter aus
[slice-133](../../planning/done/slice-133-emittierter-baum-ohne-platzhalter-links.md)). Die
Zeilenangaben wandern mit der Datei und sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); der **Wortlaut** ist der Geltungsbereich, nicht die Zeile. Die Fall-**Nummern** des
Laufs — `not ok 40` und `not ok 41` — sind davon unberührt.

**Nicht Geltungsbereich, und die Abgrenzung ist der wichtigste Satz dieses Kopfes:** die
Befunde, die `make smoke` im **emittierten** Baum meldet — beim Anlegen zehn, am Stand `66459c7`
zwei —, fallen **nicht** unter diesen Carveout.
Sie brechen [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — Rang 1 der
Source Precedence —, und eine Rang-1-Zusage wird nicht durch einen Carveout ausgenommen, sondern
durch Reparatur eingelöst; die Begründung führt
[slice-133](../../planning/done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §1. Ihre Träger
sind zwei Slices, nicht diese Datei: **acht** Befunde hat
[slice-133](../../planning/done/slice-133-emittierter-baum-ohne-platzhalter-links.md)
weggenommen, **zwei** trägt
[slice-130](../../planning/in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md). Gemessen mit
demselben Kommando über zwei Ständen: `make smoke` am Stand `26aec2c`
`23 Datei(en) geprüft, 10 Befund(e)`, am Stand `66459c7` `23 Datei(en) geprüft, 2 Befund(e)` —
gleicher Nenner, also ist nichts aus dem Prüfbereich gefallen. **Acht statt der sieben, mit denen
der Schnitt rechnete, und der Grund ist die Bauart:** die Neutralisierung trägt die
Platzhalter-**Form** und verfügt über keine Namen, also fiel `<ziel>/harness/conventions/MR-NNN-titel.md`
mit — ein Befund der Ursache B, der dieselbe Form trug. **Der Entscheidungs-Gegenstand von
slice-130 ist davon unberührt:** die Klassen-Weichen sind über die ganze slice-133-Kette
unangetastet
(`git diff 3ea5ae2^ 66459c7 -- internal/emit/templates.go | grep -cE '^[+-][^+-].*func (inScope|isRecurring|isDerivativeIndex)'`
→ **0**), `MR-NNN-titel.template.md` wird weiterhin als Singleton emittiert, und die zwei
verbliebenen Befunde stehen beide in `<ziel>/docs/plan/planning/welle-results.md` (`:67`, `:83`).
Wer die Differenz als Regression liest, sucht einen Fehler, den es nicht gibt; wer sie als
*„schon erledigt"* liest, lässt die Klassen-Entscheidung fallen, die davon unberührt ist.

**Folge-Slice:** [slice-130](../../planning/in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md)
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
[slice-081](../../planning/done/slice-081-baum-tauschen-pin-ziehen.md) sind **vier** Vorlagen
neu — `observations`, `reconciliation`, `welle-results` und `MR-NNN-titel`, der Adaptions-Eintrag
—, und die in-scope-Zahl geht von 17 auf 21
(`find .harness/baseline/*/templates -type f | sed 's|.*/templates/||' | grep '\.template\.md$' | grep -v '^project-readme\.template\.md$' | wc -l`).

**Die vier werden heute schon emittiert — das ist gemessen, nicht vorhergesagt.** `emit.inScope`
ist default-true und wirkt am **realen** Vorlagen-Satz; `courseSet()` ist die Test-Fixture, nicht
der Emissions-Pfad. Der emittierte Bestand steht deshalb bereits auf **23** Dateien mit
**10** Befunden (`make smoke` am Stand `26aec2c`) gegen **19** Dateien und **0** Befunde über dem
Vor-Tausch-Stand (`T=$(mktemp -d); git archive c6cc56f | tar -x -C "$T"; cd "$T" && make smoke`) —
beide Zahlen wandern mit dem Vorlagen-Satz und sind **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Unter jenen zehn standen drei, die an diesen vier Vorlagen hingen — im
**gebootstrappten Zielrepo**, hier `<ziel>/`, nicht in diesem:
`<ziel>/docs/plan/planning/welle-results.md:67` und `:83` sowie
`<ziel>/harness/conventions/MR-NNN-titel.md:15`. Der dritte ist mit
[slice-133](../../planning/done/slice-133-emittierter-baum-ohne-platzhalter-links.md)
gefallen, weil sein Ziel-Pfad `<tag>` trug und die Form-Regel keine Namen kennt; **zwei** stehen
noch (`make smoke` am Stand `66459c7`), und sie tragen keinen `<…>`-Platzhalter, lösen sich also
nur über die Klasse.
Die Zusage aus
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), der emittierte
Stand sei *„out-of-the-box gate-sicher"*, **ist damit gebrochen** — und zwar unabhängig von jeder
Entscheidung dieses Carveouts. Was hier ausgenommen ist, ist der rote `test`-Gate; der
Vertragsbruch ist es **nicht** (Kopf, §Nicht Geltungsbereich).

**Das Grün ist nicht durch Nachziehen der Fixture zu haben.** Wer die vier Pfade in `courseSet()`
einträgt, färbt beide roten Fälle grün und `TestTemplates_EmittierterBestandVollstaendig` rot; wer
sie daraufhin in die Erwartungsliste aufnimmt, hat die Entscheidung getroffen, ohne sie zu treffen
— und schreibt den heutigen Ist-Zustand als Soll fest, statt ihn zu prüfen. Dass er falsch ist,
zeigen dieselben drei Befundzeilen: `welle-results` trägt am flachen Emissions-Ort
`](../../observations.md)`, `MR-NNN-titel` einen `<tag>`-Platzhalter im Baseline-Pfad. Beides liest
das emittierte Doku-Gate (`internal/emit/templates/d-check.yml`: `modules: [links, anchors]`,
`scan.ignore` nimmt nur `**/*.template.md`, `.tmp/**`, `.harness/**` aus).

**Warum die Ausnahme und nicht der Slice.** Die Entscheidung ist ein eigener Gegenstand mit
eigener Ebene: sie ändert, was ein **gebootstrapptes Zielrepo** bekommt
([`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)), berührt mit
`internal/emit/` eine Schicht, die
[slice-081](../../planning/done/slice-081-baum-tauschen-pin-ziehen.md) nicht führt, und wäre
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

**[slice-130](../../planning/in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) liegt in
`done/`.** Damit trägt jede der vier Vorlagen eine Klasse an der Weiche in
`internal/emit/templates.go`, `TestTemplates_EmittierterBestandVollstaendig` hält den vollen
Ist-Bestand, und `make test` ist ohne Ausnahme grün. Prüfbar ohne Rückfrage: ein `ls` über
`docs/plan/planning/done/` und ein `make gates`-Lauf ohne die Konfiguration unten.

**Was den Trigger nicht auslöst:** ein grüner Lauf, der durch Anpassen der erwarteten Zahl
entstanden ist. Der Trigger fragt nach der **Entscheidung**, nicht nach der Farbe.

## Geltungs-Konfiguration

**Es gibt heute keine — und anders als bei
[`CO-005`](../CO-005-adaptions-block-datierter-beleg.md) ist das kein Werkzeug-Befund, sondern ein
offener Posten.** Gemessen, nicht angenommen: `git grep -c 'CO-004\|CO-005' -- test/ .d-check.yml
Makefile` liefert **keinen Treffer**, und der rote Lauf gibt `not ok 40` / `not ok 41` ohne jede
Kennung aus. Modul 7 verlangt *„Die Gate-Konfiguration nennt die `CO-<NNN>` im Gate-Output — sonst
ist die Ausnahme eine stille Senkung ohne Begründung … sichtbar sein muss sie in jedem Fall."*
Für die bats-Stufe ist das **erfüllbar** — eine Fehlermeldung ist Text, den ein Fall schreibt.
`CO-005` steht anders da: dort trägt das Modul `links` am gepinnten Pin **keinen** Ort, an dem es
ginge. Zwei Carveouts, zwei Antworten, und der Unterschied liegt im Werkzeug, nicht in der
Sorgfalt.

**Was daraus folgt, und für wen.** Die Verdrahtung liegt in `test/courseset-fixture.bats` und ist
**Implementer**-Arbeit; dieser Carveout beschreibt sie, er stellt sie nicht her. Solange sie
fehlt, ist die Modul-7-Pflicht **offen** — die Ausnahme ist über diese Datei begründet, aber nicht
über den Gate-Output sichtbar. Der Posten ist deshalb Bedingung des Abnahme-Punktes von
[slice-081](../../planning/done/slice-081-baum-tauschen-pin-ziehen.md) §2 DoD (4) und nicht in
eine Fußnote verschoben.

**Die Ausnahme senkt die Strenge nicht.** Die beiden Fälle bleiben scharf: sie vergleichen weiter
den vollen Ist-Bestand und die volle Zahl, und die Config bleibt unberührt — `make test` bleibt
rot. Ein Ausschluss der Fälle wäre eine Schwellen-Senkung und nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5 eine eigene Entscheidung; dieser Carveout erteilt sie
**nicht**.

| Datei | Zeile/Section | Wert |
|---|---|---|
| — | — | heute keine. Die Fehlermeldungen der zwei Fälle des Geltungsbereichs (Z. 59 und Z. 77) nennen `CO-004` **nicht**; die Nennung ist möglich, aber nicht gesetzt (Begründung oben, Kommando gefahren) |

## Verifikation (nach Auflösung)


- [x] `git grep -c 'CO-004' -- test/ .d-check.yml Makefile` ist leer — gefahren 2026-08-30, Exit 1,
      keine Zeile. Die Kennung war **nie** verdrahtet (§Geltungs-Konfiguration), der Punkt ist also
      beim Anlauf schon erfüllt gewesen — und **das** ist der Befund, nicht ein Haken: die
      Modul-7-Pflicht *„die Kennung im Gate-Output"* blieb über die ganze Standzeit offen, obwohl
      sie für die bats-Stufe erfüllbar war.
- [x] `make gates` grün ohne Ausnahme — für **dieses** Gate. Gefahren 2026-08-30: die bats-Stufe
      meldet `1..195` ohne `not ok`, `make test` ist damit grün, und keine Konfiguration nimmt einen
      Fall aus. **Was daneben rot bleibt, gehört nicht hierher:** `docs-check` fällt unter
      [`CO-005`](../CO-005-adaptions-block-datierter-beleg.md) (Träger
      [slice-132](../../planning/open/slice-132-adaptions-block-ohne-totes-ziel.md)) — ein anderer Carveout,
      eine andere Ursache, und dieser hier ist extensional geschlossen (Kopf, §Geltungsbereich).
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`).
- [x] Index-Zeile in [`README.md`](../README.md) von *Aktiv* nach *Aufgelöst* umgehängt, mit Datum und
      auflösendem Slice (2026-08-30). Ihr Link zeigt auf den **heutigen** Ort; er zieht mit dem
      Move nach, im selben Zug wie die übrigen Verweise auf diese Datei.
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

**Warum zwei Haken stehen und zwei nicht — die Trennlinie ist dieselbe wie bei
[`CO-003`](CO-003-mutate-ohne-zeitschranke.md): der Ort und die Rolle.** Gehakt ist, was über
**diesem** Baum wahr ist und je mit seinem Kommando belegt. Offen ist der `git mv` — er ist ein
eigener Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3) und macht erst den Ort wahr, den der
Status-Kopf schon nennt. Offen ist ebenso der Folge-Slice:
[slice-130](../../planning/in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) liegt bei
dieser Auflösung in `in-progress/`, und seine Closure schreibt der **Planner**, nicht der Lauf, der
den Code geschrieben hat (Baseline-Regelwerk `modul-08-agentenrollen.md`). Damit steht auch die
wörtliche Trigger-Bedingung oben — *„slice-130 liegt in `done/`"* — noch aus; eingetreten und
gemessen ist die Sache, für die sie steht (die vier Klassen und der grüne Wächter), und genau die
prüft der zweite Absatz des Triggers ein.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-28 | Angelegt — der Baum-Tausch stellt dem Emitter vier unbeantwortete Klassen-Fragen | [slice-081](../../planning/done/slice-081-baum-tauschen-pin-ziehen.md) |
| 2026-08-29 | Geprüft, **nicht** aufgelöst: die Deckung ist unverändert (die zwei roten Fälle tragen weiter ihren Wortlaut, `make -k gates` hat keinen roten Fall daneben), die Buchhaltung ist nachgezogen — `8`/`2` statt `7`/`3`, verschobene Zeilenangaben, ein vierter grüner Fall in derselben Datei | [slice-133](../../planning/done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §7 |
| 2026-08-30 | **Aufgelöst, Vollzug ausstehend.** Die vier Klassen sind entschieden und stehen an den Weichen: `welle-results` und `MR-NNN-titel` wiederkehrend (`emit.isRecurring`), `reconciliation` modus-gebunden (`emit.isBrownfieldOnly`, neue Weiche), `observations` Singleton (Voreinstellung, am Weichen-Kommentar belegt). Beide Fälle des Geltungsbereichs sind grün und tragen dabei **neue Namen**: aus *„genau 17 in-scope-Templates"* wurde *„genau 21"*, aus *„die fuenf wiederkehrenden Templates existieren real"* wurde *„die sieben"* — der Wortlaut oben ist der von 2026-08-28 | [slice-130](../../planning/in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) |
