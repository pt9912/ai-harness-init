# Slice slice-213: Der Review-Report läuft in der Tabellen-Form, und ein Gate hält sie

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
(jede Zahl unten steht neben dem Kommando, das sie liefert — und **kein** Grenzwert steht hier, §1),
[`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
(warum die Abschnitts-Bilanz der Vorab-Messung hier nicht wiederholt wird, §1).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind ein
Rollen-Anweisungssatz und eine Gate-Konfiguration).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-11.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Findings- und der Negativbefund-Abschnitt eines Review-Reports laufen in der
**Tabellen-Form**, und je eine `structure`-Regel in [`.d-check.yml`](../../../../.d-check.yml) hält
diese Form über `docs/reviews/*.md`. Was gehalten wird, ist die **Form** — dass die Abschnitte
Tabellen mit den vorgeschriebenen Spalten sind. Ein **Volumen-Grenzwert** wird hier **nicht**
gesetzt; er ist Gegenstand von
[slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md).

**Warum die Form vor der Grenze kommt, und nicht umgekehrt.** Die bisherige Begrenzung war eine
Zeilen-Grenze im Auftrag des Orchestrators — ein Auftragstext lebt in einem Lauf und ist zwischen
Läufen nicht haltbar; derselbe Auftrag trug den Satz *„keine Negativbefund-Liste"*, der dem
Anweisungssatz §Negativbefunde (Pflicht) widerspricht, und die zwei Läufe, die ihm folgten, brachen
ihre eigene Rollen-Norm. Diese Zeilen-Grenze ist mit diesem Slice **hinfällig**, und die
Negativbefund-Pflicht **bleibt in Kraft**: Sie wechselt die Form, nicht den Status. Der Deckel über
das Volumen kommt danach — aus einer Messung über Reports, die in dieser Form geschrieben sind, und
nicht aus einem gesetzten Wert (§1 *Warum hier kein Grenzwert steht*).

### Die Ziel-Form steht in der Baseline-Vorlage, nicht in diesem Plan

Der vendored Baum trägt die Vorlage bereits:

```sh
ls .harness/baseline/v6.7.2/templates/docs/reviews/review-report.template.md
```

Die **neue** Fassung liegt heute nur im Lab des Kurses und ist **nicht adoptiert**. Der Unterschied
ist gemessen, nicht abgeschrieben:

```sh
diff -u .harness/baseline/v6.7.2/templates/docs/reviews/review-report.template.md \
        /Development/KI/ai-harness-course/lab/templates/docs/reviews/review-report.template.md
```

Er ist **vierteilig**:

1. **Findings** wird vom H3-Block je Finding (sechs Felder als Bullet-Liste) zu **einer
   Tabellenzeile je Finding**, sieben Spalten: `ID | Kategorie | Befund | Quelle | Pfad |
   Verifizierbar | Klasse`.
2. **Negativbefunde** wird von der Bullet-Liste zur Tabelle `| Bereich | Ergebnis |`; `Ergebnis`
   trägt das feste Literal *„geprüft, ohne Befund"*.
3. Ein neuer Kommentar im Findings-Abschnitt spricht die Grenzwert-Frage direkt an (unten zitiert).
4. Kopfzeile und Zitier-Form wechseln von `slice-NN`/`slice-NNN` auf `slice-<Kennung>`. **Dieser
   vierte Teil berührt weder Tabelle noch Grenze** und reist mit der Adoption der Vorlage, nicht mit
   diesem Slice.

**Am Reviewer-Skill selbst hat sich upstream nichts geändert** — die zwei Fassungen der
Skill-Vorlage sind byte-gleich:

```sh
cmp .harness/baseline/v6.7.2/templates/.harness/skills/reviewer.template.md \
    /Development/KI/ai-harness-course/lab/templates/.harness/skills/reviewer.template.md \
  && echo byte-gleich          # byte-gleich
```

### Warum hier kein Grenzwert steht

Der neue Kommentar der Vorlage sagt es selbst:

> „Absichtlich (noch) nicht gate-geprüft: d-check `structure`
> (`table.column[].cell-max-chars`) könnte die Spalten `Befund`/`Klasse`
> zellenlängen-prüfen, **sobald genug reale Reports zeigen, welche Grenze die gelebte Praxis
> trägt** — verfrüht gesetzt, bricht sie am ersten gründlichen Befund."

Und die Bezugsmenge, aus der eine solche Grenze zu messen wäre, ist heute leer:

```sh
grep -lE '^\| *ID *\| *Kategorie *\| *Befund *\|' docs/reviews/*.md | wc -l   # 0
```

**Kein Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert, sobald der erste Report in der neuen Form entsteht; tragend ist, dass
sie **heute null** ist. Ein Grenzwert wäre damit eine Zahl ohne Kommando, gesetzt statt gemessen —
genau die Klasse, vor der die Vorlage warnt. Die Reihenfolge ist deshalb: **erst Form, dann Bestand,
dann Messung, dann Wert.** Das ist kein Vertagen: Der Übergang trägt einen beobachtbaren Trigger
(§4 von [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md)), keinen Vorsatz.

### Der Bestand ist gemessen

```sh
ls docs/reviews/*.md | wc -l                                      # 345
wc -l docs/reviews/*.md | head -n -1 \
  | awk '{s+=$1;n++; if($1>m)m=$1} END{printf "%d Reports, %d Zeilen, Schnitt %.0f, max %d\n",n,s,s/n,m}'
#   345 Reports, 111070 Zeilen, Schnitt 322, max 1019
```

**Keine Erwartungswerte** — beide Zahlen wandern mit jedem Report. **Dass Findings und
Negativbefunde die zwei größten Posten sind, steht in der Vorab-Messung; ihre Zahlen stehen hier
nicht:** Jene Abschnitts-Bilanz ist über den 20 jüngsten Reports gemittelt und trägt **kein**
reproduzierendes Kommando — eine Stellen-Messung trägt keine Folgerung über den Bestand
([`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)),
und eine Zahl ohne Kommando ist nach
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
hier nicht führbar. Die **Auswahl der zwei Abschnitte** ist damit begründet, ihr Anteil ist es nicht.

### Der Mechanismus ist rot gesehen, gegen eine Kopie außerhalb des Repos

`structure` adressiert die Spalte über ihren **Kopfzeilen-Namen**. Gegen den in
[`d-check.mk`](../../../../d-check.mk) gepinnten Digest
(`sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`), netzlos, Mount `:ro`:

```sh
docker run --rm --network none -v <kopie>:/repo:ro \
  "ghcr.io/pt9912/d-check@$DIGEST" --config /repo/.d-check.yml --enable structure
```

| Eingabe | Ausgang |
|---|---|
| Tabelle, alle Spalten vorhanden | still |
| `## Findings` in der **Bestandsform** (H3-Blöcke, keine Tabelle) | `section-column-missing` |
| Tabelle, eine Zelle über einer gesetzten `cell-max-chars` | `section-cell-oversized` auf **ihrer** Zeile, Spaltenname und Zeichenzahl in der Meldung |

**Exit-Code 1** — ein Gate-Signal, kein Advisory. **Die zweite Zeile ist das Rot dieses Slice**; die
dritte gehört [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md) und ist hier
nur aufgeführt, weil derselbe Sondenlauf sie zeigte. Die Grenze der Sonde ist ihr Ort: sie lief gegen
eine Kopie, nicht gegen diesen Baum. Die DoD verlangt das Rot **im Repo**.

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
`exempt-paths`-Block aus drei Datums-Globs und einem vierten für die eine Datei ohne Datums-Präfix
bleibt genau der eine gewollte Befund stehen — 347 geprüft, 1 Befund. **Der Cutoff bleibt
unverändert gültig**: Er nimmt den Bestand in der alten Form aus, und die alte Form ändert sich
nicht mehr.

### Die zweite Regel ist geplant, nicht gemessen

Für den Negativbefund-Abschnitt liegt **keine** Messung vor, und er trägt keinen einheitlichen
Überschriften-Text — was die Frage nach dem `section-pattern` schärft:

```sh
grep -rhoE '^#{2,3} .*[Nn]egativbefund[a-zä-ü]*.*$' docs/reviews/*.md | sort | uniq -c | sort -rn | wc -l   # 13
grep -rlE '^#{2,3} .*[Nn]egativbefund' docs/reviews/*.md | wc -l                                            # 261
grep -rhoE '^## Findings$' docs/reviews/*.md | wc -l                                                        # 229
```

**Keine Erwartungswerte** — alle drei wandern. Tragend ist, dass die Findings-Regel auf ein
**Literal** zielt (`^## Findings$`), während für den Negativbefund-Abschnitt erst zu messen ist,
welches Muster trägt und welcher Cutoff dahinter bleibt. Das ist DoD (2), keine Annahme.

### Ausdrücklich NICHT in diesem Slice — je Punkt mit Begründung

- **Kein Volumen-Grenzwert.** `cell-max-chars` setzt
  [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md), **nachdem** Reports in
  der neuen Form existieren — die Adresse nimmt die Sendung an: Sie trägt genau diesen Punkt als ihr
  Ziel und startet erst nach diesem Slice. *(Klasse: Folge-Slice mit Kennung.)*
- **Keine Nicht-Leere-Bedingung** (`non-empty`, `cell-min-chars` o. ä.) neben den Spalten. Sie wäre
  eine zweite Schärfe in demselben Schritt, und ob das Modul sie in dieser Form führt, ist nicht
  gemessen; ein Abschnitt mit Tabellenkopf und ohne Zeile bleibt damit still. Wer sie will, misst
  sie zuerst — über der Form, die dieser Slice erst herstellt. *(Klasse: es wäre ein anderer
  Vorgang.)*
- **Der Spaltenschnitt beider Tabellen wird hier nicht festgelegt** — und mit ihm nicht die
  Abweichung, die die Vorlage selbst trägt: Sie führt sieben Spalten samt `ID`, das
  `## Output-Schema (pro Finding)` des Skills führt sechs Felder ohne `ID`, und die Vorlage sagt von
  sich, sie sei *„nur gespiegelt, nicht neu definiert; bei Abweichung gilt der Skill"*. Das ist ein
  **Befund an die Reviewer-Rolle** ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)),
  kein Gegenstand dieses Plans; dieser Plan ist das **Übergabe-Artefakt**, und DoD (1) benennt die
  Entscheidung. *(Klasse: andere Rolle — es wäre ein anderer Vorgang.)*
- **Keine Entscheidung über den Vorgriff auf die nicht adoptierte Vorlage.** Ob dieses Repo einer
  Lab-Fassung vorgreifen darf und ob der Vorgriff einen Adaptions-Eintrag trägt, der bei der
  Adoption retiriert wird, ist eine **Architect**-Frage ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1) mit Präzedenz in
  diesem Repo: [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  war genau ein solcher Vorgriff und liegt heute in
  [`conventions/done/`](../../../../harness/conventions/done/). Der Plan **benennt** sie und macht
  ihr Verdikt zum Start-Trigger (§4); er entscheidet sie nicht.
  *(Klasse: anderer Vorgang, andere Rolle.)*
- **Kein Adaptions-Eintrag für die Aktivierung von `structure`.** Denselben Block schreibt derselbe
  Architect; die **Form** dieser Buchung entscheidet
  [slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md). **Die Adresse
  nimmt die Sendung nur unter einer Bedingung an:** slice-212 misst extensional gegen `planning` und
  `targets`; schließt er **vor** diesem Slice, trägt seine Entscheidung die Form, aber nicht diese
  dritte Aktivierung. Der Fall steht als Risiko in §6.
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

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3). Gezählt ist nur, was mit dem Umfang wächst.

- [ ] **(1) Beide Abschnitte laufen als Tabelle, geschrieben von der Reviewer-Rolle.**
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) führt den
      Findings-Abschnitt als Tabelle und `## Negativbefunde (Pflicht)` **unverändert als Pflicht** in
      Tabellenform (`Bereich`/`Ergebnis`-Schnitt). Dort ist auch entschieden: der Spaltenschnitt
      beider Tabellen, die `ID`-Abweichung der Vorlage gegenüber dem `## Output-Schema` (Spalte
      aufnehmen **oder** Vorlagen-Abweichung benennen) und ob
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      in der Zellen-Form einlösbar bleibt (Kommando als Inline-Code neben der Zahl).
      **Eigener Commit, Rolle in der Message** — ablesbar an `git log --stat`.
- [ ] **(2) Zwei `structure`-Regeln in [`.d-check.yml`](../../../../.d-check.yml), `structure` in
      `modules:`, grüner Start über dem unveränderten Bestand.** Je eine Regel über
      `docs/reviews/*.md` für den Findings- und den Negativbefund-Abschnitt; jede nennt **den vollen
      Spaltenschnitt aus DoD (1)** und **keinen** `cell-max-chars`. Für die zweite Regel sind
      `section-pattern` und Cutoff **am Bestand gemessen**, nicht von der ersten abgeschrieben.
      `make docs-check` läuft danach über dem unveränderten Report-Bestand mit **0 Befund(e)**, und
      der Lauf steht im Umsetzungs-Commit.
- [ ] **(3) Das Gegenbeispiel ist im Repo rot gesehen, und die Verdrahtung hat einen Zahn.**
      Je Regel einmal: ein Report im Arbeitsbaum, dessen Abschnitt die Tabellen-Form **nicht** trägt,
      färbt `make docs-check` rot (`section-column-missing`) — **kein** Sondenlauf gegen eine Kopie
      außerhalb, und die Datei bleibt nicht liegen. Dauerhaft gehalten wird die Regel-Verdrahtung von
      einem Fall unter `test/mutations/`, der ihr die Zähne nimmt; Vorbild der Form ist
      `test/vcs-modul-wiring.bats` neben seinen Fällen unter `test/mutations/`, die denselben
      `.d-check.yml`-Block treffen.

Standard-Punkte der Vorlage (nicht slice-eigen, zählen nicht zur Drei):

- [ ] `make gates` grün · `make mutate` ohne Befund.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      ([`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md)) — kein Self-Review
      (Modul 8). **Der Review dieses Slice läuft bereits in der neuen Form** und ist damit der erste
      Report der Bezugsmenge, die
      [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md) braucht.
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) bekommt den Absatz
      *„Was das Modul `structure` in `docs-check` deckt, und was nicht"* — dieselbe Form wie für
      `planning` und `closure`; die Grenzen aus §6 stehen dort als Grenzen, nicht als Zusagen, und
      **dass kein Volumen-Deckel läuft**, steht ausdrücklich darin.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder *keine Beobachtung
      angefallen* in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — Repo ohne Wellen-Betrieb,
      also hier geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) | update — **Reviewer-Rolle**, eigener Commit | DoD (1): `## Output-Schema (pro Finding)` und `## Negativbefunde (Pflicht)` in Tabellenform; `## Ablage` zieht mit |
| [`.d-check.yml`](../../../../.d-check.yml) | update | DoD (2): `structure:`-Block mit zwei **Form**-Regeln, `structure` in `modules:` — am geteilten Durchsetzungspunkt statt am advisory `doc-structure`, das niemand fährt; der Spaltenschnitt kommt aus DoD (1), weil `structure` eine Spalte über ihren Kopfzeilen-Namen adressiert und die Konfiguration damit dem Anweisungssatz folgt, nie umgekehrt |
| `test/` (Verdrahtungs-Fall) | neu | DoD (3): die Felder beider Regeln gegen Regression, ohne Docker-Lauf |
| `test/mutations/` | neu | DoD (3): der Zahn — Antwort auf [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) |
| [`harness/README.md`](../../../../harness/README.md) | update | Deckungs-Absatz des neuen Moduls samt seiner Grenzen |
| `.harness/baseline/` | **unverändert** | committet vendored Fremd-Blob; eine Vorlagen-Adoption ist ein eigener Vorgang (§1 Abgrenzung) |
| [`harness/conventions.md`](../../../../harness/conventions.md) und [`harness/conventions/`](../../../../harness/conventions/) | **unverändert** | Architect-Artefakte (§1 Abgrenzung, [`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| `internal/emit/templates/d-check.yml` | **unverändert** | Ebene emittiert (§1 Abgrenzung, [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)) |

## 4. Trigger

**Start** (`next` → `in-progress`): Der Slice ist priorisiert (`open → next` vollzogen,
`Verantwortlich:` gesetzt), das WIP-Limit des Rolleninhabers ist frei, **und das Architect-Verdikt
zur Vorgriffs-Frage aus §1 liegt vor** — entweder als Entscheidung, der nicht adoptierten Vorlage
vorzugreifen (mit oder ohne Adaptions-Eintrag), oder dadurch, dass die neue Vorlage mit einer
Re-Baseline adoptiert ist. In beiden Fällen ist die Form gedeckt; ohne eines von beiden schriebe
DoD (1) eine Form, für die keine Quelle steht.

**Rückführungen — vorab benannt:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung der zweiten Regel aus
  DoD (2) einen eigenen Bestands- und Cutoff-Durchgang verlangt, der den Slice über mehr als eine
  Review-Sitzung dehnt. Schnitt dann je Abschnitt einer — die Findings-Regel zielt auf ein Literal
  und ist einzeln lieferbar.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Reviewer-Lauf den Spaltenschnitt oder die
  `ID`-Abweichung nicht entscheidet (DoD (1) ohne Träger), **oder** wenn `structure` über dem echten
  Bestand einen Befund liefert, den kein extensionaler Cutoff auffängt, ohne eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 zu sein — dann Carveout statt stiller Ausnahme.

## 5. Closure-Trigger

Zwei beobachtbare Kriterien und ein Lerneintrag:

1. `make gates` ist grün **mit** aktiviertem `structure` über dem unveränderten Report-Bestand, und
   `make mutate` meldet keinen Befund.
2. Das Rot ist im Repo gesehen — je Regel einmal `section-column-missing`, Lauf im Umsetzungs-Commit
   protokolliert — und der neue `test/mutations/`-Fall fällt, wenn ihm die Zähne genommen werden.
3. Closure-Notiz mit Steering-Loop-Lerneintrag in einer der drei Formen (geschärfte Regel · neuer
   Sensor · benannte Spec-Lücke). Ohne ihn ist der Slice nur abgelegt.

## 6. Risiken und offene Punkte

- **Die Form ist bewacht, das Volumen nicht.** Zwischen dieser Closure und der von
  [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md) hält **nichts** die
  Länge einer Zelle — die Tabellen-Form komprimiert, sie begrenzt nicht. Der Absatz in
  [`harness/README.md`](../../../../harness/README.md) muss das als Grenze führen, sonst behauptet
  er mehr, als er hält — die Klasse, die
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  führt. — **Ausgang:** <eingetreten: slice-NNN | entfallen: Grund | weiter offen: Register>
- **Der Sensor deckelt Abschnitte, nicht den Report.** Prosa **um** die Tabellen herum bleibt
  ungeregelt, und ein Report trägt weitere Abschnitte, die keine Regel kennt: Er kann beide Formen
  halten und trotzdem wachsen. — **Ausgang:** <…>
- **Der Spaltenschnitt ist zweimal geschrieben, ohne Wächter über seine Gleichheit.** Er steht im
  Anweisungssatz und in der Gate-Konfiguration; eine Änderung an einem der beiden bleibt still, bis
  ein Report darüber stolpert. Vorbild für einen Kopplungs-Wächter liegt mit `test/sources-pin.bats`
  vor; **dass** er fehlt, gehört in die Closure-Notiz. — **Ausgang:** <…>
- **`exempt-paths` hat kein `exempt-expect-count`.** Nur `exempt-section-pattern` trägt einen
  Erwartungswert; die Zahl der ausgenommenen Dateien bleibt unbewacht — ein Glob, der zu viel
  aufnimmt, bleibt still. — **Ausgang:** <…>
- **Die Tabellen-Form verdrängt den eingebetteten Code-Block im Befund.** Die Vorab-Messung führt
  Reports, die im Findings-Abschnitt Fences tragen, und es sind ihre längsten; eine Zahl steht hier
  nicht, weil jene Bilanz kein reproduzierendes Kommando trägt (§1). Ob
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  in der Zellen-Form einlösbar bleibt, ist eine Form-Entscheidung der Reviewer-Rolle und liegt in
  DoD (1). — **Ausgang:** <…>
- **Der Vorgriff auf eine nicht adoptierte Vorlage kann bei der Adoption auseinanderlaufen.** Ändert
  sich die Lab-Fassung zwischen diesem Slice und ihrer Adoption weiter, trägt das Repo eine Form,
  die die dann vendored Vorlage nicht führt. Der vierte Diff-Teil (§1) zeigt, dass die Fassung
  ohnehin noch bewegt wird. — **Ausgang:** <…>
- **Die Aktivierung vergrößert die in [slice-212](../open/slice-212-modul-aktivierung-hat-keinen-adaptions-eintrag.md)
  gemessene Differenz.** Schließt slice-212 vor diesem Slice, hat die dritte Aktivierung keinen
  Adress-Träger im Adaptions-Block — der Fall, den
  [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  führt. — **Ausgang:** <…>
- **Jeder `docs-check`-Lauf öffnet fortan den ganzen Report-Bestand.** Laufzeit-Kosten in jedem
  `make gates`, auch bei Änderungen ohne Bezug zu `docs/reviews/`. — **Ausgang:** <…>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<…>`. Auslöser: `<BEO-ALL/<slug>>`.
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <slice-214 (Zellengrenze wird gemessen statt gesetzt) — ist eine Datei in `open/`>
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
([`grundlagen-bootstrap.md`](../../../../.harness/baseline/v6.7.2/regelwerk/grundlagen-bootstrap.md#was-ist-eine-sub-area)):
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
  Schwelle und bereits adressiert. Konsequenz hier: Dass die Form-Regel **kein Volumen** deckelt,
  steht in §6 und im Doku-Update als Grenze — nicht als Zusage. Dieser Slice schneidet **keinen**
  eigenen Folge-Slice dafür; der Träger existiert.
- **`neuer-waechter-ohne-mutations-fall` (4×, Stand `offen`).** Über der Schwelle, ohne Sensor —
  Träger ist das Review. Konsequenz: DoD (3) verlangt den `test/mutations/`-Fall als **Bedingung**.
- **`uebergabe-an-andere-rolle-ohne-traeger-artefakt` (2×, Stand `offen`).** Unter der Schwelle, und
  dieser Slice erklärt **drei** Gegenstände zur Übergabe (Spaltenschnitt und `ID`-Abweichung →
  Reviewer; Vorgriffs-Frage und Adaptions-Buchung → Architect). Konsequenz: **dieser Plan ist das
  Träger-Artefakt** — eine Datei in `open/`, kein Satz in einer Closure-Notiz, die mit dem `git mv`
  Chronik wird —, und die Vorgriffs-Frage ist zusätzlich als **Start-Trigger** verdrahtet (§4), also
  beobachtbar statt bloß benannt.
- **`slice-plan-umfang-waechst-ueber-umsetzung-hinaus` (2×, Stand `offen`).** Unter der Schwelle,
  und dieser Plan ist die Stelle, an der sie eintreten kann. Konsequenz: Der Plan führt **keinen**
  Abschnitt neben §3, der die Umsetzung ein zweites Mal beschreibt — was eine Datei-Zeile trägt,
  steht in ihrer Begründungs-Spalte, was ausgeschlossen ist in §1, und jede Grenze in §6. Die
  Teilung in zwei Slices wirkt in dieselbe Richtung.
- **`rollen-report-namensformen-nicht-disjunkt` (1×, Stand `offen`).** Unter der Schwelle; der vierte
  Cutoff-Glob ist ihr Berührungspunkt — der Cutoff nimmt den Bestand auf, statt die Namensform zu
  reparieren.

**Erreicht mit diesem Slice eine dieser Beobachtungen 3×**, ist sie keine Notiz mehr, sondern eine
Lücke und braucht einen eigenen Folge-Slice — geprüft wird das bei der Closure, nicht hier: Belege
entstehen dort, nicht in der Planung.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF; ein Begründungsblock entfällt
damit. Die Sub-Area `*` (`ALL`) ist in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area als
**Greenfield** deklariert (*„Neues Repo, Doc führt, Code folgt"*, Graduation `n/a (GF)`), und dieser
Slice berührt keine Sub-Area, die dort nicht steht.
