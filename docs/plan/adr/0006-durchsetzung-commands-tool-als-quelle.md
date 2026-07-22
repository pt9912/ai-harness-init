# ADR-0006: Durchsetzungsschicht + Workflow-Commands — Tool-als-Quelle statt Picker

**Status:** Accepted

**Datum:** 2026-07-22

**Autor:** Claude (Pair-Session)

**Bezug:** [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)

**Schärft:** [`architecture.md §Komponenten`](../../../spec/architecture.md) — der *Durchsetzungs-Emitter* und der *Workflow-Command-Emitter* wechseln die Herkunftsklasse (Fetch/Picker → Tool-als-Quelle/Generator).

**Revidiert (Teil-Supersede):** die Picker-Herkunfts-Setzung aus [`ADR-0004`](0004-durchsetzungs-emission.md) (§Entscheidung 1) und die „Durchsetzung + Workflow-Commands bleiben Picker"-Grenze aus [`ADR-0005`](0005-ziel-repo-distribution.md) (§Konsequenzen). Die übrigen Setzungen beider bleiben unberührt und **Accepted**: Guard **bash + awk** + BLOCKED-Set je `--lang` ([`ADR-0004`](0004-durchsetzungs-emission.md) §Entscheidung 2/3), Fetch-vs-Generate der übrigen Klassen ([`ADR-0005`](0005-ziel-repo-distribution.md)). Da [`AGENTS.md`](../../../AGENTS.md) §3.4 nur den **Voll**-Supersede kennt, wird die Teil-Revision **im ADR-Index an ADR-0004 annotiert** (§Entscheidung 1 revidiert) — so kann kein Slice die revidierte Picker-Stanza als aktiv zitieren.

---

## Kontext

[`ADR-0004`](0004-durchsetzungs-emission.md) legte fest, die Durchsetzungsschicht (Stop-Hook,
Command-Guard, Gate-Nachweis/`record-gates`, `CLAUDE.md`, Reviewer-Skill) als **Picker** aus dem
gepinnten Kurs-Template-Satz ins Zielrepo zu emittieren. [`ADR-0005`](0005-ziel-repo-distribution.md)
stellte danach die **Skelett**-Klasse von Picker auf **deterministischen Generator** (Tool-als-Quelle)
um, ließ Durchsetzung und Workflow-Commands aber bewusst bei Picker (§Konsequenzen wörtlich:
„Durchsetzung + Workflow-Commands bleiben Picker (Kurs-Template-Satz)").

Diese Setzung **beißt jetzt**: die Picker-Quelle existiert nicht. Der vendored Kurs-Template-Satz
(`v3.5.0`) trägt `.harness/skills/` (Reviewer-/Closure-Skill), aber **keine** `.claude/`-Hooks, kein
`CLAUDE.md`, keinen Command-Guard und keine `.claude/commands/`. [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
benennt das selbst als Vorbedingung („Kurs-Upstream-Ergänzung … fehlt sie, wird begründet nicht
emittiert"). Ohne Quelle bleibt der ganze Emissions-Cluster unlieferbar — nicht durch einen Tool-Defekt,
sondern durch ein **Quellmodell**, das auf eine Upstream-Ergänzung wartet, die nicht kommt.

**Präzedenzfall (der Hebel):** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)
(Sprachskelett) war ursprünglich ebenfalls Picker; [`ADR-0005`](0005-ziel-repo-distribution.md) stellte es
auf Generator um, **weil das Skelett mechanisch ist** (Verzeichnis-Layout, Gate-Verdrahtung — kein
Kurs-SSoT). Dieselbe Diagnose trifft die Durchsetzungs-**Mechanik** (Stop-Hook, Guard, `record-gates`)
und die Command-**Artefakte**: sie sind Tool-/Prozess-Infrastruktur, nicht die inhaltliche Wahrheit des
Kurses. Der Dogfood trägt für beide eine **erprobte, adaptierbare** Fassung (`.claude/hooks/`,
`harness/tools/`-Guard, `.claude/commands/`).

Die **Annahme, die kippt:** „die Picker-Quelle wartet upstream." Sie tut es nicht — und
[`ADR-0005`](0005-ziel-repo-distribution.md)s **eigenes** Leitprinzip („hole, was Kurs-SSoT ist —
generiere, was mechanisch ist") widerspricht der Picker-Setzung für genau diese mechanischen Klassen.

## Entscheidung

Wir stellen die ausführbare **Durchsetzungs-Mechanik** (Stop-Hook, Command-Guard,
Gate-Nachweis/`record-gates`) und die **Workflow-Commands**
(`.claude/commands/{implement-slice,plan-welle,close-welle}`) von **Picker → Tool-als-Quelle** um: das
Tool bringt eine **generische, per `--lang` parametrierte** Fassung mit — analog zum Sprachskelett
([`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)/[`ADR-0005`](0005-ziel-repo-distribution.md)).
Kein Warten auf eine Kurs-Upstream-Ergänzung.

**Abgrenzung der Klassen** — das Kriterium ist bewusst **zweiteilig** (Natur **und** Verfügbarkeit),
kein sauberer Ein-Achsen-Schnitt:

1. **Tool-als-Quelle** — die ausführbare Mechanik (Hooks, Guard, `record-gates`) + die Command-Artefakte:
   **mechanische/Prozess-Infrastruktur** (kein Kurs-SSoT-Inhalt) **und** im Kurs-Template-Satz **nicht
   vorhanden**. Ableiten (aus den Kurs-Prozess-Modulen + dem erprobten Dogfood-Stand) schlägt
   unbegrenztes Warten — dieselbe Bewegung wie beim Skelett.
2. **Fetch/Picker (unverändert)** — der **Reviewer-/Closure-Skill** (`.harness/skills/`): er **liegt** im
   Kurs-Satz (verfügbare, kurs-nahe Quelle). Ihn zu generieren wäre Eigenbau neben einer vorhandenen SSoT.
3. **Autort (tool-fremd) — NICHT Teil dieser ADR:** `CLAUDE.md` ist ein **Briefing** wie `AGENTS.md`, das
   [`ADR-0005`](0005-ziel-repo-distribution.md) als agent/mensch-autort einstuft; `CLAUDE.md` folgt derselben
   Klasse und wird **nicht** tool-generiert. **Benannte Lücke:** der Kurs-Satz trägt `AGENTS.template.md`,
   aber **kein** `CLAUDE.template.md` — die CLAUDE.md-Quelle ist ein **eigener CR** (Kurs-Ergänzung oder ein
   tool-mitgeliefertes Starter-Template zum Ausfüllen), hier **nicht** entschieden.

Weitere Setzungen:

- **Guard-Bauart unverändert.** Der Command-Guard bleibt **bash + awk**, das BLOCKED-Set bleibt je `--lang`
  parametriert ([`ADR-0004`](0004-durchsetzungs-emission.md) §Entscheidung 2/3 gelten fort) — es ändert sich
  nur die **Herkunft** (Tool statt Kurs-Fetch), nicht die Bauart.
- **Die generische Fassung ist zu AUTORIEREN, nicht 1:1 der Dogfood-Stand.** Der Dogfood trägt eine
  **repo-adaptierte** Durchsetzung (MR-Block, Docker-only, ein konkretes BLOCKED-Set). „Tool-als-Quelle"
  heißt: daraus + den Kurs-Modulen eine **generische, je `--lang` parametrierte** Fassung mit
  **adaptierbaren Markern** ([`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) ableiten.
  „Kein aus dem Nichts" heißt hier: die Fassung ist erprobt + kurs-geerdet — und **jede** Zusage der
  emittierten Durchsetzung wird per [`AGENTS.md`](../../../AGENTS.md) §3.6 **rot gesehen** (die Dogfood-Erprobtheit
  ist Ausgangspunkt, **kein** Beleg für die neue generische Fassung).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Bei Picker bleiben, Templates upstream in den Kurs bringen (Kurs-CR) | Der Kurs bliebe SSoT für alle `.claude/`-Artefakte | Upstream-Abhängigkeit + Wartezeit (unbestimmt); die Mechanik ist **nicht** Kurs-SSoT, sondern Tool-Infrastruktur; reintroduziert die Zwei-Quellen-Drift, die [`ADR-0005`](0005-ziel-repo-distribution.md) beim Embed-Skelett gerade beseitigt hat |
| B — Guard/Hooks als OCI-Image, Commands weiter Picker | kein neuer Host-Dep | `docker run` pro Bash-Call (Latenz) — [`ADR-0004`](0004-durchsetzungs-emission.md) Option B verwarf das schon; löst das **Command**-Quellproblem nicht |
| **C — Tool-als-Quelle für Durchsetzung + Commands (gewählt)** | kein Upstream-Warten; **eine** Quelle (das Tool); konsistent mit [`ADR-0005`](0005-ziel-repo-distribution.md) „generiere das Mechanische"; per `--lang` parametrierbar; sofort lieferbar | das Tool trägt die generische Durchsetzungs-/Command-Fassung (Wartung) + einen Adaptierbarkeits-Contract; im emittierten `.claude/`/`harness/` liegen zwei Herkunfts-Klassen nebeneinander (Skill gefetcht, Rest tool-generiert) |
| D — Gemischt: Mechanik Tool-als-Quelle, Commands upstream-Picker | trennt die zwei Klassen sauber (die [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) ohnehin trennen); Commands blieben Kurs-SSoT | Commands blieben upstream-blockiert (die Quelle fehlt) → dieselbe Warte-Falle wie A für die halbe Fläche; **zwei** Herkunftsmodelle statt einem, ohne Gegenwert (das Command-Artefakt ist so mechanisch wie die Mechanik) |

## Konsequenzen

- Positiv: Cluster A (Durchsetzung + Commands emittieren) wird **ohne Upstream-Blocker lieferbar**; eine
  Quelle statt Picker-Drift; konsistent zum Skelett-Modell ([`ADR-0005`](0005-ziel-repo-distribution.md)).
- Reproduzierbarkeit ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): die Pin-Achse
  wandert vom Kurs-Fetch **ins Tool** — die tool-getragene Fassung ist **deterministisch** (statischer Inhalt
  + `--lang`-Parametrierung, wie der Skelett-Generator: gleiche Eingabe → byte-identisch), also
  gepinnt-reproduzierbar, nicht floating.
- Negativ: das Tool pflegt die **generische** Durchsetzungsschicht + Command-Vorlagen (je `--lang` +
  adaptierbare Marker); der Reviewer-Skill bleibt Fetch — im emittierten `.claude/`/`harness/` liegen
  damit zwei Herkunfts-Klassen.
- Grenze: **a-check** ([`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) ist von dieser ADR
  **nicht** betroffen — sein Blocker sind fehlende hexagonale Schichten (weder Dogfood noch Skelett tragen
  `domain/ports/adapters`), kein Quellmodell. Er bleibt separat aufgeschoben (kein halluziniertes Gate über
  leerem Prüfbereich, [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- Folgepflicht: CRs an [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und
  [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (Picker → Tool-als-Quelle);
  ADR-Index; `architecture.md` §Komponenten nachziehen (Emitter-Herkunftsklasse); welle-04 aus dieser
  Entscheidung schneiden.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Smoke | emittiertes Repo: Durchsetzung liegt **und wirkt** (Stop-Hook/Guard/`record-gates`), `make gates` grün **ohne** node/jq | `make smoke` / `make full-smoke` |
| bats/go-test | Guard-BLOCKED-Set je `--lang` korrekt; Command-Vorlagen tragen die adaptierbaren Marker | `make test` |
| go-test | **Determinismus**: gleiche `--lang` → byte-identische Durchsetzungs-/Command-Ausgabe (wie der Skelett-Generator, [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) | `make test` |

## Re-Evaluierungs-Trigger

Wenn der Kurs die Durchsetzungs-/Command-Templates upstream in seinen Template-Satz aufnimmt → erneut
prüfen, ob Fetch/Picker gegenüber Tool-als-Quelle Vorteile bringt. Es wäre dann dieselbe Abwägung wie beim
Sprachskelett — aktuell zugunsten Generator entschieden ([`ADR-0005`](0005-ziel-repo-distribution.md)).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-22 | Proposed (revidiert die Picker-Herkunft aus [`ADR-0004`](0004-durchsetzungs-emission.md)/[`ADR-0005`](0005-ziel-repo-distribution.md); Präzedenz [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)) | Lastenheft 0.9.0 (CR [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)/[`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) |
| 2026-07-22 | Accepted — nach unabhängigem Review-Pass (6 MEDIUM aufgelöst, 0 HIGH; Kern-Entscheidung unverändert) | [Review-Report](../../reviews/2026-07-22-adr-0006-review.md) |
