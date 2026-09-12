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
  [slice-224](../in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md) (Nachweis und
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

- [x] **1 — Der vendored Baum steht auf `v6.7.2`.**
      `.harness/baseline/v6.7.2/{regelwerk,templates}` samt `SHA256SUMS` liegt committet, das
      `v6.5.0`-Verzeichnis existiert nicht mehr, und `make baseline-verify` meldet
      `baseline-verify: v6.7.2 OK — <N> Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
      **Die Dateizahl ist kein Erwartungswert** — tragend ist das `OK`. Der Baum entsteht aus
      dem verifizierten Release-Asset über `make vendor-baseline`
      ([`harness/sensors/vendor-baseline.md`](../../../../harness/sensors/vendor-baseline.md)),
      nicht per Hand-Kopie aus einem fremden Arbeitsbaum; das Ziel ist **kein Gate** und steht in
      keiner Prerequisite-Kette — der Beleg ist `make baseline-verify` nach demselben Lauf
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] **2 — Die fünf gekoppelten Pin-Stellen tragen `v6.7.2` und den am Asset gemessenen sha256.**
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
- [x] **3 — Keine lebende Adresse bleibt auf dem abgelösten Tag, und das Übergabe-Artefakt für die
      Buchung liegt vor.** Die beiden **Link**-Kommandos aus §1 liefern über dem Ergebnis-Stand
      **0**: Ein Markdown-Link ist ein Navigations-Zeiger und damit Adresse von Bauart her.

      **Das dritte Kommando trennt nicht, was hier zu trennen ist, und die Zusage folgt ihm
      deshalb nicht.** Eine Inline-Nennung ist entweder eine **Adresse** — dann gehört sie auf den
      neuen Tag — oder Bestandteil einer **Aussage**, die den Stand nennt, gegen den sie gemessen
      ist
      ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist));
      deren Tag zu ziehen zerstörte die Aussage, und für genau sie hält
      [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
      den Tree-Operand als Ausgang 2 bereit. **Welche der beiden ein Treffer ist, sagt kein
      Kommando** — es ist ein Urteil ([`AGENTS.md`](../../../../AGENTS.md) §3.6), und ein Zähler,
      der beide Klassen addiert, ist als Zusage entweder zu eng oder wertlos. Zugesagt ist
      deshalb: **null Adressen**, und der Rest steht benannt und abgezählt daneben.

      ```sh
      PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
           ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
      git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 0
      git grep -lE '\]\([^)]*\.harness/baseline/v6\.5\.0[^)]*\)' -- "${PS[@]}" | wc -l   # 0
      git grep -oE '`[^`]*\.harness/baseline/v6\.5\.0[^`]*`'     -- "${PS[@]}" | wc -l   # 6
      git grep -lE '`[^`]*\.harness/baseline/v6\.5\.0[^`]*`'     -- "${PS[@]}"           # MR-054, MR-055
      ```

      **Keine Erwartungswerte** — die Zahlen wandern mit dem Bestand. Die **6** stehen in zwei
      Adaptions-Einträgen, führen ihren Mess-Tag im Satz (*„gegen den adoptierten Stand `v6.5.0`
      gemessen"*) und sind **Architect**-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8) —
      dieser Slice schreibt sie nicht. Das Urteil über die Trennung ist in zwei getrennten
      Rollen-Läufen gefällt statt behauptet: Der Reviewer hat jeden Inline-Treffer klassifiziert,
      der Verifier sie unabhängig einzeln gegengelesen, und beide fanden keine Fehlklassifikation.
      Dass ihre **Kommando-Form** die Ausgangs-Pflicht aus
      [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
      nicht einlöst, ist ein eigener Befund und liegt als Beleg im Beobachtungs-Register (§7) —
      nicht als Auflage hier: Der Eintrag ist angenommen, gehört einer anderen Rolle, und die
      Klasse ist älter als dieser Slice.

      Der Nachzug läuft je Eigentümer in einem eigenen Commit, der die Rolle in seiner Message
      nennt ([`AGENTS.md`](../../../../AGENTS.md) §3.8): Planungs- und Sensor-Artefakte im
      Implementations-Kontext, [`AGENTS.md`](../../../../AGENTS.md) und
      [`harness/conventions.md`](../../../../harness/conventions.md) samt
      [`harness/conventions/`](../../../../harness/conventions/) im **Architect**-Lauf,
      [`.claude/commands/`](../../../../.claude/commands/) und
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) bei der Rolle, die
      sie ausführt ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
      Das Übergabe-Artefakt für §Baseline nennt Tag, Datum und den gemessenen sha256; **geschrieben
      wird die Buchung im Architect-Lauf**, nicht hier (§1).
- [x] `make gates` grün über dem Liefer-Stand — real gefahren und durch den Stempel
      `.harness/state/gates-passed.diffsha` gedeckt, den die Verifikation byte-identisch gegen
      `bash harness/tools/working-tree-hash.sh` über dem sauberen Arbeitsbaum gehalten hat.
      **Was der Stempel nicht deckt, steht hier:** den Architect-Nachzug danach und die Commits
      dieser Closure — sie berühren Markdown und einen Rollen-Anweisungssatz, und ihr Lauf liegt
      beim Auftraggeber.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline und
      §Adoptierte Konventions-Quellen tragen den neuen Stand — **als Architect-Commit**, aus dem
      Übergabe-Artefakt aus Liefer-Punkt 3.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

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
  Sensor einfordert. — **Ausgang: entfallen.** Der Wechsel lief als reiner Rename ohne Rest
  (`git show e488119c --name-status | grep -c '^R'` → **55**, Verifikation §3), und
  `make baseline-verify` meldet `v6.7.2 OK`. Die Werkzeug-Eigenschaft bleibt und ist an ihrem Ort
  benannt (§Grenze der Sensor-Beschreibung), also kein stilles Vergessen; für **diesen** Slice hat
  sie keinen Gegenstand mehr.
- **Zwischen Tausch und Adress-Nachzug ist `make gates` rot** (125 `target-missing`). Wird der
  Tausch allein gepusht, ist der rote Zwischenstand der geprüfte Stand. — **Ausgang: entfallen.**
  Der Fehlermodus verlangt einen Push des Tausch-Commits ohne den Nachzug, und den hat es nicht
  gegeben: Keiner der Arbeits-Commits liegt am Remote, alle reisen in **einem** Push.

  ```sh
  for c in e488119c f603136b 30508fc1 38174544 a8968331; do
    git merge-base --is-ancestor $c origin/main && echo "$c gepusht" || echo "$c lokal"
  done   # fuenfmal "lokal"
  ```

  Die Verifikation konnte das nicht feststellen (§7 dort, *„git-lokal nicht beobachtbar"*); über
  `origin/main` ist es beobachtbar.
- **Ein Nachzug ersetzt eine historisch richtige Adresse.** Unter den 125 Links und 24
  Inline-Pfaden kann einer stehen, der einen **vergangenen** Stand bezeichnet und deshalb richtig
  ist, wie er dasteht; kein Gate unterscheidet das. Register-Stand der Klasse: **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/evidence/*.md | wc -l`).
  — **Ausgang: entfallen.** Zwei Rollen haben die Trennung unabhängig gemessen: Der Reviewer hat
  jeden ersetzten und jeden verbliebenen Inline-Pfad klassifiziert, der Verifier die Reste einzeln
  gegengelesen; keine Adresse bezeichnete einen vergangenen Stand. Der Fall, der **doch** eintrat,
  ist ein anderer und steht unten: eine Adresse, die zum **Operanden** einer Messung geworden war —
  nicht eine, die schon Vergangenheit bezeichnete.
- **Die 24 Inline-Pfade bleiben nach dem Nachzug unbewacht.** Ein beim Nachzug übersehener Pfad
  ist dauerhaft gate-unsichtbar; Register-Stand der Klasse `gate-modul-erreicht-den-vendored-baum-nicht`:
  **3×** (`ls docs/plan/planning/observations/BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht/evidence/*.md | wc -l`).
  Ein Versions-Sensor, der jeden Pin gegen §Baseline hielte, liegt als
  [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) in `open/` und läuft nicht.
  — **Ausgang: weiter offen → Beobachtungs-Register.** Eingetreten ist es zweimal, und beide Male
  fand es das Review statt eines Sensors: die zwei toten `cp`-Quellen im Planner-Anweisungssatz und
  die sechs Mess-Zitate in zwei Adaptions-Einträgen. Der dritte Beleg der Klasse ist mit diesem
  Slice geschrieben; ihr Ausgang ist als
  [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)
  geschnitten und wird vom Lese-Schritt der nächsten Welle-Closure zugewiesen.
- **Offene Pläne in `open/`/`next/` verpflichten nach dem Sprung anders.**
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) und
  [slice-214](../open/slice-214-zellengrenze-wird-gemessen-statt-gesetzt.md) messen ihre Ziel-Form
  als Diff zwischen dem vendored Baum und dem Kurs-Klon; nach dem Tausch vergleicht dasselbe
  Kommando eine Datei mit sich selbst. Register-Stand der Klasse
  `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`: **4×**
  (`ls docs/plan/planning/observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/evidence/*.md | wc -l`)
  — die Schwelle war **vor** diesem Slice erreicht.
  — **Ausgang: eingetreten → Folge-Slice mit ID.** Empirisch bestätigt für `slice-213`
  (`diff -q` der beiden Fassungen der Report-Vorlage → leer, EXIT 0); die Prämisse *„nicht
  adoptiert"* ist damit falsch, und mit ihr fielen der §1-Ausschluss, das §6-Risiko und der
  Start-Trigger-Zweig zur Vorgriffs-Frage. Die Sendung nimmt `slice-213` an: seine Prämisse ist im
  Closure-Zug dieses Slice berichtigt, die abgelöste Seite steht als Tree-Operand. `slice-214` ist
  gemessen unberührt — es führt keinen Baum-gegen-Klon-Vergleich und hängt an `slice-213`s
  **Lieferung**, nicht an dessen Prämisse.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-12.

- **Was hat funktioniert:** Die Trennung von **Adresse** und **Aussage**, die §1 in zwei
  Kommando-Klassen zerlegt — gate-sichtbar gegen gate-unsichtbar —, hat den Vorgang tragfähig
  gemacht: Die Markdown-Links fielen mechanisch und laut, und was blieb, war klein genug, um es
  einzeln zu lesen. Getragen hat ebenso, dass die fünf Pins **fail-closed aneinander** hängen statt
  an einer Prosa-Zusage: Der Reviewer hat die Kopplung real rot gesehen —
  [`.d-check.yml`](../../../../.d-check.yml) und `internal/fetch/baseline.go` je auf `v6.7.1` und
  Null-Hash mutiert, danach `not ok 249`/`not ok 250` und beide `--- FAIL:` —, und jede der vier
  Meldungen liest den `Makefile`-Wert zur Laufzeit, koppelt also an die kanonische Quelle statt an
  ein zweites Literal. Und die Provenienz ist diesmal in **beide** Richtungen belegt: `make
  regelwerk-check` hält den Pin gegen das reale Release-Asset, der Vergleich gegen den lokalen
  Kurs-Klon den Baum gegen den Tag. Die Hälfte, die
  [`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte Konventions-Quellen
  ausdrücklich als unbewacht benennt, ist hier durch Handarbeit geschlossen — nicht durch einen
  Sensor, und deshalb beim nächsten Sprung wieder offen.
- **Was ging anders als geplant:** Drei Dinge, alle in derselben Richtung — der Plan schnitt seine
  eigene Reichweite zu klein.
  1. **DoD 3 sagte `0` und meinte `null Adressen`.** Das dritte Kommando zählt jedes
     Inline-Vorkommen und addiert damit zwei Klassen, die derselbe Plan an anderer Stelle trennt.
     Diese Closure hat die Zusage **präzisiert, nicht abgeschwächt** (§2): Sie verlangt null
     Adressen und stellt den benannten Rest daneben. Ein Häkchen neben einem Kommando, das etwas
     anderes misst als die Zusage, friert mit `done/` ein.
  2. **Zwei ausführbare Adressen gehörten keiner der drei Eigentümer-Klassen aus DoD 3**, sondern
     dem Planner: die `cp`-Quellen der Welle-Closure in
     [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md). Der
     Nachzugs-Lauf ließ sie mit der Begründung *gate-unsichtbar* stehen — genau der Begründung, die
     §1 desselben Plans für diese Klasse ausschließt. Behoben ist es nicht durch den neuen Tag,
     sondern durch die **Tag-Form**, die dieselbe Datei in ihrer Quellen-Zeile bereits führte: Sie
     stirbt am nächsten Sprung nicht.
  3. **Der Lese-Schritt gehört nicht in diese Closure.** §8 wies ihn ihr zu; dieses Repo fährt
     Wellen (`ls docs/plan/planning/welle-*.md` → drei Dateien), und dort liest die Welle-Closure,
     was 3× erreicht hat — ausdrücklich auch für Slices ohne Wellen-Zugehörigkeit. Die DoD-Zeile zu
     den drei Paarungen sagt es im selben Plan richtig. Diese Closure schreibt deshalb Belege und
     weist keinen Ausgang zu.
- **Steering-Loop-Eintrag — geschärfte Regel, gezählt und nicht verkörpert:** *Eine Sprung-Inventur
  keilt auf die Eigenschaft `.harness/baseline/v`, nicht auf den abgehenden Tag; und eine
  ausführbare Adresse in einem Anweisungssatz trägt die Tag-Form statt eines Tags.* Auslöser:
  `BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` und
  `BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht`. **Die Teil-Zeile `— liegt in …` entfällt**,
  weil mit diesem Slice nichts verkörpert wurde: Die Zielorte beider Hälften liegen außerhalb
  dieser Rolle und sind geschnitten —
  [slice-209](../open/slice-209-report-trennt-fundort-von-fundmenge.md) für die Fundmengen-Regel,
  [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md) für
  den Prüfer der toten Inline-Pfade. Den Ausgang weist der Lese-Schritt der nächsten Welle-Closure
  zu.
- **Beobachtungs-Register (`../observations/`):** Vier Belege geschrieben, **kein** Eintrag neu
  angelegt — jede Klasse war bereits benannt, und der Zähler folgt den Dateien (keine
  Erwartungswerte):

  ```sh
  for s in gate-modul-erreicht-den-vendored-baum-nicht \
           zahl-ohne-kommando-trifft-ihren-gegenstand-nicht \
           korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge \
           folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht; do
    printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
  done   # 3 · 8 · 5 · 4
  ```

  Zwei Kandidaten aus der Reviewer-Summary sind **nicht** genommen, weil sie die Fälle nicht
  decken: `baseline-aussage-ohne-mess-tag` setzt eine Aussage **ohne** Mess-Tag voraus — die sechs
  Zitate nennen ihren Tag ausdrücklich; `verweis-nachzug-bricht-tree-operand` trifft die Ersetzung
  eines `<sha>:<pfad>`-Operanden beim Lifecycle-Move — hier **fehlt** die Tree-Operand-Form, statt
  zerstört zu werden. Eine Klasse in einen unpassenden Namen zu drücken teilt sie still.
- **Folge-Slices:** [slice-224](../in-progress/slice-224-delta-nachweis-und-planungs-nachzug.md)
  (Delta-Nachweis und Planungs-Nachzug) und
  [slice-225](../open/slice-225-gate-index-steht-einmal.md) (Norm- und Gate-Ebene) — beide Dateien
  in `open/`. **Ein Posten des Architect ist geprüft:** Die Setzung in
  [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline),
  `· seit welle-<NN>` und `· seit slice-<NNN>` blieben zulässig, misst nicht mehr gegen `v6.7.2`
  (`grep -c 'seit slice-<NNN>' .harness/baseline/v6.7.2/regelwerk/grundlagen-traceability.md` →
  **0**, EXIT 1; `grep -c 'seit slice-<Kennung>' …` → **3**, EXIT 0). Die Adresse nimmt die Sendung
  an, aber in **zwei** Zügen: `slice-224` beurteilt die Datei als einen der Delta-Posten und nennt
  nach seinem Liefer-Punkt 3 den Empfänger; sein §1 schließt den **Vollzug** in
  [`harness/conventions/`](../../../../harness/conventions/) aus und adressiert `slice-225`, dessen
  §1 ihn annimmt. Der Eintrag selbst bleibt unangetastet
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4).
- **Risiken aus §6:** fünf, jedes mit genau einem Ausgang — dreimal *entfallen* (KONVERGENZ · roter
  Zwischenstand · historisch richtige Adresse), einmal *weiter offen → Beobachtungs-Register* (die
  unbewachten Inline-Pfade), einmal *eingetreten → Folge-Slice mit ID* (offene Pläne, `slice-213`).
- **Drei Paarungen:** Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit. Die Anker-Paarung hat hier kein Objekt: Dieser
  Eintrag trägt kein Feld `liegt in`, ist also gezählt und nicht verkörpert.

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

Der Stand ist auf den **Schnitt dieses Plans** gepinnt: Ein `ls` über das Register gäbe den
heutigen, und der wandert mit jeder Closure, die einen Beleg schreibt — die Sichtung oben ist aber
die von damals.

```sh
for s in folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht \
         verweis-nachzug-ersetzt-eine-historisch-richtige-adresse \
         gate-modul-erreicht-den-vendored-baum-nicht \
         baseline-aussage-ohne-mess-tag re-baseline-ohne-inventur-slice; do
  printf '%s %s\n' "$(git ls-tree --name-only 3270d806 \
    -- docs/plan/planning/observations/BEO-ALL/$s/evidence/ | wc -l)" "$s"
done   # 3 · 2 · 2 · 2 · 2
```

**Einer steht bereits bei 3×** — `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`. Die
Schwelle ist damit **vor** diesem Slice erreicht, nicht durch ihn; den Ausgang weist der
**Lese-Schritt** zu, und der liegt in einem Repo mit Wellen-Betrieb bei der **Welle-Closure** —
ausdrücklich auch für Slices ohne Wellen-Zugehörigkeit (`v6.7.2` ·
`regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register und §Wann Arbeit eine Welle braucht).
Diese Planung weist ihn nicht zu und benennt den Eintrag als Risiko (§6).

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
