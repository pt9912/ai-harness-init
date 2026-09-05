# Slice slice-189: Die abgeschaffte Beobachtungs-Kennung zieht in den Architect-Artefakten nach

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Baseline-Test ist das *Mehr*
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): eine beobachtbare Closure-Bedingung, die
mehr beobachtet als die DoD unten. Es gibt keine — und **kein Mitglied von**
[welle-15](../welle-15-re-baseline.md): Deren Ziel verlangt für jede Pflicht des Sprungs einen
*verbuchten Ausgang*, keinen Vollzug, und diese Datei in `open/` **ist** er. Das unterscheidet
diesen Slice von
[slice-186](../in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md), dessen Nachzug
ohne ihn mit dem Umzugs-Commit schon gebrochen dastand.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die
abgeschaffte Kennungs-Form kommt aus dem auf einen Tag gepinnten Baum),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die entschiedene Kennungs-Gestalt `BEO-<KUERZEL>/<slug>`, Festlegung 3),
[`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) (dort steht die
eine Hälfte der Vorkommen),
[`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline),
[`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr),
[`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
(die andere).

**Berührte Spec-Stellen:** `—`. Der Slice zieht Kennungs-Zitate nach; er schreibt keine
Spec-Stelle.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine). Beide Liefer-Punkte liegen in
**Architect**-Artefakten: der Adaptions-Block nach
[`AGENTS.md`](../../../../AGENTS.md) §3.8, die ADR nach `modul-08-agentenrollen.md`
§Rollen-Regeln (*„ADR-Änderung: Architect schreibt"* — status-unabhängig; `Accepted` fügt nur
hinzu, dass sie niemand überschreibt).

**Autor:** Planner. **Datum:** 2026-09-05.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Die Zitate der abgeschafften `BEO-<NNN>`-Form, die
[slice-186](../in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) als Übergabe an
den Architect ausgenommen hat, nennen die entschiedene Pfad-Form `BEO-ALL/<slug>`.**

Jener Slice hat jedes lebende Zitat gezogen, das ihm gehörte, und vier Ausnahmen benannt. Zwei
davon sind **nicht dauerhaft**, sondern ein Rollenwechsel: Sie liegen in Artefakten, die einer
anderen Rolle gehören. Dieser Slice ist das Artefakt, das den Rollenwechsel trägt — ohne ihn
bliebe die Übergabe eine Zeile in einer Closure-Notiz, die mit ihrem `git mv` nach `done/`
Chronik wird ([`AGENTS.md`](../../../../AGENTS.md) §3.7).

**Dieser Plan führt selbst keine dreistellige Nummer**, aus demselben Grund wie sein Vorgänger: Er
liegt in der Bezugsmenge, die die Form abschafft, und ein Beispiel im Fließtext erhöhte die Zahl,
die die DoD auf null bringen soll. Wo der Text die abgeschaffte Gestalt zeigen muss, zeigt er sie
als Platzhalter `BEO-<NNN>`.

**Der Bestand ist gemessen, nicht geschätzt** (2026-09-05):

```sh
git grep -o 'BEO-[0-9][0-9][0-9]' -- 'docs/plan/adr/0029-*.md' 'harness/conventions/' | wc -l   # 6
git grep -c 'BEO-[0-9][0-9][0-9]' -- 'docs/plan/adr/0029-*.md' 'harness/conventions/'
#   3 in ADR-0029, je 1 in MR-041, MR-047, MR-048
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide Zahlen fallen mit dem Vollzug auf null.

**Die Abbildung ist bekannt und nicht zu raten.** Die Vorkommen in der ADR meinen
[`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md),
die im Adaptions-Block
[`BEO-ALL/adaptions-achse-1-kurzschluss`](../observations/BEO-ALL/adaptions-achse-1-kurzschluss/observation.md)
— abgelesen am Elternstand des Umzugs, der Nummer und Slug in **einem** Pfad trägt
(`git ls-tree -d --name-only 9292a08^ docs/plan/planning/observations/`), und im Adaptions-Block
zusätzlich durch das **Linkziel** bestätigt: dort zeigt der Verweis schon auf
`…/BEO-ALL/adaptions-achse-1-kurzschluss/observation.md`, nur das Label ist stehengeblieben.

**Was dieser Slice ausdrücklich nicht anfasst:**
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) mit ihren
Vorkommen (`git grep -c 'BEO-[0-9][0-9][0-9]' -- 'docs/plan/adr/0028-*.md'` → **9**, kein
Erwartungswert). Sie steht auf `Accepted` und ist nach
[`AGENTS.md`](../../../../AGENTS.md) §3.4 immutabel — eine Korrektur wäre eine Folge-ADR mit
`Supersedes` und damit ein anderer Gegenstand. Sie ist überdies **materiell folgenlos**: Die ADR
pinnt ihre Messung auf einen Mess-Ref, an dem die zitierte Kennung noch auflöst. Dort steht keine
tote Adresse, sondern eine historische Kennung an ihrem gepinnten Ort.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **Die Vorkommen in
      [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) nennen
      `BEO-ALL/anweisungssatz-eigentum-ohne-quelle`** — als Link auf deren eigene
      `observation.md`, wo die Stelle einen Verweis trägt (`observations/README.md` §Zwei
      Verweis-Formen). Die ADR steht auf `Proposed`; der Statuswert macht sie inhaltlich änderbar,
      nicht die Rolle, die sie ändert. Zahl und Fundorte: das zweite Kommando aus §1.
- [ ] **Die Vorkommen in `harness/conventions/` nennen `BEO-ALL/adaptions-achse-1-kurzschluss`**
      — nur das Label wandert, das Linkziel steht schon richtig. Zahl und Fundorte: dasselbe
      Kommando.
- [ ] `make gates` grün.
- [ ] Doku-Update: kein öffentlicher Vertrag berührt — der emittierte Baum führt keine
      `BEO`-Kennung dieses Repos
      (`git grep -o 'BEO-[0-9][0-9][0-9]' -- internal/emit/templates | wc -l` → **0**; die
      `-c`-Form taugt hier nicht, sie schweigt bei null Treffern statt eine Null auszugeben).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

**Die Vollständigkeit ist an einem Kommando ablesbar**, nicht an einer Behauptung: nach beiden
Liefer-Punkten trifft das erste Kommando aus §1 **null**.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) | update | Liefer-Punkt 1; ADR-Änderung ist Architect-Arbeit, unabhängig vom Status |
| [`harness/conventions/`](../../../../harness/conventions/) | update | Liefer-Punkt 2, je ein Label; Adaptions-Block nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 |

**Ein Commit oder zwei, entschieden am Rollen-Zuschnitt und nicht an der Datei-Menge.** Beide
Liefer-Punkte gehören derselben schreibenden Rolle; [`AGENTS.md`](../../../../AGENTS.md) §3.8
verlangt für Hard Rules und Adaptions-Block einen Commit, der *ausschließlich Artefakte derselben
schreibenden Rolle* berührt — ADRs sind darin ausdrücklich mitgenannt. Ein gemeinsamer Commit
erfüllt das.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-186](../in-progress/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) liegt in
`done/`. Der Grund ist **ordnend**, nicht tragend: Die Vorkommen stehen schon heute so da, und der
Nachzug hinge an nichts. Vor jener Closure gäbe es diesen Slice aber nicht — er *ist* ihr
Übergabe-Artefakt, und ein Träger, der vor seiner Übergabe läuft, hat keine.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Nachzug in
  [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) mehr verlangt
  als einen Kennungs-Austausch — etwa weil eine der Stellen eine Aussage über den *Zähler* jener
  Beobachtung trägt, die mit der neuen Form nicht mehr stimmt. Dann trennt der Schnitt den
  Adaptions-Block vom ADR-Text.
- `in-progress` → `open` (blockiert — Carveout?): wenn die ADR zwischen Schnitt und Ausführung auf
  `Accepted` wechselt ([slice-152](slice-152-adr-0029-acceptance-trigger.md) ist ihr
  Acceptance-Trigger). Dann ist sie nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 immutabel und
  ihre Vorkommen wandern in dieselbe dauerhafte Ausnahme wie die von
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) — der Slice
  schrumpft dann auf den Adaptions-Block.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; das erste Kommando aus §1 trifft **null**; `make gates` grün; Closure-Notiz mit
Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Bezugsmenge ist ein `grep` und keine Vollständigkeitsaussage**
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md),
  **7×**, `geplant` —
  `ls docs/plan/planning/observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/evidence | wc -l`,
  kein Erwartungswert). Das Muster findet die dreistellige Zahl; eine Beobachtung, die in einem
  dieser Artefakte nur unter ihrem Prosa-Namen genannt wird, fände es nicht, und **kein Modul der
  [`.d-check.yml`](../../../../.d-check.yml) sieht diese Klasse**. Die Zusage in §2 bindet darum
  an das Kommando und nicht an „alle". — **Ausgang:** offen bis zur Closure.
- **[`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) wechselt vor
  der Ausführung auf `Accepted`** und wird damit immutabel. Der Fall ist nicht hypothetisch:
  [slice-152](slice-152-adr-0029-acceptance-trigger.md) liegt in `open/` und trägt genau diesen
  Übergang. Er ist als Rückführung `in-progress → open` in §4 vorab benannt und kein Blocker,
  sondern eine Halbierung des Umfangs. — **Ausgang:** offen bis zur Closure.
- **Ein Label-Nachzug im Adaptions-Block berührt einen Text, dessen Aussage an der alten Kennung
  hängt**
  ([`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md),
  **13×**, `geplant` — dasselbe Kommando wie oben mit diesem Slug). Die Sätze in
  [`MR-041`](../../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline),
  [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)
  und
  [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
  sprechen über das, *was* die Beobachtung führt; wer nur das Label tauscht, ohne den Satz zu
  lesen, riskiert eine Zusage, die neben ihrer geänderten Ableitung stehenbleibt. — **Ausgang:**
  offen bis zur Closure.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (eine vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area,
die die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
den Adaptions-Block und `docs/plan/adr/` führt. `harness/tools/` und `.codex/` sind **nicht**
berührt: keine der Fundstellen aus §1 liegt dort.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist durchgegangen; je Slug die Zahl der
`evidence/`-Dateien und die erste Zeile seiner `state.md`
(`for s in zusage-nennt-sensor-der-form-nicht-sieht zusage-neben-geaenderter-ableitung-bleibt-stehen anweisungssatz-eigentum-ohne-quelle adaptions-achse-1-kurzschluss adaptions-block-spricht-ueber-sich-selbst; do d="docs/plan/planning/observations/BEO-ALL/$s"; echo "$s $(ls "$d/evidence" | wc -l)x $(head -1 "$d/state.md")"; done`;
keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die fünf Einträge des Kommandos berühren diesen Slice, weitere Treffer: keine.

- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  — bindet die Formulierung beider Liefer-Punkte; steht als Risiko in §6.
- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — der Label-Tausch im Adaptions-Block ist genau ihr Fall; steht als Risiko in §6.
- [`anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)
  und
  [`adaptions-achse-1-kurzschluss`](../observations/BEO-ALL/adaptions-achse-1-kurzschluss/observation.md)
  — die zwei **Gegenstände** der Zitate. Sie sind berührt, aber nicht getroffen: Der Slice ändert
  nichts an ihrem Stand, nur an der Form, in der andere Artefakte sie nennen.
- [`adaptions-block-spricht-ueber-sich-selbst`](../observations/BEO-ALL/adaptions-block-spricht-ueber-sich-selbst/observation.md)
  — berührt, weil Adaptions-Einträge angefasst werden; **nicht** getroffen, denn der Slice fügt
  keine Aussage über den Block hinzu, er ersetzt ein Label.

**Keine erreicht mit diesem Slice 3×** — er legt keinen Beleg an, bevor seine Closure ihn
schreibt, und keine der fünf steht mit ihm neu über der Schwelle.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
