# Slice slice-116: Der Doku-Gate urteilt über den getrackten Bestand — ein Verweis auf ein ignoriertes Ziel ist auch dort rot, wo ein früherer Lauf es angelegt hat

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Prüfbereich, eine Frage; einzeln lieferbar.
**(2) Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD.
**(3) Auslöser reaktiv oder gewollt?** Reaktiv: drei rote CI-Läufe an einem Tag, deren Ursache lokal
grün war. Kein Fähigkeits-Sprung — der Gate prüft dieselbe Eigenschaft, nur über der richtigen
Menge. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist der Doku-Gate **dieses** Repos
([`.d-check.yml`](../../../../.d-check.yml), [`d-check.mk`](../../../../d-check.mk)). Ein
emittiertes Repo bekommt seine eigene Gate-Konfiguration aus dem Werkzeug
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); was
dort an Prüfbereichs-Regeln gilt, entscheidet der Slice, der die Tool-Ebene entscheidet — mit
eigener Abwägung, nicht als Nebenwirkung. **Und die Frage ist dort nicht dieselbe:** ein Adopter hat
andere ignorierte Pfade als wir.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse in Reinform: ein Gate, das grün meldet, weil sein Prüfbereich einen Rückstand enthält, den
ein frischer Klon nicht hat),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (derselbe Baum liefert auf
zwei Maschinen zwei Verdikte — hier nicht wegen des Netzes, sondern wegen der Historie des
Arbeitsverzeichnisses),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede Zusage nennt, was sie rot färbt; für diese gibt es
heute ein Gegenbeispiel, das grün bleibt),
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(die Restlücke, die dieses Repo mit *„CI ist dort das Netz"* benennt — dies ist eine ihrer
gemessenen Instanzen),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (das
Gate-Fragment und seine Ebenen-Trennung),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (die CI
fährt auf frischem Klon — sie ist der Grund, aus dem die Lücke überhaupt sichtbar wurde),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(*„Gate-Anheben → Steering-Loop"* — eine Verschärfung braucht kein ADR),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie ausgibt),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**Ein Verweis auf ein Ziel, das `git` ignoriert, färbt einen Gate-Lauf rot — auch auf einer
Maschine, auf der ein früherer Lauf dieses Ziel angelegt hat.**

Der Lieferwert ist nicht die Reparatur eines Links. Der ist getilgt
(`git show --stat --format= c4a0c03 | tail -1` → **1 file changed, 1 insertion(+), 1 deletion(-)**).
Der Lieferwert ist, dass der nächste Verweis dieser Art **vor** dem Push auffällt und nicht in der
CI.

### Der gemessene Anlass: drei rote Läufe an einem Tag, dieselbe Zeile

| Zeitpunkt | Lauf | roter Job | Zeile |
|---|---|---|---|
| 2026-08-26T19:28 | `33005323228` | `gates` `98297459086` | `d-check: 403 Datei(en) geprüft, 1 Befund(e)` |
| 2026-08-26T18:46 | `33001548628` | `gates` `98284389358` | `d-check: 400 Datei(en) geprüft, 1 Befund(e)` |
| 2026-08-26T14:38 | `32981552921` | `gates` `98219369101` | `d-check: 399 Datei(en) geprüft, 1 Befund(e)` |

In allen dreien ist es **derselbe** Befund: `target-missing` auf einen Verweis aus
`docs/plan/planning/done/slice-098-feldliste-ist-ausdruck-des-traegers.md` in den gitignorierten
Zustands-Bereich (`gh api repos/:owner/:repo/actions/jobs/<job>/logs | grep 'target-missing'`, je
Job **eine** Zeile). Das sind **drei von elf** roten Läufen des Fensters, das
[slice-106](../in-progress/slice-106-rotes-ci-traegt-seinen-ausgang.md) §1 führt.

### Warum der Host es nicht sah — und warum die naheliegende Erklärung falsch ist

Das Ziel liegt unter dem gitignorierten Zustands-Bereich: `git check-ignore -q .harness/state/bin` <!-- d-check:ignore (der Pfad ist gitignoriert — genau das ist der Gegenstand; auf einem frischen Klon existiert er nicht) -->
trifft zu (Exit **0**). Auf einer Maschine, auf der ein früherer `make host-bin` gelaufen ist,
**existiert** er im Arbeitsverzeichnis, und der Doku-Gate löst den Verweis auf. Auf einem frischen
Klon existiert er nicht.

**Die naheliegende Erklärung — der Gate laufe vor dem Target, das den Pfad anlegt — trägt nicht.**
`grep -n '^gates:' Makefile` → Zeile **292**, und dort steht `docs-check` **vor** `host-bin`: ein
wirklich erster Lauf auf einem frischen Klon wäre also auch lokal rot. Die Blindheit entsteht durch
**Rückstände eines früheren Laufs**, nicht durch die Reihenfolge innerhalb eines Laufs
(**fremdbelegt**, in beide Richtungen nachgestellt:
[Verifikation zu slice-106](../../../reviews/2026-08-27-slice-106-verify.md) §6.8 — ohne den Pfad
`EXIT=2` mit einem Befund, mit ihm `EXIT=0` mit null Befunden). Wer die Lücke schließt, schließt sie
am **Prüfbereich**, nicht an der Target-Reihenfolge.

### Der Bestand heute: leer, und das ist der Grund, jetzt zu schneiden

**Die Eigenschaft vor der Zahl** — *ein relatives Markdown-Link-Ziel in einer getrackten Datei, das
`git check-ignore` bestätigt*: **0** von **450** Markdown-Dateien im Index
(`git ls-files '*.md' | wc -l` → **450**; die Ziel-Prüfung als Schleife über dieselbe Liste, je
Datei die Link-Ziele aus `grep -oE '\]\([^)#][^)]*\)'` ohne `http`/`mailto`, relativ zum
Verzeichnis der Datei aufgelöst und durch `git check-ignore -q` geschickt). **Die Gegenprobe zeigt,
dass die Schleife trennt:** dieselbe Extraktion über der Fassung **vor** der Behebung
(`git show c4a0c03^:docs/plan/planning/done/slice-098-feldliste-ist-ausdruck-des-traegers.md`,
Link-Ziele durch `grep -c 'harness/state'`) → **1**.

Ein leerer Bestand ist der billigste Zeitpunkt für einen fail-closed-Sensor: er wird grün geboren,
und sein erstes Rot ist ein echter Fund. Beide Zahlen wandern mit dem Bestand und sind **kein**
Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### Die Abwägung: drei Wege, einer gewählt

- **(A) Ein eigener hermetischer Prüfer in der Bauart von `make comment-claims` — gewählt, unter
  Vorbehalt von Frage A.** Er urteilt über den **Index** statt über das Arbeitsverzeichnis, braucht
  weder Netz noch Docker und ist damit dieselbe Klasse Sensor, die dieses Repo für
  Kommentar-Behauptungen schon fährt. Der Preis ist ein zweiter Prüfer neben dem Doku-Gate.
- **(B) Eine Option der Gate-Konfiguration.** Nicht verworfen, nur **ungemessen**: ob
  [`.d-check.yml`](../../../../.d-check.yml) einen Prüfbereich über getrackte Dateien kennt, sagt
  `d-check --print-config` — und das ist Frage A. Trägt sie, ist sie der schlankere Weg, weil sie
  keinen zweiten Sensor erzeugt.
- **(C) Den Doku-Gate über einen Export der getrackten Dateien fahren.** Verworfen: er verlegt die
  Kosten in jeden Lauf und ändert zugleich, was der Gate über **untrackte** Dateien sagt — eine
  Nebenwirkung, die niemand bestellt hat.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3). Wo kein Kommando einen Punkt rot färbt, steht
das dabei
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) gilt auch
für Plan-Texte).

- [ ] **(1) Ein Verweis auf ein von `git` ignoriertes Ziel färbt einen Gate-Lauf rot, unabhängig
      davon, ob das Ziel im Arbeitsverzeichnis liegt.**
      **Rot:** den mit `c4a0c03` getilgten Verweis wieder einsetzen, während der Zustands-Bereich
      **vorhanden** ist (`make host-bin` vorher gelaufen). Heute bleibt `make docs-check` in genau
      diesem Zustand grün (**fremdbelegt**,
      [Verifikation zu slice-106](../../../reviews/2026-08-27-slice-106-verify.md) §6.8); nach
      diesem Punkt muss der Lauf fallen, und die Meldung muss die Datei, die Zeile und das ignorierte
      Ziel nennen.
- [ ] **(2) Der Prüfer fällt bei leerem Prüfbereich.** Ein Lauf, der keine einzige Datei und kein
      einziges Link-Ziel findet, meldet das und endet rot — ein grüner Lauf über einer leeren Menge
      wäre die halluzinierte Zusage, gegen die
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
      steht.
      **Rot:** die Ziel-Liste künstlich leeren (Prüfbereichs-Muster auf ein nicht existierendes
      Verzeichnis zeigen lassen) — der Lauf muss fallen, nicht *„0 Befunde"* melden. Dieselbe Bauart
      führt der Mutations-Treiber schon (`grep -c 'FAELLT bei leerer Ziel-Liste' test/mutate-driver.bats`
      → **1**).
- [ ] **(3) Die Grenze steht ausgeschrieben: was der Prüfer weiterhin nicht sieht.** Mindestens zu
      benennen sind Verweise, die kein Markdown-Link sind (Inline-Code-Pfade, Prosa), und Ziele
      außerhalb des Repos.
      **Kein Kommando färbt diesen Punkt rot, und das ist der Befund, keine Vertagung.** Ob eine
      Grenzbeschreibung vollständig ist, ist ein Urteil über Prosa; ein Wächter über der
      **Anwesenheit** des Satzes belegte die Zeichenkette und nicht ihre Wahrheit. Diese Hälfte
      trägt das Review.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/` <!-- d-check:ignore (geplante Datei; ihr Name entsteht mit Frage A) --> | neu, **falls Weg (A)** | Träger von DoD (1) und (2): der hermetische Prüfer über den Link-Zielen des Index |
| [`Makefile`](../../../../Makefile) | update | ohne Ziel kein Gate; die Verdrahtung entscheidet zugleich, ob der Prüfer in `make gates` steht (Frage C) |
| [`.d-check.yml`](../../../../.d-check.yml) | update, **nur falls Weg (B) trägt** | dann entfällt der eigene Prüfer, und die Zeile hier ist die ganze Änderung |
| `test/` <!-- d-check:ignore (geplante Dateien) --> | neu | die Zähne zu DoD (1) und (2): beide Richtungen — ein ignoriertes Ziel fällt, ein normales nicht; die leere Menge fällt |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | der Haltbarkeits-Zahn. Nummern im Anschluss an die höchste **vergebene**, nicht an die Anzahl: `ls -1 test/mutations/*.sh \| sed -n 's#.*/\([0-9]*\)-.*#\1#p' \| sort -n \| tail -1` → **190** bei `ls -1 test/mutations/*.sh \| wc -l` → **183** (2026-08-27) |
| [`AGENTS.md`](../../../../AGENTS.md) und [`harness/README.md`](../../../../harness/README.md) | update, **soweit ein Ziel entsteht** | ein neues `make`-Ziel gehört in beide Sensor-Tabellen; ein Ziel, das nur im Makefile steht, ist ein Gate, das die Doku nicht kennt. **Abhängigkeit:** [slice-114](slice-114-jede-aussage-hat-einen-abschnitt.md) fasst dieselbe Datei an ihrer Gliederung an |
| [`docs/plan/planning/done/`](../done) | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich). Der eine reale Fall ist bereits behoben; der Rot-Beleg entsteht auf einer isolierten Kopie |
| [`internal/`](../../../../internal) und die emittierte Ebene | **unverändert** | ein Adopter hat andere ignorierte Pfade (Kopfzeile *Ebene*) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Kennt der gepinnte Doku-Gate einen Prüfbereich über getrackte Dateien?** | `d-check --print-config` über dem gepinnten Bild beantwortet es netzlos. Trägt es, ist Weg (B) eine Zeile in [`.d-check.yml`](../../../../.d-check.yml) und dieser Slice halb so groß; trägt es nicht, ist Weg (A) begründet statt gewählt |
| B | **Nur Markdown-Links oder auch Inline-Code-Pfade?** | Der reale Fall war ein Link. Der Doku-Gate prüft daneben Inline-Code-Pfade (`grep -m1 '^modules:' .d-check.yml` führt `codepaths`), und dieselbe Blindheit gilt dort. Ein Prüfer, der nur Links sieht, muss das **sagen** (DoD 3) |
| C | **Steht der Prüfer in `make gates` oder daneben?** | Er ist hermetisch und schnell, also spricht nichts gegen `gates`. Dagegen spricht die Ebene: er misst eine Eigenschaft des **Repos**, nicht des Produkts. Die Antwort entscheidet, ob eine Verschärfung ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)) oder ein Nicht-Gate-Verify entsteht |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit.** Der
Gegenstand liegt vollständig in diesem Repo und hängt an keiner Welle. Die Messungen aus §1 sind
gefahren.

**Eine Beobachtung zur Reihenfolge, kein Zuständiger.** Entsteht ein neues `make`-Ziel, berührt es
dieselben zwei Sensor-Tabellen, die [slice-114](slice-114-jede-aussage-hat-einen-abschnitt.md) an
ihrer Gliederung anfasst. Keiner ist Vorbedingung des anderen; wer zweiter läuft, misst gegen den
Stand, den der erste hinterlässt.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn Frage B ergibt, dass Inline-Code-Pfade eine eigene
  Extraktion brauchen, die mit der Link-Extraktion nichts teilt. Dann sind es zwei Slices.
- **`in-progress` → `open` (blockiert):** wenn Frage A ergibt, dass der Weg über die
  Gate-Konfiguration trägt, aber einen **Pin-Sprung** des Doku-Gates verlangt. Dann wartet dieser
  Slice auf den, der den Pin zieht — eine Pin-Bewegung ist ein eigener Gegenstand mit eigener
  Abwägung.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; das Gegenbeispiel zu DoD (1) ist **einmal rot
gesehen**, und zwar in dem Zustand, in dem der Gate heute grün bleibt; die leere Menge ist **einmal
rot gesehen**; Frage A, B und C sind mit ihrer Begründung beantwortet; entsteht ein Ziel, steht es in
[`AGENTS.md`](../../../../AGENTS.md) §4 und in
[`harness/README.md`](../../../../harness/README.md); Review konform (Modul 10); Verifikation
bestätigt (Modul 11); `make gates` grün; `git mv` nach `done/` als eigener Move-Commit;
Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel · neuer Sensor ·
benannte Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: dass der Bestand danach leer ist.** Er ist es heute
schon; was zählt, ist, dass die nächste Instanz auffällt.

## 6. Risiken und offene Punkte

- **Ein Prüfer über Link-Zielen kann falsch rot werden.** Anker, Query-Anteile, Ziele mit Leerzeichen
  und Verweise auf absichtlich abwesende Dateien sind Formen, die eine naive Extraktion trifft. Ein
  falsches Rot an einem korrekten Verweis kostet mehr als das stille Grün, das es ersetzt.
- **Die Ignorier-Menge ist maschinenabhängig.** `git check-ignore` liest neben
  [`.gitignore`](../../../../.gitignore) auch die globale Konfiguration des Nutzers. Ein Verweis
  könnte damit auf einer Maschine rot und auf einer anderen grün sein — die umgekehrte Richtung
  desselben Fehlers. Ob der Prüfer die globale Quelle ausschließt, gehört entschieden.
- **Zwei Prüfer über derselben Frage driften.** Bleibt der Doku-Gate zuständig für *„Ziel existiert"*
  und ein zweiter Sensor für *„Ziel ist ignoriert"*, muss ihre Arbeitsteilung an **einer** Stelle
  stehen. Zwei getrennt gepflegte Beschreibungen desselben Gegenstands sind die Drift-Konstruktion
  selbst.
- **Der Anlass ist behoben, der Sensor kommt danach.** Ein Slice, dessen Bestand leer ist, hat kein
  Gegenbeispiel im Baum. Der Rot-Beleg muss deshalb **hergestellt** werden, und er gehört auf eine
  isolierte Kopie — `docs/plan/planning/done/` bleibt unangetastet.
- **`make gates` deckt den Gegenstand heute nicht.** Genau das ist der Slice.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

**Vorgelagert — Sub-Area-Wahl prüfen:** Jede hier aufgeführte Sub-Area
muss das Inklusionskriterium erfüllen (drei Achsen, Schwelle ≥ 2; siehe
[`/kurs/de/grundlagen/konventionen.md` §Was ist eine Sub-Area?](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/konventionen.md#was-ist-eine-sub-area)).

### Sub-Area: Doku-Gate dieses Repos (`.d-check.yml`, `d-check.mk` und die Prüfer daneben)

Eine Sub-Area, kein zweiter Block: eine Gate-Konfiguration, ihr Fragment, ein möglicher zweiter
Prüfer und die zwei Tabellen, die beide beschreiben — ein Gegenstand, eine Frage. Die emittierte
Gate-Konfiguration liegt außerhalb (Kopfzeile *Ebene*).

- **Modus:** GF. Der Doku-Gate ist in diesem Repo entstanden und seither gegen den Kurs geführt; es
  gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch.
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  bindet die Schärfung,
  [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
  und
  [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)
  die Ausnahmen,
  [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) den
  Pin, und
  [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  benennt die Klasse *lokal grün, CI rot* ausdrücklich.
- **Phase-Reife:** Phase 5 (Betrieb). Der Gate läuft in jedem `make gates` und in jedem CI-Lauf;
  seine Module sind aktiviert und begründet (`grep -m1 '^modules:' .d-check.yml` führt sechs). Was
  fehlt, ist nicht Reife, sondern die richtige Menge.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für den Bestand (aus den Protokollen und dem Repo gelesen,
  §1), **offen für den Weg** — ob die Gate-Konfiguration die Eigenschaft selbst trägt, ist Frage A
  und gehört gemessen, bevor ein zweiter Prüfer entsteht.
- **Reconciliation-Aufwand:** gering bis mittel. Berührt sind eine Konfiguration oder ein kleines
  Skript, ein Makefile-Ziel, zwei Testdateien und zwei Sensor-Tabellen. Graduation-Trigger entfällt;
  die Sub-Area ist bereits GF.
