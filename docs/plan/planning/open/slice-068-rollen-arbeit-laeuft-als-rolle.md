# Slice slice-068: Rollen-Arbeit läuft als Rolle — und was am Haupt-Kontext unmessbar bleibt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — er berührt die **Welle-Aussage**
selbst (die 4 × 2-Matrix), nicht nur einen Slice.

**Bezug:** [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
(die Start-Konvention, die hier vollständig wird),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1 Punkt 5
regelt, wie Nicht-Erreichbares dokumentiert wird, und warnt im selben Atemzug, dass eine
deklarierte Abweichung *„billiger zu schreiben als eine Lösung und deshalb verdächtig"* ist).
Regelwerk-Quelle: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md`
§Token-Attributions-Regeln sowie `modul-08-agentenrollen.md` §Rollen-Regeln.

**Bewusst KEINE `LH-*`-Kennung.** Geprüft: keine der zwölf Anforderungen trifft die
Dogfood-Prozessebene. Die naheliegende
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) verlangt
*„jeder **emittierte** Gate-Target läuft auf frischem Checkout"* — die emittierte Ebene, nicht
diese; sie hier zu führen war schon in slice-059 ein Befund. Die `requirement`-Achse dieses Slice
bleibt deshalb **leer und erkennbar** statt gefüllt und falsch.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-30.

---

## 1. Ziel

**Die Konvention sagt, WAS als Rolle läuft — nicht nur, WIE.**
[slice-060](../in-progress/slice-060-rollen-achse.md) regelt die Betriebsart eines Rollen-Laufs
(@-Erwähnung, Vordergrund, `PreToolUse`-Guard). Was fehlt, ist der Satz davor: dass Rollen-Arbeit
überhaupt unter einem Rollen-Typ läuft. Ohne ihn erzwingt der Guard den Vordergrund für Rollen,
die man startet — und schweigt, wenn man den Reviewer gar nicht startet, sondern selbst reviewt.

**Und er sagt, was dabei unmessbar bleibt.** Modul 15 §Token-Attributions-Regeln unterstellt, der
Sammelposten sei die **Ausnahme**. In diesem Repo ist er die **Regel**, aus zwei gemessenen
Gründen: der Haupt-Kontext wird von keinem `Agent`-Aufruf umschlossen (kein `agentType`), und
**seine Token stehen in keiner Payload** — die `usage`-Zähler kommen aus der `tool_response` eines
`Agent`-Aufrufs, und wo kein Aufruf ist, ist kein Zähler. Selbst mit gelöster Rollen-Ableitung
(slice-060 Frage C) bekäme der Haupt-Kontext ein Etikett, aber keine Zahl.

**Warum ein eigener Slice und nicht ein Zusatz zu slice-060:** die Aussage betrifft die
**Welle-Ebene**. welle-09 verlangt je Zelle ihrer Matrix *„entweder einen laufenden Sensor oder
eine deklarierte Entscheidung mit Auflösungs-Trigger, und nichts dazwischen"*. Für die Zelle
*Token-Attribution × Repo* ist heute genau **dazwischen**: die Achse ist füllbar, ohne dass
jemand sie füllen muss.

## 2. Definition of Done

- [ ] **(1) Die Konvention steht in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung),
  und ihre Grenze steht daneben.** Wortlaut-Kern: Arbeit, die einer Harness-Rolle zugeordnet ist,
  läuft **unter dem Rollen-Typ**; der Haupt-Kontext orchestriert und ist der Sammelposten.
  **Die Grenze gehört in denselben Absatz:** eine mechanische Durchsetzung ist **nicht möglich**,
  weil niemand maschinell entscheiden kann, ob eine Haupt-Kontext-Handlung „Planner-Arbeit" war.
  Ein Guard wie der aus slice-060 DoD (1) kann hier also nicht entstehen — und das ist zu
  **sagen**, nicht durch Schweigen offenzulassen.
- [ ] **(2) Die Nicht-Erreichbarkeit der Haupt-Kontext-Token steht als erklärte Abweichung — mit
  Auflösungs-Trigger, und NACH der Prüfung.**
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5 verlangt genau
  diese Reihenfolge und nennt die bequeme Abkürzung beim Namen. Die Prüfung ist zu **zeigen**,
  nicht zu behaupten: (a) die Zähler liegen ausschließlich in `tool_response` — gemessen,
  slice-060 §3; (b) Transkripte sind als Quelle ausgeschlossen (Nutzer-Entscheidung, kein Zugriff
  außerhalb des Repos); (c) `SubagentStart` zählt Spawns, trägt aber keine Token. Erst danach die
  Abweichung. **Auflösungs-Trigger:** eine Quelle innerhalb des Repos, die Haupt-Kontext-Token
  trägt.
- [ ] **(3) Der Sensor ist eine Berichtsgröße, und die Welle-Matrix sagt das.** Der
  Sammelposten-Anteil aus [slice-066](slice-066-telemetrie-auswertung.md) DoD (1) ist die
  Messgröße dafür, ob die Konvention gelebt wird: groß heißt „nicht gelebt". Die Zelle
  *Token-Attribution × Repo* in [welle-09](../welle-09-modul-15-konformitaet.md) trägt danach
  **deklarierte Entscheidung mit Trigger**, nicht „Sensor" — ein Bericht ist kein Wächter, und die
  Matrix darf ihn nicht als einen ausweisen.
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | die Konvention aus DoD (1) und die Abweichung aus DoD (2) in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) — dieselbe Sektion, in die slice-060 die Start-Konvention schreibt |
| [`welle-09`](../welle-09-modul-15-konformitaet.md) | update | die Matrix-Zelle *Token-Attribution × Repo* auf „deklarierte Entscheidung mit Trigger" |
| [`slice-066`](slice-066-telemetrie-auswertung.md) | update | die Lesart des Sammelposten-Anteils als Konventions-Messgröße; der **Zahn** dazu bleibt dort, wo die Zahl entsteht |

**Kein Code, kein neuer Wächter.** Das ist beabsichtigt und der Grund steht in §6.

## 4. Trigger

**`open` → `next`:** [slice-060](../in-progress/slice-060-rollen-achse.md) ist **done** — er
schreibt die Start-Konvention in dieselbe
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)-Sektion, und zwei gleichzeitige Änderungen
daran erzeugen vermeidbare Konflikte.

**`next` → `in-progress`:** WIP-Limit.

Rückführungen:

- `in-progress` → `next`: falls sich beim Schreiben zeigt, dass die Konvention ohne Frage C
  (Rollen-Ableitung für den Haupt-Kontext) unvollständig bleibt. Dann ist Frage C zuerst zu
  entscheiden und dieser Slice neu zu schneiden.
- `in-progress` → `open`: falls eine Quelle *innerhalb* des Repos auftaucht, die
  Haupt-Kontext-Token trägt. Dann ist DoD (2) keine Abweichung mehr, sondern ein Sensor — und der
  Slice hat einen anderen Gegenstand.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün;
`git mv` nach `done/` (eigener Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein Slice ohne Zahn ist in diesem Repo ein Geruch.** Hier ist er begründet: der Gegenstand
  *ist* eine Aussage darüber, was messbar ist und was nicht. Ein Wächter, der eine
  Unmessbarkeit bewacht, wäre die Zusage-ohne-Abdeckung, gegen die
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 steht. Der Zahn liegt deshalb bei
  [slice-066](slice-066-telemetrie-auswertung.md): fällt der Sammelposten-Anteil aus dem Bericht,
  muss ein Fall rot werden.
- **Eine Konvention ohne Durchsetzung wird gebrochen — auch von mir.** Belegt am Tag des
  Schnitts: die Arbeit an slice-060 lief zu großen Teilen im Haupt-Kontext, also Planner und
  Implementation in **einem** Kontextfenster — genau das, was Modul 8 §Rollen-Regeln ausschließt
  (*„aber nicht im selben Kontextfenster, sonst wiederholen sich die blinden Flecken"*). Der
  Sammelposten-Anteil macht das sichtbar; er verhindert es nicht.
- **Eine Schwelle verführt zum Zielwert.** Wird der Sammelposten-Anteil zur Kennzahl mit Grenze,
  entsteht der Anreiz, Arbeit zu verlagern, damit die Zahl stimmt — statt weil die Rollen-Trennung
  trägt. Deshalb verlangt DoD (3) die **Größe im Bericht**, keine bestandene/nicht-bestandene
  Schwelle.
- **Die Abweichung ist die bequeme Hälfte.** [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) sagt es selbst; DoD (2) hält deshalb die
  Reihenfolge fest, statt sie zu versprechen.
- **Nicht in diesem Slice:** Frage C (Rollen-Ableitung für den Haupt-Kontext, slice-060 §3) und
  die emittierte Ebene (slice-062/063). Ob die Konvention ins Ziel-Repo mitgeht, ist eine
  slice-062-Entscheidung.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und
`docs/plan/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
