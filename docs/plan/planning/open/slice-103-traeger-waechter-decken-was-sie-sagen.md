# Slice slice-103: Die Träger-Wächter decken, was sie sagen — jede Assertion trägt ihren Fall oder ihre Grenze

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Durchgang über die Wächter **eines** Vertrags, einzeln
lieferbar. **(2) Gemeinsames Closure-Kriterium?** Nein — jedes wäre die Abschrift seiner eigenen
DoD. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: drei Assertions eines gebauten Wächter-Satzes
sind ohne Fall oder ohne wirksames Rot (§1). Er liefert **kein** Akzeptanzkriterium von
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) und gehört
deshalb nicht in [welle-12](../welle-12-erfassungsschicht-emittieren.md). Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Go-Wächter dieses Repos über der
Emissions-Mechanik und die Fälle in `test/mutations/`. Was hier geschärft wird, geht **nicht** ins
Ziel — [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 5(c) schließt einen ziel-seitigen Wächter über der Träger-Anwesenheit ausdrücklich aus.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel, deren Beleg hier an drei Stellen fehlt: wer
keinen Fall hat, gilt als unbewacht),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist — der Rang-Zeiger,
der heute auf einen Fall zeigt, der den Wächter grün lässt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Zusage, deren Fehlerzweig-Assertion über der Träger-Abwesenheit ohne Fall steht),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (*dieselbe Tool-Version →
derselbe Träger* — die Assertion, die das prüft, ist die zweite ohne Fall),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 1 und 5 sind der Vertrag, den diese Wächter messen; dieser Slice ändert an ihnen nichts,
er belegt sie),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Sensor-Mechanik, in der ein Fall zählt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie liefert).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Jede Assertion der Wächter über Träger, Wrapper und Hook-Eintrag ist entweder von einem
`test/mutations/`-Fall rot zu sehen oder mit Grund als unbewacht ausgesprochen — und kein Wächter
dieser Menge bleibt grün, weil er seine Erwartung aus der Funktion bezieht, die ihn rot färben
soll.**

### Die Ausgangslage: drei Stellen, gemessen statt geschätzt

Die Eigenschaft, über die gezählt wird: **eine Assertion in
[`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go), die eine Zusage aus
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1
oder 5 misst**. Drei davon tragen heute kein wirksames Rot aus `test/mutations/`:

| Stelle | Zusage | Stand |
|---|---|---|
| `:425` | ohne gelungene Ablage liegt **kein** Träger am Ablageort | kein Fall; Zähne belegt (`carrierDir` von `.harness/state/bin` auf `.harness/state/carrier` färbt rot) |
| `:353` | der abgelegte Träger **ist** das laufende Bild (sha256) | kein Fall; Zähne belegt (`io.Copy(out, src)` → `io.CopyN(out, src, 16)`) |
| `TestEnforce_WrapperSuchtDenAblageort` | der Emitter **legt** den Träger dorthin, wo der Wrapper ihn **sucht** | Fall vorhanden (`162`), aber der Kommentar nennt `159`, und unter `159` bleibt der Wächter grün |

**Der dritte ist die interessante Stelle, und er ist keine Nachlässigkeit.** Der Wächter holt die
Namen, die er im Wrapper sucht, aus `emit.CarrierPath()` — derselben Funktion, an die er koppeln
soll. Nimmt `159` der Ziel-Adresse die Endung, kollabieren beide Schleifendurchläufe auf denselben
Namen und die Prüfung wird trivial wahr. Eine Erwartung, die aus dem mutierten Gegenstand stammt,
kann ihn nicht messen; sie misst nur, dass der Code mit sich selbst übereinstimmt.

**Warum das nicht in `make mutate` auffällt.** Der Treiber verlangt, dass der im `# expect:`-Kopf
genannte Wächter fällt. `159` nennt `TestCarrierPath_NimmtDieEndungMit`, und der fällt — der Fall
ist zu Recht `ok`. Die falsche Zuschreibung steht im **Kommentar**, und
`make comment-claims` prüft die Existenz eines genannten Testnamens, nicht seine Aussage; sein
Prüfbereich nimmt `_test[.]go` zudem ganz aus
([slice-070](slice-070-comment-claims-pruefbereich.md) §1, dritte Verengung).

### Die Abgrenzung: was hier **nicht** entschieden wird

- **Die Kopf-Granularität von `test/mutations/`.** Ob ein Kopf die erwartete **Zusicherung** statt
  des **Wächter-Namens** trägt, ist der Gegenstand von
  [slice-069](slice-069-zahn-bindet-zusicherung.md) DoD (1). Dieser Slice legt Fälle in der heute
  geltenden Form an und migriert nichts.
- **Der Prüfbereich von `make comment-claims`.** Er gehört
  [slice-070](slice-070-comment-claims-pruefbereich.md). Dieser Slice repariert **einen**
  Kommentar, nicht den Sensor über Kommentaren.
- **Der ziel-seitige Wächter.** Ausgeschlossen durch
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(c);
  hier wird nichts emittiert.

## 2. Definition of Done

Zwei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Jede der drei Stellen aus §1 trägt einen Fall — oder eine ausgesprochene Grenze mit
      Grund.** Für `:353` ist der Eingriff bekannt und einzeilig
      (`io.Copy(out, src)` → `io.CopyN(out, src, 16)`: eine abgeschnittene und damit **andere**
      Datei an genau dem richtigen Ort, mit genau dem richtigen Modus). Für `:425` ist er **nicht**
      bekannt: jeder Eingriff, der den blockierten Ablageort umgeht, reißt
      `TestCarrierPath_NimmtDieEndungMit` mit, und ein Fall, der aus zwei Gründen rot wird, bindet
      keinen davon. **Findet der Lauf keinen sauberen Eingriff, ist die Grenze auszusprechen** —
      mit dem Grund, warum sie besteht, und an der Assertion selbst. Eine ausgesprochene Grenze ist
      hier ein vollwertiger Ausgang; ein Fall, der irgendetwas rot färbt, ist es nicht.
      **Rot:** `make mutate` — der neue Fall erscheint als `ok` mit seinem Wächter rot; entfernt
      man die Assertion, die er binden soll, meldet derselbe Lauf einen Befund.
- [ ] **(2) Kein Wächter dieser Menge leitet seine Erwartung aus der Funktion ab, die ihn rot
      färben soll.** `TestEnforce_WrapperSuchtDenAblageort` hält die Namen, die er im Wrapper
      sucht, gegen einen **festgeschriebenen** Satz statt gegen den Rückgabewert von
      `emit.CarrierPath()`; der Kommentar nennt danach den Fall, der ihn wirklich fällt.
      **Rot zu sehen ist:** `test/mutations/159` anwenden — heute bleibt der Wächter grün, danach
      muss er fallen. **Ohne dieses Rot ist die Kopplungs-Zusage eine Absicht**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      **Rot:** `make test` mit angewendetem `159`; dazu bleibt `162` bestehen und grün, damit die
      zweite Achse — Wrapper sucht **woanders** — nicht mit der ersten zusammenfällt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag. **Der Doku-Punkt
ist hier voraussichtlich leer:** berührt sind Testcode und Mutations-Fälle, kein emittiertes
Artefakt und keine Schnittstelle.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go) — die Namens-Erwartung von `TestEnforce_WrapperSuchtDenAblageort` und ihr Kommentar | update | DoD (2): eine Erwartung aus dem mutierten Gegenstand misst ihn nicht; der Rang-Zeiger muss danach auf den Fall zeigen, der wirklich fällt ([`AGENTS.md`](../../../../AGENTS.md) §3.7) |
| `test/mutations/` — ein Fall über der sha256-Identität, ein Fall oder eine ausgesprochene Grenze über der Träger-Abwesenheit im Fehlerzweig <!-- d-check:ignore (geplante Dateien) --> | neu | DoD (1): [`AGENTS.md`](../../../../AGENTS.md) §3.6 — wer keinen Fall hat, gilt als unbewacht |
| [`internal/emit/enforce.go`](../../../../internal/emit/enforce.go) | **unverändert** | der Vertrag stimmt; gemessen wird seine Bewachung, nicht sein Verhalten. Ändert der Lauf hier etwas, ist die Rückführung aus §4 fällig |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |
| `docs/plan/planning/done/` | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich) |

## 4. Trigger

**`open` → `next`:** [slice-096](../in-progress/slice-096-traeger-liegt-im-ziel.md) liegt in
`done/` — vorher existieren die Wächter nicht, über die dieser Slice misst. Die Bedingung ist ohne
Rückfrage prüfbar: die Plan-Datei liegt bei den geschlossenen Slices. **`next` → `in-progress`:**
WIP-Limit frei.

**Eine Reihenfolge-Empfehlung, keine Abhängigkeit.** Läuft dieser Slice **vor**
[slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md), baut jener seinen bedingten
Anwesenheits-Wächter auf einer Konstruktion, die ihre Erwartung nicht aus dem mutierten Gegenstand
zieht. Läuft er danach, ist dieselbe Konstruktion an zwei Stellen zu ziehen statt an einer. Keine
Reihenfolge bricht etwas; die zweite kostet einen Durchgang mehr.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn DoD (2) den Wächter nicht ohne
Umbau von `emit.CarrierPath()` erreichbar macht — dann trägt der Slice eine Produktionscode-Änderung
und ist ein anderer Schnitt. `in-progress` → `open`, wenn sich beim Bauen des Falls für `:425`
zeigt, dass die Assertion selbst falsch geschnitten ist — dann ist erst der Wächter zu entscheiden
und dann sein Fall.

## 5. Closure-Trigger

DoD (1) und (2) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` grün
einschließlich jedes neuen Falls, Review konform (Modul 10), Verifikation bestätigt (Modul 11),
`git mv` nach `done/` als eigener Move-Commit, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

**Ausdrücklich nicht Teil des Closure-Triggers: dass beide Stellen aus DoD (1) einen Fall
bekommen.** Eine ausgesprochene Grenze mit Grund ist der zweite zulässige Ausgang; ein Durchgang,
dessen Erfolgskriterium der Fall ist, kann nur noch Fälle bauen — auch dort, wo einer aus zwei
Gründen rot würde und deshalb keinen bindet.

## 6. Risiken und offene Punkte

- **Der Fall für `:425` ist der schwere, und er kann ausbleiben.** Der Fehlerzweig wird durch einen
  blockierten Ablageort **hergestellt**; jeder Eingriff, der die Blockade umgeht, verändert
  zugleich die Adresse, an der `TestCarrierPath_NimmtDieEndungMit` misst. Ein Fall, der aus zwei
  Gründen rot wird, ist genau die Klasse, die
  [slice-069](slice-069-zahn-bindet-zusicherung.md) §1 als gemessene Instanz führt.
- **DoD (2) kann die Kopplung schwächen statt schärfen.** Ein festgeschriebener Namens-Satz driftet
  von `emit.CarrierPath()` weg, wenn dort etwas anderes entschieden wird. Genau darum ist
  `TestCarrierPath_NimmtDieEndungMit` die zweite Hälfte: er hält die Funktion gegen ihre Tabelle,
  und der Wrapper-Wächter hält den Wrapper gegen den festgeschriebenen Satz. Fallen sie
  auseinander, fällt einer von beiden — das ist der Zweck, nicht der Fehler.
- **Der Slice kann seine eigene Lehre wiederholen.** Sein Ergebnis sind Mutations-Fälle, und ein
  Fall, dessen Kopf mehr behauptet, als sein Eingriff bewegt, ist der Befund, den er behandelt. Die
  Closure-Notiz gehört daraufhin gelesen, welche Wächter jeder neue Fall **wirklich** fällt —
  gemessen, nicht aus dem Kopf gelesen.
- **`make gates` sieht den Gegenstand nur zum Teil.** Der Doku-Gate prüft Kennungen und Pfade,
  `make comment-claims` prüft Existenz statt Aussage und lässt `_test[.]go` ganz aus. Was hier grün
  wird, ist der Mutations-Lauf; die Richtigkeit der Zuschreibung trägt das Review.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/` und
`test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
