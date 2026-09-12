# Slice slice-222: Eine Sensor-Datei trägt die Form ihrer Vorlage — und ihre Existenz ist entschieden, nicht angenommen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die von der DoD dieses Slice verschieden
wäre — jeder denkbare Trigger schriebe sie ab (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(dieser Slice baut keinen Wächter über die Form; wo kein Kommando urteilt, steht es dabei) ·
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
und
[`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)
(Ausfüll-Vorlagen werden **referenziert**, nicht kopiert — der Zeiger auf die Vorlage ist DoD (2)) ·
[`AGENTS.md`](../../../../AGENTS.md) §3.8 und
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (was an
`AGENTS.md` oder den Adaptions-Block gehört, verlässt den Slice als Übergabe) ·
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie ausgibt).

**Berührte Spec-Stellen:** — (keine; die Form einer Harness-Datei trägt kein Spec-Stratum).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Jede Datei unter [`harness/sensors/`](../../../../harness/sensors) hat einen
entschiedenen Grund zu existieren — die Ziel-Form setzt die **Tabellenzeile** als Default und die
Datei als Ausnahme —, und der Baum nennt die Vorlage, aus der seine Dateien entstehen.

### Der gemessene Ausgangspunkt

Der Baum steht und trägt die Abschnitte der Vorlage; was fehlt, ist die Entscheidung darüber, für
welches Ziel er eine Datei führt, und der Zeiger auf die Form, der er folgt.

```sh
ls harness/sensors/*.md | wc -l                # 15   Dateien
grep -cE '^\| \[?`make ' harness/README.md     # 28   Ziele in den zwei Tabellen
grep -cE '^\| \[`make '  harness/README.md     # 15   davon mit verlinkter Target-Zelle
wc -c harness/sensors/*.md | sort -n | head -1 # 713  kleinste Datei
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahlen wandern mit dem Baum. Tragend ist das Verhältnis: **Dreizehn** Ziele
tragen ihren Vertrag in einer Zeile, **fünfzehn** in einer Datei, und das Kriterium, nach dem ein
Ziel in die eine oder die andere Gruppe fällt, steht in keinem lebenden Artefakt dieses Repos. Die
Ziel-Form nennt es: eine Datei entsteht, *sobald ein Vertrag mehr braucht als einen Satz* —
Deckungsgrenze, Ausgabe-Bedeutung, Exit-Codes, Sperren (Baseline-Regelwerk
`grundlagen-begriffe.md`, Zeile `harness/sensors/<target>.md`, und
`grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt).

**Die Vorlage ist in diesem Repo unbenannt.** Sie liegt vendored unter
`.harness/baseline/v6.5.0/templates/harness/sensors/`; genannt wird sie außerhalb der Baseline nur
dort, wo der **emittierte** Vorlagensatz geprüft wird, und in einem Zeitdokument:

```sh
git grep -ln 'sensors/gate.template' -- ':!.harness/baseline' ':!docs/reviews'
#   internal/emit/templates_test.go
#   test/courseset-fixture.bats
```

Beide Treffer sprechen über das, was das Werkzeug in ein Zielrepo schreibt, nicht über die eigene
Nutzung. Damit ist die Form, der die fünfzehn Dateien folgen, für den nächsten Lauf nicht
auffindbar — genau die Lage, gegen die
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
und
[`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)
den Zeiger verlangen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Modul-Zuschalten und kein Abschnitts-Selector über `harness/sensors/**`.** `structure`
  kommt mit [slice-218](../next/slice-218-harness-einstieg-behaelt-seine-index-form.md) in die
  Modul-Liste; einen Selector über eine Pflichtgliederung führt dessen §6 als Adresse eines eigenen
  Schnitts, der mit seiner Closure entsteht. Zwei Läufe an demselben Block schreiben ihn zweimal.
  *(Folge-Slice mit Kennung — sie nimmt die Sendung an.)*
- **Keine Norm-Aussage.** Der Zeiger in [`AGENTS.md`](../../../../AGENTS.md) §4 und eine
  Deklaration der Bindungs-Klassen gehören dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); sie verlassen den Slice als Übergabe-Artefakt (§7),
  nicht als Norm-Text. *(Schicht-Abgrenzung.)*
- **Keine Prosa zurück in den Einstieg.** Was
  [slice-114](../next/slice-114-jede-aussage-hat-einen-abschnitt.md) aus
  [`harness/README.md`](../../../../harness/README.md) gezogen hat, kommt nicht zurück; die Datei
  bekommt genau den einen Satz aus DoD (2) und sonst kein Byte. *(Bestand bleibt bewusst stehen.)*
- **Keine Aussage über die emittierte Ebene.** Ob ein gebootstrapptes Zielrepo einen
  `harness/sensors/`-Baum bekommt und mit welchem Inhalt, hängt am Vorlagensatz des Werkzeugs und
  ist ein eigener Schnitt mit eigener Abwägung. Gegenstand hier ist der Dogfood.
  *(Schicht-Abgrenzung, Dogfood gegen emittiert.)*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Je Ziel eine Entscheidung, und jede bleibende Datei trägt den Grund, aus dem sie
      existiert.** Für jedes Ziel der zwei Tabellen steht *Datei* oder *Zeile* mit dem Kriterium
      der Ziel-Form — mehr als ein Satz Vertrag, belegt durch mindestens eine der vier Substanzen
      (Deckungsgrenze · Ausgabe-Bedeutung · Exit-Codes · Sperren). Die Liste liegt dem
      Umsetzungs-Commit bei. Wo die Antwort *Zeile* lautet, wandert der Satz in die Zelle und die
      Datei verschwindet ersatzlos — die Ziel-Form kennt kein `sensors/done/`. **Rot färbt nur die
      halbe Zusage:** dass Datei und verlinkte Target-Zelle einander bijektiv entsprechen, misst
      ein Kommando (die zwei Zähler aus §1); ob ein Vertrag *mehr als einen Satz* braucht, ist ein
      Urteil und trägt das Review.
- [ ] **(2) Der Baum nennt seine Vorlage.** Ein lebendes Artefakt zeigt auf
      `.harness/baseline/<tag>/templates/harness/sensors/`, sodass die nächste neue Sensor-Datei
      per `cp` entsteht statt nachgebaut zu werden
      ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert),
      [`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)).
      Das Kommando aus §1 nennt danach eine Stelle außerhalb der zwei Emissions-Tests.
- [ ] **(3) Der Lauf berührt kein Artefakt einer anderen schreibenden Rolle.**
      `git log --format=%H <erster>..<letzter> -- AGENTS.md harness/conventions.md | wc -l` → **0**
      über die Commits dieses Slice. Die drei Punkte, die dorthin gehören, stehen in §7 als
      Übergabe ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
      [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1).

Standard-Punkte der Vorlage (nicht slice-eigen, zählen nicht zur Drei):

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/sensors/`](../../../../harness/sensors) | update | DoD (1): je Datei der Beleg, dass ihr Vertrag mehr als einen Satz braucht; wo er fehlt, wandert der Satz in die Zelle und die Datei entfällt |
| [`harness/README.md`](../../../../harness/README.md) | update | DoD (1) die betroffene Zelle, DoD (2) der Zeiger auf die Vorlage — die Sensors-Sektion führt den Satz über `harness/sensors/<target>.md` bereits, hier kommt seine Herkunft dazu |
| [`AGENTS.md`](../../../../AGENTS.md) | **unverändert** | §4 zeigt für die Gate-Beschreibungen weiter auf den Einstieg; die Korrektur ist Architect-Arbeit und geht als Übergabe hinaus (§7) |
| [`harness/conventions.md`](../../../../harness/conventions.md), [`harness/conventions/`](../../../../harness/conventions) | **unverändert** | Adaptions-Block, Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | kein Modul wird zugeschaltet (§1); `structure` bringt [slice-218](../next/slice-218-harness-einstieg-behaelt-seine-index-form.md) |
| [`internal/emit/templates.go`](../../../../internal/emit/templates.go) und die emittierte Ebene | **unverändert** | Dogfood-Ebene (§1) |
| [`docs/reviews`](../../../reviews), [`docs/plan/planning/done`](../done) | **unverändert** | Zeitdokumente |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-114](../next/slice-114-jede-aussage-hat-einen-abschnitt.md) liegt in `done/`.
Beobachtbar ohne Rückfrage (`ls docs/plan/planning/done/`) und **kein Ergebnis dieses Slice**. Die
Bedingung ist keine Vorsicht, sondern eine gemessene Kollision: Beide Slices schreiben an
[`harness/README.md`](../../../../harness/README.md), und der Index, den DoD (1) gegen den Baum
hält, ist dort das Ergebnis von slice-114.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Liste aus DoD (1) ergibt, dass
  mehr als eine Handvoll Dateien in ihre Zeile zurückwandern muss — dann ist die Rückführung der
  Prosa ein eigener Gegenstand mit eigener Zuordnungs-Liste, und dieser Slice trägt nur noch die
  Entscheidung und den Zeiger.
- `in-progress` → `open` (blockiert — Carveout?): wenn sich zeigt, dass das Kriterium *„mehr als
  ein Satz"* ohne eine Setzung im Adaptions-Block nicht anwendbar ist. Dann ist der Befund eine
  Norm-Lücke, sie gehört dem Architect, und der Slice wartet auf dessen Schnitt, statt sich das
  Kriterium selbst zu geben.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Die Liste aus DoD (1) ist vollständig — je Ziel der zwei Tabellen eine Antwort, und zu jeder
   Antwort *Datei* der Beleg, welche der vier Substanzen sie trägt.
2. `make gates` ist grün, und das Kommando aus DoD (2) nennt die lebende Stelle, die die Vorlage
   führt.
3. Closure-Notiz mit Steering-Loop-Lerneintrag in einer der drei Formen (geschärfte Regel · neuer
   Sensor · benannte Spec-Lücke).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Das Kriterium ist ein Urteil und kein Kommando.** *„Mehr als ein Satz"* trennt nicht
  mechanisch; eine Datei mit zwei Sätzen Grenze erfüllt es dem Wortlaut nach und trägt trotzdem
  nichts, was eine Zelle nicht hielte. DoD (1) sagt das ausdrücklich, statt ein Kommando zu
  behaupten. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: Register>
- **Eine Datei, die verschwindet, nimmt eingehende Verweise mit.** Die Ziel-Form will genau das
  (der rote Link ist das Signal), aber der Lauf muss die Verweise vorher messen — in **beiden**
  Formen, Markdown-Link und Inline-Code-Pfad, die auf verschiedene Module des Doku-Gates fallen.
  — **Ausgang:** <…>
- **Der Zeiger aus DoD (2) trägt einen Baseline-Tag.** Er wandert bei jedem Sprung mit, wie jeder
  andere Pfad in den vendored Baum; das ist die bekannte Kante, kein neuer Fall. — **Ausgang:** <…>
- **Offen, und hier nicht entschieden:** ob die Nutzung einer Ziel-Form des adoptierten Stands,
  dessen Adaptions-Durchgang noch aussteht
  ([`harness/conventions.md`](../../../../harness/conventions.md) §Baseline: *„auf `v6.5.0`:
  2026-09-07, Delta-Nachweis steht aus"*), einen Eintrag im Adaptions-Block braucht. Die Frage
  gehört dem Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice stellt sie und
  beantwortet sie nicht. — **Ausgang:** <…>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennungen **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Drei Übergaben an den Architect sind vorgemerkt: der Zeiger in
[`AGENTS.md`](../../../../AGENTS.md) §4, der für die Gate-Beschreibungen weiter auf den Einstieg
zeigt, während sie unter [`harness/sensors/`](../../../../harness/sensors) liegen · die Frage, ob
die Bindungs-Klassen der zwei Tabellen eine Deklaration brauchen · die Adaptions-Frage aus §6.

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo mit Wellen-Betrieb — von der nächsten Welle-Closure geprüft>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** **Eine** berührte Sub-Area, `*` (gesamtes Repo, Kürzel
`ALL`) aus der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md). `TOOLS` (`harness/tools/`) ist
**nicht** berührt — die Skripte werden weder gelesen noch geändert; berührt ist die Doku-Familie
`harness/*.md`, und für sie führt die Deklaration keine eigene Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Vier Treffer, Zähler-Stände am gemergten Stand
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine
Erwartungswerte):

- [`vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../observations/BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/observation.md)
  — **1**, Stand `offen`. Die Klasse dieses Slice: die Vorlage liegt vendored und ist in keinem
  lebenden Artefakt genannt; DoD (2) ist ihr Träger.
- [`einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../observations/BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md)
  — **0**, Stand `offen`: *benannt, nicht gezählt* (aufgefallen ohne abgeschlossenen Vorgang, und
  ein Vorkommen ohne Vorgang bekommt keinen Beleg). Sie führt dieselbe offene Architect-Frage wie
  §6 dieses Plans, für die Nachbar-Fläche.
- [`sensor-pruefbereich-deckt-den-bewegten-ort-nicht`](../observations/BEO-ALL/sensor-pruefbereich-deckt-den-bewegten-ort-nicht/observation.md)
  — **1**, Stand `offen`. Genau die Richtung, in der eine verschwindende Datei aus DoD (1) still
  wird: Was den alten Ort prüfte, sieht den neuen nicht.
- [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  — **2**, Stand `offen`. DoD (3) und §7 sind ihr Gegenmittel: drei benannte Übergaben statt einer
  Absichtserklärung.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF — ein Block, `ALL`.

### Sub-Area: `*` (gesamtes Repo, `ALL`)

- **Modus:** GF. Der Baum ist in diesem Repo entstanden; es gibt keinen vorgefundenen
  Fremd-Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** mittel. Die **Form** der Datei ist im vendored Regelwerk gesetzt und als
  Vorlage vorhanden; die **Auswahl**, für welches Ziel eine entsteht, ist in keinem Artefakt dieses
  Repos verankert — das ist der Gegenstand.
- **Phase-Reife:** Phase 5 (Betrieb). Der Einstieg ist Schritt 1 des Minimal Agent Workflow, und
  die Dateien hängen als Index an seinen zwei Tabellen.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für die Bijektion (ein Kommando entscheidet sie), mittel
  für die Auswahl — sie ist ein Urteil, und DoD (1) macht es auflistbar statt beweisbar.
- **Reconciliation-Aufwand:** gering. Eine Liste, ein Zeiger, gegebenenfalls ein Rückbau einzelner
  Dateien in ihre Zelle. Graduation-Trigger entfällt (bereits GF).
