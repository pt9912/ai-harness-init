# Slice slice-219: Die Archivierung nimmt einen Schlüssel, der keine Welle ist

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Sein Closure-Trigger fordert nichts, was die DoD unten nicht schon belegt —
kein repo-weiter Beleg, kein Replay; damit fehlt das *Mehr*, an dem sich eine Welle entscheidet
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Er ist **Vorbedingung**
der ersten Archivierung, nicht Mitglied einer Welle, die sie vollzieht.

**Bezug:**
[`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (**Accepted** —
Folgepflicht 1 nennt genau diese Betriebsart; Festlegung 2 setzt den Schlüssel, Festlegung 3 nimmt
`untergrenze` den Gegenstand, Festlegung 4 hängt an `haenger`),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — Festlegung 1,
Träger ist das Produkt-Binär; dieser Slice baut in ihm und ändert daran nichts),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Betriebsart, die mehr Ausgänge aufhebt als die benannten, erzeugt ein stilles Grün an einer
fail-closed-Sperre).

**Berührte Spec-Stellen:** `—`. Der Slice baut eine Werkzeug-Fähigkeit; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Das Unterkommando `archive-welle` führt einen Schlüssel, der keine Welle ist, und hebt
dafür genau die vier Ausgänge auf, die an der Welle-Form hängen — keinen weiteren.**

Heute sperrt es. Gemessen am ruhenden Baum, über den Träger aus dem gitignorierten Zustands-Bereich
(`make host-bin` davor):

```sh
.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand
#   Mitglieder (Welle-Feld nennt altbestand): 0
#   wellenlos (seit der letzten Closure):    57
#   fremd (andere Welle, bleibt liegen):     91
#   Review-Reports (ohne Stub):             144
#   Sperren: 4 — der schreibende Lauf braeche ab.
#     [ergebnisnotiz] docs/plan/planning/done/altbestand-results.md fehlt
#     [kein-plan]     kein Welle-Plan 'altbestand*' in docs/plan/planning/done/
#     [untergrenze]   57 wellenlose(r) Slice(s) liegen flach … aber kein …/archiv.zip
#     [haenger]       ein Review-Report soll verschwinden, auf den noch verwiesen wird
```

**Die Einsammel-Regel trägt schon.** Der Schlüssel ist keine Welle, und das Werkzeug sammelt
trotzdem richtig ein: `wellenlos` steht bei 57, `fremd` bei 91, und die Summe ist der geschlossene
Bestand — keine Zeile dieses Slice muss `internal/archive/collect.go` anfassen.

```sh
n=0; for f in docs/plan/planning/done/slice-*.md; do \
  grep -q '^\*\*Welle:\*\* ohne Welle' "$f" && n=$((n+1)); done; echo "$n"   #  57
ls docs/plan/planning/done/slice-*.md | wc -l                                # 148
```

**Was aufzuheben ist, ist benannt und abzählbar.** Der Vorschau-Zweig führt am ruhenden Baum acht
Ausgänge; vier hängen an der Welle-Form bzw. an der fehlenden Untergrenze, und genau diese vier
nennt [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
Folgepflicht 1:

```sh
grep -o 'Kennung: "[a-z-]*"' internal/archive/vorschau.go   # 8 Zeilen
# aufzuheben: ergebnisnotiz · kein-plan · mehrdeutiger-plan · untergrenze
# bleiben:    unsauber · archiviert · kein-slice · haenger
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — jede Zahl wandert mit dem Bestand.

**`haenger` bleibt, und das ist keine Nebenbedingung, sondern der Gegenstand.**
[`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 4
bindet den Vollzug an den Ausgang der Norm-Frage über eingehende Verweise auf Review-Reports; ihr
einziger Träger im Werkzeug ist diese Sperre. Eine Betriebsart, die sie mit aufhebt, eröffnet den
schreibenden Lauf gegen eine Entscheidung, die nicht gefallen ist.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der schreibende Lauf über `altbestand`** — er ist an eine Vorbedingung gebunden, die dieser
  Slice nicht auflöst: die `[haenger]`-Sperre und die Entscheidung dahinter
  ([slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md)). Dieser Slice
  macht den Lauf **darstellbar**, nicht **zulässig**; wer beides in einen Slice nähme, entschiede
  eine Norm-Frage im Implementations-Kontext.
- **Der Ausgang der eingehenden Verweise auf Review-Reports** — ein anderer Vorgang mit eigener
  Alternativen-Menge, geschnitten als
  [slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md), und eine Norm-Frage
  des Architect, keine Werkzeug-Arbeit.
- **Der Prüfbereich der `closure`-Fähigkeit des Doku-Gates** — er ist
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Folgepflicht 3
  und fällig *„vor dem ersten schreibenden Lauf"*, nicht vor der Betriebsart. Er berührt
  `.d-check.yml` und `harness/README.md`, also eine andere Schicht als dieser Slice.
- **Ein Einzel-Slice-Modus (`done/slice-<NNN>-archiv.zip`)** — die Form, die die Baseline dem Repo
  **ohne** Wellen gibt. Dieses Repo fährt Wellen
  (`ls docs/plan/planning/welle-*.md | wc -l`), und
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) hat sie als
  Alternative D gemessen verworfen. Sie zu bauen hieße, eine angenommene Entscheidung zu umgehen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Die Betriebsart trägt, und ihr Schlüssel ist der aus der Entscheidung.** Ein Lauf
      `archive-welle --vorschau altbestand` meldet am ruhenden Baum **keine** der vier
      welle-/untergrenzen-gebundenen Sperren mehr (`ergebnisnotiz`, `kein-plan`,
      `mehrdeutiger-plan`, `untergrenze`) und dieselben vier Einsammel-Zahlen wie heute. Die
      Herkunft des Schlüssels ist
      [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
      Festlegung 2; er wird im Code nicht als Zweitdefinition wiederholt, sondern an einer Stelle
      geführt.
      **Gemessen am ruhenden Baum**, `make host-bin` davor, Arbeitsbaum sauber:
      `Sperren: 1` statt 4, und die verbliebene ist `[haenger]`. Die **Einsammel-Zahlen** stehen bei
      `0 · 58 · 92 · 144` statt `0 · 57 · 91 · 144` — die Verschiebung ist der **Bestand**, nicht
      die Betriebsart: `internal/archive/collect.go` ist über beide Umsetzungs-Commits **null
      Zeilen** geändert
      (`git diff f9ef00e2^..94bad9a3 -- internal/archive/collect.go | wc -l` → 0), und die
      Klassifikation deckt den Bestand weiterhin vollständig ab
      (`58 + 92 = 150 =` `ls docs/plan/planning/done/slice-*.md | wc -l`). Der Schlüssel hat genau
      eine Definition — `AltbestandSchluessel` in `internal/archive/vorschau.go`, gegen das Literal
      der Entscheidung gehalten von `TestAltbestandSchluesselTraegtDenWertAusADR0041`.
- [x] **`haenger` bleibt stehen, und das Gegenbeispiel ist rot gesehen.** Derselbe Lauf meldet
      `[haenger]` unverändert und bricht mit Exit 3 ab. Ein Fall unter `test/mutations/` hebt die
      Sperre mit auf und **muss** dabei rot färben ([`AGENTS.md`](../../../../AGENTS.md) §3.6);
      welcher Wächter fällt, steht in seiner `# expect:`-Zeile. Ohne dieses Gegenbeispiel ist
      Festlegung 4 eine Zusage ohne Zähne — sie hängt allein an dieser Sperre.
      **Exit 3 nachgefahren**; der Fall ist
      `test/mutations/310-archive-welle-go-altbestand-hebt-haenger-mit-auf.sh` mit
      `# expect: TestAltbestandBehaeltHaengerSperre`, **rot gesehen vom Reviewer** (einziger
      Fehlschlag `--- FAIL: TestAltbestandBehaeltHaengerSperre`, danach per `git checkout`
      zurückgesetzt) — nicht vom Kontext, der ihn schrieb.
- [x] **Die drei übrigen Ausgänge sind nachweislich unberührt.** `unsauber`, `archiviert` und
      `kein-slice` sperren unter der neuen Betriebsart wie zuvor; der Nachweis ist ein Test je
      Ausgang über einem synthetischen Baum, nicht die Abwesenheit einer Meldung in einem Lauf.
      **Drei Tests, je Ausgang einer:** `TestAltbestandSperrtBeiUnsauberemBaum`,
      `TestAltbestandSperrtBeiBereitsArchiviert`, `TestAltbestandSperrtBeiKeinSlice`. Die
      **Kalibrierung** der aufgehobenen Menge trägt
      `test/mutations/311-archive-welle-go-altbestand-hebt-kein-slice-mit-auf.sh`
      (`# expect: TestAltbestandSperrtBeiKeinSlice`), ebenfalls vom Reviewer rot gesehen.
- [x] `make gates` grün. **Nicht behauptet, sondern gedeckt:** Der aufgezeichnete Stempel
      `.harness/state/gates-passed.diffsha` und `harness/tools/working-tree-hash.sh` über dem
      Abschluss-Stand sind **deckungsgleich** — der EXIT-0-Lauf des Umsetzungs-Kontexts gilt genau
      diesem Baum. Der Closure-Commit ändert ihn und verlangt einen neuen Lauf.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
      [`docs/reviews/2026-09-12-slice-219-archivierung-nimmt-einen-schluessel-ohne-welle.md`](../../../reviews/2026-09-12-slice-219-archivierung-nimmt-einen-schluessel-ohne-welle.md)
      — 1 HIGH · 1 MEDIUM · 2 LOW · 1 INFO, Verdikt *blockierend*; HIGH-1, LOW-2 und INFO-1 sind in
      `94bad9a3` behoben, MEDIUM-1 ist als Grenze benannt und adressiert (§7), LOW-1 ist in einer
      Commit-Message und damit unveränderlich (Register-Beleg, §7).
- [x] Doku-Update: [`harness/README.md`](../../../../harness/README.md) beschreibt beim
      `archive-welle`-Absatz, was die Betriebsart aufhebt und was sie stehen lässt — ein
      öffentlicher Vertrag im Sinne von [`AGENTS.md`](../../../../AGENTS.md) §6 Schritt 7 ist mit
      dem Unterkommando berührt.
      **Geliefert, aber an einer anderen Adresse, und der Grund ist gemessen:** Der Prosa-Block
      liegt seit `9a57f2b3` (slice-114, 08:50) in
      [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md); in
      `harness/README.md` steht nur noch die Index-Zeile darauf. Dieser DoD-Punkt entstand um 12:44
      und nannte die Adresse, die zu diesem Zeitpunkt bereits umgezogen war — der **Plan** war
      falsch, nicht die Lieferung. Der Vertrag ist in §Vertrag und §Grenze (Punkte 6 und 7) der
      Sensor-Datei beschrieben.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag. — §7.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
      Drei `evidence/slice-219.md` ergänzt, kein neues Verzeichnis — §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen). — §6, drei
      von drei.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).
      Der Punkt fragt nach dem **Träger**, nicht nach einer hier gefahrenen Prüfung. Dieses Repo
      fährt Wellen (`ls docs/plan/planning/welle-*.md | wc -l` → 3, kein Erwartungswert), der
      Träger ist damit die nächste Welle-Closure — auch für diesen Slice ohne Wellen-Zugehörigkeit.
      Was sie vorfindet, ist hier vorbereitet: der genannte Folge-Slice liegt als Datei in `open/`,
      die drei zitierten Beobachtungen als Verzeichnisse mit nicht leerem `evidence/`, und ein
      `liegt in`-Feld steht nicht (§7 — mit diesem Slice wurde nichts verkörpert).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/archive/vorschau.go` | update | dort liegen die acht Ausgänge; vier bekommen die Bedingung, die der Schlüssel ohne Welle setzt |
| `cmd/ai-harness-init/archive_welle.go` | update | der Schlüssel erreicht die Vorprüfung über den Parser; die Betriebsart ist ein Wert, kein zweiter Zweig |
| `test/mutations/` | neu | je ein Fall für `haenger` und für die Kalibrierung der aufgehobenen Menge |
| [`harness/README.md`](../../../../harness/README.md) | update | die Zusage über das Unterkommando wächst mit |

**Der Einsammel-Pfad bleibt unberührt.** `internal/archive/collect.go` klassifiziert schon heute
`Mitglied · Wellenlos · Fremd` und liefert für `altbestand` die richtigen Zahlen (§1) — eine
Änderung dort wäre eine zweite Fassung derselben Regel.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): keine weitere Bedingung —
[`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) liegt `Accepted`,
und ihre Folgepflicht 1 ist der Auftrag. Der Slice ist **einzeln lieferbar**: Er wartet nicht auf
[slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md), weil er den
schreibenden Lauf gerade nicht eröffnet.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich zeigt, dass die Betriebsart
  nicht als Bedingung an vier Ausgängen darstellbar ist, sondern einen zweiten Pfad durch die
  Vorprüfung verlangt — dann trennt der Schnitt die Parser-/Wert-Hälfte von der Ausgangs-Hälfte.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Aufhebung von `untergrenze` die
  Einsammel-Regel mit bewegt und der Altbestand dadurch in eine spätere Welle-Closure liefe. Das
  ist die Wirkung, die
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 5 der
  Untergrenze zuschreibt; kippt sie, ist die Entscheidung betroffen und nicht nur der Bau.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `--vorschau altbestand` meldet am ruhenden Baum allein `[haenger]`; der
Mutations-Fall zu `haenger` ist rot gesehen; Closure-Notiz mit Steering-Loop-Lerneintrag
geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Betriebsart hebt mehr auf als die vier** — `haenger` fällt still mit, und der schreibende
  Lauf wird zulässig, bevor die Norm-Frage entschieden ist. Kein Gate meldet das: Die Vorschau ist
  kein Gate und steht in keiner Prerequisite-Kette
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  DoD 2 bindet das Gegenbeispiel. — **Ausgang: entfallen.** `haenger` steht: Der Lauf über dem
  ruhenden Baum meldet ihn als **einzige** Sperre und endet mit Exit 3. Die Bedingung `welleGebunden`
  gattert allein `ergebnisnotiz`, `planSperre` und `untergrenzeSperre`; `haenger` liegt außerhalb
  beider `if`-Blöcke. Das Risiko kann nicht mehr eintreten, weil es jetzt einen Wächter hat:
  `test/mutations/310-…-hebt-haenger-mit-auf.sh` hebt die Sperre mit auf und färbt dabei rot
  (`--- FAIL: TestAltbestandBehaeltHaengerSperre`, vom Reviewer gefahren). Der Zweig hängt zudem an
  **Gleichheit mit einer Konstante** — ein Tippfehler im Schlüssel fällt in den welle-gebundenen
  Zweig und sperrt vollständig, statt still durchzulaufen.
- **Die Aufhebung von `untergrenze` bewegt die Einsammel-Regel mit**
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md),
  Stand `geplant`). `untergrenzeSperre` und `Bestand.Slices()` lesen denselben wellenlosen Bestand;
  wer die Sperre an der falschen Stelle entschärft, nimmt der nächsten Welle-Closure die Grenze,
  die [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
  Festlegung 5 ihr zuschreibt. — **Ausgang: entfallen.** Die Sperre ist **am Schlüssel** entschärft,
  nicht an der Einsammel-Regel, und beides ist getrennt gemessen. `internal/archive/collect.go` ist
  über beide Umsetzungs-Commits **null Zeilen** geändert
  (`git diff f9ef00e2^..94bad9a3 -- internal/archive/collect.go | wc -l` → 0). Und die Gegenprobe
  am lebenden Baum: `--vorschau welle-01` meldet `[untergrenze]` unverändert
  (*„58 wellenlose(r) Slice(s) liegen flach … aber kein …/archiv.zip setzt eine Untergrenze"*) und
  dieselbe wellenlose Menge wie der `altbestand`-Lauf. Die Grenze aus Festlegung 5 steht für jede
  Welle-Kennung weiter; sie fällt erst, wenn das Sammel-Archiv wirklich liegt — was dieser Slice
  ausdrücklich nicht tut.
- **Der neue Wächter bekommt keinen Mutations-Fall**
  ([`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md),
  Stand `offen`). Der Bestand um dieses Unterkommando ist dicht bewacht
  (`ls test/mutations/*archive-welle*.sh | wc -l`, kein Erwartungswert); eine Betriebsart ohne
  eigenen Fall fiele darin auf und bliebe trotzdem grün. — **Ausgang: entfallen.** Die Betriebsart
  hat **zwei** Fälle bekommen, und sie decken die zwei Richtungen getrennt: `310` bewacht, dass
  `haenger` **nicht** mit aufgeht (Festlegung 4), `311` die **Kalibrierung** der aufgehobenen Menge
  am Beispiel `kein-slice`. Beide sind rot gesehen, und zwar vom Reviewer statt vom schreibenden
  Kontext. Das Risiko kann für diesen Slice nicht mehr eintreten; für den **schreibenden** Pfad
  stellt es sich neu und steht darum als Risiko 3 in
  [slice-220](../open/slice-220-plan-ausgang-traegt-eine-kennung.md), nicht als offener Rest hier.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-12.

- **Was hat funktioniert:** Der Schnitt hat die Betriebsart als **Wert** gedacht, nicht als zweiten
  Pfad, und das hat getragen: Ein Schlüssel, eine Bedingung, vier Ausgänge unter ihr — der
  Einsammel-Pfad blieb mit null geänderten Zeilen unberührt, und die Rückführung
  `in-progress → next` aus §4 (*„wenn die Betriebsart einen zweiten Pfad verlangt"*) wurde nie
  gebraucht. Ebenso getragen hat die Entscheidung, den **Gegenstand** des Slice an die Sperre zu
  hängen, die **stehen bleibt**, statt an die vier, die fallen: `haenger` ist der einzige Träger von
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 4, und
  ein Slice, der nur die Aufhebung beschrieben hätte, hätte sie im Vorbeigehen mitnehmen können.
  Dass der **Reviewer** die zwei Mutationen selbst angewandt und zurückgesetzt hat, ist der Grund,
  warum „rot gesehen" hier eine Messung ist und keine Zusage des schreibenden Kontexts.
  **Ein Re-Evaluierungs-Trigger der Entscheidung ist damit beantwortet, und nur dieser Lauf konnte
  es:** *„Wenn die Betriebsart aus Folgepflicht 1 am Werkzeug nicht darstellbar ist"* ist als
  **feedback**-Trigger *„an einem Implementations-Lauf ablesbar, der sie misst"* — dieser Lauf ist
  er, und die Messung fällt **negativ** aus. Die Betriebsart ist als Bedingung an vier Ausgängen
  darstellbar, ohne zweiten Pfad durch die Vorprüfung; die Prämisse, unter der die Entscheidung
  ihre Optionen am selben änderbaren Werkzeug misst, steht.
- **Was ging anders als geplant:** Der Slice hat die Vorprüfung geöffnet und dabei eine Zusage
  **falsch gemacht**, die vorher wahr war — das ist der Befund, den der Plan nicht vorhergesehen
  hat. Die Sensor-Datei sagt, was die Vorschau an Sperren nennt, seien *„genau die Ausgänge, an
  denen der schreibende Lauf abbricht"*; für den neuen Schlüssel stimmt das nicht mehr, weil
  `Anwenden` weiterhin mit `if len(b.Plaene) != 1` beginnt und `Einsammeln` für einen Schlüssel ohne
  Welle null Pläne liefert. **Entschieden wurde, die Zusage einzuschränken statt den Code zu
  erweitern:** Folgepflicht 1 der Entscheidung begrenzt die Betriebsart nach ihrem eigenen Wortlaut
  auf die **Ausgänge** der Vorprüfung, §1 dieses Plans schließt den schreibenden Lauf ausdrücklich
  aus, und wer beides in einen Slice nähme, hätte den Plan geändert statt ergänzt. Zweitens war die
  **Doku-Adresse in DoD 6 schon beim Schreiben tot** — slice-114 hatte den Prosa-Block vier Stunden
  zuvor in eine Sensor-Datei verlegt; geliefert wurde am richtigen Ort, falsch war der Plan.
- **Steering-Loop-Eintrag — neuer Sensor:** Die Festlegung, die den **Vollzug** zurückhält, hat
  Zähne bekommen. `test/mutations/310-archive-welle-go-altbestand-hebt-haenger-mit-auf.sh` färbt rot,
  sobald `haenger` unter dem neuen Schlüssel mit aufgehoben wird, und
  `test/mutations/311-archive-welle-go-altbestand-hebt-kein-slice-mit-auf.sh` hält die **Bezugsmenge**
  der Aufhebung — ohne den zweiten wäre „genau vier Ausgänge" eine Zahl ohne Gegenprobe. Die
  Verallgemeinerung, die der Slice liefert: **Wer eine fail-closed-Sperre bedingt aufhebt, braucht
  zwei Fälle und nicht einen** — einen für das, was fallen soll, und einen für die Grenze, an der
  das Fallen aufhört; der erste allein lässt jede Ausweitung still durchgehen.
  Eine `— liegt in …`-Teilzeile steht **nicht**: Mit diesem Slice ist keine Regel an einem Zielort
  verkörpert worden, und kein Register-Eintrag hat mit ihm 3× erreicht. Der Eintrag ist gezählt,
  nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):** Kein neues Verzeichnis — drei vorhandene Kennungen
  **zitiert** statt neu formuliert, je eine `evidence/slice-219.md`:
  [`BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md)
  (HIGH-1, zwei Konjunktiv-Kommentare über die verworfene Alternative in einer `_test.go`, die
  `make comment-claims` dauerhaft ausnimmt) · steht damit bei **7×** ·
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  (MEDIUM-1, die Zusage der Sensor-Datei blieb neben der geänderten Ableitung stehen) · **23×** ·
  [`BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  (LOW-1, *„Sieben neue Go-Tests"* in der Commit-Message gegen gemessene sechs; gebunden von
  [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  Setzung 1 statt von
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1) · **7×**. Alle Stände sind gemessen, keine Erwartungswerte.
  **Zwei Kandidaten sind geprüft und ausgelassen**, statt einen Zähler nebenbei zu bewegen: Die tote
  DoD-Adresse (§2, Punkt 6) fällt **nicht** unter
  [`BEO-ALL/gleichzeitig-laufender-slice-macht-adresse-tot`](../observations/BEO-ALL/gleichzeitig-laufender-slice-macht-adresse-tot/observation.md)
  — dessen Identität verlangt *„Sein Umsetzungs-Commit war richtig, als er entstand"*, und hier war
  die Adresse beim Schreiben bereits umgezogen. Und
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  bekommt **keinen** Beleg, weil der Fall gerade nicht eintrat (§6, Risiko 3).
  **Der Lese-Schritt ist hier bewusst nicht gefahren.** Dieses Repo fährt Wellen
  (`ls docs/plan/planning/welle-*.md | wc -l` → 3, kein Erwartungswert), und die Träger-Tabelle des
  Baseline-Regelwerks `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht weist ihn nur im Repo
  **ohne** Wellen der Slice-Closure zu. Diese Closure **zählt** darum und **entscheidet nicht**:
  Kein Ausgang wird zugewiesen, kein `state.md` angefasst. Festgehalten für den, der ihn fährt:
  Zwei der drei oben gespeisten Einträge stehen **über** der Schwelle und tragen den Stand `offen`
  (7× und 7×) — das ist der Gegenstand des Lese-Schritts, nicht dieser Notiz.
- **Folge-Slices:** [slice-220](../open/slice-220-plan-ausgang-traegt-eine-kennung.md) — *Der
  Plan-Ausgang des schreibenden Laufs trägt eine Kennung*; liegt als Datei in `open/`. Er ist der
  **Ausgang der benannten Lücke aus MEDIUM-1**, und der Ausgang ist ein Folge-Slice und nicht
  *weiter offen*: Ein Kommentar im Go-Code trägt eine Lücke nicht, er beschreibt sie nur.
  **Der Gegenstand ist enger als die Lücke breit ist, und das mit Absicht.** Der Defekt ist keine
  fehlende Fähigkeit, sondern **eine Bedingung an zwei Stellen, von denen dieser Slice nur eine
  entschärft hat**: `planSperre` in `internal/archive/vorschau.go` schweigt unter dem neuen
  Schlüssel, `if len(b.Plaene) != 1` in `internal/archive/anwenden.go` greift weiter. Der
  Folge-Slice gibt dem Ausgang eine **Kennung**, damit er wie die acht anderen in der Vorschau
  erscheint — dann sagt die Vorschau für `altbestand` die Wahrheit, und die zwei Stellen, die die
  Ausnahme heute in Prosa erklären (`ABGRENZUNG` in `vorschau.go`, §Grenze Punkt 7 der
  Sensor-Datei), verlieren ihren Gegenstand statt nötiger zu werden.
  **Was er ausdrücklich nicht erledigt, steht in seinem §1:** ob `Anwenden` den Schlüssel ohne
  Welle-Plan **tragen** soll. Das braucht
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 1
  (*der wellenlose Altbestand **wird archiviert***), und heute trägt es kein Vorgang — weder
  [slice-216](../open/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md), der die
  Norm-Frage und damit `haenger` löst, noch Festlegung 4, die allein den **Vollzug** an jene Frage
  bindet, noch Folgepflicht 1, die nach ihrem Wortlaut an den Ausgängen der Vorprüfung endet. Nach
  slice-220 steht diese Frage als **benannte Sperre im Lauf** statt als Kommentar im Code, und
  damit vor dem nächsten Planungs-Schnitt statt in einer Datei, die niemand aufschlägt.
- **Risiken aus §6:** drei von drei, jedes **entfallen**, jedes mit Begründung und Messung — die
  `haenger`-Sperre steht (Exit 3, Mutation 310 rot), die Einsammel-Regel ist unbewegt (null
  geänderte Zeilen, Gegenprobe an `welle-01`), und die Betriebsart hat zwei Mutations-Fälle statt
  keinem.
- **Drei Paarungen:** dieses **Repo** fährt Wellen — Anker, Folge-Slice und Register prüft die
  nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo). `harness/tools/` ist
**nicht** berührt: Der Träger ist das Produkt-Binär
([`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1), die Arbeit
liegt in `internal/archive/` und `cmd/`, und kein Skript unter `harness/tools/` wird angefasst. Die
Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) führt
für diesen Bereich keine eigene Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist
durchgegangen; die Stände sind gemessen, nicht abgelesen
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2):

```sh
cd docs/plan/planning/observations/BEO-ALL
for d in neuer-waechter-ohne-mutations-fall zusage-nennt-sensor-der-form-nicht-sieht \
         verweis-nachzug-schreibt-in-eingefrorenes-artefakt zusage-ohne-herstellbares-gegenbeispiel; do
  printf '%2s  %s\n' "$(ls $d/evidence/*.md | wc -l)" "$d"; done
#  4  neuer-waechter-ohne-mutations-fall
# 12  zusage-nennt-sensor-der-form-nicht-sieht
# 13  verweis-nachzug-schreibt-in-eingefrorenes-artefakt
#  2  zusage-ohne-herstellbares-gegenbeispiel
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. Vier berühren diesen
Slice; **keine** erreicht mit ihm erstmals 3×:

- **`neuer-waechter-ohne-mutations-fall` (4×, `offen`)** — Risiko 3, bindet DoD 2.
- **`zusage-nennt-sensor-der-form-nicht-sieht` (12×, `geplant`)** — Risiko 2.
- **`verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (13×, `offen`)** — berührt den Slice über
  [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 4:
  Der Eintrag ist der Grund, warum `haenger` stehen bleibt.
- **`zusage-ohne-herstellbares-gegenbeispiel` (2×, `offen`)** — DoD 2 verlangt ein rot gesehenes
  Gegenbeispiel; ist es nicht herstellbar, ist das der Befund und nicht die Ausrede.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
