# Slice slice-133: Der emittierte Baum trägt keine Platzhalter-Links

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — sie trägt eine Closure-Bedingung, die von
dieser DoD verschieden ist (die drei Durchgänge der Ziel-Prozedur, dazu die drei Sensoren
außerhalb der Gates), und dieser Slice ist einer ihrer Zugänge.

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
— und zwar ihr **eigener** Satz über diese Klasse: derivative Sichten entstehen
*„nicht als **gate-unsichere Platzhalter-Skelette** bei Bootstrap"*, und der emittierte Stand ist
*„out-of-the-box gate-sicher"*. Der Sollzustand steht damit im Vertrag; dieser Slice stellt ihn
wieder her, er entscheidet ihn nicht.
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Happy Path: *„`make gates`
läuft grün"*),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (deren
**Messmethode** wörtlich der Smoke-Test ist),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(Default-Regel für emittierte Prüfbereiche — fail-closed),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede Neutralisierung nennt, was sie rot färbt) und §3.7
(die Deckungs-Grenze steht am Code, nicht nur hier).

**Berührte Spec-Stellen:**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — die
Zusage, die heute gebrochen ist. Der Verweis zeigt **aufwärts**: das Lastenheft nennt diesen Slice
nie, und dieser Slice ändert es nicht (Rang 1; Baseline verbatim in
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler):
*„weder ADR noch Slice dürfen `LH-*` je ändern — sie referenzieren nur"*).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ein frisch gebootstrapptes Zielrepo trägt in den drei Singleton-Artefakten, die
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
namentlich aufzählt, keinen Link mehr, der ins Leere zeigt.**

### Der Bruch ist gemessen, nicht befürchtet — und er ist eingetreten

`make smoke` am Stand `26aec2c`:

```
d-check: 23 Datei(en) geprüft, 10 Befund(e)
smoke: FEHLER — emittiertes docs-check meldet Befunde (nicht out-of-the-box gate-sicher,
       slice-028/LH-QA-01)
```

Gegen den Vor-Tausch-Stand gehalten, gleiche Maschine, gleiche gepinnten Images
(`T=$(mktemp -d); git archive c6cc56f | tar -x -C "$T"; cd "$T" && make smoke`):
`d-check: 19 Datei(en) geprüft, 0 Befund(e)`, Exit 0. **Der Baum-Tausch aus
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) ist die Ursache, nicht eine
Vorlast.** Beide Zahlen wandern mit dem Vorlagen-Satz und sind **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); tragend ist die Aufteilung darunter, nicht die Ziffer.

### Die zehn Befunde haben zwei Ursachen, und nur eine gehört hierher

Je Befund an seiner Vorlagen-Zeile nachgesehen, nicht über die Summe geschlossen:

`<ziel>/` meint das **gebootstrappte Zielrepo**, nicht dieses; die Vorlagen liegen unter
`.harness/baseline/v5.12.0/templates/`, hier als `…/` abgekürzt. Beide Präfixe stehen, damit keine
Zelle wie ein Pfad **dieses** Repos aussieht — die Ebenen-Trennung ist der Gegenstand des Slice,
nicht seine Kosmetik.

| Emittierte Datei · Ziel | n | Vorlage | Ursache |
|---|---|---|---|
| `<ziel>/docs/plan/planning/in-progress/roadmap.md` → `](../<welle-NN-titel>.md)` | 1 | `…/docs/plan/planning/roadmap.template.md` | **A** |
| `<ziel>/harness/README.md` → `](<pfad>)` | 3 | `…/harness/README.template.md` Z. 152–154 | **A** |
| `<ziel>/harness/conventions.md` → `](conventions/MR-<NNN>-<titel>.md)`, `](conventions/done/MR-<NNN>-<titel>.md)` | 3 | `…/harness/conventions.template.md` Z. 131, 143 | **A** |
| `<ziel>/docs/plan/planning/welle-results.md` → `](observations.template.md)`, `](../observations.md)` | 2 | `…/docs/plan/planning/welle-results.template.md` | **B** |
| `<ziel>/harness/conventions/MR-NNN-titel.md` → `](…/baseline/<tag>/regelwerk/grundlagen-referenz-richtung.md#…)` | 1 | `…/harness/conventions/MR-NNN-titel.template.md` | **B** |

**Ursache A — sieben Befunde, dieser Slice.** Drei Vorlagen, die **schon vor dem Tausch im
Vorlagen-Satz lagen und schon vor dem Tausch als Singletons emittiert wurden**, tragen in ihrem
Rumpf neuerdings **Platzhalter-Links**: `](../<welle-NN-titel>.md)`, `](<pfad>)`,
`](conventions/MR-<NNN>-<titel>.md)`. Keiner davon ist eine Klassen-Frage — alle drei Ziele nennt
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
ausdrücklich als Singletons (*„`AGENTS.md`, `spec/*`, `harness/*`, Root-`README.md`, Roadmap"*).
Dass es die Zeilen vorher nicht gab, ist gemessen, nicht angenommen — je Vorlage `alt=0`, in der
Summe `neu=7`, also genau die sieben Befunde der Tabelle:

```
P='\]\((<pfad>|\.\./<welle-NN-titel>\.md|conventions/(done/)?MR-<NNN>-<titel>\.md)\)'
for f in docs/plan/planning/roadmap.template.md harness/README.template.md \
         harness/conventions.template.md; do
  printf '%s: alt=%s neu=%s\n' "$f" \
    "$(git show "c6cc56f:.harness/baseline/v3.5.2/templates/$f" | grep -oE "$P" | wc -l)" \
    "$(grep -oE "$P" ".harness/baseline/v5.12.0/templates/$f" | wc -l)"
done
```

`grep -o … | wc -l` und nicht `grep -c`: Zeile 143 der `conventions`-Vorlage trägt **zwei**
Platzhalter-Links, und eine Zeilenzählung liefert hier 6 statt 7
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 — das Kommando muss **genau** die Zahl ausgeben, neben der es steht).

**Ursache B — drei Befunde, nicht dieser Slice.** Sie hängen an den **vier neuen** Vorlagen und
lösen sich **mit ihrer Klassen-Entscheidung**, nicht durch Link-Arbeit: fällt
`welle-results.template.md` auf *wiederkehrend*, wird sie als `.template.md` emittiert und fällt
damit unter `scan.ignore` des emittierten Gates — beide Befunde verschwinden, ohne dass ein Link
angefasst wurde. Ihr Träger ist
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md).

### Warum das keine Ausnahme ist, sondern eine Reparatur

Der Trichter aus Baseline-Regelwerk `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz führt
**nicht** auf Carveout. *Frage 1 (Granularität):* zehn Befunde über fünf emittierte Dateien aus
fünf Vorlagen mit **einem** Geltungsbereich (`internal/emit/` → emittierter Baum) sind eine
**Häufung**, und Modul 7 sagt dazu ausdrücklich *„Carveouts sind für **punktuelle** Ausnahmen …
Eine Diskrepanz-**Häufung** … gehört nicht in eine Carveout-Kaskade"*. Die Cluster-Antwort trifft
ebenso wenig: eine BF-Sub-Area-Markierung setzte *„Code führt, Doku folgt"*, und darum geht es
nicht — `internal/emit/` ist GF deklariert. Der ADR-Zweig scheidet an *Frage 2* aus: der Trigger
ist ernst erreichbar, ADR-permanent verlangt das Gegenteil. Was Modul 7 für diesen Ausgang nennt,
ist **„Übernahme im nächsten Slice"** — dieser hier.

Dazu kommt die Grenze, an der jedes der drei Werkzeuge ohnehin endete:
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) ist Rang 1
der Source Precedence, und ein Carveout steht in **keinem** Rang. Baseline-Regelwerk
`grundlagen-source-precedence.md` §Vollständigkeit lässt Artefakten außerhalb der Rangliste das
**Verweisen**, **Ausführen** und **Ausbuchstabieren** — nicht das **Festlegen**. Eine Ausnahme, die
den Bruch einer Rang-1-Zusage für zulässig erklärt, legt fest.

### Der Mechanismus existiert schon, und sein Kommentar hat den Fall vorhergesagt

`internal/emit/templates.go` führt mit `NeutralizeRoadmap` und `NeutralizeMakeClaims` bereits zwei
Neutralisierungen genau dieser Bauart. Der Doc-Kommentar der ersten benennt die Lücke, durch die
Ursache A gefallen ist, wörtlich:

> *„Aendert dagegen der KURS die Link-Form upstream, bleibt dieser Test gruen — die Fixture traegt
> den alten Wortlaut, und `courseset-fixture.bats` gleicht nur den Datei-BESTAND ab, keinen Inhalt;
> diese reale Drift faengt allein `make smoke` (Tier-2, NICHT in make gates)."*

Eingetreten ist die **zweite** Variante: der alte Marker
`roadmapDoneLink` steht unverändert in der `roadmap`-Vorlage beider Bäume — in `v3.5.2` über
`c6cc56f` je **1**, in `v5.12.0` im Arbeitsbaum je **1**. Der Marker wird aus der Konstanten
gelesen statt abgeschrieben, damit die Messung ihm folgt, wenn er sich ändert:

```
R=docs/plan/planning/roadmap.template.md
M=$(grep -m1 'roadmapDoneLink =' internal/emit/templates.go | cut -d'"' -f2)
git show "c6cc56f:.harness/baseline/v3.5.2/templates/$R" | grep -cF "$M"
grep -cF "$M" ".harness/baseline/v5.12.0/templates/$R"
```

Die Neutralisierung feuert also weiter — die neue Fassung hat
**daneben** einen zweiten Platzhalter-Link gesetzt, den kein Marker kennt. Eine Neutralisierung,
die einen **Wortlaut** kennt statt einer **Form**, deckt den nächsten Zugang nicht. Welche der
beiden Bauarten dieser Slice wählt — Marker je Fundstelle oder Regel über die Platzhalter-Form —,
ist eine Entscheidung am Code und gehört in ihren Kommentar
([`AGENTS.md`](../../../../AGENTS.md) §3.7), nicht in diesen Plan.

**Die Ebene ist die Pointe.** Nichts hiervon ist eine Aussage über *dieses* Repo: `harness/README.md`
und `harness/conventions.md` liegen hier gefüllt, ihre Platzhalter-Zeilen existieren nur im
emittierten Skelett. Was dieses Repo an seinen eigenen Artefakten tut, ist eine Dogfood-Frage mit
eigenem Eigentümer und steht **nicht** in diesem Slice.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Die sieben Befunde der Ursache A sind fort, und zwar namentlich geprüft, nicht über
      die Summe.** `make smoke` meldet für `docs/plan/planning/in-progress/roadmap.md`,
      `harness/README.md` und `harness/conventions.md` **keinen** Befund mehr. Die Restmenge ist
      **kein** Erfolgskriterium dieses Slice: sie ist die Ursache B und trägt
      [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md) — ein Lauf, der beide
      Klassen zugleich grün meldet, ist ein Hinweis, dass eine Klasse anders aufgelöst wurde als
      hier beschrieben, und gehört nachgesehen statt abgehakt.
- [x] **(2) Die Neutralisierung ist rot gesehen, und ihre Deckungs-Grenze steht am Code.**
      Benannt und einmal gefahren ist, welche Mutation sie fallen lässt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6); der Fall liegt in `test/mutations/`. Der
      Doc-Kommentar sagt im **Indikativ**, was die Neutralisierung hält, und benennt, was sie
      **nicht** hält — insbesondere, ob ein *künftiger* Vorlagen-Zugang mit derselben
      Platzhalter-Form von ihr erfasst wird oder wieder nur von `make smoke`
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
- [x] **(3) Ein Wächter innerhalb von `make gates` sieht die Klasse, oder seine Abwesenheit ist
      benannt.** Heute liegt der einzige Sensor für diese Drift außerhalb der Gates — das ist die
      Aussage des zitierten Doc-Kommentars und der Grund, warum der Bruch einen ganzen Slice lang
      unbemerkt blieb. Der Slice entscheidet je Antwort: Wächter gebaut (dann trägt er die
      Platzhalter-Form, nicht den Wortlaut) **oder** ausdrücklich nicht gebaut, mit Grund und
      Folge-Slice. Eine dritte Antwort — die Frage nicht stellen — ist ausgeschlossen
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] `make gates` grün, soweit die Welle es zulässt — die offenen Carveouts
      [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) und
      [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) bleiben bis zu ihren
      eigenen Folge-Slices bestehen und sind **nicht** Gegenstand dieses Slice.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist —
      [`spec/lastenheft.md`](../../../../spec/lastenheft.md) bleibt dabei **unverändert** (§3).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (die `observations.md` neben den Wellen): das Repo führt **keines** —
      ob es entsteht, hängt an derselben Dogfood-Frage, die dieser Slice nicht entscheidet (§1).
      Das Item entfällt nicht still, sondern mit diesem Grund; er wird in §7 notiert. Dasselbe
      gilt für das Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
      Wellen-Betrieb, sie werden also von der [welle-10](../welle-10-re-baseline.md)-Closure
      geprüft, nicht hier.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | die Neutralisierung der Platzhalter-Links; hier fällt die Bauart-Entscheidung (Marker je Fundstelle ↔ Regel über die Form) und wird am Kommentar belegt |
| `internal/emit/templates_test.go` | update | der Wächter über die Wirkung; `courseSet()` bleibt Fixture und ersetzt `make smoke` nicht (§1) |
| `test/mutations/` | neu | je Zusage aus DoD (2) ein rot färbender Fall ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| `internal/emit/templates/d-check.yml` | **offen — Entscheidung im Slice** | die zweite mögliche Bauart wäre eine Regel im **emittierten** Prüfbereich statt im Emitter. Sie ist nach [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) belegpflichtig und wäre ein Ausschluss im Zielrepo, den der Adopter erbt — der Slice begründet, welche Ebene trägt, statt beide anzufassen |
| `.harness/baseline/v5.12.0/templates/` | **unverändert** | committet vendored Fremd-Blob; ein Edit dort wäre ein Fork und bräche [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache). Der Kurs-Fix wäre die SSoT-Lösung und ist hier nicht verfügbar — dieselbe Lage, die der Kommentar von `NeutralizeRoadmap` schon beschreibt |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | Rang 1. Der Sollzustand steht bereits dort; dieser Slice stellt ihn her. Erwiese sich die Zusage als so nicht haltbar, verlässt die Frage den Slice als Übergabe (§6) — sie wird nicht hier geschrieben ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) |
| `internal/emit/templates/commands/`, `.harness/skills/` | **unverändert** | der **Text** der emittierten Artefakte ist Gegenstand von [slice-085](../open/slice-085-emittierte-ebene-zieht-nach.md) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) liegt in `done/` — der
Vorlagen-Satz, dessen Platzhalter neutralisiert werden, steht dann fest und wechselt während der
Arbeit nicht. Das WIP-Limit wird mit demselben Übergang frei. Dieser Slice läuft **vor**
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md): er trägt sieben der zehn
Befunde und ist von der Klassen-Entscheidung unabhängig, während deren DoD (3) den **gemeinsamen**
Nachweis führt und ihn erst danach führen kann.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Entscheidung aus DoD (3) einen
  eigenen Wächter verlangt, der mehr ist als die Umkehrung der Neutralisierung — dann trennt der
  Schnitt Reparatur und Sensor.
- `in-progress` → `open` (blockiert — Carveout?): wenn sich zeigt, dass die drei Ziele **nicht**
  ohne eine Änderung an
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) gate-sicher
  zu machen sind. Das Lastenheft ist Rang 1 und wird nicht im Implementations-Kontext
  fortgeschrieben; die Frage geht dann als Übergabe hinaus, und der Bruch bleibt bis zur Antwort
  **offen benannt** statt durch eine Ausnahme geschlossen (§1, letzter Absatz der Werkzeug-Wahl).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **`make smoke` meldet für die drei Dateien aus DoD (1) keinen Befund
mehr** (die Restmenge ist benannt und trägt einen anderen Slice), und **`make gates` ist grün bis
auf die zwei offenen Carveouts der Welle**. Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag
und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Eine Neutralisierung je Fundstelle bringt die Lücke zurück, die diesen Slice ausgelöst hat.**
  `NeutralizeRoadmap` kennt einen **Wortlaut**; der nächste Vorlagen-Zugang mit derselben
  Platzhalter-Form fällt wieder durch und wird wieder erst von `make smoke` gesehen. — **Ausgang:
  entfallen.** Die Regel verfügt über keinen Namen und keinen Wortlaut; sie ist gegen einen dem
  Code unbekannten, frei erfundenen Platzhalter geprüft —
  `command grep -n 'glossar/<begriff>' internal/emit/templates_test.go` → Zeile **710**, die
  Eingabe von `TestTemplates_NeuerPlatzhalterLinkOhneCodeaenderung`
  (`command grep -n 'func TestTemplates_NeuerPlatzhalterLinkOhneCodeaenderung' internal/emit/templates_test.go`
  → Zeile **707**). Dass Fall `206` genau diesen Test rot färbt, ist die Messung der Verifikation
  und in dieser Closure **Eingabe**, nicht neu gefahren (§7, DoD (2)).
- **Der Ausschluss könnte in den emittierten Prüfbereich wandern statt in den Emitter.** Dann
  erbt jeder Adopter einen blinden Fleck in seinem eigenen `d-check`, und der Befund ist gegen
  einen unsichtbaren getauscht — dieselbe Abwägung, die
  [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) für `scan.ignore` führt. —
  **Ausgang: entfallen.** Die Reparatur liegt im Emitter, und der emittierte Prüfbereich ist über
  die **ganze** Kette unberührt:
  `git diff --name-only 3ea5ae2^ HEAD -- internal/emit/templates/d-check.yml | wc -l` → **0**.
  Ein Adopter erbt damit keinen blinden Fleck, den
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  fail-closed ausschließt; die Begründung, welche Ebene trägt, steht seit der Fix-Runde am Code.
- **`make full-smoke` zieht das Asset aus dem Netz** und ist damit an eine Bedingung außerhalb des
  Repos gebunden; `make smoke` allein deckt den zusammengeführten `make gates`-E2E im Ziel nicht
  (der Hinweis steht in seiner eigenen Ausgabe). — **Ausgang: weiter offen** — der dritte der drei
  zulässigen, weil **beide** vorformulierten Zweige durch Messung widerlegt sind.
  *„beide Läufe gelingen"* trifft nicht: `make full-smoke; echo $?` → **2**, und `make smoke`
  meldet zwei Befunde (§7). *„der Nachweis ist nicht führbar"* trifft ebenso wenig — die
  **Netz**-Bedingung, um die dieses Risiko geht, war erfüllt, und der Treiber ordnet den Fehlschlag
  selbst zu: `full-smoke: FEHLER — AUSGANG BAUM: … Keine der 4 gefuehrten Formen einer nicht mit
  2xx beantworteten Anfrage nach einem gepinnten Artefakt steht in den 191 gelesenen Zeilen`
  (die Zeilenzahl wandert mit der Ausgabe und ist kein Erwartungswert,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Ein `CO-NNN` entsteht darum nicht.
  **Offen bleibt die Kopplung selbst, und die zweite Hälfte des Risikos ist bestätigt statt
  aufgelöst.** Die Netz-Bindung hat kein Commit aufgehoben, dieser Lauf hat sie nur erfüllt; und
  `make smoke` meldet für die drei Ziele aus DoD (1) nichts, während `make full-smoke` trotzdem
  fällt — an genau **einem** Teil-Ziel im Zielrepo
  (`make full-smoke 2>&1 | command grep -cE '^make\[1\]: \*\*\* \['` → **1**,
  `d-check.mk:20: docs-check`) mit denselben zwei Klasse-B-Befunden. `make smoke` allein deckt den
  zusammengeführten `make gates`-E2E im Ziel also wirklich nicht.
  **Wohin dieser Ausgang gehört, und warum er heute hier steht:** Modul 5 §Offene Risiken hängt
  *weiter offen* an das **Beobachtungs-Register**, und das Repo führt keines
  (`ls docs/plan/planning/observations.md` → `Datei oder Verzeichnis nicht gefunden`). Sein Träger
  ist seit dem 2026-08-29 geschnitten:
  [slice-137](../in-progress/slice-137-beobachtungs-register-bekommt-seinen-ort.md). Bis der läuft, ist
  dieser Absatz der Ort — das ist die Grenze, nicht die Erledigung.
- **Die drei Ziele sind Singletons, die der Adopter danach selbst füllt.** Eine Neutralisierung,
  die eine Zeile **löscht** statt sie zu entschärfen, nimmt ihm das Form-Beispiel — genau das, was
  `NeutralizeRoadmap` mit Absicht stehen lässt (*„die Zeile bleibt als Form-Beispiel erhalten,
  traegt aber keinen toten Link"*). — **Ausgang: entfallen**, am emittierten Ist-Ergebnis geprüft
  statt am Test: im gebootstrappten Zielrepo steht
  `command grep -n 'zuerst' <ziel>/harness/README.md` → Zeile **144**
  ``1. <zuerst — z. B. `AGENTS.md` §Hard Rules>`` und
  `command grep -n 'MR-\<NNN\>' <ziel>/harness/conventions.md` → Zeile **129**
  `| \<NNN\> <a id="mr-<NNN>"></a> | MR-\<NNN\> |`. Beide Zeilen tragen ihren Text und keinen Link
  mehr; keine berührte Zeile ist gelöscht (Bootstrap-Kommando in §7).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner (Modul 5 §Closure- und Lerneintrag-Regeln). **Datum:** 2026-08-29.
**Gegenstand:** `HEAD` = `66459c7`, Arbeitsbaum sauber (`git status --porcelain=v1 | wc -l` → **0**).
Die Kette: `3ea5ae2` (Lifecycle-Move, reines `R100`) · `2a18b2f` (Link-Abgleich) · `f979b59`
(Implementer) · `db3fdb4` (Review, NICHT KONFORM, 2 HIGH) · `6967691` (Fix-Runde) · `f523b7e`
(Verifikation). Dazwischen und danach liegen zwei Commits anderer Slices (`e7eb8d1`, `66459c7`);
sie bewegen keine Datei dieses Slice
(`git show --name-only --format= e7eb8d1 66459c7 | grep -c 'slice-133\|internal/emit\|^test/'` → **0**).

Jede Zahl unten ist **in diesem Lauf** erhoben; die Zahlen aus Umsetzung, Review und Verifikation
waren **Eingabe, kein Beleg**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). Wo ich eine Messung **nicht** wiederholt habe, steht es dabei.

### DoD-Stand — die drei slice-eigenen Punkte, jeder mit dem Kommando, das ihn hier trug

**(1) Die sieben Befunde der Ursache A sind fort, namentlich geprüft — ERFÜLLT.** `make smoke`
selbst gefahren: `d-check: 23 Datei(en) geprüft, 2 Befund(e)`, und die Befundliste ist zwei Zeilen
lang, beide außerhalb der drei genannten Ziele
(`make smoke 2>&1 | command grep -cE '^(docs/plan/planning/in-progress/roadmap|harness/README|harness/conventions)\.md:'`
→ **0**). **Der Nenner ist unverändert**, und das ist der Punkt: §1 zitiert für `26aec2c`
`23 Datei(en) geprüft, 10 Befund(e)`; mein Lauf liefert dieselbe **23** bei **2** — nichts ist
still aus dem Scan gefallen.

**Eine Ebene tiefer nachgemessen statt aus der Befundzahl geschlossen.** Der Träger aus
`make host-bin` bootstrapt ein leeres Repo, und über dessen emittierten Baum läuft ein eigener
Scanner:

```
Z=$(mktemp -d); git init -q "$Z"
( cd "$Z" && .harness/state/bin/ai-harness-init --lang go --name V )
find "$Z" -name '*.md' -not -path '*/.harness/baseline/*' | wc -l                      # -> 25
for f in $(find "$Z" -name '*.md' -not -path '*/.harness/baseline/*'); do
  command grep -HnoE '\]\([^()[:space:]]*\)' "$f"; done \
 | awk '{i=index($0,"](");z=substr($0,i+2);sub(/\)$/,"",z);sub(/#.*$/,"",z);
         if (z ~ /<[^<>]*>/) n++} END {printf "%d\n", n+0}'                            # -> 0
```

**25** emittierte Markdown-Dateien, **0** Links mit `<…>`-Platzhalter im Ziel-Pfad. Die Gegenprobe
über den **vendored** Satz **desselben** Zielrepos (`find "$Z/.harness/baseline" -name '*.md'` als
Eingang, sonst identisch) liefert **12** — der Scanner funktioniert, und die Differenz ist genau
die Emit-Regel.

**Die Nachschau, die DoD (1) verlangt, ist fällig gewesen und trägt.** Der Punkt warnt: *„ein Lauf,
der beide Klassen zugleich grün meldet … gehört nachgesehen statt abgehakt."* Beide Klassen sind
nicht zugleich grün — aber **ein** Befund der Klasse B ist mitgefallen
(`<ziel>/harness/conventions/MR-NNN-titel.md`, `<tag>` im Baseline-Pfad). Die Erklärung ist
gemessen und nicht erzählt: die Klassen-Weichen sind über die **ganze** Kette unangetastet
(`git diff 3ea5ae2^ HEAD -- internal/emit/templates.go | command grep -cE '^[+-][^+-].*func (inScope|isRecurring|isDerivativeIndex)'`
→ **0**), und die zwei verbliebenen Befunde tragen **kein** `<…>` — sie sind die Klasse, die
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md) mit seiner
Klassen-Entscheidung auflöst. Die Form-Regel greift also **breiter als die Ursachen-Einteilung des
Plans**; das ist die Konsequenz der gewählten Bauart und zieht eine Buchhaltung nach sich (unten).

**(2) Die Neutralisierung ist rot gesehen, die Deckungs-Grenze steht am Code — ERFÜLLT.**
`make mutate` kann nicht laufen: der Treiber fährt einen Grün-Vorlauf je benutztem Modus und bricht
fail-closed ab, solange einer rot ist, und `test-bats` **ist** rot (unten). Statt das Ersatz-Protokoll
zu übernehmen, habe ich den **tragenden** Arm selbst gefahren — `git archive HEAD | tar -x` in eine
Kopie außerhalb des Repos, Fall-Skript unverändert:

| Kopie | Sensor | `ok 43` |
|---|---|---|
| Fall `209` (`spitzes Ziel nur am Anfang`) über der heutigen Bedingung | `make test-bats` | **`not ok 43`** |
| dieselbe Kopie, Klassifikator auf `substr(ziel, 1, 1) == "<"` zurückgedreht | `make test-bats` | **`ok 43`** |

Die zweite Zeile ist die tragende: dieselbe Mutation, dieselbe Kopie, nur die Bedingung
zurückgedreht — und der Wächter schweigt. Der Zahn beißt die **Klassifikation selbst**, nicht ihre
Umgebung. Die drei übrigen Fälle habe ich **nicht** neu gefahren; sie sind vorhanden, ausführbar
und im Treiber-Format (`git ls-files -s test/mutations/20[6-9]*.sh | grep -c '^100755 '` → **4**), und
ihr Rot ist von der Verifikation unabhängig nachgestellt — für sie ist deren Protokoll **Eingabe**.

Die Deckungs-Grenze steht in `internal/emit/templates.go` und beantwortet die Frage, die DoD (2)
namentlich stellt, im Indikativ: eine Vorlage, die upstream mit einem `<…>`-Ziel dazukommt, fällt
**ohne Codeänderung** darunter — gemessen an einem frei erfundenen Platzhalter, den der Code nicht
kennt (`command grep -n 'glossar/<begriff>' internal/emit/templates_test.go` → Zeile **710**) —,
und was die Regel **nicht** hält, steht als vier benannte Grenzen daneben, die erste mit der
Konsequenz beim Namen: *„Im emittierten Baum sieht diese Form allein `make smoke`, und der laeuft
ausserhalb von `make gates`."*

**(3) Ein Wächter innerhalb von `make gates` sieht die Klasse — ERFÜLLT über Antwort (a).**
Der Wächter liegt mechanisch in den Gates: `ok 43` steht in der Ausgabe meines eigenen
`make -k gates`-Laufs. Und er kippt über dem Ereignis, für das er gebaut ist — **unabhängig
nachgemessen, mit dem Klassifikator aus dem Wächter selbst statt abgeschrieben**
(`sed -n '/^platzhalter_formen() {/,/^}/p' test/courseset-fixture.bats | wc -l` → **10**; dieselbe
Ausgabe ohne `wc` als Funktion geladen):

| Baum | `sort -u` | `uniq -c` |
|---|---|---|
| `v3.5.2` (über `c6cc56f`, Dateiliste aus `git ls-tree -r --name-only c6cc56f`) | `eingebettet` | `4 eingebettet` |
| `v5.12.0` (Arbeitsbaum) | `eingebettet` `spitz` | `9 eingebettet`, `3 spitz` |

Die drei spitzen Ziele stehen an genau einer Stelle:
`command grep -rnoE '\]\(<[^<>()]*>\)' .harness/baseline/v5.12.0/templates` → drei Treffer, alle in
`…/harness/README.template.md`, Zeilen `152`, `153`, `154`. **Sie kamen mit dem Tausch.** Gegen eine
dem Vor-Tausch-Satz treue Fixture wäre der Wächter **vor** dem Tausch grün und **am** Tausch rot
gewesen.

**Antwort (b) ist gestrichen, und das ist die Entscheidung dieses Zuges.** Die Commit-Message der
Fix-Runde nahm für den Rest zusätzlich *„(b) nicht gebaut"* in Anspruch; DoD (3) ist ein
**Entweder-oder**, und (a) ist gebaut, liegt in `make gates`, trägt die Form statt eines Wortlauts
und ist rot gesehen. Der „Rest", den (b) meinte — ob die Emit-Regel einen **realen** Link erreicht
—, ist genau der Gegenstand, den DoD (2) am Code benannt haben will, und er steht dort. Zwei
DoD-Punkte auf **einem** Gegenstand wären Doppel-Buchführung, und die Pflicht *„mit Grund **und**
Folge-Slice"* hinge an einer Zusage ohne eigenen Gegenstand.
[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md) ist als **Präzedenz für
den Schnitt** richtig genannt und als **Adressat** falsch: sein DoD-(3)-Posten (e) betrifft
`emitDokumentSatz` und `makeQuellenDesZiels`, eine andere Fixture-Grenze. Was bleibt, ist keine
offene DoD-Pflicht, sondern ein **Bau-Problem mit eigenem Ort** — siehe *Übergabe* unten.

### Die vier Standard-Punkte

**`make gates` grün, soweit die Welle es zulässt — ERFÜLLT.** `make -k gates` (keep-going; ohne
`-k` verdeckt der erste Abbruch zehn Ziele), Exit **2**, und **genau zwei** rote Ziele:
`make -k gates 2>&1 | command grep -cE '^make(\[[0-9]+\])?: \*\*\*'` → **2**, nämlich `docs-check`
und `test-bats`. `docs-check`: `d-check: 456 Datei(en) geprüft, 1 Befund(e)`, und der eine ist
`harness/conventions.md:1019 → ../.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md#… · target-missing`
— [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md), vom Slice unabhängig.
`test-bats`: `1..190` mit `not ok 40` und `not ok 41`, Zeichen für Zeichen die zwei Fallnamen aus
[`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md); `ok 42` und der neue `ok 43`
sind grün. **Kein roter Fall außerhalb der Carveouts.** Grün und selbst gesehen:
`baseline-verify: v5.12.0 OK — 51 Dateien`, `lint`, `build`, `test-go`, `shell-lint`, `ci-lint`,
`comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`, `host-bin`,
`span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`.

**Doku-Update — ERFÜLLT, kein Trigger.** Über die ganze Kette ist kein öffentlicher Vertrag
berührt: `git diff --name-only 3ea5ae2^ HEAD -- spec/ .harness/baseline/ | wc -l` → **0**.
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) wird
**eingelöst**, nicht fortgeschrieben — die Richtung, die
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
verlangt.

**Beobachtungs- und Reconciliation-Register — das Item entfällt, und hier ist der Grund.** Eine
`observations.md` unter `docs/plan/planning/` existiert nicht
(`ls docs/plan/planning/observations.md` → `Datei oder Verzeichnis nicht gefunden`); der Wegfall
ist keine Auslassung, sondern die Folge einer Dogfood-Entscheidung, die dieser Slice nicht trifft
(§1). **Seit dem 2026-08-29 hat sie einen Träger:**
[slice-137](../in-progress/slice-137-beobachtungs-register-bekommt-seinen-ort.md) legt das Register an und
gibt jedem seiner drei Schritte einen Ort. Das Reconciliation-Register entfällt aus einem anderen
Grund und dauerhaft: das Repo hat keinen Brownfield-Bootstrap.

**Die drei Paarungen — nicht hier fällig.** Dieses Repo fährt Wellen-Betrieb; Anker, Folge-Slice
und Register prüft die [welle-10](../welle-10-re-baseline.md)-Closure.

### Was funktionierte

**Die Bauart-Entscheidung war nie strittig, und drei Rollen sagen es unabhängig.** Review,
Verifikation und dieser Lauf haben je eigenständig geprüft, dass die Neutralisierung eine **Form**
trägt statt eines Wortlauts, dass sie im Emitter liegt statt im emittierten Prüfbereich und dass
sie die Zeile als Form-Beispiel stehen lässt. **Kein Befund traf die Neutralisierung selbst** — die
Fix-Runde hat an ihr keine Anweisung bewegt, nur Kommentar:
`git show 6967691 -- internal/emit/templates.go | grep -E '^[+-]' | grep -vE '^[+-][+-]' | grep -cvE '^[+-][[:space:]]*(//|$)'`
→ **0**.

**Der Ort des Wächters ist gedeckt, obwohl der Plan ihn offenließ.** Dass er in `test/*.bats` statt
in einem Go-Test liegt, hat einen realen Grund: `cat .dockerignore` → `.git`, `.harness` — die
go-test-Stufe sieht den vendored Satz nicht.

### Was ging anders als geplant

**Zwei Dateien liegen außerhalb der Plan-Tabelle §3**, beide innerhalb der in §8 deklarierten
Sub-Areas, beide in Commit-Messages begründet und in keinem Planner-Artefakt vermerkt:
`internal/emit/readme.go` (der zweite Aufrufpunkt; über dem heutigen realen Satz wirkungslos —
`command grep -oE '\]\([^()[:space:]]*\)' .harness/baseline/v5.12.0/templates/project-readme.template.md | command grep -cE '<[^<>]*>'`
→ **0** bei **3** Link-Zielen insgesamt — und ausdrücklich mit der Form statt
dem heutigen Stand begründet) und `test/courseset-fixture.bats` (der Ort des DoD-(3)-Wächters, den
der Plan bewusst offenließ). **Die Plan-Tabelle bleibt unangetastet**: sie heißt *„Plan (vor
Code)"*, und ein nachträglich eingetragener Zusatz machte die Verifikation §8.2 unlesbar, die genau
gegen diesen Text gemessen hat. Der Ort für die Abweichung ist dieser Absatz. **Dieselbe Klasse ist
am selben Modul schon einmal aufgetreten** (`docs/reviews/2026-08-25-slice-087-review.md` `F-2`,
dieselbe Datei `readme.go`) — zweimal ist kein Einzelfall mehr; ihren Termin trägt
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) als neunter Posten (*Form der
Plan-Tabelle*), sie braucht hier keinen zweiten Schnitt.

**Der Review war blockierend, und sein tragender Befund war das Symptom seines schmalsten.** Beide
HIGH waren **ein** Defekt in zwei Ansichten; das hat den Slice eine Runde gekostet, in der drei
schwere Auswege erwogen wurden (andere Achse · Fall auf Antwort (b) · Rückführung nach §4), während
die Reparatur eine Bedingung war. Das ist der Anlass des Lerneintrags und steht dort.

### Steering-Loop-Eintrag — **geschärfte Regel**, gezählt und nicht verkörpert

**Die Klasse:** *Betrifft ein Befund das **Instrument** einer anderen Messung desselben Laufs, ist
diese Messung mit dem korrigierten Instrument zu wiederholen, bevor beide als getrennte Befunde
geführt werden.* Sonst wird ein **Symptom** als eigenständiger Struktur-Defekt gerankt, und weil
das schwerere Ranking das Verdikt und die vorgeschlagenen Auswege bestimmt, kostet es eine Runde am
falschen Gegenstand. Die Messung ist dabei nicht falsch — sie ist über einem Zustand richtig, den
der Bericht selbst als reparaturbedürftig führt, und trägt darum kein Urteil über den reparierten.

**Der gemessene Anlass — drei Kontexte, ein Instrument, an einem Tag.** Der Review führte zwei
HIGH, und sie waren **derselbe** Defekt in zwei Ansichten: `HIGH-2` wies die `spitz`-Bedingung
(`substr(ziel, 1, 1) == "<"`) als defekt nach, `HIGH-1` war **mit genau dieser Bedingung gemessen**
und schloss daraus, der Wächter könne das Ereignis nicht anzeigen, für das er gebaut ist. Über
`f979b59` stimmte die Messung; als **Struktur**-Aussage über den Wächter stimmte sie nicht, und
genau so wurde sie geführt — mit drei schweren Auswegen, von denen keiner nötig war. Der
Haupt-Kontext hat den Befund mit demselben Instrument nachgeprüft und den Defekt damit geerbt.
Erst die Verifikation zog den Klassifikator aus dem Wächter, statt ihn abzuschreiben, und fuhr ihn
über **beiden** Bedingungen — das Ergebnis kippte. **In diesem Lauf ein drittes Mal unabhängig
erhoben** (Tabelle unter DoD (3)): `v3.5.2` → `{eingebettet}`, `v5.12.0` → `{eingebettet, spitz}`.
`HIGH-1` fiel mit der einen Zeile, die `HIGH-2` verlangte.

**Die Form ist eine Regel, kein Sensor, und der Grund ist gemessen.** Ein Gate müsste erkennen,
dass das Instrument einer Messung im selben Lauf unter Befund steht; kein Modul liest Berichte, und
die Stelle, an der es hier saß, liegt dauerhaft außerhalb des einzigen Kandidaten —
`make comment-claims` prüft vier Pfad-Muster, `test/*.bats` ist keines davon (selbst gefahren:
`46 Datei(en) geprueft, 0 Befund(e)`, und diese **0** sagt über die bats-Seite nichts). Ein
behaupteter Wächter wäre genau das stille Grün aus
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6). Was die
Regel **hat**, ist eine billige und vorgemachte Prozedur: den Klassifikator per `sed` aus dem
Wächter ziehen und die Messung über beiden Ständen fahren (DoD (3) oben, zehn Zeilen).

**Adressat und Grenze.** Der Regeltext gehörte an
[`AGENTS.md`](../../../../AGENTS.md) §3.6 und damit dem **Architect**
([`AGENTS.md`](../../../../AGENTS.md) §3.8); der Träger für seinen **Termin** ist
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), der genau diese Klasse von
Postens führt. **Dieser Lauf hat ihn dort nicht eingetragen** — das ist die Grenze dieser Closure
und steht hier, weil sie sonst nirgends stünde. Das Feld `liegt in` entfällt darum ersatzlos: der
Eintrag ist **gezählt, nicht verkörpert**
(`grundlagen-traceability.md` §Herkunfts-Anker).

### Ausgänge — jeder offene Posten hat einen, *„genannt"* ist keiner

| Posten | Herkunft | Ausgang |
|---|---|---|
| Der Wächter kann das Ereignis nicht anzeigen, für das er gebaut ist | Review `HIGH-1` | **mit `HIGH-2` gefallen** — über `f979b59` traf die Messung zu, über `6967691` nicht mehr: mit dem korrigierten Klassifikator kippt das Urteil über dem Tausch (Tabelle unter DoD (3), in diesem Lauf erhoben). Kein eigener Eingriff nötig; der Anlass des Lerneintrags ist, dass der Befund als **eigenständiger** geführt wurde |
| Der Kommentar definiert `spitz` als *„das ganze Ziel"*, der Code prüft das erste Zeichen | Review `HIGH-2` | **erledigt** in `6967691` — heute `print (ziel ~ /^<[^<>]*>$/) ? "spitz" : "eingebettet"`, und Fall `209` hält die Bedingung fest; hier A/B gefahren (DoD (2)) |
| Vier lebende Artefakte führen die Aufteilung `7`/`3` | Review `MEDIUM-1`, Verifikation `V-3` | **erledigt in diesem Zug** — `CO-004`, `slice-130`, `welle-10` und die Roadmap tragen jetzt `8`/`2` mit dem Grund (die Form-Regel kennt keine Namen); dazu die verschobenen Zeilenangaben in `CO-004` |
| `internal/emit/readme.go` steht nicht in der Plan-Tabelle | Review `LOW-1`, Verifikation `V-5` | **hier vermerkt**, §3 unangetastet (*Was ging anders als geplant*); der Termin für die Regel liegt bei [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), neunter Posten |
| Der Kopf von Fall `207` beschreibt eine Mutation, der `sed` erreicht zwei Zeilen | Review `LOW-2` | **weiter offen, ohne eigenen Schnitt** — für das Verdikt des Treibers folgenlos (`narrow_sensor` wählt `test-bats`, die Go-Stufe läuft nicht), und der Fall wird beim Fall von [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md) ohnehin zum ersten Mal mechanisch gefahren. Sein Ort ist dann [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md)s Lauf, nicht dieser |
| Die Ebenen-Entscheidung (Emitter ↔ emittierter Prüfbereich) ist unbelegt | Review `LOW-3` | **erledigt** in `6967691` — die Begründung steht am Code; Risiko 2 in §6 trägt die Messung |
| `CO-004` zitiert verschobene Zeilennummern | Review `LOW-4` | **erledigt in diesem Zug** — `command grep -n '^@test' test/courseset-fixture.bats` → `59`, `77`, `93`, `165`; die Fall-**Nummern** `not ok 40`/`41` waren und bleiben richtig |
| `slice-115` zitiert `not ok 71`/`72` aus einer datierten Sonde | Review `LOW-4`, zweiter Fundort | **als Protokoll kenntlich gemacht**, nicht korrigiert — die Zahlen sind das Ergebnis **jenes** Laufs; die Einfügung dieses Slice verschiebt jede bats-Nummer ab `44` um eins, und das steht jetzt dort |
| Die Zusagen dieses Slice liegen zur Hälfte außerhalb von `make comment-claims` | Verifikation `V-4` | **weiter offen, benannt** — der Prüfbereich ist Gegenstand von [slice-070](../open/slice-070-comment-claims-pruefbereich.md); die Richtigkeit der bats-Stelle hängt heute an einem Rollen-Durchgang und an keinem Sensor |
| `make mutate` ist der einzige Sensor dieses Slice ohne mechanischen Lauf | Verifikation `V-6` | **weiter offen, mit Träger** — der Abbruch hängt an [`CO-004`](../../carveouts/done/CO-004-emitter-klassifikation-offen.md), dessen Folge-Slice [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md) ist; ich habe den tragenden Arm des Ersatzes selbst gefahren (DoD (2)) |
| Antwort (b) ohne Folge-Slice | Verifikation `V-2` | **entschieden: (b) gestrichen** (DoD (3) oben) |
| Risiko 3 hat keinen gültigen vorformulierten Ausgang | Verifikation `V-1` | **entschieden: weiter offen** (§6), mit dem Register-Träger [slice-137](../in-progress/slice-137-beobachtungs-register-bekommt-seinen-ort.md) |

### Folge-Slices

**Keiner neu.** Die verbliebenen zwei Befunde trägt
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md), der ohnehin unmittelbar
nach diesem Slice läuft; die zwei *weiter offen*-Posten oben zeigen auf bestehende Pläne.

### Übergabe — ein Bau-Problem mit drei Fundstellen und einem vorbereiteten Ort

**Kein Lauf in `make gates` hat den realen Vorlagen-Satz UND die Emit-Regel zugleich**, und die
Ursache ist eine Zeile: `cat .dockerignore` → `.git`, `.harness`. Die go-test-Stufe sieht den
vendored Satz nicht, die bats-Stufe hat keine Go-Toolchain. **Dieselbe Ursache trägt drei
unabhängig gefundene Befunde:** `docs/reviews/2026-08-26-slice-099-review.md` `F-3` (der
Gate-Tabellen-Wächter misst über der synthetischen Fixture),
[slice-110](../open/slice-110-erfassungs-waechter-fall-meldung-grenze.md) DoD (3) Posten (e)
(dieselbe Fixture-Grenze, als **Meldung** geschnitten) und der Rest dieses Slice. **Der Ort ist
vorbereitet und nicht erfunden:** slice-110 §4 benennt die Rückführung vorab — *„`in-progress` →
`next`, wenn der Ausgang von (e) den **Docker-Build-Kontext** berührt … dann ist die
Fixture-Grenze kein Meldungs-Problem, sondern ein Bau-Problem, und der Schnitt läuft zwischen
*Grenze nennen* und *Grenze schließen*"*. Dieser Slice ist die **dritte** Instanz und damit das
Argument, den Schnitt *Grenze schließen* zu ziehen, statt ihn ein drittes Mal zu benennen. **Was
diese Übergabe nicht ist:** ein Slice-Plan. Der entsteht im Planungs-Lauf, nicht in einer
Closure-Notiz.

### Was diese Closure nicht belegt

[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) ist am `HEAD` dieses Slice
**weiterhin gebrochen** — `make full-smoke; echo $?` → **2**, mit
`full-smoke: FEHLER — make gates im emittierten Repo ist NICHT Exit 0 (LH-FA-01 Happy-Path
verletzt)`. Das ist kein Versäumnis dieses Slice: seine DoD (1) schließt die Restmenge ausdrücklich
aus. Es ist der Grund, warum die [welle-10](../welle-10-re-baseline.md)-Closure diesen Slice
**nicht** als Beleg für den Happy Path führen darf — eingelöst wird er erst mit
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md) DoD (3), das den
**gemeinsamen** Nachweis führt. Derselbe Satz steht in welle-10 §4, damit er dort gelesen wird und
nicht nur hier.

### Verifikation dieser Closure

`make smoke`, `make -k gates` und `make full-smoke` sind über dem Arbeitsbaum dieser Closure
gefahren und oben zitiert; `make gates` bleibt an den zwei Carveout-Stellen rot, und **das ist kein
Closure-Kriterium dieses Slice** (DoD (4): *„soweit die Welle es zulässt"*). Ein zweiter
Review-Durchgang nach Modul 10 hat **nicht** stattgefunden; was den blockierenden `HIGH-1`
schließt, ist die Fix-Runde `6967691` **plus** die zwei unabhängigen Nachmessungen — die der
Verifikation und die dieses Laufs. Das ist die Grenze dieser Closure, und sie steht hier, weil sie
sonst nirgends stünde.

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `internal/emit/` (eigener Zuschnitt, eigene
Tests, eigene Ziel-Form — drei von drei Achsen) und `test/` (eigener Zuschnitt, eigene
Werkzeugkette — zwei von drei). Beide erfüllen die Schwelle ≥ 2; keine ist zu grob geschnitten.

**Vorgelagert — offene Beobachtungen sichten:** das Repo führt **kein** Beobachtungs-Register —
eine `observations.md` unter `docs/plan/planning/` existiert nicht, und ob es entsteht, hängt an
derselben Dogfood-Frage, die dieser Slice nicht entscheidet (§1). Keine Treffer, und der Grund ist
die fehlende Datei, nicht ein leeres Register.

Alle berührten Sub-Areas GF: `internal/emit/` und `test/` gehören zum Greenfield-Bestand; der
Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md). Der Modus-Begründungsblock
entfällt damit nach dem *Umfang*-Absatz oben.
