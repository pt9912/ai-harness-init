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

**Verantwortlich:** `—`

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
  ([slice-216](slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md)). Dieser Slice
  macht den Lauf **darstellbar**, nicht **zulässig**; wer beides in einen Slice nähme, entschiede
  eine Norm-Frage im Implementations-Kontext.
- **Der Ausgang der eingehenden Verweise auf Review-Reports** — ein anderer Vorgang mit eigener
  Alternativen-Menge, geschnitten als
  [slice-216](slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md), und eine Norm-Frage
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

- [ ] **Die Betriebsart trägt, und ihr Schlüssel ist der aus der Entscheidung.** Ein Lauf
      `archive-welle --vorschau altbestand` meldet am ruhenden Baum **keine** der vier
      welle-/untergrenzen-gebundenen Sperren mehr (`ergebnisnotiz`, `kein-plan`,
      `mehrdeutiger-plan`, `untergrenze`) und dieselben vier Einsammel-Zahlen wie heute. Die
      Herkunft des Schlüssels ist
      [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
      Festlegung 2; er wird im Code nicht als Zweitdefinition wiederholt, sondern an einer Stelle
      geführt.
- [ ] **`haenger` bleibt stehen, und das Gegenbeispiel ist rot gesehen.** Derselbe Lauf meldet
      `[haenger]` unverändert und bricht mit Exit 3 ab. Ein Fall unter `test/mutations/` hebt die
      Sperre mit auf und **muss** dabei rot färben ([`AGENTS.md`](../../../../AGENTS.md) §3.6);
      welcher Wächter fällt, steht in seiner `# expect:`-Zeile. Ohne dieses Gegenbeispiel ist
      Festlegung 4 eine Zusage ohne Zähne — sie hängt allein an dieser Sperre.
- [ ] **Die drei übrigen Ausgänge sind nachweislich unberührt.** `unsauber`, `archiviert` und
      `kein-slice` sperren unter der neuen Betriebsart wie zuvor; der Nachweis ist ein Test je
      Ausgang über einem synthetischen Baum, nicht die Abwesenheit einer Meldung in einem Lauf.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) beschreibt beim
      `archive-welle`-Absatz, was die Betriebsart aufhebt und was sie stehen lässt — ein
      öffentlicher Vertrag im Sinne von [`AGENTS.md`](../../../../AGENTS.md) §6 Schritt 7 ist mit
      dem Unterkommando berührt.
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
[slice-216](slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md), weil er den
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
  DoD 2 bindet das Gegenbeispiel. — **Ausgang:** <…>
- **Die Aufhebung von `untergrenze` bewegt die Einsammel-Regel mit**
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md),
  Stand `geplant`). `untergrenzeSperre` und `Bestand.Slices()` lesen denselben wellenlosen Bestand;
  wer die Sperre an der falschen Stelle entschärft, nimmt der nächsten Welle-Closure die Grenze,
  die [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
  Festlegung 5 ihr zuschreibt. — **Ausgang:** <…>
- **Der neue Wächter bekommt keinen Mutations-Fall**
  ([`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md),
  Stand `offen`). Der Bestand um dieses Unterkommando ist dicht bewacht
  (`ls test/mutations/*archive-welle*.sh | wc -l`, kein Erwartungswert); eine Betriebsart ohne
  eigenen Fall fiele darin auf und bliebe trotzdem grün. — **Ausgang:** <…>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register:** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
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
