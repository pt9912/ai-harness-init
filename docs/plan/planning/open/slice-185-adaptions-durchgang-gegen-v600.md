# Slice slice-185: Der Adaptions-Durchgang gegen `v6.0.0` — jeder Eintrag mit eigenem Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — **Mitglied.** Der Adaptions-Durchgang ist eine
der sieben Eigenschaften der Migrations-Prozedur, die diesen Sprung regiert (*„Der Review geht
durch die Adaptions-Liste, nicht nur durch den Diff"*), und beide Fassungen führen sie byte-gleich
([slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9, Stufe b). Präzedenz ist
[slice-157](../done/slice-157-adaptions-durchgang-v5180.md) als Mitglied von
[welle-14](../done/welle-14-re-baseline.md).

**Bezug:**
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 4, zweiter Punkt:
**jeder** Eintrag bekommt seinen Ausgang **einzeln, mit eigenem Beleg** — eine Pauschale ist
ausgeschlossen; dritter Punkt: der Durchgang erfasst ADRs **nicht**),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (der Adaptions-Block ist
der Gegenstand),
[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
(er liegt in der Verzeichnis-Form — eine Datei je Eintrag),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Sprung ist die
Bewegung des Pins, gegen den die Einträge messen).

**Berührte Spec-Stellen:** `—`. Der Slice fällt Konformitäts-Urteile über Adaptions-Einträge; er
schreibt keine Spec-Stelle.

**Verantwortlich:** Architect — [`AGENTS.md`](../../../../AGENTS.md) §3.8: der Adaptions-Block wird
vom Architect geschrieben, und jeder Ausgang ist eine Änderung an ihm.

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Jeder lebende Adaptions-Eintrag ist gegen `v6.0.0` geprüft und trägt einen der fünf Ausgänge der
Migrations-Prozedur, einzeln und mit eigenem Beleg.**

**Der Prüfbereich ist gemessen, nicht geschätzt.** 19 der 47 lebenden Einträge nennen in ihrem
Feld *Ersetzt-Baseline-Regel* oder im Rumpf eine der sieben Regelwerks-Dateien, die dieser Sprung
bewegt:

```sh
ls harness/conventions/MR-*.md | wc -l                                          # 47 lebende Eintraege
git grep -lE 'regelwerk/(README|grundlagen-begriffe|grundlagen-harness-dateien|grundlagen-traceability|modul-05-planning-harness|modul-06-roadmap|modul-10-review-harness)\.md' \
  -- 'harness/conventions/MR-*.md' | wc -l                                      # 19 im Pfad-Prüfbereich
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Beträge wandern mit jedem neuen Eintrag.

**Die 19 sind die Delta-Hälfte und decken den Durchgang nicht.** `BEO-013` (im
[Register](../observations.md)) misst genau diese Lücke: Ein Durchgang, der nach dem **Delta**
fragt, findet eine Deckung nicht, die ein Durchgang findet, der **jeden** Eintrag gegen den neuen
Volltext hält — und die Fehlerrichtung ist *bleibt gültig*, wo *gegenstandslos* richtig wäre. Die
Prozedur stellt ihre Frage darum pro Eintrag über die ganze Liste, nicht über den Diff; die 19
sagen, **wo zuerst zu lesen ist**, nicht, wo aufgehört wird.

**Was dieser Slice nicht tut.** Er fasst keine ADR an
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4, dritter Punkt:
Ergibt der Durchgang, dass eine begründende ADR überholt ist, ist die Antwort eine **Folge-ADR mit
`Supersedes`**, nie ein Edit). Und er entscheidet die regierende Fassung nicht — das ist
[slice-178](slice-178-regierende-fassung-des-sprungs-v600.md), der ihm vorausgeht.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Jeder lebende Eintrag trägt einen Ausgang, einzeln und mit Beleg.** Die fünf Ausgänge
      sind die der Prozedur (*gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist
      entfallen · widerspricht*) — eine geschlossene Menge, kein Freitext. **Inventar gegen
      Abdeckung**, nicht Stichprobe: die Zahl der mit Ausgang versehenen Einträge deckt
      `ls harness/conventions/MR-*.md | wc -l` am Ausgangsstand. War eine Adaption eine
      **Lockerung** und verschärft die neue Fassung, ist die Antwort ein **Carveout mit
      Auflösungs-Trigger**, keine stille Dauer-`MR` — der Satz steht in der Prozedur selbst.
- [ ] **Die Volltext-Hälfte ist gelaufen und als solche ausgewiesen** (`BEO-013`). Jeder Eintrag
      ist gegen den **neuen Volltext** seiner Zieldatei gehalten, nicht gegen das Delta; die 19
      Pfad-Treffer aus §1 sind die Lesereihenfolge und **nicht** die Bezugsmenge. Der Slice weist
      je Eintrag aus, welche der zwei Hälften den Ausgang trug — sonst ist nicht unterscheidbar,
      ob eine Deckung geprüft oder nur nicht getroffen wurde.
- [ ] **Rückbau ist ein neuer Eintrag, kein Edit.** Wird ein Eintrag gegenstandslos, wandert er
      nach `harness/conventions/done/` und behält Kopf und Zeiger
      ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf));
      seine Verzeichnis-Position **ist** sein Zustand
      ([`MR-046`](../../../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
      Der Move ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.3 vom Rewrite getrennt.
- [ ] `make gates` grün.
- [ ] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice. Ein öffentlicher
      Vertrag ist nicht berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben — neuer Eintrag oder ein weiterer Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions/`](../../../../harness/conventions/) | update | je Eintrag der Ausgang, in seiner eigenen Datei ([`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | die Index-Zeilen der bewegten Einträge |
| `harness/conventions/done/` | neu/update | was gegenstandslos wird, wandert dorthin — eigener Move-Commit |
| `docs/plan/carveouts/` | neu | **nur falls** ein Ausgang *Lockerung gegen Verschärfung* lautet |

**Alle Commits gehören derselben schreibenden Rolle** ([`AGENTS.md`](../../../../AGENTS.md) §3.8);
der Slice berührt keine Artefakte einer anderen und braucht darum keine Rollen-Trennung innerhalb
seiner Commits — wohl aber die Move-/Rewrite-Trennung aus §3.3.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`), zwei Bedingungen:

1. **[slice-182](../in-progress/slice-182-baum-tausch-v600-pins-ziehen.md) liegt in `done/`.** Vorher ist
   `v5.18.0` der Ist-Maßstab
   ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), und der
   Volltext, gegen den geprüft wird, liegt netzlos nicht vor.
2. **[slice-178](slice-178-regierende-fassung-des-sprungs-v600.md) liegt in `done/`, und die dort
   entstandene ADR steht auf `Accepted`.** Der Durchgang **fällt** Konformitäts-Urteile; ohne
   entschiedene normative Quelle wären sie auf eine Fassung gestützt, die niemand gewählt hat —
   genau die Lage, die [welle-15](../welle-15-re-baseline.md) §5 als *„blockiert jeden Durchgang,
   der eines fällt"* führt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn 47 Einzelurteile nicht in eine
  Review-Sitzung passen. Dann teilt der Schnitt entlang der **Zieldatei** des Feldes
  *Ersetzt-Baseline-Regel*, nicht entlang der Nummern — eine Nummern-Hälfte mischt Gegenstände,
  eine Datei-Hälfte nicht.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Ausgang eine **ADR** überholt. Die
  Folge-ADR mit `Supersedes` ist ein eigener Gegenstand und kein Zwischenschritt in diesem
  Durchgang.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; Inventar gegen Abdeckung geht auf (jeder lebende Eintrag hat genau einen der fünf
Ausgänge); Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Durchgang folgt dem Delta und meldet *bleibt gültig*, wo *gegenstandslos* richtig wäre**
  (`BEO-013`, 1×). Der Fehler ist am vorigen Sprung an **zwei** Einträgen gemessen worden. Er hat
  hier einen eigenen DoD-Punkt (2), weil ein Satz im Vorgehen ihn nachweislich nicht verhindert
  hat. — **Ausgang:** <…>
- **Eine Pauschale ersetzt 47 Einzelurteile.** [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
  Festlegung 4 schließt sie ausdrücklich aus, und die Prozedur stellt ihre Frage *„pro Eintrag"*.
  Der Druck dazu wächst mit der Zahl — deshalb steht die Rückführung in §4 vorab. —
  **Ausgang:** <…>
- **Die Selbstauskunft eines frisch geschriebenen Eintrags ist zu klein** (`BEO-009`, 10×,
  **geplant**). Das Nachbar-Repo hat an genau dieser Stelle einen Review-Befund: die Zahlen im
  begleitenden Adaptions-Dokument (cite-Direktiven, Tombstone-Fundstellen) waren beide zu niedrig
  (`unzip -p /Development/d-check/docs/plan/planning/done/welle-88/archiv.zip
  docs/plan/planning/done/slice-193-baseline-v600-bump.md`, §9). Jede Zahl in einem neuen Eintrag
  steht neben dem Kommando, das sie liefert
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)). —
  **Ausgang:** <…>

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
den Konventionsspeicher führt. Eine feinere Aufteilung entlang der Eintrags-Gegenstände wäre keine
Ausdifferenzierung: Die Einträge teilen einen Speicher und eine schreibende Rolle.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts (`BEO-004`). Vier Zeilen berühren diesen Slice mit ihrem Zähler-Stand, keine erreicht mit
ihm 3×:

- `BEO-013` (1×) — *ein Delta-Durchgang findet nicht, was ein Volltext-Durchgang findet*.
  **Dieser Slice ist ihr Ausgang**, mit eigenem DoD-Punkt statt eines Satzes im Vorgehen.
- `BEO-009` (10×, **geplant**) — *eine Zusage neben der geänderten Ableitung bleibt stehen*. Steht
  als Risiko in §6, hier in der Selbstauskunfts-Form.
- `BEO-019` (2×) — *Byte-Gleichheit an einem Abschnitt wird als Aussage über die Regel gelesen*.
  Bindet die Lesart der Prozedur: Sie ist byte-gleich, ihre Delegate sind es nicht
  ([slice-176](../done/slice-176-inventur-vor-dem-schnitt-v600.md) §9).
- `BEO-016` (1×) — *Slice-Pläne tragen ein Vielfaches der nötigen Zeilenzahl*. Bindet diesen Plan
  selbst; er ist deshalb knapp gehalten.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
