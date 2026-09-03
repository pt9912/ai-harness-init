# Slice slice-155: Inventur vor dem Schnitt — der Form- und Regel-Diff `v5.12.0` → `v5.18.0`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md) — der erste Slice der Welle; er liefert die
Grundlage, auf der ihre übrigen Mitglieder geschnitten werden.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Baseline
ist auf einen Tag gepinnt — der Diff ist die Vorarbeit zum Tausch dieses Pins),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 3: vor jedem
künftigen Sprung wird gemessen, ob die **gepinnte** Fassung die Migrations-Prozedur führt),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der vendored Baum ist der Gegenstand),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (die Adoptions-Erklärung,
die der Tausch fortschreibt).

**Berührte Spec-Stellen:** `—`. Der Slice katalogisiert und schneidet; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Planner (pt9912). Der Liefergegenstand ist ein Katalog im Plan und eine Menge
neuer Slice-Dateien in `open/` — beides Planner-Artefakte (Baseline-Regelwerk
`modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse: Planner wird über das
Template geführt). Das Feld weicht damit von der Default-Besetzung ab, die Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine nennt (*„den Rolleninhaber der
Implementer-Rolle"*).

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der vollständige Form- und Regel-Diff `v5.12.0` → `v5.18.0` liegt als Katalog vor, jede
geänderte Position hat eine Zuordnung, und daraus steht fest, welche Slices
[welle-14](../welle-14-re-baseline.md) braucht — bevor der Rest geschnitten wird.**

Der Slice ist die Antwort auf `BEO-010` ([Register](../observations.md)):
[welle-10](../done/welle-10-re-baseline.md) schloss mit erheblich mehr Mitgliedern, als sie
geschnitten hatte — beide Zahlen stehen dort neben den Kommandos, die sie ausgeben —, weil die
Form-Pflichten der neuen Fassung einzeln als Nachzügler zurückkamen. Der Umfang der Folge-Arbeit
wird hier **gemessen, nicht geschätzt**.

**Er entscheidet nichts über den Ist-Zustand.** Ein Katalog stellt fest, was sich geändert hat;
ob eine Änderung dieses Repo bindet, ist eine Konformitäts-Frage, und für die bleibt bis zum
Tausch `v5.12.0` maßgeblich ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
Festlegung 2). Der Katalog hängt darum nicht an der offenen Frage aus §6.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Diff-Katalog** in §9 dieses Plans: je geänderter Datei die inhaltlichen Positionen als
      Stichwort, je Position eine von drei Zuordnungen — *bindet dieses Repo* · *bindet die
      emittierte Ebene* · *ohne Gegenstand hier*. Vollständigkeit gemessen statt behauptet: die
      Datei-Liste des Katalogs deckt `git diff --name-only v5.12.0 v5.18.0 -- lab/regelwerk
      lab/templates` am lokalen Kurs-Klon, und die **neuen** Dateien sind als solche ausgewiesen.
- [x] **Folge-Slice-Liste**: jede Position mit einer der ersten zwei Zuordnungen trägt entweder
      einen Folge-Slice (Datei in `open/`, Gegenstand benannt) oder die Begründung, warum keiner
      nötig ist. Keine Position ohne Ausgang.
- [x] **Messung nach [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
      Festlegung 3**: Führt die gepinnte Fassung `v5.12.0` die Migrations-Prozedur? Ergebnis mit
      Beleg im Plan, und daraus der Fall (erster: die Ziel-Fassung regiert ohne neue Abwägung ·
      zweiter: die Wahl ist neu zu begründen). Der zweite Fall wird **nicht hier entschieden** —
      er geht als Übergabe an den Architect (§6). *Ergebnis: zweiter Fall; Träger der Übergabe ist
      [slice-163](../done/slice-163-regierende-fassung-des-sprungs.md).*
- [x] `make gates` grün.
- [x] Doku-Update: [welle-14](../welle-14-re-baseline.md) §4 führt **jeden** neu geschnittenen
      Slice — als Tabellenzeile, wenn er Mitglied ist, sonst benannt mit dem Grund seines
      Ausschlusses (§6 jener Datei); die Roadmap trägt ihren Drift-Eintrag. Ein öffentlicher
      Vertrag ist nicht berührt. *Der Nachsatz ist eine Präzisierung dieses Punktes gegenüber dem
      Schnitt: dass eine Katalog-Position ihren Ausgang außerhalb der Welle finden kann, war beim
      Schneiden nicht gesehen — die Klasse liegt als `BEO-018` im [Register](../observations.md).*
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
| [welle-14](../welle-14-re-baseline.md) §4 | update | die Slice-Tabelle der Welle bekommt ihre übrigen Zeilen |

Der Katalog wird am lokalen Kurs-Klon `/Development/KI/ai-harness-course` gemessen (`git diff`
zwischen den zwei Tags). Der vendored Baum unter `.harness/baseline/` wird in diesem Slice **nicht**
angefasst — der Tausch ist ein eigener Slice, den der Katalog benennt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [welle-14](../welle-14-re-baseline.md) ist eröffnet — ihre
Plan-Datei liegt flach in `docs/plan/planning/`, und die Roadmap führt sie unter *Offene Wellen*.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Zuordnung einer Position selbst
  Messarbeit am Bestand dieses Repos verlangt, die über einen Lauf hinausgeht — dann wird der
  Katalog nach Achsen geteilt (Regelwerk-Hälfte / Template-Hälfte), und die Zuordnung der zweiten
  Achse wird ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn der lokale Kurs-Klon den Tag `v5.18.0` nicht
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

- **Der Katalog wird zur Beweisführung und wächst über seinen Zweck hinaus** — die Klasse liegt als
  `BEO-016` im [Register](../observations.md). Ein Katalog ist eine Liste mit Zuordnung, kein
  Nachweis je Position. — **Ausgang: entfallen.** Das Risiko hatte diesen Lauf als Gegenstand, und
  der ist vorbei: §9 ist eine Tabelle mit einer Spalte `Zu` und einer Spalte `Ausgang`, und die
  Nachweis-Pflicht steht ausdrücklich beim tragenden Slice statt bei der Position. Gemessen: die
  acht geschnittenen Pläne liegen zwischen **159** und **180** Zeilen
  (`wc -l docs/plan/planning/open/slice-1{56,57,58,59,60,61,62,63}-*.md | sort -n`) gegen die
  **185**-Zeilen-Vorlage, aus der sie kopiert sind
  (`wc -l .harness/baseline/v5.12.0/templates/docs/plan/planning/slice.template.md`) — keine
  Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Die **Klasse** bleibt im Register und wird von jedem künftigen Plan neu gestellt.
- **Ein Delta-Katalog findet eine Deckung nicht, die ein Volltext-Durchgang fände** — die Klasse
  liegt als `BEO-013` im [Register](../observations.md), gemessen an zwei Einträgen des letzten
  Adaptions-Durchgangs. Der Katalog dieses Slice ist definitionsgemäß ein Delta; der
  Adaptions-Durchgang, den er als Folge-Slice benennt, braucht darum ausdrücklich die
  Volltext-Hälfte. — **Ausgang: weiter offen → `BEO-013`** im [Register](../observations.md). Der
  Einzelfall ist gebunden — [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) trägt die
  Volltext-Hälfte als eigenen DoD-Punkt —, die Klasse bleibt: dieser Katalog **ist** ein Delta und
  sagt das über sich selbst.
- **Übergabe an den Architect, offen zum Zeitpunkt des Schnitts: die regierende Fassung dieses
  Sprungs.** [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) ist `Accepted` und
  nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 nicht änderbar. Ihre Festlegung 3 sieht genau
  diesen Fall vor, und ihr erster Re-Evaluierungs-Trigger sagt, was folgt: *„Führt die dann
  gepinnte Fassung die Migrations-Prozedur, greift der zweite Fall, und die Wahl ist neu zu
  begründen."* Eine **neu zu begründende Wahl der normativen Quelle** ist eine Architektur-Frage
  ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)), und
  [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) §Verglichene Alternativen
  verwirft Option A — sie im Wellenplan zu halten — ausdrücklich. Dieser Slice **misst** (DoD 3)
  und **entscheidet nicht**. Zwei Posten gehen mit der Messung an den Architect: die Wahl selbst,
  und der Ort, an dem die Zielstand-Setzung des Auftraggebers samt Delta-Nachweis künftig steht —
  §Geschichte jener ADR ist mit ihrer Annahme geschlossen. — **Ausgang: eingetreten →
  [slice-163](../done/slice-163-regierende-fassung-des-sprungs.md).** Die Messung in §9 ergibt den
  **zweiten** Fall von Festlegung 3 (beide Fassungen führen die Prozedur, der Abschnitt ist
  byte-gleich), also ist die Wahl neu zu begründen. Beide Posten hängen an demselben Verdikt und
  gehen darum in **einen** Slice; er ist Mitglied von [welle-14](../welle-14-re-baseline.md) und
  liegt vor jedem Durchgang, der ein Konformitäts-Urteil fällt.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Der Katalog **vor** dem Schnitt macht die Mitglieder-Zahl zur Messung.
  21 Positionen ergaben **sechs** gebündelte Slices statt zwanzig einzelne — die Bündelung fällt
  auf, weil die Zuordnung *vor* dem Schneiden steht: Position 9, 10 (d), 11, 12, 16, 17, 18 und
  6 (a) sind acht Positionen aus fünf Dateien und **ein** Slice, weil sie denselben neuen
  Closure-Schritt tragen. Und die drei Kategorien trennen sauber: dass eine Position *ohne
  Gegenstand hier* ist, war dreimal eine kurze, belegbare Antwort statt einer Vermutung.
- **Was ging anders als geplant:** Zwei Slices folgen **nicht** aus der Datei-Tabelle, sondern aus
  der Messung darunter — [slice-163](../done/slice-163-regierende-fassung-des-sprungs.md) aus
  Festlegung 3 und [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) aus einer
  Position, deren Ausgang die Welle ausschließt. Der Plan hatte für die erste eine *Übergabe*
  vorgesehen und für die zweite nichts; beide brauchten einen Träger, und eine Übergabe ohne
  Träger ist ein Posten, den niemand hält.
- **Steering-Loop-Eintrag:** Der Zuschnitt einer Re-Baseline-Welle folgt seit diesem Slice einem
  gemessenen Katalog statt einer Schätzung — der Nachweis ist §9 dieses Plans, der Ertrag steht in
  [welle-14](../welle-14-re-baseline.md) §4. Der Eintrag ist **gezählt, nicht verkörpert**: er
  liegt in keinem Zielort, weil `BEO-010` bei 2× steht und die Schwelle nicht erreicht hat.
  Auslöser: `BEO-010` (slice-149, slice-148 — 2×).
- **Beobachtungs-Register (`../observations.md`):** `BEO-018` neu angelegt (`*` (gesamtes Repo),
  1×, Beleg slice-155) — die Out-of-Scope-Liste einer Welle und die Doku-DoD eines ihrer Slices
  sagen über dieselbe neue Datei Verschiedenes. Kein Zähler erhöht: `BEO-010` ist die **Antwort**
  dieses Slice und nicht sein drittes Auftreten (ein Nachzügler wäre die dritte Instanz, und
  darüber urteilt die Closure der Welle); `BEO-013` hat hier keinen zweiten Durchgang, der die
  Deckung verfehlt hätte; `BEO-016` hat diesen Plan gebunden, aber kein neues Auftreten erzeugt —
  die Messung dazu steht in §6. Drei `Stand`-Zellen sind um ihren Träger ergänzt (`BEO-010`,
  `BEO-013`).
- **Folge-Slices:** [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) (Tausch und Pins) ·
  [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) (Adaptions-Durchgang) ·
  [slice-158](../open/slice-158-archivierungs-schritt.md) (Archivierungs-Schritt) ·
  [slice-159](../next/slice-159-register-traegt-die-drei-ausgaenge.md) (Beobachtungs-Register) ·
  [slice-160](../open/slice-160-docker-form-hermetisch-und-beleg.md) (Docker-Form) ·
  [slice-161](../open/slice-161-conventions-kopf-traegt-die-ziel-form.md) (Kopf-Form der
  Konventionen) · [slice-162](../open/slice-162-versions-sensor-baseline-pins.md)
  (Versions-Sensor) · [slice-163](../done/slice-163-regierende-fassung-des-sprungs.md) (regierende
  Fassung) — alle acht sind Dateien in `open/`.
- **Risiken aus §6:** drei, je genau ein Ausgang — *entfallen* (Katalog-Umfang, mit Messung) ·
  *weiter offen → `BEO-013`* (Delta gegen Volltext) · *eingetreten → slice-163* (regierende
  Fassung).
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — die Paarungen prüft die Closure von
  [welle-14](../welle-14-re-baseline.md). Was dieser Slice ihnen vorlegt: **Anker** — kein Feld
  `liegt in`, der Steering-Loop-Eintrag ist gezählt, nicht verkörpert; **Folge-Slice** — acht
  Kennungen, alle als Datei in `open/`; **Register** — `BEO-010`, `BEO-011`, `BEO-013` und
  `BEO-016` sind hier zitiert und haben je eine Zeile, `BEO-018` ist neu und trägt mit
  `slice-155` seinen Beleg.

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
feinere Aufteilung wäre hier keine Ausdifferenzierung, sondern eine Vorwegnahme des Ergebnisses:
**welche** Bereiche der Diff trifft, ist der Liefergegenstand.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations.md) ist vollständig
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts, und genau das führt `BEO-004` selbst. Vier Zeilen berühren diesen Slice mit ihrem
Zähler-Stand:

- `BEO-010` (2×) — *Re-Baseline ohne vorgeschalteten Inventur-Slice*. Dieser Slice **ist** ihre
  Antwort, nicht ihr drittes Auftreten. Kommt eine Form-Pflicht dieser Fassung trotzdem als
  Nachzügler zurück, ist **das** die dritte Instanz.
- `BEO-011` (1×) — *gesammelte Sprünge kosten überproportional*. Die Welle adoptiert sechs Minor-
  Stände ohne Major-Grenze; ob die Kostenreihe damit kippt, misst ihre Closure.
- `BEO-013` (1×) — *Delta-Durchgang findet nicht, was ein Volltext-Durchgang findet*. Steht als
  Risiko in §6 und bindet den Zuschnitt des Adaptions-Durchgangs, den dieser Slice benennt.
- `BEO-016` (1×) — *Slice-Pläne tragen ein Vielfaches der nötigen Zeilenzahl*. Bindet diesen Plan
  selbst; er ist deshalb knapp gehalten.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.

## 9. Diff-Katalog

Ausgangs-Messung, gefahren am 2026-09-03 am lokalen Kurs-Klon:
`git diff --shortstat v5.12.0 v5.18.0 -- lab/regelwerk lab/templates` → **21 Dateien, +414/−45**.
Die Zahlen wandern nicht mehr (beide Tags sind fest), sind aber am Klon zu reproduzieren und stehen
hier neben ihrem Kommando
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

**Die Datei-Liste unten deckt `git diff --name-status v5.12.0 v5.18.0 -- lab/regelwerk
lab/templates`** — 21 Zeilen, davon **2** mit Status `A` (neu, in `v5.12.0` nicht vorhanden); sie
sind als **NEU** ausgewiesen.

**Was dieser Katalog ist und was nicht.** Eine Liste mit Zuordnung. Er stellt fest, *was* sich
geändert hat und *auf welcher Ebene* es einen Gegenstand hat — er führt **keinen Nachweis je
Position**. Ob eine Position dieses Repo wirklich bindet, gehört in den Slice, der sie trägt; die
Zuordnung hier ist die Adresse, nicht das Urteil.

### Die 21 Positionen

Zuordnungen: **D** = bindet dieses Repo (Dogfood) · **E** = bindet die emittierte Ebene
(`internal/emit/templates/`) · **—** = ohne Gegenstand hier.

| # | Datei | Position (Stichwort) | Zu | Ausgang |
|---|---|---|---|---|
| 1 | `regelwerk/README.md` | Stand-Zeile: Kurs-Welle 98 · 2026-08-26 → 111 · 2026-08-31 | D | [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) — `harness/conventions.md` §Baseline zitiert genau diese Zeile |
| 2 | `grundlagen-begriffe.md` | neue Glossarzeile `MR-<NNN>`: Vergabestelle Adaptions-Block, Text in `harness/conventions/MR-<NNN>-<titel>.md`, Zustand = Verzeichnis-Position, **kein Status-Feld** | D | [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) — die Verzeichnis-Form selbst ist per [welle-14](../welle-14-re-baseline.md) §6 ausgeschlossen (`BEO-014`) |
| 3 | `grundlagen-durchsetzungsschicht.md` | §Referenz-Implementierung → §Das vollständige Artefakt-Set; der Pfad `tools/harness/…` fällt zugunsten *„eine gemeinsame, inhaltsbasierte Nachweis-Quelle"*, der Referenz-Repo-Schluss entfällt | D | [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) — [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) ersetzt genau die gestrichene Zeile, [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) zitiert den umbenannten Anker |
| 4 | `grundlagen-harness-dateien.md` | Modus-Deklaration führt je Sub-Area ein **Kürzel** (kurz, GROSS, unveränderlich), sobald Kennungen ein Bereichssegment tragen; ohne Segment entfällt die Spalte | D | [slice-161](../open/slice-161-conventions-kopf-traegt-die-ziel-form.md) — die Bedingung ist zu messen, nicht anzunehmen |
| 5 | `grundlagen-source-precedence.md` | „Das Segment wird nachgeschlagen, nicht formuliert" — das Kürzel steht in der Modus-Deklaration | D | [slice-161](../open/slice-161-conventions-kopf-traegt-die-ziel-form.md) — dieselbe Pflicht wie 4, ein Slice |
| 6 | `grundlagen-traceability.md` | vier Zusätze: (a) Herkunfts-Anker nach dem Archivieren ist zweistufig (Stub → Archiv) · (b) Gegenrichtung der Ruheort-Regel für `MR-<NNN>`: der `git mv` zieht die Pfad-Berichtigung nach · (c) **zwei Rot-Quellen**: Baseline-Verweise tragen die Version, ein Versions-Sensor prüft jeden Pin gegen **eine** Deklaration · (d) „Beide Commits gehören in denselben Push" | D | (a) → [slice-158](../open/slice-158-archivierungs-schritt.md) · (b) → [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) · (c) → [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) · (d) → [slice-157](../done/slice-157-adaptions-durchgang-v5180.md), dort als **Übergabe an den Architect** (Hard-Rule-Nachbarschaft zu [`AGENTS.md`](../../../../AGENTS.md) §3.3, kein `MR`) |
| 7 | `modul-00-einfuehrung.md` | Streichung der Beleg-Quellenangabe im ersten Bullet | — | reine Kurs-Didaktik; kein Repo-Artefakt zitiert die Stelle als Regel |
| 8 | `modul-02-harness-bootstrap.md` | (a) Streichung „Die vier Fallstudien sind alle in BF" · (b) **neu**: „Und das Fragment mountet" — das generierte d-check-Fragment reicht den Baum read-only herein; **zulässig, solange nur gelesen wird**, sonst `MR` | (a) — · (b) D+E | (a) Kurs-Didaktik · (b) → [slice-157](../done/slice-157-adaptions-durchgang-v5180.md), Deckungs-Frage zu [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert); die Mount-Achse selbst trägt [slice-160](../open/slice-160-docker-form-hermetisch-und-beleg.md) |
| 9 | `modul-05-planning-harness.md` | `done/` ist nicht die letzte Station: nach der Wellen-Closure Volltext ins Archiv, gekürzter Stub bleibt | D | [slice-158](../open/slice-158-archivierungs-schritt.md) |
| 10 | `modul-06-roadmap.md` | (a) Beleg-Form generalisiert: Kennung eines abgeschlossenen **Vorgangs** (Slice · Welle · Review-Report), Lage = wo die Klasse abgeschlossen wird · (b) **neu**: ein Vorgang zählt **einmal**; ein Vorkommen ohne Vorgang ist *benannt, nicht gezählt* · (c) **neu**: drei Ausgänge ab 3× (*verkörpert · geplant · gestrichen*) als geschlossene Menge, `offen` unterhalb der Schwelle ist kein Ausgang · (d) **neu**: Closure-Schritt 4 *Zeitdokumente archivieren*, Schritte 5/6 verschoben, **sechs** statt fünf | D (a–d), E (a–c über die Anweisungssätze) | (a)–(c) → [slice-159](../next/slice-159-register-traegt-die-drei-ausgaenge.md) · (d) → [slice-158](../open/slice-158-archivierungs-schritt.md) |
| 11 | `modul-08-agentenrollen.md` | Rollen-Sequenz für eine Welle: **sechs** Closure-Schritte, Schritt 4 = Archivieren (Planner), 5 = Self-Close-Commit, 6 = Roadmap | D+E | [slice-158](../open/slice-158-archivierungs-schritt.md) — beide `close-welle.md` führen heute *fünf* |
| 12 | `modul-10-review-harness.md` | Review-Report wandert vollständig ins Archiv, **ohne Stub**; ein Rang-Dokument, das einen einzelnen Report als Beleg verlinkt, macht ein Zeitdokument zur Quelle | D | [slice-158](../open/slice-158-archivierungs-schritt.md) |
| 13 | `modul-13-quality-gates.md` | **neu**: §Gate und Beleg — zwei Rollen derselben Prüfung. Der tolerierende Nachsatz gehört an den Beleg-Lauf, **nie** an den Gate-Lauf; die sammelnde Stage erbt von der Quell-, nicht von der Gate-Stage | D+E | [slice-160](../open/slice-160-docker-form-hermetisch-und-beleg.md) |
| 14 | `modul-14-docker-harness.md` | **neu**, drei Abschnitte: §Zwei Formen des Reproduzierbarkeits-Ankers (Archiv vs. Rezept) · §Besitz der Belege eines containerisierten Gates (root über schreibbarem Mount) · §Der Prüflauf ist hermetisch — kein Mount (`COPY` + `stdout`; `--no-cache-filter`, **kein** `-q`) | D+E | [slice-160](../open/slice-160-docker-form-hermetisch-und-beleg.md) |
| 15 | `templates/.d-check.yml` | (a) **neu**: `versions`-Block (auskommentiert) — `pin-pattern`, `current-from: harness/conventions.md#baseline`, `exempt-paths`; `version-stale` statt totem Link · (b) `vcs`: `immutable-when` keilt auf die Datums-Zeile, `status-line`/`head-allow` entfallen | (a) D+E · (b) — | (a) → [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) · (b) kein Folge-Slice: er gilt der Verzeichnis-Form `harness/conventions/**`, die dieses Repo nicht führt (`BEO-014`, per [welle-14](../welle-14-re-baseline.md) §6 ausgeschlossen), und die emittierte Starter-Config trug den Block nie |
| 16 | `templates/README.md` | zwei neue Zeilen für die Archiv-Stub-Vorlagen; die „wiederkehrend"-Liste wächst um beide | D | [slice-158](../open/slice-158-archivierungs-schritt.md) — derivativ zu Position 10 (d), keine eigene Arbeit |
| 17 | `templates/docs/plan/planning/archiv-stub-slice.template.md` | **NEU** — Stub an der Stelle des archivierten Slice-Volltexts; keine Abschnittsüberschriften, `Welle:` + `Archiviert mit:` + `Hervorgegangen:` | D | [slice-158](../open/slice-158-archivierungs-schritt.md) |
| 18 | `templates/docs/plan/planning/archiv-stub-welle.template.md` | **NEU** — Stub an der Stelle des archivierten Welle-Plans; Zeiger auf die Ergebnisnotiz und die Zahl der archivierten Vorgänge | D | [slice-158](../open/slice-158-archivierungs-schritt.md) |
| 19 | `templates/docs/plan/planning/observations.template.md` | Kopftext nennt die drei Ausgänge; Bedienhinweis: Vorgangs-Beleg, ein Vorgang zählt einmal, `offen` als Normalzustand | D | [slice-159](../next/slice-159-register-traegt-die-drei-ausgaenge.md) — Singleton-Form-Pflicht, die zweite Ursachen-Klasse aus `BEO-010` |
| 20 | `templates/harness/conventions.template.md` | (a) `Stand:` ist **Version/Tag, kein Datum** — sonst bricht der Versions-Sensor fail-closed · (b) Modus-Deklaration bekommt die Kürzel-Spalte | D | [slice-161](../open/slice-161-conventions-kopf-traegt-die-ziel-form.md); die emittierte Fassung ist dieselbe vendored Vorlage mit zwei Transformationen ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) §Nur die Dogfood-Ebene) und zieht mit [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) mit |
| 21 | `templates/harness/conventions/MR-NNN-titel.template.md` | (a) das Feld `- **Status:** Accepted` **entfällt** · (b) der `Ersetzt-Baseline-Regel`-Link trägt Tiefe **und** Version, je mit eigenem Wächter | D | [slice-157](../done/slice-157-adaptions-durchgang-v5180.md) — (a) deckt sich mit [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) §*„Akzeptiert" heißt committet*; (b) ist die Regel, deren Werkzeug [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) baut |

**Verteilung — Handzählung über die Spalte `Zu`, kein Kommando gibt genau sie aus**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1): **20** der 21 Zeilen tragen **D**, davon **6** zusätzlich **E**. **Eine** Zeile ist
ganz ohne Gegenstand (7), zwei weitere tragen je eine Teil-Position ohne Gegenstand (8a, 15b).
Jede Position mit **D** oder **E** trägt in der Spalte `Ausgang` entweder eine Slice-Kennung oder
die Begründung, warum keiner nötig ist; **keine Position ohne Ausgang**.

**Sechs Folge-Slices, nicht zwanzig.** Der Schnitt bündelt:
[156](../done/slice-156-baum-tauschen-pins-ziehen.md) (Tausch und Pins) ·
[157](../done/slice-157-adaptions-durchgang-v5180.md) (Adaptions-Durchgang, Delta **und**
Volltext) · [158](../open/slice-158-archivierungs-schritt.md) (Archivierungs-Schritt) ·
[159](../next/slice-159-register-traegt-die-drei-ausgaenge.md) (Beobachtungs-Register) ·
[160](../open/slice-160-docker-form-hermetisch-und-beleg.md) (Docker-Form) ·
[161](../open/slice-161-conventions-kopf-traegt-die-ziel-form.md) (Kopf-Form von
`harness/conventions.md`, Architect). Genau das ist die Lehre aus dem Nachzügler-Problem von
[welle-10](../done/welle-10-re-baseline.md): einmal breiter schneiden statt fünfmal denselben Fund
einzeln.

**Dazu zwei Slices, die nicht aus der Tabelle folgen, sondern aus der Messung darunter:**
[163](../done/slice-163-regierende-fassung-des-sprungs.md) (die regierende Fassung — Mitglied der
Welle, sie blockiert jeden Durchgang mit Konformitäts-Urteil) und
[162](../open/slice-162-versions-sensor-baseline-pins.md) (Versions-Sensor — **kein** Mitglied,
ein Sensor-Neubau, den [welle-14](../welle-14-re-baseline.md) §6 ausschließt; er liegt in `open/`
und ist damit verbucht, ohne die Welle zu dehnen).

### Messung nach [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3

**Frage:** Führt die **gepinnte** Fassung `v5.12.0` die Migrations-Prozedur?

**Ergebnis: ja — und die Ziel-Fassung führt dieselbe, wörtlich.** Der Abschnitt
§Freshness-Audit der vendored Baseline (Schritt 2) in `modul-02-harness-bootstrap.md` ist zwischen
den beiden Tags **byte-gleich**:

```sh
# am lokalen Kurs-Klon
diff <(git show v5.12.0:lab/regelwerk/modul-02-harness-bootstrap.md \
        | sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p') \
     <(git show v5.18.0:lab/regelwerk/modul-02-harness-bootstrap.md \
        | sed -n '/^#### Freshness-Audit/,/^#### Gate-Fragment/p')
# -> leer
git show v5.18.0:lab/regelwerk/modul-02-harness-bootstrap.md | grep -c 'Der Freshness-Audit hat sieben Eigenschaften'
# -> 1
```

Dass der vendored Baum dieses Repos denselben Text trägt wie der Kurs-Tag, ist mitgemessen
(dasselbe `diff` gegen
`.harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md` → leer).

**Damit greift der zweite Fall** von Festlegung 3: *„Führen beide sie, ist die Wahl **offen** und
wird in jenem Sprung begründet entschieden. Diese ADR entscheidet sie nicht vor."* Der erste Fall
— der Fall jener ADR, in dem die gepinnte Fassung den Vorgang nicht beschreibt — greift **nicht**.

**Der zweite Re-Evaluierungs-Trigger ist nicht gefeuert.** Die dreizehn Suchbegriffe jener ADR
über die **hinzugefügten** Zeilen dieses Schritts finden **12** Zeilen; alle sind gelesen, und
keine ist eine Meta-Regel darüber, welche Fassung einen Wechsel regiert — sie sprechen von der
`MR`-Kennung, vom Baseline-Bump als Anlass eines Versions-Sensors, von der Schritt-Zahl der
Closure-Prozedur, vom `Stand:`-Feld und von der Adoptions-Zeile darunter:

```sh
git diff v5.12.0 v5.18.0 -- lab/regelwerk lab/templates | grep '^+' | grep -cE \
  'welche Fassung|maßgeblich|regiert|gepinnte Fassung|alte Fassung|Prozedur|Migration|Re-Vendor|Bump|adoptiert|Adoption|Übergang|Reihenfolge des Wechsels'
# -> 12
```

### Übergabe an den Architect

Dieser Slice **misst** und entscheidet nicht (§1, §6). Zwei Posten gehen mit der Messung an den
Architect, beide als Architektur-Frage nach
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md); ihr **Träger** ist
[slice-163](../done/slice-163-regierende-fassung-des-sprungs.md) — eine Übergabe ohne Träger wäre
ein Posten, den niemand hält:

1. **Die Wahl der regierenden Fassung für den Sprung `v5.12.0` → `v5.18.0`.** Der zweite Fall
   greift, die Wahl ist offen und neu zu begründen. Da beide Fassungen denselben Wortlaut führen,
   ist die *praktische* Differenz null — die **Begründungspflicht** besteht trotzdem, und sie ist
   nicht hier einzulösen:
   [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) §Verglichene Alternativen
   verwirft Option A — die Festlegung im Wellenplan zu halten — ausdrücklich. Der Plan von
   [welle-14](../welle-14-re-baseline.md) trägt darum einen Zeiger, keine Setzung.
2. **Wo die Zielstand-Setzung des Auftraggebers samt Delta-Nachweis künftig steht.** §Geschichte
   jener ADR ist mit ihrer Annahme geschlossen — sie sagt selbst, dass ab *Accepted* jede weitere
   Bewegung des Zielstands eine Folge-ADR mit `Supersedes` ist. Die Setzung, die
   [welle-14](../welle-14-re-baseline.md) trägt (`v5.18.0` statt `v5.12.0`), hat damit heute
   **keinen** Ort, an dem sie mit Delta-Nachweis stünde; dieser Katalog ist der Nachweis, nicht
   sein Gefäß.

**Was nicht übergeben wird:** die Zuordnung der 21 Positionen und der Zuschnitt der acht
Folge-Slices. Beides ist Planner-Arbeit und steht oben.
