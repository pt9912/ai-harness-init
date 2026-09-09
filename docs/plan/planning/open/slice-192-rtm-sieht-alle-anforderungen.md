# Slice slice-192: Die Requirements-Matrix sieht alle Anforderungen, und ihr Vollständigkeits-Urteil bekommt einen Leser

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Begründung in §1 *Warum wellenlos* — geprüft gegen
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht (Modul 6)
und gegen die Identität von [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(tragend — ein grünes Vollständigkeits-Urteil über einem Ausschnitt),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Lauf ist netzlos und
gepinnt), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 2 (die Gate/advisory-Grenzziehung, die Liefer-Punkt 2 bewegt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop, kein ADR).

**Berührte Spec-Stellen:** — . Der Slice ändert keine Spec-Aussage; er richtet einen Sensor auf den
**Bestand** von [`spec/lastenheft.md`](../../../../spec/lastenheft.md), ohne dessen Text zu berühren.
Die Datei ist Prüfgegenstand, nicht Änderungsziel (§3).

**Verantwortlich:** — .

**Autor:** Planner. **Datum:** 2026-09-06.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Die Requirements-Traceability-Matrix urteilt über alle vierzehn Anforderungen statt über vier, ihr
Vollständigkeits-Urteil wird in `make gates` gelesen, und der Prüfbereich selbst bekommt einen
Wächter — weil ein zurückgedrehtes Muster das Urteil still grün lässt.**

### Der Befund, gemessen

Alle Zahlen dieses Abschnitts stammen aus dem Schnitt-Lauf vom 2026-09-06 über einem Klon außerhalb
des Repos (Stand `abf05be`), netzlos (`--network none`), Mount `:ro`, Image per Digest
`sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641` — derselbe Pin, den
[`d-check.mk`](../../../../d-check.mk) führt. **Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); der erste Schritt der Umsetzung ist, sie neu zu fahren.

1. **Das Urteil ist grün über einem Ausschnitt.** `make doc-trace` antwortet
   `4 Anforderung(en), 0 Waise(n).` — während
   `grep -cE '^### LH-(FA|QA)-[0-9]+' spec/lastenheft.md` → **14** liefert. Zehn Anforderungen
   stehen außerhalb des Urteils, und der Satz *„0 Waise(n)"* sagt das nicht.
2. **Die Ursache ist das Vorgabe-Muster, nicht der Bestand.** Das Default-`id-pattern` lautet laut
   `--print-config` `[A-Z][A-Z0-9]*-(?:FA-[A-Z]+|QA)-\d+[A-Za-z]?`. Sein `FA`-Zweig verlangt ein
   **Bereichssegment** (`FA-<BUCHSTABEN>-<Ziffern>`); unsere Kennungen tragen die Form
   `LH-FA-<NN>` und damit keines — passend zur Modus-Deklaration in
   [`harness/conventions.md`](../../../../harness/conventions.md), die für ADRs und Slices
   ausdrücklich kein Segment führt. Der `QA`-Zweig (`QA-\d+`) passt; genau die vier `LH-QA-*` sind
   sichtbar.
3. **Der Fix ist gefahren, nicht entworfen.** Mit
   `trace.requirements.source: spec/lastenheft.md` und `id-pattern: 'LH-(?:FA|QA)-\d+'` antwortet
   derselbe Lauf `14 Anforderung(en), 0 Waise(n).`; alle zehn `LH-FA-*` erscheinen mit ADR- und
   Slice-Spalte.
4. **Das Vollständigkeits-Urteil hat Zähne.** Eine an
   [`spec/lastenheft.md`](../../../../spec/lastenheft.md) angehängte, von keinem ADR und keinem
   Slice genannte Anforderung liefert `15 Anforderung(en), 1 Waise(n).` und
   `make doc-complete` **Exit 1**. Das Rot ist damit herstellbar
   ([`AGENTS.md`](../../../../AGENTS.md) §3.6) und die Klasse real: Eine Lastenheft-Änderung ist in
   diesem Repo ein eigener Vorgang
   ([`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)),
   und niemand hält heute nach, ob die neue Kennung je einen Slice bekommt.
5. **Der Prüfbereich schützt sich nicht selbst — das ist der Grund für Liefer-Punkt 3.** Wird das
   `id-pattern` auf die Vorgabe zurückgedreht, meldet `make doc-complete` wieder
   `4 Anforderung(en), 0 Waise(n).`, **Exit 0**. Die Regression ist still: Das Gate bewacht die
   *Waisen* innerhalb seines Ausschnitts, nie den **Zuschnitt** des Ausschnitts. Ein Wächter, der
   nur `doc-complete` verdrahtet, verlässt sich also auf genau die Eigenschaft, die heute gebrochen
   ist.
6. **Zwei Eigenschaften tragen und stehen deshalb hier.** `trace:` ist **kein Modul** — die
   Modul-Liste des gepinnten Images führt zweiundzwanzig Namen und `trace` ist keiner davon
   (`--print-config | grep -m1 '^# Verfügbar:' | grep -cw trace` → **0**); der Block ändert an
   `make docs-check` nichts (dieselbe Befundzahl mit Block wie ohne). Und ein `source:`, das keine
   Anforderung trifft, ist **fail-closed**: `id-pattern: 'XX-…'` bricht mit
   `trace.requirements: Quelle … ergab 0 Anforderungen`, **Exit 2** — ein leerer Prüfbereich kann
   sich hier nicht als Grün tarnen.

### Warum wellenlos

Zwei Fragen, beide gemessen beantwortet.

**Gehört der Schnitt in [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)? Nein.** Deren
Identität sind die **gemessenen Modul-Achsen** des Roadmap-Kandidaten *Regeln ohne
Feedback-Quadrant schließen*; ihr §6 schließt mit genau dieser Begründung `workflows`, `reviews`,
`planning.observations`, `hostpaths`, `versions`, `pins`, `immutable` und `diagrams` als **eigene
Kandidaten** aus — *„keine der gemessenen Achsen … und die Welle-Identität sind die Achsen des
Kandidaten"*. `--trace` ist nicht einmal ein Modul (Befund 6), also erst recht keine dieser Achsen.
Dazu begründet ihr §4 die Mitgliederzahl ausdrücklich (*„Warum sechs und nicht drei"*); ein siebter
Eintrag änderte die Identität der Welle, statt ihr etwas hinzuzufügen.

**Ist es eine eigene Welle? Nein.** Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht: Eine Welle liegt vor, wenn ein Closure-Trigger **mehr** beobachtet, als die DoDs
ihrer Slices ohnehin belegen. Hier ist es ein Slice; sein Closure-Trigger schriebe seine eigene DoD
ab — der dort benannte Regelfall für wellenlose Arbeit.

**Eine Berührung bleibt und wird nicht zur Mitgliedschaft.** Der Closure-Trigger von
[welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) verlangt, dass für **jedes** der zwölf
advisory-`docs?-*`-Ziele in [`d-check.mk`](../../../../d-check.mk) entschieden und aufgeschrieben
ist, ob es einen Prüfbereich hat. Die Datei führt `grep -cE '^docs?-[a-z-]+:' d-check.mk` → **13**
Ziele; genau eines davon, `docs-check`, ist als Gate behauptet, die übrigen **zwölf** sind advisory
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 2). `doc-trace` und `doc-complete` sind zwei dieser zwölf, und dieser Slice entscheidet
genau sie. Er **entlastet** damit jenen Trigger, ohne in die Welle zu gehören; das Verhältnis ist
Angrenzung, nicht Bündelung.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

**Drei Liefer-Punkte, und sie bauen aufeinander:** (1) macht das Urteil vollständig, (2) gibt ihm
einen Leser, (3) bewacht den Zuschnitt, den (1) gesetzt hat. Ohne (3) ist (2) ein Gate, das seine
eigene Voraussetzung nicht hält (§1 Befund 5).

- [ ] **(1) Der `trace:`-Block steht in [`.d-check.yml`](../../../../.d-check.yml), und die Matrix
  urteilt über alle Anforderungen.** `make doc-trace` nennt so viele Anforderungen, wie
  `grep -cE '^### LH-(FA|QA)-[0-9]+' spec/lastenheft.md` liefert — beide Zahlen im Umsetzungs-Commit
  gefahren und dort abgedruckt, keine Erwartungswerte. **Rot gesehen:** ein `id-pattern`, das nichts
  trifft, bricht mit Exit 2 (fail-closed, §1 Befund 6) — die Ausgabe steht im Commit.
- [ ] **(2) `doc-complete` läuft in `make gates`, und die Zusage ist an das gebunden, was sie
  misst.** An **jeder** Stelle, die das Ziel als Gate führt, steht, dass `ok` **verfolgt** heißt
  (die Anforderung wird von mindestens einem ADR oder Slice referenziert) und **nicht erfüllt** —
  sonst entsteht die Vollständigkeits-Zusage, die
  [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  beschreibt. **Rot gesehen:** eine unreferenzierte Anforderung im Lastenheft färbt `make gates`
  rot, Exit 1 (§1 Befund 4), Ausgabe im Commit.
- [ ] **(3) Ein Wächter hält den Prüfbereich selbst, und ein `test/mutations/`-Fall hält ihm die
  Zähne.** Der Wächter vergleicht die Anforderungszahl der Matrix gegen die Zahl der
  `### LH-*`-Überschriften in [`spec/lastenheft.md`](../../../../spec/lastenheft.md) und wird rot,
  wenn sie auseinanderfallen. **Rot gesehen:** das `id-pattern` auf die Tool-Vorgabe
  zurückgedreht — `doc-complete` bleibt dabei grün (Exit 0, §1 Befund 5), der neue Wächter nicht.
  Der Mutations-Fall bildet genau dieses Zurückdrehen ab; `make mutate` meldet ihn als bewacht.
- [ ] `make gates` grün.
- [ ] **Der Nachzug an [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  Setzung 2 ist erfolgt** — dort steht `doc-complete` heute in der Aufzählung der zwölf advisory
  Ziele, und *„Genau eines davon, `docs-check`, steht in `make gates`"*. Der Text ist
  **Architect-Eigentum** ([`AGENTS.md`](../../../../AGENTS.md) §3.8); dieser Slice schreibt ihn
  nicht, sondern hängt an ihm (§4 Start-Trigger, §6 Risiko 1).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml) | update | der `trace:`-Block (Liefer-Punkt 1). **Kein Modul** — die Modul-Liste bleibt unberührt, und `make docs-check` liefert dieselbe Befundzahl wie ohne Block (§1 Befund 6) |
| `Makefile` | update | `doc-complete` in die `gates`-Kette (Liefer-Punkt 2) und das Rezept des Prüfbereichs-Wächters (Liefer-Punkt 3) |
| [`AGENTS.md`](../../../../AGENTS.md) §4 | update | die Gate-Tabelle nennt das neue Ziel samt der Abgrenzung *verfolgt ≠ erfüllt*. **§4 ist nicht §3** — die Eigentums-Regel aus §3.8 bindet die Hard Rules und den Adaptions-Block, nicht die Gate-Tabelle |
| [`harness/README.md`](../../../../harness/README.md) §Sensors | update | dieselbe Zeile in der Sensor-Tabelle, mit derselben Abgrenzung |
| `harness/tools/` | neu | der Prüfbereichs-Wächter aus Liefer-Punkt 3, damit `make shell-lint` ihn deckt und ein bats-Fall seinen Urteils-Teil ohne Docker prüfen kann |
| `test/mutations/` | neu | der Fall, der dem Wächter aus Liefer-Punkt 3 die Zähne nimmt (`id-pattern` auf die Vorgabe zurückgedreht) |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | Prüfgegenstand, nicht Änderungsziel. Wer hier eine Anforderung ergänzt, um das Gate zu bedienen, hat die Richtung umgedreht |
| [`harness/conventions/MR-010-…`](../../../../harness/conventions/MR-010-d-check-gate-fragment-tool-generiert.md) | **unverändert — fremdes Rollen-Eigentum** | Setzung 2 muss nachgezogen werden, aber vom **Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Ein Implementations-Lauf, der sie mitnimmt, ist die Klasse [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md) — am 2026-09-06 bei `ls docs/plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/evidence/*.md \| wc -l` → **5**, kein Erwartungswert |
| [`d-check.mk`](../../../../d-check.mk) | **unverändert** | die Ziel-Definitionen stehen bereits und sind vom Tool erzeugt; dieser Slice ruft sie, er schreibt sie nicht um |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **zwei Bedingungen, beide beobachtbar, beide tragend.**

1. **[slice-125](../done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) liegt in
   `done/`.** Beobachtbar ohne Rückfrage: `ls docs/plan/planning/done/slice-125-*.md`. Der Grund ist
   **tragend, nicht ordnend**: Beide Slices schreiben in denselben Schlüsselbaum
   [`.d-check.yml`](../../../../.d-check.yml) — jener verdrahtet das Modul `planning`, dieser den
   `trace:`-Block. Es ist dieselbe Form, die
   [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §4 für das Paar `slice-125`/`slice-129`
   führt: *„die Reihenfolge ist frei, die Parallelität nicht"*. Am 2026-09-06 ist die **Arbeit**
   von slice-125 committet (`abf05be`), der Slice aber noch nicht geschlossen — der Zustand ist die
   Verzeichnis-Position, nicht der Commit-Stand.
2. **[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   Setzung 2 führt `doc-complete` nicht mehr als advisory.** Beobachtbar ohne Rückfrage — die
   Advisory-Aufzählung nennt das Ziel nicht mehr:

   ```sh
   grep -c 'doc-complete' harness/conventions/MR-010-d-check-gate-fragment-tool-generiert.md   # 0
   ```

   Der Grund ist **tragend**: Solange dort *„Genau eines davon,
   `docs-check`, steht in `make gates`"* steht, widerspräche Liefer-Punkt 2 einem aktiven
   Adaptions-Eintrag. Das ist ein **Gate-Anheben** und damit Steering-Loop, kein ADR
   ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)) —
   geschrieben wird es vom **Architect**, nicht von diesem Slice.

**Die zweite Bedingung ist kein Vorwand, sie zu umgehen.** Fällt die Architect-Entscheidung gegen
das Gate, bleibt Liefer-Punkt 1 unberührt lieferbar und der Slice geht mit zwei Punkten nach
`next` zurück — nicht mit einem stillschweigend gestrichenen dritten (§6 Risiko 1).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Prüfbereichs-Wächter aus
  Liefer-Punkt 3 braucht einen eigenen Urteils-Mechanismus, der über einen Zahlenvergleich
  hinausgeht — etwa weil die Matrix-Ausgabe nicht stabil zerlegbar ist. Dann werden (1)+(2) und (3)
  getrennt geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Die Architect-Entscheidung zu
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  Setzung 2 steht aus, nachdem die Arbeit begonnen hat — oder `make gates` wird durch
  `doc-complete` aus einem Grund rot, der nicht in diesem Slice liegt (eine Anforderung ohne
  Referenz, die eine Spec-Entscheidung braucht statt eines Slice-Bezugs).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

- **Beobachtbar 1:** `make gates` ist grün und fährt `doc-complete` mit; die Matrix urteilt über so
  viele Anforderungen, wie `grep -cE '^### LH-(FA|QA)-[0-9]+' spec/lastenheft.md` liefert.
- **Beobachtbar 2:** Beide neuen Zusagen sind **einmal rot gesehen**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6), jede mit dem Kommando, das sie rot färbt, im
  Umsetzungs-Commit: die unreferenzierte Anforderung für `doc-complete`, das zurückgedrehte
  `id-pattern` für den Prüfbereichs-Wächter. `make mutate` führt den Wächter aus Liefer-Punkt 3 als
  bewacht.
- **Review** durch einen Lauf, der die Umsetzung nicht geschrieben hat; danach Verifikation gegen
  diese DoD.
- Closure-Notiz §7 mit Lerneintrag, geschrieben vom **Planner** in frischem Kontext
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10), und jedes Risiko aus §6 mit genau einem Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Risiko 1 — die Architect-Entscheidung zu
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  Setzung 2 fällt gegen das Gate.** Dann ist Liefer-Punkt 2 nicht lieferbar und Liefer-Punkt 3
  verliert seinen Anlass zur Hälfte (der Prüfbereichs-Wächter trüge dann eine advisory-Ausgabe,
  kein Gate). Der Slice wird auf Liefer-Punkt 1 zurückgeschnitten, statt das Gate gegen einen
  aktiven Adaptions-Eintrag zu setzen. — **Ausgang:** <offen>
- **Risiko 2 — `ok` heißt verfolgt, nicht erfüllt, und ein Gate-Name suggeriert das Gegenteil.**
  `doc-complete` trägt im Hilfetext das Wort *Vollständigkeits-Gate*; wer die Zeile in
  [`AGENTS.md`](../../../../AGENTS.md) §4 liest, kann sie als Aussage über **Erfüllung** lesen. Die
  DoD bindet die Zusage (Liefer-Punkt 2), aber kein Sensor hält sie — dieselbe Klasse wie
  [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  (am 2026-09-06 bei **1×**, `ls docs/plan/planning/observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/evidence/*.md | wc -l`,
  kein Erwartungswert). — **Ausgang:** <offen>
- **Risiko 3 — der Prüfbereichs-Wächter zerlegt eine Ausgabe, die das Tool ändern darf.** Er liest
  die Anforderungszahl aus der Matrix-Ausgabe. Der Pin
  [`MR-052`](../../../../harness/conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
  hat zuletzt eine **vierte Ausgabe-Spalte** eingeführt; ein Wächter, der auf Spaltenpositionen
  keilt, bricht beim nächsten Sprung still. Er schneidet deshalb auf die Summenzeile, nicht auf die
  Tabelle — und der Re-Pin-Trockenlauf muss ihn mitführen. — **Ausgang:** <offen>
- **Risiko 4 — `modality` bleibt draußen, und die Lücke bleibt damit benannt.** Die
  RFC-2119-Klassifikation ist **nicht** Teil dieses Schnitts (§8 *Ausdrücklich nicht in diesem
  Schnitt*). Damit bleibt offen, dass unsere Anforderungstexte keine Modalverben führen — die
  Frage wandert, sie verschwindet nicht. — **Ausgang:** <offen>
- **Risiko 5 — der `trace:`-Block ist ein zweiter Schreiber in
  [`.d-check.yml`](../../../../.d-check.yml).** Der Start-Trigger serialisiert gegen
  [slice-125](../done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md), aber
  [slice-129](../in-progress/slice-129-closure-notiz-hat-einen-sensor.md) schreibt in denselben Baum und ist
  nicht durch diesen Trigger gedeckt. Läuft es dazwischen, ist der Konflikt ein Merge-Konflikt,
  kein stiller. — **Ausgang:** <offen>

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

**Alle berührten Sub-Areas GF** — der Begründungsblock unten steht trotzdem, weil das
Evidenz-Kriterium hier eine Antwort trägt, die über *„GF, also niedrig"* hinausgeht.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (gesamtes Repo), Kürzel
`ALL` aus der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md). Die Pfad-Kandidaten aus §3 —
[`.d-check.yml`](../../../../.d-check.yml), `Makefile`, [`AGENTS.md`](../../../../AGENTS.md),
[`harness/README.md`](../../../../harness/README.md), `harness/tools/`, `test/mutations/` — liegen
in **keiner** engeren deklarierten Sub-Area: `TOOLS` (`harness/tools/`) wird zwar pfad-berührt,
aber die Aussage dieses Slice ist die Gate-Fläche des Repos, nicht die Werkzeug-Mechanik; das
Skript ist Träger, nicht Gegenstand. Eine eigene Sub-Area *„Doc-Gate"* auszudifferenzieren erfüllte
die Schwelle ≥ 2 von 3 Achsen nicht — sie hätte weder eigene Konventionen-Dichte noch eigenen
Reifegrad gegenüber `*`.

**Vorgelagert — offene Beobachtungen sichten:** Gesichtet ist der **gemergte** Stand vom
2026-09-06: **57** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein
Erwartungswert). Alle Einträge dieses Repos führen dieselbe Sub-Area `*`, die Sichtung ist also
nach **Gegenstand** geschnitten, nicht nach Sub-Area. **Vier Einträge berühren diesen Slice**, je
mit ihrem Zähler-Stand aus `ls <eintrag>/evidence/*.md | wc -l`:

| Beobachtung | Stand | berührt |
|---|---|---|
| [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | **7×**, *geplant* (`slice-181`) | den Befund selbst in seiner schärfsten Form — der Sensor sieht die Kennungs-Form `LH-FA-<NN>` nicht. Der Ausgang ist **vergeben**, die Schwelle längst überschritten |
| [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md) | **1×**, offen | Risiko 2 — *„0 Waise(n)"* über vier von vierzehn, und `ok` = verfolgt ≠ erfüllt |
| [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md) | **5×**, offen | §3 letzte Zeile und §4 Bedingung 2 — der [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Nachzug gehört dem Architect |
| [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md) | **2×**, offen | §5 Beobachtbar 2 — beide neuen Zusagen tragen ihr Rot, und genau deshalb ist Liefer-Punkt 3 eigenständig |

**Was daraus folgt — und eine Schwelle ist in Reichweite.** Der Schnitt löst **keinen**
Folge-Slice aus, weil beim Schnitt kein Beleg entsteht: Belegt wird bei der **Closure**
(Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register). Für die Closure gilt
gerechnet: `zusage-nennt-sensor-der-form-nicht-sieht` stünde bei **8×** — Ausgang bereits vergeben,
also folgenlos; `vollstaendigkeits-zusage-misst-falsche-ebene` bei **2×**;
`fremdes-rollen-artefakt-im-implementations-kontext` bei **6×** — ebenfalls über der Schwelle und
mit [`AGENTS.md`](../../../../AGENTS.md) §3.8/§3.10 bereits verkörpert. **Der eine, der kippen
kann, ist [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md):
er steht bei 2× und erreichte mit einem Beleg aus diesem Slice genau 3×** — dann ist er keine Notiz
mehr, sondern eine Lücke mit eigenem Folge-Slice (Modul 5 §Zwei Schritte vor der
Modus-Begründung). **Ob er einen Beleg bekommt, ist offen und hängt am Ausgang der Arbeit:** Der
Slice ist so geschnitten, dass für **beide** neuen Zusagen ein Rot hergestellt wird (§5
Beobachtbar 2) — gelingt das, ist er kein Auftreten der Klasse, sondern ihr Gegenteil. Scheitert es
an einer der beiden, ist er eines, und die Closure schneidet den Folge-Slice.

**Eine zweite Entscheidung bleibt der Closure überlassen und wird hier nur benannt:** welcher
Eintrag den Beleg für den Befund selbst bekommt. Er passt auf die *schärfste Form* von
`zusage-nennt-sensor-der-form-nicht-sieht`, dessen Erstformulierung aber vom „Skript- oder
Funktionskopf" spricht, während hier eine **Tool-Ausgabe** urteilt. Das ist ein Urteil beim
Schreiben (*Mensch urteilt, Maschine prüft Deckung*) und fällt bei der Slice-Closure, nicht beim
Schnitt — vorschnell einen neuen Namen anzulegen teilte die Beobachtung still.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** **hoch.** Die berührte Fläche ist durchgängig verankert —
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2
  zieht die Gate/advisory-Grenze und zählt die Ziele auf,
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  regelt das Anheben als Steering-Loop,
  [`MR-052`](../../../../harness/conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
  hält den lebenden Pin, und [`AGENTS.md`](../../../../AGENTS.md) §3.6 bindet jede neue Zusage an
  ihr rot gesehenes Gegenbeispiel. Genau diese Dichte ist der Grund, warum der Slice die
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Kante
  nicht übersehen konnte.
- **Phase-Reife:** **Phase 5.** Das Doc-Gate läuft seit slice-009 in `make gates`, ist mehrfach
  re-gepinnt und tool-generiert; verändert wird eine **Konfigurations-Fläche innerhalb** eines
  reifen Gates, nicht seine Einführung.
- **Evidenz-/Diskrepanz-Risiko:** **niedrig für den Code-Bestand, benannt für die Zusagen.** Der
  Fix ist vollständig gemessen (§1) und ändert an `make docs-check` nichts. Das verbleibende Risiko
  liegt nicht im Bestand, sondern in der **Reichweite der Zusage**: `ok` heißt verfolgt, nicht
  erfüllt (Risiko 2), und `doc-complete` bewacht den Zuschnitt seines eigenen Prüfbereichs nicht
  (§1 Befund 5) — beides ist der Grund für Liefer-Punkt 3 statt eine Restunsicherheit daneben.
- **Reconciliation-Aufwand:** **keiner** — GF, es gibt keine Inventur-Linie. Gemessen statt
  behauptet: `ls docs/plan/planning/reconciliation.md` → *nicht vorhanden*; dieses Repo hat keinen
  Brownfield-Bootstrap und führt darum kein Inventur-Register. Deshalb trägt §2 das
  Reconciliation-Item der Vorlage nicht — es entfällt, wie die Vorlage es für Repos ohne
  Brownfield-Bootstrap vorsieht. **Graduation:** entfällt (GF).

### Ausdrücklich nicht in diesem Schnitt

- **Das `modality`-Feld des `trace`-Blocks** (RFC-2119-Klassifikation, `require-levels: [must]`) —
  **gemessen ausgeschlossen, nicht bloß abgegrenzt.** Über unserem Lastenheft klassifiziert es
  **keine einzige** der vierzehn Anforderungen als `must`: **12×** `unknown`, **2×** `may`, weil
  unsere Anforderungstexte keine Modalverben führen. Und weil `require-levels: [must]` nur die
  gelisteten Stufen gatet, **nimmt es dem Gate aus Liefer-Punkt 2 die Zähne**: dieselbe
  unreferenzierte, modalverb-freie Anforderung, die ohne `modality` Exit **1** liefert, erscheint
  mit `modality` als `WAISE` in der Matrix — und der Lauf endet mit Exit **0**. Ein sichtbarer
  Waisen-Eintrag neben einem grünen Exit ist genau die Klasse, die dieser Slice schließt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); sie
  hier mit hereinzunehmen hieße, sie im selben Zug wieder zu öffnen. Die Fähigkeit ist damit eine
  **eigene Frage mit eigenem Gegenstand** — entweder die Anforderungstexte bekommen Modalverben
  (eine Lastenheft-Änderung und damit ein Change-Request-Vorgang,
  [`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)),
  oder `levels:` wird auf unseren Sprachgebrauch konfiguriert. Beides ist ein eigener Schnitt;
  **eine Slice-Kennung steht hier deshalb nicht** — sie behauptete eine Datei, die es nicht gibt.
  Was dieser Lauf hinterlässt, ist die Messung, die jenen Schnitt billig macht (Risiko 4).
- **`cross-consistency`** — der Mengenabgleich zweier Traceability-Sichten setzt eine kuratierte
  Vorwärts-Sicht voraus, die dieses Repo nicht führt: `ls docs/plan/traceability.md` → *nicht
  vorhanden*. Ein Block darüber liefe gegen einen leeren Prüfbereich
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **`format: table` und die `adrs`/`slices`-Vorgaben.** Beide Default-Blöcke passen auf diesen
  Baum, ohne dass etwas gesetzt werden muss — die Matrix findet ADRs und Slices bereits. Was nicht
  gebraucht wird, wird nicht konfiguriert.
- **Jede Senkung einer bestehenden Schwelle.** Dieser Slice **hebt** nur
  ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
  Stellt sich heraus, dass `doc-complete` nur durch eine Lockerung woanders grün wird, ist das ein
  ADR und ein Rückführungs-Grund (§4), kein Zwischenschritt.
