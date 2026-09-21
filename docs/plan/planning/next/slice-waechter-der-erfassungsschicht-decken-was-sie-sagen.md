# Slice slice-waechter-der-erfassungsschicht-decken-was-sie-sagen: Der Träger- und der Feldlisten-Wächter tragen ihren Fall oder ihre ausgesprochene Grenze

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

**Berührte Spec-Stellen:** — Gegenstand sind Wächter; keine Spec-Stelle wird geschrieben.

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-17. **Neu geschnitten:** Planner, 2026-09-20 (Rückführung
`in-progress` → `next`, siehe §4).

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Träger-Wächter (`internal/emit/enforce_test.go`) und die Feldlisten-Wächter
(`internal/span/fieldlist_test.go`, `internal/emit/fieldlist_test.go`) sind entweder von einem
`test/mutations/`-Fall rot zu sehen oder mit Grund als unbewacht ausgesprochen; kein Wächter
bezieht seine Erwartung aus der Funktion, die ihn rot färben soll.

**Übernimmt:** `slice-103-traeger-waechter-decken-was-sie-sagen`,
`slice-108-feldlisten-waechter-tragen-ihren-fall`.

**Warum die zwei ein Slice sind.** Träger und Feldliste sind zwei Ausfertigungen derselben Frage
über zwei benachbarte Bestände: *deckt der Wächter, was er sagt?* Gleiche Leserichtung, gleiches
Instrument (`make mutate` mit `# expect:`-Kopf), gleiche Verdikt-Form (**Fall** oder
**ausgesprochene Grenze**).

**Aus dem größeren Schnitt neu hervorgegangen.** Dieser Slice trug ursprünglich einen dritten
Bestand (Erfassungs-Ausgabe/Leser, vormals `slice-110-erfassungs-waechter-fall-meldung-grenze`)
sowie zwei weitere Liefer-Punkte (Meldungs-Treffer, Fixture-/Mengen-Grenze). Der Review kam in
einer Sitzung nicht durch den gesamten Drei-Bestand — der in §4 vorab benannte
Rückführungs-Grund trat ein. Der Träger- und der Feldlisten-Bestand waren zu diesem Zeitpunkt
bereits vollständig und einzeln rot-verifiziert geliefert (Commit `ad7eba8f`); dieser Slice wird
auf genau diesen gelieferten Umfang reduziert. Der Rest — DoD 2, DoD 3 und der komplette
Leser/Aufräum-Bestand — läuft als eigener Folge-Slice
`slice-leser-und-aufraeum-waechter-decken-was-sie-sagen` (`open/`) weiter, der auch
`slice-110-erfassungs-waechter-fall-meldung-grenze` übernimmt.

**Der Bestand ist geschlossen und benannt:**
[`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go) (Träger, Wrapper,
Hook-Eintrag), [`internal/span/fieldlist_test.go`](../../../../internal/span/fieldlist_test.go) und
[`internal/emit/fieldlist_test.go`](../../../../internal/emit/fieldlist_test.go) (Feldliste), sowie
die zugehörigen Fälle unter [`test/mutations/`](../../../../test/mutations).

**Die Ausgangslage nach dem Umsetzungs-Commit `ad7eba8f`, gemessen statt geschätzt** — **keine
Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2), die Zahl wandert mit dem Bestand:

```sh
# Traeger- und Feldlisten-Waechter ohne Fall: ein func Test..., dessen Name in keinem
# '# expect:'-Kopf steht
comm -23 \
  <(grep -h '^func Test' internal/emit/enforce_test.go internal/span/fieldlist_test.go \
      internal/emit/fieldlist_test.go \
      | sed 's/^func \([A-Za-z_0-9]*\)(.*/\1/' | sort) \
  <(sed -n 's/^# expect: //p' test/mutations/*.sh | sort -u)
# TestBlockedFragment_Drops
# TestEnforce_EmitsAllMechanicFiles
# -> 2, genau die zwei mit Grund ausgesprochenen Grenzen (Kommentar direkt vor der jeweiligen
#    func-Zeile in internal/emit/enforce_test.go), keine weitere
```

Der gemessene Befund deckt sich mit der Selbsteinschätzung des Implementer-Laufs: Über den
gesamten ursprünglichen Fünf-Datei-Bestand (inklusive der beiden noch unangefassten Leser-Dateien
`internal/emit/erfassung_test.go`, `internal/report/report_test.go`) liefert dasselbe `comm`
ebenfalls exakt diese zwei Namen und keinen weiteren — der Träger- und Feldlisten-Anteil von DoD 1
ist damit vollständig; offen bleibt für den Leser-Bestand nicht die Fall-Abdeckung selbst, sondern
die noch nicht einzeln geprüfte Selbstbezugs-Eigenschaft (dieselbe Klasse wie
`TestEnforce_WrapperSuchtDenAblageort`, unten), die der Folge-Slice trägt.

Für `TestEnforce_WrapperSuchtDenAblageort` war die teuerste Klasse gemessen: ein Wächter, der die
Namen, die er sucht, aus `emit.CarrierPath()` holt — also aus derselben Funktion, an die er
koppeln soll —, maß nur, dass der Code mit sich selbst übereinstimmt. `make mutate` fiel das nicht
auf, weil der `# expect:`-Kopf einen **anderen** Wächter nannte, der zu Recht fiel. Behoben mit dem
Umsetzungs-Commit; `test/mutations/159` reißt den Wächter jetzt wie gefordert.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Leser- und Aufräum-Bestand** (`internal/emit/erfassung_test.go`,
  `internal/report/report_test.go`, `internal/emit/templates/enforce/erfassung.mk`) samt DoD 2
  (Meldungs-Treffer) und DoD 3 (Fixture-/Mengen-Grenze). **Folge-Slice** —
  `slice-leser-und-aufraeum-waechter-decken-was-sie-sagen` (`open/`), aus der Neuschneidung dieses
  Slice hervorgegangen und trägt den Rest, den §4 dieses Slice vorab als Rückführungsfall benannt
  hatte.

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

**Ein Liefer-Punkt**, mit dem Kommando, das ihn **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **(1) Jede Zusage des Träger- und Feldlisten-Bestands trägt ihren `test/mutations/`-Fall
      oder ihre an der Assertion ausgesprochene Grenze mit Grund — und kein Wächter bezieht seine
      Erwartung aus der Funktion, die ihn rot färben soll.** Nach dem Lauf liefert das
      `comm`-Kommando aus §1 genau die zwei Namen, für die eine Grenze ausgesprochen ist, und
      keinen weiteren. **Eine ausgesprochene Grenze ist ein vollwertiger Ausgang; ein Fall, der
      irgendetwas rot färbt, ist es nicht** — wo ein Eingriff mehrere Wächter zugleich reißt,
      bindet er keinen.
      **Rot:** `make mutate` — jeder neue Fall (382–393) erscheint als `ok` mit seinem erwarteten
      Wächter rot; nimmt man die Assertion heraus, die er binden soll, meldet derselbe Lauf einen
      Befund. Für `TestEnforce_WrapperSuchtDenAblageort` zusätzlich: `test/mutations/159`
      angewendet — vor dem Fix blieb der Wächter grün, danach fällt er.
      **Belegt:** Initiale Lieferung in `ad7eba8f` (Wrapper-Fix, zwei Fallgrenzen mit
      Assertions-Kommentar, zehn neue Fälle 382–393). Review-Report
      [2026-09-21](../../../reviews/2026-09-21-slice-waechter-der-erfassungsschicht-decken-was-sie-sagen.md)
      fand F-1 HIGH (Kommentar über `TestEnforce_WrapperSuchtDenAblageort` chronikte eine abgelöste
      Fassung statt den geltenden Zustand zu nennen, AGENTS.md §3.7) und F-2 LOW (Scope-Beschreibung
      nannte den mitgelieferten Fall 393 nicht explizit); F-1 behoben in `fcc6438c`, F-2 als
      Präzisions-Lücke ohne Codeproblem akzeptiert (Beleg: Folge-Slice-Plan hat den Fall bereits
      korrekt mitgerechnet). Der Verifier hat unabhängig bestätigt: `comm`-Ergebnis stimmt exakt,
      `test/mutations/159` reißt den Wächter nach dem Fix wie gefordert, der F-1-Fix ist inhaltlich
      echt (Kommentar nennt jetzt nur den geltenden Zustand, keine Chronik) statt nur umformuliert.
- [x] `make gates` grün. Vom Verifier inhaltsbasiert bestätigt (Gate-Hash `ed98487a…` stimmt exakt
      auf HEAD `fcc6438c`). Vom Planner bei dieser Closure erneut selbst gefahren (2026-09-21) auf
      Commit `780c9b51` (Stand nach den Closure-Eintragungen) — alle Recipes bis `span-check`
      durchlaufen (`record-gates` bricht bei jedem roten Prerequisite vor dem Hash-Schreiben ab,
      Mechanik: `Makefile:record-gates`), Hash `ad33060c69c9f2e0…` in
      `.harness/state/gates-passed.diffsha`.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). Report:
      [2026-09-21](../../../reviews/2026-09-21-slice-waechter-der-erfassungsschicht-decken-was-sie-sagen.md)
      (1 HIGH F-1 behoben, 1 LOW F-2 akzeptiert; merge-blockierend: nein nach dem Fix).
- [x] Doku-Update: entfällt wie geplant — berührt sind ausschließlich Testcode, Mutations-Fälle und
      Kommentare an Assertions; kein emittiertes Artefakt, keine Schnittstelle,
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) unverändert.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — siehe §7.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — siehe §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen) — siehe §6.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft — siehe §7.

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go) | update — **geliefert** | die Wrapper-Erwartung wird festgeschrieben statt aus `emit.CarrierPath()` geholt; Grenzen an der Assertion |
| [`internal/span/fieldlist_test.go`](../../../../internal/span/fieldlist_test.go) · [`internal/emit/fieldlist_test.go`](../../../../internal/emit/fieldlist_test.go) | update — **geliefert** | Grenz-Aussagen an den Assertions, die keinen Fall bekommen |
| [`test/mutations/`](../../../../test/mutations) | neu / update — **geliefert (382–393)** | je Wächter ein Fall auf der schmalsten Stufe; `# verify:` benennt sie |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Je Wächter wird zuerst entschieden, **ob** ein Eingriff existiert, der genau ihn reißt; erst
  danach wird ein Fall geschrieben. Wo keiner existiert, steht die Grenze an der Assertion — das
  ist der Ausgang, nicht der Verzicht.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei; der Träger- und
Feldlisten-Bestand liegt bereits vollständig vor (Commit `ad7eba8f`) — der nächste Lauf trägt nur
noch die Closure-Formalitäten (Review, DoD abhaken, §6/§7).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Review kommt in **einer** Sitzung
  nicht durch den Bestand — erkennbar daran, dass ein Report die Wächter nur stichprobenweise
  durchgeht. Dann wird nach den drei Beständen neu geschnitten (Träger · Feldliste · Leser), nicht
  nach den drei Liefer-Punkten.

  **Eingetreten am 2026-09-20.** Der Bestand von drei Liefer-Punkten über drei Testdateien plus
  einem Aufräum-Fragment war für eine Review-Sitzung zu groß — genau die vorab benannte Bedingung.
  Der Implementer-Lauf hatte zu diesem Zeitpunkt DoD 1 für Träger und Feldliste vollständig und
  einzeln rot-verifiziert geliefert (Commit `ad7eba8f`, zehn neue Mutations-Fälle 382–393, Fix an
  `TestEnforce_WrapperSuchtDenAblageort`, zwei ausgesprochene Grenzen mit Kommentar-Beleg an der
  jeweiligen Assertion) und empfahl die Rückführung mit Neuschnitt nach den drei Beständen selbst.
  Der Planner hat die Einschätzung anhand des `comm`-Kommandos aus §1 gegen den vollständigen
  Fünf-Datei-Bestand nachgeprüft: exakt zwei verbleibende Namen, deckungsgleich mit den zwei
  benannten Grenzen, keine weiteren — der Träger- und Feldlisten-Anteil ist damit tragfähig
  abgeschlossen. Ergebnis: dieser Slice wird auf den gelieferten Umfang reduziert und bleibt in
  `next/`; der Rest läuft als `slice-leser-und-aufraeum-waechter-decken-was-sie-sagen` (`open/`)
  weiter.
- `in-progress` → `open` (blockiert — Carveout?): Für mehrere Wächter existiert kein Eingriff, der
  genau sie reißt, und die ausgesprochene Grenze träfe die Mehrheit — dann ist nicht der Fall das
  Problem, sondern der Schnitt der Wächter selbst. *Nicht eingetreten.*

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün, und `make mutate` meldet **keinen** Befund; die neuen Fälle (382–393)
   erscheinen als `ok` mit ihrem erwarteten Wächter rot. **Randbedingung dieses Hosts:** `make
   mutate` (wie `make full-smoke`) kann auf einem macOS-Devhost strukturell nicht grün laufen —
   siehe die Beobachtung
   [`lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/observation.md).
   Der Beleg für dieses Kriterium läuft über CI (`workflow_dispatch` auf
   `.github/workflows/mutate.yml`), nicht über einen lokalen Lauf auf diesem Host.
2. Das `comm`-Kommando aus §1 liefert genau die zwei Namen, für die eine Grenze ausgesprochen ist;
   die gelesene Ausgabe steht im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Bestand sprengt die Review-Sitzung.** *Eingetreten* — Ausgang: Rückführung
   `in-progress` → `next` mit Neuschnitt nach den drei Beständen (§4); Folge-Slice
   `slice-leser-und-aufraeum-waechter-decken-was-sie-sagen` trägt den Rest. Für den jetzt
   reduzierten Umfang (Träger + Feldliste) besteht das Risiko nicht mehr fort.
2. **Ein Fall reißt mehrere Wächter zugleich** und bindet damit keinen. **Entfallen.** Das
   `comm`-Kommando aus §1 liefert nach `ad7eba8f` exakt zwei Namen — deckungsgleich mit den zwei
   ausgesprochenen Grenzen; jeder der übrigen acht Wächter hat einen eigenen bindenden Fall
   (382–393), keiner davon reißt einen zweiten mit. Der Verifier hat das `comm`-Ergebnis
   unabhängig nachgerechnet (Review-Negativbefund „§2 DoD (1) … geprüft, ohne Befund"). Getragen
   durch die bereits verkörperte Regel [`AGENTS.md`](../../../../AGENTS.md) §3.6 — Register-Eintrag
   [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
   (Stand bereits `verkörpert` vor dieser Closure): Dieser Slice **wendet** die Regel an, statt eine
   neue Instanz des Problems zu sein — kein neuer Beleg in diesem Register-Eintrag nötig.
3. **Die ausgesprochene Grenze wird zur bequemen Antwort.** **Entfallen.** Die zwei ausgesprochenen
   Grenzen (`TestBlockedFragment_Drops`, `TestEnforce_EmitsAllMechanicFiles`) tragen je einen
   eigenen, individuell begründeten Kommentar direkt an der Assertion — keine pauschale Formel
   (Review-Negativbefund bestätigt das unabhängig). Getragen durch dieselbe bereits verkörperte
   Regel wie Risiko 2, aus demselben Grund kein neuer Registerbeleg.
4. **Der neue `test-go`-Fall nimmt dem bestehenden `full-smoke`-Fall die Zähne**, weil beide
   dieselbe Eigenschaft messen. **Entfallen.** Fall 393
   (`test/mutations/393-zeilen-zaehlt-erst-nach-dem-parsen.sh`) deckt
   `TestAggregiere_ZeilenZaehltAuchUnlesbare` in `internal/report/report_test.go` — eine
   `make test-go`-Zusage über die **Reihenfolge**, in der `internal/report/report.go` `b.Zeilen`
   erhöht (erst nach erfolgreichem Parsen, nicht davor). Geprüft: Die einzigen `span-report`-Zähne
   in `harness/tools/full-smoke.sh` (rund um Zeile 1140–1207) messen Nachrichtentext am
   **emittierten Ziel-Repo** — „Kein Bestand:" bei geräumtem Bestand, „der Traeger liegt nicht" /
   „das ist KEINE Aussage über den Bestand" bei fehlendem Träger —, nicht die interne
   Zählreihenfolge unlesbarer Zeilen im eigenen `internal/report`-Paket dieses Repos. Zwei
   unabhängige Eigenschaften an zwei unabhängigen Beständen (emittiertes Ziel-Repo vs. dieses
   Repos eigenes `internal/report`), keine Entwaffnung.

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

- **Was hat funktioniert:** Die Rückführung mit Neuschnitt (§4, eingetreten 2026-09-20) hat einen
  Drei-Bestand-Slice, der eine Review-Sitzung sprengte, auf den bereits vollständig gelieferten
  Träger- und Feldlisten-Anteil reduziert, statt den Rest nachträglich zu rechtfertigen — die in §4
  *vorab* benannte Bedingung traf exakt ein und wurde am gemessenen `comm`-Ergebnis (§1) verifiziert,
  bevor der Schnitt vollzogen wurde. Für den reduzierten Slice hat danach die Rollen-Trennung
  Implementer → Reviewer → Verifier gefangen, was ein einzelner Kontext wahrscheinlich übersehen
  hätte: F-1 (HIGH) ist ein Kommentar, der `AGENTS.md` §3.6 (Zusage mit rot gesehenem
  Gegenbeispiel) korrekt erfüllt, dabei aber §3.7 verletzt (er erzählt eine abgelöste Code-Fassung
  statt den geltenden Zustand zu nennen) — eine Verletzung, die kein Gate fängt
  (`make comment-claims` prüft nur die Existenz eines genannten Sensors und nimmt `_test.go` ohnehin
  aus seinem Prüfbereich aus) und die der Implementer-Kontext, der den Kommentar selbst schrieb, im
  Self-Review kaum gefunden hätte. Der Verifier hat den Fix danach unabhängig als inhaltlich echt
  bestätigt (Kommentar nennt jetzt nur den geltenden Zustand), nicht nur als Umformulierung.
- **Was ging anders als geplant:** §6 sah für Risiko 2–4 nur eine *„Absehbar"*-Einschätzung mit
  Verweis auf die Closure vor; die Belege dafür (comm-Ergebnis, Grenz-Kommentare, Unabhängigkeit von
  Fall 393 gegenüber den `full-smoke`-Zähnen) standen zum Planungszeitpunkt noch nicht geprüft da.
  Diese Closure trägt sie nach (§6) — kein neuer Befund, aber ein Schritt, der im ursprünglichen
  Plan als reine Formalität unterschätzt war: die Prüfung von Risiko 4 (Fall 393 vs.
  `full-smoke`-Zahn) brauchte einen eigenständigen Blick in `harness/tools/full-smoke.sh`, den keine
  der bisherigen Runden geleistet hatte.
- **Steering-Loop-Eintrag:** Kein neuer. §8 hat bereits vor dieser Closure geprüft, dass keiner der
  berührten Register-Einträge mit diesem Slice erstmals 3× erreicht; diese Closure bestätigt das
  unverändert — zwei der drei berührten Einträge
  ([`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md),
  [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md))
  sind bereits `verkörpert` (seit früheren Wellen/Slices) und dieser Slice wendet ihre Regeln nur
  an, ohne einen neuen Beleg zu erzeugen; der dritte
  ([`lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/observation.md))
  steht nach diesem Beleg bei 1×.
- **Beobachtungs-Register (`../observations/`):** `evidence/slice-waechter-der-erfassungsschicht-decken-was-sie-sagen.md`
  in
  [`BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/)
  neu angelegt — erster abgeschlossener Vorgang, der auf diese Randbedingung stößt; Zähler steht
  damit bei 1×. Geprüft und bewusst **nicht** auf `gelöst` gesetzt: Der zwischenzeitlich gepushte
  Fix `b9809fc1` trägt einen additiven, für den Host cross-kompilierenden Pfad
  (`make full-smoke-host`/`make smoke-host`), ändert aber laut eigener Commit-Aussage den
  byte-identischen Default-Pfad (`make full-smoke`/`make smoke`) nicht — und für `make mutate`,
  das dieser Slice als CI-Ersatz genau in diesem Closure-Trigger (§5) braucht, existiert gar kein
  Host-Pfad. Die Beobachtung ist für zwei ihrer drei benannten Ziele gemildert, für ihr drittes
  (und für den unveränderten Default der ersten beiden) trifft sie weiter zu — `state.md`
  dokumentiert das als Stand, nicht als Chronik.
- **Folge-Slices:** `slice-leser-und-aufraeum-waechter-decken-was-sie-sagen` (`open/`) — trägt den
  Leser-/Aufräum-Bestand (`internal/emit/erfassung_test.go`, `internal/report/report_test.go`,
  `internal/emit/templates/enforce/erfassung.mk`) samt DoD 2 und DoD 3, aus der Neuschneidung dieses
  Slice hervorgegangen (§1/§4).
- **Risiken aus §6:** vier, jedes mit genau einem Ausgang — Risiko 1 *eingetreten* (Rückführung mit
  Neuschnitt), Risiko 2 *entfallen* (comm-Ergebnis deckungsgleich, kein Fall reißt zwei Wächter),
  Risiko 3 *entfallen* (zwei individuell begründete Grenz-Kommentare), Risiko 4 *entfallen* (Fall
  393 und die `full-smoke`-`span-report`-Zähne messen unabhängige Eigenschaften an unabhängigen
  Beständen) — Details je bei §6.
- **Drei Paarungen** (Repo ohne Wellen-Betrieb, hier geprüft):
  (a) **Anker-Paarung** — kein Eintrag dieser Closure trägt `liegt in <Zielort>` (kein
  Register-Eintrag erreicht mit diesem Slice erstmals 3×), daher nichts zu prüfen.
  (b) **Folge-Slice-Paarung** — `slice-leser-und-aufraeum-waechter-decken-was-sie-sagen` existiert
  als Datei in `open/` (`ls docs/plan/planning/open/slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md`).
  (c) **Register-Paarung** — das neu angelegte Verzeichnis
  `docs/plan/planning/observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/` existiert
  mit einer nicht-leeren `evidence/` (jetzt ein Eintrag); die beiden bereits verkörperten
  Register-Einträge, auf die Risiko 2/3 sich stützen, existieren unverändert mit nicht-leerer
  `evidence/`.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/emit/`, `internal/span/` und
`test/mutations/` — alle in `*`. `internal/report/` (Leser) und `harness/tools/` (`TOOLS`, Zahn des
Aufräum-Ziels) sind mit dem Leser/Aufräum-Bestand an den Folge-Slice gewandert. Die berührte
Sub-Area erfüllt das Inklusionskriterium; ausdifferenziert wird nichts.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die `state.md` des
Eintrags; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen (reduzierten) Slice |
|---|---|---|---|
| [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) | 8 | verkörpert | der Gegenstand dieses Slice in einem Satz |
| [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md) | 3 | verkörpert | §6 Risiko 2 und die ausgesprochene Grenze als Ausgang |
| [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) | 4 | verkörpert | §6 Risiko 4 |

DoD 2 (ursprünglich mit
[`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
verknüpft) ist mit dem Leser-Bestand an den Folge-Slice gewandert; die Berührung steht dort.
Keiner der verbliebenen Einträge erreicht **mit diesem Slice** erstmals 3×.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
