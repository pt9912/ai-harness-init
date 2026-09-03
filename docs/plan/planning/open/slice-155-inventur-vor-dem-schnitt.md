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

- [ ] **Diff-Katalog** in §9 dieses Plans: je geänderter Datei die inhaltlichen Positionen als
      Stichwort, je Position eine von drei Zuordnungen — *bindet dieses Repo* · *bindet die
      emittierte Ebene* · *ohne Gegenstand hier*. Vollständigkeit gemessen statt behauptet: die
      Datei-Liste des Katalogs deckt `git diff --name-only v5.12.0 v5.18.0 -- lab/regelwerk
      lab/templates` am lokalen Kurs-Klon, und die **neuen** Dateien sind als solche ausgewiesen.
- [ ] **Folge-Slice-Liste**: jede Position mit einer der ersten zwei Zuordnungen trägt entweder
      einen Folge-Slice (Datei in `open/`, Gegenstand benannt) oder die Begründung, warum keiner
      nötig ist. Keine Position ohne Ausgang.
- [ ] **Messung nach [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
      Festlegung 3**: Führt die gepinnte Fassung `v5.12.0` die Migrations-Prozedur? Ergebnis mit
      Beleg im Plan, und daraus der Fall (erster: die Ziel-Fassung regiert ohne neue Abwägung ·
      zweiter: die Wahl ist neu zu begründen). Der zweite Fall wird **nicht hier entschieden** —
      er geht als Übergabe an den Architect (§6).
- [ ] `make gates` grün.
- [ ] Doku-Update: [welle-14](../welle-14-re-baseline.md) §4 trägt eine Zeile je neu geschnittenem
      Slice, und die Roadmap ihren Drift-Eintrag. Ein öffentlicher Vertrag ist nicht berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
  Nachweis je Position. — **Ausgang:** offen, wird bei Closure verbucht.
- **Ein Delta-Katalog findet eine Deckung nicht, die ein Volltext-Durchgang fände** — die Klasse
  liegt als `BEO-013` im [Register](../observations.md), gemessen an zwei Einträgen des letzten
  Adaptions-Durchgangs. Der Katalog dieses Slice ist definitionsgemäß ein Delta; der
  Adaptions-Durchgang, den er als Folge-Slice benennt, braucht darum ausdrücklich die
  Volltext-Hälfte. — **Ausgang:** offen, wird bei Closure verbucht.
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
  §Geschichte jener ADR ist mit ihrer Annahme geschlossen. — **Ausgang:** offen, wird bei Closure
  verbucht.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations.md`):** <neue `BEO-<NNN>` angelegt (Sub-Area, 1×, Beleg slice-NNN) | `BEO-<NNN>` auf <N>× erhöht, Beleg slice-NNN ergänzt | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

<!-- Wird im Implementations-Lauf gefüllt; DoD-Punkt 1 und 2 dieses Plans. -->

Ausgangs-Messung, gefahren am 2026-09-03 am lokalen Kurs-Klon:
`git diff --shortstat v5.12.0 v5.18.0 -- lab/regelwerk lab/templates` → **21 Dateien, +414/−45**.
Die Zahlen wandern nicht mehr (beide Tags sind fest), sind aber am Klon zu reproduzieren und stehen
hier neben ihrem Kommando
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
