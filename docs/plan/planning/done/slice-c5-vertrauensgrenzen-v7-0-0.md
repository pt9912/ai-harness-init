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
`modul-04-adrs.md` §Bedrohung, Grenze, Ausgang (Pfad: `.harness/baseline/v7.0.0/regelwerk/modul-04-adrs.md`)
(Anker am Zug-Stand verifiziert, `### Bedrohung, Grenze, Ausgang`), der
§6-Vertrag der `architecture.template.md` (Pfad: `.harness/baseline/v7.0.0/templates/spec/architecture.template.md`),
der erweiterte Kontext-Eingang und die erweiterte Klassifikation der
`reviewer.template.md` (Pfad: `.harness/baseline/v7.0.0/templates/.harness/skills/reviewer.template.md`),
die QA-Form der `lastenheft.template.md` (Pfad: `.harness/baseline/v7.0.0/templates/spec/lastenheft.template.md`)
(*eine prüfbare Eigenschaft, die eine Bedrohung abwehrt — nicht die Bedrohung selbst*)
und der Bedrohungs-Absatz der `NNNN-title.template.md` (Pfad: `.harness/baseline/v7.0.0/templates/docs/plan/adr/NNNN-title.template.md`) —,
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

- [x] **LP1 — Referenz-Achsen-Lesung, Nachzug je Fund:** die Bestands-Lesung läuft (je Kommando eine Fundliste, [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form) gegen die fünf neuen Anker-Formen; je Fund aus dem Bestand (`.d-check.yml`-Anker-Deckung, `harness/conventions/`-Eintragsverweise, `AGENTS.md`, `harness/README.md` §Sensors) läuft ein Nachzugs-Zug; bei **0 Funden trägt die Fundliste die Antwort** (Form der Tafel: *keine Treffer sind ebenfalls eine Antwort*). Messung: die Fundliste im §7 der Closure; `make docs-check` grün am Zug-Stand.
- [x] **LP2 — Walk-Verdikt je Form, kein Code-Zug:** die fünf Formen verifiziert **byte-genau aus dem Baseline-Baum** (Integrität: am C1-Pin), kein Pfad unter `internal/emit/templates/`, keine in-code Konstante der fünf Formen in `internal/emit/`-Quellen — Messung: `ls internal/emit/templates/` + `grep -l 'architecture.template\|lastenheft.template\|reviewer.template' internal/emit/*.go` (nur Referenz-Zeilen, keine Inhalte), §7 trägt die Ausgabe-Muster; Änderung an Emitter-Dateien: keine (Negativ-Aussage je git-Diff des Zugs).
- [x] **LP3 — Dogfood-Setzung je Form:** die Dogfood-vs.-Emittierend-Abwägung steht als §7-Entscheidungs-Zeile — der Review-Skill bleibt Bestand (Ausschluss §1 Punkt 2), der §6-Vertrag der Sicht ist der eigene Vorgang; Dogfood-Dateien des Skills/der Sicht/Stand-Zeilen: **unverändert** (Negativ-Aussage je git-Diff des Zugs).

Standard-Pflichten je Slice:

- [x] `make gates` grün — am Zug-Ende; die frische Messung steht in der Paarungs-Zeile §7.
- [x] Review durchgeführt, Report unter `docs/reviews/` mit der **vollständigen** Kennung im Dateinamen — Rollenwechsel nach Schritt 8 des Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review. ✓ [`../../../../docs/reviews/2026-11-25-slice-c5-vertrauensgrenzen-v7-0-0.md`](../../../../docs/reviews/2026-11-25-slice-c5-vertrauensgrenzen-v7-0-0.md) — HIGH 0 · MEDIUM 1 · LOW 0 · INFO 2.
- [x] Doku-Update — trifft nicht: kein LP1-Fund in einem der Index-Artefakte (F1 = 0, Beleg: §7).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register ([`../observations/`](../../planning/observations/)) fortgeschrieben — neues Verzeichnis oder `evidence/`-Nachtrag, kein Zähler-Feld. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. ✓ `evidence/`-Nachtrag [`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../../planning/observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/evidence/slice-c5-vertrauensgrenzen-v7-0-0.md) (Form: [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung); Beleg in §7).
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen) — je Zeile unten. ✓ R1 mit der C7-Kennung, R2 mit Grenze, R3 weiter offen mit Zeiger (`slice-c5-vertrauensgrenzen-v7-0-0` §7).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) — von der Welle-Closure geprüft; im Repo der Wellen-Betriebs-Form — im Paarungs-Commit nach dem `git mv` getragen, Ergebnis in §7.

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

- **R1 — Nachzugsfläche größer als die Tafel schätzt:** die Lesung findet Nachzüge, die ein Umsetzungs-Teil brauchen (§1-Ausschluss trifft sie) oder deren Zahl die drei Liefer-Punkte sprengt. Ausgang: *eingetreten* → je eigenem Nachzug ein Fund im LP1-Katalog und der Nachzugs-Zug im Slice; sprengt die Zahl die M-Schätzung → Rückführung `next` (§4), die Fundliste bleibt der Beleg. **Ausgang (Closure 2026-11-26):** *eingetreten* — die Fundliste (F2/F3, §7) führt die Nachzugs-Posten, und der Nachzugs-Zug für sie ist der Tafel-Zug C7; Adresse: `slice-c7-adaptions-nachzuege-v7-0-0` (Tafel-Kennung, die Slice-Datei entsteht beim Schnitt). Keine Rückführung (§4): die Zahl bleibt in der M-Schätzung.
- **R2 — Review-Konsequenzen über die Slice-Grenze:** künftige Dogfood-Reviews laufen mit der Bestands-Fassung des Skills — die v7-HIGH-Abschwächung („es sei denn, eine aktive ADR akzeptiert genau diese Bedrohung") und die v7-MEDIUM-Kategorie greifen im Dogfood vor einer eigenen Schärfung nicht; im Moment läuft kein aktives Review, und die Formen der Welle (C2–C7) sind Planungs- und Werkzeug-Artefakte ohne laufenden Review-Beleg. Ausgang: *entfallen* mit Grenze — die Grenze steht als Ausschluss §1 Punkt 2 und als §7-Zeile, nicht still grün; läuft vor der Welle-Closure ein echtes Review an, wandert der Ausgang zu *weiter offen* (das Register trägt die Klasse). **Ausgang (Closure 2026-11-26):** *entfallen* mit Grenze — im Zug lief kein Review; die Grenze (Bestands-Kategorien bis zu einer eigenen Schärfung) steht in Ausschluss §1 Punkt 2 („Die Grenze dieser Auslassung steht hier") und als LP3-Zeile in §7.
- **R3 — der Kontext-Eingang-Teil wäre nicht leere Verträge:** die v7-Kontext-Zusätze (architecture-Sicht, `Schärft:`-ADRs, `open/`-Slices) finden im Dogfood reale Adressen (`ARC-*`, `Schärft:`-ADRs) — ihr Einzug in den Skill ist real nachzugsfähig, nicht nur ein Stillstand. Ausgang: *weiter offen* → die Anlage (Skill-Kontext-Zeilen + §6-Form der Sicht) ist der eigene Vorgang aus §1 Punkt 2; er wird in §7 als Vorbild-Zeile benannt, kein stiller Bestand. **Ausgang (Closure 2026-11-26):** *weiter offen* — der Zeiger auf den eigenen Vorgang steht in der LP3-Zeile von §7; die Registers-Sichtung (§8) hielt.

## 7. Closure-Notiz

**Was hat funktioniert:** der Zug blieb eine Lesung ohne Code-Griff — F1 lief 0-fundig, die drei
Negativ-Diffs (LP2/LP3) blieben leer, das Walk-Verdikt brauchte keinen Emitter-Griff. Review:
Report unter [`../../../../docs/reviews/2026-11-25-slice-c5-vertrauensgrenzen-v7-0-0.md`](../../../../docs/reviews/2026-11-25-slice-c5-vertrauensgrenzen-v7-0-0.md)
— HIGH 0 · MEDIUM 1 · LOW 0 · INFO 2; die Auflage des MEDIUM-1 (Lesungs-Belege als §7-Text statt
Übergabe-Meldung) ist mit dieser Notiz getragen.

**LP1 — Fundlisten je Kommando** ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form, jede Zahl am Kommando):

- **F1** — `git grep -nE 'Bedrohung, Grenze, Ausgang|prüfbare Eigenschaft, die eine Bedrohung|Kontext-Eingang' -- AGENTS.md .d-check.yml harness/ ':!harness/conventions/done' ':!.harness/baseline'` → **Exit 1 = 0 in-scope Treffer** (am Closure-Stand 2026-11-26). Die Fundliste trägt die Antwort als 0: kein Nachzugs-Zug aus den fünf Anker-Formen (Form der Tafel: *keine Treffer sind ebenfalls eine Antwort*).
- **F2** —

  ```sh
  grep -n 'v5\.12\.0' harness/conventions/MR-031-die-kommentar-regel-steht-in-der-adoptierten-baseline.md   # 8 Zeilen
  ```

  → **8 Zitat-Stellen: Z. 38, 40, 42, 56, 86, 87, 106, 107** (Eintrag: [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline); der Pfad steht im fenced Block — dieselbe Kommando-Form wie die Messung). Byte-Substanz am v7-Baum (Review-Nachlauf, wiederholt am Closure-Stand): `grep -c '^### 3\.7 Ein Kommentar beschreibt, was da ist$' .harness/baseline/v7.0.0/templates/AGENTS.template.md` → **1**, `grep -c '^### Was ein Kommentar trägt — Code, Konfiguration, Skripte$' .harness/baseline/v7.0.0/regelwerk/grundlagen-harness-dateien.md` → **1** — der Fund ist die Pfad-Form, nicht die Substanz.
- **F3** — `grep -n 'v6\.18\.1' harness/migration.md` → **41 Fundstellen** (Instanz-Register Z. 121–145, Vorlagen-Zuordnung Z. 169–177, Streu-Zeilen Z. 55, 63, 113, 114, 185, 192, 315); die vom Review adressierten Registerzeilen: **Z. 140–144**.
- **Die zwei C7-Adressen namentlich:** (a) [`harness/conventions/MR-031-die-kommentar-regel-steht-in-der-adoptierten-baseline.md`](../../../../harness/conventions/MR-031-die-kommentar-regel-steht-in-der-adoptierten-baseline.md) Z. 106–107 — die `v5.12.0`-Pfadzitate der Reviewer-Skill-Messung; (b) [`harness/migration.md`](../../../../harness/migration.md) Z. 140–144 — die `v6.18.1`-Instanz-Registerzeilen. Beide Posten fallen unter die Tafel-C7-Zelle (Terminologie und Stand-Zeilen des Konventionsspeichers, [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)-Träger); Übergabe-Adresse: `slice-c7-adaptions-nachzuege-v7-0-0` (Tafel-Vorschlag, die Slice-Datei entsteht beim Schnitt).

**LP2 — Walk-Verdikt je Form, kein Code-Zug:**

- `ls internal/emit/templates/` → `agents · baseline-verify.sh · commands · d-check.yml · enforce · observations` — keiner der fünf Form-Pfade liegt darunter.
- `grep -l 'architecture.template\|lastenheft.template\|reviewer.template' internal/emit/*.go` → `internal/emit/emitteddocs_test.go · internal/emit/templates_test.go · internal/emit/templates.go` — Referenz-Zeilen, keine Form-Inhalte; die Quelle der fünf Formen bleibt der Walk über den vendored `/templates/`-Baum.
- Negativ-Diff je Ausschluss-Gruppe: `git diff --name-only ae34e38f..d29be86c -- internal/ .harness/skills/ spec/ Makefile .harness/baseline/` → **leer** — die fünf Formen reisen byte-genau als Baumbestand (Integrität am C1-Pin, Review-Stichprobe `make baseline-verify` → `v7.0.0 OK`, 55 Dateien).

**LP3 — Dogfood-Setzung je Form (Entscheidungs-Zeile):** Der Review-Skill
[`../../../../.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) bleibt Bestand
(Ausschluss §1 Punkt 2 — eigener Urteils-Typ, `v2.3.0`); künftige Dogfood-Reviews laufen bis zu
einer eigenen Schärfung mit den Kategorien des Bestands — die v7-MEDIUM-Kategorie und die
v7-HIGH-Abschwächung greifen im Dogfood bis dahin nicht (R2-Grenze, benannt, nicht still). Die
§6-Form der Sicht ([`../../../../spec/architecture.md`](../../../../spec/architecture.md)) ist der
eigene Vorgang: die Anlage (Skill-Kontext-Zeilen + §6-Form) ist der Vorbild-Zeiger aus R3, kein
stiller Bestand.

**Lern-Eintrag (geschärfte Regel, `· seit slice-c5-vertrauensgrenzen-v7-0-0`):** Lesungs-Übergaben
— Fundlisten je Kommando, Byte-Belege, Walk-Verdikt — trägt die Slice-Closure als Text in §7
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form),
nicht als Übergabe-Meldung; eine Mess-Pflicht in §7 (LP1) liest der Verifier gegen kein Kommando,
solange die Fundliste nur im Lauf-Kontext liegt. Quelle: MEDIUM-1 — Findings HIGH 0 · MEDIUM 1 ·
LOW 0 · INFO 2.

**Beobachtungen:** die MEDIUM-1-Klasse („Übergabe-Beleg steht nur im Lauf-Kontext") zählt als
Beobachtung unter [`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md);
Beleg (`evidence/slice-c5-vertrauensgrenzen-v7-0-0.md`) in der Closure nachgetragen, der Stand des
Eintrags (`verkörpert`) bleibt. Sonst keine Beobachtung angefallen — die §8-Sichtung hielt (keine
Register-Zeile trifft die Referenz-Achse; die einzige `ARC-`-Erwähnung des Registers betrifft
nicht sie, Review-Urteil 4).

**Drei Paarungen (geprüft am 2026-11-26, nach dem `git mv` — Form der Vorgänger-Slices):**

- *(a) Anker:* §7 trägt kein `liegt in`-Feld — der Lern-Eintrag ist gezählt, nicht verkörpert
  (Beleg: Register, `evidence/slice-c5-vertrauensgrenzen-v7-0-0.md`). Grün.
- *(b) Folge-Slice:* §7 nennt als R1-Risiko-Ausgang die Kennung `slice-c7-adaptions-nachzuege-v7-0-0`
  — Tafel-Kennung des C7-Zugs, wie auf der C6/C7-Zeile der
  [Delta-Tafel](../../../../docs/plan/planning/welle-baseline-sprung-v7-0-0.md) §4
  (*„Vorschlag; Slice-Datei entsteht beim Schnitt"*); keine Datei-Adresse genannt, die Paarung
  trägt sie beim Schnitt. Grün — mit dem Grenz-Vermerk, dass die Kennung bis zum Schnitt nur die
  Tafel trägt.
- *(c) Register:* die eine in §7 genannte Beobachtung existiert als Verzeichnis und trägt einen
  nicht leeren Beleg — [`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)
  (8 Belege). Grün.

**Ruhe-Marker:** [`roadmap.md`](../in-progress/roadmap.md) §Offene Wellen — `in-progress/` trägt
nach dem `git mv` nur ihr `roadmap.md`; der Marker „Nichts in Arbeit." trifft den Zustand
(Gegenstück der Zug-Form `d29be86c`).

**Paarungen geprüft am 2026-11-26:** `make docs-check` → 3012 Datei(en) geprüft, 0 Befund(e)
(frische Messung am Paarungs-Commit; der Move-Stand trug Post-Move-Zustand ohne die hier
getragenen Hälften — Paarungs-Häkchen, Ruhe-Marker). `make gates` — grün am Zug-Ende, gemessen
nach den Bestands-Korrekturen unten (Stempel deckt HEAD).

**Bestands-Korrekturen am Zug-Ende (2026-11-26):** der Wächter
`test/ignore-refs-restbreite.bats` (Fall *„jede Top-Level-ignore-refs-Ausnahme deckt genau
die an ihr deklarierte Anzahl Markdown-Links"*) meldete das Paar
`docs/plan/planning/done/** → .harness/baseline/**` mit 16 aufgelösten Links gegen
`# Deckung: 10` — die sechs Baseline-Verweise dieser Datei (§1, §8) trugen Link-Form und
zogen mit dem Move in den gezählten Baum. Korrektur am **Bestand** (Inline-Code-Form mit
`Pfad:`-Angabe), nicht an der Deklaration: eine Verbreiterung des Eintrags verlangt eine
eigene ADR ([ADR-0026](../../../../docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0039](../../../../docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)).

**Offene Reste:** der Deckungs-Zähler hält keinen Puffer für Baseline-Verweise, die Slice-Dateien
beim Move in `done/` einziehen — jede künftige Closure steht vor derselben Wahl (Bestand korrigieren
oder ADR). Benannt, nicht geschlossen.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Beide vorgelagerten Prüfungen vor dem Block:

1. **Sub-Area-Wahl prüfen:** die berührte Sub-Area ist `*` (gesamtes Repo) — der Zug ist eine Referenz-Achsen-Lesung über den Bestand, kein Pfad-Ensemble; Kürzel `ALL`. Schwelle erfüllt.
2. **Offene Beobachtungen sichten:** das Register ([`../observations/BEO-ALL/`](../../planning/observations/BEO-ALL/)) trägt keine Beobachtung, die die Vertrauensgrenzen-Referenz-Achse, den Review-Skill-Urteils-Typ oder die ARC-*-Formen berührt (Lesung je Suchmuster, 2026-11-25) — **keine Treffer sind ebenfalls eine Antwort**; Zähler-Stand `—`.

**Modus-Begründung:** alle berührten Sub-Areas GF — der Sprung ist ein Baumbestand-Übernahme-Form, kein Bestands-Rückbau; Phase-Reife des berührten Bestands (Dogfood-Referenz-Achse) Phase 3 aus der Phase × Modus-Matrix (`modul-02-harness-bootstrap.md`, Pfad: `.harness/baseline/v7.0.0/regelwerk/modul-02-harness-bootstrap.md`); Evidenz-/Diskrepanz-Risiko niedrig (die Lesung ist grep-getragen am Zug-Stand, kein Inventur-Risiko einer Code-Fassung); Reconciliation-Aufwand kein — die Tafel-C5-Zelle verlangt keinen Inventur-Split, ein Carveout ist nicht angelegt, ein Graduation-Trigger entfällt (GF).
