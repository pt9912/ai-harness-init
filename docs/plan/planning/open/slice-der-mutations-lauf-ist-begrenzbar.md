# Slice slice-der-mutations-lauf-ist-begrenzbar: Der Mutations-Lauf läßt sich auf die Fälle einer Runde begrenzen — und die Runde schuldet nicht mehr den ganzen Satz

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Es gibt keine beobachtbare Closure-Bedingung, die mehr beobachtet als die
DoD dieses Slice: sie prüft ihre eigene Auswahl, ihre eigene Ausgabe und ihre eigenen Wächter
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap — auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Weder der Treiber noch die Anweisungssätze dieses Repos gehen
in ein Zielrepo: `grep -rln 'mutate' internal/emit/templates/ | wc -l` → **0** (die emittierte
`.claude/agents/implementer.md` trägt die Zeile nicht). Ob ein Zielrepo den Filter oder die
Stufen-Aussage bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Zusage-Hälfte, deren Feedback-Träger dieser Lauf
ist — und deren Aussage über ihn **bleibt**, was sie ist),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Auswahl, die nichts trifft, ist kein grüner Lauf; ein Lauf, der mehr behauptet als er prüft, ist
ein behauptetes Gate),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (dieselbe Auswahl,
dasselbe Verdikt — und die Grenze dieser Zusage, siehe *Berührte Spec-Stellen*),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (die Auswahl bleibt
bash + coreutils, wie der übrige Treiber),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
(Setzung 2 und ihr Nachtrag — die Sensor-Klassen-Trennung, an der die Stufe dieses Laufs hängt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 1 und 2 — jede Zahl dieses Plans steht neben ihrem Kommando),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt den Tag, gegen den sie gemessen ist),
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
(wellenlose Arbeit),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(Kennungs-Form),
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Festlegung 1 — wem
die Anweisungssätze gehören, die dieser Slice ändert),
[`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) (`Proposed` —
Festlegung 1 weist die Modul-11-Passage einer anderen Rolle zu; siehe *Eigentum* in §1),
[`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) (der
Beleg-Mechanismus, an dem die erste Grenze dieses Slice hängt).

**Berührte Spec-Stellen:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) —
die Zusage *derselbe Prüfgegenstand, dasselbe Verdikt, unabhängig von der Worker-Zahl* bekommt mit
dem Filter eine **zweite Achse**, und sie gilt für sie so, wie sie für die erste gilt: **dieselbe
Auswahl, dasselbe Verdikt** — kein Zufall, keine Maschinen-Abhängigkeit, keine
Dateisystem-Reihenfolge. Die Auswahl ist eine Funktion von Muster und Fall-Menge, nicht von der
Wanduhr. **Und sie bekommt eine Grenze, die die erste Achse nicht hat:** die Worker-Zahl ändert den
*Ausschnitt* nicht, das Muster schon — ein gefilterter Lauf belegt deshalb nichts über die **nicht**
gewählten Fälle. Diese Grenze ist Liefer-Punkt (2), nicht eine Fußnote.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ist
daneben tragend für die zwei Rot-Bedingungen: kein Muster ohne Treffer, kein Teillauf mit dem
Anspruch eines Voll-Belegs.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine). **Die zwei Anweisungssatz-Zeilen
sind eine Übergabe und kein Planner-Liefergegenstand** — welcher Rolle sie gehören, steht in §1
unter *Eigentum*.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Eine Rolle fährt in ihrer Runde genau ihre Mutationsfälle — und die zwei Stellen, die ihr
heute den ganzen Satz vorschreiben, schreiben ihr ihn nicht mehr vor, ohne daß der repo-weite Satz
dabei an Deckung verliert.**

Der Satz hat **zwei Hälften**, und sie tragen dieselbe Aussage auf zwei Ebenen:

- **Werkzeug-Seite:** der Treiber kann seinen Fall-Satz **begrenzen** (`MUTATE_ONLY`) — und sagt
  dabei, daß ein begrenzter Lauf kein Voll-Beleg ist.
- **Anweisungssatz-Seite:** die zwei Stellen, die den **vollen** Lauf als Rundenpflicht führen,
  werden gezogen: die Runde belegt ihre **eigenen** neuen oder geänderten Wächter einzeln (Mutation
  von Hand, den benannten Test fallen sehen, seine Ausgabe lesen — [`AGENTS.md`](../../../../AGENTS.md)
  §3.6), der **repo-weite** Satz steht auf der Stufe, die das Regelwerk ihm gibt.

### Die Lage, mit ihrer Messung

Der Satz umfaßt **315** Fall-Dateien (`ls test/mutations/*.sh | wc -l` → **315**; **kein
Erwartungswert**, er wandert mit jedem bewachten Wächter,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Je Fall läuft **ein voller Sensor-Lauf**, und was der gekostet hat, sagt der Lauf am
Ende **selbst** — `report_times` gibt *Zeit je Sensor* und *untere Schranke jeder
Parallelisierung = längster Einzelfall* aus. Eine Zahl gehört darum nicht in diesen Plan: sie steht
in der Ausgabe des Laufs, der sie gemessen hat.

Für **eine** Rolle ist der Satz um Größenordnungen größer als ihre Frage. Sie ändert wenige
Wächter; die Fälle, die **ihre** Stellen mutieren, sind ein Ausschnitt davon — **39** Fall-Dateien
mutieren den Treiber selbst (`grep -l 'harness/tools/mutate.sh' test/mutations/*.sh | wc -l` →
**39**, kein Erwartungswert) —, und die übrigen sagen über ihren Diff nichts. Der Treiber kennt
heute **keine** Auswahl: `grep -c 'MUTATE_ONLY' harness/tools/mutate.sh Makefile` → **0** und
**0**.

**Der Widerspruch, der den Slice begründet, steht in [`AGENTS.md`](../../../../AGENTS.md) §3.6
selbst:** der Sensor prüft die *„Haltbarkeit vorhandener Zähne, nicht die **Entstehung** neuer"*.
Als **repo-weiter** Satz ist er damit richtig aufgestellt; als **Rundenpflicht** jeder Rolle prüft
er genau das, was die Runde ohnehin gerade tut, und zwar für den ganzen Bestand.

### Die Stufe steht schon — dieser Slice entscheidet sie nicht, er zitiert sie

Der repo-weite Satz läuft **nächtlich**, nicht mehr pro Push: `.github/workflows/mutate.yml`
(`schedule` + `workflow_dispatch`) trägt ihn, die Pro-Push-Aufgabe ist aus
`.github/workflows/ci.yml` entfallen (`grep -c 'run: make mutate' .github/workflows/ci.yml` → **0**;
dieselbe Zählung in `mutate.yml` → **1** — beide **keine Erwartungswerte**). Der Grund ist die
Zuordnung des Regelwerks am adoptierten Stand `v6.8.0`:
`grep -n 'Post-integration' .harness/baseline/v6.8.0/regelwerk/grundlagen-klassifikation.md` →
**Zeile 202** (`| Post-integration | Mutation Tests, vollständige Verifikation, Validator-Agent |
teurer, aber tolerierbar |`) und **Zeile 213** (`nach Merge : Mutation Tests : vollständige
Verifikation : Validator-Agent`). **Die Stufe ist damit eine Tatsache dieses Plans, kein
Liefer-Punkt.**

**Was daran ausdrücklich offen bleibt und wem es gehört:** die Auslöser-Menge der CI ist eine
Setzung wie [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
Setzung 2 — der Adaptions-Eintrag dazu ist **Architect**-Arbeit
([`AGENTS.md`](../../../../AGENTS.md) §3.8) und nicht dieser Slice.

**Der Sensor bleibt, was er ist.** [`AGENTS.md`](../../../../AGENTS.md) §3.6 nennt `make mutate`
weiter als seine Feedback-Hälfte; geändert wird die **Stufe** ihres Laufs, nicht sein Bestand. Die
Sektion führt bereits, daß das Regelwerk diesen Träger nicht kennt —
`grep -rl 'make mutate' .harness/baseline/v6.8.0/regelwerk/ | wc -l` → **0** (kein Erwartungswert)
—, und dieser Plan schreibt das nicht neu.

### Eigentum: wem die Liefergegenstände gehören

Der **Planner** schreibt keinen der beiden Anweisungssätze, die dieser Slice zieht — ein
Planner-Commit darauf wäre der Verstoß, den der Adaptions-Block führt. Je Liefergegenstand, mit
seiner Quelle:

| Liefergegenstand | schreibende Rolle | Quelle |
|---|---|---|
| `harness/tools/mutate.sh`, `Makefile`, [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md), `test/*` | die Rolle, die diesen Slice ausführt | das Feld `Verantwortlich:` dieses Plans (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine) |
| [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) | **Implementer** | [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 (`Accepted`) — sie gehört der Rolle, die sie **ausführt** |
| [`.claude/agents/implementer.md`](../../../../.claude/agents/implementer.md) | **keine geschlossene Zuständigkeit** | [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) nimmt `.claude/agents/*.md` **ausdrücklich aus**; [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) Festlegung 1 weist die Passage *Modul 11* dem **Architect** zu, steht aber auf **`Proposed`**. Die Frage ist als [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md) geführt |

Die dritte Zeile ist damit eine **Übergabe**, kein Liefer-Punkt: der Träger nennt in seiner
Commit-Message die Quelle, die **ihn** für diese Zeile benennt. Gibt es keine angenommene, geht sie
über den Auftraggeber-Pfad ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
Setzung 2) — oder sie bleibt stehen, und §7 sagt das (§6 Risiko 1).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Änderung an der Fall-Menge.** Kein Fall wird entfernt, zusammengelegt oder wegen des
  Filters umgeschnitten: *der Bestand bleibt bewusst stehen.* Eine Auswahl ist kein Anlaß, den
  Satz zu verkleinern — wer beides in einem Zug tut, kann die verlorene Deckung nicht mehr messen.
- **Kein Auswahl-Kriterium über die `# files:`-Angabe.** Sie ist eine Bash-Glob, die
  `resolve_file_spec` gegen den Baum **auflöst** und deren Mehrdeutigkeit fail-closed abbricht;
  sie als Auswahl-Schlüssel zu nehmen, hinge den Filter an die Semantik einer anderen Regel und
  gäbe derselben Menge eine **zweite** Identität. *Es wäre ein anderer Vorgang — und die Auswahl
  bekäme zwei Quellen.*
- **Keine Änderung an der Stufe, an `mutate.yml` oder an `ci.yml`.** Sie ist entschieden und
  committed (siehe oben), ihr Adaptions-Eintrag ist Architect-Arbeit. *Es wäre ein anderer
  Vorgang.*
- **Die Kosten der seriellen Spur werden nicht angefaßt.** Die Fälle der Modi `smoke`/`full-smoke`
  laufen in **einer** Spur, weil ihr Urteil nicht vollständig in ihrem Trockenlauf steht
  (der Treiber sagt es selbst); ob sie einzeln parallelisierbar werden — eigene Docker-Tags — oder
  ob ihr Zuschnitt sich ändert, ist ein eigener Schnitt mit eigener Messung. *Es wäre ein anderer
  Vorgang — und der Filter macht ihn nicht nötig.*
- **Kein CI-Sharding (Matrix über k Jobs).** Den vollen Satz über mehrere Runner zu verteilen,
  ändert die Vollständigkeit über eine zweite Achse (Teil-Belege, die zusammengeführt werden
  müssen); das ist ein Kandidat für die **Roadmap-Vorschau**, nicht ein Punkt dieses Slice.
  *Es wäre ein anderer Vorgang.*
- **Kein Zug an den Anweisungssätzen von Reviewer und Verifier.** Keiner der beiden nennt
  `make mutate`; dort wäre es kein Ziehen einer falsch gewordenen Zeile, sondern ein **neuer**
  Schritt — und welche Rolle in ihrer Runde welchen Sensor fährt, entscheidet ihre eigene Runde.
  *Schicht-Abgrenzung.*
- **Kein Produkt-Code und keine emittierte Vorlage.** `internal/emit/` bleibt unberührt; der
  Treiber und die Anweisungssätze dieses Repos sind Dogfood (siehe *Ebene* oben). *Schicht-Abgrenzung.*

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Drei Liefer-Punkte.** Je Punkt ist benannt, **was ihn rot färbt** — und wo die Antwort dauerhaft
interessant ist, gehört sie als Fall nach `test/mutations/` ([`AGENTS.md`](../../../../AGENTS.md)
§3.6). Ein Fall dort mutiert `harness/tools/mutate.sh` und erwartet den **Titel** des bats-Tests,
der fallen soll; seine Form steht an den 39 bestehenden Treiber-Fällen
(`grep -l 'harness/tools/mutate.sh' test/mutations/*.sh | wc -l` → **39**, kein Erwartungswert).

- [ ] **(1) Die Auswahl greift und läßt die Warteschlange unangetastet.** `MUTATE_ONLY` — eine
      Env-Variable **mit ihrer Vorgabe im Skript** (leer = kein Filter), in derselben Form wie
      `MUTATE_JOBS`/`MUTATE_STALL_SECONDS`, vom `Makefile` nur **durchgereicht** — wählt aus der
      Fall-Menge aus, und zwar an der **einen** Stelle, an der die Fall-Liste entsteht. Alles
      Nachgelagerte (Numerierung, Warteschlange, `merge_report`, `report_times`) rechnet danach
      über die **ausgewählte** Menge: *„jede ausgewählte Fall-ID genau einmal"* bleibt eine
      Eigenschaft, die der Bericht **belegt**, keine Zusage. **Rot gesehen, zweimal:** (a) ein
      Muster **ohne Treffer** bricht den Lauf ab, statt einen leeren grünen Lauf zu liefern — ein
      Tippfehler darf nicht wie ein bestandener Lauf aussehen; (b) die Auswahl wird **nicht**
      angewandt → der benannte bats-Test in `test/mutate-driver.bats` fällt (Fall in
      `test/mutations/`).
- [ ] **(2) Ein Teillauf ist kein Voll-Beleg — mechanisch und gesagt.** *(a) Mechanisch:* ein Lauf
      über einer **echten Teilmenge** liest, schreibt und löscht den Beleg-Slot aus
      [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) **nicht**
      — er bestätigt und widerlegt die Aussage über den vollen Satz nicht. *Ob ein Lauf voll war,
      ist **abgeleitet** und kein zweites Feld:* `Auswahl == Fall-Menge` ⇒ voller Lauf (Beleg wie
      bisher), sonst Teillauf. **Rot gesehen:** nimmt man diese Bindung weg, schreibt ein grüner
      Teillauf den Schlüssel — der nächste **volle** Lauf gibt dann den früheren Beleg aus und
      überspringt den ganzen Satz (Fall in `test/mutations/`). *(b) Gesagt:* die Ausgabe nennt
      Muster, Zahl der ausgewählten und der nicht ausgewählten Fälle und **was Exit 0 hier heißt**
      („die ausgewählten Fälle sind grün — über die übrigen sagt dieser Lauf nichts"); der
      **Hilfetext des Ziels** und [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      tragen dieselbe Grenze, und dessen `Bindung`-Zeile nennt die **Stufe** statt des
      entfallenen Pro-Push-Auslösers (`grep -c 'Pro-Push-Auslöser' harness/sensors/mutate.md` → **1**
      vor dem Slice, kein Erwartungswert). **Rot gesehen:** fällt die Auswahl-Zeile aus der Ausgabe,
      fällt der benannte bats-Test.
- [ ] **(3) Die zwei Stellen, die den vollen Lauf als Rundenpflicht führen, sind gezogen — mit
      benanntem Träger.** [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md)
      (Schritt 18: *„`make mutate` **immer**, wenn Wächter neu/geändert sind"*, samt dem Verweis in
      Schritt 19) sagt danach: die Runde belegt ihre **eigenen** neuen oder geänderten Wächter
      einzeln — Mutation von Hand, den benannten Test fallen sehen, seine Ausgabe lesen —, und der
      **repo-weite** Satz steht auf der Post-integration-Stufe; will sie den automatischen Nachweis
      für ihren Ausschnitt, fährt sie `MUTATE_ONLY='<ihre Fälle>' make mutate`. **Eigentum:**
      Implementer ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
      Festlegung 1, `Accepted`) — der Planner schreibt sie nicht. Dieselbe Aussage an
      [`.claude/agents/implementer.md`](../../../../.claude/agents/implementer.md) Zeile 28 ist
      eine **Übergabe ohne geschlossene Zuständigkeit** (§1 *Eigentum*, §6 Risiko 1): sie wird
      gezogen oder ausdrücklich stehen gelassen — **beides mit benanntem Träger**. *Was ihn rot
      färbt: die alte Zeile steht noch — das ist am Satz selbst ablesbar, und genau das ist der
      Zustand vor diesem Slice.*

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die Grenze des Laufs steht in
      [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) und im Hilfetext des
      Ziels — Liefer-Punkt (2) **ist** dieses Item, ein zweiter Doku-Ort entsteht nicht: die
      Werkzeug-Zeile in [`harness/README.md`](../../../../harness/README.md) §Werkzeuge **zeigt**
      auf die Sensordatei und führt die Aussage nicht als zweite Fassung.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — **hier nicht**: Dieses
      Repo fährt Wellen-Betrieb (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein
      Erwartungswert), also prüft sie die nächste Welle-Closure, auch für diesen Slice ohne
      Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | (1) die Auswahl an der **einen** Stelle, an der die Fall-Liste entsteht, und (2a) die Bindung der Beleg-Logik an die Vollständigkeit des Laufs |
| `Makefile` | update | (1) `MUTATE_ONLY` in derselben Form durchreichen wie `MUTATE_JOBS`; (2b) der Hilfetext des Ziels nennt den Unterschied |
| [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) | update | (2b) die Grenze des Teillaufs als Vertrag und die **Stufe** in der `Bindung`-Zeile |
| `test/mutate-driver.bats` | update | (1)/(2) die Auswahl als **reine** Funktion, die leere Auswahl, die Beleg-Hälfte, die Auswahl-Zeile der Ausgabe — die Hausform der übrigen Treiber-Tests (`failure_form`, `narrow_sensor`, `case_mode`, `queue_new`): sourcen, hermetisch fahren (`grep -c '^@test' test/mutate-driver.bats` → **57** vor dem Slice, kein Erwartungswert) |
| `test/mutations/NNN-mutate-*.sh` | neu | (1)/(2) je Zusage ein Fall — `# files: harness/tools/mutate.sh`, `# expect: driver: <Titel des bats-Tests>` (die Form der 39 bestehenden) |
| [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) | update | (3) die Zeile, die den vollen Lauf als Rundenpflicht führt — **Übergabe an den Implementer** ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) |
| [`.claude/agents/implementer.md`](../../../../.claude/agents/implementer.md) | update | (3) dieselbe Aussage in der Typkarte — **Übergabe ohne geschlossene Zuständigkeit** (§1 *Eigentum*, §6 Risiko 1) |

**Ansatz als Liste — was eine Zeile pro Datei nicht trägt:**

- **Die Auswahl geschieht an genau einer Stelle.** `main()` baut die Fall-Liste
  (`cases=("$CASES_DIR"/*.sh)`) und leitet daraus alles Weitere ab: Numerierung, `CASE_NAMES`,
  `CASE_MODES`, beide Warteschlangen, `merge_report`, `report_times`. Der Filter greift dort — und
  **nirgends sonst**. Wird er statt dessen auf die Warteschlange oder in `merge_report` gesetzt,
  zählt der Bericht gegen die **volle** Zahl und meldet die nicht gewählten Fälle als *„ohne
  Ergebnis geblieben"* — eine falsche Vollständigkeits-Aussage in beide Richtungen. Genau darum
  ist *„die Warteschlange wird nicht umgangen"* kein Detail, sondern der Grund, warum die Auswahl
  **vor** ihr sitzt: sie erbt die Warteschlangen-Eigenschaft, statt sie zu umgehen.
- **Die Auswahl ist eine reine Funktion** (`select_cases <muster> <fall-datei>…`), damit der bats-Test
  sie ohne Lauf prüfen kann — dieselbe Bauart, mit der `failure_form`, `narrow_sensor`, `case_mode`
  und `resolve_file_spec` heute geprüft werden. Die Muster sind Shell-Globs gegen den **Fall-Namen**
  (der Basisname ohne `.sh` — dieselbe Identität, die der Bericht druckt und die `# expect:`-Zeile
  trägt). Ein Muster ohne Metazeichen trifft nur sich selbst — `MUTATE_ONLY='197-*'` ist die Form,
  `MUTATE_ONLY='197'` trifft nichts und **fällt fail-closed auf**.
- **Reihenfolge: erst (1), dann (2), dann (3).** Die Anweisungssatz-Zeile schickt auf das Werkzeug
  („fährst du es automatisch, dann so") — sie zu ziehen, bevor (1) steht, verweist auf eine Option,
  die es noch nicht gibt. Umgekehrt gilt: (3) ist **nicht** Voraussetzung für (1) und (2).
- **Der Kommentar-Kopf des Treibers zieht mit** ([`AGENTS.md`](../../../../AGENTS.md) §3.7): der
  Filter und die Beleg-Bindung stehen dort in der Form *was gilt*, nicht *wie es dazu kam*; der
  bestehende Kopf führt die Grenzen des Sensors bereits in dieser Form und wird **ergänzt**, nicht
  umgeschrieben.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice** (WIP-Limit frei) und der
Slice ist priorisiert. Beobachtbar ohne Rückfrage, auf dem **Hauptzweig**:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'   # 0
```

**Der Trigger ist kein Ergebnis dieses Slice** — er spricht über den Bestand *vor* der Arbeit. Er
bindet **keine Abhängigkeit** von einem anderen Slice: die Stufe ist gesetzt (`.github/workflows/mutate.yml`),
und was dieser Slice liefert, hängt an keiner offenen Vorarbeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **die Beleg-Hälfte (2a) verlangt eine
  Änderung an [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  selbst** — etwa einen Beleg-Slot *je Auswahl* statt des einen, den die ADR führt. Dann ist die
  Beleg-Frage ein eigener, ADR-pflichtiger Schnitt und nicht ein Nebensatz dieses Slice.
- `in-progress` → `open` (blockiert — Carveout?): **für
  [`.claude/agents/implementer.md`](../../../../.claude/agents/implementer.md) läßt sich auch die
  *Entscheidung* nicht benennen** — kein Träger, keine angenommene Quelle, kein Auftraggeber-Pfad.
  Dann ist die Zuständigkeits-Frage eine Planungs-/Architekt-Frage und geht **zurück**, statt
  stillschweigend in einen Commit zu rutschen, den keine Rolle deckt
  (die Frage ist als [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)
  geführt).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Die roten Läufe der Liefer-Punkte (1) und (2) stehen mit ihren Kommandos im
   Umsetzungs-Commit** — die Auswahl, die nicht angewandt wird, das Muster ohne Treffer, ein
   grüner Teillauf, der den Beleg schriebe, die fehlende Auswahl-Zeile —, und `make gates` meldet
   **Exit 0**. Das Rot muß die **behauptete** Ursache tragen
   ([`AGENTS.md`](../../../../AGENTS.md) §3.6), nicht irgendeine: die Meldung des Falls wird
   gelesen und benannt.
2. **Der Unterschied ist mit den eigenen Zahlen des Laufs belegt, nicht behauptet.** Auf
   **demselben** Baum, im selben Commit-Zustand, einmal `MUTATE_FORCE=1 make mutate` (voller Satz)
   und einmal ein gefilterter Lauf über die Fälle **eines** Sensors oder **einer** Datei: der
   gefilterte Lauf nennt in seiner Vollständigkeits-Zeile genau die ausgewählten Fall-IDs, und
   **die Wanduhr beider Läufe** steht in der Ausgabe (`report_times` gibt sie je Sensor aus). **Kein
   Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2) — die Zahlen wandern mit Maschine, Cache und Fall-Bestand; tragend ist, daß beide
   genannt sind und ihre Differenz die Größenordnung zeigt, um die es geht.

**Lerneintrag:** die Form entscheidet die Closure und nicht dieser Plan. Wurde mit diesem Slice ein
Sensor oder eine Regel verkörpert, trägt der Eintrag `liegt in <Zielort>` — beim Make-Target auf
dessen Target-Zeile, bei der Sensordatei in ihr (Baseline-Regelwerk
`grundlagen-traceability.md` §Herkunfts-Anker).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Die Typkarten-Zeile hat keinen belegten Träger.** Für
  [`.claude/agents/implementer.md`](../../../../.claude/agents/implementer.md) nennt keine
  angenommene Quelle die schreibende Rolle: [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  nimmt die Klasse aus, [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
  Festlegung 1 nennt den Architect und steht auf `Proposed`. Ein Commit ohne benannten Träger wäre
  genau der Verstoß, den der Adaptions-Block führt.
  **Gegenmittel im Plan:** DoD (3) verlangt die **Entscheidung mit benannter Quelle** — gezogen
  oder ausdrücklich stehen gelassen —, §4 führt die Rückführung nach `open`, §7 nennt das Ergebnis.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(2) Der Filter wird zum Ersatz für den vollen Satz.** Eine Runde meldet „mutate grün" über
  ihrem Ausschnitt, während der repo-weite Satz lokal nie wieder läuft — und seit der Stufen-Änderung
  läuft er auch im Push nicht mehr, sondern nur **nächtlich**.
  **Gegenmittel im Plan:** (2a) bindet die Beleg-Logik an die Vollständigkeit — ein Teillauf kann
  den Voll-Beleg weder erzeugen noch entwerten; (2b) nennt die Auswahl in jeder Ausgabe; und der
  volle Satz hat einen benannten Auslöser (`.github/workflows/mutate.yml`, `MUTATE_FORCE=1`).
  **Benannte Grenze:** *daß* eine Rolle den vollen Satz lokal fährt, erzwingt nichts — das Netz ist
  der Nacht-Job, und seine Kadenzen sind nicht dieser Slice.
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(3) Die Auswahl trifft etwas anderes als gemeint.** Ein Muster, das **nicht** leer ausgeht,
  aber die falschen Fälle zieht, ist für keinen Sensor von der richtigen Auswahl zu unterscheiden —
  die leere Auswahl ist fail-closed gefangen, diese nicht.
  **Gegenmittel im Plan:** die Ausgabe **nennt** die ausgewählten Fall-IDs; ein falscher, aber nicht
  leerer Ausschnitt bleibt damit ein Urteil des Lesers und wird als Grenze benannt, nicht als
  Zusage verkauft (Baseline-Regelwerk `modul-13-quality-gates.md` §Hard Rule, *„Ein Gate ohne seine
  Grenze behauptet ebenfalls zu viel"*).
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>
- **(4) Der Kommentar-Kopf des Treibers wird zur Chronik.** Die Versuchung ist konkret: den
  *Anlaß* des Filters in den Kopf zu schreiben, neben die vorhandenen Befund-Kennungen.
  **Gegenmittel im Plan:** §3 verlangt die Form *was gilt*; der Bestand des Kopfes ist **kein**
  Arbeitsauftrag dieses Slice ([`AGENTS.md`](../../../../AGENTS.md) §3.7).
  — **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu setzen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/sensors/<name>.md>`.
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes der vier mit genau einem Ausgang — siehe §6>
- **Die zwei Anweisungssatz-Zeilen:** <Ergebnis der Übergabe — gezogen, mit der Rolle in der
  Commit-Message | ausdrücklich stehen gelassen, mit dem Grund. **Nicht** dieses Slice'
  Liefergegenstand im Planner-Kontext>
- **Drei Paarungen:** Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** Sub-Areas der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area):

- **`*` (gesamtes Repo, Kürzel `ALL`)** — erfüllt die Schwelle: eigene Regeln (die Hauskonventionen
  der Planungsablage und der Register), eigener Prüfbereich (`make docs-check`, `make gates`),
  eigene Fehlermodi (eine Aussage über einen Lauf, die seine Grenze nicht nennt). Hier liegt der
  Anweisungssatz, liegen `Makefile` und Sensordatei.
- **`harness/tools/` (Kürzel `TOOLS`)** — erfüllt: eigene Regel-Form (die Hausform der Prüfer und
  des Treibers unter `harness/tools/`,
  [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)),
  eigener Prüfbereich (`make shell-lint`, `make test`), eigene Fehlermodi (ein Treiber, dessen
  Auswahl die Warteschlange umgeht, verliert seine Vollständigkeits-Eigenschaft). **`CODEX` ist
  geprüft und nicht berührt.**

`test/` und `.claude/` sind keiner eigenen Sub-Area zugeordnet und laufen unter `*`; sie
auszudifferenzieren wäre eine Deklaration, die dieser Slice nicht braucht (die drei Achsen tragen
für sie keine eigene Regel-Form).

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen —
**114** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **114**, **kein
Erwartungswert**,
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2); alle führen dieselbe Sub-Area `*`. **Zehn Einträge** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand | wo sie diesen Slice trifft |
|---|---|---|---|
| `neuer-waechter-ohne-mutations-fall` | 6× | verkörpert | DoD (1)/(2) — **jeder** neue Wächter dieses Slice braucht seinen Fall in `test/mutations/`, sonst ist er unbewacht |
| `zusage-nennt-sensor-der-form-nicht-sieht` | 15× | geplant | DoD (2b) — die Auswahl-Zeile ist eine Zusage über die **Form** der Ausgabe; der Test liest die Zeile, nicht den Lauf |
| `vollstaendigkeits-zusage-misst-falsche-ebene` | 3× | verkörpert | DoD (2b) — die Vollständigkeits-Zeile eines Teillaufs wäre genau diese Klasse, wenn sie unverändert stehenbliebe |
| `baum-hash-deckt-nicht-jeden-pruefgegenstand` | 1× | offen | DoD (2a) — der Beleg-Schlüssel deckt den Prüfgegenstand nicht ganz; hier bekommt die Aussage eine **zweite** Grenze |
| `roter-nicht-gate-sensor-ohne-instrument` | 1× | offen | §6 (2) — ein Nicht-Gate-Sensor, der rot steht: hier die **Rundenpflicht**, die keine Form für „nicht der volle Satz" kennt |
| `rotierender-pruef-gegenstand-ohne-ort` | 1× | offen | DoD (1) — die Fall-Menge rotiert mit jedem Wächter (siehe die Zahl oben); der Filter wählt aus einer bewegten Menge |
| `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` | 3× | verkörpert | DoD (3)/§3 — die neuen Fälle ankern per `sed` am Treiber und müssen dessen Wortlaut überleben |
| `mutations-fall-an-zeilennummer-verankert` | 1× | offen | DoD (3)/§3 — die neuen Fälle ankern an der **Stelle**, die sie mutieren, nicht an einer Zeilennummer; die Klasse bleibt bei dieser Gelegenheit unter der Schwelle |
| `zahl-neben-nie-gefahrenem-kommando` | 4× | verkörpert | §5 Kriterium 2 — die zwei Zahlen kommen aus der **Ausgabe** des gefahrenen Laufs, nicht aus einem Plan |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3× | geplant | §2 — die drei Liefer-Punkte; die zwei Anweisungssatz-Zeilen sind **eine** Übergabe und kein vierter Punkt |

```sh
for s in neuer-waechter-ohne-mutations-fall zusage-nennt-sensor-der-form-nicht-sieht \
         vollstaendigkeits-zusage-misst-falsche-ebene baum-hash-deckt-nicht-jeden-pruefgegenstand \
         roter-nicht-gate-sensor-ohne-instrument rotierender-pruef-gegenstand-ohne-ort \
         mutations-fall-wird-von-berechtigter-aenderung-entwaffnet \
         mutations-fall-an-zeilennummer-verankert zahl-neben-nie-gefahrenem-kommando \
         slice-plan-umfang-waechst-ueber-umsetzung-hinaus; do
  printf '%s  %s  %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" \
    "$(grep -m1 -oE '(offen|verkörpert|geplant|gestrichen)' docs/plan/planning/observations/BEO-ALL/$s/state.md)" "$s"
done
```

**Keiner der zehn erreicht mit diesem Slice 3×** — vier stehen bei 1× und könnten auf 2× steigen,
sechs stehen bereits darüber (zwei davon `geplant`, mit Kennung eines anderen Slice). **Ein eigener
Folge-Slice entsteht aus der Sichtung also nicht.** Für alles unter der Schwelle bleibt dieser
Sichtungs-Schritt der einzige Leser (Baseline-Regelwerk `modul-06-roadmap.md`, *Wann Arbeit eine
Welle braucht*).

**Modus-Begründungsblock — Umfang.** **Alle berührten Sub-Areas sind GF** — `*` (gesamtes Repo) und
`harness/tools/` führen beide **Greenfield** in der Modus-Deklaration
([`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); kein
Begründungsblock je Sub-Area ist damit fällig, und der Slice ist kein Refactor ohne neue
Berührung — er ergänzt den Bestand, er schneidet ihn nicht um.
