# Slice slice-168: Die Adaptions-Einträge trennen Abweichung von Buchführung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Kein Closure-Kriterium beobachtet mehr, als die DoD
unten belegt (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht). Insbesondere **kein Mitglied von**
[welle-14](../welle-14-re-baseline.md): deren §6 schließt den Adaptions-Block
aus, und der Gegenstand hier ist der **Inhalt** der Einträge, nicht die Form
des Blocks.

**Bezug:** [`BEO-014`](../observations.md) (Schwelle erreicht, dieser Slice ist
ihr Ausgang *geplant*),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)
(die Bezugsmenge ist der Block selbst),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)
(der Block gehört dem Architect).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** `—` bis zur Priorisierung. Geschrieben wird der Block vom
**Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8); der Schnitt ist
Planner-Arbeit, das Verdikt je Eintrag nicht.

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Jeder Eintrag des Adaptions-Blocks, der Buchführung über den Block selbst
beschreibt statt einer Abweichung von einer Baseline-Regel, trägt ein Verdikt:
bleibt · geht in einen anderen Eintrag auf · wird retiriert.**

Sechs Einträge sind dieser Frage einzeln gewidmet —
[`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger),
[`MR-038`](../../../../harness/conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte),
[`MR-043`](../../../../harness/conventions.md#mr-043--ein-nachgetragenes-pflichtfeld-schlägt-die-einordnung-im-rumpf),
[`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form),
[`MR-046`](../../../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht).
Die Bezugsmenge, gegen die sie zu halten sind, ist der Block als ganzer:
`grep -c '^| \[MR-' harness/conventions.md` → **48** Index-Zeilen (Stand
2026-09-03; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die Bezugsmenge ist gemessen, nicht geschätzt:** ein Kommando gibt aus,
      welche Einträge des Blocks Buchführung über den Block beschreiben, und die
      sechs oben sind gegen dieses Ergebnis gehalten — Zugänge und Abgänge
      benannt.
- [ ] **Jeder Eintrag der gemessenen Menge trägt genau ein Verdikt** aus
      *bleibt · geht auf in `MR-<NNN>` · retiriert*, je mit Begründung; ein
      Verdikt ohne Begründung ist keines.
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
| [`harness/conventions/`](../../../../harness/conventions/) | update | die Einträge der gemessenen Menge tragen ihr Verdikt |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | der Index folgt jedem Abgang |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [welle-14](../welle-14-re-baseline.md) liegt
in `done/`. Grund ist ordnend: [slice-161](slice-161-conventions-kopf-traegt-die-ziel-form.md)
bewegt den Kopf derselben Datei, und zwei Läufe auf demselben Artefakt
kollidieren.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die gemessene
  Menge über die sechs hinaus so wächst, dass ein Verdikt je Eintrag nicht in
  einer Review-Sitzung prüfbar ist.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Verdikt eine
  Baseline-Regel voraussetzt, die der adoptierte Stand nicht führt — dann ist
  der Ausgang eine ADR, nicht ein Eintrags-Verdikt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; kein Eintrag der gemessenen Menge steht ohne Verdikt;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **„Buchführung über den Block" ist ein Urteil, kein Muster** — ein `grep`
  zählte Einträge, nicht Verstöße. Die DoD verlangt trotzdem ein Kommando; es
  liefert die **Kandidaten**, das Verdikt bleibt Lesen.
  — **Ausgang:** offen, wird bei Closure verbucht.
- **Ein Abgang bricht eingehende Verweise** — der Block ist repo-weit
  referenziert, und ein retirierter Eintrag zieht seinen Index-Anker mit.
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
- **Steering-Loop-Eintrag:** <…>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — den
einzigen Namen, den die Modus-Deklaration führt; genau das ist `BEO-004`.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-014` ist der Auslöser
dieses Slice (Schwelle erreicht, Ausgang *geplant* auf diese Datei).
`BEO-020` (ein Auflösungs-Trigger feuert mit der Migration, das Urteil hat
keinen Träger) berührt denselben Gegenstand und steht bei 2× — tritt er hier
erneut auf, erreicht er die Schwelle. `BEO-004` unterscheidet nichts und ist
Architect-Arbeit. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
