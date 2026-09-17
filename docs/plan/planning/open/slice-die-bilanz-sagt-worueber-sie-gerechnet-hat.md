# Slice slice-die-bilanz-sagt-worueber-sie-gerechnet-hat: Fehlender Ablageort, leerer Bestand und Bestand ohne Zähler sind in der Ausgabe von `span-report` dreierlei

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht beobachtet keine Closure-Bedingung mehr, als diese DoD belegt.

**Bezug:**
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (*Accepted* — die Erfassungs-Policy,
deren Bilanz hier ausgegeben wird),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (*Accepted* — sie hält fest, dass
jede der drei Größen ihre eigene Angabe braucht; die Bestandszeile ist keine der drei),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Ausgabe, die *nichts gefunden* und *nichts zu finden* gleich schreibt, behauptet mehr, als sie
gemessen hat),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(eine Zahl nennt die Menge, über die sie spricht — hier auf die Ausgabe eines Werkzeugs angewandt).

**Berührte Spec-Stellen:**
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 — der
Slice **liest** die Feld-Bedeutungen; geschrieben wird §5 hier nicht.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die Ausgabe von `make span-report` trennt *nichts gefunden* von *nichts zu finden*,
begründet jede ihrer Leeren mit einer Ursache, die auf den gemeldeten Zustand zutrifft, und ihre
Bestandszeile benennt die Menge, die sie zählt.

**Übernimmt:** — nichts. Die Übernahme von `slice-071-bilanz-nennt-ihren-bestand` ist gestrichen.

### Die Übernahme ist gestrichen, der Gegenstand bleibt beim Geber

Eine Übernahme von **einem** Geber ist keine Gruppierung, sondern ein Identitäts-Wechsel. Verlangt
wird er von keiner Quelle:
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
setzt die Namens-Form für jede **neu vergebene** Kennung, *der Bestand behält seine Nummer*.
Bezahlt würde er mit einer vollständigen Stilllegung des Gebers — ein Ausgang für jedes seiner
Risiken, `Gegenstand:`-Zeile, Register-Beleg, Closure-Notiz, `git mv` —, also mit einem
Closure-Vorgang für einen Gegenstand, den derselbe Plan unverändert weiterträgt.

**Gemessen, was dieser Plan über den Geber hinaus führt: nichts.** Beide tragen dieselben drei
Liefer-Punkte, (1) und (3) im gleichen Wortlaut; **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
grep -cE '^- \[ \] \*\*\(' docs/plan/planning/next/slice-071-bilanz-nennt-ihren-bestand.md              # 3
grep -cE '^- \[ \] \*\*\(' docs/plan/planning/open/slice-die-bilanz-sagt-worueber-sie-gerechnet-hat.md  # 3
```

**Folge:** `slice-071-bilanz-nennt-ihren-bestand` bleibt unter seiner Kennung in `next/` und führt
den Gegenstand weiter. **Dieser Plan wird in Stufe 2b stillgelegt** — `git mv` nach `done/`, §7
trägt `Gegenstand: entfallen — der Gegenstand bleibt bei slice-071-bilanz-nennt-ihren-bestand`,
die Liefer-Punkte bleiben leer (Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice,
dessen Gegenstand ein anderer übernimmt, Wegfall-Hälfte). Gelöscht wird er nicht: Löschen machte
seine Kennung ununterscheidbar von einer, die es nie gab.

**Der Befund, je mit dem Kommando neben der Aussage** — **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
# der Bestand wird mit einem Glob gelesen; ueber einem fehlenden Verzeichnis
# meldet der Aufruf weder Treffer noch Fehler
grep -c 'filepath.Glob' internal/report/report.go
# der Ablageort ist ein Argument, also ein Wert, den ein Aufrufer vertippen kann
grep -c 'return args\[0\], nil' cmd/ai-harness-init/span_report.go
# das vorangestellte mkdir des make-Ziels deckt allein den Pfad, den es selbst mountet
grep -c 'mkdir -p .harness/state/spans' Makefile
# die Bestandszeile nennt eine Zahl, ohne zu sagen, worueber sie spricht
grep -c 'Bestand: %d Sitzung' internal/report/report.go
```

Über einem Ablageort, den es **nicht gibt**, kehrt `Aggregiere` mit einer leeren Bilanz zurück,
`Schreibe` formt sie zu *„Keine Rolle traegt Token."*, und der Aufruf endet über den
Erfolgs-Zweig — dieselbe wohlgeformte Ausgabe wie über einem leeren Ablageort. Die Bestandszeile
zählt die verschiedenen `session`-Werte der **lesbaren** Zeilen; wie sich die Summe über diese
Ströme verteilt, sagt sie nicht.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Exit-Code trägt die Unterscheidung.** Welche Zahl welche Bedeutung hat, ist Gegenstand von
  `slice-079-exit-code-vertrag`; eine zweite Festlegung daneben driftete von ihr weg, bevor die
  erste steht. Die Adresse ist ein **Folge-Slice**, die Unterscheidung steht im **Text**.
- **Der Grund-Satz zur Mechanik des Agenten-Werkzeugs bleibt, wo er trägt** — über einem Bestand
  **mit** Agent-Läufen und ohne Zähler. Er bleibt als **Bestand** bewusst stehen, samt seinem
  Messort in [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh); wer ihn
  wegnimmt, nimmt einem fremden Wächter die Zähne.
- **Der Wortlaut der Bestandszeile wird hier nicht festgelegt**, nur ihre Wahrheitsbedingung. Eine
  Angabe, die über die gezählte Menge hinausgreift, wäre selbst die Klasse, die dieser Slice
  behebt — die Wortwahl ist ein **anderer Vorgang**, falls sie je einen braucht.
- **Keine Änderung am Span-Schema und an §5.** Was ein Feld bedeutet, steht im Technik-Stratum;
  dieser Slice liest es — **Schicht-Abgrenzung**.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Drei Liefer-Punkte**, jeder mit dem Kommando, das ihn **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Jede Leere-Lage der Ausgabe ist von den anderen unterscheidbar, und jede Begründung
      trifft ihren eigenen Fall.** Die Lagen sind: **Ablageort existiert nicht** · **Ablageort
      existiert und ist leer** · **Bestand ohne Verbrauchs-Zähler**. Welche vorliegt, steht im
      **Text**; wo der Text eine Ursache nennt, ist es eine, die in genau diesem Zustand vorliegen
      kann — die Träger-Ursachen gehören in die Träger-Meldung eine Ebene höher.
      **Rot:** ein Go-Test über [`internal/report`](../../../../internal/report/report.go) und
      [`cmd/ai-harness-init/span_report.go`](../../../../cmd/ai-harness-init/span_report.go) mit
      einem Pfad, den es nicht gibt — er fällt, sobald die Ausgabe wieder die eines leeren
      Bestands ist; dazu je ein `test/mutations/`-Fall, der die Unterscheidung entfernt und der
      die Träger-Ursachen in die Bestands-Meldung zurückschreibt.
- [ ] **(2) Ein Bestand ohne einen einzigen Agent-Lauf ist eine eigene Lage.** Er bekommt eine
      Meldung, die das sagt, statt der Mechanik des Agenten-Werkzeugs die Schuld an einer Leere zu
      geben, die sie nicht verursacht hat.
      **Rot:** ein Go-Test über `report.Schreibe` mit einem Bestand aus reinen Werkzeug-Zeilen — er
      fällt, sobald die Ausgabe wieder den Mechanik-Satz trägt; dazu ein `test/mutations/`-Fall,
      der die Lagen zusammenlegt, und der bestehende `full-smoke`-Fall über dem Grund-Satz fällt
      weiterhin über seinem eigenen Verify-Pfad.
      **Warum das kein Teil von (1) ist:** die Lage sitzt in derselben Verzweigung, aber ihr
      Gegenbeispiel ist ein anderer **Bestand**, nicht ein anderer Pfad.
- [ ] **(3) Die Bestandszeile nennt die Menge, die sie zählt — und die genannte ist die gezählte.**
      Die Angabe steht **neben** der Zahl, nicht in einer Fußnote und nicht im Kopf-Kommentar.
      Wahrheitsbedingung: gezählt werden die verschiedenen `session`-Werte der Zeilen, die sich
      parsen lassen.
      **Rot:** ein Go-Test mit einem Bestand, in dem eine Zeile nicht parst — die Angabe neben der
      Zahl muss ihn ausschließen; dazu ein `test/mutations/`-Fall, der die Angabe über die gezählte
      Menge hinaus aufweitet.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: berührt ist der Vertrag von
      [`make span-report`](../../../../harness/sensors/span-report.md) — die Sensor-Datei nennt
      danach die drei Lagen und die Menge der Bestandszeile.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
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
| [`internal/report/report.go`](../../../../internal/report/report.go) | update | die drei Lagen und die Angabe neben der Bestandszahl |
| [`cmd/ai-harness-init/span_report.go`](../../../../cmd/ai-harness-init/span_report.go) | update | der fehlende Ablageort ist eine eigene Lage, nicht der Erfolgs-Zweig |
| [`internal/report/report_test.go`](../../../../internal/report/report_test.go) | update | ein Test je Lage und je Bestand |
| [`test/mutations/`](../../../../test/mutations) | neu | je ein Fall für das Zusammenlegen der Lagen und für die aufgeweitete Angabe |
| [`harness/sensors/span-report.md`](../../../../harness/sensors/span-report.md) | update | der Sensor-Vertrag nennt die drei Lagen |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Die Lagen werden **einmal** unterschieden — an der Stelle, an der der Bestand gelesen wird —,
  und die Meldung folgt daraus. Zwei Verzweigungen für dieselbe Frage wären zwei Quellen für
  denselben Zustand.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei, und der übernommene
Slice liegt in `done/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Lagen-Trennung verlangt einen
  Exit-Code-Vertrag, um überhaupt beobachtbar zu sein. Dann hängt dieser Slice an
  `slice-079-exit-code-vertrag` und wird danach neu geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Der bestehende `full-smoke`-Zahn über dem
  Grund-Satz lässt sich nicht erhalten, ohne die neue Lage zu verwässern.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün, und `make mutate` meldet **keinen** Befund — auch nicht über dem
   bestehenden Fall zum Grund-Satz.
2. Die drei Lagen sind je einmal mit gelesener Ausgabe belegt, und die Rot-Kommandos aus §2 stehen
   im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der neue Text nimmt dem bestehenden `full-smoke`-Fall die Zähne**, weil sein Grund-Satz
   verschwindet. *Absehbar:* entfallen, wenn der Satz an seinem Messort bleibt und der Fall dort
   weiter fällt.
   — **Ausgang: weiter offen.** Der Text wird von diesem Plan nicht mehr geschrieben, die Klasse
   bleibt aber für jeden, der ihn anfasst: ein Fall, der einen Wortlaut misst, verliert seine Zähne
   an einer berechtigten Änderung. **Ins Beobachtungs-Register gewandert** als Zuordnung zu
   [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
   (`verkörpert`). **Keine Beleg-Datei angelegt:** benannt, nicht erlitten — der Text ist nie
   entstanden.
2. **Die Lagen-Trennung wird im Exit-Code statt im Text gesucht.** *Absehbar:* entfallen, wenn die
   Tests allein den geschriebenen Text lesen; sonst Rückführung nach §4.
   — **Ausgang: entfallen.** Das Risiko hing am Ausführungs-Weg **dieses** Plans (Tests, die den
   Text statt den Exit-Code lesen); dieser Weg entsteht nicht. Wer den Gegenstand arbeitet,
   schneidet ihn in `slice-071-bilanz-nennt-ihren-bestand` neu und trifft die Wahl dort.
3. **Die Angabe neben der Zahl greift über die gezählte Menge hinaus.** *Absehbar:* entfallen,
   wenn ein Test mit einer nicht parsenden Zeile die Angabe hält.
   — **Ausgang: entfallen.** Die Angabe neben der Zahl bleibt beim Gegenstand:
   `slice-071-bilanz-nennt-ihren-bestand` führt sie in seinem Liefer-Punkt (3) — *die Bestandszeile
   ist eindeutig* — und grenzt sie in seinem §6 gegen die ungemessene Streuung ab. Dieser Plan
   fügt dem nichts hinzu, was mit ihm stürbe.
4. **Der fehlende Ablageort bleibt maskiert**, weil das `make`-Ziel sein Verzeichnis vorher
   anlegt. *Absehbar:* entfallen, wenn der Test das Unterkommando direkt mit einem freien Pfad
   aufruft statt über das `make`-Ziel.
   — **Ausgang: entfallen.** Auch dieses Risiko hing am Ausführungs-Weg dieses Plans (Aufruf über
   das `make`-Ziel statt über das Unterkommando); er entsteht nicht. Die Frage stellt sich erst
   wieder dem Lauf, der den Gegenstand in `slice-071-bilanz-nennt-ihren-bestand` arbeitet.

## 7. Closure-Notiz

**Gegenstand:** entfallen: Die Gruppe ist gestrichen. Der Gegenstand bleibt bei
`slice-071-bilanz-nennt-ihren-bestand`, der ihn unverändert führt und nicht geschlossen ist —
übertragen war er nie (§1: `Übernimmt: — nichts`).

**Stillgelegt ohne Lieferung** — Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice,
dessen Gegenstand ein anderer übernimmt, Wegfall-Hälfte: *Entfällt der Gegenstand ganz, trägt die
Zeile statt einer Kennung den Grund.* Die Liefer-Punkte in §2 bleiben **leer**: Dieser Slice hat
nichts geliefert. `Verantwortlich:` bleibt stehen.

**Keine Adresse zeigt ins Leere.** Vor dem Move nannte nur diese Datei selbst ihre Kennung; nach
dem Move ist die Ausgabe über der lebenden Plan- und Norm-Fläche leer:

```sh
git grep -l 'slice-die-bilanz-sagt-worueber-sie-gerechnet-hat' -- \
  'docs/plan/planning/open' 'docs/plan/planning/next' 'docs/plan/planning/in-progress' \
  'docs/plan/planning/*.md' 'docs/plan/adr' 'spec' 'harness' 'AGENTS.md' '.claude'
```

**Wellenlos.** Der Kopf führt keine Welle; die Roadmap führt wellenlose Arbeit nicht
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht), und diese Closure trägt sie allein. Die
Streichung der Gruppe ist damit keine Umplanung im Sinne des Drift-Logs — dort steht, was **eine
Welle** bewegt.

**Was hat funktioniert:** Der Weg aus `open/` ist derselbe wie aus `next/`, und er kostet nichts
außer dieser Notiz: Die Kennung bleibt auffindbar, statt gelöscht zu werden, und die
`Gegenstand:`-Zeile sagt an ihrer Form, dass hier nichts übernommen wurde, sondern etwas wegfiel.

**Was ging anders als geplant:** Der Plan war **zu früh**, nicht zu spät. Er entstand im Schnitt
der sechs Gruppen-Slices und wurde von den Runden danach — Architect-Verdikt, zwei Reviews, die
Stufe-2a-Entscheidung — wieder zurückgenommen, ohne je beansprucht worden zu sein. Das ist die
Gegenrichtung zum Muster *tote Slices*: Dort kommt die Prüfung zu spät, hier kam der Plan zu früh.

**Steering-Loop-Eintrag:** **gezählt, nicht verkörpert** — kein Zielort, darum **kein**
`liegt in`-Feld (`grundlagen-traceability.md` §Herkunfts-Anker). Eine Regel dafür schreibt dieser
Lauf nicht: Ob ein Schnitt erst nach dem Verdikt entstehen darf, ist eine Entscheidung über den
Planungs-Ablauf und gehört nicht in die Closure des Plans, den sie beträfe.

**Beobachtungs-Register** (`../observations/`): neu angelegt
[`BEO-ALL/plan-entsteht-vor-dem-verdikt-ueber-seinen-gegenstand`](../observations/BEO-ALL/plan-entsteht-vor-dem-verdikt-ueber-seinen-gegenstand/observation.md)
mit dem Beleg `evidence/slice-die-bilanz-sagt-worueber-sie-gerechnet-hat.md`, Stand `offen`. Der
Eintrag grenzt sich dort gegen
[`BEO-ALL/geplanter-slice-wird-nie-gearbeitet`](../observations/BEO-ALL/geplanter-slice-wird-nie-gearbeitet/observation.md)
ab: **zwei** Klassen, nicht ein Name für beides. Der zweite Plan derselben Gelegenheit steht unter
*Benannt, nicht gezählt*.

**Lese-Schritt** (Repo ohne Wellen-Betrieb, `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht): Kein Eintrag erreicht mit dieser Closure 3×, und kein Eintrag über der Schwelle steht
ohne Ausgang — dasselbe Kommando wie in
[`slice-090`](slice-090-freshness-audit-im-ziel.md) §7, Ausgabe leer.

**Die drei Paarungen.** (a) Anker-Paarung: kein Eintrag trägt `liegt in`, sie hat keinen
Gegenstand. (b) Folge-Slice-Paarung: kein Folge-Slice genannt. (c) Register-Paarung: beide
zitierten Beobachtungen existieren als Verzeichnis und tragen je mindestens einen Beleg.

**Was diese Closure nicht trägt:** Review und Verifikation am Gegenstand — es gibt keinen Diff,
den sie prüfen könnten. Geprüft ist die **Form** der Stilllegung durch `make docs-check` (Modul
`structure`, `open-tasks-require-marker`) und der Gesamtstand durch `make gates`.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/report/`, `cmd/ai-harness-init/`,
`harness/sensors/` und `test/mutations/` — alle in `*`. `harness/tools/` (`TOOLS`) wird für den
bestehenden `full-smoke`-Zahn gelesen; `.codex/` (`CODEX`) ist nicht berührt. Beide berührten
Sub-Areas erfüllen das Inklusionskriterium; ausdifferenziert wird nichts.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die `state.md` des
Eintrags; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | 17 | geplant | DoD 1 — eine Begründung, die auf ihren Fall nicht zutrifft |
| [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | 6 | geplant | DoD 3 — die Bestandszahl spricht über die Sitzungen, nicht über den Ablageort |
| [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) | 4 | verkörpert | §6 Risiko 1 |
| [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md) | 16 | verkörpert | die Bestandszeile ist genau diese Klasse in einer Werkzeug-Ausgabe |

Keiner der vier erreicht **mit diesem Slice** erstmals 3×; ein eigener Folge-Slice entsteht daraus
nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
