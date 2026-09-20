# Slice slice-fall-anlage-misst-gegen-den-quell-bestand: Die Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als
diese DoD — der MR-Eintrag und der Register-Ausgang sind Belege der
Liefer-Punkte selbst.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (mutate meldet jeden gelisteten
Wächter, der seine Zähne verloren hat) und §3.8 (der Architect schreibt die
Norm-Artefakte; eigener Commit, nur Architect-Artefakte),
[`ADR-0060`](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)
(die berechtigten Re-Schnitte, die die Zähne entwaffneten),
[Verifikations-Report](../../../../docs/reviews/2026-09-19-slice-mutations-faelle-pruefen-ihre-ziel-stellen-verifikation.md)
§Die Verkörperungs-Frage (F-1, MEDIUM — der Ausgang löste ins Leere),
Register-Beobachtung
[`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
(5×, Ausgang *geplant* auf diese Kennung).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Architect (pt9912)

**Autor:** Planner. **Datum:** 2026-09-20.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten.

**Ziel:** Die 5×-Regel des Register-Eintrags
`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` — „die
Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand, nicht gegen die
Fassung der letzten Fassung" — wird verkörpert: Der Architect schreibt den
`MR`-Eintrag im Adaptions-Block (§3.8-Form — eigener Commit, nur
Architect-Artefakte, Rolle in der Message), und der Register-Ausgang dreht
auf *verkörpert* mit Zielort und Herkunfts-Anker
`seit slice-fall-anlage-misst-gegen-den-quell-bestand`. Der Vorgänger-Slice
(`slice-mutations-faelle-pruefen-ihre-ziel-stellen`) heilte die drei
Instanzen, nicht die Regel — dieser Slice ist der Architektur-Zug der
Closure (Planner → Architect → Planner).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein neues Werkzeug** — **Schicht-Abgrenzung:** die Regel verkörpert die
  Anlage-Form; ein Sensor für Fall-Anlagen wäre ein eigener Vorgang mit
  eigener Bedarf-Entscheidung.
- **Keine Umung der drei geheilten Zähne** — **Bestand bleibt bewusst
  stehen:** die Zähne stehen, wie der Vorgänger sie lieferte.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**.

- [x] **Liefer-Punkt 1 — der `MR`-Eintrag steht:** der Architect schreibt den
      Eintrag im Adaptions-Block (Index-Zeile, Datei unter
      `harness/conventions/`, §3.8-Form — eigener Commit, nur
      Architect-Artefakte, Rolle in der Message); er trägt die Regel, ihre
      Grenze und den Herkunfts-Anker
      `seit slice-fall-anlage-misst-gegen-den-quell-bestand`. Rote
      Gegenprobe: trägt der Eintrag keinen Herkunfts-Anker, färbt
      `make docs-check` (Modul-Deckung der Konvention-Regeln) rot — Grenze:
      die Anker-Form prüft kein Sensor, das Review prüft sie.
- [x] **Liefer-Punkt 2 — der Register-Ausgang dreht auf *verkörpert*:**
      `state.md` trägt den Zielort und den Herkunfts-Anker auf einer Zeile
      (`liegt in <MR>`-Form, Anker-Paarung a). Rot: fehlt der Zielort oder der
      Anker in der Datei, bricht die Paarung — die Prüfung ist die
      Anker-Paarung der Closure, kein eigener Sensor.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — oder
      „keine Beobachtung angefallen" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind
      getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/conventions/MR-<NNN>-….md` | neu | der MR-Eintrag — der Architect schreibt ihn (§3.8) |
| `harness/conventions.md` | update | die Index-Zeile des Eintrags |
| `docs/plan/planning/observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/state.md` | update | Ausgang dreht auf *verkörpert* (Zielort + Anker) |

## 4. Trigger

**Start** (`next` → `in-progress`): Architect übernimmt, WIP-Limit frei.

**Rückführungen:** zu groß → `next`, wenn die Regel über die Anlage hinaus
wächst; blockiert → `open`, falls der Adaptions-Block eine andere Form
verlangt.

## 5. Closure-Trigger

DoD belegt und der Register-Ausgang trägt *verkörpert* mit Zielort und
Anker — die Anker-Paarung der Register-Seite löst auf.

## 6. Risiken und offene Punkte

- **Die MR-Form trägt die Grenze, die die Regel nicht löst** — ein
  MR-Eintrag ist Deklaration, kein Sensor; die Anlage-Form wird vom Lauf
  gehalten, der sie schreibt, und vom Review danach. — **Ausgang:** *weiter
  offen* → die Grenze trägt
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  selbst („kein Sensor hält die Anlage"); die Sichtung liest sie bei der
  nächsten Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** der Architektur-Zug der Closure lief in einem
  eigenen Kontext und einem eigenen Commit — [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  trägt die Regel, den Geltungsbereich (die Anlage neuer Mutations-Fälle,
  der `sed`-Anker je Fall gegen den Quell-Bestand), die drei Fundmengen, die
  Grenze und die Auflösungs-Trigger, und keine Kopf-Marke.
- **Was ging anders als geplant:** die Lifecycle-Claims des Slices waren
  zweigelokal — der Architektur-Lauf schrieb `MR-071`, ohne den
  `open → in-progress`-Move zu tragen; die Claims wurden nachgeholt
  (Verantwortlich: Architect, die zwei Moves), bevor die Closure lief. Die
  Herkunfts-Anker-Form trägt `MR-071` in der MR-Form — das Feld
  „Wirksamkeits-Anlass" nennt den 5×-Übertritt dieses Register-Eintrags
  blank ([`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt));
  die `seit slice-`-Form steht am MR-Zielort nicht.
- **Steering-Loop-Eintrag:** geschärfte Regel für die Fall-Anlage: „die
  Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand, nicht gegen die
  Fassung der letzten Fassung" — verkörpert als
  [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  — liegt in [harness/conventions/MR-071-die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand.md](../../../../harness/conventions/MR-071-die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand.md).
  Herkunft: `seit slice-fall-anlage-misst-gegen-den-quell-bestand`.
- **Beobachtungs-Register (`../observations/`):** keine Beobachtung
  angefallen — der Ausgang von
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` dreht
  auf *verkörpert* (Zählerstand 5×); die Verkörperung ist der Gegenstand
  dieses Slices.
- **Folge-Slices:** keine — die drei Fundmengen sind geheilt (68/71/96 im
  Vorgänger, 29/275/114 im Vor-Vorgänger); die Regel ist verkörpert.
- **Risiken aus §6:** MR-Form-Grenze → *weiter offen* (trägt [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand) selbst).
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist der Adaptions-Block — die
Sub-Area `*` (gesamtes Repo) erfüllt die Schwelle ≥ 2 von 3 (Inventur: ja;
mehrere Dateien: ja; Aussage: ja — die Regel-Zusage). `*` steht in der
Modus-Deklaration als Greenfield.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-20 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**151**). Treffer: der auslösende Eintrag
`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`
(**Zählerstand 5×**, Ausgang *geplant* auf diese Kennung) — er ist der
Gegenstand, nicht eine weitere Berührung; sein Ausgang dreht mit diesem
Slice auf *verkörpert*. Keine weiteren Treffer — notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF; kein BF/Hybrid-Block.