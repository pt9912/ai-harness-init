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

**Verantwortlich:** —

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
[slice-130](slice-130-emitter-entscheidet-jedes-neue-template.md).

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
`[`welle-NN-results.md`](../done/welle-NN-results.md)` steht unverändert in beiden Bäumen
(`grep -c` je Tag → **1** und **1**), die Neutralisierung feuert also weiter — die neue Fassung hat
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

- [ ] **(1) Die sieben Befunde der Ursache A sind fort, und zwar namentlich geprüft, nicht über
      die Summe.** `make smoke` meldet für `docs/plan/planning/in-progress/roadmap.md`,
      `harness/README.md` und `harness/conventions.md` **keinen** Befund mehr. Die Restmenge ist
      **kein** Erfolgskriterium dieses Slice: sie ist die Ursache B und trägt
      [slice-130](slice-130-emitter-entscheidet-jedes-neue-template.md) — ein Lauf, der beide
      Klassen zugleich grün meldet, ist ein Hinweis, dass eine Klasse anders aufgelöst wurde als
      hier beschrieben, und gehört nachgesehen statt abgehakt.
- [ ] **(2) Die Neutralisierung ist rot gesehen, und ihre Deckungs-Grenze steht am Code.**
      Benannt und einmal gefahren ist, welche Mutation sie fallen lässt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6); der Fall liegt in `test/mutations/`. Der
      Doc-Kommentar sagt im **Indikativ**, was die Neutralisierung hält, und benennt, was sie
      **nicht** hält — insbesondere, ob ein *künftiger* Vorlagen-Zugang mit derselben
      Platzhalter-Form von ihr erfasst wird oder wieder nur von `make smoke`
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
- [ ] **(3) Ein Wächter innerhalb von `make gates` sieht die Klasse, oder seine Abwesenheit ist
      benannt.** Heute liegt der einzige Sensor für diese Drift außerhalb der Gates — das ist die
      Aussage des zitierten Doc-Kommentars und der Grund, warum der Bruch einen ganzen Slice lang
      unbemerkt blieb. Der Slice entscheidet je Antwort: Wächter gebaut (dann trägt er die
      Platzhalter-Form, nicht den Wortlaut) **oder** ausdrücklich nicht gebaut, mit Grund und
      Folge-Slice. Eine dritte Antwort — die Frage nicht stellen — ist ausgeschlossen
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] `make gates` grün, soweit die Welle es zulässt — die offenen Carveouts
      [`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md) und
      [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) bleiben bis zu ihren
      eigenen Folge-Slices bestehen und sind **nicht** Gegenstand dieses Slice.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist —
      [`spec/lastenheft.md`](../../../../spec/lastenheft.md) bleibt dabei **unverändert** (§3).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (die `observations.md` neben den Wellen): das Repo führt **keines** —
      ob es entsteht, hängt an derselben Dogfood-Frage, die dieser Slice nicht entscheidet (§1).
      Das Item entfällt nicht still, sondern mit diesem Grund; er wird in §7 notiert. Dasselbe
      gilt für das Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt
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
| `internal/emit/templates/commands/`, `.harness/skills/` | **unverändert** | der **Text** der emittierten Artefakte ist Gegenstand von [slice-085](slice-085-emittierte-ebene-zieht-nach.md) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) liegt in `done/` — der
Vorlagen-Satz, dessen Platzhalter neutralisiert werden, steht dann fest und wechselt während der
Arbeit nicht. Das WIP-Limit wird mit demselben Übergang frei. Dieser Slice läuft **vor**
[slice-130](slice-130-emitter-entscheidet-jedes-neue-template.md): er trägt sieben der zehn
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
  Platzhalter-Form fällt wieder durch und wird wieder erst von `make smoke` gesehen. — **Ausgang:**
  <entfallen: die Neutralisierung trägt die Form und ist gegen einen erfundenen zweiten Platzhalter
  geprüft | eingetreten: benannte Entscheidung für den Wortlaut, mit Grund am Kommentar und
  Folge-Slice>
- **Der Ausschluss könnte in den emittierten Prüfbereich wandern statt in den Emitter.** Dann
  erbt jeder Adopter einen blinden Fleck in seinem eigenen `d-check`, und der Befund ist gegen
  einen unsichtbaren getauscht — dieselbe Abwägung, die
  [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) für `scan.ignore` führt. —
  **Ausgang:** <entfallen: die Reparatur liegt im Emitter, `internal/emit/templates/d-check.yml`
  unverändert | eingetreten: Begründung nach [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed),
  und die Grenze steht im Config-Kommentar>
- **`make full-smoke` zieht das Asset aus dem Netz** und ist damit an eine Bedingung außerhalb des
  Repos gebunden; `make smoke` allein deckt den zusammengeführten `make gates`-E2E im Ziel nicht
  (der Hinweis steht in seiner eigenen Ausgabe). — **Ausgang:** <entfallen: beide Läufe gelingen
  und sind protokolliert | eingetreten: CO-NNN, solange der Nachweis nicht führbar ist>
- **Die drei Ziele sind Singletons, die der Adopter danach selbst füllt.** Eine Neutralisierung,
  die eine Zeile **löscht** statt sie zu entschärfen, nimmt ihm das Form-Beispiel — genau das, was
  `NeutralizeRoadmap` mit Absicht stehen lässt (*„die Zeile bleibt als Form-Beispiel erhalten,
  traegt aber keinen toten Link"*). — **Ausgang:** <entfallen: jede berührte Zeile steht nach der
  Emission noch, ohne Link | eingetreten: benannte Ausnahme je gelöschter Zeile>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

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
