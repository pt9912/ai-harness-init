# Slice slice-110: Die Wächter der Erfassungs-Ausgabe tragen ihren Fall, ihre Meldung und ihre Grenze

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Durchgang über eine abgeschlossene Wächter-Menge, einzeln
lieferbar. **(2) Gemeinsames Closure-Kriterium?** Nein — jedes wäre die Abschrift der eigenen DoD.
**(3) Auslöser reaktiv oder gewollt?** Reaktiv: sechs Befunde einer Verifikation und eines Reviews
(§1). Nach Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das
Verzeichnis.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Wächter, der weniger sieht als seine Meldung behauptet, sagt einen Prüfbereich zu, den er nicht
hat — dieselbe Klasse eine Ebene neben dem Gate),
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Gegenstand der
bewachten Zusagen: Leser und Aufräum-Kommando im Ziel),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 4, 6 Stück 2 und 8 sind die Verträge, über die diese Wächter wachen),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (wer keinen Fall in `test/mutations/` hat, gilt als
unbewacht — die Regel, an der DoD (2) hängt).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-26.

---

## 1. Ziel

**Jeder Wächter über Leser und Aufräum-Fragment gibt eine Meldung aus, die auf seinen Treffer
zutrifft; jede Zusage, die er hält, hat ihren `test/mutations/`-Fall oder ihre ausgesprochene
Grenze; und wo er eine Menge nicht sieht, sagt er es.**

Der Bestand, über den dieser Slice geht, ist geschlossen und benannt: die Wächter aus
[`internal/emit/erfassung_test.go`](../../../../internal/emit) und
[`internal/report/report_test.go`](../../../../internal/report), das Fragment
`harness/mk/erfassung.mk` und die zugehörigen Fälle unter `test/mutations/`. <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->

### Die sechs Befunde, die diesen Schnitt tragen — jeder mit seinem Kommando

| # | Befund | Kommando, das den heutigen Stand zeigt |
|---|---|---|
| (a) | Die Meldung des Gate-Tabellen-Wächters verlangt wörtlich `KEIN GATE`, geprüft wird `kein Gate` — eine Zeile mit genau dem, was die Meldung fordert, bleibt rot | `grep -n 'kein Gate\|KEIN GATE zu sagen' internal/emit/erfassung_test.go` |
| (b) | `span-clean` meldet *„entfernt"* auch über einem Zustand, in dem nichts zu entfernen war | `grep -n 'entfernt' internal/emit/templates/enforce/erfassung.mk` |
| (c) | `TestAggregiere_ZeilenZaehltAuchUnlesbare` hat Zähne, aber keinen Fall | `grep -rl 'ZeilenZaehltAuchUnlesbare' test/mutations/ \| wc -l` → **0** |
| (d) | Der Satz *„ein erneuter Lauf des Werkzeugs legt ihn wieder ab"* hat einen **Anwesenheits**-Wächter, keinen über seiner **Wahrheit** | `grep -n 'erneuter Lauf des Werkzeugs legt ihn wieder ab' harness/tools/full-smoke.sh` |
| (e) | Der Gate-Tabellen-Wächter liest für zwei seiner fünf Dokument-Quellen eine synthetische Fixture statt des realen vendored Satzes; die Meldung sagt es nicht | `grep -n 'courseSet\|claimSet' internal/emit/emitteddocs_test.go internal/emit/templates_test.go` |
| (f) | Die Menge der Ziel-Quellen enthält das konditionale Arch-Gate-Fragment nicht, und die benannte Grenze nennt es nicht | `sed -n '/func makeQuellenDesZiels/,/^}/p' internal/emit/erfassung_test.go \| grep -c ArchGate` → **0** |

Alle sechs Zahlen wandern mit ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Warum das ein Slice ist und nicht sechs.** Die sechs teilen den Gegenstand (dieselben zwei
Test-Dateien plus ein Fragment), die Leserichtung (was sagt der Wächter über sich selbst?) und die
Prüfbarkeit in einer Sitzung. Sie zu trennen erzeugte Slices, die dieselbe Datei nacheinander
anfassen — der Schicht-Schnitt, vor dem Modul 5 §Ziel-Form warnt. Die Präzedenz für die Form ist
[slice-103](../done/slice-103-traeger-waechter-decken-was-sie-sagen.md) (dieselbe Frage für die
Träger-Ablage) und [slice-108](../done/slice-108-feldlisten-waechter-tragen-ihren-fall.md) (für die
Feldliste); dies ist die dritte Ausfertigung, für Leser und Aufräum-Fragment.

**Was dieser Slice nicht ist: eine Korrektur der Leser-Ausgabe.** Dass der Leser seine Lagen
mit zutreffenden Ursachen begründet, ist ein anderer Gegenstand — er liegt in
[slice-071](../next/slice-071-bilanz-nennt-ihren-bestand.md), weil er dieselbe Ausgabe und dieselbe
Lagen-Trennung betrifft. Hier geht es um die **Wächter**, dort um das **Produkt**.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Jede Meldung dieses Bestands trifft ihren Treffer — und wer ihr folgt, kommt ins
      Grün.** Betroffen sind (a) und (b) aus §1: die Gate-Tabellen-Meldung nennt genau die
      Schreibweise, die der Wächter akzeptiert (oder der Wächter akzeptiert die genannte), und das
      Aufräum-Ziel meldet, **was es getan hat**, statt was es getan hätte.
      **Rot:** ein `test/mutations/`-Fall mit `# verify: test-go`, der eine Gate-Tabellen-Zeile mit
      **exakt der von der Meldung verlangten** Schreibweise einträgt — er muss **grün** bleiben,
      solange die Meldung recht hat, und der Wächter muss fallen, sobald sie es nicht tut. Für (b)
      ein zweiter Lauf des Aufräum-Ziels über bereits leerem Zustand, im Zahn von
      [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh).
- [ ] **(2) Jede Zusage dieses Bestands trägt ihren Fall oder ihre ausgesprochene Grenze.**
      Betroffen sind (c) und (d) aus §1. Für (c) ein Fall, der die Zeilen-Zählung hinter den
      Parse-Zweig schiebt. Für (d) die Entscheidung zwischen **Fall** (der Idempotenz-Abschnitt
      lässt den Träger driften und prüft die Wiederablage) und **ausgesprochener Grenze** (der Satz
      sagt, dass nur seine Anwesenheit bewacht ist) — beide Ausgänge sind zulässig, *„genannt"*
      ist keiner.
      **Rot:** `make mutate` mit dem neuen Fall zu (c); für (d) das gewählte Rot-Kommando im Plan
      benannt, bevor gebaut wird.
- [ ] **(3) Wo ein Wächter eine Menge nicht sieht, sagt er es — in der Meldung, nicht im
      Kommentar.** Betroffen sind (e) und (f) aus §1: die Fixture-Grenze des Gate-Tabellen-Wächters
      und das fehlende Arch-Gate-Fragment in der Menge der Ziel-Quellen.
      **Rot:** ein Go-Test, der die **benannte** Grenze gegen den tatsächlich gelesenen Satz hält
      und fällt, sobald eine Quelle dazukommt, die die Grenze nicht führt; dazu ein
      `test/mutations/`-Fall mit `# verify: test-go`, der genau diese Quelle hinzufügt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/erfassung_test.go`](../../../../internal/emit) — Meldungstexte, benannte Grenzen, gelesene Quellenmenge | update | (a), (e), (f) aus §1 |
| [`internal/emit/templates/enforce/erfassung.mk`](../../../../internal/emit) — die Meldung des Aufräum-Ziels | update | (b) aus §1; der Text ist emittiert, also verbatim und konvergent ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) |
| [`internal/report/report_test.go`](../../../../internal/report) | **unverändert oder Fall-Nennung** | (c) braucht den Fall, nicht den Test — der Wächter hat gemessen Zähne |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | (b) zweiter Aufräum-Lauf; (d), falls der Ausgang *Fall* statt *Grenze* ist |
| `test/mutations/` — Fälle für (a), (c) und (3) <!-- d-check:ignore (geplante Dateien) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht |
| **Bestehende gemeinsame Stellen, die ein neuer Wächter bewegt** — heute erkennbar: `emitDokumentSatz` in [`internal/emit/emitteddocs_test.go`](../../../../internal/emit) (Fixture-Grenze (e)) und `makeQuellenDesZiels` (Quellenmenge (f)) | update | Diese Zeile steht hier, weil die letzten drei Slices dieser Familie genau sie im Plan nicht hatten (Träger: [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), neunter Posten) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

## 4. Trigger

**`open` → `next`:** keine Vorbedingung außerhalb dieses Slice — der bewachte Bestand ist gebaut
und abgeschlossen ([slice-099](../done/slice-099-leser-und-aufraeum-kommando.md)), und keine
Entscheidung steht aus. Beobachtbar ohne Rückfrage: die sechs Kommandos aus §1 laufen und liefern
die dort genannten Werte. **`next` → `in-progress`:** WIP-Limit frei.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn der Ausgang von (e) den
**Docker-Build-Kontext** berührt (`.dockerignore` schließt `.harness/` aus, seit slice-022b) —
dann ist die Fixture-Grenze kein Meldungs-Problem, sondern ein Bau-Problem, und der Schnitt läuft
zwischen *Grenze nennen* und *Grenze schließen*. `in-progress` → `open`, wenn (d) nicht ohne eine
Aussage über die Idempotenz-Klasse des Trägers entscheidbar ist — dann steht eine Entscheidung
aus, und ein Slice, der sie nebenbei träfe, träfe sie an der falschen Stelle. Beide Bedingungen
sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` grün mit den neuen
Fällen, `make full-smoke` grün über beide Bootstrap-Varianten, Closure-Notiz in §7 mit
Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Eine Meldung zu ändern ist billiger, als sie richtig zu machen.** Bei (a) sind zwei Ausgänge
  zulässig — die Meldung an den Wächter anpassen oder den Wächter an die Meldung —, und nur der
  zweite entscheidet die Sachfrage, welche Schreibweise ein Adopter schreiben darf. Wer den
  billigeren nimmt, ohne die Frage zu stellen, hat die Meldung geheilt und die Zusage nicht.
  — **Ausgang: eingetreten** → `slice-waechter-der-erfassungsschicht-decken-was-sie-sagen`. Der
  Nehmer lässt beide Ausgänge ausdrücklich zu und bindet sie an einen Rot-Weg: Sein Liefer-Punkt
  (2) verlangt, dass die Meldung genau die Schreibweise nennt, die der Wächter akzeptiert — *oder*
  der Wächter die genannte —, geprüft durch einen `test/mutations/`-Fall, der eine Zeile in
  **exakt der von der Meldung verlangten** Schreibweise einträgt. Die Sachfrage ist damit nicht
  mehr umgehbar.
- **(b) sieht harmlos aus und ist die Klasse dieses Bestands.** Eine Meldung, die eine Entfernung
  behauptet, die nicht stattfand, ist folgenlos — bis jemand sie als Beleg liest. Der Ausgang darf
  auch *„die Meldung bleibt, weil sie über die Zusage spricht und nicht über den Lauf"* sein,
  aber dann steht dieser Satz geschrieben.
  — **Ausgang: eingetreten** → derselbe Nehmer. Er schreibt den Satz, den dieses Risiko verlangt,
  als Zusage statt als Option: *„das Aufräum-Ziel meldet, **was es getan hat**, statt was es getan
  hätte"* (Liefer-Punkt 2), mit dem zweiten Lauf über bereits leerem Zustand als Rot-Weg.
- **(d) kann teuer werden.** Ein Zahn über der **Wahrheit** des Wiederablage-Satzes braucht einen
  zweiten Init-Lauf nach einer Träger-Wegnahme — ein `full-smoke`-Fall, und genau diese Klasse
  misst [slice-105](../done/slice-105-mutate-messen-dann-teilen.md) als Klippe. Die ausgesprochene Grenze
  ist der billigere Ausgang und muss nicht der schlechtere sein.
  — **Ausgang: eingetreten** → derselbe Nehmer, und dort ist der teurere Weg **gewählt**: Sein
  Liefer-Punkt (2) verankert den zweiten Lauf im Zahn von
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh). Die ausgesprochene
  Grenze bleibt der Rückfall, nicht der Default.
- **(e) ist eine vorbestehende Grenze der gesamten Emit-Test-Infrastruktur**, nicht ein Defekt
  dieses Wächters. Wer sie hier zu schließen versucht, schneidet einen anderen Slice.
  — **Ausgang: eingetreten** → derselbe Nehmer. Seine Liefer-Punkt (3) nennt die **Fixture-Grenze
  des Gate-Tabellen-Wächters** ausdrücklich als einen der zwei betroffenen Fälle und verlangt, dass
  der Wächter sie in seiner **Meldung** sagt. Die vorbestehende Grenze bleibt damit eine benannte,
  kein geschlossener Nebengegenstand.
- **(f) ist heute nicht realisiert.** Das Arch-Gate-Fragment behauptet nichts über die zwei Ziele
  (`grep -c 'span-' internal/emit/archgate.go` → **0**, mitwandernd). Der Slice schließt eine
  **Aussage**-Lücke, keine gemessene Verletzung — das gehört in die Closure-Notiz, damit niemand
  einen Fund behauptet, wo eine Vorsorge steht.
  — **Ausgang: eingetreten** → derselbe Nehmer. Sein Liefer-Punkt (3) führt die **Menge der
  Ziel-Quellen ohne das konditionale Arch-Gate-Fragment** als zweiten Fall und hält sie mit einem
  Go-Test gegen den tatsächlich gelesenen Satz. Dass hier eine **Aussage**-Lücke und keine
  gemessene Verletzung vorliegt, wandert mit: Der Rot-Weg entsteht dort durch eine **hinzugefügte**
  Quelle, nicht durch einen Fund.

## 7. Closure-Notiz (nach `done/`)

**Gegenstand:** übernommen von `slice-waechter-der-erfassungsschicht-decken-was-sie-sagen`.

**Stillgelegt ohne Lieferung** — Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice,
dessen Gegenstand ein anderer übernimmt. Die Liefer-Punkte in §2 bleiben **leer**: Dieser Slice
hat nichts geliefert, und ein Haken behauptete es. `Verantwortlich:` bleibt stehen.

**Die Adresse nimmt an.** Der Nehmer liegt in `open/`, ist nicht geschlossen und nennt in §1
unter `Übernimmt:` diese Kennung. Er führt den Gegenstand in seinen Liefer-Punkten (2) und (3)
und nennt den Erfassungs-Bestand (`internal/emit/erfassung_test.go`,
`internal/report/report_test.go`, das Aufräum-Fragment
`internal/emit/templates/enforce/erfassung.mk`) ausdrücklich als Teil seiner geschlossenen Menge.

**Wellenlos.** Der Kopf führt keine Welle; die Roadmap führt wellenlose Arbeit nicht
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht), und diese Closure trägt sie allein.

**Was hat funktioniert:** Der Slice hatte je Fall die zulässigen Ausgänge **vorab** benannt und
die billige Antwort (Meldung anpassen) von der tragenden (Wächter entscheiden) getrennt. Genau
diese Trennung steht im Nehmer als Zusage mit Rot-Weg — sie hat den Schnitt überlebt, weil sie
eine Bedingung war und keine Aufzählung.

**Was ging anders als geplant:** Geprüft hat den Schnitt keine Implementation, sondern erst die
Gruppierung — das Muster *tote Slices* aus `modul-05-planning-harness.md` §Regeln gegen typische
Fehlannahmen. Der Plan stand von seinem Schnitt am 2026-08-23 an unbeansprucht in `next/`, und er
ist der älteste der drei Wächter-Geber; der Nehmer bündelt sie in einer Leserichtung.

**Steering-Loop-Eintrag:** **gezählt, nicht verkörpert** — kein Zielort, darum **kein**
`liegt in`-Feld (`grundlagen-traceability.md` §Herkunfts-Anker). Die Form der Stilllegung steht
seit `v6.9.0` in der adoptierten Baseline; eine zweite Fassung daneben driftete.

**Beobachtungs-Register** (`../observations/`): zitiert, nicht neu formuliert —
[`BEO-ALL/geplanter-slice-wird-nie-gearbeitet`](../observations/BEO-ALL/geplanter-slice-wird-nie-gearbeitet/observation.md).
**Keine zweite Beleg-Datei:** Dieser Geber steht dort unter *Benannt, nicht gezählt*; er ist ein
Fund **derselben** Gelegenheit wie `slice-090-freshness-audit-im-ziel`, und der Zähler misst
Wiederholung über Vorgänge hinweg, nicht die Zahl der Funde (`modul-06-roadmap.md` §Das
Beobachtungs-Register). Der Stand bleibt `offen`, unter der Schwelle.

**Lese-Schritt** (Repo ohne Wellen-Betrieb, `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht): Kein Eintrag erreicht mit dieser Closure 3×, und kein Eintrag über der Schwelle steht
ohne Ausgang — dasselbe Kommando wie in
[`slice-090`](slice-090-freshness-audit-im-ziel.md) §7, Ausgabe leer.

**Die drei Paarungen.** (a) Anker-Paarung: kein Eintrag trägt `liegt in`, sie hat keinen
Gegenstand. (b) Folge-Slice-Paarung: kein Folge-Slice genannt. (c) Register-Paarung: die zitierte
Beobachtung existiert als Verzeichnis und trägt einen Beleg.

**Was diese Closure nicht trägt:** Review und Verifikation am Gegenstand — es gibt keinen Diff,
den sie prüfen könnten. Geprüft ist die **Form** der Stilllegung durch `make docs-check` (Modul
`structure`, `open-tasks-require-marker`) und der Gesamtstand durch `make gates`.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/`,
`internal/report/`, `harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
