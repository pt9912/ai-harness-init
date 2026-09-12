# Slice slice-223: Der vendored Baum steht auf `v6.7.2`, die fünf Pins ziehen mit, und jede lebende Adresse zeigt dorthin

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht ist angewandt und fällt negativ aus: Es gibt keine
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice — `make gates` und
`make baseline-verify` stehen in §2 und sind damit keine repo-weiten Belege *über* die DoD
hinaus. Der einzige Kandidat für ein solches *Mehr* ist die Buchung des Vollzugs in §Baseline
von [`harness/conventions.md`](../../../../harness/conventions.md); sie ist kein Bündel-Trigger,
weil [`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen sie dem
Lauf zuweist, der den Vollzug ausführt, und weil dieselbe Folgepflicht **Slices** anordnet, keine
Welle. Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood und emittierter Pin, nicht emittierter Inhalt.** Gegenstand sind der vendored
Baum dieses Repos und die fünf gekoppelten Pin-Stellen; zwei davon liegen in
`internal/fetch/baseline.go` und wandern ins Zielrepo. Was ein emittiertes Repo an **Inhalt**
bekommt, entscheidet
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
und nicht diese Datei (§1).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag-Pin ist die
Reproduzierbarkeits-Klammer; er ist auf einen Tag gepinnt, nicht `main`-floating),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (`DefaultTag`/
`DefaultBaselineSHA256` schicken dasselbe Asset ins Zielrepo — deshalb sind sie zwei der fünf
Stellen),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(`make vendor-baseline` stellt her und prüft nicht; der Beleg ist `make baseline-verify` nach
demselben Lauf),
[`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (die regierende Fassung
dieses Sprungs; ihre Folgepflicht *„Planner, fällig vor dem Vollzug"* ordnet diesen Slice an),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (§Wer den Zielstand bewegt —
die Setzung auf `v6.7.2` ist die des Auftraggebers),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2 —
die Drei-Teil-Form, in der der Vollzug gebucht wird),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(committet vendored, netzlos; Setzung 4 trägt die KONVERGENZ-Grenze in §6),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando — und der sha256 steht deshalb **nicht** hier, §2),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Messung unten nennt den Tag, gegen den sie gemessen ist).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind ein vendored
Fremd-Blob, fünf Pin-Werte und Adressen in lebenden Artefakten).

**Verantwortlich:** Implementer-Rolleninhaber dieses Laufs.

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `.harness/baseline/v6.7.2/{regelwerk,templates}` samt `SHA256SUMS` liegt committet im
Baum, die fünf gekoppelten Pin-Stellen tragen `v6.7.2` und den **am Release-Asset gemessenen**
sha256, und jede Adresse in einem **lebenden** Artefakt, die das Tag-Segment nennt, zeigt in den
neuen Baum.

### Die Reihenfolge ist gemessen, nicht vorsichtig

Der Adress-Nachzug ist kein Nachklapp, sondern Teil desselben Liefergegenstands, und zwar aus
zwei getrennten Gründen mit zwei verschiedenen Sichtbarkeiten. Beide Zahlen sind über den
Arbeitsbaum gefahren, der diesen Plan enthält; sie wandern mit dem Bestand und sind **keine
Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

```sh
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 125 Markdown-Links
git grep -lE '\]\([^)]*\.harness/baseline/v6\.5\.0[^)]*\)' -- "${PS[@]}" | wc -l   #  58 Dateien
git grep -oE '`[^`]*\.harness/baseline/v6\.5\.0[^`]*`'     -- "${PS[@]}" | wc -l   #  24 Inline-Code-Pfade
```

**Die 125 Markdown-Links sind gate-sichtbar** und fallen im selben Moment, in dem das
`v6.5.0`-Verzeichnis verschwindet: `links` prüft die Existenz des Ziels, und der Ausschluss
`.harness/baseline/**` in `scan.ignore` nimmt den Baum vom **Scannen** aus, nicht vom
**Verweis-Ziel-Sein**. Zwischen dem Tausch-Commit und dem Nachzugs-Commit ist das Repo rot; beide
gehören deshalb in denselben Push (`v6.5.0` · `regelwerk/grundlagen-traceability.md`
§Herkunfts-Anker, *„Beide Commits gehören in denselben Push"*).

**Die 24 Inline-Code-Pfade sind gate-unsichtbar** und werden es bleiben:
`codepaths.roots: [spec, docs, harness]` vergleicht Präfix-**Zeichenketten**, und `.harness`
beginnt nicht mit `harness` — [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md)
§Modul `codepaths` führt die Messung samt der verworfenen Reparatur. Sie sind der Grund, warum die
Liste oben aus einem `git grep` kommt und nicht aus einem Gate-Lauf.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Delta-Urteil über den neuen Stand.** Welche Regel der Fassung `v6.7.2` welches Artefakt
  dieses Repos trifft, ist Gegenstand von
  [slice-224](../open/slice-224-delta-nachweis-und-planungs-nachzug.md) (Nachweis und
  Planungs-Ebene) und [slice-225](../open/slice-225-gate-index-steht-einmal.md) (Norm- und
  Gate-Ebene). Dieser Slice bewegt Bytes und Adressen, er fällt kein Urteil — *Folge-Slice
  übernimmt es*, und beide nehmen die Sendung an (ihr §1 nennt genau diesen Gegenstand).
- **Keine eingefrorene Adresse wird berührt.** Was in `docs/reviews/**`,
  `docs/plan/planning/done/**`, `docs/plan/carveouts/done/**`, im Beobachtungs-Register und in
  einer `Accepted`-ADR auf `v6.5.0` zeigt, bleibt stehen — [`AGENTS.md`](../../../../AGENTS.md)
  §3.4 und §3.11 sperren die Reparatur, und die Klasse hat mit
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) bereits ihr Verdikt:
  *Bestand bleibt bewusst stehen*.
- **Kein zweites Referenz-Ventil in [`.d-check.yml`](../../../../.d-check.yml).** Jedes weitere
  `ignore-refs`-Paar ist eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 mit eigener
  ADR; dieser Slice löst die 125 Links durch **Nachzug**, nicht durch Ausnahme — *es wäre ein
  anderer Vorgang*.
- **Kein Inhalt der emittierten Ebene.** Die **Pin**-Hälfte gehört zwingend hierher:
  `DefaultTag`/`DefaultBaselineSHA256` sind zwei der fünf gekoppelten Stellen, und wer sie stehen
  ließe, färbt `make gates` rot. Die **Inhalts**-Hälfte — was ein Zielrepo an Vorlagen, Modulen und
  Sensor-Verzeichnis bekommt — hat einen eigenen Prüfbereich und einen eigenen Beleg
  (`make full-smoke`, nicht `make gates`) und liegt bei
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  und [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  — *Schicht-Abgrenzung*.
- **Keine Buchung in §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md).**
  Die Datei ist Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8); der Vollzug wird in
  der Drei-Teil-Form von [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  Festlegung 2 gebucht, und dieser Slice liefert dafür das Übergabe-Artefakt (§2, Liefer-Punkt 3)
  — *es wäre ein anderer Vorgang, und zwar einer anderen Rolle*.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte. Gezählt ist nur, was mit dem Umfang wächst.

- [ ] **1 — Der vendored Baum steht auf `v6.7.2`.**
      `.harness/baseline/v6.7.2/{regelwerk,templates}` samt `SHA256SUMS` liegt committet, das
      `v6.5.0`-Verzeichnis existiert nicht mehr, und `make baseline-verify` meldet
      `baseline-verify: v6.7.2 OK — <N> Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
      **Die Dateizahl ist kein Erwartungswert** — tragend ist das `OK`. Der Baum entsteht aus
      dem verifizierten Release-Asset über `make vendor-baseline`
      ([`harness/sensors/vendor-baseline.md`](../../../../harness/sensors/vendor-baseline.md)),
      nicht per Hand-Kopie aus einem fremden Arbeitsbaum; das Ziel ist **kein Gate** und steht in
      keiner Prerequisite-Kette — der Beleg ist `make baseline-verify` nach demselben Lauf
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] **2 — Die fünf gekoppelten Pin-Stellen tragen `v6.7.2` und den am Asset gemessenen sha256.**
      Die fünf Stellen sind `BASELINE_TAG`/`BASELINE_ZIP_SHA256` im `Makefile` (kanonisch), das
      `sources`-Paar `url`/`sha256` in [`.d-check.yml`](../../../../.d-check.yml) und
      `DefaultTag`/`DefaultBaselineSHA256` in `internal/fetch/baseline.go`; die vier
      nicht-kanonischen sind fail-closed an das Makefile-Paar gekoppelt und laufen in `make gates`
      (`test/sources-pin.bats`, `TestDefaultTag_MatchesBaseline`,
      `TestDefaultBaselineSHA256_MatchesMakefile`). `make regelwerk-check` (Netz, **nicht** in
      `make gates`) meldet `0 Befund(e)`, EXIT 0.

      **Der sha256 wird am Release-Asset gemessen, nicht aus einer Erwartung übernommen** —
      [`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) sagt es zu, und der in
      [`ADR-0043`](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) genannte Wert gehört zu
      `v6.7.1` und ist hier falsch. **Dieser Plan nennt ihn nicht**: ihn hier zu führen hieße, eine
      Zahl ohne ihr Kommando zu setzen
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
      Steht der Wert im Umsetzungs-Lauf nicht neben dem Kommando, das ihn liefert, ist dieser
      Liefer-Punkt offen.

      **Kein Gate deckt die Kopplung Baum ↔ Pin:** `baseline-verify` entdeckt das
      `<tag>`-Verzeichnis, statt `BASELINE_TAG` zu lesen, und `test/sources-pin.bats` koppelt die
      fünf nur untereinander — beide sind grün, während Baum und Pins verschiedene Tags tragen.
      Präzedenz und dieselbe benannte Lücke:
      [slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) DoD 1.
- [ ] **3 — Jede lebende Adresse zeigt in den neuen Baum, und das Übergabe-Artefakt für die
      Buchung liegt vor.** Die drei Kommandos aus §1 liefern über dem Ergebnis-Stand **0**
      Treffer für `v6.5.0` im lebenden Ausschnitt. Der Nachzug läuft je Eigentümer in einem
      eigenen Commit, der die Rolle in seiner Message nennt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8): Planungs- und Sensor-Artefakte im
      Implementations-Kontext, [`AGENTS.md`](../../../../AGENTS.md) und
      [`harness/conventions.md`](../../../../harness/conventions.md) samt
      [`harness/conventions/`](../../../../harness/conventions/) im **Architect**-Lauf,
      [`.claude/commands/`](../../../../.claude/commands/) und
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) bei der Rolle, die
      sie ausführt ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
      Das Übergabe-Artefakt für §Baseline nennt Tag, Datum und den gemessenen sha256; **geschrieben
      wird die Buchung im Architect-Lauf**, nicht hier (§1).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline und
      §Adoptierte Konventions-Quellen tragen den neuen Stand — **als Architect-Commit**, aus dem
      Übergabe-Artefakt aus Liefer-Punkt 3.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v6.7.2/{regelwerk,templates}/` + `SHA256SUMS` | neu | der vendored Baum aus dem verifizierten Release-Asset |
| `.harness/baseline/` (der zuvor darin liegende Tag-Ordner) | entfällt | `make vendor-baseline` bricht bei einem **anderen** vorliegenden Tag vor jedem Zugriff ab (§6); der alte Baum weicht vorher |
| `Makefile` (`BASELINE_TAG`, `BASELINE_ZIP_SHA256`) | update | kanonisches Pin-Paar |
| [`.d-check.yml`](../../../../.d-check.yml) (`sources`-`url`/`sha256`) | update | fail-closed an das Makefile-Paar gekoppelt (`test/sources-pin.bats`) |
| `internal/fetch/baseline.go` (`DefaultTag`, `DefaultBaselineSHA256`) | update | dasselbe Asset wandert ins Zielrepo ([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) |
| 58 lebende `.md` mit 125 Markdown-Links ins Tag-Segment | update | gate-sichtbar; ohne Nachzug meldet `links` `target-missing` (§1) |
| 24 Inline-Code-Pfade in lebenden Artefakten | update | gate-unsichtbar; Träger ist dieser Plan, nicht ein Sensor (§1) |
| Übergabe-Artefakt an den Architect (Tag · Datum · gemessener sha256) | neu | §Baseline von [`harness/conventions.md`](../../../../harness/conventions.md) ist Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) steht auf `Accepted` — ablesbar
am Kopffeld `**Status:**` der Datei und an ihrer Status-Zelle im
[ADR-Index](../../adr/README.md). Beobachtbar ohne Rückfrage, und **kein Ergebnis dieses Slice**:
Der Accept-Übergang ist Architect-Arbeit und steht in keiner DoD-Zeile von §2.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Adress-Nachzug aus Liefer-Punkt 3
  lässt sich nicht in *einer* Review-Sitzung prüfen — konkret, wenn er über die drei benannten
  Eigentümer-Rollen hinaus eine vierte berührt oder wenn er neben der Tag-Ersetzung eine
  **inhaltliche** Änderung an einer lebenden Aussage verlangt. Dann wird der Nachzug ein eigener
  Slice und dieser behält Baum und Pins.
- `in-progress` → `open` (blockiert — Carveout?): Das Release-Asset `lab-regelwerk.zip` für
  `v6.7.2` ist nicht erreichbar oder sein gemessener sha256 lässt `make vendor-baseline` an der
  Sperre `internal/fetch.SHA256Mismatch` abbrechen. Der Baum bleibt dann unverändert (die Sperre
  greift **vor** jedem Schreibzugriff), und die Frage geht als Meldung zurück an den Auftraggeber,
  nicht in eine Umgehung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make baseline-verify` meldet `v6.7.2 OK` und `make gates` ist
grün über einem Baum, in dem die drei Kommandos aus §1 null `v6.5.0`-Treffer im lebenden
Ausschnitt liefern. (2) Der Review-Report zu diesem Slice liegt unter `docs/reviews/` und trägt
keinen blockierenden Befund. Dazu der Lerneintrag in §7 und für jedes Risiko aus §6 ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die KONVERGENZ von `make vendor-baseline` deckt den Tag-Wechsel nicht.** Das Ziel ersetzt ein
  Verzeichnis nur, wenn es **denselben** Tag trägt; bei einem anderen bricht es vor jedem Zugriff
  ab ([`harness/sensors/vendor-baseline.md`](../../../../harness/sensors/vendor-baseline.md)
  §Grenze). Der Lauf muss das `v6.5.0`-Verzeichnis vorher entfernen — ein Schritt, den kein
  Sensor einfordert. — **Ausgang:** offen bis zur Closure.
- **Zwischen Tausch und Adress-Nachzug ist `make gates` rot** (125 `target-missing`). Wird der
  Tausch allein gepusht, ist der rote Zwischenstand der geprüfte Stand. — **Ausgang:** offen bis
  zur Closure.
- **Ein Nachzug ersetzt eine historisch richtige Adresse.** Unter den 125 Links und 24
  Inline-Pfaden kann einer stehen, der einen **vergangenen** Stand bezeichnet und deshalb richtig
  ist, wie er dasteht; kein Gate unterscheidet das. Register-Stand der Klasse: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/evidence/*.md | wc -l`).
  — **Ausgang:** offen bis zur Closure.
- **Die 24 Inline-Pfade bleiben nach dem Nachzug unbewacht.** Ein beim Nachzug übersehener Pfad
  ist dauerhaft gate-unsichtbar; Register-Stand der Klasse `gate-modul-erreicht-den-vendored-baum-nicht`:
  **2×** (`ls docs/plan/planning/observations/BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht/evidence/*.md | wc -l`).
  Ein Versions-Sensor, der jeden Pin gegen §Baseline hielte, liegt als
  [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) in `open/` und läuft nicht.
  — **Ausgang:** offen bis zur Closure.
- **Offene Pläne in `open/`/`next/` verpflichten nach dem Sprung anders.**
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) und
  [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md) messen ihre Ziel-Form
  als Diff zwischen dem vendored Baum und dem Kurs-Klon; nach dem Tausch vergleicht dasselbe
  Kommando eine Datei mit sich selbst. Register-Stand der Klasse
  `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`: **3×**
  (`ls docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/*.md | wc -l`)
  — die Schwelle ist damit **vor** diesem Slice erreicht, der Lese-Schritt gehört in dessen
  Closure. — **Ausgang:** offen bis zur Closure.

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
  — liegt in `<…>`. Auslöser: `<BEO-ALL/<slug>>`.
  *(Wurde mit diesem Slice nichts verkörpert, entfällt die Teil-Zeile `— liegt in …` ersatzlos.
  Der Eintrag ist dann gezählt, nicht verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <slice-224 (Delta-Nachweis und Planungs-Nachzug) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo,
Kürzel `ALL`), deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area. Die Schwelle ≥ 2 von 3 Achsen ist erfüllt: eigene Konventionen
([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
regelt den vendored Baum), eigener Prüfbereich (`make baseline-verify`,
`test/sources-pin.bats`) und eigene Fehlermodi (Tag-Drift zwischen Baum und Pins). Eine
**engere** Sub-Area trägt nicht: Die 125 Links liegen quer über `harness/`, `docs/`, `spec/`,
`.claude/`, `internal/` und `test/`, und eine Aufteilung nach Verzeichnis schnitte denselben
Vorgang in Stücke, die einzeln keinen Wert haben. `TOOLS` und `CODEX` sind **nicht** berührt:
Pfad-Berührung allein genügt nicht, und keine Aussage dieser beiden Sub-Areas ändert sich.

**Vorgelagert — offene Beobachtungen sichten:** Das Beobachtungs-Register ist am gemergten Stand
durchgegangen — **98** Verzeichnisse
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein Erwartungswert**). Alle
Beobachtungen dieses Repos führen dieselbe Sub-Area `*`, die Sichtung ist also vollständig und
nicht gefiltert. **Fünf Treffer** berühren diesen Slice; ihre Zähler-Stände stehen unten im
Kriterium *Evidenz-/Diskrepanz-Risiko* und als Risiko in §6, jeweils neben dem Kommando, das sie
liefert:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand |
|---|---|---|
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | 3× | offen |
| `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` | 2× | offen |
| `gate-modul-erreicht-den-vendored-baum-nicht` | 2× | offen |
| `baseline-aussage-ohne-mess-tag` | 2× | offen |
| `re-baseline-ohne-inventur-slice` | 2× | offen |

```sh
for s in folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht \
         verweis-nachzug-ersetzt-eine-historisch-richtige-adresse \
         gate-modul-erreicht-den-vendored-baum-nicht \
         baseline-aussage-ohne-mess-tag re-baseline-ohne-inventur-slice; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Einer steht bereits bei 3×** — `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`. Die
Schwelle ist damit **vor** diesem Slice erreicht, nicht durch ihn; der Lese-Schritt, der ihm
seinen Ausgang zuweist, gehört in die Closure und nicht in diese Planung
(`v6.5.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register). Dieser Slice erzeugt
keinen weiteren Beleg für den Eintrag, er benennt ihn als Risiko (§6).

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block entfällt
damit nicht, aber er trägt nur eine Sub-Area.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch. Der vendored Baum, seine Präsenz-Pflicht und sein
  Verifikations-Beleg stehen in
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache);
  die Form der Buchung in §Baseline setzt
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2;
  die Tag-Nennung in einer Baseline-Aussage
  [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist).
  Der Vorgang selbst hat vier Präzedenzfälle mit eigenen Slice-Plänen.
- **Phase-Reife:** Phase 5 für die Pin-Achse (fünf Stellen, drei laufende Kopplungs-Tests in
  `make gates`), Phase 3 für die Adress-Achse (die Regel steht, der Wächter reicht nur an die
  Markdown-Hälfte).
- **Evidenz-/Diskrepanz-Risiko:** mittel, und die Belegquelle ist das Register oben. Die
  tragende Diskrepanz ist nicht Doku gegen Code, sondern **Adresse gegen Baum**: Zwei der fünf
  Treffer (`gate-modul-erreicht-den-vendored-baum-nicht` 2×,
  `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` 2×) sagen, dass der Nachzug in beide
  Richtungen fehlgehen kann — zu wenig (24 unbewachte Inline-Pfade) und zu viel (eine historisch
  richtige Adresse überschrieben). `baseline-aussage-ohne-mess-tag` (2×) trifft diesen Plan selbst:
  jede Messung oben nennt ihren Tag.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund, kein Eintrag im
  Reconciliation-Register. Graduation entfällt (n/a bei GF); der Trigger, der die Adress-Achse auf
  Phase 5 hebt, ist [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) (Versions-Sensor
  über alle Baseline-Pins) — er liegt in `open/` und ist **nicht** Bedingung dieses Slice.
