# Slice slice-184: Die Form-Beschreibung des Beobachtungs-Registers zieht im Bestand nach

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — **Mitglied**, und der Grund ist nicht Nähe,
sondern Gleichzeitigkeit: Ab dem Moment, in dem
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) die Ablage umzieht, weisen
**zehn** lebende Slice-Pläne und **vier** Anweisungssatz-Dateien einen Vorgang an, den es nicht
mehr gibt (§1, mit Kommando). Das Welle-Ziel *„statt einzeln als Nachzügler zurückzukommen"* wäre mit einem Ausgang in
`open/` gerade nicht eingelöst — der Nachzügler wäre schon da.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die
Form-Pflicht kommt aus dem auf einen Tag gepinnten Baum),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (ein
Rollen-Anweisungssatz gehört der Rolle, die ihn **ausführt** — dieser Slice berührt drei davon),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die Ziel-Gestalt, die hier zitiert wird, statt sie zweitzufassen),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando).

**Berührte Spec-Stellen:** `—`. Der Slice zieht Form-Beschreibungen nach; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Kein lebendes Artefakt dieses Repos und kein emittiertes beschreibt das Beobachtungs-Register
noch als Tabelle mit gepflegtem Zähler.**

**Der Gegenstand ist die Form-Beschreibung, nicht jede Adresse — und die Grenze ist jetzt real
gemessen, nicht nur behauptet** (Review-Nacharbeit an
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md), Review-Fund
MEDIUM-1: die beiden Pläne wiesen sich wechselseitig dieselbe Teilmenge zu, ohne dass einer sie
trug). [slice-177] zieht die bare Adresse `observations.md` → `observations/README.md` überall
dort nach, wo sie **unabhängig** von der Vorlagen-Zeile unten auftritt — namentlich in allen
sechs Anweisungssatz-Dateien (§ unten). **Was hier bleibt**, ist die **Anweisung daneben**, dort wo
Adresse und Form **dieselbe Zeichenkette** sind und sich nicht trennen lassen — die Vorlagen-Zeile
*„Beobachtungs-Register (`../observations.md`) fortgeschrieben"* selbst, mit ihrer Anweisung: *neue
`BEO-<NNN>` oder Zähler +1*, *`BEO-<NNN>` zitieren und den Zähler erhöhen*, *jede Registerzeile
trägt einen Beleg*. Unter der Ziel-Form gibt es keine Zeile, keine fortlaufende Nummer und keinen
Zähler, den man erhöht — er **folgt** aus den Dateien (Position **P-14** des Katalogs in
[slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9).

**Der Bestand ist gemessen, nicht geschätzt:**

```sh
git grep -lE 'Beobachtungs-Register \(`\.\./observations\.md`\) fortgeschrieben' \
  -- 'docs/plan/planning/open/*.md' 'docs/plan/planning/next/*.md' \
     'docs/plan/planning/in-progress/*.md' | wc -l                              # 10 Plaene
ls docs/plan/planning/open/*.md docs/plan/planning/next/*.md \
   docs/plan/planning/in-progress/slice-*.md | wc -l                            # 60 Plaene gesamt
git grep -lE 'BEO-<NNN>|Registerzeile|Zähler erhöhen' \
  -- .claude/commands internal/emit/templates/commands | wc -l                  #  4 Dateien
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Beträge wandern mit jedem neu geschnittenen Plan.

**Die vier sind die Form-Hälfte, nicht die Adress-Hälfte.** Nimmt man den Pfad `observations.md`
mit ins Muster, sind es **alle sechs** Anweisungssatz-Dateien — die zwei zusätzlichen trugen die
Adresse und sonst nichts von der alten Form, und die Adresse hat
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) bereits über seine
eigene Bezugsmenge nachgezogen (alle sechs Dateien zeigen jetzt auf `observations/README.md`).
Dieser Slice übernimmt für alle sechs nur noch die **Form**-Sprache (`BEO-<NNN>`, *Registerzeile*,
*Zähler erhöhen*), nicht mehr die Adresse. Beide Mengen sind mit demselben Kommando und nur
getauschtem Muster gemessen, damit die
Grenze zwischen den zwei Slices nicht behauptet, sondern sichtbar ist.

**Ein dritter Träger steht jetzt neben den beiden, und die Grenze ist textlich gemessen.**
[slice-186](../in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) zieht die **Identität** einer
konkreten Beobachtung nach — eine dreistellige Nummer im Fließtext oder als Link-Label, die seit
dem Umzug nirgends mehr auflöst. **Hier bleibt die Form-Sprache**: der Platzhalter
`BEO-<NNN>` mit seinen spitzen Klammern, *Registerzeile*, *Zähler erhöhen*. Die zwei Mengen
schneiden sich nicht — `printf 'BEO-<NNN>\n' | grep -c 'BEO-[0-9][0-9][0-9]'` → **0**, der
Platzhalter trägt keine dreistellige Zahl —, und die Grenze steht symmetrisch in beiden Plänen,
wie sie es zwischen diesem Slice und
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) schon tut. **Kein
vierter Liefer-Punkt hier:** Die DoD unten führt drei, und Modul 5 lässt nicht mehr zu.

**Zwei Ebenen, und sie sind auseinanderzuhalten.** Die drei Anweisungssätze unter
`.claude/commands/` binden **diesen** Lauf; ihre Gegenstücke unter
`internal/emit/templates/commands/` sind **Produkt** und binden jeden Adopter. Dieselbe Änderung,
zwei Verträge — deshalb steht die emittierte Hälfte als eigener DoD-Punkt und nicht als Anhang.

**Was dieser Slice nicht entscheidet.** Wer die Anweisungssätze schreiben darf, ist die offene
Frage aus `BEO-007` (4×, **geplant**); sie wird hier nicht beantwortet, sondern **angewandt**:
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) gibt jeden
Anweisungssatz der Rolle, die ihn ausführt, und der Slice zerlegt seine Commits danach.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Die lebenden Slice-Pläne tragen die Ziel-Form.** Die DoD-Zeile und die §7-Zeile jedes
      Plans in `open/`, `next/` und `in-progress/` nennen die Verzeichnis-Ablage und **setzen
      keinen Zähler** — der Wortlaut kommt aus `slice.template.md` des dann vendored Stands, nicht
      aus einer eigenen Formulierung. Vollständigkeit gemessen statt behauptet: das Kommando aus
      §1 trifft danach **null**. **Zeitdokumente bleiben unangetastet** — `done/` und
      `docs/reviews/` sind Chronik von Beruf ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
- [x] **Die drei Anweisungssätze unter `.claude/commands/` tragen die Ziel-Form** — kein
      `BEO-<NNN>`, keine *Registerzeile*, kein *Zähler erhöhen*. **Der Commit-Zuschnitt folgt
      [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md):**
      `plan-welle.md` und `close-welle.md` gehören dem Planner, `implement-slice.md` dem
      Implementer — zwei Rollen, zwei Commits, die Rolle je in der Message.
- [x] **Die emittierten Gegenstücke ziehen mit.** `internal/emit/templates/commands/` trägt
      denselben Stand; belegt durch `make full-smoke` — dass die emittierte Hälfte über `make gates`
      allein nicht gedeckt ist, ist gemessen und nicht vermutet
      ([slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md)).
- [x] `make gates` grün.
- [x] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice. **Ein öffentlicher
      Vertrag ist berührt** — die emittierten Anweisungssätze sind das, was ein Adopter bekommt;
      die Änderungshistorie von [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md)
      bekommt ihre Zeile, ihre **bestehenden** Zeilen bleiben unangetastet.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register fortgeschrieben — neuer Eintrag oder ein weiterer Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Slice-Pläne in `open/`, `next/`, `in-progress/` | update | die zwei Vorlagen-Zeilen je Plan, Bezugsmenge in §1 |
| [`.claude/commands/`](../../../../.claude/commands/) | update | drei Anweisungssätze, **zwei Commits** nach Rolle |
| `internal/emit/templates/commands/` | update | die emittierte Hälfte — anderer Vertrag, eigener DoD-Punkt |
| [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md) | update | eine neue Zeile in der Änderungshistorie |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) liegt in `done/`. Der Grund ist
tragend, nicht ordnend: Der Ziel-Wortlaut, den die Pläne übernehmen, ist der der neuen
`slice.template.md`; vorher schriebe der Lauf eine Form ab, die im Repo noch keinen Gegenstand hat,
und die zehn Pläne verwiesen auf eine Ablage, die es nicht gibt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Anweisungssätze nicht mit einer
  Ersetzung auskommen, sondern ihre Register-Abschnitte neu geschrieben werden müssen. Dann trennt
  der Schnitt den Plan-Bestand (Liefer-Punkt 1) von den Anweisungssätzen (Liefer-Punkte 2 und 3) —
  und Letztere zerfallen ohnehin schon nach Rolle.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Plan im Bestand seine DoD-Zeile nicht
  bloß umformuliert bekommt, sondern durch den Sprung eine **andere Pflicht** trägt (`BEO-023`).
  Das ist ein Urteil je Plan und gehört nicht in einen mechanischen Nachzug.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die zwei Kommandos aus §1 treffen null; `make full-smoke` grün; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Nachzug ersetzt Wortlaut und lässt die Pflicht dahinter stehen** (`BEO-023`, 2×). Ein Plan
  in `open/` kann durch den Sprung nicht nur anders **formuliert**, sondern anders **verpflichtet**
  sein; eine Ersetzung, die das nicht prüft, macht aus einer offenen Frage eine erledigte. Steht
  als zweite Rückführung in §4. — **Ausgang: entfallen.** Alle **acht** Ersetzungen sind ein
  Träger-Wechsel derselben Pflicht: Der Wortlaut ist der der vendored `slice.template.md` —
  `grep -cF 'fortgeschrieben — neues Verzeichnis' .harness/baseline/v6.0.0/templates/docs/plan/planning/slice.template.md`
  → **1**, **kein** Erwartungswert —, und die verlangte Handlung — *das Register fortschreiben* — ist vorher wie nachher dieselbe; nur ihr
  Mittel wechselt von Zeile-plus-Zähler auf Verzeichnis-plus-Beleg. Kein Plan gewinnt oder
  verliert dadurch eine Pflicht, und das Urteil je Plan war damit für alle acht dasselbe.
- **Die Bezugsmenge ist ein `grep` und keine Vollständigkeitsaussage** (`BEO-025`, 2×). Die zwei
  Kommandos in §1 finden **Muster**; eine Prosa-Beschreibung der Tabellen-Form ohne diese Wörter
  fänden sie nicht. Der Slice sagt darum die getroffene Menge zu, nicht die vollständige. —
  **Ausgang: eingetreten →**
  [slice-188](../open/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md). Zweimal
  eingetreten, an zwei Orten mit zwei Folgen. **Innerhalb** der Anweisungssätze: Das Muster fand
  **zwei** von **vier** betroffenen Dateien; die zwei übrigen tragen dieselbe Tabellen-Form unter
  anderen Wörtern (`— keine —`, *Gestrichene Einträge*, *keine Zeile*) und sind hier mitgezogen
  worden — gefunden hat sie das Lesen, nicht der Sensor. **Außerhalb**, und dort nicht
  absorbierbar: `internal/archive/stub.go` erkennt die Kennung als `BEO-[0-9]{3}` und baut den
  Link auf die abgelöste Register-**Datei**, die der Umzug in ein Verzeichnis aufgelöst hat (den
  Pfad nennt die Datei selbst); eine Closure-Notiz in der heutigen Form fällt durch den Ausdruck
  **durch**, und das Stub-Feld verliert die Zeile still. Go-Dateien liegen in keiner der drei
  Bezugsmengen dieser Welle — `git grep -l 'BEO-[0-9]\|observations\.md' -- '*.go' | wc -l` →
  **3**, während [slice-186](../in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) über
  `'*.md'` misst. Das ist ein zweiter Liefergegenstand und damit ein eigener Slice, kein vierter
  DoD-Punkt hier.
- **Die emittierte Hälfte wird als dieselbe Änderung behandelt wie die lokale** (Dogfood ≠
  emittiert). Beide tragen denselben Text, aber verschiedene Verträge: der eine bindet diesen Lauf,
  der andere jeden Adopter — und nur der zweite verlangt eine Zeile in der Änderungshistorie. —
  **Ausgang: entfallen.** Die zwei Ebenen sind als zwei Verträge behandelt worden: eigener
  DoD-Punkt, `make full-smoke` als Beleg, und eine Zeile in der Änderungshistorie **nur** für die
  emittierte Hälfte. Die Annahme *„beide tragen denselben Text"* ist dabei gemessen **falsch** —
  jede Ebene trug eine Formulierung, die die andere nicht hatte —, und beide sind darum einzeln
  gelesen und einzeln gezogen worden; die Prämisse des Risikos trifft nicht mehr zu.
- **Zwei Rollen in einem Lauf** (`BEO-007`, 4×, **geplant**). `implement-slice.md` gehört dem
  Implementer ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md));
  wer ihn im selben Kontext wie die Planner-Sätze ändert, hat den Rollenwechsel übersprungen, den
  der Commit-Zuschnitt nur noch abbildet. — **Ausgang: entfallen.** Der Rollenwechsel hat
  stattgefunden, nicht bloß der Commit-Zuschnitt: Der Implementer lieferte `implement-slice.md`
  lokal und emittiert und **ließ die zwei Wellen-Commands stehen**, weil
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 sie
  dem Planner gibt; der Planner-Kontext hat sie in einem eigenen Lauf und einem eigenen Commit
  gezogen. Die ADR ist damit angewandt und nicht ausgelegt worden.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Der Schnitt nach **Rolle** statt nach Datei. Der Implementer-Lauf hat
  die zwei Wellen-Commands nicht angefasst und den Grund benannt; der Planner-Lauf hat sie
  gezogen. Der Rollenwechsel ist damit an `git log --stat` ablesbar und nicht bloß behauptet — und
  er hat sich sofort ausgezahlt: Der zweite Kontext fand beim Lesen die Hälfte der Arbeit, die das
  DoD-Muster nicht sah.
- **Was ging anders als geplant:** Die Bezugsmenge war zu klein, und zwar messbar. Das Muster aus
  §1 traf **vier** Anweisungssatz-Dateien; betroffen waren **sechs** — in der Hälfte dieses
  Planner-Laufs **zwei** von **vier**. Die zwei ungesehenen tragen dieselbe abgelöste Form unter
  anderen Wörtern: `— keine —`, *Gestrichene Einträge*, *keine Zeile*. Beide Werte sind über
  denselben Ref und nur getauschtes Muster erhoben, **keine Erwartungswerte**:

  ```sh
  git grep -lE 'BEO-<NNN>|Registerzeile|Zähler erhöhen' bfd117a^ \
    -- .claude/commands internal/emit/templates/commands | wc -l                       # 4
  git grep -lE 'BEO-<NNN>|Registerzeile|Zähler erhöhen|— keine —|Gestrichene Einträge|leerer Tabelle|jede Zeile mit Zähler' \
    bfd117a^ -- .claude/commands internal/emit/templates/commands | wc -l              # 6
  ```

  Dass das emittierte `plan-welle.md` überhaupt betroffen war, stand in keinem Lauf-Bericht;
  gefunden hat es die Sichtung aller sechs Dateien mit erweitertem Muster. Zweitens hat dieselbe Sichtung einen
  Träger **außerhalb** aller drei Bezugsmengen dieser Welle sichtbar gemacht
  (`internal/archive/stub.go`, §6 Risiko 2) — der Grund für den Folge-Slice unten.
  Und drittens: das Bestands-Kommando aus §1 traf beim Start **9** Pläne und danach **1** — diese
  **1** ist dieser Plan selbst, der die getilgte Zeile in §1 zitiert; er verlässt den Pathspec mit
  dem `git mv` nach `done/`. Beide Werte sind **keine Erwartungswerte**
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2), gefahren als
  `git grep -lE 'Beobachtungs-Register \(`\.\./observations\.md`\) fortgeschrieben' <ref> -- 'docs/plan/planning/open/*.md' 'docs/plan/planning/next/*.md' 'docs/plan/planning/in-progress/*.md' | wc -l`
  über `bfd117a^` und `HEAD`.
- **Steering-Loop-Eintrag:** *benannte Spec-Lücke.* Ein Slice, der einen Bestand über ein
  **Muster** definiert, sagt heute die getroffene Menge zu — und keine Quelle verlangt, dass er
  die **Achse** nennt, entlang derer das Muster blind ist. Hier war es die Achse *dieselbe Aussage
  in anderen Wörtern* (die zwei ungesehenen Dateien) und die Achse *derselbe Gegenstand in einer
  anderen Dateiklasse* (`'*.md'` gegen `'*.go'`). Beide Blindstellen sind erst beim Lesen
  aufgefallen, nicht beim Messen. Ein Sensor dafür ist **nicht** gebaut und wird hier nicht
  behauptet
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
  der Eintrag ist gezählt, nicht verkörpert — die Teil-Zeile `— liegt in …` entfällt darum
  ersatzlos.
- **Beobachtungs-Register (`../observations/`):** drei Vorgänge eingetragen, alle mit dem Beleg
  `evidence/slice-184.md`, keine Kennung neu formuliert, wo eine bestand.
  [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  ergänzt — Zähler steht damit bei **7×**;
  [`BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  ergänzt — **2×**; und
  [`BEO-ALL/mess-zusage-trifft-das-eigene-zitat`](../observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/observation.md)
  **neu angelegt** — **1×**. Der Zähler ist jeweils die Zahl der Dateien unter `evidence/`,
  gemessen mit `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`; **keine
  Erwartungswerte**. Die Ergänzung an `zusage-nennt-sensor-der-form-nicht-sieht` ist der
  **Zähler**-Vorgang für ein Auftreten der Klasse und **nicht** ein zweiter Ausgang für Risiko 2 —
  dessen einer Ausgang ist der Folge-Slice unten.
- **Folge-Slices:**
  [slice-188](../open/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md) (*Der
  Archiv-Stub kennt die Kennungs-Form des Registers*) — liegt als Datei in `open/`.
- **Risiken aus §6:** vier notiert, vier mit genau einem Ausgang — dreimal *entfallen* mit
  Begründung, einmal *eingetreten* mit Folge-Slice-ID. Keines steht ohne Ausgang da.
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — sie prüft die Closure von
  [welle-15](../welle-15-re-baseline.md).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area,
die die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
Planning-Artefakte, Anweisungssätze und den emittierten Baum führt. `.codex/` ist **nicht**
berührt: Es führt allein den SessionStart-Injektor und keinen Anweisungssatz.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Vier Zeilen berühren diesen Slice mit ihrem Zähler-Stand, keine erreicht mit
ihm 3×:

- `BEO-009` (10×, **geplant**) — *eine Zusage neben der geänderten Ableitung bleibt stehen*.
  **Dieser Slice ist ihr Ausgang für den Register-Fall**, nicht ihr elftes Auftreten.
- `BEO-023` (2×) — *ein Folge-Slice wartet in `open/` über einen Baseline-Sprung hinweg, und der
  Sprung ändert die Pflicht, die er halten soll*. Steht als Risiko in §6 und als zweite
  Rückführung in §4.
- `BEO-007` (4×, **geplant**) — *wer die Anweisungssätze schreiben darf, sagt keine Quelle*. Steht
  als Risiko in §6; angewandt, nicht entschieden.
- `BEO-025` (2×) — *eine Zusage nennt einen Sensor, der die zugesagte Form nicht sieht*. Steht als
  Risiko in §6 und bindet die Formulierung von DoD 1 und 3.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
