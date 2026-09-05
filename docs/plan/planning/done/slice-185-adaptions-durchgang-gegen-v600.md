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
[Register](../observations/README.md)) misst genau diese Lücke: Ein Durchgang, der nach dem **Delta**
fragt, findet eine Deckung nicht, die ein Durchgang findet, der **jeden** Eintrag gegen den neuen
Volltext hält — und die Fehlerrichtung ist *bleibt gültig*, wo *gegenstandslos* richtig wäre. Die
Prozedur stellt ihre Frage darum pro Eintrag über die ganze Liste, nicht über den Diff; die 19
sagen, **wo zuerst zu lesen ist**, nicht, wo aufgehört wird.

**Was dieser Slice nicht tut.** Er fasst keine ADR an
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4, dritter Punkt:
Ergibt der Durchgang, dass eine begründende ADR überholt ist, ist die Antwort eine **Folge-ADR mit
`Supersedes`**, nie ein Edit). Und er entscheidet die regierende Fassung nicht — das ist
[slice-178](../done/slice-178-regierende-fassung-des-sprungs-v600.md), der ihm vorausgeht.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Jeder lebende Eintrag trägt einen Ausgang, einzeln und mit Beleg.** Die fünf Ausgänge
      sind die der Prozedur (*gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist
      entfallen · widerspricht*) — eine geschlossene Menge, kein Freitext. **Inventar gegen
      Abdeckung**, nicht Stichprobe: die Zahl der mit Ausgang versehenen Einträge deckt
      `ls harness/conventions/MR-*.md | wc -l` am Ausgangsstand. War eine Adaption eine
      **Lockerung** und verschärft die neue Fassung, ist die Antwort ein **Carveout mit
      Auflösungs-Trigger**, keine stille Dauer-`MR` — der Satz steht in der Prozedur selbst.
      **Erfüllt:** §9, drei Tabellen, 47 Zeilen; die Lockerungs-Frage ist in §9 §Bilanz einzeln
      beantwortet.
- [x] **Die Volltext-Hälfte ist gelaufen und als solche ausgewiesen** (`BEO-013`). Jeder Eintrag
      ist gegen den **neuen Volltext** seiner Zieldatei gehalten, nicht gegen das Delta; die 19
      Pfad-Treffer aus §1 sind die Lesereihenfolge und **nicht** die Bezugsmenge. Der Slice weist
      je Eintrag aus, welche der zwei Hälften den Ausgang trug — sonst ist nicht unterscheidbar,
      ob eine Deckung geprüft oder nur nicht getroffen wurde. **Erfüllt:** §9 §Methode nennt die
      Hälften und zählt die Änderungs-Menge extensional aus — **sieben** Gegenstände, deren
      Partition über die größte Einzeldatei aufgeht; die zwei Tabellen sind nach Hälfte
      geschnitten (20 Delta, 27 Volltext).
- [x] **Rückbau ist ein neuer Eintrag, kein Edit.** Wird ein Eintrag gegenstandslos, wandert er
      nach `harness/conventions/done/` und behält Kopf und Zeiger
      ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf));
      seine Verzeichnis-Position **ist** sein Zustand
      ([`MR-046`](../../../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
      Der Move ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.3 vom Rewrite getrennt.
      **Erfüllt ohne Gegenstand:** kein Eintrag wird gegenstandslos (§9 §Bilanz), also wandert
      keiner und entsteht keiner. Ein Rückbau ohne Befund wäre der Fehler, nicht die Pflicht.
- [x] `make gates` grün.
- [x] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt diesen Slice. Ein öffentlicher
      Vertrag ist nicht berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — geschrieben im **Planner**-Kontext nach dem
      Review, mit dessen wiederkehrenden Klassen als dritter Quelle (Baseline-Regelwerk
      `modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln).
- [x] Beobachtungs-Register fortgeschrieben — **fünf** Belege über vier Verzeichnisse, eines davon
      neu (§7); keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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

**Ist-Stand nach dem Durchgang.** Die ersten drei Zeilen sind ohne Gegenstand geblieben: kein
Eintrag bewegt sich, also bekommt keine Index-Zeile eine Änderung und keine Datei wandert nach
`done/`. Bewegt hat sich in
[`harness/conventions.md`](../../../../harness/conventions.md) allein, was **kein** Ausgang
dieses Durchgangs ist — zwei Zustandsfelder, die neben einer geänderten Ableitung stehen
geblieben waren (§7). Sie liegen in einem eigenen Commit, der nur Architect-Artefakte berührt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`), zwei Bedingungen:

1. **[slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) liegt in `done/`.** Vorher ist
   `v5.18.0` der Ist-Maßstab
   ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), und der
   Volltext, gegen den geprüft wird, liegt netzlos nicht vor.
2. **[slice-178](../done/slice-178-regierende-fassung-des-sprungs-v600.md) liegt in `done/`, und die dort
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

**Keine der beiden ist gezogen, und die erste ist vor dem Beginn gemessen worden.** Die
Änderungs-Menge dieses Sprungs ist **schmaler** als die des vorigen, den
[slice-157](../done/slice-157-adaptions-durchgang-v5180.md) in einem Lauf getragen hat: **14**
Dateien mit Netto-Delta gegen **19** damals, davon **7** von **26** im `regelwerk/`-Baum
(Kommandos in §9 §Methode). Die zweite ist nicht eingetreten: kein Ausgang überholt eine ADR
(§9 §Bilanz).

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
  hat. — **Ausgang: weiter offen → Beobachtungs-Register**
  ([`delta-durchgang-uebersieht-deckung`](../observations/BEO-ALL/delta-durchgang-uebersieht-deckung/observation.md)).
  Die Auflage ist gefahren, und zwar in einer **geschlossenen** Form: §9 §Methode zählt die
  Änderungs-Menge des Sprungs extensional aus — **99** hinzugefügte Regel-Zeilen über **14**
  Dateien plus **eine** neue Vorlage — und ordnet sie sieben Gegenständen zu, von denen keiner
  eine der 47 Adaptionen berührt. Die Klasse ist damit **nicht** aufgetreten; ein ausgebliebenes
  Auftreten erhöht keinen Zähler, der Eintrag bleibt bei **1×**.
- **Eine Pauschale ersetzt 47 Einzelurteile.** [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
  Festlegung 4 schließt sie ausdrücklich aus, und die Prozedur stellt ihre Frage *„pro Eintrag"*.
  Der Druck dazu wächst mit der Zahl — deshalb steht die Rückführung in §4 vorab. —
  **Ausgang: entfallen.** Der Druck ist eingetreten (das Ergebnis ist über alle 47 dasselbe), die
  Pauschale nicht: jede der 47 Zeilen in §9 nennt die Pflicht, an der ihr Eintrag gemessen ist,
  und ein eigenes Kommando oder eine eigene gelesene Stelle. Acht Zeilen tragen einen Beleg, den
  ein `grep` nicht liefert (§9 §Methode), drei nennen einen Auflösungs-Trigger mit eigenem Ergebnis, und eine
  ([`MR-035`](../../../../harness/conventions.md#mr-035)) trägt einen **gefeuerten** Trigger — die Zeilen sind nicht austauschbar. Das Risiko
  kann in diesem Slice nicht mehr eintreten und wird darum gestrichen statt weitergezählt.
- **Die Selbstauskunft eines frisch geschriebenen Eintrags ist zu klein** (`BEO-009`, 10×,
  **geplant**). Das Nachbar-Repo hat an genau dieser Stelle einen Review-Befund: die Zahlen im
  begleitenden Adaptions-Dokument (cite-Direktiven, Tombstone-Fundstellen) waren beide zu niedrig
  (`unzip -p /Development/d-check/docs/plan/planning/done/welle-88/archiv.zip
  docs/plan/planning/done/slice-193-baseline-v600-bump.md`, §9). Jede Zahl in einem neuen Eintrag
  steht neben dem Kommando, das sie liefert
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)). —
  **Ausgang: eingetreten → in diesem Slice behoben, kein Folge-Slice.** Der Durchgang schreibt
  keinen neuen Eintrag (§9 §Bilanz), also gibt es keine Selbstauskunft eines neuen Eintrags; der
  Fund liegt eine Ebene daneben und im selben Register: zwei Zustandsfelder in
  [`harness/conventions.md`](../../../../harness/conventions.md) standen neben einer geänderten
  Ableitung — die Prozedur-Entscheidung dieses Sprungs als `Proposed` neben einer ADR-Datei auf
  `Accepted`, und eine Verzeichnis-Zahl neben einem Kommando, das sie nicht ausgibt. Beide sind
  in einem eigenen Architect-Commit nachgezogen und als Beleg im Register verbucht
  ([`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md),
  jetzt **13×**, Stand unverändert `geplant`).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die Volltext-Hälfte ließ sich zum ersten Mal **schließen** statt nur
  behaupten. Statt je Eintrag zu fragen *„habe ich genug gelesen?"* zählt der Durchgang die
  **Änderungs-Menge** aus — jede hinzugefügte Regel-Zeile des Sprungs, abzüglich des
  Herkunfts-Kommentars des vendored Baums — und ordnet sie sieben Gegenständen zu. Danach ist
  *„kein Gegenstand berührt eine Adaption"* eine Aussage über eine abgezählte Menge und nicht
  über einen Leseeindruck. Der Preis ist niedrig: **99** Zeilen über **14** Dateien.
- **Was ging anders als geplant:** Der Durchgang erwartete Bewegung — die zwei Vorgänger
  lieferten je einen Nicht-*bleibt-gültig*-Ausgang. Hier ist es **keiner**, und das liegt an der
  Gestalt des Sprungs: `v6.0.0` ändert **ein** Artefakt des Harness (das Beobachtungs-Register)
  und ergänzt drei Randregeln; von den 47 Adaptionen ist keine über dieses Artefakt geschrieben.
  Bewegt hat sich stattdessen eine Klasse **neben** dem Durchgang — zwei Zustandsfelder, die eine
  überholte Ableitung weitersagten (§6).
- **Was der Review beitrug (dritte Quelle nach Baseline-Regelwerk `modul-05-planning-harness.md`
  §Closure- und Lerneintrag-Regeln):**
  [`2026-09-05-slice-185-adaptions-durchgang-review.md`](../../../reviews/2026-09-05-slice-185-adaptions-durchgang-review.md)
  — **blockierend, 3 MEDIUM, kein HIGH**; das Sachurteil *47× bleibt gültig* ist unabhängig gegen
  den `v6.0.0`-Volltext nachgeprüft und trägt. Die drei trafen die **Beleg-Kette**, nicht das
  Verdikt, und sind hier aufgelöst: die grep-blinde Zitat-Menge war halb so groß beziffert, wie
  die eigenen Tabellen sie belegen (§9 §Methode, jetzt acht über sechs Dateien) · die Partition
  der 99 Zeilen ließ eine Zeile aus (§9, jetzt sieben Gegenstände statt sechs) · die
  Closure-Schritte liefen im Architect-Kontext statt beim Planner. **LOW-2** ist mitbehoben (die
  Bijektion nennt das Lifecycle-Verzeichnis als Glob), **INFO-2** in derselben Zeile benannt.
  **INFO-1** (die Auszähl-Schleife überspringt die eine entfallene Baseline-Datei) und **INFO-3**
  (zwei Einträge zitieren einen `v3.5.2`-Pfad ohne Ziel) sind gemessen folgenlos für die 47
  Ausgänge und bleiben ohne Aktion; INFO-3 gehört ohnehin
  [slice-091](../open/slice-091-vendored-baum-ohne-anspruch.md)/[slice-092](../open/slice-092-traeger-inventur.md).
- **Was diese Closure nicht deckt — zwei offene Übergaben, benannt statt still:**
  **(1) An den Architect:** §Baseline von
  [`harness/conventions.md`](../../../../harness/conventions.md) spricht
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Bindungskraft zu
  (*„stehen in"*, *„bindet"*), während jene ADR auf `Proposed` steht
  (`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0031-*.md`) — Review LOW-1. Die Datei gehört dem
  Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Planner-Lauf fasst sie nicht an.
  **(2) Die Verifier-Kante ist nicht gelaufen.** Baseline-Regelwerk `modul-08-agentenrollen.md`
  §Rollen-Sequenz für einen Slice führt `I→R→Vf→P`; hier folgt `P` unmittelbar auf `R`. Was dieser
  Lauf selbst gefahren hat, steht unten unter *Verifikation*; ein DoD-Urteil aus getrenntem
  Kontext ersetzt es nicht.
- **Steering-Loop-Eintrag:** Regel geschärft: *Eine extensionale Auszählung ist erst geschlossen,
  wenn ihre Partition die ausgezählte Menge ausschöpft **und** ihre Fundzahlen gegen die eigene
  Aufzählung gehalten sind.* Der erste Teil ist der ursprüngliche Lerneintrag — die Frage *„regelt
  die neue Fassung das jetzt selbst?"* hat genau so viele mögliche Quellen, wie der Sprung
  Regel-Zeilen hinzufügt, und die sind zählbar. Der zweite Teil ist die Verschärfung, die dieser
  Slice bezahlt hat: **beide** Auszählungen des Durchgangs waren zu klein — die Partition um eine
  Zeile (sechs statt sieben Gegenstände), die Zitat-Fundmenge um vier (vier statt acht) —, und
  beide Male stand die Zahl **ohne** ihr Kommando und ohne Handzählungs-Ansage da, also ohne die
  Stelle, an der ein Leser sie hätte nachzählen können. Eine Auszählung, die sich selbst als
  Schluss-Argument benutzt, trägt ihre Ableitung mit; sonst ist sie ein Leseeindruck mit Ziffer.
  Auslöser:
  [`delta-durchgang-uebersieht-deckung`](../observations/BEO-ALL/delta-durchgang-uebersieht-deckung/observation.md)
  (1×) und
  [`extensionale-zahl-unterschreitet-die-eigene-fundmenge`](../observations/BEO-ALL/extensionale-zahl-unterschreitet-die-eigene-fundmenge/observation.md)
  (1×). *Gezählt, nicht verkörpert:* keiner der beiden erreicht die Schwelle, also entfällt das
  Feld `liegt in`.
- **Beobachtungs-Register:** fünf Belege, davon zwei aus dem Review dieses Slice; **ein** neues
  Verzeichnis. Jeder Stand ist die Zahl der Dateien unter `evidence/`
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`) — keine Erwartungswerte,
  sie wandern mit dem Register:
  [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
  **2×** · [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  **13×** (§6) ·
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  **3×** — **zwei** Belege in diesem Zug, weil zwei Vorgänge betroffen sind: `slice-178`, dessen
  Fund aus dem nachträglichen Review nie gebucht wurde, und `slice-185` selbst. Damit ist die
  Schwelle erreicht; der Ausgang steht dem **Lese-Schritt** zu und der liegt bei der Closure von
  [welle-15](../welle-15-re-baseline.md), nicht hier ·
  [`extensionale-zahl-unterschreitet-die-eigene-fundmenge`](../observations/BEO-ALL/extensionale-zahl-unterschreitet-die-eigene-fundmenge/observation.md)
  **1×**, neu angelegt: Die Nachbarklasse
  [`zahl-neben-nie-gefahrenem-kommando`](../observations/BEO-ALL/zahl-neben-nie-gefahrenem-kommando/observation.md)
  trifft nicht — dort steht ein Kommando neben der Zahl und liefert sie nicht, hier steht gar
  keines, und der Beleg ist der eigene Fließtext ·
  [`delta-durchgang-uebersieht-deckung`](../observations/BEO-ALL/delta-durchgang-uebersieht-deckung/observation.md)
  bleibt bei **1×** — die Klasse ist nicht aufgetreten.
- **Folge-Slices:** keine geschnitten. **Ein Posten geht ohne Kennung weiter**, und er gehört
  einem anderen Slice: die Tag-Nennungen im Eintrags-Bestand
  (`git grep -c 'v5.12.0' -- 'harness/conventions/' | awk -F: '{s+=$NF} END{print s}` → **87**
  Zeilen in **41** Dateien; keine Erwartungswerte) sind kein Freshness-Audit-Ausgang, sondern die
  Klasse aus
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum),
  und ihr Träger sind [slice-091](../open/slice-091-vendored-baum-ohne-anspruch.md) und
  [slice-092](../open/slice-092-traeger-inventur.md)
  ([welle-15](../welle-15-re-baseline.md) §5). Eine Kennung hier behauptete eine Datei, die es
  nicht gibt.
- **Risiken aus §6:** je genau ein Ausgang — *weiter offen → Register*, *entfallen* (mit
  Begründung), *eingetreten → im Slice behoben*. Siehe §6.
- **Verifikation, und was sie deckt:** `make gates` in diesem Lauf gefahren, **EXIT 0**. Dazu
  wiederholt: die Bijektion aus §Bilanz (leere Ausgabe, Exit 0, **47** Ausgangs-Zeilen, keine
  doppelt), die acht `grep -c -F` der grep-blinden Zitate (alle **0**, alle acht Sätze wörtlich am
  Zielstand), die Auszählung der **26** `modul-06`-Zeilen gegen die Partition 1 + 2 + 23, und die
  drei Bestands-Kommandos zur Schluss-Aussage (Register **3**, Modus-Deklaration **2**, Carveout
  **4**, Frist **1**). **Was das nicht deckt:** das DoD-Urteil aus getrenntem Kontext — die
  Verifier-Kante ist nicht gelaufen (oben, offene Übergabe 2).
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

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist vollständig
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

**Die Sichtung greift dem Ergebnis nicht vor.** Sie fragt, welche offene Beobachtung diesen Slice
**vorab** berührt; welche er **erzeugt**, beantwortet erst die Closure. Zwei tun das und stehen
darum in §7 statt hier —
[`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md),
mit diesem Slice an der Schwelle, und die neu angelegte
[`extensionale-zahl-unterschreitet-die-eigene-fundmenge`](../observations/BEO-ALL/extensionale-zahl-unterschreitet-die-eigene-fundmenge/observation.md).

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

## 9. Durchgangs-Protokoll je Eintrag

### Bezugsmenge

```sh
ls harness/conventions/MR-*.md      | wc -l   # 47 aktiv — die Bezugsmenge der DoD
ls harness/conventions/done/*.md    | wc -l   #  4 aufgelöst (Verzeichnis-Position)
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen wandern mit dem Block. **Kein Eintrag entsteht in diesem Durchgang**,
die 47 sind also dieselben vor und nach ihm. **Die vier aufgelösten sind mitgeprüft**, weil eine
Verzeichnis-Position kein Beleg dafür ist, dass der Zielstand ihren Gegenstand nicht wiederbelebt.

### Methode — zwei Hälften, und die zweite ist diesmal geschlossen

Die fünf Ausgänge stehen in `modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline
(Schritt 2): **gegenstandslos · bleibt gültig · teilweise überholt · Bezug entfallen ·
widerspricht**. Die regierende Fassung ist die Ziel-Fassung
([`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md), `Accepted`).

**Erste Hälfte — Delta.** Gelesen wird der **Volltext** des Abschnitts, den das Pflichtfeld
`Ersetzt-Baseline-Regel` nennt, im Zielstand `v6.0.0` — nicht die Diff-Zeilen. Führt das Feld
`keine` (Fork), steht dieselbe Frage ohne Adresse: regelt der Zielstand den Gegenstand jetzt
selbst?

**Zweite Hälfte — Volltext, und sie läuft als Auszählung statt als Leseeindruck.** Ein Eintrag,
dessen Zieldatei sich nicht bewegt hat, kann trotzdem gegenstandslos werden — dann nämlich, wenn
der Zielstand seinen Gegenstand **an einer anderen Stelle** neu regelt. Diese Möglichkeit ist
abzählbar: sie hat genau so viele Kandidaten, wie der Sprung Regel-Zeilen hinzufügt. Der Baum des
abgelösten Standes steht netzlos in `git`, der neue liegt im Arbeitsbaum:

```sh
ALT=$(mktemp -d); git archive d75cd8c^ .harness/baseline/v5.18.0 | tar -x -C "$ALT"
A="$ALT/.harness/baseline/v5.18.0"; B=".harness/baseline/v6.0.0"
for f in $(cd "$A" && find . -name '*.md' | sort); do
  [ -f "$B/$f" ] || continue
  roh=$(diff "$A/$f" "$B/$f" | grep -c '^[<>]')
  q=$(  diff "$A/$f" "$B/$f" | grep -c '^[<>].*<!-- Quelle:')
  [ $((roh-q)) -gt 0 ] && printf '%s\n' "${f#./}"
done | wc -l                                  # 14 Dateien mit Netto-Delta, davon 7 in regelwerk/
for f in $(cd "$A" && find . -name '*.md'); do
  [ -f "$B/$f" ] || continue
  diff "$A/$f" "$B/$f" | grep '^>' | grep -v '<!-- Quelle:' | grep -vE '^> *$'
done | wc -l                                  # 99 hinzugefügte Regel-Zeilen
ls -1 "$B/regelwerk"/*.md | wc -l             # 26 Regelwerks-Dateien insgesamt
```

**Keine Erwartungswerte** — alle drei wandern mit dem Tag-Paar. `d75cd8c` ist der Commit, der den
vendored Baum getauscht hat; **netto** heißt: ohne den Herkunfts-Kommentar `<!-- Quelle: … -->`,
dessen Ziel zwischen zwei Vendorings die Form wechselt, ohne dass eine Regel sich ändert
([`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) §Was das Messinstrument
mitzählt).

**Die 99 Zeilen und die eine neue Datei sind gelesen und tragen sieben Gegenstände:**

| # | Gegenstand | Wo |
|---|---|---|
| 1 | Das **Beobachtungs-Register** läuft in der Verzeichnis-Form; die Kennung **ist** der Pfad `BEO-<KUERZEL>/<slug>`, der Zähler wird aus den Evidence-Dateien abgeleitet statt geführt | `modul-06-roadmap.md`, `modul-05-planning-harness.md`, `grundlagen-begriffe.md`, `grundlagen-harness-dateien.md` §Verzeichniskonvention, fünf Vorlagen, neue Vorlage `observation.template.md` |
| 2 | Die **Kürzel-Spalte** der Modus-Deklaration ist **nicht mehr bedingt** — jedes Repo führt seit (1) mindestens eine Kennungsklasse mit Segment | `grundlagen-harness-dateien.md` §Konventionsspeicher |
| 3 | Die **Archivierung der Zeitdokumente** hat im wellenlosen Betrieb einen Träger: die Slice-Closure, nach den Paarungen, `done/slice-<NNN>-archiv.zip` | `modul-05-planning-harness.md`, `modul-06-roadmap.md`, `modul-10-review-harness.md` |
| 4 | Ein **Fluss-Diagramm** des Steering Loops, additiv am Ende der Datei — 38 der 99 Zeilen | `grundlagen-traceability.md` |
| 5 | Die **Release-URL** der zwei Vorlagen zeigt auf `releases/latest/` statt auf einen Tag | `templates/AGENTS.template.md`, `templates/harness/conventions.template.md` |
| 6 | Die **Stand-Zeile** des Regelwerk-Index und zwei tag-gescopte Kurs-Links werden relativ | `regelwerk/README.md` |
| 7 | Die **Carveout-Frist** misst in Wellen und hat im wellenlosen Betrieb keinen Ersatz-Träger — der Zielstand stellt das als **benannte Lücke** frei und begründet ausdrücklich **keine** Pflicht (*„das bleibt eine benannte Lücke, keine Pflicht, und ein Repo bleibt ohne sie konform"*) | `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, **eine** Zeile |

Die Partition ist über die größte Einzeldatei geprüft und geht auf: die **26** `modul-06`-Zeilen
zerfallen in **1** (Gegenstand 7, die erste hinzugefügte Zeile) + **2** (Gegenstand 3) + **23**
(Gegenstand 1) — Handzählung über die Ausgabe des Kommandos aus §Methode, auf `modul-06` verengt;
kein Kommando gibt die Aufteilung selbst aus
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1).

**Keiner der sieben berührt eine der 47 Adaptionen** — und das ist keine Themen-Aussage, sondern
über den Bestand gemessen: nur **drei** Einträge nennen das Beobachtungs-Register überhaupt, und
alle drei zitieren dort eine Beobachtung als Beleg ihrer eigenen Begründung, statt eine Regel über
das Register zu setzen
(`grep -l -i 'beobachtungs-register\|BEO-' harness/conventions/MR-*.md` → [`MR-041`](../../../../harness/conventions.md#mr-041), [`MR-047`](../../../../harness/conventions.md#mr-047),
[`MR-048`](../../../../harness/conventions.md#mr-048)). Die **zwei**, die die Modus-Deklaration nennen, tun es als Block-Grenze eines Kommandos
bzw. als Fundort eines Falls, nicht als Gegenstand
(`grep -l 'Modus-Deklaration\|Kürzel-Spalte' harness/conventions/MR-*.md` → [`MR-019`](../../../../harness/conventions.md#mr-019), [`MR-028`](../../../../harness/conventions.md#mr-028)).
Die **vier**, die einen Carveout nennen, tun es über die Template-Ablage bzw. die
Append-only-Form einer Instanz, keiner über eine **Frist**
(`grep -li 'carveout' harness/conventions/MR-*.md` → [`MR-008`](../../../../harness/conventions.md#mr-008), [`MR-029`](../../../../harness/conventions.md#mr-029), [`MR-040`](../../../../harness/conventions.md#mr-040), [`MR-041`](../../../../harness/conventions.md#mr-041);
`grep -li 'frist' harness/conventions/MR-*.md` trifft allein [`MR-025`](../../../../harness/conventions.md#mr-025), und dort geht es um die
Befristung eines Adaptions-Eintrags, nicht um die eines Carveouts).
Keine Erwartungswerte; alle drei Listen wandern mit dem Block.

**Ein `grep` auf ein Zitat ist kein Volltext-Durchgang** — in diesem Durchgang **achtmal** belegt,
über **sechs** Dateien. Acht zitierte Baseline-Sätze geben als `grep -c -F` über das volle Zitat
eine **0** und stehen trotzdem wörtlich am Zielstand; ein Zeilenumbruch oder ein Inline-Markup
trennt das Muster. Es sind die Zeilen von [`MR-007`](../../../../harness/conventions.md#mr-007)
(`modul-02-harness-bootstrap.md`), [`MR-009`](../../../../harness/conventions.md#mr-009),
[`MR-048`](../../../../harness/conventions.md#mr-048),
[`MR-049`](../../../../harness/conventions.md#mr-049) (alle drei `modul-14-docker-harness.md`),
[`MR-014`](../../../../harness/conventions.md#mr-014) (`grundlagen-durchsetzungsschicht.md`),
[`MR-015`](../../../../harness/conventions.md#mr-015) (`grundlagen-source-precedence.md`),
[`MR-019`](../../../../harness/conventions.md#mr-019) (`grundlagen-referenz-richtung.md`) und
[`MR-032`](../../../../harness/conventions.md#mr-032) (`grundlagen-harness-dateien.md`). Gelesen
statt gegrept steht jeder von ihnen da; ein Durchgang, der die **0** für sich nähme, verbuchte
achtmal *Bezug entfallen* statt *bleibt gültig*.

**Beide Zahlen sind Handzählungen über die Beleg-Spalte der drei Tabellen unten**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1: liefert kein Kommando eine Zahl, steht das dabei). Mechanisch abzulesen ist eine
**Untergrenze** — sieben der acht Zeilen nennen den Umbruch ausdrücklich, die achte
([`MR-014`](../../../../harness/conventions.md#mr-014)) nennt statt seiner die Zeilennummer:

```sh
grep -hoE '^\| \[MR-[0-9]{3}\][^|]*\| bleibt gültig \| [^|]*' \
  docs/plan/planning/*/slice-185-adaptions-durchgang-gegen-v600.md \
  | grep -cE 'bricht nach|bricht zwischen|umgebrochen nach'   # 7 — Untergrenze, nicht die Fundmenge
```

Die Klasse liegt als
[`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md)
im Register. **Ihr Beleg zu diesem Slice nennt vier statt acht** und ist nach
Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register *unveränderlich ab Merge* —
er bleibt, wie er steht. Die Diskrepanz ist selbst ein Fund und hat einen eigenen Registereintrag
([`extensionale-zahl-unterschreitet-die-eigene-fundmenge`](../observations/BEO-ALL/extensionale-zahl-unterschreitet-die-eigene-fundmenge/observation.md));
gültig ist die Zahl an dieser Stelle, weil sie hier neben ihrer Ableitung steht.

**Wie die Spalte *Hälfte* zu lesen ist.** *Delta* heißt: der Eintrag nennt eine Datei, die dieser
Sprung bewegt, und der Ausgang steht auf dem gelesenen neuen Volltext ihres Abschnitts. *Volltext*
heißt: die genannte Datei trägt netto **0** geänderte Zeilen, und der Ausgang steht auf der
Wiederholung der Messung des Eintrags **plus** der Auszählung oben. Das Kriterium ist mechanisch:

```sh
git grep -lE 'regelwerk/(README|grundlagen-begriffe|grundlagen-harness-dateien|grundlagen-traceability|modul-05-planning-harness|modul-06-roadmap|modul-10-review-harness)\.md' \
  -- 'harness/conventions/MR-*.md' | wc -l                                                # 19
git grep -lE 'templates/(AGENTS\.template\.md|README\.md|harness/conventions\.template\.md|docs/plan/planning/(README|reconciliation|slice|welle-results)\.template\.md)' \
  -- 'harness/conventions/MR-*.md' | wc -l                                                # 7
```

Die Vereinigung beider Listen zählt **20** Einträge (Handzählung über die zwei Ausgaben; kein
Kommando gibt genau sie aus,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1); die übrigen **27** stehen allein auf der Volltext-Hälfte.

### Ausgänge — Delta-Hälfte (20 Einträge)

| MR | Ausgang | Beleg am Zielstand `v6.0.0` |
|---|---|---|
| [MR-000](../../../../harness/conventions.md#mr-000) | bleibt gültig | §Konventionsspeicher führt den Block unverändert (`grep -c 'Index\*\* der Abweichungen ggü. Baseline' …/grundlagen-harness-dateien.md` → **1**), das Vertrags-Präfix bleibt frei (`grep -c '<PREFIX>-FA-<NN>' …/grundlagen-source-precedence.md` → **2**). Die 8 hinzugefügten Zeilen der Datei liegen in §Verzeichniskonvention (Register-Pfad) und in der Kürzel-Prosa — beide außerhalb der Setzungen dieses Eintrags |
| [MR-005](../../../../harness/conventions.md#mr-005) | bleibt gültig | Die Abweichungs-Aussage ist mit [MR-047](../../../../harness/conventions.md#mr-047) fort (Kopf-Marke); der Ort fehlt weiter: `grep -rc 'tools/harness' …/regelwerk/ …/templates/` gibt **keine Nicht-Null-Zeile**, und §Verzeichniskonvention nennt für ausführbare Harness-Tools keinen — ihre eine geänderte Zeile ist der Register-Pfad |
| [MR-008](../../../../harness/conventions.md#mr-008) | bleibt gültig | Die Adaptions-Hälfte ist mit [MR-041](../../../../harness/conventions.md#mr-041) zurückgebaut; der tragende Satz steht (`grep -c 'keine Blank-Kopie im Repo' …/modul-02-harness-bootstrap.md` → **1**). Die eine geänderte Zeile in `templates/README.md` benennt die Register-Vorlage, nicht die fünf wiederkehrenden Ausfüll-Templates; die fortbindende Hälfte ist die [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Abgrenzung auf der emittierten Ebene |
| [MR-009](../../../../harness/conventions.md#mr-009) | bleibt gültig | Die Digest-Regel steht — **gelesen, nicht gegrept**: `grep -n 'Digest-Zeile' …/modul-14-docker-harness.md` → Zeile **29**, der Satz bricht nach *bewusster* um; §Gate-Fragment `d-check.mk` existiert weiter (`grep -c 'Gate-Fragment' …/modul-02-harness-bootstrap.md` → **1**); das Startgerüst kennt die zwei `codepaths`-Ventil-Achsen weiterhin nicht — `grep -n -e exempt-paths -e ignore-refs …/templates/.d-check.yml` trifft **eine** Zeile, und die liegt im auskommentierten `versions:`-Block |
| [MR-020](../../../../harness/conventions.md#mr-020) | bleibt gültig | Der ersetzte Satz steht wörtlich (`grep -c 'Einträge werden nie überschrieben' …/grundlagen-harness-dateien.md` → **1**); die Eintrags-Vorlage ist zwischen den Tags byte-gleich und führt kein `Status`-Feld (`grep -c '^- \*\*Status:\*\*' …/templates/harness/conventions/MR-NNN-titel.template.md` → **0**) |
| [MR-025](../../../../harness/conventions.md#mr-025) | bleibt gültig | `grundlagen-begriffe.md` ändert genau **eine** Zeile, und das ist die Glossarzeile der Beobachtungs-Kennung; die Klasse bleibt dem Begriff nach die **Harness-Lüge** (`grep -c 'Harness-Lüge' …/grundlagen-begriffe.md` → **1**), und eine Regel über den Beleg einer Zahl in Prosa führt der Zielstand weiter nicht (`grep -rl 'Erwartungswert' …/regelwerk/` ist leer, Exit 1) |
| [MR-026](../../../../harness/conventions.md#mr-026) | bleibt gültig | Der Zielstand vergibt für Hard Rules weiter keine Nummer: `grep -rn 'AGENTS.md §3' …/regelwerk/` → **0** Zeilen; die eine Nennung bleibt das Form-Beispiel des Herkunfts-Ankers (`grep -c '### 3.3 <Hard Rule>' …/grundlagen-traceability.md` → **1**), und die 38 hinzugefügten Zeilen jener Datei liegen sämtlich im neuen Fluss-Abschnitt. **Auflösungs-Trigger unverändert:** `comm -12 <(grep -E '^### 3\.' AGENTS.md \| sort) <(grep -E '^### 3\.' …/templates/AGENTS.template.md \| sort) \| wc -l` → **2** (§3.3 und §3.7); der zweite ist der mit [MR-031](../../../../harness/conventions.md#mr-031) verbuchte, und die eine geänderte Zeile der Vorlage ist ihre Release-URL |
| [MR-028](../../../../harness/conventions.md#mr-028) | bleibt gültig | Der ersetzte Satz steht wörtlich (`grep -c 'trägt das Muster bereits über sein Feld' …/grundlagen-traceability.md` → **1**), die Form-Vorgabe ebenso (`grep -c 'ein Feld, kein Konstrukt' …` → **1**). Der neue Fluss-Abschnitt beschreibt den Steering-Loop-Weg und trifft das Feld `Wirksamkeits-Anlass` an keiner Stelle |
| [MR-029](../../../../harness/conventions.md#mr-029) | bleibt gültig | Alle drei zitierten Sätze stehen: `grep -c 'die Senkung ist' …/modul-07-carveouts.md` → **1**, `grep -c 'Formfehler und wird zuerst repariert' …/modul-02-harness-bootstrap.md` → **1**, `grep -c 'Rückbau ist ein neuer Eintrag, kein Edit' …` → **1** |
| [MR-031](../../../../harness/conventions.md#mr-031) | bleibt gültig | Die Deckung hält am neuen Tag, alle vier Messungen wiederholt: `grep -c '^### 3\.7 Ein Kommentar beschreibt, was da ist$' …/templates/AGENTS.template.md` → **1**, `grep -c '^### Was ein Kommentar trägt — Code, Konfiguration, Skripte$' …/grundlagen-harness-dateien.md` → **1**, `grep -c 'nennt sie als \*\*ein\*\* auflösbares Feld' …` → **1**, `grep -c 'seit slice-<NNN>' …/grundlagen-traceability.md` → **3** |
| [MR-032](../../../../harness/conventions.md#mr-032) | bleibt gültig | Der ersetzte Satz steht — **gelesen**: `grep -n 'Status-Feld' …/grundlagen-harness-dateien.md` → Zeile **243**, umgebrochen nach *kein*. Sein Auflösungs-Trigger ist mit [MR-045](../../../../harness/conventions.md#mr-045) eingetreten und von [MR-046](../../../../harness/conventions.md#mr-046) Verdikt 1 für die Teil-Ablösung als **nicht** eingetreten verbucht; der Zielstand ändert daran nichts, die Verzeichnis-Position bleibt binär |
| [MR-034](../../../../harness/conventions.md#mr-034) | bleibt gültig | Sein Auslöser ist ein Werkzeug-Stand, kein Baseline-Stand; die Eintrags-Vorlage ist byte-gleich und kennt zu `Löst auf` weiterhin nur den Baseline-Stand als Auslöser (`grep -c 'Ausgelöst durch Baseline-Stand' …/templates/harness/conventions/MR-NNN-titel.template.md` → **2**, beide Baseline) |
| [MR-035](../../../../harness/conventions.md#mr-035) | bleibt gültig | Die drei Messungen am neuen Tag: `grep -c 'ohne das ganze Regelwerk im Kontext zu halten' …/regelwerk/README.md` → **1**, `grep -rl 'claude/rules' .harness/baseline/v6.0.0/ \| wc -l` → **0**, `grep -c 'Per-Lauf-Relevantes gehört verkörpert, nicht extern' …/modul-02-harness-bootstrap.md` → **1** — der Mechanismus bleibt der Baseline unbekannt. **Der einzige gefeuerte Trigger dieses Durchgangs, und er ist beantwortet:** der Tag-Bump hat die vier Symlinks **nachgezogen** statt sie zu entfernen (`git ls-files -s .claude/rules/ \| awk '$1=="120000"' \| wc -l` → **4**, alle Ziele unter `.harness/baseline/v6.0.0/`), die Menge ist unverändert — Setzung 2 verlangt einen neuen Eintrag für *einen Eintrag mehr oder weniger*, und es ist keiner. Bewegt haben sich allein die Beträge von Setzung 1 (`ls .claude/rules/*.md \| wc -l` → **4** von **26**, Zeichen-Anteil **19,7 %**); ihr Nachzug ist die [MR-040](../../../../harness/conventions.md#mr-040)-Klasse und liegt bei [slice-091](../open/slice-091-vendored-baum-ohne-anspruch.md)/[slice-092](../open/slice-092-traeger-inventur.md) |
| [MR-037](../../../../harness/conventions.md#mr-037) | bleibt gültig | Der Abschnitt, den der Eintrag nennt, trägt den zweitgrößten Netto-Anteil des Sprungs (**26** hinzugefügte Zeilen) und ist gelesen: hinzu kommen die Freistellung der Carveout-Frist als *benannte Lücke*, ein Absatz über den Ort der Archivierung und eine Tabellenzeile *Zeitdokumente archivieren*. Alle drei zitierten Sätze stehen unverändert (`grep -c 'Wellenlose Arbeit erscheint nicht in der Roadmap' …/modul-06-roadmap.md` → **1**, `grep -c 'auch eine neue Fähigkeit kann ein einzelner Slice sein' …` → **1**, `grep -c 'die mehr beobachtet, als die DoDs ihrer Slices schon' …` → **1**). Der Zielstand **erweitert** den Träger-Katalog des wellenlosen Betriebs, statt den Auslöser-Test zu ändern |
| [MR-038](../../../../harness/conventions.md#mr-038) | bleibt gültig | Die ersetzte Freshness-Audit-Eigenschaft steht wörtlich (`grep -c 'den Baseline-Stand nennt, der den Trigger gefeuert hat' …/modul-02-harness-bootstrap.md` → **1**); ihr Auflösungs-Trigger — eine erneute Änderung dieser Eigenschaft — ist nicht eingetreten: die Datei trägt netto **0** geänderte Zeilen |
| [MR-039](../../../../harness/conventions.md#mr-039) | bleibt gültig | Beide zitierten Stellen stehen (`grep -c 'Einträge werden nie überschrieben' …/grundlagen-harness-dateien.md` → **1**, `grep -c 'Index\*\* der Abweichungen ggü. Baseline' …` → **1**). Sein Auflösungs-Trigger ist mit [MR-045](../../../../harness/conventions.md#mr-045) eingetreten und von [MR-046](../../../../harness/conventions.md#mr-046) Verdikt 2 einzeln abgearbeitet |
| [MR-043](../../../../harness/conventions.md#mr-043) | bleibt gültig | Der ersetzte Satz steht (§Herkunfts-Anker, `grep -c 'trägt das Muster bereits über sein Feld' …/grundlagen-traceability.md` → **1**); sein Trigger übernimmt die Bedingung von [MR-032](../../../../harness/conventions.md#mr-032) und ist nach [MR-046](../../../../harness/conventions.md#mr-046) Verdikt 3 nicht eingetreten |
| [MR-045](../../../../harness/conventions.md#mr-045) | bleibt gültig | Beide tragenden Sätze stehen am neuen Tag: `grep -c 'Der \*\*Default\*\* ist die Verzeichnis-Form' …/grundlagen-harness-dateien.md` → **1** und `grep -c 'trägt die Index-Zeile den alten Überschriften-Slug \*\*zusätzlich\*\*' …` → **1** |
| [MR-046](../../../../harness/conventions.md#mr-046) | bleibt gültig | Die ersetzte Zelle steht (Zeile **243**, siehe [MR-032](../../../../harness/conventions.md#mr-032)), und die Ziel-Form trägt weiterhin keinen dritten Zustand: `grep -c 'teilweise' …/templates/harness/conventions/MR-NNN-titel.template.md` → **0**, die Vorlage ist byte-gleich. Der Auflösungs-Trigger ist nicht eingetreten |
| [MR-047](../../../../harness/conventions.md#mr-047) | bleibt gültig | Der Eintrag misst gegen `v5.18.0` und trägt am neuen Tag unverändert: `grep -rc 'tools/harness' …/regelwerk/ …/templates/` gibt **keine Nicht-Null-Zeile**, §Das vollständige Artefakt-Set nennt weiter keinen Ort, §Verzeichniskonvention ebenso — ihre eine geänderte Zeile ist der Register-Pfad. Sein Auflösungs-Trigger (die Baseline nennt wieder einen Ort) ist nicht eingetreten |

### Ausgänge — Volltext-Hälfte (27 Einträge)

Für alle 27 gilt zusätzlich zur eigenen Messung: die genannte Zieldatei trägt zwischen den Tags
netto **0** geänderte Zeilen (Kommando in §Methode), und keiner der sieben Gegenstände des Sprungs
regelt ihren Gegenstand an anderer Stelle neu.

| MR | Ausgang | Beleg am Zielstand `v6.0.0` |
|---|---|---|
| [MR-001](../../../../harness/conventions.md#mr-001) | bleibt gültig | §Referenz-Richtung (SDP) trägt die Sektions-Ausnahme (`grep -c 'ohne ausgenommene Sektion' …/grundlagen-referenz-richtung.md` → **1**) und die Reifestufen-Klausel (`grep -c 'anker-validierende Stufe ist eine Reifestufe darüber, kein Startwert' …` → **1**) |
| [MR-002](../../../../harness/conventions.md#mr-002) | bleibt gültig | §Das vollständige Artefakt-Set führt am Zielstand weiter **fünf** Posten, und alle fünf liegen vor — `.claude/settings.json` · `.claude/hooks/*.sh` · `.claude/commands/*.md` · `harness/tools/working-tree-hash.sh` · `CLAUDE.md`. §Guard-Härtung regelt den Denylist-Inhalt ohne Umfangs-Festschreibung; der Eintrag protokolliert weiter eine Übernahme, keine Abweichung |
| [MR-003](../../../../harness/conventions.md#mr-003) | bleibt gültig | Beide zitierten Sätze wörtlich: `grep -c 'Nachweis über Inhalt, nicht Diff' …/grundlagen-durchsetzungsschicht.md` → **1**; `grep -c 'rekursiv\*\* derselben Prüfung unterworfen' …/modul-13-quality-gates.md` → **1**; die Restlücke steht als §Grenzen — ehrlich benannt |
| [MR-004](../../../../harness/conventions.md#mr-004) | bleibt gültig | Die Lücke, über die die Injektor-Mechanik fort gilt, ist unverändert offen: `grep -rc 'SessionStart' …/regelwerk/` gibt **keine Nicht-Null-Zeile** — der Zielstand schreibt vor, dass das Regelwerk nicht ganz im Kontext steht, nicht, **wodurch** ein Teil hineinkommt |
| [MR-006](../../../../harness/conventions.md#mr-006) | bleibt gültig | §Anmerkung zur vendored Baseline verlangt unverändert das Nachschlagen pro Entscheidung (`grep -c 'ohne das ganze Regelwerk im Kontext zu halten' …/modul-02-harness-bootstrap.md` → **1**) — genau das, was der Eintrag zurückbaut |
| [MR-007](../../../../harness/conventions.md#mr-007) | bleibt gültig | Die ersetzte Koexistenz-Setzung steht (`grep -c 'Das alte Verzeichnis fällt' …/modul-02-harness-bootstrap.md` → **1**, der Satz bricht nach *fällt* um); Setzung 4 (ein Tag zur Zeit) tritt weiter an ihre Stelle und ist gehalten (`ls -1 .harness/baseline/` → **eine** Zeile) |
| [MR-010](../../../../harness/conventions.md#mr-010) | bleibt gültig | Beide Abweichungs-Punkte stehen unverändert: der Zielstand schreibt weiter `-include` und *„Das Tool pflegt die Recipe-Form"* (`grep -c 'Das Tool pflegt die Recipe-Form' …/modul-02-harness-bootstrap.md` → **1**); der Absatz §Und das Fragment mountet erlaubt die Mount-Form *„solange das Werkzeug nur liest"* (`grep -c` → **1**) und fordert nichts nach |
| [MR-011](../../../../harness/conventions.md#mr-011) | bleibt gültig | Die Messung des Eintrags trägt unverändert: `grep -rl -e check-lines -e citations …/regelwerk/` ist **leer** (Exit 1); die Deckung des Verzichts steht weiter als *„Vorhanden ≠ behauptet"* (`grep -c` → **1**) |
| [MR-012](../../../../harness/conventions.md#mr-012) | bleibt gültig | §Freshness-Audit führt `sources` weiter namentlich und als *„Netz-Operation, außerhalb der Gates"* (`grep -c` → **1**) |
| [MR-013](../../../../harness/conventions.md#mr-013) | bleibt gültig | Dieselbe Stelle, dieselbe Grenze: `grep -c 'ersetzt die Release-Listen-Prüfung nicht' …/modul-02-harness-bootstrap.md` → **1**; zur **Ablage** des Hashes sagt der Zielstand weiterhin nichts — die Zwei-Pin-Kopplung füllt weiter eine Lücke |
| [MR-014](../../../../harness/conventions.md#mr-014) | bleibt gültig | Der Satz, den der Eintrag einlöst, steht — **gelesen**: `grep -n 'CI das Netz' …/grundlagen-durchsetzungsschicht.md` → Zeile **72**; einen CI-Aufbau schreibt der Zielstand weiter nicht vor |
| [MR-015](../../../../harness/conventions.md#mr-015) | bleibt gültig | §Spec-Stratifizierung trägt den Träger-Satz wörtlich — **gelesen, nicht gegrept**: der Satz bricht zwischen *Der* und *Träger* um, `grep -c 'Der Träger ist dann der' …/grundlagen-source-precedence.md` gibt **0**, `grep -c 'Träger ist dann der \*\*Commit\*\*' …` → **1**. Der zitierte Grundsatz ebenso (`grep -c 'bewusst kein Harness-Konstrukt' …` → **1**); der Rückbau ist mit [MR-036](../../../../harness/conventions.md#mr-036)/[MR-042](../../../../harness/conventions.md#mr-042) verbucht, der Cutoff-Absatz bindet fort |
| [MR-017](../../../../harness/conventions.md#mr-017) | bleibt gültig | Die Ebenen-Begründung trägt weiter, und die Messung ist **vollständig** statt stichprobenhaft: `grep -rn 'Adopter' …/regelwerk/ \| wc -l` → **6** Zeilen in drei Dateien, alle gelesen — Template-Schichtung, Reviewer-Skill-HIGH-Regel, Root-`README.md` und AGENTS-Vorlage eines Adopter-Repos, Baseline-Ablage; **kein** Emissions-Fall. fail-closed steht unverändert als Design-Eigenschaft 1 (`grep -c 'Ein Gate, das im Zweifel passieren lässt, ist keiner' …/grundlagen-durchsetzungsschicht.md` → **1**) |
| [MR-019](../../../../harness/conventions.md#mr-019) | bleibt gültig | §Spec-Straten verlangt die Deklaration weiter nur für den anderen Fall — **gelesen**: `grep -n 'Ein Repo \*kann\* mit zwei Straten' …/grundlagen-referenz-richtung.md` → Zeile **290**, der Satz bricht nach *von* um — und hält *„Alle drei Straten sind obligatorisch"* (`grep -c` → **1**); eine Pflichtgliederung für die Spezifikation gibt es weiter nicht (`grep -c '^### Ziel-Form: Spezifikation' …/modul-03-spec.md` → **1**) |
| [MR-021](../../../../harness/conventions.md#mr-021) | bleibt gültig | Die ersetzte Drei-Spalten-Form steht wörtlich (`grep -c 'liste jeden Attribut-Namen' …/modul-15-observability.md` → **1**); die vierte Spalte `Sensor` tritt weiter an ihre Stelle |
| [MR-024](../../../../harness/conventions.md#mr-024) | bleibt gültig | Die Messung des Eintrags trägt unverändert: `grep -rl structure …/regelwerk/` ist **leer** (Exit 1), das Modul bleibt verfügbar statt aktiviert (`grep -c structure .d-check.yml` → **0**) |
| [MR-027](../../../../harness/conventions.md#mr-027) | bleibt gültig | Der Gegenstand gehört weiter dem Werkzeug: `grep -rn 'd-check:ignore' …/regelwerk/ \| wc -l` → **1**, und die eine Zeile ist die Regel, dass gesetzte Marker das Adoptieren eines Templates überleben — über **Form** und **Lage** der Wirkung sagt sie nichts |
| [MR-030](../../../../harness/conventions.md#mr-030) | bleibt gültig | Beide Messungen tragen am Zielstand: `grep -c 'participant I as Implementer' …/modul-08-agentenrollen.md` → **1**, `grep -rl 'implementer' …/regelwerk/ \| wc -l` → **0** |
| [MR-033](../../../../harness/conventions.md#mr-033) | bleibt gültig | Der Zielstand führt weiter keine Regel darüber, dass eine Baseline-Aussage ihren Mess-Tag nennt; der Eintrag ist eine Sachstands-Setzung ohne Baseline-Gegenstück. Dass der Sprung keine hinzufügt, ist die Auszählung aus §Methode: **99** hinzugefügte Regel-Zeilen, sieben Gegenstände, keiner davon eine Beleg-Regel |
| [MR-036](../../../../harness/conventions.md#mr-036) | bleibt gültig | Der Absatz, dessen Deckung der Eintrag feststellt, steht am Zielstand (`grep -c 'Fallen Auftraggeber- und Entwickler-Rolle zusammen' …/grundlagen-source-precedence.md` → **1**) samt dem Träger-Satz (siehe [MR-015](../../../../harness/conventions.md#mr-015)); der Rückbau bleibt richtig |
| [MR-040](../../../../harness/conventions.md#mr-040) | bleibt gültig | Die Lücke, die der Eintrag füllt, ist unverändert offen: der Freshness-Audit bindet die **Form** einer Instanz (`grep -c 'nicht rückwirkend umgeschrieben' …/modul-02-harness-bootstrap.md` → **1**) und führt keinen Ausgang für eine **Aussage über den vendored Baum**. Der Trigger — eine Änderung des Audits an dieser Stelle — ist nicht eingetreten |
| [MR-041](../../../../harness/conventions.md#mr-041) | bleibt gültig | Die Deckung, die den Rückbau trug, steht wörtlich (`grep -c 'keine Blank-Kopie im Repo' …/modul-02-harness-bootstrap.md` → **1**); §Anmerkung zum Instanziierungs-Zeitpunkt ist unverändert |
| [MR-042](../../../../harness/conventions.md#mr-042) | bleibt gültig | Beide tragenden Sätze stehen: `grep -c 'auslösenden Slice in der Historie nennt' …/modul-03-spec.md` → **1** und `grep -c 'Historie-Zeile ist ein Protokoll und wird nicht' …` → **1**; die Verweis-Spalten-Aussage ebenso (`grep -c 'die Verweis-Spalte nennt diesen Vorgang statt eines' …/grundlagen-source-precedence.md` → **1**) |
| [MR-044](../../../../harness/conventions.md#mr-044) | bleibt gültig | Beide Regeln, die in derselben Tabelle zusammentreffen, stehen unverändert: `grep -c 'liste jeden Attribut-Namen' …/modul-15-observability.md` → **1** und die `ID`-Spalte der Ziel-Form (`grep -c '\| ID ' …/templates/spec/spezifikation.template.md` → **4**, Datei byte-gleich). Der Trigger — das Observability-Modul nimmt die `ID`-Spalte auf — ist nicht eingetreten |
| [MR-048](../../../../harness/conventions.md#mr-048) | bleibt gültig | Beide Quellen stehen: §Zwei Formen des Reproduzierbarkeits-Ankers — **gelesen**, `grep -n 'Rezept-Form' …/modul-14-docker-harness.md` → Zeilen **65** und **72**, der zitierte Satz bricht nach *die* um — und die Digest-Regel (`grep -c 'nicht per Tag' …` → **1**). Sein Auflösungs-Trigger hängt an einem Change Request auf [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) und ist nicht eingetreten |
| [MR-049](../../../../harness/conventions.md#mr-049) | bleibt gültig | Der ersetzte Satz steht (`grep -c 'Die Quellen wandern beim Build ins Image' …/modul-14-docker-harness.md` → **1**), der `:ro`-Preis ebenso — **gelesen**: `grep -n 'Umleitung alles' …` → Zeile **85**, der Satz bricht nach *alles* um. Die Freistellung der tool-generierten Mount-Form (§Und das Fragment mountet) ist unverändert |
| [MR-050](../../../../harness/conventions.md#mr-050) | bleibt gültig | Griff 1 der Tabelle *Zwei Wege, die Prüfung auszulösen* steht (`grep -c 'no-cache-filter' …/modul-14-docker-harness.md` → **1**); sein Auflösungs-Trigger hängt an einer Eingabe außerhalb des Build-Kontexts (`grep -c '^require' go.mod` → **0**) und ist nicht eingetreten |

### Ausgänge — die vier aufgelösten Einträge in `conventions/done/`

Sie sind **mitgeprüft**, nicht übersprungen: eine Verzeichnis-Position belegt nicht, dass der
Zielstand den Gegenstand nicht wiederbelebt. Alle vier tragen nach
[`MR-020`](../../../../harness/conventions.md#mr-020) nur Kopf und Zeiger und damit **keine
Adaption**, an der ein Ausgang ansetzen könnte — der Ausgang liegt bei dem Eintrag, der sie
aufhob, und jeder der drei steht oben auf *bleibt gültig*.

| MR | aufgehoben durch | Prüfung |
|---|---|---|
| [MR-016](../../../../harness/conventions.md#mr-016) | [MR-037](../../../../harness/conventions.md#mr-037) | die drei `modul-06`-Sätze stehen, und der neue Archivierungs-Absatz derselben Sektion **erweitert** den wellenlosen Betrieb, statt ihn zurückzunehmen — der Rückbau bleibt richtig |
| [MR-018](../../../../harness/conventions.md#mr-018) | [MR-021](../../../../harness/conventions.md#mr-021) | die Drei-Spalten-Form steht — der Zielort im Technik-Stratum bleibt |
| [MR-022](../../../../harness/conventions.md#mr-022) | [MR-031](../../../../harness/conventions.md#mr-031) | die AGENTS-Vorlage führt §3.7 weiter — der Vorgriff bleibt eingeholt |
| [MR-023](../../../../harness/conventions.md#mr-023) | [MR-031](../../../../harness/conventions.md#mr-031) | dieselbe Messung |

### Bilanz

| Ausgang | Zahl | Einträge |
|---|---|---|
| bleibt gültig | 47 | alle aktiven |
| gegenstandslos · teilweise überholt · Bezug entfallen · widerspricht | 0 | — |
| ohne Gegenstand (aufgelöst, `conventions/done/`) | 4 | [MR-016](../../../../harness/conventions.md#mr-016) · [MR-018](../../../../harness/conventions.md#mr-018) · [MR-022](../../../../harness/conventions.md#mr-022) · [MR-023](../../../../harness/conventions.md#mr-023) |

**Handzählung über die Spalte `Ausgang` der drei Tabellen oben; kein Kommando gibt genau sie aus**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). Die Bezugsmenge ist die des Kommandos oben — jeder ihrer Einträge steht in genau einer
Zeile, keiner ohne Ausgang.

**Dass keiner ohne Ausgang steht, ist nicht abgezählt, sondern als Bijektion geprüft** — die
Bezugsmenge gegen die Kennungen mit Ausgangs-Zeile, in beide Richtungen; die Ausgabe ist leer:

```sh
diff <(ls harness/conventions/MR-*.md | xargs -n1 basename | cut -d- -f1-2 | sort) \
     <(grep -hoE '^\| \[MR-[0-9]{3}\]\([^)]*\) \| (bleibt gültig|gegenstandslos|teilweise überholt|Bezug entfallen|widerspricht)' \
         docs/plan/planning/*/slice-185-adaptions-durchgang-gegen-v600.md \
       | grep -oE 'MR-[0-9]{3}' | sort -u)
```

Ein Eintrag ohne Zeile und eine Zeile ohne Eintrag sind darin derselbe Defekt. **Der zweite
Operand nennt das Lifecycle-Verzeichnis als Glob statt fest** — ein Kommando, das nach dem
`git mv` einen Defekt meldete, wo keiner ist, misst den Ort statt den Gegenstand
([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); `make slice-mv` zieht
Verweise nach, keine Kommando-Argumente. Die Prüfung deckt **Existenz**, nicht Eindeutigkeit —
`sort -u` kollabiert zwei Zeilen derselben Kennung; dass es heute keine gibt, sagt
`… | sort | uniq -c | awk '$1>1'` → leere Ausgabe bei **47** Zeilen.

**Die Lockerungs-Frage ist einzeln beantwortet, nicht übergangen.** Die Prozedur verlangt bei
*Lockerung gegen Verschärfung* ein Carveout statt einer stillen Dauer-`MR`. Zwei Einträge dieses
Blocks sind ausdrücklich als Lockerung bzw. Senkung geführt:
[`MR-020`](../../../../harness/conventions.md#mr-020) (die tragende
[ADR-0014](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) nennt sie *„eine Lockerung der
Baseline-Disziplin"*) und Punkt 3 des Zensus in
[`MR-029`](../../../../harness/conventions.md#mr-029) (eine Senkung nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5, autorisiert durch
[ADR-0017](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)). An beiden Stellen
**verschärft der Zielstand nicht**: `grep -c 'Einträge werden nie überschrieben'
…/grundlagen-harness-dateien.md` → **1** und `grep -c 'Rückbau ist ein neuer Eintrag, kein Edit'
…/modul-02-harness-bootstrap.md` → **1**, beide Dateien an diesen Zeilen unverändert. Ein Carveout
ist damit nicht fällig, und `docs/plan/carveouts/` bleibt unberührt.

**Warum ein Durchgang ohne einen einzigen Rückbau kein übersprungener ist.** Die zwei Vorgänger
lieferten je einen Nicht-*bleibt-gültig*-Ausgang, dieser keinen — das ist ein Ergebnis und keine
Auslassung, und es hängt an der **Gestalt** des Sprungs, nicht an seiner Größe. `v6.0.0` schreibt
**ein** Harness-Artefakt um (das Beobachtungs-Register) und ergänzt drei Randregeln; von den 47
Adaptionen ist keine über dieses Artefakt geschrieben. Der Beleg dafür ist die Auszählung in
§Methode, nicht das Ausbleiben eines Treffers: Hätte der Sprung eine Adaption eingeholt, stünde
die Regel unter den 99 Zeilen. **Was der Sprung dem Repo abverlangt hat, lag außerhalb dieses
Registers** — Register-Umzug, Kennungs-Nachzug, Anweisungssätze; das sind die sieben übrigen
Mitglieder von [welle-15](../welle-15-re-baseline.md).

### Was dieser Durchgang **nicht** trägt

Die Nennungen abgelöster Tags in den Eintrags-Dateien sind **kein** Freshness-Audit-Ausgang,
sondern die Klasse aus [`MR-040`](../../../../harness/conventions.md#mr-040) (drei Ausgänge für
eine Präsens-Aussage über den vendored Baum):

```sh
git grep -c 'v5\.12\.0' -- 'harness/conventions/' | awk -F: '{s+=$NF} END{print s}'   # 87 Zeilen
git grep -l 'v5\.12\.0' -- 'harness/conventions/' | wc -l                             # 41 Dateien
```

**Keine Erwartungswerte** — beide wandern mit dem Block. Ihr Träger sind
[slice-091](../open/slice-091-vendored-baum-ohne-anspruch.md) und
[slice-092](../open/slice-092-traeger-inventur.md)
([welle-15](../welle-15-re-baseline.md) §5). Sie hier mitzunehmen wäre ein vierter Liefer-Punkt an
einem Slice mit drei (Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice). Der
Durchgang **prüft** diese Nennungen, wo sie eine Messung tragen — jede Zeile der drei Tabellen
oben ist gegen den Zielstand neu gefahren —, und **ändert** keine.

Ebenfalls nicht getragen: die Zitate der abgeschafften Beobachtungs-Nummer in §1, §6 und §8 dieses
Plans. Sie sind der Gegenstand von
[slice-186](../in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md); jede in diesem
Durchgang **neu** geschriebene Nennung steht in der Pfad-Form und löst auf.
