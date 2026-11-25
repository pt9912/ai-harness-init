# Slice slice-c5-vertrauensgrenzen-v7-0-0: Vertrauensgrenzen-Formen — Referenz-Achse am Stand v7.0.0

**Lifecycle:** Der Zustand dieser Datei ist das Verzeichnis, in dem sie liegt
(`open/`, `next/`, `in-progress/`, `done/`); er wechselt nur durch `git mv`
(Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) —
deren Closure-Trigger trägt das Mehr über die DoD dieses Slice: die Gesamt-Gates
am neuen Stand, der Replay-Lauf `make full-smoke` und der Bestands-Lese-Schritt.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (adoptierter Stand `v7.0.0`, Form-Vorbild der Form-Bezüge) · Form-Bezüge: [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) · [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) · Tafel-Bezug: Delta-Tafel C5 in [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md) §4, gelesen von [`slice-baseline-delta-lesung-v7-0-0`](../done/slice-baseline-delta-lesung-v7-0-0.md).

**Berührte Spec-Stellen:** `—` — die Vertrauensgrenzen-/Bedrohungs-Formen tragen
ihr Stratum aus dem Baseline-Regelwerk (`modul-04-adrs.md` §Bedrohung, Grenze,
Ausgang; `modul-10-review-harness.md` §Finding-Kategorien), keine Festlegung der
[`spec/lastenheft.md`](../../../../spec/lastenheft.md)/[`spec/architecture.md`](../../../../spec/architecture.md)
dieses Repos; die Anforderungs-Seite steht in der `LH-QA`-ID des Felds Bezug.

**Verantwortlich:** pt9912

**Autor:** pt9912 (Planner-Lauf). **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die C5-Formen des v7-Stands reisen als Baumbestand mit dem C1-Zug —
C5 trägt die **Referenz-Achse dieses Bestands** (Tafel-Zeile: *keine Umsetzung*):
die Bestands-Lesung des Dogfood gegen die fünf neuen Anker-Formen —
[`modul-04-adrs.md` §Bedrohung, Grenze, Ausgang](../../../../.harness/baseline/v7.0.0/regelwerk/modul-04-adrs.md)
(Anker am Zug-Stand verifiziert, `### Bedrohung, Grenze, Ausgang`), der
§6-Vertrag der [`architecture.template.md`](../../../../.harness/baseline/v7.0.0/templates/spec/architecture.template.md),
der erweiterte Kontext-Eingang und die erweiterte Klassifikation der
[`reviewer.template.md`](../../../../.harness/baseline/v7.0.0/templates/.harness/skills/reviewer.template.md),
die QA-Form der [`lastenheft.template.md`](../../../../.harness/baseline/v7.0.0/templates/spec/lastenheft.template.md)
(*eine prüfbare Eigenschaft, die eine Bedrohung abwehrt — nicht die Bedrohung selbst*)
und der Bedrohungs-Absatz der [`NNNN-title.template.md`](../../../../.harness/baseline/v7.0.0/templates/docs/plan/adr/NNNN-title.template.md) —,
das Walk-Verdikt je Form (Emitter kopiert aus der Baseline, kein Code-Zug),
und die **Dogfood-vs.-Emittierend-Abwägung** des Review-Skills als Setzung,
die in der Closure-Notiz steht. Der §6-Vertrag dieses Slices:
verwaltet die Formen als Referenz und Entscheidung, keine Um- oder Anlage der
Vertrauensgrenzen in Dogfood-Artefakten.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **C6/C7** — jedes übernimmt seine Tafel-Kennung: `slice-c6-agents-vorlage-v7-0-0` (AGENTS-Formen der Emitter-Templates), `slice-c7-adaptions-nachzuege-v7-0-0` (Terminologie und Stand-Zeilen des Konventionsspeichers — dort läuft [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)). Klasse 1 (Folge-Slices der Tafel; die Kennungen nehmen ihre Punkte an, die Cluster-Zeilen der Tafel nennen ihren Gegenstand).
- **Der Review-Skill-Nachzug und die Dogfood-Sicht-Schärfung** (§6-Form in [`spec/architecture.md`](../../../../spec/architecture.md), die v7-MEDIUM-Kategorie und die HIGH-Abschwächung in [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md)) — Klasse 3 (anderer Vorgang) und Klasse 2 (Bestand bleibt bewusst stehen): Der Dogfood-Skill ist ein Accepted-Artefakt (`v2.3.0`) mit eigener Urteils-Form; ein Nachzug verlangt zwei Anlagen, die der Tafel-Zug nicht trägt — den Einzug der Kontext-Zeilen in die Reviewer-Praxis und die §6-Vertrauensgrenzen-Form in der Architektur-Sicht dieses Repos (deren `ARC-*` und `Schärft:`-Felder existieren real: `spec/architecture.md` trägt den `ARC-`-Adress-Kasten, `git grep -l 'Schärft:' -- docs/plan/adr/*.md` führt drei ADR-Dateien der Distribution-Linie — der [`ADR-Index`](../../../../docs/plan/adr/README.md) trägt ihren Zustand) — bis dahin greift die neue MEDIUM-Kategorie im Dogfood nicht. Die Form-Sprünge der früheren Basellinie zogen den Skill an Adressen, nicht an Urteils-Formen; die Sprung-Züge der v6.18-Linie (`693b05bd`, `18ad6af9`; der `git log --stat` misst ihre Reichweite). **Die Grenze dieser Auslassung steht hier** — künftige Dogfood-Reviews laufen bis zu einer eigenen Schärfung mit den Kategorien des Bestands; sie ist nicht still grün, sondern benannt. Die Anlage ist ein eigener Vorgang (Schärfung der Reviewer-Rolle + der Architektur-Sicht), nicht C5.
- **Der Emitter-Code-Zug** — entfällt als Alternative mit Beleg (Klasse 3, Form des C4-Verdikt): die fünf Formen liegen als Quelldateien im vendored `v7.0.0`-Baum und **keiner** der Pfade führt unter [`internal/emit/templates/`](../../../../internal/emit/templates/); der Emitter ist Walk-Form (`fs.WalkDir` über die vendored `/templates/`, `internal/emit/templates.go`, Regel `inScope`: *ein upstream neu hinzugekommenes Template fliesst damit automatisch mit* — `slice-c4-environment-check-v7-0-0` §R1 hat dieselbe Form am Smoke belegt). Kein Konstante-Griff im Code.
- **Der Modul-14-Umbau als Dogfood-Anlage** — die Umgebungs-Zusage, der Träger und der Tool-Pin-Check dieses Repos stehen ([`AGENTS.md`](../../../../AGENTS.md) §3.9 mit den gepinnten Image-Digests, `make traeger-pins-check`/`make traeger-fetch` je eigener Zeile im Gate-Index [`harness/README.md`](../../../../harness/README.md) §Sensors); die **Ziel**-Form des Umbaus reist als Baumbestand (C1), die Dogfood-Anlage wäre dieselbe Lüge wie C4's Weg B ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): eine Regel ohne lebenden Träger. Klasse 2 (Bestand) und Klasse 3 (die Ziel-Form ist kein Dogfood-Objekt).
- **Eine MR-/ADR-Setzung** — Klasse 3: das Walk-Verdikt und die Setzung sind keine Abweichungen von der Baseline und keine Schwellen-Form; [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) hat keine Bedienung durch diesen Zug.

**Keine Mindestzahl** — fünf echte Ausschlüsse, je eine Begründung einer Klasse.

## 2. Definition of Done

Liefer-Punkte (drei, [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form der Kennung; gezählt nach [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)):

- [ ] **LP1 — Referenz-Achsen-Lesung, Nachzug je Fund:** die Bestands-Lesung läuft (je Kommando eine Fundliste, [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form) gegen die fünf neuen Anker-Formen; je Fund aus dem Bestand (`.d-check.yml`-Anker-Deckung, `harness/conventions/`-Eintragsverweise, `AGENTS.md`, `harness/README.md` §Sensors) läuft ein Nachzugs-Zug; bei **0 Funden trägt die Fundliste die Antwort** (Form der Tafel: *keine Treffer sind ebenfalls eine Antwort*). Messung: die Fundliste im §7 der Closure; `make docs-check` grün am Zug-Stand.
- [ ] **LP2 — Walk-Verdikt je Form, kein Code-Zug:** die fünf Formen verifiziert **byte-genau aus dem Baseline-Baum** (Integrität: am C1-Pin), kein Pfad unter `internal/emit/templates/`, keine in-code Konstante der fünf Formen in `internal/emit/`-Quellen — Messung: `ls internal/emit/templates/` + `grep -l 'architecture.template\|lastenheft.template\|reviewer.template' internal/emit/*.go` (nur Referenz-Zeilen, keine Inhalte), §7 trägt die Ausgabe-Muster; Änderung an Emitter-Dateien: keine (Negativ-Aussage je git-Diff des Zugs).
- [ ] **LP3 — Dogfood-Setzung je Form:** die Dogfood-vs.-Emittierend-Abwägung steht als §7-Entscheidungs-Zeile — der Review-Skill bleibt Bestand (Ausschluss §1 Punkt 2), der §6-Vertrag der Sicht ist der eigene Vorgang; Dogfood-Dateien des Skills/der Sicht/Stand-Zeilen: **unverändert** (Negativ-Aussage je git-Diff des Zugs).

Standard-Pflichten je Slice:

- [ ] `make gates` grün — am Zug-Ende; die frische Messung steht in der Paarungs-Zeile §7.
- [ ] Review durchgeführt, Report unter `docs/reviews/` mit der **vollständigen** Kennung im Dateinamen — Rollenwechsel nach Schritt 8 des Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist — nur bei LP1-Fund in einem der Index-Artefakte.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register ([`../observations/`](../../planning/observations/)) fortgeschrieben — neues Verzeichnis oder `evidence/`-Nachtrag, kein Zähler-Feld. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen) — je Zeile unten.
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) — von der Welle-Closure geprüft; im Repo der Wellen-Betriebs-Form — im Paarungs-Commit nach dem `git mv` getragen, Ergebnis in §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Bestands-Lesung (`grep`-Bestand über `AGENTS.md`, `.d-check.yml`, `harness/conventions.md`, `harness/conventions/`, `harness/README.md`) | inspect | Fundliste gegen die fünf Anker-Formen ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form, jede Zahl am Kommando); je Fund ein Nachzugs-Zug |
| `.d-check.yml` / Konventionseinträge / Gate-Index | update je Fund | Anker-Deckung der Referenz-Achse — nur Träger, die einen Fund führen |
| `internal/emit/` | inspect — keine Änderung | das Walk-Verdikt ist eine Lesung: die Quelle der fünf Formen ist der vendored Baum, nicht der Code (Ausschluss §1 Punkt 3, LP2) |
| `spec/architecture.md`, `.harness/skills/reviewer.md` | entfällt | Klasse 3/2 — siehe §1, zweiter Ausschluss |

**Ansatz als Liste** — die fünf Formen sind gleichrangig, die Lesung führt je Form eine Fundliste:

- `modul-04-adrs.md` §Bedrohung, Grenze, Ausgang — Bestands-Zitate auf den `modul-04`-Anker (der v6-Baum trug den Anker nicht; der Dogfood-**Bestand** war bei der letzten Lesung 0-fundig, gemessen am 2026-11-25).
- §6 der `architecture.template.md` · Kontext-Eingang/Klassifikation der `reviewer.template.md` · QA-Form der `lastenheft.template.md` (prüfbare Eigenschaft statt der Bedrohung selbst) · Bedrohungs-Absatz der `NNNN-title.template.md` — Bestands-Zitate auf die v6-Formen dieser vier Vorlagen-Namen (drei davon sind in C2 zu den englischen Namen umgezogen; die Referenz-Züge tragen die C2-Formen, der C5-Zug prüft den v7-Inhalt dagegen).

## 4. Trigger

**Start (`open` → `next`, `next` → `in-progress`):** [`slice-c4-environment-check-v7-0-0`](../done/slice-c4-environment-check-v7-0-0.md) liegt in `done/` — beobachtbar am Verzeichnis; die Delta-Tafel §4 der [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md) trägt C5 als geordneten Vorschlag. Welle-Reihen-Form: der Auftrag des Cluster-Schnitts; der Implementer übernimmt.

**Rückführungen — vorab benennen:**
- **`in-progress` → `next` (zu groß / Schnitt falsch):** die Lesung findet Nachzugs-Züge über der Tafel-M-Schätzung (mehr Funde als drei zu ziehende Nachzüge oder einer verlangt eine Umsetzung, die §1 ausgeschlossen hat) — dann zurück: die Fundliste bleibt, die Nachzüge zerlegen sich in eigene Slices (Klasse 1 je Ausschluss-Form des Nachzugs).
- **`in-progress` → `open` (Blocker):** der vendored `v7.0.0`-Baum trägt eine der fünf Formen nicht am C1-Stand (`make baseline-verify`-Integrität rot oder Form-Abweichung gegen das Release-Asset) — Blocker mit Carveout-Frage (Modul 7), die Welle trägt den C1-/Ziel-Baum-Vergleich, kein stiller Carveout.

## 5. Closure-Trigger

LP1 trägt die Fundliste (oder die 0-Fund-Antwort) mit je Fund einem geleisteten Nachzugs-Zug, LP2 das Walk-Verdikt je Form, LP3 die §7-Entscheidungs-Zeile der Dogfood-Abwägung; §6 trägt je Risiko einen Ausgang, der Lern-Eintrag steht in §7.

## 6. Risiken und offene Punkte

- **R1 — Nachzugsfläche größer als die Tafel schätzt:** die Lesung findet Nachzüge, die ein Umsetzungs-Teil brauchen (§1-Ausschluss trifft sie) oder deren Zahl die drei Liefer-Punkte sprengt. Ausgang: *eingetreten* → je eigenem Nachzug ein Fund im LP1-Katalog und der Nachzugs-Zug im Slice; sprengt die Zahl die M-Schätzung → Rückführung `next` (§4), die Fundliste bleibt der Beleg. *(Ausgang je Tatsache bei Closure gesetzt.)*
- **R2 — Review-Konsequenzen über die Slice-Grenze:** künftige Dogfood-Reviews laufen mit der Bestands-Fassung des Skills — die v7-HIGH-Abschwächung („es sei denn, eine aktive ADR akzeptiert genau diese Bedrohung") und die v7-MEDIUM-Kategorie greifen im Dogfood vor einer eigenen Schärfung nicht; im Moment läuft kein aktives Review, und die Formen der Welle (C2–C7) sind Planungs- und Werkzeug-Artefakte ohne laufenden Review-Beleg. Ausgang: *entfallen* mit Grenze — die Grenze steht als Ausschluss §1 Punkt 2 und als §7-Zeile, nicht still grün; läuft vor der Welle-Closure ein echtes Review an, wandert der Ausgang zu *weiter offen* (das Register trägt die Klasse).
- **R3 — der Kontext-Eingang-Teil wäre nicht leere Verträge:** die v7-Kontext-Zusätze (architecture-Sicht, `Schärft:`-ADRs, `open/`-Slices) finden im Dogfood reale Adressen (`ARC-*`, `Schärft:`-ADRs) — ihr Einzug in den Skill ist real nachzugsfähig, nicht nur ein Stillstand. Ausgang: *weiter offen* → die Anlage (Skill-Kontext-Zeilen + §6-Form der Sicht) ist der eigene Vorgang aus §1 Punkt 2; er wird in §7 als Vorbild-Zeile benannt, kein stiller Bestand.

## 7. Closure-Notiz

Wird bei der Closure vor dem `git mv` nach `done/` gefüllt — Form des
Vorgänger-Slices: Fundliste und Walk-Verdikt je Kommando, Entscheidungs-Zeile
der Dogfood-Abwägung, Lern-Eintrag, Risiko-Ausgänge, drei Paarungen.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Beide vorgelagerten Prüfungen vor dem Block:

1. **Sub-Area-Wahl prüfen:** die berührte Sub-Area ist `*` (gesamtes Repo) — der Zug ist eine Referenz-Achsen-Lesung über den Bestand, kein Pfad-Ensemble; Kürzel `ALL`. Schwelle erfüllt.
2. **Offene Beobachtungen sichten:** das Register ([`../observations/BEO-ALL/`](../../planning/observations/BEO-ALL/)) trägt keine Beobachtung, die die Vertrauensgrenzen-Referenz-Achse, den Review-Skill-Urteils-Typ oder die ARC-*-Formen berührt (Lesung je Suchmuster, 2026-11-25) — **keine Treffer sind ebenfalls eine Antwort**; Zähler-Stand `—`.

**Modus-Begründung:** alle berührten Sub-Areas GF — der Sprung ist ein Baumbestand-Übernahme-Form, kein Bestands-Rückbau; Phase-Reife des berührten Bestands (Dogfood-Referenz-Achse) Phase 3 aus der Phase × Modus-Matrix ([`modul-02-harness-bootstrap.md`](../../../../.harness/baseline/v7.0.0/regelwerk/modul-02-harness-bootstrap.md)); Evidenz-/Diskrepanz-Risiko niedrig (die Lesung ist grep-getragen am Zug-Stand, kein Inventur-Risiko einer Code-Fassung); Reconciliation-Aufwand kein — die Tafel-C5-Zelle verlangt keinen Inventur-Split, ein Carveout ist nicht angelegt, ein Graduation-Trigger entfällt (GF).
