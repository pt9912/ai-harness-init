# Slice slice-159: Das Beobachtungs-Register trägt die Ziel-Form — drei Ausgänge und die Vorgangs-Beleg-Regel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(die Belege sind Zahlen mit Kommando),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(dieses Repo führt Wellen **und** wellenlose Slices — der Zähler hängt am Slice).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**[`observations.md`](../observations.md) führt die drei Ausgänge — *verkörpert · geplant ·
gestrichen* — als geschlossene Menge und die generalisierte Beleg-Regel, und jede Zeile ab 3×
trägt genau einen der drei.**

Die Ziel-Fassung ändert drei Dinge an diesem Register: der Beleg ist die Kennung eines
abgeschlossenen **Vorgangs** (Regelfall Slice, auch Welle und Review-Report) statt allein
`slice-<NNN>`; **ein Vorgang zählt einmal** (zwei Funde im selben Slice sind eine Gelegenheit,
kein zweites Auftreten, und ein Vorkommen ohne abgeschlossenen Vorgang ist *benannt, nicht
gezählt*); und ab 3× ist der Stand einer von drei Ausgängen, wobei `offen` unterhalb der Schwelle
der Normalzustand und **kein** Ausgang ist.

Das ist die zweite Ursachen-Klasse aus `BEO-010` ([Register](../observations.md)) — ein
Singleton-Artefakt, dessen Form-Pflicht in
[welle-10](../done/welle-10-re-baseline.md) einzeln als Nachzügler zurückkam. Hier steht sie im
Schnitt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Der Kopftext des Registers trägt die drei Ausgänge und die Vorgangs-Beleg-Regel** — als
      geschlossene Menge, nicht als Aufzählung unter anderen; `offen` ist als Normalzustand
      unterhalb der Schwelle ausgewiesen.
- [ ] **Jede Zeile ab 3× trägt genau einen der drei Ausgänge**, und die Zeilen darunter tragen
      `offen`. Die Menge der betroffenen Zeilen ist als Kommando ausgewiesen, nicht geschätzt.
- [ ] **Die Beleg-Spalte ist gegen die neue Regel geprüft:** je Zeile so viele Belege wie der
      Zähler, jeder die Kennung eines abgeschlossenen Vorgangs — und wo ein Vorkommen keinen
      hatte, steht es benannt statt gezählt.
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
| [`observations.md`](../observations.md) | update | Kopftext und die `Stand`-Spalte |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](slice-156-baum-tauschen-pins-ziehen.md) liegt in
`done/` — die Ziel-Form ist dann die adoptierte, und die Änderung misst gegen den Ist-Maßstab.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Prüfung der Beleg-Spalte je
  Zeile ein Urteil über die Vorgangs-Zugehörigkeit verlangt, das über einen Lauf hinausgeht —
  dann wird die Zeilen-Prüfung ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn eine Zeile ab 3× keinen der drei Ausgänge
  tragen kann, ohne eine Norm-Entscheidung vorwegzunehmen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; keine `Stand`-Zelle trägt Freitext, wo die geschlossene Menge gilt; Closure-Notiz
mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die `Stand`-Zelle trägt Chronik statt Zustand** — [`AGENTS.md`](../../../../AGENTS.md) §3.7
  bindet die Zustandsfelder lebender Register, und die drei Ausgänge sind genau eine
  Zustands-Aussage. Die heutigen Zellen tragen zum Teil ausgeschriebene Herleitung.
  — **Ausgang:** offen, wird bei Closure verbucht.
- **Der Umbau der Beleg-Spalte ändert einen Zähler-Stand** — *ein Vorgang zählt einmal* kann eine
  Zeile senken, und eine gesenkte Zeile verlässt die Schwelle. — **Ausgang:** offen, wird bei
  Closure verbucht.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — das Register führt
selbst nur diesen Namen, und genau das ist `BEO-004`.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-004` (die Sub-Area-Spalte unterscheidet
nichts) berührt den Gegenstand unmittelbar, ihre Auflösung ist Architect-Arbeit und **nicht**
Gegenstand hier; `BEO-010` trägt den Zuschnitt und ist in
[slice-155](../in-progress/slice-155-inventur-vor-dem-schnitt.md) verbucht. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
