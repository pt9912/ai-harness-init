# Slice slice-c3-d-check-faecher-v7-0-0: d-check-Fächer am Stand v7.0.0

**Welle:** `welle-baseline-sprung-v7-0-0`

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · Form-Bezüge: [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) (Ruder je emittierter Aktivierung), [`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft), [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff), [`MR-066`](../../../../harness/conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst) (Pin-Form), [`MR-068`](../../../../harness/conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand) (kommentierter Block ohne Gegenstand), [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) (Dogfood-Zug) · Tafel-Bezug: Delta-Tafel C3 in [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md), gelesen von [`slice-baseline-delta-lesung-v7-0-0`](../done/slice-baseline-delta-lesung-v7-0-0.md); Form der Ziel-Fassung: [`ADR-0093`](../../../../docs/plan/adr/0093-ziel-fassung-regiert-den-sprung-v6181.md).

**Berührte Spec-Stellen:** — — die Modul-Zusammensetzung des emittierten Doc-Gates trägt keine Festlegung der Spezifikation; die Bindung trägt [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) auf der Adoptions-Ebene, die Anforderung-Seite steht in den `LH-QA`-IDs des Felds Bezug.

**Verantwortlich:** pt9912

**Autor:** pt9912 (Planner-Lauf). **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Doc-Gate-Konfiguration trägt die zwei d-check-Fächer der Delta-Tafel C3 am Stand `v7.0.0` — die planning-`waves`-Fähigkeit samt ihren PFLICHT-Globs und das pinsync-Modul als Pin-Stellen-Abgleich — je der Form je Ebene: emittiert je [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)-Ruder (Erprobung am dogfood-Lauf · grüner Start über dem frisch emittierten Bestand · rotes Gegenbeispiel in der emittierten Konfiguration), Dogfood je [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)-Form (Schärfung ohne Schwellen-Senkung, rotes Gegenbeispiel als Mutations-Fall). Der d-check-Werkzeug-Pin selbst bleibt am Stand `v0.93.0` ([`MR-066`](../../../../harness/conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **C4–C7** — jedes übernimmt seine Tafel-Kennung: `slice-c4-environment-check-v7-0-0` (die Vorlage `environment-check.template.md`), `slice-c5-vertrauensgrenzen-v7-0-0`, `slice-c6-agents-vorlage-v7-0-0`, `slice-c7-adaptions-nachzuege-v7-0-0`. Klasse 1 (Folge-Slices der Tafel; die Kennungen nehmen ihre Punkte an, die Cluster-Zeilen der Tafel nennen ihren Gegenstand).
- **Der d-check-IMAGE-/Digest-Pin** — Bestand bleibt bewusst stehen: der Pin trägt der Stand [`MR-092`](../../../../harness/conventions.md#mr-092--d-check-pin-v0861-go-sicherheitsfix-prüfverhalten-unverändert)/[`MR-066`](../../../../harness/conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst) am gepinnten `v0.93.0`; ein Sprung wäre eine eigene Pin-Fassung mit eigener Kennung (Klasse 3 — Pin-Wartung ist ein anderer Vorgang als Konfig-Formen, die der Pin nur liest).
- **Das Go-Pin-Paar** (`GO_VERSION ?= 1.27.3` im `Makefile` gegen `go 1.27` in `go.mod`) als weiteres pinsync-Paar — Klasse 3 (anderer Vorgang): pinsync vergleicht die Fanggruppe byte-genau; die zwei Formen (`1.27.3` gegen `1.27`) paaren nicht dieselbe Ziffernfolge, und die Fanggruppe, die beide deckt, misst nicht dieselbe Stelle. Das Urteil darüber ist nicht der C3-Gegenstand; das d-check-Paar trägt, was die Lesung nennt (der Pin des Prüfwerkzeugs selbst).
- **Ein `doc-pinsync`-Rezept in `d-check.mk`** — Klasse 3 (anderer Vorgang): die advisory-Rezepte des Fragments bleiben sonst verbatim vom Werkzeug ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); ein hand-gesetztes Target für ein Modul ohne Tool-Rezept wäre ein [`MR-062`](../../../../harness/conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff)-Sondergegenstand ohne Träger im Tool-Auslauf. Die Block-Aktivierung genügt; der Lauf bleibt über `docs-check` am Gate.
- **Eine ADR zur Dogfood-Aktivierung** — entfällt: die Aktivierung ist eine Schärfung (Klasse [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)), und [`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet Senkungen. Die einzige Senkungs-Anwärterin des Zuges — eine `scan.ignore`-Weitung im Dogfood — wird nicht getragen: der `worktrees`-Ignore wandert nur in die **emittierte** Vorlage (die Form der v7-Baseline selbst), `scan.ignore` der [``.d-check.yml``](../../../../.d-check.yml) dieses Repos bleibt unverändert.

**Keine Mindestzahl** — fünf echte Ausschlüsse, je eine Begründung einer Klasse.

## 2. Definition of Done

Liefer-Punkte (drei, [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form der Kennung; gezählt nach [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)):

- [ ] **LP1 — emittierte Konfiguration** ([`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml)): `scan.ignore` trägt `.claude/worktrees/**` samt Begründung (Klasse Grenze — Form der v7-Vorlage); der planning-Block trägt die `waves:`-Fähigkeit — `dir`, `glob: 'wave-*.md'`, `results-glob: 'wave-*-results.md'`, `mode: many` — samt der GRENZE-Form (d-check ≥ `v0.91.0`, hier `v0.93.0`; Kennung ohne Ziffernfolge ungewertet — die Listen-Hälfte von `## Offene Wellen` ist bei Namens-Form ungewächtert); der pinsync-Block steht als **kommentierter** Standard-Block in v7-Form — **nicht** aktiviert. **Ruder je [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) für die planning-Erweiterung:** Erprobung am dogfood-Lauf (die Glob-Zeilen über dem Dogfood-Bestand), grüner Start über dem frisch emittierten Bestand (Ruhe-Marker + leere Wellen-Menge), rotes Gegenbeispiel **in der emittierten Konfiguration** (Bijektion im Ziel brechen — Datei ohne Zeiger und Zeiger ohne Datei, je Grund-Code `wave-drift`). Messung: `make docs-check` grün am Stand nach dem Zug ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] **LP2 — Dogfood-Konfig** ([`.d-check.yml`](../../../../.d-check.yml)): der planning-Block trägt die zwei expliziten Glob-Zeilen (`glob: 'welle-*.md'`, `results-glob: 'welle-*-results.md'` — die Bestandsform dieser Ablage, bislang am Werkzeug-Default); der pinsync-Block ist **aktiviert** (`modules` + Block) und paart den d-check-Pin byte-genau zwischen `d-check.mk` (`DCHECK_IMAGE ?=`) und `internal/emit/emit.go` (`DefaultImage`); die Grenze Kennung ohne Ziffernfolge ungewertet steht benannt in [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Grenze. **Rotes Gegenbeispiel:** ein verfälschter Pin-Wert an **genau einer** der beiden Quellen färbt `make docs-check` rot — als Mutations-Fall in `test/mutations/` je Anlagen-Form ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand), Anker am Commit je [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)). Messung: `make docs-check` grün am geänderten Bestand.
- [ ] **LP3 — Adaptions-Dokumentation je aktiviertem Modul:** zwei Eintrags-Dateien unter [`harness/conventions/`](../../../../harness/conventions.md) — `MR-<NNN>` (planning: emittierte `waves`-Erweiterung [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)-Form + Dogfood-Glob-Zeilen [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)-Form) und `MR-<NNN>` (pinsync: Dogfood-Aktivierung [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)-Form, emittierter kommentierter Block [`MR-068`](../../../../harness/conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)-Form „verfügbar, ohne Gegenstand") — als **Platzhalter-Form laut diesem Plan**; die Endform trägt der Architektur-Zug je [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)/[`MR-034`](../../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)-Fassung. Messung: die Index-Zeilen in [`harness/conventions.md`](../../../../harness/conventions.md) je Spaltenform der aktiven Tabelle, `make docs-check` prüft die Anker.

Standard-Pflichten je Slice:

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` mit der **vollständigen** Kennung im Dateinamen — der Report trägt die Ruder-Nachweise je emittierter Änderung (Erprobung · grüner Start · rotes Gegenbeispiel, je [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)/[`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)-Maßstab).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist — [`harness/README.md`](../../../../harness/README.md) §Sensors, die `docs-check`-Zeile, falls ihr Vertragstext die Pin-/Glob-Form berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschritten — je Auftreten eine `evidence/`-Datei; keine Beobachtung angefallen ist ebenfalls eine Antwort (§7).
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) — im Repo **mit** Wellen-Betrieb von der Welle-Closure geprüft; hier nur notiert.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/d-check.yml` | update | die drei v7-Formen: `worktrees`-Ignore, planning-`waves`-Fähigkeit mit PFLICHT-Glob-Zeilen und GRENZE-Form, pinsync als kommentierter Block (nicht aktiviert — ein Pin, eine Stelle, kein Gegenstand am frischen Ziel; [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)-Ruder je planning-Erweiterung) |
| `.d-check.yml` | update | planning-Glob-Zeilen (Bestandsform `welle-*`) und pinsync-Block aktiviert: Pin-Paar `d-check.mk` ↔ `internal/emit/emit.go`, byte-genau je Fanggruppe |
| `harness/conventions/MR-096-planning-faecher-am-stand-v7-0-0.md`, `harness/conventions/MR-097-pinsync-faecher-am-stand-v7-0-0.md` | neu | Platzhalter-Kennungen `MR-096` (planning) und `MR-097` (pinsync) — die Nummern nach der zwischenzeitlichen Vergabe von [`MR-094`](../../../../harness/conventions.md#mr-094--die-gegenmessung-eines-d-check-sprungs-schrumpft-auf-die-einheimische-flaeche) (heute, d-check-Sprung v0.93.0); der Adaptions-Durchgang (Eintrags-Datei und Index-Zeile) ist Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und Übergabe dieses Laufs — §7; die End-Form trägt der Architektur-Zug ([`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)) <!-- d-check:ignore: MR-096- und MR-097-Datei sind geplant, nicht angelegt; der Architektur-Zug (AGENTS.md §3.8) legt sie an und setzt die Anker --> |
| `harness/conventions.md` (Index) | update | zwei Zeilen je aktiver Tabelle, Spalten je Form der Ziel-Form; Anker-Form je [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) |
| `harness/sensors/docs-check.md` | update | §Grenze des planning-Moduls: Kennung ohne Ziffernfolge ungewertet, am Dogfood-Bestand benannt; Pinsync-Abschnitt (Messung der Pin-Paarung am geänderten Bestand, je [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)-Form) |
| `test/mutations/<kennung>-d-check-pin-paarung-faerbt-pinsync-rot.sh` | neu | Mutations-Fall: verfälschter Pin-Wert an genau einer der zwei Quellen färbt `make docs-check` rot — Anlage je [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand), Anker am Commit je [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |

**Ansatz als Liste** — die emittierte Ebene zieht als Konfiguration (keine Rezept-Zeilen, keine Tool-Zeilen): die Formen sind die der v7-Vorlage samt ihren Kopfkommentar-Formen; der Dogfood-Zug läuft am Bestand und meldet am ersten `docs-check`-Lauf, ob die Glob- und Pin-Form den Bestand trifft; die Proben laufen je Ebene — die [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)-Ruder am emittierten Stand, der Mutations-Fall am Dogfood-Stand.

## 4. Trigger

**Start (`next` → `in-progress`):** [`slice-c2-template-renames-und-kennungs-formen-v7-0-0`](../done/slice-c2-template-renames-und-kennungs-formen-v7-0-0.md) liegt in `done/` und dieser Plan liegt in `next/`; die Delta-Tafel §4 der [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md) trägt C3 als geordneten Vorschlag — beobachtbar am Zustands-Verzeichnis und am Reihen-Satz der Tafel; der Implementer übernimmt.

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **Bedingung** — die zwei Fächer brauchen getrennte Probe-Züge, die nicht in einer Review-Sitzung zusammen prüfbar sind (z. B. wenn die planning-Bijektions-Proben am Ziel einen eigenen Bootstrap-Lauf je Richtung fordern) — der Slice kehrt zurück und teilt sich in planning- und pinsync-Teil.
- `in-progress` → `open` (blockiert — Carveout?): **Bedingung** — der Dogfood-Lauf am gepinnten `v0.93.0` trägt die neuen Blöcke nicht grün (Form-Abweichung der v7-Vorlage am Pin, oder die Bijektion deckt die Bestands-Formen nicht); dann Carveout-Antrag oder Pin-Sprung als eigene Kennung — kein stilles Überschreiben des Pins.

## 5. Closure-Trigger

DoD vollständig und beobachtbar: die drei Liefer-Punkte geprüft (LP1–LP3 samt Ruder-Nachweisen im Review-Report), `make docs-check` und `make gates` grün, Review-Report unter `docs/reviews/` mit der vollständigen Kennung im Dateinamen, jedes §6-Risiko mit Ausgang, Lerneintrag in §7 — der Übergang nach `done/` ist die beobachtbare Bedingung.

## 6. Risiken und offene Punkte

- **R1 — die Pin-Paarung paart nicht:** die Fanggruppen über `d-check.mk` (`DCHECK_IMAGE ?=`) und `internal/emit/emit.go` (`DefaultImage`) tragen verschiedene Ziffern-Formen oder der Muster-Anker liest keine Stelle — erster Lauf rot. — **Ausgang:** _bei Closure einer der drei: eingetreten (Folge-Slice mit Kennung Muster-Formanpassung) | entfallen (Grund) | weiter offen (→ `BEO-…/…`)._
- **R2 — die planning-Bijektion über dem Dogfood-Bestand:** die 21 Ergebnisnotizen-Formen unter `docs/plan/planning/done/` — falls die Bijektion an der Ergebnisnotiz-Form hängt (`wave-results-missing`/`wave-unregistered`), färben Meldungen den Bestand rot. — **Ausgang:** _bei Closure._
- **R3 — die emittierte planning-`waves`-Fähigkeit rotiert am frischen Ziel:** `make full-smoke` (grüner Start) meldet einen Befund, weil die Roadmap-Vorlage des Skeletts die Bijektion unter der neuen Cap nicht trägt. — **Ausgang:** _bei Closure._
- **R4 — die Grenze Kennung ohne Ziffernfolge ungewertet:** die benannte Offene-Wellen-Zeile des Dogfood (`welle-baseline-sprung-v7-0-0`) liest `waves` als literales Glob-Präfix plus folgende Ziffernfolge — die Listen-Hälfte von `## Offene Wellen` bleibt bei Namens-Form ungewächtert ([`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form, Grenze d-check `v0.91.0`, am `v0.93.0` nachgemessen). — **Ausgang:** _bei Closure; im Regelfall: im Gate-Index ([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Grenze) benannt, nicht geschlossen (`weiter offen` ins Register, wenn die Klasse ein drittes Mal steht)._

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <geschärfte Regel · neuer Sensor · benannte Spec-Lücke — gezählt, nicht verkörpert, sofern nichts mit diesem Slice verkörpert wird>
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt oder `evidence/slice-c3-d-check-faecher-v7-0-0.md` ergänzt — Zähler folgt aus den Dateien | keine Beobachtung angefallen>
- **Folge-Slices:** <`slice-<Kennung>` (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang>
- **Drei Paarungen:** <im Repo mit Wellen-Betrieb von der Welle-Closure geprüft — hier notiert, nicht geprüft>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Areas sind `harness/tools/` (Kürzel `TOOLS`, die Tool-Formen `internal/emit/templates/d-check.yml` und die `docs-check`-Sensor-Doku), `.claude/` (kein — der Zug liest die `.claude/worktrees/**`-Form, ändert sie aber nicht) und `*` (gesamtes Repo, Kürzel `ALL` — die Dogfood-`.d-check.yml` und `harness/conventions/`); jede erfüllt die Inklusions-Schwelle in der Form der Modus-Deklaration — drei Achsen, Schwelle ≥ 2, zu grob ist keine der drei.

**Vorgelagert — offene Beobachtungen sichten:** Register in der Form des gemergten Standes durchgegangen; die Sondierung über die Titel-Felder

```sh
grep -l -iE 'pinsync|\.d-check\.yml|planning-modul|waves-|worktrees' docs/plan/planning/observations/BEO-ALL/*/observation.md
```

nennt Fundstellen, die `.d-check.yml` in Prosa berühren, keine offene Beobachtung, die diese Sub-Area mit 2× trägt: offene Einträge mit benachbartem Gegenstand stehen unter der Schwelle — [`BEO-ALL/interface-formzug-ohne-rezept-nachziehung`](../observations/BEO-ALL/interface-formzug-ohne-rezept-nachziehung/observation.md) (1×, seit `slice-c2-template-renames-und-kennungs-formen-v7-0-0`; berührt Rezept-Zeilen am Emissions-Interface, während C3 keine Rezept-Zeile anfasst) und [`BEO-ALL/ignore-refs-paar-aufnahme-hat-keinen-sensor`](../observations/BEO-ALL/ignore-refs-paar-aufnahme-hat-keinen-sensor/observation.md) (1×; berührt `ignore-refs`-Paare der ADR-Klasse, nicht `scan.ignore`) — beide notiert, keine davon ist durch diesen Slice die dritte Berührung.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
