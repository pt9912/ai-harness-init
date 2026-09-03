# Slice slice-165: Die stummen `v5.12.0`-Nennungen bekommen ihren Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
(die Setzung, die diesen Durchgang vorschreibt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(die Kopplung Zahl ↔ Kommando, die der Sprung zerreißt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Jede stumme Nennung des abgelösten Tags in einem lebenden repo-eigenen Artefakt trägt genau
einen der drei Ausgänge aus
[`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
— nachgemessen · Tree-Operand · entfallen.**

Stumm heißt: kein Markdown-Link, also kein `target-missing`, also kein Gate. Der Tausch auf
`v5.18.0` ([slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md)) hat den
gate-sichtbaren Teil erledigt und den stummen unberührt gelassen — dort ist die Adresse meist
Operand eines Kommandos, dessen Ergebnis im selben Satz zitiert wird, und ein Pfad-`sed` machte aus
einem lauten Fehler einen stummen.

**Der Bestand ist gemessen, nicht geschätzt** — beim Lauf neu zu erheben, die Zahl wandert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
git grep -n 'v5\.12\.0' -- ':!.harness/baseline' ':!docs/reviews' \
  ':!docs/plan/planning/done' ':!docs/plan/adr' | grep -vc ']('   # 2026-09-03: 152
```

**Zwei Teilmengen liegen ausdrücklich außerhalb:** die **88** Treffer in
[`harness/conventions.md`](../../../../harness/conventions.md) (dieselbe Zählung, auf die Datei
eingeschränkt) sind Adaptions-Block und damit Architect
([`AGENTS.md`](../../../../AGENTS.md) §3.8) — sie trägt
[slice-157](../in-progress/slice-157-adaptions-durchgang-v5180.md). Und die **eingefrorenen** ADRs bleiben
unangetastet: [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
§Geltungsbereich schließt `docs/plan/adr/` selbst aus.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Jeder Treffer der Restmenge trägt einen der drei Ausgänge**, je Treffer entschieden und
      am Fundort begründet, wo der Ausgang *Tree-Operand* oder *entfallen* ist. Ein pauschales
      „alle gezogen" erfüllt den Punkt nicht.
- [ ] **Keine Zahl ist mitgewandert:** wo der Ausgang *nachgemessen* lautet, ist das Kommando
      gegen den neuen Baum gefahren und die **Folgerung** gezogen, nicht die Ziffer gerundet.
      Belegt an mindestens einem Treffer, dessen Ergebnis sich bewegt hat — findet der Lauf
      keinen, ist **das** der Befund und steht in §7.
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
| lebende Plan- und Welle-Dateien unter `docs/plan/planning/` | update | die Mehrzahl der Treffer |
| [`AGENTS.md`](../../../../AGENTS.md) | update | Mess-Stände in §3.7 — Hard Rule, also Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), eigener Commit |
| `internal/emit/templates.go`, `internal/emit/templates_test.go` | update | Kommentare mit einer Aussage über den vendored Satz ([`AGENTS.md`](../../../../AGENTS.md) §3.7) |
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md), [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md), [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update | je eine Handvoll Treffer, verschiedene Ausgänge |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md)
liegt in `done/` — vorher gibt es keinen neuen Baum, gegen den nachgemessen würde.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Restmenge nicht in einer
  Review-Sitzung prüfbar ist — dann wird nach Artefakt-Klasse geteilt (Plan-Dateien / Go-Kommentare
  / Anweisungssätze).
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Treffer eine Aussage trägt, deren
  Nachmessung eine Entscheidung verlangt, die einer anderen Rolle gehört.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die Restmenge ist mit dem Kommando aus §1 neu erhoben und je Treffer verbucht;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Durchgang zieht den Tag und lässt die Zahl stehen** — genau der Fehler, gegen den
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  steht, und kein Gate sieht ihn. — **Ausgang:** offen, wird bei Closure verbucht.
- **Ein Teil der Treffer gehört dem Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.7/§3.8),
  und ein Planner- oder Implementer-Lauf schreibt sie im Vorbeigehen mit. — **Ausgang:** offen,
  wird bei Closure verbucht.

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
- **Beobachtungs-Register (`../observations.md`):** <…>
- **Folge-Slices:** <…>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die Modus-Deklaration
in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt keine engere, und die Treffer liegen quer über den Baum.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-009` (*Fix ändert die Ableitung, die Zusage
daneben bleibt stehen*, Schwelle erreicht) trägt genau die Unterklasse, die dieser Slice abarbeitet
— ihre Stand-Zelle nennt *„Präsens-Satz über den vendored Baum"* ausdrücklich als offen und
sensorlos. `BEO-015` (*Zahl steht neben einem nie gefahrenen Kommando*) bindet die Arbeitsweise
dieses Durchgangs. Zähler-Stände siehe [Register](../observations.md). Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
