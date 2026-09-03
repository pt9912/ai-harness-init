# Slice slice-161: `harness/conventions.md` trägt die Ziel-Form ihres Kopfes — Stand als Version, Kürzel-Spalte

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (das ID-Schema
dieses Repos — es entscheidet, ob die Kürzel-Spalte überhaupt geführt wird),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) (die schreibende Rolle).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der Kopf von [`harness/conventions.md`](../../../../harness/conventions.md) trägt die Ziel-Form:
ein `Stand:`-Feld mit der **Version** an der Stelle, die ein Versions-Sensor per
`current-from: harness/conventions.md#baseline` liest — und die Modus-Deklaration trägt die
Kürzel-Spalte oder die Begründung, warum sie entfällt.**

Die Ziel-Fassung präzisiert zwei Dinge an der Vorlage: `Stand:` ist eine Version oder ein Tag und
**kein Datum** — steht dort ein Datum, findet der Versions-Sensor keine Version und bricht
fail-closed ab, der Gate läuft dann gar nicht mehr. Und die Modus-Deklaration bekommt eine
**Kürzel**-Spalte, die nur Repos führen, deren Kennungen ein Bereichssegment tragen
(`ADR-<KUERZEL>-NNNN`, `slice-<KUERZEL>-NNN`); wer ohne Segment zählt, streicht sie. Ein
vergebenes Kürzel ist unveränderlich.

**Dieser Slice ist Architect-Arbeit** — der Adaptions-Block und der Kopf, in dem er wohnt, gehören
der Rolle, die die Norm schreibt ([`AGENTS.md`](../../../../AGENTS.md) §3.8): eigener Commit, nur
Architect-Artefakte, Rolle in der Message.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **§Baseline trägt ein `Stand:`-Feld mit der Version** — an einer Stelle, die ein Sensor
      über den Abschnitts-Anker liest, und getrennt vom Datum der Adoption. Dass die heutige Form
      das nicht leistet, ist gemessen und nicht behauptet.
- [ ] **Die Kürzel-Frage ist beantwortet:** entweder trägt die Modus-Deklaration die Spalte, oder
      der Text nennt die Bedingung, unter der sie entfällt — mit dem Beleg aus dem ID-Schema
      dieses Repos ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)).
      Keine leere Spalte und kein stilles Weglassen.
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt.
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
| `harness/conventions.md` §Baseline | update | das `Stand:`-Feld als Bezugspunkt des Sensors |
| `harness/conventions.md` §Modus-Deklaration pro Sub-Area | update | die Kürzel-Frage |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](slice-156-baum-tauschen-pins-ziehen.md) liegt in
`done/` — die Form, gegen die gemessen wird, ist dann die adoptierte, und §Baseline nennt bereits
den neuen Tag.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Kürzel-Frage eine Änderung am
  ID-Schema nach sich zöge — das wäre eine eigene Entscheidung mit eigenem Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn das `Stand:`-Feld nicht ohne eine zweite
  Quelle für denselben Zustand entstehen kann.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; der Kopf trägt die Version genau einmal; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Das neue Feld wird zur zweiten Quelle** — der Tag steht heute in `BASELINE_TAG` und in
  §Baseline; ein drittes Feld daneben altert.
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 4 verlangt ausdrücklich **genau eine** Quelle für den Tag-String. — **Ausgang:** offen,
  wird bei Closure verbucht.
- **Die Kürzel-Spalte wird geführt, obwohl die Bedingung nicht erfüllt ist** — eine Spalte ohne
  Gegenstand ist eine Form, die nichts trägt. — **Ausgang:** offen, wird bei Closure verbucht.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der Gegenstand **ist**
die Modus-Deklaration selbst, und sie führt für sich keine engere Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-004` (die Sub-Area-Spalte des Registers
unterscheidet nichts, weil die Deklaration nur `*` führt) berührt diesen Slice direkt — die Zeile
nennt die Auflösung ausdrücklich als Architect-Arbeit, und dieser Slice ist eine. Ob er sie
mitnimmt, entscheidet er selbst; die Kürzel-Frage ist die verwandte, nicht dieselbe.
Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
