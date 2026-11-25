# Slice slice-c4-environment-check-v7-0-0: environment-check — Sensor-Vorlage am Stand v7.0.0

**Lifecycle:** Der Zustand dieser Datei ist das Verzeichnis, in dem sie liegt
(`open/`, `next/`, `in-progress/`, `done/`); er wechselt nur durch `git mv`
(Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) —
deren Closure-Trigger trägt das Mehr über die DoD dieses Slice: die Gesamt-Gates
am neuen Stand, der Replay-Lauf `make full-smoke` und der Bestands-Lese-Schritt.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Sensor-Index-Eintrag ohne lebenden Träger) · [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · [`ADR-0057`](../../../../docs/plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md) (Singleton-Default der Vorlagen-Dispositons-Form) · Form-Bezüge: [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) · [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) · Tafel-Bezug: Delta-Tafel C4 in [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md) §4, gelesen von [`slice-baseline-delta-lesung-v7-0-0`](../done/slice-baseline-delta-lesung-v7-0-0.md).

**Berührte Spec-Stellen:** `—` — die Umgebungs-Zusage und der Tool-/Versions-Check
tragen Stratum aus dem Baseline-Regelwerk (`modul-14-docker-harness.md` §Der zweite
Träger: Tool-Pin und Tool-/Versions-Check), keine Festlegung der
[`spec/spezifikation.md`](../../../../spec/spezifikation.md) dieses Repos; die
Anforderungs-Seite steht in den `LH-QA`-IDs des Felds Bezug.

**Verantwortlich:** pt9912

**Autor:** pt9912 (Planner-Lauf). **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die neue v7-Vorlage
[`environment-check.template.md`](../../../../.harness/baseline/v7.0.0/templates/harness/sensors/environment-check.template.md)
 führt — als gestempeltes Singleton je
[`ADR-0057`](../../../../docs/plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md) Festlegung 1 — **das emittierte Skelett**: Die
Emissions-Verankerung trägt am Zug (Quelldatei-Kandidaten-Menge, Fixtur-Form,
Kopier-Form im gebootstrappten Ziel mit Vorlagen-Hint); der Smoke belegt, dass
die Datei im Ziel ankommt; und die **Dogfood-Verankerungs-Abwägung** entscheidet
und steht in der Closure-Notiz. Keine Gate-Aktivierung — die Vorlage ist
gate-neutral (`scan.ignore **/*.template.md`), der Tool-/Versions-Check läuft hier
nicht und die Index-Zeile kommt nach der Form der Vorlage selbst erst mit Skript
und Break-Test dazu.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **C5–C7** — jedes übernimmt seine Tafel-Kennung: `slice-c5-vertrauensgrenzen-v7-0-0` (Vertrauensgrenzen-Texte), `slice-c6-agents-vorlage-v7-0-0` (die AGENTS-Formen — ihr Docker-Block nennt die Sensor-Datei `environment-check.md` unter `harness/sensors/` als Zielort und ist die Referenz-Form dieser Kennung im emittierten AGENTS), `slice-c7-adaptions-nachzuege-v7-0-0`. Klasse 1 (Folge-Slices der Tafel; die Kennungen nehmen ihre Punkte an, die Cluster-Zeilen der Tafel nennen ihren Gegenstand).
- **Die Dogfood-Verankerung — die Sensor-Datei `environment-check.md` unter [`harness/sensors/`](../../../../harness/sensors/) in diesem Repo** — Klasse 3 (anderer Vorgang) und Klasse 2 (Bestand bleibt bewusst stehen): Dieses Repo trägt keinen `make environment-check`-Target, keine Inventar-Deklaration, keinen Break-Test; seine Umgebungs-Zusage trägt der Docker-only-Deckel ([`AGENTS.md`](../../../../AGENTS.md) §3.9, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) mit den gepinnten Image-Digests und den Netz-Sensoren `make traeger-pins-check`/`make traeger-fetch` — je eigener Zeile im Gate-Index ([`harness/README.md`](../../../../harness/README.md) §Sensors), kein Target fehlt. Eine Sensor-Datei ohne lebenden Träger wäre ein behauptetes-Gate-Gegenstand ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6); die Vorlage trägt die Regel selbst: „Eine Index-Zeile … gehört erst dazu, wenn das Skript existiert und sein Break-Test gelaufen ist"). Führt ein gebootstrapptes Ziel selbst einen environment-check ein, ist das ein Ziel-Vorgang, nicht C4. **Weg B (kopieren) entfällt:** die Datei ohne Skript zu kopieren, würde die Lüge, die [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) fängt, in diesem Repo ausdrücken; der Dogfood-Index trägt die Sensor-Zeilen der Dogfood-Sensoren, und eine Vorlagen-Abbildung ohne Träger würde die zweite Quelle derselben Aussage führen.
- **Eine MR-/ADR-Setzung zur Emission** — Klasse 3: die Emission ist keine Gate-Neuheit und keine Schwellen-Form. [`ADR-0057`](../../../../docs/plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md) Festlegung 1 trägt den Singleton-Default; die Fixtur-Form („in-scope", Disposition `f(hint + body)`) trägt der C2-Zug [`slice-c2-template-renames-und-kennungs-formen-v7-0-0`](../done/slice-c2-template-renames-und-kennungs-formen-v7-0-0.md) und nennt diese Kennung im Kommentar (`internal/emit/templates_test.go`); die Vorlage ist gate-neutral. Trägt der Code-Zug eine Form, die kein bestehender Eintrag deckt, benennt er die Lücke in der Closure statt einem erfundenen Eintrag (Klasse Grenze).
- **README-Zahlen 24→28 im Emitter** — entfällt als Alternative mit Beleg: Der Emitter generiert kein README — der Fixtur-Bestand nennt `harness/README.md` als außer Scope (`internal/emit/templates_test.go`), `internal/emit/` führt kein README-Emitter-Modul, und die **24/28-Zahlen der v7-Baseline** stehen im Baseline-Text [`templates/README.md`](../../../../.harness/baseline/v7.0.0/templates/README.md) („24 Dokument-Skelette … 28 Dateien in drei Klassen") — ein Baumbestand, der mit dem C1-/Baseline-Sprung-Zug mitkam, kein Emitter-Angriffspunkt. Die Dogfood-Index-Zahlen bleiben unverändert; der Zug ändert nichts, das an ihrer Form rührt.
- **Der d-check-/a-check-Pin-Zug** — Klasse 3 (anderer Vorgang): der Pin-Wartung-Zug bleibt an der Pin-Fassung-Form ([`MR-066`](../../../../harness/conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst), [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)); der C4-Zug berührt keinen Pin.

**Keine Mindestzahl** — fünf echte Ausschlüsse, je eine Begründung einer Klasse.

## 2. Definition of Done

Liefer-Punkte (drei, [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form der Kennung; gezählt nach [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)):

- [x] **LP1 — Emit-Verankerung:** Die Quelldatei-Pfad-Sektion der Emissions-Form (`internal/emit/` — Fixtur-Aufzählung und der Singleton-Standard-Pfad) führt [`harness/sensors/environment-check.template.md`](../../../../.harness/baseline/v7.0.0/templates/harness/sensors/environment-check.template.md) aus dem vendored `v7.0.0`-Baum, **byte-genau**, kopiert als gestempeltes Singleton mit Vorlagen-Hint; der Fixtur-Zug (falls der C2-Stand am Code-Zug verbleibend ergänzt) trägt die Dispositions-Aussage am Zug. Messung: `make smoke` — die Datei liegt im gebootstrappten Ziel am festen Pfad und enthält den Template-Hint (Kopier-Satz der Vorlage, der ihren Ziel-Ort selbst nennt). **Beleg:** Messtellen-Zug `841346b3` (`harness/tools/smoke.sh:79-96`, Herkunfts-Anker am Ort); die Walk-Form emittierte ohne Code-Zug byte-genau — diff-leer gegen das Release-Asset (Pin sha256 geprüft) und gegen die Ziel-Kopie; Rot-Beleg am Real-Pfad: Hand-Mutation an `emit.inScope` → „smoke 3/5 … fehlt"-Meldung → zurück → zweiter Lauf grün.
- [x] **LP2 — Gate-Auslauf-Abstand:** Die emittierte Form bleibt gate-neutral — keine README-Tabellen-Zeile, kein Target im emittierten Makefile, kein `scan.ignore`-Neu-Eintrag; der Template-Hint der kopierten Datei trägt die Pflicht, „Index-Zeile … erst, wenn das Skript existiert und sein Break-Test gelaufen ist". **Ruder:** die [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)-Form gilt je Gate-Aktivierung — hier entfällt sie; eine Gate-Ruder-Nachweis-Pflicht trägt der Zug nicht. **Grenze der Messung (benannt):** die Smoke-Stufe misst die **Existenz des Skeletts** im Ziel, nicht den Tool-/Versions-Check im Verhalten — der Check selbst (Skript, Inventar, Soll-Quelle, Break-Test) entsteht erst als Ziel-Vorgang und wird von diesem Zug nicht gemessen; die Grenze steht auch in der Closure-Notiz, nicht als `E2E ok`-Aussage gelesen. **Beleg:** die Grenze trägt die Messtelle selbst (`harness/tools/smoke.sh:86-88`:`Gemessen ist hier die Existenz des Skeletts und dessen Gate-Neutralität — NICHT ein Check im Verhalten`); Gate-Neutralität gemessen am emittierten docs-check des Smoke-Ziels — 0 Befunde out-of-the-box.
- [x] **LP3 — Dogfood-Abwägung niedergeschrieben:** keine Kopie der Sensor-Datei in dieses Repo; die Begründung (Klasse 3/2 des ersten Ausschluss-Punkts) trägt die Closure-Notiz als Entscheidungs-Zeile; der Dogfood-Index ([`harness/README.md`](../../../../harness/README.md) §Sensors) bleibt unverändert; keine MR-/Index-Form berührt. **Beleg:** Entscheidungs-Zeile in §7 (Dogfood-Abwägung); der Range-Diff berührt die Dogfood-Datei und den Index nicht (Review, Negativbefunde: „Dogfood-Nicht-Anlage" ohne Befund).

Standard-Pflichten je Slice:

- [x] `make gates` grün — am Zug-Ende bestätigt; die frische Messung steht in der Paarungs-Zeile §7.
- [x] Review durchgeführt, Report unter `docs/reviews/` mit der **vollständigen** Kennung im Dateinamen — [`2026-11-25-slice-c4-environment-check-v7-0-0.md`](../../../reviews/2026-11-25-slice-c4-environment-check-v7-0-0.md) (`3cc9b1a7`; HIGH 0 · MEDIUM 0 · LOW 0 · INFO 1, F-1 → Grenz-Zeile §7, kein Blocker).
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist — nicht betroffen (LP2): `harness/README.md` §Sensors unberührt (Review-Negativbefund „Dogfood-Nicht-Anlage" ohne Befund).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — §7.
- [x] Beobachtungs-Register ([`../observations/`](../../planning/observations/)) fortgeschritten — ein Verzeichnis neu (F-1-Fundklasse): je `observation.md`, `state.md`, `evidence/slice-c4-environment-check-v7-0-0.md` (§7).
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen) — je Zeile unten.
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) — von der Welle-Closure geprüft; im Repo der Wellen-Betriebs-Form — im Paarungs-Commit nach dem `git mv`, Ergebnis in §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates_test.go` | update | die Fixtur-Form trägt die Quelldatei [`harness/sensors/environment-check.template.md`](../../../../.harness/baseline/v7.0.0/templates/harness/sensors/environment-check.template.md) (C2-Stand prüfen: der Eintrag steht; der C4-Zug vollzieht den verbleibenden Code-Pfad, falls die Dispositions-Aussage am Zug noch eine Ausdrucks-Form fehlt) |
| `internal/emit/` Singleton-Standard-Pfad (`templates.go` Weichen / Bootstrap-Kopierweg) | inspect / update je Ist | die Weichen `isRecurring` / `isDerivativeIndex` / `isBrownfieldOnly` treffen die Vorlage nicht — der Singleton-Standard-Pfad emittiert; falls der Fetch-→-Kopierweg fehlt, trägt ihn der Zug ([`ADR-0057`](../../../../docs/plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md) Festlegung 1 Form) |
| Dogfood-Datei `environment-check.md` unter `harness/sensors/` | entfällt | Klasse 3/2 — siehe §1, zweiter Ausschluss |

## 4. Trigger

**Start (`open` → `next`, `next` → `in-progress`):** [`slice-c3-d-check-faecher-v7-0-0`](../done/slice-c3-d-check-faecher-v7-0-0.md) liegt in `done/` — beobachtbar am Verzeichnis; die Delta-Tafel §4 der [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md) trägt C4 als geordneten Vorschlag. Welle-Reihen-Form: der Auftrag des Cluster-Schnitts; der Implementer übernimmt.

**Rückführungen — vorab benennen:**
- **`in-progress` → `next` (zu groß / Schnitt falsch):** unter der Beobachtung, dass der Implementer am Singleton-Kopierweg eine Form findet, die die Emissions-Architektur ([`ADR-0057`](../../../../docs/plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md), Weichen-Form) verlangt — dann zurück: der Code-Zug wird zerlegt, die Fixtur-Form bleibt, der Kopierweg trägt ein Folge-Slice.
- **`in-progress` → `open` (Blocker):** unter der Beobachtung, dass der vendored `v7.0.0`-Baum die Vorlage nicht byte-genau am C1-Stand trägt oder der Fetch die Quelldatei nicht führt — Blocker mit Carveout-Frage (Modul 7), die Welle trägt den C1/Ziel-Baum-Vergleich, kein stiller Carveout.

## 5. Closure-Trigger

Der Emit-Zug hat die Vorlage im gebootstrappten Ziel abgelegt (`make smoke`-Beleg an LP1), die gate-neutrale Form ist benannt (LP2), die Dogfood-Abwägung steht in der Closure-Notiz (LP3), §6 trägt je Risiko einen Ausgang, der Lern-Eintrag steht (§7).

## 6. Risiken und offene Punkte

- **R1 — Singleton-Mechanik:** Der Kopierweg des Emitters (Fetch-Quelldatei → Ziel-Pfad, mit Vorlagen-Hint) liegt nicht bei der Fixtur-Form — die Fixtur prüft die Dispositions-Aussage, der Lauf am `smoke` prüft die Kopie. Ausgang: *entfallen* — der Kopierweg liegt auf der Walk-Form: die drei Weichen (`isRecurring` / `isDerivativeIndex` / `isBrownfieldOnly`) treffen die Vorlage nicht, der Singleton-Standard-Pfad emittiert (`internal/emit/templates.go` `planTemplates`, Fixtur `internal/emit/templates_test.go`) — kein Code-Zug am Zug; die Kopie ist byte-genau gefahren: diff-leer gegen das Release-Asset (Pin sha256 geprüft) und gegen die Ziel-Kopie (Implementer-Zug `841346b3`).

- **R2 — Mess-Ausschnitt:** Die Smoke-Stufe misst die Existenz des Skeletts, nicht den Check im Verhalten — der Check selbst wird nicht ausgeführt (es gibt kein Skript). Ausgang: *entfallen* — die R2-Grenze trägt die Messtelle selbst (`harness/tools/smoke.sh:86-88`: „Gemessen ist hier die Existenz des Skeletts und dessen Gate-Neutralität — NICHT ein Check im Verhalten"); getragen am selben Ort je Plan-Übergabe (LP2: „die Grenze steht auch in der Closure-Notiz, nicht als `E2E ok`-Aussage gelesen") und Review-Übergabe F-1 (Grenz-Zeile der Closure-Notiz statt Verifier-Rot-Nachzug) — Grenz-Zeile in §7, und zwar benannt, nicht still grün.

- **R3 — Zahl-Formen:** Die Fixtur-in-Scope-Menge (Zähler der Fixtur-Datei) und die v7-[`templates/README.md`](../../../../.harness/baseline/v7.0.0/templates/README.md)-Zahlen (24/28) sind Zahl-Aussagen — je [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form trägt der Zug eine geänderte Zahl neben dem Kommando, das sie liefert; der Baseline-Text bleibt am Tag des C1-Zuges. Ausgang: *entfallen* mit Beleg — der Zug ändert keine der beiden Zahl-Formen: die 24/28-Zahlen des Baseline-Texts bleiben unverändert; der README-Emitter generiert kein README — `grep -n 'readme' internal/emit/templates_test.go` nennt nur `project-readme.template.md` und den `README.md`-Quellnamen der `RootReadme()`-Quelle, keine Emissions-Zelle für `harness/README.md` (gemessen am Zug-Stand `841346b3`, 2026-11-25).

## 7. Closure-Notiz

- **Was hat funktioniert:** der Zug lief ohne Code-Änderung — die §3-Tabelle bestätigte die Fixtur-Form am C2-Stand (`internal/emit/templates_test.go`), die Walk-Form emittierte byte-genau (LP1-Belege) und die Messtelle trägt Zusage, Grenze und Herkunfts-Anker am selben Ort ([`harness/tools/smoke.sh`](../../../../harness/tools/smoke.sh) Z. 79–96, `· seit slice-c4-environment-check-v7-0-0`); das emittierte docs-check im Smoke-Ziel meldete 0 Befunde out-of-the-box; `mutate-auswahl` urteilte lokal (Fall `668-pin-fallback-smoke-veraltet`, 1 ≤ 8, [`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)).
- **Was ging anders als geplant:** F-1 (INFO, [`Review-Report`](../../../reviews/2026-11-25-slice-c4-environment-check-v7-0-0.md), `3cc9b1a7`) — die zweite Messtelle hat keinen eigenen Rot-Beleg; der Nachzug über den Real-Träger blieb unvernünftig teuer und die Grenz-Zeile steht stattdessen hier (Wenig-Papier-Modus des Auftraggebers je Review-Übergabe) — siehe unten; kein offener Verifier-Auftrag.
- **Steering-Loop-Eintrag:** [`BEO-ALL/rot-beleg-einer-neuen-smoke-messtelle-nur-hinter-der-ersten-pruefung`](../observations/BEO-ALL/rot-beleg-einer-neuen-smoke-messtelle-nur-hinter-der-ersten-pruefung/observation.md) — die Fundklasse F-1 je Report-Wortlaut („Rot-Beleg einer neuen Smoke-Messtelle nur hinter der ersten von zwei Prüfungen"); gezählt, nicht verkörpert (kein `liegt in`-Feld) — ein Beleg (`evidence/slice-c4-environment-check-v7-0-0.md`), Stand `offen`. **Grenz-Zeile (§3.6-Form):** Die zweite Messtelle (Gate-Neutralität, `harness/tools/smoke.sh:93`) trägt ihren Rot-Beleg nicht — ihre Bindung läuft über die Fall-153-Anspruchs-Fixtur (`test/mutations/153-ziel-anspruch-nicht-neutralisiert.sh` → `TestEmittierteDokumente_NurInitInvarianteZiele`, eine Emissions-Fixtur statt der realen `v7.0.0`-Vorlage); die Grenze steht hier, nicht still grün. Die Messtelle selbst nennt keinen Mechanismus, der den Fall trägt, aber der Rot-Pfad ist real und greifbar (Messtellen-Zug `841346b3`, `grep -q 'make environment-check'`). Keine bestehende Registerklasse trägt die Form — die Messprobe (`grep -rl 'Messtelle\|Rot-Beleg' docs/plan/planning/observations/BEO-ALL/*/observation.md`, 0 Treffer, 2026-11-25) nahm zwei Grenznachbarn zur Kenntnis: [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md) dort fehlt jeder Fall, hier bindet ein Fall auf Mechanismus-Ebene über einer Fixtur; [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) dort bleibt ein grüner Wächter über der Fixture behauptet (Klasse verkörpert, [`AGENTS.md`](../../../../AGENTS.md) §3.6), hier trägt die Messtelle ihren Ausschnitt am eigenen Ort und die Lücke wird an der Grenz-Zeile benannt.
- **Beobachtungs-Register ([`../observations/`](../../planning/observations/)):** ein Verzeichnis neu — [`BEO-ALL/rot-beleg-einer-neuen-smoke-messtelle-nur-hinter-der-ersten-pruefung`](../observations/BEO-ALL/rot-beleg-einer-neuen-smoke-messtelle-nur-hinter-der-ersten-pruefung/) je `observation.md`, `state.md`, `evidence/slice-c4-environment-check-v7-0-0.md`; der Zähler folgt aus den Dateien.
- **Dogfood-Abwägung (LP3, Entscheidungs-Zeile):** *keine Kopie* der Sensor-Datei `environment-check.md` unter `harness/sensors/` — Klasse 3 (anderer Vorgang) und Klasse 2 (Bestand bleibt bewusst stehen), §1 zweiter Ausschluss: die Umgebungs-Zusage dieses Repos trägt der Docker-only-Deckel ([`AGENTS.md`](../../../../AGENTS.md) §3.9, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) mit `make traeger-pins-check`/`make traeger-fetch` je eigener Index-Zeile ([`harness/README.md`](../../../../harness/README.md) §Sensors, unberührt); **Weg B (kopieren) entfällt** — eine Vorlagen-Abbildung ohne Träger wäre ein behauptetes-Gate-Gegenstand ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Führt ein gebootstrapptes Ziel den Check selbst ein, ist das ein Ziel-Vorgang.
- **Folge-Slices:** keine aus diesem Slice — C5–C7 sind Tafel-Adressen der [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md)-Tafel, ihre Slice-Dateien entstehen beim jeweiligen Schnitt (Form des Vorgänger-Slices).
- **Risiken aus §6:** R1/R2/R3 entfallen, je Zeile ein Ausgang — R2 mit Grenze (oben).

## 8. Sub-Area-Prüfungen und Modus-Begründung

Beide vorgelagerten Prüfungen vor dem Block:

1. **Sub-Area-Wahl prüfen:** die berührte Sub-Area ist `*` (gesamtes Repo) — die Emission ist ein Baumschnitt über die Vorlagen-Klassen, kein Pfad-Ensemble unter `harness/tools/` oder `.codex/`; Kürzel `ALL`. Schwelle erfüllt.
2. **Offene Beobachtungen sichten:** das Register ([`../observations/BEO-ALL/`](../../planning/observations/BEO-ALL/)) trägt keine Beobachtung, die die Vorlagen-Emissions-Familie oder die Sensor-Datei-Familie berührt — **keine Treffer sind ebenfalls eine Antwort**; Zähler-Stand `—`.

**Modus-Begründung:** alle berührten Sub-Areas GF — der Sprung ist ein Neueintrag-Form, kein Bestands-Rückbau; Phase-Reife des berührten Bestands (Emitter-Schicht) ist Phase 3 aus der Phase × Modus-Matrix ([`modul-02-harness-bootstrap.md`](../../../../.harness/baseline/v7.0.0/regelwerk/modul-02-harness-bootstrap.md)); Evidenz-/Diskrepanz-Risiko niedrig (die Fixtur-Form prüft die Disposition, der Smoke prüft die Kopie); Reconciliation-Aufwand kein — die C4-Zelle verlangt die Sensor-Zeile nicht, ein Carveout ist nicht angelegt, ein Graduation-Trigger entfällt (GF).
