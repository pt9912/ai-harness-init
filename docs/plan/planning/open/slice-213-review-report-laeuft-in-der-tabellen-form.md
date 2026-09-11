# Slice slice-213: Das Volumen eines Review-Reports hängt an einer Zellengrenze statt an einem Auftragstext

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die mehr beobachtet als die DoD dieses
Slice — ein Trigger wie *„die Regel steht"* wäre die Abschrift der eigenen DoD. Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind der Anweisungssatz und die Gate-Konfiguration
**dieses** Repos. Was ein emittiertes Repo an Modulen bekommt, entscheidet
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
und nicht diese Datei.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Regel, unter der **jede** Datei ihres Prüfbereichs fällt, ist kein Gate, sondern dauerhaftes Rot —
der Cutoff in §1 ist die Antwort darauf),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (jede Messung unten läuft
gegen den in [`d-check.mk`](../../../../d-check.mk) gepinnten Digest, netzlos, Mount `:ro`),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (der
Anweisungssatz [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) gehört der
**Reviewer**-Rolle — dieser Slice plant seine Änderung, er schreibt sie nicht),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(*„Gate-Anheben → Steering-Loop"* — der Weg, den diese Aktivierung nimmt, und der Grund, warum sie
**kein** ADR braucht; [`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet Senkungen),
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) (`structure`
liegt seit diesem Pin im Bild und ist **verfügbar, nicht aktiviert** — dieser Slice aktiviert es),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert),
[`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
(warum die Abschnitts-Bilanz der Vorab-Messung hier **nicht** wiederholt wird, §1).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind ein
Rollen-Anweisungssatz und eine Gate-Konfiguration).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-11.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Findings-Abschnitt **und** der Negativbefund-Abschnitt eines Review-Reports laufen als
Tabelle, und je eine `structure`-Regel in [`.d-check.yml`](../../../../.d-check.yml) deckelt ihre
tragende Zelle über `cell-max-chars`. Der Deckel liegt damit im Gate, das jeder Lauf fährt, statt in
einem Auftragstext, den nur der Lauf sieht, der ihn bekommt.

**Warum der Sensor den Auftragstext ablöst und nicht ergänzt.** Die bisherige Begrenzung war eine
Zeilen-Grenze im Auftrag des Orchestrators. Sie hat gewirkt — und sie trug zugleich den Satz *„keine
Negativbefund-Liste"*, der dem Anweisungssatz
[`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) §Negativbefunde (Pflicht)
widerspricht: die zwei Läufe, die ihm folgten, brachen ihre eigene Rollen-Norm. Ein Auftragstext ist
kein Träger — er lebt in einem Lauf und ist zwischen Läufen nicht haltbar. Mit diesem Slice ist die
Zeilen-Grenze im Auftrag **hinfällig**; begrenzt wird die Zelle, und die Negativbefund-**Pflicht
bleibt in Kraft**.

### Der Bestand ist gemessen

```sh
ls docs/reviews/*.md | wc -l                                      # 345
wc -l docs/reviews/*.md | head -n -1 \
  | awk '{s+=$1;n++; if($1>m)m=$1} END{printf "%d %d %.0f %d\n",n,s,s/n,m}'
#   345 Reports, 111070 Zeilen, Schnitt 322, max 1019
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit jedem Report.

**Dass Findings und Negativbefunde die zwei größten Posten sind, steht in der Vorab-Messung; ihre
Zahlen stehen hier nicht.** Die Abschnitts-Bilanz dort ist über den 20 jüngsten Reports gemittelt
und trägt **kein** reproduzierendes Kommando; eine Stellen-Messung trägt keine Folgerung über den
Bestand ([`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)),
und eine Zahl ohne Kommando ist nach
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
hier nicht führbar. Die **Auswahl der zwei Abschnitte** ist damit begründet, ihr Anteil ist es
nicht — das Nachmessen über dem ganzen Bestand steht als Risiko in §6.

### Der Mechanismus ist rot gesehen, gegen eine Kopie außerhalb des Repos

`structure.table.column.cell-max-chars` adressiert die Spalte über ihren **Kopfzeilen-Namen**.
Gegen den in [`d-check.mk`](../../../../d-check.mk) gepinnten Digest
(`sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`), netzlos, Mount `:ro`:

```sh
docker run --rm --network none -v <kopie>:/repo:ro \
  "ghcr.io/pt9912/d-check@$DIGEST" --config /repo/.d-check.yml --enable structure
```

| Eingabe | Ausgang |
|---|---|
| Tabelle, alle Zellen unter der Grenze | still |
| Tabelle, eine Zelle bei 599 Zeichen | `section-cell-oversized` auf **ihrer** Zeile, Spaltenname und Zeichenzahl in der Meldung |
| `## Findings` in der Bestandsform (H3-Blöcke, keine Tabelle) | `section-column-missing` |

**Exit-Code 1** — ein Gate-Signal, kein Advisory. Die Grenze der Sonde ist ihr Ort: sie lief gegen
eine Kopie, nicht gegen diesen Baum. Die DoD verlangt das Rot **im Repo**.

Die Regel, über der diese drei Ausgänge entstanden — der Stand der Vorab-Messung, nicht die
Fassung, die dieser Slice schreibt (§3a Wahl 2 schneidet den vierten Glob extensional, §3a Wahl 4
lässt den Wert der zweiten Regel messen):

```yaml
structure:
  - files: "docs/reviews/*.md"
    section-pattern: '^## Findings$'
    sections: each
    non-empty: true
    exempt-paths: [ … drei Datums-Globs, ein vierter für die Datei ohne Datums-Präfix … ]
    table:
      column:
        - name: Befund
          cell-max-chars: 400
          cell-min-chars: 1
```

Der Spaltenname `Befund` ist die Kopplung an DoD (1): Er muss die Kopfzeile treffen, die der
Anweisungssatz vorschreibt — die Konfiguration folgt der Skill-Datei, nicht umgekehrt.

### Der Cutoff ist die Bedingung der Aktivierung, nicht ihr Zubehör

Ohne `exempt-paths`, gegen den echten Bestand (`git archive HEAD docs/reviews`):

```
345 Datei(en) geprueft
  240  section-column-missing     ## Findings ohne Befund-Spalte
  109  section-missing            gar kein ## Findings / ## Befunde
```

**Jeder** der 345 Reports fällt — eine Regel in diesem Zustand ist kein Gate, sondern die Erziehung
dazu, Rot zu überlesen
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
Ebene tiefer, wörtlich dieselbe Begründung, die der `scan.ignore`-Kommentar in
[`.d-check.yml`](../../../../.d-check.yml) für seinen einen Eintrag führt). Mit einem
`exempt-paths`-Block aus drei Datums-Globs und einem vierten für die eine Datei ohne Datums-Präfix:

```
347 Datei(en) geprueft, 1 Befund(e)
docs/reviews/2026-09-12-rot.md:7  section-cell-oversized
```

344 der 345 werden von den Datums-Globs getroffen; die 345. heißt `slice-039-review.md`.

### Die zweite Regel ist geplant, nicht gemessen

Für den Negativbefund-Abschnitt liegt **keine** Messung vor — weder Grenzwert noch Cutoff noch
`section-pattern`. Und der Abschnitt trägt keinen einheitlichen Überschriften-Text, was die
Form-Frage schärft:

```sh
grep -rhoE '^#{2,3} .*[Nn]egativbefund[a-zä-ü]*.*$' docs/reviews/*.md | sort | uniq -c | sort -rn | wc -l   # 13
grep -rlE '^#{2,3} .*[Nn]egativbefund' docs/reviews/*.md | wc -l                                            # 261
grep -rhoE '^## Findings$' docs/reviews/*.md | wc -l                                                        # 229
```

**Keine Erwartungswerte** — alle drei wandern. Tragend ist, dass die gemessene Findings-Regel auf
ein **Literal** zielt (`^## Findings$`), während für den Negativbefund-Abschnitt erst zu messen ist,
welches Muster trägt und welcher Cutoff dahinter bleibt. Das ist DoD (2), keine Annahme.

### Ausdrücklich NICHT in diesem Slice — je Punkt mit Begründung

- **Der Spaltenschnitt der zwei Tabellen wird hier nicht festgelegt.** Welche Spalten eine
  Finding-Zeile und welche eine *„geprüft, ohne Befund"*-Zeile trägt, ist eine Entscheidung der
  **Reviewer**-Rolle ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
  Dieser Plan ist das **Übergabe-Artefakt**, nicht die Entscheidung; er benennt sie als DoD (1).
  *(Klasse: andere Rolle — es wäre ein anderer Vorgang.)*
- **Kein Adaptions-Eintrag für die Aktivierung von `structure`.** Den Adaptions-Block schreibt der
  **Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). Die **Form**
  dieser Buchung — neuer Eintrag oder die Feststellung, dass eine Modul-Aktivierung überhaupt keine
  Abweichung ist — entscheidet [slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md).
  **Die Adresse nimmt die Sendung nur unter einer Bedingung an:** slice-212 misst extensional gegen
  `planning` und `targets`; schließt er **vor** diesem Slice, trägt seine Entscheidung die Form, aber
  nicht diese dritte Aktivierung. Der Fall steht als Risiko in §6.
  *(Klasse: anderer Vorgang, andere Rolle.)*
- **Keine Änderung an der emittierten Doc-Gate-Startkonfiguration**
  (`internal/emit/templates/d-check.yml`). Welche Module ein Zielrepo bekommt, entscheidet
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  — dieser Slice **ist** die dort verlangte Erprobung im Dogfood, nicht ihr Ergebnis.
  *(Klasse: Schicht-Abgrenzung, Dogfood gegen emittiert.)*
- **Kein Umbenennen und kein Nachziehen des Report-Bestands.** `docs/reviews/**` sind
  Zeitdokumente; ein Umzug bräche eingehende Verweise, und die Beobachtung
  [`rollen-report-namensformen-nicht-disjunkt`](../observations/BEO-ALL/rollen-report-namensformen-nicht-disjunkt/observation.md)
  hält für ihren Stand bereits fest, dass der Bestand nicht umbenannt wird. Der Cutoff **nimmt ihn
  auf**, statt ihn anzufassen. *(Klasse: Bestand bleibt bewusst stehen.)*
- **Keine Grenze über den Report als Ganzes.** Der Sensor deckelt die **Zelle**; eine Zeilen- oder
  Byte-Grenze über die Datei ist eine andere Fähigkeit und keine Spalte. Was dadurch offen bleibt —
  Prosa um die Tabellen herum —, steht als Risiko in §6, nicht als Zusage.
  *(Klasse: anderer Vorgang.)*

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3). Gezählt ist nur, was mit dem Umfang wächst.

- [ ] **(1) Beide Abschnitte laufen als Tabelle, geschrieben von der Reviewer-Rolle.**
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) führt den
      Findings-Abschnitt als Tabelle — die sechs Felder des heutigen `## Output-Schema (pro Finding)`
      (`kategorie · quelle · pfad · befund · verifizierbar · klasse`) als Spalten — und
      `## Negativbefunde (Pflicht)` **unverändert als Pflicht**, in Tabellenform mit einer Zeile je
      geprüftem Bereich. Der Spaltenschnitt beider Tabellen und die Frage, ob
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      in der Zellen-Form einlösbar ist (Kommando als Inline-Code neben der Zahl), sind **dort**
      entschieden. **Eigener Commit, Rolle in der Message** — ablesbar an `git log --stat`.
- [ ] **(2) Zwei `structure`-Regeln in [`.d-check.yml`](../../../../.d-check.yml), `structure` in
      `modules:`, grüner Start über dem unveränderten Bestand.** Je eine Regel über
      `docs/reviews/*.md` für den Findings- und den Negativbefund-Abschnitt, jede mit eigener Spalte,
      eigenem `cell-max-chars` und eigenem `exempt-paths`-Cutoff. Für die **zweite** Regel sind
      `section-pattern`, Grenzwert und Cutoff **am Bestand gemessen**, nicht von der ersten
      abgeschrieben (§1, letzter Messblock). `make docs-check` läuft danach über dem unveränderten
      Report-Bestand mit **0 Befund(e)**, und der Lauf steht im Umsetzungs-Commit.
- [ ] **(3) Das Gegenbeispiel ist im Repo rot gesehen, und die Verdrahtung hat einen Zahn.**
      Je Regel einmal: eine Report-Datei im Arbeitsbaum mit einer Zelle über der Grenze färbt
      `make docs-check` rot (`section-cell-oversized`, Spaltenname und Zeichenzahl in der Meldung) —
      **kein** Sondenlauf gegen eine Kopie außerhalb, und die Datei bleibt nicht liegen. Dauerhaft
      gehalten wird die Regel-Verdrahtung von einem Fall unter `test/mutations/`, der ihr die Zähne
      nimmt; Vorbild der Form ist `test/vcs-modul-wiring.bats` neben seinen Fällen unter
      `test/mutations/`, die denselben `.d-check.yml`-Block treffen.

Standard-Punkte der Vorlage (nicht slice-eigen, zählen nicht zur Drei):

- [ ] `make gates` grün · `make mutate` ohne Befund.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      ([`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md)) — kein Self-Review
      (Modul 8). **Der Review dieses Slice läuft bereits in der neuen Form** und ist damit zugleich
      ihre erste Anwendung.
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) bekommt den Absatz
      *„Was das Modul `structure` in `docs-check` deckt, und was nicht"* — dieselbe Form wie für
      `planning` und `closure`; die Grenzen aus §6 stehen dort als Grenzen, nicht als Zusagen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder *keine Beobachtung
      angefallen* in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — Repo ohne Wellen-Betrieb,
      also hier geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) | update — **Reviewer-Rolle**, eigener Commit | DoD (1): `## Output-Schema (pro Finding)` und `## Negativbefunde (Pflicht)` in Tabellenform; `## Ablage` nennt die Struktur und zieht mit |
| [`.d-check.yml`](../../../../.d-check.yml) | update | DoD (2): `structure:`-Block mit zwei Regeln, `structure` in `modules:` |
| `test/` (Verdrahtungs-Fall) | neu | DoD (3): die Felder beider Regeln gegen Regression, ohne Docker-Lauf |
| `test/mutations/` | neu | DoD (3): der Zahn, der dem Verdrahtungs-Fall die Zähne nehmen lässt — Antwort auf [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) |
| [`harness/README.md`](../../../../harness/README.md) | update | Deckungs-Absatz des neuen Moduls samt seiner Grenzen |
| [`harness/conventions.md`](../../../../harness/conventions.md) und [`harness/conventions/`](../../../../harness/conventions/) | **unverändert** | Architect-Artefakte (§1 Abgrenzung, [`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| `internal/emit/templates/d-check.yml` | **unverändert** | Ebene emittiert (§1 Abgrenzung, [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)) |

## 3a. Umsetzungsplan

> Dieser Abschnitt steht **nicht** in der Vorlage. Er ist der **zweite** Durchlauf eines
> Versuchs, den der Auftraggeber am 2026-09-11 angeordnet hat (erster:
> [slice-071](../next/slice-071-bilanz-nennt-ihren-bestand.md) §3a); die Schwelle dieses Repos für
> eine Norm liegt bei 3×.

### Offene Wahlen

**Wahl 1 — läuft die Regel am geteilten Durchsetzungspunkt oder am advisory Target?**
`d-check.mk` führt bereits `doc-structure` als Ziel ohne Gate-Versprechen (gelistet in
`targets.exempt-targets` der [`.d-check.yml`](../../../../.d-check.yml)); die Alternative ist die
Aufnahme in `modules:`, womit die Regel in `make docs-check` und damit in `make gates` fährt.

- **Advisory `doc-structure`.** *Erreicht:* die Regel liegt im Repo, ohne dass ein Fehlalarm
  `make gates` blockiert; der Cutoff darf nachreifen. *Sieht nicht:* niemand fährt sie. Ein Sensor
  ohne Durchsetzungspunkt ist Feedforward — genau der Zustand, den dieser Slice ablöst, nur mit
  einem anderen Namen als *Auftragstext*.
- **Aufnahme in `modules:`.** *Erreicht:* jeder Lauf trägt den Deckel; ein Report, der die Form
  bricht, färbt rot, und der Review dieses Slice ist bereits sein erster Testfall. *Sieht nicht:*
  jeder `docs-check`-Lauf öffnet fortan auch jede Report-Datei, auch wenn die auslösende Änderung
  mit `docs/reviews/` nichts zu tun hat — dieselbe Kosten-Aussage, die
  [`harness/README.md`](../../../../harness/README.md) für `closure` bereits führt.

**Entscheidung: Aufnahme in `modules:`.** Der Auftrag ist ausdrücklich *ein Träger statt eines
Auftragstexts*. Ein advisory Target wäre derselbe trägerlose Zustand unter neuem Namen. Dieses Repo
hat **einen** Durchsetzungspunkt; ein zweites Profil wäre ein zweiter Ort, an dem dieselbe
Modul-Config driften kann.

**Wahl 2 — übernimmt der Cutoff die vier Globs der Vorab-Messung wörtlich, oder wird der vierte
extensional geschnitten?** Drei der vier sind Datums-Globs und enden mit dem Tag der Messung; der
vierte (`docs/reviews/slice-*.md`) nimmt die eine Datei ohne Datums-Präfix auf.

- **Wörtlich vier Globs.** *Erreicht:* den gemessenen Zustand — 347 geprüft, 1 Befund; kein
  Nachmessen nötig. *Sieht nicht:* der vierte Glob ist **prospektiv offen**. Jeder künftige Report,
  der wieder ohne Datums-Präfix benannt wird, fällt dauerhaft aus dem Prüfbereich — und genau diese
  Kollision führt
  [`rollen-report-namensformen-nicht-disjunkt`](../observations/BEO-ALL/rollen-report-namensformen-nicht-disjunkt/observation.md)
  als offene Beobachtung.
- **Vierter Glob extensional auf die eine Datei.** *Erreicht:* der Cutoff nennt den Bestand, den er
  ausnimmt, und wächst nicht still mit. Präzedenz im selben Repo: der `scan.ignore`-Eintrag ist
  *„EXTENSIONAL GESCHLOSSEN auf genau diese eine Datei"*
  ([`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)). *Sieht nicht:* die
  Vorab-Messung ist damit nicht mehr wörtlich gedeckt — der grüne Start ist neu zu fahren.

**Entscheidung: extensional.** Ein Ausnahme-Glob, der eine **Form** statt eines **Bestands** nennt,
ist kein Cutoff, sondern eine dauerhafte Lücke; dieses Repo hat für genau diese Unterscheidung
bereits eine angenommene Entscheidung. Dass die Messung dadurch neu zu fahren ist, kostet nichts,
weil DoD (2) den grünen Start ohnehin im Repo verlangt.

**Wahl 3 — deckelt jede Regel eine Spalte oder mehrere?**

- **Eine Spalte je Regel** (die tragende: `befund` bzw. ihr Gegenstück im Negativbefund-Abschnitt).
  *Erreicht:* genau die Zelle, in der das Volumen gemessen wurde; jede Zahl der Regel hat ein
  Kommando hinter sich. *Sieht nicht:* Prosa, die in eine Nachbarspalte ausweicht (`klasse`,
  `quelle`).
- **Mehrere Spalten je Regel.** *Erreicht:* kein Ausweichen. *Sieht nicht:* jede zusätzliche Spalte
  bräuchte ihre **eigene** gemessene Grenze; eine gesetzte statt gemessene Zahl ist nach
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  keine, und sie erzeugt Fehlalarme in Spalten, deren Bestand niemand angesehen hat.

**Entscheidung: eine Spalte je Regel.** Das Ausweichen ist ein **benanntes Risiko** (§6), kein
ungemessener zweiter Deckel. Eine Regel darf schmaler sein als die Sorge, die sie auslöst — sie darf
nur nicht behaupten, breiter zu sein.

**Wahl 4 — tragen beide Regeln denselben Grenzwert?**

- **Ein gemeinsamer Wert.** *Erreicht:* eine Zahl statt zweier, symmetrische Regeln. *Sieht nicht:*
  die zwei Abschnitte sind nicht dieselbe Sache — eine Finding-Zelle trägt Beobachtung und Beleg,
  eine *„geprüft, ohne Befund"*-Zelle trägt einen Bereichsnamen. Ein von der ersten abgeschriebener
  Wert wäre eine Zahl ohne eigenes Kommando.
- **Je ein eigener Wert.** *Erreicht:* jede Grenze steht neben der Messung, die sie erzeugt hat.
  *Sieht nicht:* zwei Zahlen sind zwei Pflegestellen, und keine von beiden hat einen Wächter über
  ihrer Höhe.

**Entscheidung: je ein eigener Wert — und nur einer von beiden steht heute.** Für die
Findings-Regel ist `cell-max-chars: 400` gemessen (still über der Sonde, rot bei 599). Für die
Negativbefund-Regel wird der Wert **in der Umsetzung gemessen**, nicht hier gesetzt; ihn abzuschreiben
wäre genau die Klasse, die
[`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
führt. Das ist eine Entscheidung über das **Verfahren**, keine Vertagung: DoD (2) nennt es.

**Wahl 5 — wie wird das Gegenbeispiel im Repo haltbar?**

- **Fixture-Report im Prüfbereich.** *Erreicht:* echtes Rot in einem echten Gate-Lauf, jederzeit
  nachvollziehbar. *Sieht nicht:* ein absichtlich roter Report unter `docs/reviews/` hielte
  `make gates` **dauerhaft** rot — dieselbe Fehlform, die der `scan.ignore`-Kommentar als
  *„erzieht dazu, Rot zu überlesen"* benennt. Ein Ausnahme-Eintrag dafür wäre eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 mit eigener ADR.
- **Verdrahtungs-Fall plus `test/mutations/`-Zahn.** *Erreicht:* die Felder beider Regeln sind gegen
  Regression gehalten, hermetisch und ohne Docker-Lauf (Vorbild `test/vcs-modul-wiring.bats`), und
  `make mutate` meldet, wenn der Wächter seine Zähne verliert. *Sieht nicht:* er prüft die
  **Konfiguration**, nicht dass d-check über ihr rot wird — das Rot selbst bleibt ein Lauf, den der
  Umsetzungs-Commit protokolliert.

**Entscheidung: Verdrahtungs-Fall plus Zahn, und das Rot als protokollierter Lauf im Repo.** Beide
Hälften sind nötig und keine ersetzt die andere: DoD (3) verlangt darum **beides** — das einmalige
Rot im Arbeitsbaum dieses Repos und die dauerhafte Listung im Mutations-Satz.

### Was ausdrücklich keine Wahl ist

- **Wer [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) schreibt.**
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) ist angenommen und
  damit nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 bindend: die **Reviewer**-Rolle, in einem
  eigenen Commit. Ein Implementations-Lauf, der die Datei mitnimmt, ist der Fall, den
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  als verkörperte Regel führt.
- **Dass DoD (1) vor DoD (2) liegt.** `structure` adressiert eine Spalte über ihren
  **Kopfzeilen-Namen**; der Name entsteht im Anweisungssatz. Die Konfiguration folgt der Skill-Datei,
  nie umgekehrt — sonst schriebe die Gate-Config das Urteil einer fremden Rolle vor.
- **Kein ADR für diese Anhebung.** [`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet **Senkungen**;
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  führt *„Gate-Anheben → Steering-Loop"*. Der Weg ist der Lerneintrag der Closure, nicht eine
  Entscheidung.
- **Die Negativbefund-Pflicht selbst.** Sie bleibt — entschieden vom Auftraggeber am 2026-09-11.
  Offen ist allein ihre **Spaltenform**, und die gehört der Reviewer-Rolle (§1 Abgrenzung).
- **Die Ablage-Form der Reports** (`docs/reviews/<YYYY-MM-DD>-<gegenstand>.md`) bleibt unberührt;
  der Cutoff nimmt den Bestand auf, statt ihn zu bewegen.

## 4. Trigger

**Start** (`next` → `in-progress`): Der Slice ist priorisiert (`open → next` vollzogen,
`Verantwortlich:` gesetzt) und das WIP-Limit des Rolleninhabers ist frei.

**Rückführungen — vorab benannt:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung der zweiten Regel aus
  DoD (2) einen **eigenen** Bestands- und Cutoff-Durchgang verlangt, der den Slice über mehr als
  eine Review-Sitzung dehnt. Schnitt dann je Abschnitt einer — die Findings-Regel ist gemessen und
  einzeln lieferbar.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Reviewer-Lauf den Spaltenschnitt nicht
  entscheidet (DoD (1) ohne Träger), **oder** wenn `structure` über dem echten Bestand einen Befund
  liefert, den kein extensionaler Cutoff auffängt, ohne eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 zu sein — dann Carveout statt stiller Ausnahme.

## 5. Closure-Trigger

Zwei beobachtbare Kriterien und ein Lerneintrag:

1. `make gates` ist grün **mit** aktiviertem `structure` über dem unveränderten Report-Bestand, und
   `make mutate` meldet keinen Befund.
2. Das Rot ist im Repo gesehen — je Regel einmal `section-cell-oversized`, Lauf im Umsetzungs-Commit
   protokolliert — und der neue `test/mutations/`-Fall fällt, wenn ihm die Zähne genommen werden.
3. Closure-Notiz mit Steering-Loop-Lerneintrag in einer der drei Formen (geschärfte Regel · neuer
   Sensor · benannte Spec-Lücke). Ohne ihn ist der Slice nur abgelegt.

## 6. Risiken und offene Punkte

- **Der Deckel sieht das Ausweichen in eine Nachbarspalte nicht.** Prosa, die aus `befund` nach
  `klasse` oder `quelle` wandert, unterläuft die Grenze, ohne sie zu brechen — dieselbe Klasse, die
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  führt. — **Ausgang:** <eingetreten: slice-NNN | entfallen: Grund | weiter offen: Register>
- **Der Sensor deckelt die Zelle, nicht den Report.** Prosa **um** die Tabellen herum bleibt
  unbegrenzt, und ein Report trägt neben den zwei geregelten Abschnitten weitere, die keine Regel
  kennt: Er kann beide Deckel halten und trotzdem wachsen. — **Ausgang:** <…>
- **`exempt-paths` hat kein `exempt-expect-count`.** Nur `exempt-section-pattern` trägt einen
  Erwartungswert; die Zahl der ausgenommenen Dateien bleibt unbewacht — ein Glob, der zu viel
  aufnimmt, bleibt still. Die extensionale Form aus §3a Wahl 2 begrenzt den Schaden, sie behebt ihn
  nicht. — **Ausgang:** <…>
- **Die Tabellen-Form verdrängt den eingebetteten Code-Block im Befund.** Die Vorab-Messung führt
  Reports, die im Findings-Abschnitt Fences tragen, und es sind ihre längsten; eine Zahl steht hier
  nicht, weil jene Bilanz kein reproduzierendes Kommando trägt (§1). Ob
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  in der Zellen-Form einlösbar bleibt (Kommando als Inline-Code neben der Zahl), ist eine
  Form-Entscheidung der Reviewer-Rolle und liegt in DoD (1). — **Ausgang:** <…>
- **Die Aktivierung vergrößert die in [slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md)
  gemessene Differenz.** Schließt slice-212 vor diesem Slice, hat die dritte Aktivierung keinen
  Adress-Träger im Adaptions-Block — der Fall, den
  [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  führt. — **Ausgang:** <…>
- **Der Anteil der zwei Abschnitte am Gesamtvolumen ist nicht über dem Bestand gemessen.** Die
  Vorab-Messung mittelt über die 20 jüngsten Reports und trägt kein reproduzierendes Kommando (§1).
  Trägt die Umsetzung die Bilanz über allen Reports nach, entfällt das Risiko; sonst bleibt die
  Auswahl der zwei Abschnitte begründet und ihr Anteil unbelegt. — **Ausgang:** <…>
- **Jeder `docs-check`-Lauf öffnet fortan den ganzen Report-Bestand.** Laufzeit-Kosten in jedem
  `make gates`, auch bei Änderungen ohne Bezug zu `docs/reviews/`. — **Ausgang:** <…>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<…>`. Auslöser: `<BEO-ALL/<slug>>`.
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen.** Berührt werden
[`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md),
[`.d-check.yml`](../../../../.d-check.yml), `test/` und
[`harness/README.md`](../../../../harness/README.md). Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt drei Sub-Areas — `*` (`ALL`),
`harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`); keiner der berührten Pfade liegt in den zwei
engeren. Die Berührung ist damit `*` (`ALL`), und sie hält die Schwelle ≥ 2 von 3
([`grundlagen-bootstrap.md`](../../../../.harness/baseline/v6.5.0/regelwerk/grundlagen-bootstrap.md#was-ist-eine-sub-area)):
Achse 1 (Konventions-Härte) — der Block trägt repo-weite Einträge; Achse 2 (Inventur-Linie) — Gate-
und Doku-Aussage sind als Paar abgleichbar; Achse 3 (Struktureller Cluster) trägt für `*`
naturgemäß nicht. **Eine feinere Ausdifferenzierung wird hier nicht vorgenommen** — sie wäre eine
Änderung der Modus-Deklaration und damit Architect-Arbeit (§1 Abgrenzung).

**Vorgelagert — offene Beobachtungen sichten.** Das Register führt

```sh
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l   # 93
```

Verzeichnisse (**kein Erwartungswert**, die Zahl wandert). Für die berührte Sub-Area `*` (`ALL`)
liegen alle Einträge im Prüfbereich; **fünf** berühren diesen Slice unmittelbar. Zähler-Stände,
gemessen:

```sh
cd docs/plan/planning/observations/BEO-ALL
for d in zusage-nennt-sensor-der-form-nicht-sieht neuer-waechter-ohne-mutations-fall \
         uebergabe-an-andere-rolle-ohne-traeger-artefakt slice-plan-umfang-waechst-ueber-umsetzung-hinaus \
         rollen-report-namensformen-nicht-disjunkt; do
  printf '%s\t%s\n' "$(ls $d/evidence/*.md | wc -l)" "$d"; done
#   11  zusage-nennt-sensor-der-form-nicht-sieht
#    4  neuer-waechter-ohne-mutations-fall
#    2  uebergabe-an-andere-rolle-ohne-traeger-artefakt
#    2  slice-plan-umfang-waechst-ueber-umsetzung-hinaus
#    1  rollen-report-namensformen-nicht-disjunkt
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. Wirkung auf diesen Plan,
je Eintrag:

- **`zusage-nennt-sensor-der-form-nicht-sieht` (11×, Stand `geplant`, Träger
  [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md)).** Weit über der
  Schwelle und bereits adressiert. Konsequenz hier: die drei Dinge, die der Sensor **nicht** sieht,
  stehen in §6 als Grenzen und in der DoD (Doku-Update) als Grenzen — nicht als Zusagen. Dieser
  Slice schneidet **keinen** eigenen Folge-Slice dafür; der Träger existiert.
- **`neuer-waechter-ohne-mutations-fall` (4×, Stand `offen`).** Über der Schwelle, ohne Sensor —
  Träger ist das Review. Konsequenz hier: DoD (3) verlangt den `test/mutations/`-Fall **als
  Bedingung**, nicht als Nachtrag.
- **`uebergabe-an-andere-rolle-ohne-traeger-artefakt` (2×, Stand `offen`).** Unter der Schwelle, und
  dieser Slice ist der Fall, in dem sie eintreten könnte: Er erklärt zwei Gegenstände zur Übergabe
  (Spaltenschnitt → Reviewer, Adaptions-Buchung → Architect). Konsequenz: **dieser Plan ist das
  Träger-Artefakt** für den ersten — eine Datei in `open/`, kein Satz in einer Closure-Notiz, die
  mit dem `git mv` Chronik wird. Für den zweiten trägt die benannte Bedingung in §1 und das Risiko
  in §6.
- **`slice-plan-umfang-waechst-ueber-umsetzung-hinaus` (2×, Stand `offen`).** Unter der Schwelle,
  und §3a ist genau die Stelle, an der sie eintreten kann. Konsequenz: §3a trägt fünf Wahlen und
  keine Wiederholung der DoD; die Grenzen stehen in §6, nicht doppelt in §3a.
- **`rollen-report-namensformen-nicht-disjunkt` (1×, Stand `offen`).** Unter der Schwelle, und der
  vierte Cutoff-Glob ist ihr Berührungspunkt — die Entscheidung in §3a Wahl 2 ist die Antwort
  darauf, den Bestand aufzunehmen, statt die Namensform zu reparieren.

**Erreicht mit diesem Slice eine dieser Beobachtungen 3×**, ist sie keine Notiz mehr, sondern eine
Lücke und braucht einen eigenen Folge-Slice — geprüft wird das bei der Closure, nicht hier: Belege
entstehen dort, nicht in der Planung.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF; ein Begründungsblock entfällt
damit. Die Sub-Area `*` (`ALL`) ist in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area als
**Greenfield** deklariert (*„Neues Repo, Doc führt, Code folgt"*, Graduation `n/a (GF)`), und dieser
Slice berührt keine Sub-Area, die dort nicht steht.
