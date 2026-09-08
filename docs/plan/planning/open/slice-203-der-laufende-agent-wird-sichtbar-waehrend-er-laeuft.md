# Slice slice-203: Der laufende Agent wird sichtbar, während er läuft

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice legt **einen** Bericht an; sein Beleg ist ein Lauf über einem
realen Strom und ein Gegenbeispiel-Paar, und beides steht in seiner eigenen DoD. Ein
Closure-Trigger darüber schriebe sie ab (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht).

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist der Span-Bestand **dieses** Repos unter
`.harness/state/spans/`. Was ein emittiertes Repo an Beobachtungs-Werkzeugen bekommt, entscheidet
der Slice, der die Tool-Ebene entscheidet — dort ist die Frage auch nicht dieselbe, weil ein frisch
gebootstrapptes Ziel keinen Bestand hat, über den ein Bericht urteilen könnte.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der
tragende Vertrag: ein Bericht prüft nichts und färbt nichts rot — er steht außerhalb `make gates`
und außerhalb jeder Prerequisite-Kette, wie `span-report` und `hook-overhead`),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Docker-only: der
Träger wird über `make host-bin` gebaut, der Host bekommt keine neue Abhängigkeit),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (die Erfassungs-Policy, deren Bestand
dieser Bericht liest — er erweitert sie nicht),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (Festlegung 2:
der Träger ist das Produkt-Binär; dieser Slice hängt sein Unterkommando an denselben Träger, statt
ein zweites Werkzeug daneben zu stellen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl der Ausgabe nennt ihre Bezugsmenge; der Span-Bestand wandert mit jedem Lauf und liefert
keine Erwartungswerte)

**Berührte Spec-Stellen:** [`SPEC-011`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
· `SPEC-012` · `SPEC-013` — die drei Listen-Felder (`slice`, `requirement`, `adr`), die die
Kopfzeile der Sicht auswertet. Der Slice **liest** sie; er ändert das geschlossene Schema nicht.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-08.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein laufender Agent wird beobachtbar, **während** er läuft — `make span-watch` liest den
jüngsten Strom unter `.harness/state/spans/` und sagt in einem Blick, wer gerade woran arbeitet
und ob der Lauf **arbeitet**, **STILL** steht (kein Call im Fenster — ein blockierendes Kommando
oder ein Hänger) oder **POLLT** (die Mehrheit der Calls fällt auf denselben Gegenstand).

Der Anlass ist gemessen und liegt als
`BEO-ALL/hintergrund-lauf-wird-gepollt-statt-abgewartet` im Beobachtungs-Register: Zwei
Implementer-Läufe zwei Tage auseinander lasen 81 % bzw. 97 % ihrer Lese-Zugriffe auf
Hintergrund-Ausgabedateien. Heute fällt das erst **nach** dem Lauf auf, und nur dem, der den
Bestand von Hand durchsucht.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Gate, keine Prerequisite-Kette, kein Eintrag in `make gates`.** Ein Bericht prüft nichts
  und färbt nichts rot; ein Gate über ihm wäre eines über einem Prüfbereich, den ein frischer
  Checkout gar nicht hat — der Span-Bestand ist gitignored und maschinenlokal
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  Der Punkt steht hier, weil er sonst beim Schreiben hineinwandert: `span-check` liegt **in**
  `gates`, und ein neues `span-*`-Ziel daneben zu hängen ist der naheliegende Griff.
- **Keine Änderung an der Erfassung** — `span-emit`, `internal/span/` und die Feld-Tabelle
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  bleiben unangetastet. Das Schema ist **geschlossen**; ein neues Feld ist ein Eintrag dort und
  damit ein **anderer Vorgang**. Dieser Slice kommt mit den Feldern aus, die bereits geschrieben
  werden.
- **Keine Aussage darüber, warum ein Lauf pollt, und keine Abhilfe dagegen.** Ob das Werkzeug ein
  Warte-Mittel führt, das der Lauf nicht wählt, und ob eine Regel ihn darauf verpflichten sollte,
  ist eine Frage an den Steering Loop und nicht an einen Bericht — **Bestand bleibt bewusst
  stehen**. Der Slice macht das Muster sichtbar; der Ausgang der Beobachtung wird beim
  Lese-Schritt zugewiesen, wenn sie die Schwelle erreicht.
- **Keine Bereinigung und keine Rotation des Span-Bestands.** `make span-clean` gibt es, und wann
  ein Bestand altert, ist eine eigene Frage — **ein anderer Vorgang**. Dieser Slice liest nur.
- **Nichts Emittiertes.** Weder `internal/emit/templates/` noch das emittierte `make gates`
  bekommen dieses Ziel — **Schicht-Abgrenzung**, und beim Review sofort prüfbar: berührt der Diff
  `internal/emit/`, ist der Slice aus seiner Schicht gelaufen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Liefer-Punkt 1 — der Träger.**

- [ ] `span-watch` existiert als **Unterkommando des Produkt-Binärs** und `make span-watch` ruft
      es mit `host-bin` als Prerequisite — dieselbe Form wie `span-report`
      ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
      Festlegung 2). Das Ziel steht **nicht** in `make gates` und in **keiner**
      Prerequisite-Kette; belegt durch `grep` auf das `gates`-Ziel und seine Kette, nicht durch
      Augenschein.
- [ ] Der Name in der Rezept-Zeile hat einen `case` im Dispatch von
      `cmd/ai-harness-init/main.go` — `test/unterkommando-kopplung.bats` deckt das bereits für
      jeden Aufrufer und muss den neuen Namen ohne Änderung mittragen; läuft der Fall nicht von
      selbst mit, ist **das** der Befund.
- [ ] Die Kopfzeile nennt Rolle und Slice aus dem Strom. **`slice`, `requirement` und `adr` sind
      Listen** (`SPEC-011`/`012`/`013`), keine Zeichenketten — ein Leser, der sie als
      Zeichenkette liest, findet nichts und meldet stumm „leer". Gegenbeispiel rot gesehen: ein
      Strom mit gefülltem `slice` muss den Wert **anzeigen**; der Prototyp zeigt an derselben
      Stelle nichts.
- [ ] Ohne Bestand bricht der Lauf ab und erfindet keine Folge — dieselbe Linie, die
      `harness/tools/hook-overhead.sh` zieht (*„ohne Bestand gibt es keine zu messen"*). Eine
      Auswertung über der leeren Menge wäre sonst wahr, ohne etwas gemessen zu haben.

**Liefer-Punkt 2 — das Urteil und seine Schwelle.**

- [ ] Die drei Zustände **arbeitet · STILL · POLLING** werden über einem realen Strom
      unterschieden, mit einem Fenster als Parameter.
- [ ] **Die Polling-Schwelle trägt beide Richtungen, je einmal rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): (a) ein Strom mit dem gemessenen Muster wird
      als POLLING gemeldet; (b) ein **legitimer** Lauf, der zurecht oft denselben Gegenstand
      liest, wird **nicht** gemeldet. Die Schwelle ist ein **Urteil**, kein Messwert — welcher
      Fall (b) trägt, ist Teil der Lieferung und nicht der Ausrede; ohne ihn ist die Schwelle
      eine Zahl, die nur ihren eigenen Anlassfall trifft.
- [ ] Jede Zahl der Ausgabe nennt ihre Bezugsmenge (Fenster, Nenner) — der Bestand wandert mit
      jedem Lauf, und eine Zahl ohne Bezugsmenge ist hier nie ein Erwartungswert
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

**Liefer-Punkt 3 — die Einordnung im Harness-Einstieg.**

- [ ] [`harness/README.md`](../../../../harness/README.md) §Sensors führt `span-watch` im
      Absatz **Nicht-Gate-Verify** neben `span-report` und `hook-overhead` — mit der ausdrücklichen
      Aussage, dass es kein Gate ist, **und** mit seinen Grenzen: der Bestand ist maschinenlokal
      und rotiert, das Fenster ist eine Wahl, und die Schwelle ist ein Urteil.

**Pro Slice konstant — zählt nicht in die drei:**

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register ([`../observations/`](../observations/)) fortgeschrieben — **kein
      Zähler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls
      eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice läuft
      **ohne Welle**, sie werden also hier geprüft, nach dem `git mv`.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/span_watch.go` | neu | Einstiegspunkt des Unterkommandos, neben `span_report.go` |
| `cmd/ai-harness-init/main.go` | update | ein `case "span-watch":` im Dispatch — sonst fällt der Name in den Init-Pfad |
| `internal/span/` | update | die Auswertung (jüngster Strom, Fenster, drei Zustände); die Urteils-Logik gehört zur Bibliothek, nicht in `cmd/` |
| `Makefile` | update | Ziel `span-watch: host-bin`, **nicht** in `gates` |
| `cmd/ai-harness-init/span_watch_test.go` bzw. `internal/span/*_test.go` | neu | die zwei Richtungen der Schwelle über synthetischen Strömen |
| `test/mutations/<N>-span-watch-*.sh` | neu | ohne Fall ist der neue Wächter unbewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| [`harness/README.md`](../../../../harness/README.md) | update | Liefer-Punkt 3 |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert, `Verantwortlich:` ist gesetzt, das
WIP-Limit des Rolleninhabers ist frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Fall (b) der Schwelle — ein
  legitimer Lauf, der zurecht oft denselben Gegenstand liest — lässt sich nicht über einem
  synthetischen Strom herstellen, sondern verlangt eine zweite Erfassungs-Achse. Dann trägt
  Liefer-Punkt 2 einen eigenen Schnitt.
- `in-progress` → `open` (blockiert — Carveout?): Die Auswertung braucht ein Feld, das das
  geschlossene Schema nicht führt. Dann liegt der Slice hinter einem Spec-Eintrag, und der ist
  nach §1 ausdrücklich ein anderer Vorgang.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(1)** `make span-watch` läuft über einem realen Strom und meldet
die drei Zustände; `make gates` ist grün und das neue Ziel ist in keiner Prerequisite-Kette —
beides aus einem Lauf belegt, nicht behauptet. **(2)** Beide Richtungen der Schwelle sind je
einmal **rot gesehen** und als Fall abgelegt. Dazu der Lerneintrag in einer der drei Formen
(geschärfte Regel · neuer Sensor · benannte Spec-Lücke).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Schwelle trifft nur ihren Anlassfall.** „Mehr als die Hälfte, mindestens 10" ist am
  gemessenen Strom gesetzt und kann einen legitimen Lauf als POLLING melden — ein Bericht, der
  Fehlalarm gibt, wird abgeschaltet und misst dann gar nichts. — **Ausgang:** <offen>
- **Der Prüfgegenstand ist maschinenlokal und rotiert.** Ein Test über dem echten Bestand wäre auf
  einem anderen Checkout leer und still grün; die Fälle müssen über synthetischen Strömen laufen.
  — **Ausgang:** <offen>
- **Der Bericht sieht womöglich sich selbst.** Der beobachtende Lauf schreibt selbst Spans in
  denselben Bestand; „der jüngste Strom" kann der eigene sein. — **Ausgang:** <offen>
- **Ein Bericht ohne Sensor altert unbemerkt.** Ändert sich die Feld-Form des Schemas, meldet
  nichts, dass die Kopfzeile leer läuft — genau der Defekt, den der Prototyp bereits hat.
  — **Ausgang:** <offen>

## 7. Closure-Notiz

<!-- Wird bei der Closure gefüllt — Planner, nicht der Lauf, der die Arbeit tat
(AGENTS.md §3.10). -->

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Der Träger
liegt in `cmd/` und `internal/`, das Ziel im `Makefile` — `harness/tools/` (`TOOLS`) ist als Pfad
**nicht** berührt, weil dieser Slice kein Skript dort anlegt, sondern ein Unterkommando des
Trägers; `.codex/` (`CODEX`) ist gar nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; die Zähler sind als Dateizahl unter
`evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
Erwartungswerte** —
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2, gelesen am gemergten Stand vom 2026-09-08). Diesen Vorgang betreffen:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `hintergrund-lauf-wird-gepollt-statt-abgewartet` | 1× | offen | **der Anlass** — dieser Slice macht die Klasse sichtbar; er ist **nicht** ihr Ausgang, denn er behebt sie nicht |
| `vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut` | 1× | offen | der Prototyp durchsucht den Bestand mit `grep`, obwohl `internal/span/` ihn bereits liest — genau die Klasse; Liefer-Punkt 1 legt den Einstieg dorthin statt daneben |
| `zusage-ohne-herstellbares-gegenbeispiel` | 2× | offen | die Polling-Schwelle ist der Regelfall: Richtung (b) ist das Gegenbeispiel, das erst noch herstellbar sein muss |
| `neuer-waechter-ohne-mutations-fall` | 1× | offen | der neue Träger braucht seinen Fall in `test/mutations/`, sonst ist er unbewacht |
| `zusicherung-ueber-der-leeren-menge-wahr` | 1× | offen | ein Lauf ohne Bestand — die DoD verlangt Abbruch statt einer stillen Wahrheit |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 3× | offen | über der Schwelle: jede Zahl der Ausgabe muss ihre Bezugsmenge nennen |
| `zaehler-label-nennt-falsche-einheit` | 3× | offen | über der Schwelle: die Ausgabe zählt Calls, Dateien und Fundstellen nebeneinander — jede Zeile nennt ihre Einheit |

**Zwei Einträge stehen über der Schwelle** (`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`,
`zaehler-label-nennt-falsche-einheit`) und warten auf den Lese-Schritt; dieser Slice weist ihnen
keinen Ausgang zu und erhöht sie nicht vorab. Alle Bezeichnungen sind **zitiert**, nicht neu
formuliert.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.
