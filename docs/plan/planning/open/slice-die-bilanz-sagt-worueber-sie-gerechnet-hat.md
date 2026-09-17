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

**Übernimmt:** `slice-071-bilanz-nennt-ihren-bestand`.

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
2. **Die Lagen-Trennung wird im Exit-Code statt im Text gesucht.** *Absehbar:* entfallen, wenn die
   Tests allein den geschriebenen Text lesen; sonst Rückführung nach §4.
3. **Die Angabe neben der Zahl greift über die gezählte Menge hinaus.** *Absehbar:* entfallen,
   wenn ein Test mit einer nicht parsenden Zeile die Angabe hält.
4. **Der fehlende Ablageort bleibt maskiert**, weil das `make`-Ziel sein Verzeichnis vorher
   anlegt. *Absehbar:* entfallen, wenn der Test das Unterkommando direkt mit einem freien Pfad
   aufruft statt über das `make`-Ziel.

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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
