# Slice slice-158: Der Archivierungs-Schritt der Wellen-Closure — Entscheidung und Sechs-Schritte-Form

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
(die emittierten Anweisungssätze nennen die Schritt-Zahl),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (wer die
Command-Artefakte schreiben darf).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ob und ab wann Modul 6 Schritt 4 — *Zeitdokumente der Welle archivieren* — in diesem Repo läuft,
ist entschieden und belegt; und wo heute *fünf* Closure-Schritte stehen, stehen sechs.**

Die neue Fassung schiebt der Wellen-Closure einen Schritt ein: Slice-Dateien, Welle-Plan und
Review-Reports wandern nach `done/<welle-id>/archiv.zip`, an ihrer Stelle bleiben gekürzte Stubs
(zwei neue Vorlagen), die Ergebnisnotiz bleibt vollständig und flach. Gemessen ist der Bruch, den
das erzeugt: die Anweisungssätze dieses Repos und die emittierten führen beide *„fünf Schritte"*
(`grep -c 'fünf' .claude/commands/close-welle.md internal/emit/templates/commands/close-welle.md`;
keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Der Altbestand ist nicht Gegenstand** — [welle-14](../welle-14-re-baseline.md) §6 schließt ihn
aus, und die Ziel-Fassung stellt ihn selbst frei.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die Entscheidung steht mit Beleg:** ab welcher Welle Schritt 4 hier läuft — oder dass er
      als benannte Abweichung nicht läuft (`MR-<NNN>`). Dazu die Vorbedingung, die die Quelle
      selbst nennt: der **Geltungsbereich der vorhandenen Sensoren** ist gegen `done/*.md` geprüft,
      damit kein Sensor über den Stubs grün bleibt, ohne noch etwas zu prüfen.
- [ ] **Sechs statt fünf:** die Closure-Schritt-Zahl und der Archivierungs-Schritt stehen in den
      Anweisungssätzen — Dogfood **und** emittierte Ebene. Wer sie schreiben darf, ist
      [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md); ist sie bei
      Beginn noch `Proposed`, ist das der Blocker aus §4 und keine stille Ausnahme.
- [ ] **Die zwei Stub-Vorlagen sind erreichbar** — `archiv-stub-slice` und `archiv-stub-welle`
      sind wiederkehrende Artefakte und entstehen per `cp` aus dem vendored Baum
      ([`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline));
      dass das gilt, ist belegt, nicht angenommen.
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
| [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update | führt heute fünf Schritte |
| `internal/emit/templates/commands/close-welle.md` | update | dieselbe Aussage auf der emittierten Ebene |
| `harness/conventions.md` | update | falls die Antwort ein `MR-<NNN>` ist — Architect, eigener Commit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`) — **zwei Bedingungen, beide vor dem Beginn prüfbar:**

1. [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) liegt in `done/` — die Quelle, gegen
   die die Form gemessen wird, ist die adoptierte.
2. **Eine Vorbedingung außerhalb dieses Slice, kein Liefer-Punkt:**
   [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) trägt
   `**Status:** Accepted`
   (`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`
   → **1**). Träger ist
   [slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md). Vorher steht
   nicht fest, wer die zwei Anweisungssätze schreiben darf, die DoD 2 anfasst — und ein Lauf, der
   sie ohne diese Antwort ändert, ist genau der Vorgang, den [`BEO-007`](../observations.md) zählt.
   Der Slice liegt darum in `open/`, nicht in `next/`; dieselbe Platzierung aus demselben Grund
   trägt [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Sensor-Geltungsbereich mehr
  als eine Nachziehung verlangt — dann trägt die Sensor-Hälfte ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Reviewer-Durchgang aus
  [slice-145](../done/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) nicht annimmt und
  das Eigentum an den Command-Artefakten offen bleibt ([`BEO-007`](../observations.md)).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; kein Anweisungssatz nennt mehr eine Schritt-Zahl, die die adoptierte Fassung
nicht führt; Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Sensor auf `done/*.md` bleibt über den Stubs grün, ohne noch etwas zu prüfen** — die
  Quelle nennt diese Vorbedingung selbst; ungeprüft ist sie ein stilles Grün. — **Ausgang:**
  offen, wird bei Closure verbucht.
- **Der Slice hängt an einer `Proposed`-ADR** — wer die Command-Artefakte schreiben darf, ist
  `BEO-007` im [Register](../observations.md), und die Zeile schließt erst, wenn alle drei
  Hälften eine angenommene Quelle haben. — **Ausgang:** offen, wird bei Closure verbucht.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der Planning-Lifecycle
und die Command-Artefakte liegen in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).

**Vorgelagert — offene Beobachtungen sichten:** `BEO-007` (Command-Eigentum) steht als Risiko in
§6; `BEO-009` (ein Fix ändert die Ableitung und lässt die Zusage stehen) trifft die
Schritt-Zahl-Aussage und ist der Grund für DoD 2. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
