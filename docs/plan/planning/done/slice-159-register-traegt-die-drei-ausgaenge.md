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

- [x] **Der Kopftext des Registers trägt die drei Ausgänge und die Vorgangs-Beleg-Regel** — als
      geschlossene Menge, nicht als Aufzählung unter anderen; `offen` ist als Normalzustand
      unterhalb der Schwelle ausgewiesen.
- [x] **Jede Zeile ab 3× trägt genau einen der drei Ausgänge**, und die Zeilen darunter tragen
      `offen`. Die Menge der betroffenen Zeilen ist als Kommando ausgewiesen, nicht geschätzt.
- [x] **Die Beleg-Spalte ist gegen die neue Regel geprüft:** je Zeile so viele Belege wie der
      Zähler, jeder die Kennung eines abgeschlossenen Vorgangs — und wo ein Vorkommen keinen
      hatte, steht es benannt statt gezählt.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt.
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
| [`observations.md`](../observations.md) | update | Kopftext und die `Stand`-Spalte |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) liegt in
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
  — **Ausgang: eingetreten**, an fünf Zellen, alle fünf in diesem Slice geräumt: die
  Lauf-Protokolle des Lese-Schritts sind fort. Gemessen über die abgelöste Fassung als
  Tree-Operand,
  `git show 8ca4a28:docs/plan/planning/observations.md | grep -cE 'Der \*\*Lese-Schritt\*\*|Der Lese-Schritt läuft|der Lese-Schritt der nächsten'`
  → **5**, dasselbe Muster auf der heutigen Datei → **0** (keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). **Kein Folge-Slice, weil kein Rest bleibt:**
  [`AGENTS.md`](../../../../AGENTS.md) §3.7 bindet die Zelle, die geschrieben wird; der Bestand
  darunter ist kein Arbeitsauftrag.
- **Der Umbau der Beleg-Spalte ändert einen Zähler-Stand** — *ein Vorgang zählt einmal* kann eine
  Zeile senken, und eine gesenkte Zeile verlässt die Schwelle. — **Ausgang: entfallen** — keine
  Zeile führt denselben Vorgang zweimal, und je Zeile deckt sich die Beleg-Zahl mit dem Zähler:
  `awk -F'|' '/^\| BEO-/ {gsub(/^ +| +$/,"",$6); n=split($6,a,","); z=substr($5,1,index($5,"×")-1)+0; if(n!=z) print $2}' docs/plan/planning/observations.md`
  → **leere Ausgabe**. Kein Zähler bewegt sich durch die neue Regel, also verlässt keine Zeile
  die Schwelle.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die Ziel-Form stand vollständig in zwei Quellen — dem Bedienhinweis der
  Vorlage `observations.template.md` und der Ausgangs-Tabelle in `modul-06-roadmap.md`
  §Das Beobachtungs-Register. Für vier der fünf Zeilen ab 3× stand der Ausgang inhaltlich schon in
  der Zelle und war nur noch als Ausgang zu schreiben.
- **Was ging anders als geplant:** Der Plan sah eine Form-Anpassung. Tragend war die
  Ausgangs-Zuweisung: drei Zeilen standen auf *„Schwelle erreicht, weiter offen"* — ein Zustand,
  den die neue Fassung ausdrücklich verbietet —, und zwei davon sagten selbst, warum sie keinen
  Ausgang tragen: ihr Ausgang ist ein Slice-Schnitt, und die schließende Rolle durfte keinen
  machen. Eine davon brauchte darum eine neue Datei statt einer Umformulierung.
- **Steering-Loop-Eintrag:** Regel geschärft: *Der Lese-Schritt gehört in die Rolle, die seinen
  Ausgang schreiben darf* — ein Eintrag ohne Ausgang wird sonst von Closure zu Closure vererbt,
  ohne dass jemand ihn ablehnt. Auslöser: `BEO-022` (slice-157, slice-167 — 2×).
  *Gezählt, nicht verkörpert:* die Schwelle ist nicht erreicht, also entfällt das Feld `liegt in`.
- **Beobachtungs-Register (`../observations.md`):** neue `BEO-022` angelegt (`*` (gesamtes Repo),
  2×, Belege slice-157 und slice-167); `BEO-009` auf **5×** erhöht, Beleg slice-159 ergänzt — der
  Kopftext dieses Registers führt jetzt die Vorgangs-Beleg-Regel, während
  [`implement-slice.md`](../../../../.claude/commands/implement-slice.md) daneben die abgelöste
  Slice-Form behauptet, in beiden Fassungen. Die Ausgänge der fünf Zeilen ab 3× stehen in ihren
  Zellen: `BEO-001` und `BEO-003` *verkörpert*, `BEO-007`, `BEO-009` und `BEO-014` *geplant*.
- **Folge-Slices:** [slice-168](../open/slice-168-adaptions-eintraege-trennen-abweichung-von-buchfuehrung.md)
  (Die Adaptions-Einträge trennen Abweichung von Buchführung) — ist eine Datei in `open/` und der
  *geplant*-Ausgang von `BEO-014`; **kein** Mitglied von [welle-14](../welle-14-re-baseline.md),
  deren §6 den Adaptions-Block ausschließt.
- **Risiken aus §6:** zwei, je genau ein Ausgang — *eingetreten, im Slice geräumt* (Chronik in der
  `Stand`-Zelle, fünf Zellen) · *entfallen, mit Messung* (kein Zähler bewegt sich).
- **Drei Paarungen** (geprüft **nach** dem `git mv` nach `done/`): (a) **Anker** — kein Eintrag
  trägt das Feld `liegt in`, also kein Gegenstand; die drei Treffer von
  `grep -n 'liegt in' docs/plan/planning/done/slice-159-*.md` sind Trigger-Prosa aus §4 und zwei
  Nennungen des Feldnamens in Backticks. (b) **Folge-Slice** — `slice-168` ist eine Datei im
  Planning-Lifecycle (`ls docs/plan/planning/*/slice-168-*.md` → `open/`). (c) **Register** — jede
  Zeile trägt mindestens einen Beleg
  (`awk -F'|' 'NR>1 && /^\| BEO-/ {if ($6 !~ /slice-/) print $2}' docs/plan/planning/observations.md`
  → leer), und jede in `done/` zitierte Kennung hat eine Zeile
  (`for b in $(grep -rhoE 'BEO-[0-9]{3}' docs/plan/planning/done/ | sort -u); do grep -q "^| $b " docs/plan/planning/observations.md || echo "FEHLT: $b"; done`
  → leer).

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
[slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) verbucht. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
