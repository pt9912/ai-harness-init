# Slice slice-leser-und-aufraeum-waechter-decken-was-sie-sagen: Der Leser- und der Aufräum-Wächter treffen ihre Meldung und sagen ihre Menge

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-v021-faehigkeit](../welle-v021-faehigkeit.md) — Mitglied laut
deren §4 (Slices in dieser Welle); die Welle bündelt die Belegbasis-Kette und trägt
über diese DoD hinaus den repo-weiten `make full-smoke`-Beleg als Closure-Bedingung.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Wächter ohne Zähne ist ein stilles Grün — dieselbe Klasse eine Ebene tiefer),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (*Accepted* — ihre
Festlegungen 1 und 5 sind die Zusagen, die die Erfassungs-Wächter messen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — die Bestandszahlen unten wandern und sind keine Erwartungswerte),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel; *gelistet*
heißt: ein Fall in `test/mutations/`).

**Berührte Spec-Stellen:** — Gegenstand sind Wächter und ein Aufräum-Fragment; keine Spec-Stelle
wird geschrieben.

**Verantwortlich:** Implementer (pt9912) — hält die Arbeit fort, die die Rückführung von
`slice-waechter-der-erfassungsschicht-decken-was-sie-sagen` abgetrennt hat.

**Autor:** Planner. **Datum:** 2026-09-20.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Leser-Wächter der Erfassungs-Ausgabe (`internal/emit/erfassung_test.go`,
`internal/report/report_test.go`) trägt entweder seinen `test/mutations/`-Fall oder seine
ausgesprochene Grenze; jede seiner Meldungen trifft den Treffer, den sie meldet; und wo er eine
Menge nicht sieht, sagt er es in der Meldung statt im Kommentar. Das Aufräum-Ziel in
`internal/emit/templates/enforce/erfassung.mk` meldet, was es getan hat.

**Übernimmt:** `slice-110-erfassungs-waechter-fall-meldung-grenze`.

**Aus einer Neuschneidung hervorgegangen.** Dieser Slice ist der Rest von
`slice-waechter-der-erfassungsschicht-decken-was-sie-sagen`, nachdem dessen Review in einer
Sitzung nicht durch den vollen Drei-Bestand kam (§4 dort). Der Träger- und der Feldlisten-Anteil
sind dort bereits geliefert und bleiben reduziert in `next/` stehen; dieser Slice trägt den
dritten Bestand (Leser, vormals `slice-110`) sowie die beiden Liefer-Punkte, die den Ursprungs-Plan
zu groß gemacht haben (Meldungs-Treffer, Fixture-/Mengen-Grenze).

**Der Bestand ist geschlossen und benannt:**
[`internal/emit/erfassung_test.go`](../../../../internal/emit/erfassung_test.go) und
[`internal/report/report_test.go`](../../../../internal/report/report_test.go) (Leser und
Gate-Tabelle), das Aufräum-Fragment
[`internal/emit/templates/enforce/erfassung.mk`](../../../../internal/emit/templates/enforce/erfassung.mk)
sowie die zugehörigen Fälle unter [`test/mutations/`](../../../../test/mutations).

**Die Ausgangslage, gemessen statt geschätzt** — **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2), die Zahl wandert mit dem Bestand:

```sh
# Leser-Waechter ohne Fall: ein func Test..., dessen Name in keinem '# expect:'-Kopf steht
comm -23 \
  <(grep -h '^func Test' internal/emit/erfassung_test.go internal/report/report_test.go \
      | sed 's/^func \([A-Za-z_0-9]*\)(.*/\1/' | sort) \
  <(sed -n 's/^# expect: //p' test/mutations/*.sh | sort -u) | wc -l     # 0 (gemessen 2026-09-20)
```

Die Fall-Abdeckung selbst zeigt hier aktuell keine Lücke — offen ist nicht diese Zahl, sondern die
noch nicht einzeln geprüfte Selbstbezugs-Eigenschaft (derselbe Fehlertyp wie bei
`TestEnforce_WrapperSuchtDenAblageort` im Träger-Bestand: ein Wächter, der seine Erwartung aus der
Funktion holt, die ihn rot färben soll) sowie die beiden noch unbearbeiteten Liefer-Punkte
Meldungs-Treffer und Fixture-/Mengen-Grenze.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Träger- und der Feldlisten-Bestand.** Bereits geliefert und reduziert in
  `slice-waechter-der-erfassungsschicht-decken-was-sie-sagen` (`next/`) — **anderer Vorgang**,
  dessen eigene Closure diesen Slice nicht braucht.
- **Die Aussagen der Feldliste selbst.** Ob die Incident-Frage je Feld an **eine** Quelle gebunden
  ist und ob ein Satz über den Bestand mehr behauptet als der Träger, ist ein Gegenstand des
  **Produkts**; dieser Slice hat die **Wächter**. Die Adresse ist
  `slice-109-feldliste-jede-aussage-hat-ihre-quelle`, der unverändert in `next/` steht.
- **Die Kopf-Granularität von `test/mutations/`.** Ob ein Kopf die erwartete **Zusicherung** statt
  des Wächter-Namens trägt, übernimmt der **Folge-Slice** `slice-069-zahn-bindet-zusicherung`;
  dieser Slice legt Fälle in der heute geltenden Form an und migriert nichts.
- **Die Ausgabe des Lesers.** Dass `make span-report` seine Lagen mit zutreffenden Ursachen
  begründet, ist das **Produkt**; hier geht es um die Wächter darüber —
  **Schicht-Abgrenzung**, und die Adresse ist `slice-071-bilanz-nennt-ihren-bestand`.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste.

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

- [x] **(1) Jede Zusage des Leser-Bestands trägt ihren `test/mutations/`-Fall oder ihre an der
      Assertion ausgesprochene Grenze mit Grund — und kein Wächter bezieht seine Erwartung aus der
      Funktion, die ihn rot färben soll.** Nach dem Lauf liefert das `comm`-Kommando aus §1 genau
      die Namen, für die eine Grenze ausgesprochen ist, und keinen weiteren.
      **Rot:** `make mutate` — jeder neue Fall erscheint als `ok` mit seinem erwarteten Wächter
      rot; nimmt man die Assertion heraus, die er binden soll, meldet derselbe Lauf einen Befund.
      **Belegt:** Commit `3147fe59` liefert die Konstante `keinGateMarke`, `TestErfassung_KeinArchGateInZielQuellen`
      und Fall 187. Review-Runde 1
      ([2026-09-22](../../../reviews/2026-09-22-slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md))
      hat DoD (1) unabhängig nachgerechnet: `comm` liefert `0`, keine Selbstbezugs-Stelle
      (Negativbefunde). Kein Fund gegen DoD (1) in beiden Runden.
- [x] **(2) Jede Meldung dieses Bestands trifft ihren Treffer — wer ihr folgt, kommt ins Grün.**
      Die Gate-Tabellen-Meldung nennt genau die Schreibweise, die der Wächter akzeptiert (oder der
      Wächter akzeptiert die genannte), und das Aufräum-Ziel meldet, **was es getan hat**, statt
      was es getan hätte.
      **Rot:** ein `test/mutations/`-Fall mit `# verify: test-go`, der eine Gate-Tabellen-Zeile mit
      **exakt der von der Meldung verlangten** Schreibweise einträgt — er bleibt grün, solange die
      Meldung recht hat, und der Wächter fällt, sobald sie es nicht tut; für das Aufräum-Ziel ein
      zweiter Lauf über bereits leerem Zustand im Zahn von
      [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh).
      **Belegt:** Commit `3147fe59` lieferte den `full-smoke.sh`-Zahn (zweiter `span-clean`-Lauf)
      und einen ersten, nicht-diskriminierenden Beleg über den bestehenden Fall 182. Review-Runde 1
      fand F-1 HIGH (Fall 182 misst die Meldungs-Treffer-Eigenschaft nicht — fällt identisch gegen
      Vor- und Nach-Fix-Fassung) und F-2 LOW (der `full-smoke.sh`-Zahn selbst trägt keinen eigenen
      Rot-Beleg im Commit). Commit `e03908fe` behebt F-1: `gateTabellenZeileBefund` hält Prüfung und
      Meldung an einer Stelle, neuer Fall `test/mutations/394` trennt sie testweise wieder und
      diskriminiert real (Review-Runde 2, Punkt A, selbst im gepinnten Image rot/grün reproduziert).
      Commit `a147be2b` korrigiert den Kommentar über dem neuen Test (F-3 aus Runde 2, §3.7) auf den
      geltenden Zustand im Indikativ und entfernt den rohen Commit-Hash (F-4). F-2 bleibt als
      benannte, nicht blockierende Lücke offen — siehe unten „F-2 (Runde 1) — Behandlung" und
      Beobachtungs-Register.
- [x] **(3) Wo ein Wächter eine Menge nicht sieht, sagt er es in der Meldung — und die Stufe je
      Fall hängt an der Eigenschaft, nicht an der Nachbarschaft.** Betroffen sind die
      Fixture-Grenze des Gate-Tabellen-Wächters und die Menge der Ziel-Quellen ohne das
      konditionale Arch-Gate-Fragment; wer für einen Fall die teure Stufe wählt, schreibt in den
      Fall-Kopf, welche Eigenschaft die schmalere **nicht** trifft.
      **Rot:** ein Go-Test, der die **benannte** Grenze gegen den tatsächlich gelesenen Satz hält
      und fällt, sobald eine Quelle dazukommt, die die Grenze nicht führt; dazu ein
      `test/mutations/`-Fall mit `# verify: test-go`, der genau diese Quelle hinzufügt.
      **Belegt:** Commit `3147fe59` liefert den Arch-Gate-Fragment-Teil vollständig
      (`TestErfassung_KeinArchGateInZielQuellen`, Fall 187, Review-Runde 1 ohne Befund real im
      gepinnten Image reproduziert). Für die Fixture-Grenze des Gate-Tabellen-Wächters hatte
      Commit `3147fe59` zunächst nur eine Kommentar-Behauptung ohne Sensor geliefert; Review-Runde 1
      hat das als „technisch unmöglich für einen Go-Test, aber nicht als Kategorie unmöglich"
      eingeordnet und einen Folge-Slice empfohlen. Commit `e03908fe` liefert stattdessen einen
      echten Sensor — einen neuen Fall in
      [`test/courseset-fixture.bats`](../../../../test/courseset-fixture.bats), der die Grenze
      direkt gegen den **realen** vendorten Vorlagensatz hält (der Docker-Build-Kontext der
      Go-Test-Stage schließt `.harness/` per `.dockerignore` aus, bats mountet den vollen Checkout).
      Review-Runde 2 (Punkt B) hat den Sensor selbst verifiziert: grün auf unverändertem Baum, rot
      bei einer real eingefügten unmarkierten Zeile in der committeten Vorlage, danach sauber
      zurückgesetzt (Checksumme, `git status`, `make baseline-verify` geprüft). Damit ist die
      Fixture-Grenze real geschlossen, nicht nur ausgesprochen.
- [x] `make gates` grün. Gate-Hash `fefa8d94a2ab4b3aecd31a88154e6f41a2c529ebec43b2d577f1d4b4a880cc99`
      in `.harness/state/gates-passed.diffsha` deckt HEAD `a147be2b` (Stand nach Runde-2-Fix, vor
      dieser Closure). Vom Planner bei dieser Closure erneut selbst gefahren — Ergebnis und Hash der
      Closure-Commits siehe Commit-Historie dieses Slice in `git log`.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). Zwei Reports: Runde 1
      [2026-09-22](../../../reviews/2026-09-22-slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md)
      (1 HIGH F-1, 1 LOW F-2, F-1 blockierend) und Runde 2
      [2026-09-22](../../../reviews/2026-09-22-slice-leser-und-aufraeum-waechter-decken-was-sie-sagen-runde-2.md)
      (1 HIGH F-3, 1 LOW F-4, F-3 blockierend; F-1/Fixture-Grenze aus Runde 1 als geschlossen
      bestätigt). Beide Runden-Befunde inhaltlich behoben (`a147be2b`); F-2 aus Runde 1 bleibt als
      benannte, nicht blockierende Lücke (siehe unten).
- [x] Doku-Update: entfällt wie geplant — berührt sind ausschließlich Testcode, Mutations-Fälle,
      ein bats-Fall und Kommentare an Assertions; kein emittiertes Artefakt, keine Schnittstelle,
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) unverändert (der Text des
      Aufräum-Ziels selbst ändert sich für einen Adopter nicht).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — siehe §7.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — siehe §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen) — siehe §6.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft — siehe §7.

**F-2 (Runde 1) — Behandlung, statt Verschleppung.** Der zweite `span-clean`-Lauf-Zahn in
`harness/tools/full-smoke.sh` (Zeilen 1150–1157) trägt — anders als der Nachbar-Zahn direkt darüber
— keinen eigenen `test/mutations/`-Fall, der ihn als „Rot-Gegenbeispiel" bindet: Der Verifier hat
den Fund als nicht-blockierend eingestuft, aber offen belassen, weil bisher nur isoliert und
unpersistiert geprüft wurde, dass er aus dem richtigen Grund rot liefe. Statt das kommentarlos
weiterzuschieben: Der Gegenstand ist derselbe wie die verkörperte Beobachtung
[`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) —
ein neuer Prüfschritt ohne bindenden Fall in `test/mutations/`. Da diese Regel bereits verkörpert
ist (`AGENTS.md` §3.6) und der zusätzliche Aufwand eines `# verify: full-smoke`-Falls (der einen
vollen `full-smoke`-Lauf braucht, der auf diesem Host strukturell nicht läuft, siehe
`lokaler-full-smoke-scheitert-auf-macos-host`) den Rahmen dieses Slice sprengen würde, wird die
Lücke hier bewusst **nicht** geschlossen, sondern als weiteres Auftreten der bestehenden
Beobachtung eingetragen (Beleg unten, §7) — benannt statt verschwiegen, nicht blockierend laut
beiden Rollen (Reviewer Runde 1, Verifier).

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/erfassung_test.go`](../../../../internal/emit/erfassung_test.go) · [`internal/report/report_test.go`](../../../../internal/report/report_test.go) | update | Meldungen und die benannte Sicht-Grenze (DoD 2 und 3); Grenzen an Assertions ohne Fall (DoD 1) |
| [`internal/emit/templates/enforce/erfassung.mk`](../../../../internal/emit/templates/enforce/erfassung.mk) | update | das Aufräum-Ziel meldet, was es getan hat |
| [`test/mutations/`](../../../../test/mutations) | neu / update | je Wächter ein Fall auf der schmalsten Stufe; `# verify:` benennt sie |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Je Wächter wird zuerst entschieden, **ob** ein Eingriff existiert, der genau ihn reißt; erst
  danach wird ein Fall geschrieben. Wo keiner existiert, steht die Grenze an der Assertion — das
  ist der Ausgang, nicht der Verzicht.
- Reihenfolge: erst DoD 1 (Fall/Grenze), dann DoD 2 (Meldung), dann DoD 3 (Menge). So fällt früh
  auf, falls die Verdikt-Form aus dem Ursprungs-Slice nicht trägt.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`open` → `next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei, und
`slice-waechter-der-erfassungsschicht-decken-was-sie-sagen` (Träger + Feldliste) ist geschlossen
oder liegt zumindest nicht mehr im selben WIP-Slot — die beiden Bestände sind unabhängig
lieferbar, ein serieller Zwang besteht nicht.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Review kommt in **einer** Sitzung
  nicht durch den Leser-Bestand plus die drei Liefer-Punkte — dann wird nach DoD-Punkt neu
  geschnitten (Fall/Grenze · Meldung · Menge-Sicht), nicht mehr nach Bestand.
- `in-progress` → `open` (blockiert — Carveout?): Für den Gate-Tabellen-Wächter existiert kein
  Eingriff, der genau ihn reißt, und die ausgesprochene Grenze träfe die Mehrheit seiner
  Zusicherungen — dann ist nicht der Fall das Problem, sondern der Schnitt des Wächters selbst.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün, und `make mutate` meldet **keinen** Befund; die neuen Fälle erscheinen
   als `ok` mit ihrem erwarteten Wächter rot. **Randbedingung dieses Hosts:** `make mutate` (wie
   `make full-smoke`) kann auf einem macOS-Devhost strukturell nicht grün laufen — siehe
   [`lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/observation.md).
   Der Beleg läuft über CI (`workflow_dispatch` auf `.github/workflows/mutate.yml`).
2. Das `comm`-Kommando aus §1 liefert genau die Namen, für die eine Grenze ausgesprochen ist; die
   gelesene Ausgabe steht im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Leser-Bestand plus drei Liefer-Punkte sprengt wieder die Review-Sitzung.** Derselbe
   Größenregel-Kante wie beim Ursprungs-Slice, jetzt eine Ebene kleiner. *Absehbar:* entfallen,
   wenn ein Report den vollständigen Bestand durchgeht; sonst eingetreten mit Rückführung nach §4.
   **Eingetreten.** Der Ursprungs-Slice `slice-waechter-der-erfassungsschicht-decken-was-sie-sagen`
   hatte genau diesen Bestand (Träger + Feldliste + Leser, drei Liefer-Punkte) am 2026-09-20 nach
   `next` zurückgeführt, weil ein Report nicht in einer Sitzung durch den vollständigen
   Drei-Bestand kam; dieser Slice ist der dabei abgetrennte Rest (Leser-Bestand, §1). Für **diesen**
   reduzierten Umfang selbst ist das Risiko nicht erneut eingetreten: Beide Review-Runden
   ([2026-09-22 Runde 1](../../../reviews/2026-09-22-slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md),
   [Runde 2](../../../reviews/2026-09-22-slice-leser-und-aufraeum-waechter-decken-was-sie-sagen-runde-2.md))
   kamen vollständig durch den Bestand dieses Slice, ohne weitere Rückführung.
2. **Ein Fall reißt mehrere Wächter zugleich** und bindet damit keinen. *Absehbar:* entfallen,
   wenn für jeden Wächter entweder ein bindender Eingriff oder eine ausgesprochene Grenze
   dasteht.
   **Entfallen.** Das `comm`-Kommando aus §1 liefert nach dem finalen Stand weiterhin `0`
   Fälle-ohne-Bindung außerhalb der ausgesprochenen Grenzen (Review-Runde 1, Negativbefund); jeder
   neue Fall (187, 394) bindet genau einen Wächter, keiner reißt einen zweiten mit.
3. **Die ausgesprochene Grenze wird zur bequemen Antwort.** *Absehbar:* entfallen, wenn die Zahl
   der Grenzen im Report je einzeln begründet ist; sonst weiter offen ins Register.
   **Entfallen — nicht durch eine Abgrenzung, sondern weil die Grenze real geschlossen wurde.**
   Ursprünglich hätte dieses Risiko für die Fixture-Grenze des Gate-Tabellen-Wächters gedroht
   „bequem" zu werden (eine reine Kommentar-Behauptung ohne Sensor, wie Commit `3147fe59` sie
   zunächst lieferte). Review-Runde 1 hat dem widersprochen und einen echten Sensor verlangt statt
   der Abgrenzung; Commit `e03908fe` liefert ihn (neuer Fall in `test/courseset-fixture.bats` gegen
   den realen vendorten Baum). Review-Runde 2 (Punkt B) und der Verifier bestätigen unabhängig: die
   Lücke ist geschlossen, weil ein echter, verifizierter Sensor entstanden ist — nicht, weil eine
   Abgrenzung sie bequem für erledigt erklärt hätte. Damit ist die Bedingung, vor der dieses Risiko
   warnt, nicht eingetreten.
4. **Der neue `test-go`-Fall nimmt dem bestehenden `full-smoke`-Fall die Zähne**, weil beide
   dieselbe Eigenschaft messen. *Absehbar:* entfallen, wenn beide Fälle nebeneinander bestehen und
   je eine andere Eigenschaft im Kopf nennen.
   **Entfallen.** Geprüft für alle neu entstandenen Fälle: Fall 394 (`test-go`) deckt, dass
   `gateTabellenZeileBefund` Prüfung und Meldung an einer Konstante hält — eine Eigenschaft von
   `internal/emit/erfassung_test.go` selbst. Der einzige benachbarte `full-smoke.sh`-Zahn zur
   Gate-Tabellen-Meldung (Zeilen rund um 1075, „gates-Kette des Ziels nennt span-report/span-clean")
   misst eine andere Eigenschaft: dass die **emittierte** Gate-Kette eines Ziel-Repos
   `span-report`/`span-clean` nicht unmarkiert führt — ein Test am emittierten Ziel-Repo, nicht an
   diesem Repos eigenem `internal/emit`-Paket. Der neue zweite-`span-clean`-Lauf-Zahn (Zeilen
   1150–1157) misst wiederum eine dritte Eigenschaft (Idempotenz des Aufräum-Ziels über bereits
   leerem Bestand). Keine Überschneidung, keine Entwaffnung.
5. **`make mutate` ist auf dem lokalen macOS-Devhost strukturell rot** (Exec-format-Fehler des
   Linux-Trägers, siehe
   [`lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/observation.md)).
   *Absehbar:* entfallen, sobald der CI-Lauf (`workflow_dispatch`) den Closure-Trigger aus §5
   Punkt 1 trägt; sonst weiter offen ins Register (bereits eingetragen).
   **Weiter offen** — der CI-Lauf ist für diese Closure nicht angefordert worden; die Randbedingung
   besteht unverändert fort. Weiterer Beleg im Register (§7), Zähler jetzt 2×.

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

- **Was hat funktioniert:** Die Drei-Runden-Rollen-Trennung (Implementer → Verifier/Reviewer →
  Implementer → Reviewer, wiederholt) hat zweimal hintereinander real substantielle Lücken
  gefangen, die die Selbsteinschätzung des Implementer-Laufs allein nicht gefangen hätte: Ein
  Verifier hat den ersten Fix-Versuch (`603e279e`) zurückgewiesen, weil DoD (2) einen eigenen,
  diskriminierenden `test/mutations/`-Fall verlangt und keine bloße Begründung, warum keiner nötig
  sei. Der zweite Fix-Versuch (`e03908fe`) hat DoD (2) real geschlossen (Fall 394, im gepinnten
  Image rot/grün reproduziert) und zusätzlich DoD (3)s Fixture-Grenze — ursprünglich fälschlich als
  „technisch unmöglich" eingestuft — durch einen echten `test/courseset-fixture.bats`-Sensor
  geschlossen. Review-Runde 2 hat trotzdem einen neuen Fund gemacht (F-3 HIGH): Der Kommentar über
  dem neuen Test in `e03908fe` narrativierte wieder den abwesenden Vorzustand im Konjunktiv statt
  den geltenden Zustand im Indikativ zu nennen — dieselbe Fehlerklasse, die der Vorgänger-Review vom
  2026-09-21 bereits einmal fing und die Runde-1-Review für den (anderen) Commit `3147fe59`
  ausdrücklich als „nicht wiederholt" bestätigt hatte. Diese Bestätigung galt nie für `e03908fe`, da
  der Kommentar dort neu entstand — ein Beleg dafür, dass §3.7-Disziplin pro Commit neu geprüft
  werden muss, nicht einmalig pro Slice.
- **Was ging anders als geplant:** Drei Implementer-Runden statt einer (`3147fe59`, `603e279e`,
  `e03908fe`, `a147be2b`) und zwei Review-Runden statt einer waren nötig — der ursprüngliche
  Trigger-Text (§5) sah nur „ein" Closure-Kriterium vor und unterschätzte, dass DoD (2)s
  Rot-Kriterium einen echten diskriminierenden Fall verlangt, nicht nur „irgendein" Rot. Die DoD
  (3)-Fixture-Grenze war im Plan als „Folge-Slice oder ausgesprochene Grenze" offengelassen und
  wurde stattdessen real geschlossen — eine dritte, im Plan nicht vorgesehene Option, die erst
  Review-Runde 1 durch den Verweis auf das bereits im Bestand gelebte `test/courseset-fixture.bats`-
  Muster sichtbar machte.
- **Steering-Loop-Eintrag:** Kein neuer verkörperter Eintrag. Zwei berührte Register-Einträge sind
  bereits `verkörpert` (`AGENTS.md` §3.6/§3.7 seit früheren Wellen/Slices) und dieser Slice wendet
  ihre Regeln nur an bzw. liefert ein weiteres reales Auftreten — das Muster bestätigt sich weiter,
  kein neuer Handlungsbedarf, nur Beleg. Für `neuer-waechter-ohne-mutations-fall` ebenso: bereits
  verkörpert, F-2 (Runde 1) ist ein weiteres Auftreten derselben, bereits verkörperten Regel, kein
  neuer Zielort nötig.
- **Beobachtungs-Register (`../observations/`):** drei Fortschreibungen.
  (1) `evidence/slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md` in
  [`BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/)
  ergänzt — Zähler steht damit bei 2×.
  (2) `evidence/slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md` in
  [`BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/)
  neu angelegt (F-3, Runde 2) — Eintrag bereits `verkörpert`, kein neuer Zielort, nur Beleg.
  (3) `evidence/slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md` in
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall/`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/)
  neu angelegt (F-2, Runde 1: der zweite `span-clean`-Lauf-Zahn hat keinen bindenden
  `test/mutations/`-Fall) — Eintrag bereits `verkörpert`, kein neuer Zielort, nur Beleg.
- **Folge-Slices:** keine neuen. `slice-110-erfassungs-waechter-fall-meldung-grenze` war bereits
  vor diesem Slice übernommen (§1 `Übernimmt:`) und ist mit dieser Closure vollständig geliefert.
- **Risiken aus §6:** fünf, jedes mit genau einem Ausgang — Risiko 1 *eingetreten* (Rückführung des
  Ursprungs-Slice; für den reduzierten Umfang dieses Slice selbst nicht erneut eingetreten),
  Risiko 2 *entfallen* (`comm` liefert weiterhin 0, kein Fall reißt zwei Wächter), Risiko 3
  *entfallen* (die Fixture-Grenze wurde real durch einen neuen Sensor geschlossen, nicht durch eine
  bequeme Abgrenzung), Risiko 4 *entfallen* (Fall 394 und die beiden `full-smoke`-Zähne messen drei
  unabhängige Eigenschaften, keine Entwaffnung), Risiko 5 *weiter offen* (Register, Zähler jetzt 2×)
  — Details je bei §6.
- **Drei Paarungen** (Repo ohne Wellen-Betrieb, hier geprüft):
  (a) **Anker-Paarung** — kein Eintrag dieser Closure trägt `liegt in <Zielort>` (kein
  Register-Eintrag erreicht mit diesem Slice erstmals 3×, alle drei berührten Einträge sind bereits
  länger `verkörpert`), daher nichts zu prüfen.
  (b) **Folge-Slice-Paarung** — dieser Slice erzeugt keinen neuen Folge-Slice; der übernommene
  `slice-110-erfassungs-waechter-fall-meldung-grenze` ist mit dieser Closure vollständig geliefert,
  nicht weitergereicht.
  (c) **Register-Paarung** — alle drei berührten Verzeichnisse
  (`lokaler-full-smoke-scheitert-auf-macos-host`, `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`,
  `neuer-waechter-ohne-mutations-fall`) existieren unverändert mit nicht-leerer `evidence/` (je ein
  neuer Eintrag hinzugefügt).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/emit/`, `internal/report/` und
`test/mutations/` — alle in `*`. `harness/tools/` (`TOOLS`) wird für den Zahn des Aufräum-Ziels
berührt. Beide berührten Sub-Areas erfüllen das Inklusionskriterium; ausdifferenziert wird nichts.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die `state.md` des
Eintrags; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) | 8 | verkörpert | der Gegenstand dieses Slice in einem Satz |
| [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md) | 3 | verkörpert | §6 Risiko 2 und die ausgesprochene Grenze als Ausgang |
| [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) | 4 | verkörpert | §6 Risiko 4 |
| [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | 17 | geplant | DoD 2 — die Meldung verlangt eine Schreibweise, die der Wächter nicht akzeptiert |
| [`lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/observation.md) | 0 (benannt, nicht gezählt) | offen | §5 Punkt 1 und §6 Risiko 5 — der lokale `make mutate`-Closure-Beleg dieses Slice läuft über CI |

Keiner der Einträge erreicht **mit diesem Slice** erstmals 3×; ein eigener Folge-Slice entsteht
daraus nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
