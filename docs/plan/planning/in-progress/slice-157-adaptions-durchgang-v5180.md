# Slice slice-157: Adaptions-Durchgang gegen `v5.18.0` — Delta **und** Volltext

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](../welle-14-re-baseline.md).

**Bezug:** [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 4: jeder
Eintrag bekommt seinen Ausgang **einzeln, mit eigenem Beleg**),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Jeder Eintrag des Adaptions-Blocks trägt einen der fünf Ausgänge gegen `v5.18.0`, mit eigenem
Beleg — und der Durchgang hält jeden Eintrag gegen den *Volltext* des Zielstands, nicht nur gegen
das Delta.** Die Volltext-Hälfte ist die Auflage aus `BEO-013` ([Register](../observations.md)):
ein Delta-Durchgang findet eine Deckung nicht, die ein Volltext-Durchgang fände, und die
Fehlerrichtung ist *bleibt gültig* statt *gegenstandslos*.

Der Katalog in [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9 nennt vier
Positionen, die hier zusammenlaufen: die `MR-<NNN>`-Glossarzeile, der umbenannte Abschnitt
§Referenz-Implementierung → §Das vollständige Artefakt-Set (er trägt die von
[`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
ersetzte Regel und den von
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
zitierten Anker), die Mount-Freistellung des Gate-Fragments
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) und
der Wegfall des `Status:`-Feldes in der Eintrags-Vorlage
([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Inventar gegen Abdeckung:** die Bezugsmenge ist als Kommando ausgewiesen, und **jeder**
      Eintrag darin trägt genau einen der fünf Ausgänge mit eigenem Beleg. Keine Pauschale.
- [ ] **Volltext-Hälfte belegt:** je Eintrag ist nicht nur das Delta, sondern der Zielstand-Text
      der ersetzten Regel gelesen; die vier Katalog-Positionen oben sind namentlich verbucht.
- [ ] **Übergabe an den Architect benannt:** die Positionen, die keine `MR`-Antwort haben,
      sondern eine Hard-Rule-Nachbarschaft — die Push-Disziplin aus `grundlagen-traceability.md`
      (*„Beide Commits gehören in denselben Push"*) neben
      [`AGENTS.md`](../../../../AGENTS.md) §3.3 — stehen als Übergabe im Plan, nicht als
      Entscheidung.
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
| dieser Plan, §9 | update | trägt das Durchgangs-Protokoll je Eintrag |
| `harness/conventions.md` | update | die Ausgänge — Architect, eigener Commit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) liegt in
`done/` — der Ist-Maßstab ist `v5.18.0`, und die Trennung *Prozedur ≠ Ist-Maßstab*
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2) ist damit
aufgelöst.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Volltext-Hälfte über die
  Bezugsmenge hinaus nicht in einem Lauf zu tragen ist — dann wird der Durchgang nach
  Eintrags-Bereichen geteilt.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Eintrag nur mit einer Entscheidung
  auflösbar ist, die eine eigene ADR verlangt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; jeder Eintrag der ausgewiesenen Bezugsmenge trägt einen Ausgang; Closure-Notiz
mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Achse 1 wird mit dem Kurzschluss beantwortet** — *„die Baseline behandelt jetzt dasselbe
  Thema"* statt *„der neue Text erfüllt genau die Pflicht, für die der Eintrag entstand"*; die
  Klasse liegt als `BEO-008` im [Register](../observations.md). — **Ausgang:** offen, wird bei
  Closure verbucht.
- **Der Delta-Durchgang findet eine Deckung nicht** — `BEO-013`, die Auflage dieses Slice.
  — **Ausgang:** offen, wird bei Closure verbucht.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der Adaptions-Block
spricht über den ganzen Baum, und die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt für ihn keine engere.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-008` und `BEO-013` stehen als Risiken in §6;
`BEO-014` (Buchführungs-Anteil des Blocks) berührt den Gegenstand, ist aber per
[welle-14](../welle-14-re-baseline.md) §6 ausgeschlossen. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
