# Slice slice-176: Inventur vor dem Schnitt — der Form- und Regel-Diff `v5.18.0` → `v6.0.0`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-15](../welle-15-re-baseline.md) — der erste Slice der Welle; er liefert die
Grundlage, auf der ihre übrigen Mitglieder geschnitten werden.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Baseline
ist auf einen Tag gepinnt — der Diff ist die Vorarbeit zum Tausch dieses Pins),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (ihr erster
Re-Evaluierungs-Trigger verlangt die Messung unten; ihre Festlegung 2 nennt den Ort der
Zielstand-Buchung),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 3 stellt das
Kriterium, das jene Messung anwendet),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der vendored Baum ist der Gegenstand).

**Berührte Spec-Stellen:** `—`. Der Slice katalogisiert und schneidet; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Planner (pt9912). Der Liefergegenstand ist ein Katalog im Plan und
eine Menge neuer Slice-Dateien in `open/` — beides Planner-Artefakte (Baseline-Regelwerk
`modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse).

**Autor:** Planner. **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der vollständige Form- und Regel-Diff `v5.18.0` → `v6.0.0` liegt als Katalog vor, jede geänderte
Position hat eine Zuordnung, und daraus steht fest, welche Slices
[welle-15](../welle-15-re-baseline.md) braucht — bevor der Rest geschnitten wird.**

Der Slice ist die Antwort auf `BEO-010` (Register, 2×): der Umfang der
Folge-Arbeit wird **gemessen, nicht geschätzt**. Er ist zugleich die Probe auf `BEO-011` (1×) —
dieser Sprung wird zeitnah statt gesammelt adoptiert, und ob die Kostenreihe damit flacher bleibt,
misst die Closure der Welle.

**Er entscheidet nichts über den Ist-Zustand.** Ein Katalog stellt fest, was sich geändert hat; ob
eine Änderung dieses Repo bindet, ist eine Konformitäts-Frage, und für die bleibt bis zum Tausch
`v5.18.0` maßgeblich ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
Festlegung 2). Der Katalog hängt darum nicht an den offenen Fragen aus §6.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Diff-Katalog** in §9 dieses Plans: je geänderter Datei die inhaltlichen Positionen als
      Stichwort, je Position eine von drei Zuordnungen — *bindet dieses Repo* · *bindet die
      emittierte Ebene* · *ohne Gegenstand hier*. Vollständigkeit gemessen statt behauptet: die
      Datei-Liste des Katalogs deckt `git diff --name-status v5.18.0 v6.0.0 -- lab/regelwerk
      lab/templates` am lokalen Kurs-Klon, und die **neuen** (`A`) wie die **entfallenen** (`D`)
      Dateien sind als solche ausgewiesen.
- [x] **Folge-Slice-Liste**: jede Position mit einer der ersten zwei Zuordnungen trägt entweder
      einen Folge-Slice (Datei in `open/`, Gegenstand benannt) oder die Begründung, warum keiner
      nötig ist. Keine Position ohne Ausgang.
- [x] **Messung nach
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
      Re-Evaluierungs-Trigger 1**, zweistufig, weil jener Trigger beides verlangt: (a) Führt die
      gepinnte Fassung `v5.18.0` die Migrations-Prozedur
      ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3)? (b) Führt
      sie sie **byte-gleich**, tragen die Abschnitte, in die sie delegiert, ein Delta? Ergebnis je
      Stufe mit Beleg im Plan, und daraus der Fall. Die **Wahl** wird nicht hier entschieden — sie
      geht als Übergabe an den Architect (§6).
- [ ] `make gates` grün.
- [x] Doku-Update: [welle-15](../welle-15-re-baseline.md) §4 führt **jeden** neu geschnittenen
      Slice — als Tabellenzeile, wenn er Mitglied ist, sonst benannt mit dem Grund seines
      Ausschlusses (§6 jener Datei, `BEO-018`); die Roadmap trägt ihren Drift-Eintrag. Ein
      öffentlicher Vertrag ist nicht berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| dieser Plan, §9 | update | trägt den Katalog und die Messung |
| `docs/plan/planning/open/` | neu | je Folge-Slice eine Datei, per `cp` aus der Vorlage |
| [welle-15](../welle-15-re-baseline.md) §4 | update | die Slice-Tabelle der Welle bekommt ihre übrigen Zeilen |

Der Katalog wird am lokalen Kurs-Klon `/Development/KI/ai-harness-course` gemessen (`git diff`
zwischen den zwei Tags). Der vendored Baum unter `.harness/baseline/` wird in diesem Slice **nicht**
angefasst — der Tausch ist ein eigener Slice, den der Katalog benennt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [welle-15](../welle-15-re-baseline.md) ist eröffnet — ihre
Plan-Datei liegt flach in `docs/plan/planning/`, und die Roadmap führt sie unter *Offene Wellen*.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Zuordnung einer Position selbst
  Messarbeit am Bestand dieses Repos verlangt, die über einen Lauf hinausgeht — dann wird der
  Katalog nach Achsen geteilt (Regelwerk-Hälfte / Template-Hälfte), und die Zuordnung der zweiten
  Achse wird ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn der lokale Kurs-Klon den Tag `v6.0.0` nicht
  führt und das Delta netzlos nicht messbar ist. Ein Ersatz über die Release-Assets ist ein anderer
  Gegenstand und kein Zwischenschritt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; jede benannte Folge-Slice-Datei liegt im Planning-Lifecycle; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Katalog wird zur Beweisführung und wächst über seinen Zweck hinaus** (`BEO-016` im
  Register). Ein Katalog ist eine Liste mit Zuordnung, kein Nachweis je
  Position; die Nachweis-Pflicht steht beim tragenden Slice. — **Ausgang: eingetreten**, und die
  Positions-Tabelle ist nicht die Ursache: sie misst 15 Zeilen, §9 im Ganzen **226** gegen **134**
  beim Inventur-Slice des vorigen Sprungs, bei kleinerem Delta. Der Zuwachs sitzt in den zwei
  Mess-Abschnitten daneben, die die DoD verlangt. Kein Folge-Slice — der Eintrag steht bei **2×**
  im Register (Beleg slice-176) und wird beim nächsten Auftreten zur Lücke.
- **Ein Delta-Katalog findet eine Deckung nicht, die ein Volltext-Durchgang fände** (`BEO-013`).
  Dieser Katalog ist definitionsgemäß ein Delta; der Adaptions-Durchgang, den er als Folge-Slice
  benennt, braucht darum ausdrücklich die Volltext-Hälfte als eigenen DoD-Punkt. — **Ausgang:
  entfallen**, weil die vorab gestellte Bedingung erfüllt ist:
  [slice-185](../open/slice-185-adaptions-durchgang-gegen-v600.md) ist geschnitten, und seine
  **DoD 2** führt die Volltext-Hälfte als eigenen Punkt statt als Satz im Vorgehen; §1 dort weist
  die 19 Pfad-Treffer ausdrücklich als Lesereihenfolge und **nicht** als Bezugsmenge aus. Der
  Zähler bleibt bei **1×** — der Durchgang ist geschnitten, nicht gelaufen, und ein
  vorweggenommenes Auftreten wäre keines.
- **Der Bestand offener Slice-Pläne wird von diesem Katalog nicht gehalten** (`BEO-023`). Er misst
  das Delta der **Baseline**; ob ein Plan in `open/` seine Pflicht über den Sprung hinweg behält,
  misst er nicht. — **Ausgang: eingetreten**, und zwar beziffert: `v6.0.0` schreibt die DoD- und
  die §7-Zeile in `slice.template.md` um, und die abgelöste Form steht in **10** von **60**
  lebenden Plänen. Folge-Slice
  [slice-184](../next/slice-184-register-form-im-bestand-nachziehen.md), Welle-Mitglied; Register
  auf **2×** mit Beleg slice-176. **Die Grenze bleibt:** gezählt ist der Wortlaut, nicht die
  Pflicht dahinter — dass ein Plan durch den Sprung anders *verpflichtet* sein kann, ist ein
  Urteil je Plan und steht als Rückführung in dessen §4.
- **Übergabe 1 an den Architect: die regierende Fassung dieses Sprungs — Träger ist
  [slice-178](../done/slice-178-regierende-fassung-des-sprungs-v600.md).**
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 1
  gilt **nur** für `v5.12.0` → `v5.18.0`; ihr erster Re-Evaluierungs-Trigger verlangt für diesen
  Sprung eine neue Messung, und `BEO-019` sagt, warum sie zweistufig ist: ein byte-gleicher
  Abschnitt delegiert in Dateien, die ein Delta tragen können. Dieser Slice **misst** (DoD 3) und
  entscheidet nicht — eine neu zu begründende Wahl der normativen Quelle ist Architektur-Frage
  ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)). — **Ausgang: entfallen.**
  Der Posten kann in diesem Slice nicht mehr eintreten: Die zweistufige Messung liegt vor (§9,
  DoD 3) und kommt im **zweiten** Fall von
  [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 heraus — beide
  Fassungen führen die Prozedur, byte-gleich, und genau einer der vier Delegate trägt ein Delta.
  Der Träger [slice-178](../done/slice-178-regierende-fassung-des-sprungs-v600.md) liegt in `open/`
  und ist Mitglied der Welle; die Übergabe steht in
  [welle-15](../welle-15-re-baseline.md) §5.
- **Übergabe 2 an den Architect: die Buchung der Zielstand-Setzung — sie gehört nicht in diesen
  Slice.** Der Auftraggeber hat `v6.0.0` als Zielstand gesetzt; verbucht wird sie nach
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 in
  §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md), mit genau drei
  Teilen — Ziel-Tag und **Datum des Vollzugs**, dieser Slice als Zeiger auf den Delta-Nachweis,
  sonst nichts. Der Vollzug ist der Baum-Tausch, und der ist ein eigener Slice, den der Katalog
  benennt (Präzedenz [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md), der die Zeile für
  den vorigen Sprung schrieb). Vorher trüge die Zeile ein Datum für ein Ereignis, das nicht
  stattgefunden hat. Dieser Slice liefert den **Nachweis**, auf den sie zeigt, nicht die Zeile. —
  **Ausgang: entfallen.** Der Baum-Tausch-Slice ist geschnitten:
  [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) trägt die Buchung als dritten
  Liefer-Punkt, mit dem **Datum des Vollzugs** und einem eigenen Architect-Commit
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Damit hat der Posten einen Träger statt eines
  Platzhalters, und [welle-15](../welle-15-re-baseline.md) §4 nennt keinen ungeschnittenen Slice
  mehr.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Messen statt schätzen hat den Schnitt getragen** — die Welle stand
  bei vier Mitgliedern und steht bei sieben, und keine der drei neuen Zeilen war vorab gedacht:
  `slice-182` folgt aus P-01, `slice-184` aus P-15, `slice-185` aus einer Zählung über den
  Adaptions-Block. Ebenso trägt die **zweistufige** Messung: Stufe (a) allein hätte *„beide
  Fassungen führen die Prozedur"* geliefert und die Wahl als erledigt erscheinen lassen; erst
  Stufe (b) zeigt, dass genau **einer** der vier Delegate ein Delta hat und dass es dieselbe
  Zieldatei trifft wie beim vorigen Sprung.
- **Was ging anders als geplant:** **Die Vollständigkeits-Zusage der DoD misst auf der falschen
  Einheit.** Sie verlangt, dass die *Datei-Liste* des Katalogs `git diff --name-status` deckt —
  aber `modul-06-roadmap.md` trägt fünf Hunks mit fünf unabhängigen Gegenständen, und eine Position
  bündelt drei Dateien. Eine Datei-Deckung wäre grün gewesen, während eine Position ohne Ausgang
  dasteht. Der Katalog ist deshalb gegen die **Hunk**-Menge geführt (21/21). — Und der
  **Cross-Check gegen das Nachbar-Repo lief nur zur Hälfte**: Zuordnung und Strang-Schnitt decken
  sich, aber die Messung nach
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) hat dort kein
  Gegenstück, weil `/Development/d-check` die Frage
  nach der regierenden Fassung gar nicht als Entscheidung führt (83 ADRs, 0 Treffer). Eine
  Präzedenz deckt die **Form** der Arbeit, nicht die **Entscheidungen**, die ein Repo trägt.
- **Steering-Loop-Eintrag (geschärfte Regel, benannt und noch nicht verkörpert):** *Eine
  Vollständigkeits-Zusage über ein Delta wird gegen die **Hunk**-Menge geführt, nicht gegen die
  Datei-Liste — eine Datei trägt mehrere unabhängige Positionen, und eine Position spannt über
  mehrere Dateien.* Das Gegenbeispiel ist in diesem Lauf real angefallen und nicht konstruiert
  (§9, Vollständigkeits-Raster). Die Regel steht als `BEO-037` **gezählt, nicht verkörpert**: Ihr
  Zielort wäre der Planner-Anweisungssatz
  ([`.claude/commands/plan-welle.md`](../../../../.claude/commands/plan-welle.md),
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), und der ist
  Gegenstand einer eigenen offenen Frage (`BEO-007`, 4×, **geplant**). Ein Herkunfts-Anker steht
  hier deshalb nicht — es gibt nichts, worauf er zeigen könnte.
- **Beobachtungs-Register (`../observations.md`):** `BEO-037` neu angelegt (`*`, 1×, Beleg
  slice-176); `BEO-016`, `BEO-019` und `BEO-023` je auf **2×** erhöht, Beleg slice-176 ergänzt.
  `BEO-010`, `BEO-011` und `BEO-013` bleiben unverändert — dieser Slice ist ihre **Antwort** bzw.
  ihre Vorsorge, kein weiteres Auftreten.
- **Folge-Slices:** [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md),
  [slice-184](../next/slice-184-register-form-im-bestand-nachziehen.md) und
  [slice-185](../open/slice-185-adaptions-durchgang-gegen-v600.md) — Mitglieder von
  [welle-15](../welle-15-re-baseline.md); [slice-183](../open/slice-183-ausloeser-der-wellenlosen-archivierung.md)
  — ausdrücklich **kein** Mitglied, Grund in jener §4 (`BEO-018`). Alle vier sind Dateien im
  Planning-Lifecycle.
- **Risiken aus §6:** jedes mit genau einem Ausgang — zwei *eingetreten* (`BEO-016`, `BEO-023`),
  drei *entfallen* (`BEO-013` mit erfüllter Vorab-Bedingung, Übergabe 1, Übergabe 2). Keines
  *weiter offen*.
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area, die
die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
diesen Gegenstand führt; `harness/tools/` und `.codex/` sind vom Katalog nicht berührt. Eine
feinere Aufteilung wäre keine Ausdifferenzierung, sondern eine Vorwegnahme des Ergebnisses:
**welche** Bereiche der Diff trifft, ist der Liefergegenstand.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts, und genau das führt `BEO-004` selbst. Fünf Zeilen berühren diesen Slice mit ihrem
Zähler-Stand, keine erreicht mit ihm 3×:

- `BEO-010` (2×) — *Re-Baseline ohne vorgeschalteten Inventur-Slice*. Dieser Slice **ist** ihre
  Antwort, nicht ihr drittes Auftreten. Kommt eine Form-Pflicht dieser Fassung trotzdem als
  Nachzügler zurück, ist **das** die dritte Instanz.
- `BEO-011` (1×) — *gesammelte Sprünge kosten überproportional*. Dieser Sprung wird zeitnah
  adoptiert; ob die Kostenreihe flacher bleibt, misst die Closure der Welle.
- `BEO-013` (1×) — *Delta-Durchgang findet nicht, was ein Volltext-Durchgang findet*. Steht als
  Risiko in §6 und bindet den Zuschnitt des Adaptions-Durchgangs, den dieser Slice benennt.
- `BEO-016` (1×) — *Slice-Pläne tragen ein Vielfaches der nötigen Zeilenzahl*. Bindet diesen Plan
  selbst; er ist deshalb knapp gehalten.
- `BEO-019` (1×) — *Byte-Gleichheit an einem Abschnitt wird als Aussage über die Regel gelesen*.
  Bindet DoD 3: die Messung ist zweistufig, weil die erste Stufe allein die Klasse reproduzierte.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

## 9. Diff-Katalog

Ausgangs-Messung, gefahren am 2026-09-04 am lokalen Kurs-Klon:
`git diff --shortstat v5.18.0 v6.0.0 -- lab/regelwerk lab/templates` → **14 Dateien, +191/−91**.
Die Zahlen wandern nicht mehr (beide Tags sind fest), sind aber am Klon zu reproduzieren und stehen
hier neben ihrem Kommando
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
**Die Major-Nummer ist kein Größenmaß:** die Delta-Größe steht neben dem Kommando oben, nicht in
der Versionsnummer.

**Was der Katalog ist und was nicht:** eine Liste mit Zuordnung. Er stellt fest, *was* sich
geändert hat und *auf welcher Ebene* es einen Gegenstand hat; er führt **keinen Nachweis je
Position**. Ob eine Position dieses Repo wirklich bindet, gehört in den Slice, der sie trägt.

### Vollständigkeits-Raster

Der Katalog deckt die Datei-Liste des `--name-status`-Laufs vollständig, und die Deckung ist eine
Zählung statt einer Zusicherung: Jeder **Hunk** des Diffs ist genau einer Position zugeordnet,
Positionen dürfen mehrere Hunks bündeln. **21 Hunks über 14 Dateien**, davon **eine** neue (`A`)
und **eine** entfallene (`D`):

```sh
# am lokalen Kurs-Klon /Development/KI/ai-harness-course
git diff --name-status v5.18.0 v6.0.0 -- lab/regelwerk lab/templates          # 14 Zeilen, 1×A, 1×D
git diff v5.18.0 v6.0.0 -- lab/regelwerk lab/templates | grep -c '^@@'        # 21
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Tags sind fest, die Zahlen sind am Klon zu reproduzieren.

### Der Katalog — 15 Positionen

Drei Zuordnungen, geschlossene Menge: **RE** *bindet dieses Repo* · **EM** *bindet die emittierte
Ebene* · **—** *ohne Gegenstand hier*.

| # | Datei · Hunks | Position | Zu | Ausgang |
|---|---|---|---|---|
| P-01 | `regelwerk/README.md` ×1 | `Stand:`-Zeile `Kurs-Welle 111 · 2026-08-31` → `116 · 2026-09-03` | RE | [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) — §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md) zitiert genau diese Zeile per `sed -n '3p'` |
| P-02 | `grundlagen-begriffe.md` ×1 · `modul-05` H2 | Kennung: `BEO-<NNN>` → `BEO-<KUERZEL>/<slug>`; **keine Vergabestelle, keine fortlaufende Nummer** | RE | entschieden in [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Festlegung 3, vollzogen von [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) — **kein neuer Slice** |
| P-03 | `grundlagen-harness-dateien.md` H1 | Planning-Layout: `observations.md` → `observations/` | RE | [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) |
| P-04 | `grundlagen-harness-dateien.md` H2 | **„Die Spalte ist nicht bedingt."** Die Kürzel-Spalte der Modus-Deklaration ist unbedingt Pflicht, weil `BEO-<KUERZEL>/<slug>` jedem Repo mindestens **eine** Kennungsklasse mit Segment gibt | RE | [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) Folgepflicht 2 (Architect-Commit) — **kein neuer Slice**; s. *Eine Verschärfung* unten |
| P-05 | `grundlagen-traceability.md` ×1 (+45) | neu **§Der Fluss**: Diagramm des Steering Loops, die zwei Schleifen, und die Begründung, warum der Volltext eines geschlossenen Slice ins Archiv darf | — | keiner. Kein lebendes Artefakt dieses Repos bildet den Fluss ab (`git grep -ln 'flowchart\|stateDiagram' -- '*.md' ':!.harness/baseline' ':!docs/plan/planning/done' ':!docs/reviews'` → `roadmap.md`, `spec/architecture.md`; beide zeigen etwas anderes). Der Abschnitt ist die **Begründung** zu P-06, nicht eine zweite Pflicht |
| P-06 | `modul-05` H1 · `modul-06` H2 · `modul-10` ×1 | **Die Zeitdokumente-Archivierung bekommt für den wellenlosen Betrieb einen Träger** — die Slice-Closure selbst, nach den Paarungen, Schlüssel `done/slice-<NNN>-archiv.zip` **flach** neben dem Stub; der Review-Report wandert mit | RE | **neu:** [slice-183](../open/slice-183-ausloeser-der-wellenlosen-archivierung.md) (Architect). Gemessen: **47** geschlossene Slices tragen `**Welle:** ohne Welle`, **0** sind archiviert |
| P-07 | `modul-06` H1a | Carveout-Frist misst in Wellen — Zusatz: *„das bleibt eine benannte Lücke, keine Pflicht, und ein Repo bleibt ohne sie konform"* | — | keiner: **Entlastung**, keine neue Pflicht. Der Bestand ist trotzdem benannt — [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) führt seine Prüfungen seit `welle-03` in Wellen und hat wellenlose Neuzugänge nachweislich übersehen; die Ziel-Fassung erklärt das ausdrücklich für konform |
| P-08 | `modul-06` H1b | neuer Absatz *„Warum das Archivieren nicht hier steht"* | — | keiner: erläutert die Trägerschaft aus P-06, stellt keine eigene Pflicht |
| P-09 | `modul-06` H3 | **§Das Beobachtungs-Register vollständig neu**: Verzeichnis statt Tabelle · drei Dateien mit drei Lebensdauern · **Zähler abgeleitet statt geführt** · Kennung **ist** der Pfad · leere Ablage = nur `README.md` · *gestrichen* wird Verzeichnis-Vermerk statt zweiter Sektion · die Beleg-Prüfungen fallen von **drei** auf **zwei** (die *Anzahl*-Prüfung hat kein Objekt mehr) | RE | [`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) + [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) — **kein neuer Slice** |
| P-10 | `modul-06` H4 | Wellen-Eröffnung Schritt 2 nennt den neuen Registerpfad | RE | [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) DoD 2 |
| P-11 | `modul-06` H5 | Register-Paarung (c): die genannte Beobachtung existiert als **Verzeichnis** statt als Zeile | RE | [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) — dazu die **benannte Lücke**: die maschinelle Hälfte ist hier ohnehin unbewacht (`grep -c observations .d-check.yml` → 0), und das bleibt sie ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| P-12 | `templates/README.md` ×1 · `reconciliation.template.md` ×1 · `welle-results.template.md` ×1 | drei Querverweise ziehen auf `observation.template.md` bzw. `observations/` nach | — | [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) trägt sie **als Baum-Inhalt**, nicht als Arbeit: Dieses Repo emittiert **keine** Planning-Vorlage (`find internal/emit/templates -path '*planning*'` → leer) und führt keine `reconciliation.md` (Greenfield) |
| P-13 | `README.template.md` ×1 | Planning-README: das Register liegt als `observations/` neben den Wellen | RE | [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) DoD 2 — `docs/plan/planning/README.md` steht in dessen Bezugsmenge |
| P-14 | `observation.template.md` (**A**, +88) · `observations.template.md` (**D**, −58) | die Ziel-Form **je Beobachtung** entsteht, die Register-Vorlage entfällt | RE | [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) legt daraus per `cp` an; die Vorlage liegt netzlos erst nach [slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) vor — genau die erste Start-Bedingung jenes Slice |
| P-15 | `slice.template.md` ×2 | DoD-Zeile und §7-Zeile: Verzeichnis-Ablage, **kein Zähler wird gesetzt** — er folgt aus den Dateien | RE **+ EM** | **neu:** [slice-184](../next/slice-184-register-form-im-bestand-nachziehen.md). Gemessen: **10** von **60** lebenden Plänen tragen die alte DoD-Zeile, **4** Anweisungssatz-Dateien die alte Form-Beschreibung (Kommandos in dessen §1) |

**Keine Position ohne Ausgang** — elf tragen einen benannten Slice oder eine angenommene ADR, vier
tragen die Begründung, warum keiner nötig ist (P-05, P-07, P-08, P-12).

### Ein Ausgang, der aus keiner Position folgt — der Adaptions-Durchgang

Er steht hier, weil ein Katalog ihn strukturell **nicht** finden kann und dieser Plan das vorab
benannt hat (§6, `BEO-013`). Der Adaptions-Durchgang ist keine Zeile des Diffs, sondern eine der
sieben Eigenschaften der Migrations-Prozedur (*„Der Review geht durch die Adaptions-Liste, nicht
nur durch den Diff"*) — und seine Frage wird **pro Eintrag** gestellt, nicht pro Hunk. Wie groß er
ist, lässt sich trotzdem messen:

```sh
ls harness/conventions/MR-*.md | wc -l                                          # 47 lebende Eintraege
git grep -lE 'regelwerk/(README|grundlagen-begriffe|grundlagen-harness-dateien|grundlagen-traceability|modul-05-planning-harness|modul-06-roadmap|modul-10-review-harness)\.md' \
  -- 'harness/conventions/MR-*.md' | wc -l                                      # 19 im Pfad-Prüfbereich
```

**Die 19 sind die Delta-Hälfte und sind ausdrücklich nicht die Bezugsmenge** — genau die Lücke,
die `BEO-013` misst. Träger ist **neu:**
[slice-185](../open/slice-185-adaptions-durchgang-gegen-v600.md), dessen DoD 2 die Volltext-Hälfte
als eigenen Punkt führt statt als Satz im Vorgehen. Damit hat auch der Posten einen Ausgang, den
der Katalog seiner Bauart nach übersieht.

**Eine Verschärfung, die leicht übersehen wird (P-04).** Die Pflichtgliederungs-**Zeile** in
`grundlagen-harness-dateien.md` ist zwischen den Tags byte-gleich (`git show
<tag>:lab/regelwerk/grundlagen-harness-dateien.md | grep -n 'Modus-Deklaration pro Sub-Area'` →
in beiden Fassungen dieselbe Zeile 236). Geändert hat sich die **Prosa darunter**, die ihre
Bedingung auflöst: aus *„Wo Kennungen **kein** Segment tragen, entfällt die Spalte"* wird *„**Die
Spalte ist nicht bedingt.**"* Der Absatz in §Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area), der
die heutige Leere begründet, misst mit `git grep -ohE '\b(ADR|CO|MR)-[A-Z]{2,}-[0-9]+|\bslice-[A-Z]{2,}-[0-9]+'`
— ein Muster, das `BEO-<KUERZEL>/<slug>` **nie** träfe. Die Folgepflicht 2 von
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
ersetzt den Absatz ohnehin; die Verschärfung ist hier festgehalten, damit der Architect-Lauf den
**neuen** Grund schreibt statt des alten.

### Messung nach [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Re-Evaluierungs-Trigger 1

Zweistufig, weil jener Trigger beides verlangt. Gefahren am 2026-09-04 am lokalen Kurs-Klon.

**Stufe (a) — führt die gepinnte Fassung `v5.18.0` die Migrations-Prozedur?** **Ja.**
`modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2) steht dort mit
**sieben** Eigenschaften und **fünf** Ausgängen:

```sh
git show v5.18.0:lab/regelwerk/modul-02-harness-bootstrap.md \
  | sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p' | grep -c '^\* \*\*'   # 7
git show v5.18.0:lab/regelwerk/modul-02-harness-bootstrap.md | grep -c 'sieben Eigenschaften'   # 1
```

Damit greift **nicht** der erste Fall von
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3, sondern der
**zweite**: *„Führen beide sie, ist die Wahl offen und wird in jenem Sprung begründet
entschieden."*

**Stufe (b) — byte-gleich, und tragen die Delegate ein Delta?** Der Abschnitt ist **byte-gleich**,
und zwar die ganze Datei:

```sh
git diff --shortstat v5.18.0 v6.0.0 -- lab/regelwerk/modul-02-harness-bootstrap.md   # leer
diff <(git show v5.18.0:… | sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p') \
     <(git show v6.0.0:…  | sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p')  # leer, 123 == 123 Zeilen
```

**Von den vier Abschnitten, in die er delegiert, trägt genau einer ein Delta — und es ist derselbe
wie beim vorigen Sprung:**

```sh
for f in grundlagen-harness-dateien modul-07-carveouts modul-04-adrs grundlagen-bootstrap; do
  printf '%s: ' "$f"
  diff <(git show "v5.18.0:lab/regelwerk/$f.md") <(git show "v6.0.0:lab/regelwerk/$f.md") | grep -c '^[<>]'
done
# -> grundlagen-harness-dateien: 11   modul-07-carveouts: 0
#    modul-04-adrs: 0                 grundlagen-bootstrap: 0
```

Die **11** Zeilen liegen in zwei Hunks; der zweite (`@@ -292,8 +292,13 @@`) sitzt innerhalb von
`### harness/conventions.md als Konventionsspeicher` (Sektionsbeginn Zeile 219) und ist genau die
delegierte Frage *„ist dieses Feld Pflicht?"* — Position **P-04** oben. Das Muster von
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) §*Das Argument,
das an seine Stelle tritt* wiederholt sich damit **an derselben Zieldatei**, eine Fassung später.

**Der Fall, der daraus folgt:** zweiter Fall von
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3 — die Wahl ist
**offen** und zu begründen; *byte-gleich* trägt sie nicht, weil die Prozedur delegiert und das
Delegat ein Delta hat (`BEO-019`). **Entschieden wird sie hier nicht** — das ist
[slice-178](../done/slice-178-regierende-fassung-des-sprungs-v600.md), §6 Übergabe 1.

**Als Beifang, weil er den Zuschnitt jenes Slice betrifft:** der **dritte**
Re-Evaluierungs-Trigger jener ADR (*„wenn eine künftige Baseline die Meta-Frage selbst
beantwortet"*) ist **nicht** gefeuert — dieselben dreizehn Suchbegriffe über die hinzugefügten
Zeilen finden **0**:

```sh
git diff v5.18.0 v6.0.0 -- lab/regelwerk lab/templates | grep '^+' | grep -cE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
# -> 0
```

**Grenze**, unverändert die der Vorgänger: ein Negativ aus dreizehn aufgezählten Zeichenketten.
Damit greift die zweite Rückführung von
[slice-178](../done/slice-178-regierende-fassung-des-sprungs-v600.md) §4 **nicht**.

### Cross-Check gegen das Nachbar-Repo

`/Development/d-check` hat denselben Sprung am 2026-09-03/04 vollzogen (`welle-88`, Slices
`193`–`195`, Volltexte unter `done/welle-88/archiv.zip`). Er ist **Präzedenz und Beleg-Quelle,
keine Vorgabe** — dort gelten eigene Adaptionen und ein eigener Sub-Area-Zuschnitt.

**Die Klassifizierung deckt sich, mit einer benannten Abweichung.** d-check schneidet dieselben
zwei Stränge, die hier P-06 und P-02/P-09/P-13/P-14 sind, und trennt ebenso Pin-Bump ·
Register-Architektur · Register-Migration. Die Abweichung ist der **Zuschnitt**, nicht die
Zuordnung: d-check adoptiert P-06 auf Regelwerks-Ebene **im Bump-Slice** und schiebt die
Werkzeug-Umsetzung als unverbindlichen Folge-Slice; hier bekommt P-06 mit
[slice-183](../open/slice-183-ausloeser-der-wellenlosen-archivierung.md) einen **eigenen
Architect-Slice**, weil zwei Re-Evaluierungs-Trigger von
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) feuern und eine gefeuerte
Trigger-Bedingung eine Entscheidung verlangt, keine Übernahme. Der Grund ist repo-eigen: d-check
führt keine ADR über den Archivierungs-Träger, dieses Repo schon.

**Zwei Befunde des Nachbarn sind hier als Risiko übernommen, nicht als Ergebnis.** Sein Bump-Slice
meldet in der Closure-Notiz zwei Klassen, die erst der unabhängige Review fand — eine übersehene
lebende Version-Annotation neben einem Zitat und zu kleine Selbstauskunfts-Zahlen im begleitenden
Adaptions-Eintrag; beide stehen in
[slice-182](../done/slice-182-baum-tausch-v600-pins-ziehen.md) §6, Risiko 1 und 2. Und sein
Migrations-Slice sprengte die Ein-Sitzungs-Review-Grenze (28 Einträge, ~180 Dateien): das ist die
Rückführung, die [slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) §4 bereits
vorab benennt.

**Die Messung nach [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
Trigger 1 hat der Nachbar nicht gefahren, und der Grund ist gemessen statt vermutet:** Er führt
die Frage nach der regierenden Fassung überhaupt nicht als Entscheidung — sein Bump-Slice nennt im
Bezugs-Feld fünf `MR`-Einträge und **keine** ADR, und über seinen ganzen ADR-Bestand trifft die
Suche nach der Meta-Frage nicht:

```sh
# im Nachbar-Repo /Development/d-check
ls docs/plan/adr/[0-9]*.md | wc -l                                              # 83 ADRs
grep -rlicE 'regierende Fassung|Ziel-Fassung regiert' docs/plan/adr/ | wc -l    #  0
```

**Grenze**, dieselbe wie oben: ein Negativ aus aufgezählten Zeichenketten. Ein Abgleich der
Ergebnisse ist damit gegenstandslos — und das ist eine Auskunft über seinen Bestand, nicht über
die Richtigkeit der Messung oben.

**Eine Position ist vor diesem Katalog gemessen und geschnitten:** `v6.0.0` ersetzt die
Register-Vorlage durch eine Vorlage je **Beobachtung**
(`git diff --name-status v5.18.0 v6.0.0 -- lab/templates/docs/plan/planning`). Ihre Träger sind
[slice-179](../done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) (die Form-Entscheidung) und
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) (der Vollzug); der Katalog
weist ihr diese Slices zu, statt einen dritten zu erzeugen.

**Eine zweite Position hängt daran und hat ausdrücklich keinen Träger:** Dieselbe Umgestaltung
löst das **Kennungs-Schema** ab — statt `BEO-<NNN>` adressiert die Ziel-Fassung `BEO-<KUERZEL>/<slug>`,
und sie sagt dazu *„eine fortlaufende Nummer gibt es nicht mehr"*
(`git show v6.0.0:lab/regelwerk/modul-06-roadmap.md`, §Das Beobachtungs-Register, am lokalen
Kurs-Klon). Der **Bestand** der abgelösten Form ist repo-weit gemessen:

```sh
git grep -oE '\bBEO-[0-9]{3}\b' -- '*.md' ':!.harness/baseline' | wc -l   # 594 Vorkommen
git grep -lE '\bBEO-[0-9]{3}\b' -- '*.md' ':!.harness/baseline' | wc -l   #  70 Dateien
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die Position ist von der **Ablage**-Form getrennt zu führen: Die
Verzeichnis-Gestalt trägt
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md), das erste Pfad-Segment
entscheidet [slice-179](../done/slice-179-register-ortsfestigkeit-vor-dem-umzug.md) — was mit den
594 Vorkommen im Bestand geschieht (umhängen, oder als Stand ihrer Zeit stehen lassen, wo die
Quelle eingefroren ist), ist eine dritte Frage, die dieser Katalog **zuordnet** und die keinen
vorab erfundenen Träger bekommt (`BEO-010`, `BEO-018`).
