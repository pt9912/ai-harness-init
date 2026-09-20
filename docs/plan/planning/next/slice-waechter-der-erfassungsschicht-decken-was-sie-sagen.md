# Slice slice-waechter-der-erfassungsschicht-decken-was-sie-sagen: Jeder Wächter über Träger, Feldliste und Erfassungs-Ausgabe trägt seinen Fall, seine Meldung und seine Grenze

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
Festlegungen 1 und 5 sind die Zusagen, die die Träger-Wächter messen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — die Bestandszahlen unten wandern und sind keine Erwartungswerte),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel; *gelistet*
heißt: ein Fall in `test/mutations/`).

**Berührte Spec-Stellen:** — Gegenstand sind Wächter und ein Aufräum-Fragment; keine Spec-Stelle
wird geschrieben.

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Jeder Wächter über Träger-Ablage, Feldliste und Erfassungs-Ausgabe ist entweder von einem
`test/mutations/`-Fall rot zu sehen oder mit Grund als unbewacht ausgesprochen; jede seiner
Meldungen trifft den Treffer, den sie meldet; und wo er eine Menge nicht sieht, sagt er es in der
Meldung statt im Kommentar.

**Übernimmt:** `slice-103-traeger-waechter-decken-was-sie-sagen`,
`slice-108-feldlisten-waechter-tragen-ihren-fall`,
`slice-110-erfassungs-waechter-fall-meldung-grenze`.

**Warum die drei ein Slice sind.** Sie sind drei Ausfertigungen derselben Frage über drei
benachbarte Bestände: *deckt der Wächter, was er sagt?* Gleiche Leserichtung, gleiches Instrument
(`make mutate` mit `# expect:`-Kopf), gleiche Verdikt-Form (**Fall** oder **ausgesprochene
Grenze**). Getrennt geschnitten fassen sie dieselben Testdateien nacheinander an und wiederholen
dreimal dieselbe Entscheidung darüber, was ein vollwertiger Ausgang ist.

**Der Bestand ist geschlossen und benannt:**
[`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go) (Träger, Wrapper,
Hook-Eintrag), [`internal/span/fieldlist_test.go`](../../../../internal/span/fieldlist_test.go) und
[`internal/emit/fieldlist_test.go`](../../../../internal/emit/fieldlist_test.go) (Feldliste),
[`internal/emit/erfassung_test.go`](../../../../internal/emit/erfassung_test.go) und
[`internal/report/report_test.go`](../../../../internal/report/report_test.go) (Leser und
Gate-Tabelle), das Aufräum-Fragment
[`internal/emit/templates/enforce/erfassung.mk`](../../../../internal/emit/templates/enforce/erfassung.mk)
sowie die zugehörigen Fälle unter [`test/mutations/`](../../../../test/mutations).

**Die Ausgangslage, gemessen statt geschätzt** — **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2), beide Zahlen wandern mit ihrem Bestand:

```sh
# Feldlisten-Waechter ohne Fall: ein func Test..., dessen Name in keinem '# expect:'-Kopf steht
comm -23 \
  <(grep -h '^func Test' internal/span/fieldlist_test.go internal/emit/fieldlist_test.go \
      | sed 's/^func \([A-Za-z_0-9]*\)(.*/\1/' | sort) \
  <(sed -n 's/^# expect: //p' test/mutations/*.sh | sort -u) | wc -l     # 8
# der Traeger-Waechter, der seine Erwartung aus der zu mutierenden Funktion bezieht
grep -c 'TestEnforce_WrapperSuchtDenAblageort' internal/emit/enforce_test.go   # 2
```

Die Klasse hinter der zweiten Zahl ist die teuerste: Ein Wächter, der die Namen, die er sucht, aus
`emit.CarrierPath()` holt — also aus derselben Funktion, an die er koppeln soll —, misst nur, dass
der Code mit sich selbst übereinstimmt. `make mutate` fällt das nicht auf, weil der `# expect:`-Kopf
einen **anderen** Wächter nennt, der zu Recht fällt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Aussagen der Feldliste selbst.** Ob die Incident-Frage je Feld an **eine** Quelle gebunden
  ist und ob ein Satz über den Bestand mehr behauptet als der Träger, ist ein Gegenstand des
  **Produkts**; dieser Slice hat die **Wächter** darüber. Zwei verschiedene Gegenstände, zwei
  Schnitte — das ist der Grund, und er allein trägt. Das ist ein **anderer Vorgang**; die Adresse
  ist `slice-109-feldliste-jede-aussage-hat-ihre-quelle`, der unverändert in `next/` steht.

- **Die Kopf-Granularität von `test/mutations/`.** Ob ein Kopf die erwartete **Zusicherung** statt
  des Wächter-Namens trägt, übernimmt der **Folge-Slice** `slice-069-zahn-bindet-zusicherung`;
  dieser Slice legt Fälle in der heute geltenden Form an und migriert nichts.
- **Der Prüfbereich von `make comment-claims`.** Dass er `_test[.]go` ganz ausnimmt, bleibt als
  **Bestand** bewusst stehen — er ist Gegenstand von `slice-070-comment-claims-pruefbereich` und
  wird hier nicht nebenbei verschoben.
- **Die Ausgabe des Lesers.** Dass `make span-report` seine Lagen mit zutreffenden Ursachen
  begründet, ist das **Produkt**; hier geht es um die Wächter darüber —
  **Schicht-Abgrenzung**, und die Adresse ist `slice-071-bilanz-nennt-ihren-bestand`.

### Nachbarschaft: zwei Slices schreiben an §5, und dieser ist keiner davon

`slice-109-feldliste-jede-aussage-hat-ihre-quelle` schreibt an
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5, und
`slice-204-das-programm-feld-nennt-das-programm` zieht dort `SPEC-021` und `SPEC-031` nach. **Der
Ausschluss von `slice-109` hängt nicht daran, wer als Einziger §5 schreibt** — dieser Grund trüge
nicht, denn es sind zwei; er hängt am Gegenstand. Die Nachbarschaft steht hier, weil zwei
schreibende Zugriffe auf denselben Abschnitt einen Konflikt erzeugen, wenn sie gleichzeitig
laufen: Wer beide zugleich anfasst, löst ihn im Text statt in der Planung. Dieser Slice berührt §5
nicht und ist von beiden unabhängig.

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

- [ ] **(1) Jede Zusage dieses Bestands trägt ihren `test/mutations/`-Fall oder ihre an der
      Assertion ausgesprochene Grenze mit Grund — und kein Wächter bezieht seine Erwartung aus der
      Funktion, die ihn rot färben soll.** Nach dem Lauf liefert das `comm`-Kommando aus §1 genau
      die Namen, für die eine Grenze ausgesprochen ist, und keinen weiteren. **Eine ausgesprochene
      Grenze ist ein vollwertiger Ausgang; ein Fall, der irgendetwas rot färbt, ist es nicht** — wo
      ein Eingriff mehrere Wächter zugleich reißt, bindet er keinen.
      **Rot:** `make mutate` — jeder neue Fall erscheint als `ok` mit seinem erwarteten Wächter
      rot; nimmt man die Assertion heraus, die er binden soll, meldet derselbe Lauf einen Befund.
      Für `TestEnforce_WrapperSuchtDenAblageort` zusätzlich: `test/mutations/159` angewendet —
      heute bleibt der Wächter grün, danach **muss** er fallen.
- [ ] **(2) Jede Meldung dieses Bestands trifft ihren Treffer — wer ihr folgt, kommt ins Grün.**
      Die Gate-Tabellen-Meldung nennt genau die Schreibweise, die der Wächter akzeptiert (oder der
      Wächter akzeptiert die genannte), und das Aufräum-Ziel meldet, **was es getan hat**, statt
      was es getan hätte.
      **Rot:** ein `test/mutations/`-Fall mit `# verify: test-go`, der eine Gate-Tabellen-Zeile mit
      **exakt der von der Meldung verlangten** Schreibweise einträgt — er bleibt grün, solange die
      Meldung recht hat, und der Wächter fällt, sobald sie es nicht tut; für das Aufräum-Ziel ein
      zweiter Lauf über bereits leerem Zustand im Zahn von
      [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh).
- [ ] **(3) Wo ein Wächter eine Menge nicht sieht, sagt er es in der Meldung — und die Stufe je
      Fall hängt an der Eigenschaft, nicht an der Nachbarschaft.** Betroffen sind die
      Fixture-Grenze des Gate-Tabellen-Wächters und die Menge der Ziel-Quellen ohne das
      konditionale Arch-Gate-Fragment; wer für einen Fall die teure Stufe wählt, schreibt in den
      Fall-Kopf, welche Eigenschaft die schmalere **nicht** trifft.
      **Rot:** ein Go-Test, der die **benannte** Grenze gegen den tatsächlich gelesenen Satz hält
      und fällt, sobald eine Quelle dazukommt, die die Grenze nicht führt; dazu ein
      `test/mutations/`-Fall mit `# verify: test-go`, der genau diese Quelle hinzufügt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: voraussichtlich leer — berührt sind Testcode, Mutations-Fälle und höchstens
      Kommentare an Assertions; kein emittiertes Artefakt und keine Schnittstelle. Ändert sich der
      Text des Aufräum-Ziels für einen Adopter sichtbar, bekommt
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) seine Zeile.
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
| [`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go) | update | die Wrapper-Erwartung wird festgeschrieben statt aus `emit.CarrierPath()` geholt; Grenzen an die Assertion |
| [`internal/span/fieldlist_test.go`](../../../../internal/span/fieldlist_test.go) · [`internal/emit/fieldlist_test.go`](../../../../internal/emit/fieldlist_test.go) | update | Grenz-Aussagen an den Assertions, die keinen Fall bekommen |
| [`internal/emit/erfassung_test.go`](../../../../internal/emit/erfassung_test.go) · [`internal/report/report_test.go`](../../../../internal/report/report_test.go) | update | Meldungen und die benannte Sicht-Grenze (DoD 2 und 3) |
| [`internal/emit/templates/enforce/erfassung.mk`](../../../../internal/emit/templates/enforce/erfassung.mk) | update | das Aufräum-Ziel meldet, was es getan hat |
| [`test/mutations/`](../../../../test/mutations) | neu / update | je Wächter ein Fall auf der schmalsten Stufe; `# verify:` benennt sie |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Je Wächter wird zuerst entschieden, **ob** ein Eingriff existiert, der genau ihn reißt; erst
  danach wird ein Fall geschrieben. Wo keiner existiert, steht die Grenze an der Assertion — das
  ist der Ausgang, nicht der Verzicht.
- Reihenfolge: erst der Träger-Bestand (DoD 1 samt `159`), dann die Feldliste, dann Leser und
  Aufräum-Fragment. So fällt früh auf, falls die Verdikt-Form nicht trägt.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei, und die drei
übernommenen Slices liegen in `done/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Review kommt in **einer** Sitzung
  nicht durch den Bestand — erkennbar daran, dass ein Report die Wächter nur stichprobenweise
  durchgeht. Dann wird nach den drei Beständen neu geschnitten (Träger · Feldliste · Leser), nicht
  nach den drei Liefer-Punkten.
- `in-progress` → `open` (blockiert — Carveout?): Für mehrere Wächter existiert kein Eingriff, der
  genau sie reißt, und die ausgesprochene Grenze träfe die Mehrheit — dann ist nicht der Fall das
  Problem, sondern der Schnitt der Wächter selbst.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün, und `make mutate` meldet **keinen** Befund; die neuen Fälle erscheinen
   als `ok` mit ihrem erwarteten Wächter rot.
2. Das `comm`-Kommando aus §1 liefert genau die Namen, für die eine Grenze ausgesprochen ist; die
   gelesene Ausgabe steht im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Bestand sprengt die Review-Sitzung.** Der Slice fasst drei Wächter-Bestände zusammen;
   das ist die Größenregel-Kante dieses Schnitts. *Absehbar:* entfallen, wenn ein Report den
   vollständigen Bestand durchgeht; sonst eingetreten mit der Rückführung aus §4 als Ausgang.
2. **Ein Fall reißt mehrere Wächter zugleich** und bindet damit keinen. *Absehbar:* entfallen,
   wenn für jeden Wächter entweder ein bindender Eingriff oder eine ausgesprochene Grenze
   dasteht.
3. **Die ausgesprochene Grenze wird zur bequemen Antwort.** *Absehbar:* entfallen, wenn die Zahl
   der Grenzen im Report je einzeln begründet ist; sonst weiter offen ins Register.
4. **Der neue `test-go`-Fall nimmt dem bestehenden `full-smoke`-Fall die Zähne**, weil beide
   dieselbe Eigenschaft messen. *Absehbar:* entfallen, wenn beide Fälle nebeneinander bestehen und
   je eine andere Eigenschaft im Kopf nennen.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/emit/`, `internal/span/`,
`internal/report/` und `test/mutations/` — alle in `*`. `harness/tools/` (`TOOLS`) wird für den
Zahn des Aufräum-Ziels berührt; `.codex/` (`CODEX`) nicht. Beide berührten Sub-Areas erfüllen das
Inklusionskriterium; ausdifferenziert wird nichts.

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

Keiner der vier erreicht **mit diesem Slice** erstmals 3×; ein eigener Folge-Slice entsteht daraus
nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
