# Slice slice-sprung-auf-v680-wird-vollzogen: Jeder Träger des Tags steht auf `v6.8.0`, der Adaptions-Block ist gegen das Delta gelesen, und der Vorlagen-Report liegt vor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht ist angewandt und fällt negativ aus: Es gibt keine
Closure-Bedingung, die mehr beobachtet als die DoD dieses Slice — `make gates` und
`make baseline-verify` stehen in §2 und sind damit keine repo-weiten Belege *über* die DoD
hinaus. Der einzige Kandidat für ein solches *Mehr* wäre die Buchung des Vollzugs in §Baseline
von [`harness/conventions.md`](../../../../harness/conventions.md); sie ist kein Bündel-Trigger,
weil [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Konsequenzen sie dem
Lauf zuweist, der den Vollzug ausführt, und weil dieselbe Folgepflicht **einen Slice** anordnet,
keine Welle. Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood und emittierter Pin, nicht emittierter Inhalt.** Gegenstand sind der vendored
Baum dieses Repos, die fünf gekoppelten Pin-Stellen und die Adressen in lebenden Artefakten; zwei
Pin-Stellen liegen in `internal/fetch/baseline.go` und wandern ins Zielrepo. Was ein emittiertes
Repo an **Inhalt** bekommt, entscheidet
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
und nicht diese Datei (§1).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag-Pin ist die
Reproduzierbarkeits-Klammer, auf einen Tag gepinnt statt `main`-floating — in
[`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Entscheidung der **tragende**
Grund der regierenden Fassung, nicht nur der Rahmen),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (`DefaultTag`/
`DefaultBaselineSHA256` schicken dasselbe Asset ins Zielrepo — deshalb sind sie zwei der fünf
Stellen),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(`make vendor-baseline` stellt her und prüft nicht; der Beleg ist `make baseline-verify` nach
demselben Lauf — und für den Vorgang dieses Slice existiert **kein** Sensor, §6),
[`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) (die regierende Fassung
dieses Sprungs; ihre Folgepflicht *„Planner, fällig vor dem Vollzug"* ordnet diesen Slice an, ihre
Folgepflicht *„Architect, fällig im Durchgang"* den Liefer-Punkt 2),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (§Wer den Zielstand bewegt —
die Setzung auf `v6.8.0` ist die des Auftraggebers; Festlegung 2 trennt Prozedur und Ist-Maßstab,
Festlegung 4 hält die fünf Ausgänge des Adaptions-Durchgangs),
[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (Festlegung 2 —
die Drei-Teil-Form, in der der Vollzug gebucht wird; die ADR steht auf `Proposed`, siehe §6),
[`ADR-0043`](../../adr/0043-ziel-fassung-regiert-den-sprung-v671.md) (Festlegung 2 — die
Leseregel für die Delta-Basis; sie ergibt `v6.7.2` und wird **gelesen**, nicht neu gesetzt),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (das Verdikt für die
eingefrorene Adresse auf den abgelösten Tag: *Bestand bleibt bewusst stehen*),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(committet vendored, netzlos; Setzung 4 trägt die KONVERGENZ-Grenze in §6),
[`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
und
[`MR-056`](../../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)
(die sieben Symlinks in `.claude/rules/`: dieser Slice hängt sie um und rührt den
Auswahl-Maßstab nicht an — §1),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando — und der sha256 steht deshalb **nicht** hier, §2),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Messung unten nennt den Tag, gegen den sie gemessen ist — und genau diese Klasse ist vom
Adress-Nachzug ausgenommen, §2 Liefer-Punkt 1).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind ein vendored
Fremd-Blob, fünf Pin-Werte, Adressen in lebenden Artefakten, das Abweichungs-Register und ein
neuer Bericht unter `docs/migrations/`). <!-- d-check:ignore (geplante Ablage) -->

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-13.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Sprung `v6.7.2` → `v6.8.0` ist vollzogen: der vendored Baum, die fünf gekoppelten
Pin-Stellen, die sieben tag-tragenden Symlinks in `.claude/rules/` und jede Adresse in einem
**lebenden** Artefakt stehen auf `v6.8.0`; der Adaptions-Block ist gegen das Regelwerks-Delta
gelesen und trägt, wo er betroffen ist, einen der fünf Ausgänge; und `docs/migrations/v6.8.0.md` <!-- d-check:ignore (geplante Ablage) -->
hält das Vorlagen-Ergebnis fest.

### Drei Achsen, und sie werden nicht ineinander übersetzt

Der Slice liefert auf drei getrennten Achsen, und die Trennung ist nicht Ordnungsliebe, sondern
Quellenlage: `harness/migration.md` §5 setzt ausdrücklich, dass die Ausgänge über die **Vorlage**
nicht die fünf Ausgänge über den **Adaptions-Eintrag** sind — *„zwei verschiedene Achsen, die nicht
ineinander übersetzt werden"*. Die dritte Achse, die **Adresse**, urteilt gar nicht; sie bewegt
Bytes.

| Achse | Gegenstand | Ausgangs-Menge | Liefer-Punkt |
|---|---|---|---|
| Adresse | Baum · Pin · Symlink · Markdown-Link · Inline-Pfad | keine — die Adresse zeigt in den neuen Baum oder nicht | 1 |
| Adaptions-Eintrag (`MR-<NNN>`) | die aktiven Einträge unter [`harness/conventions/`](../../../../harness/conventions/) — `ls harness/conventions/*.md \| wc -l` → **55** | fünf: gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist entfallen · widerspricht | 2 |
| Vorlage | die Vorlagen des vendored Baums — `find .harness/baseline/v6.7.2/templates -name '*.template.md' \| wc -l` → **25** | vier aus `harness/migration.md` §5 a, bzw. *append-only* aus §5 b | 3 |

**Keine Erwartungswerte** — beide Zahlen wandern, die erste mit dem Block, die zweite mit dem Tag.
Die zweite ist gegen den heute vendorten Stand `v6.7.2` gemessen
([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist));
dass sie über den Sprung unverändert bleibt, ist die Aussage von
[`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Kein Vorlagen-Delta und wird
in Liefer-Punkt 3 nachgemessen, nicht hier vorausgesetzt.

### Der Adress-Nachzug ist gemessen, nicht geschätzt

Beide Kommandos laufen über dem Arbeitsbaum, der diesen Plan enthält; die Zahlen wandern mit dem
Bestand und sind **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
PS=( '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
     ':!docs/plan/carveouts/done' ':!docs/plan/planning/observations' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.7\.2[^)]*\)' -- "${PS[@]}" | wc -l   # 127 Markdown-Links
git grep -lE '\]\([^)]*\.harness/baseline/v6\.7\.2[^)]*\)' -- "${PS[@]}" | wc -l   #  59 Dateien
git grep -oE '`[^`]*\.harness/baseline/v6\.7\.2[^`]*`'     -- "${PS[@]}" | wc -l   #  76 Inline-Code-Pfade
git grep -lE '`[^`]*\.harness/baseline/v6\.7\.2[^`]*`'     -- "${PS[@]}" | wc -l   #  14 Dateien
```

**Die 127 Markdown-Links sind gate-sichtbar** und fallen in demselben Moment, in dem das
`v6.7.2`-Verzeichnis verschwindet: `links` prüft die Existenz des Ziels, und der Ausschluss
`.harness/baseline/**` in `scan.ignore` nimmt den Baum vom **Scannen** aus, nicht vom
**Verweis-Ziel-Sein**. Zwischen dem Tausch-Commit und dem Nachzugs-Commit ist das Repo rot; beide
gehören deshalb in denselben Push (Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker, *„Beide Commits gehören in denselben Push"*).

**Die 76 Inline-Code-Pfade sind gate-unsichtbar** und werden es bleiben: `codepaths` vergleicht
Präfix-**Zeichenketten** und führt `roots: [spec, docs, harness]`, und `.harness` beginnt nicht mit
`harness` — [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md)
§Modul `codepaths` führt die Messung samt der verworfenen Reparatur, und das
Beobachtungs-Register führt die Klasse (§8). Sie sind der Grund, warum die Liste oben aus einem
`git grep` kommt und nicht aus einem Gate-Lauf.

**Beide Zahlen sind größer als beim vorigen Sprung** (dort 125 Links, 24 Inline), und der Zuwachs
sitzt fast vollständig in einer Datei: `harness/migration.md` führt das Instanz-Register mit einer
tag-tragenden Vorlagen-Zeile je Vorlage
(`git grep -c '\.harness/baseline/v6\.7\.2/' -- harness/migration.md` → **44**, kein
Erwartungswert). Die Datei ist Architect-Eigentum
([`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
[`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Kopplung) — ihr Nachzug
läuft im Architect-Commit, nicht im Implementations-Commit (§2 Liefer-Punkt 1).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Instanz-Adaptions-Durchgang über `harness/migration.md` §4/§5 a mit Form-Vergleich.**
  Er hätte keinen Gegenstand: Über die zwei Tags ist keine Vorlage geändert
  ([`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Kein Vorlagen-Delta),
  und ein Vergleich einer Instanz gegen eine unveränderte Vorlage misst nichts — *es wäre ein
  anderer Vorgang, und er hat heute kein Objekt*. Liefer-Punkt 3 **berichtet** diesen Befund, er
  fährt den Durchgang nicht.
- **Keine eingefrorene Adresse wird berührt.** Was in `docs/reviews/**`,
  `docs/plan/planning/done/**`, `docs/plan/carveouts/done/**`, im Beobachtungs-Register und in
  einer `Accepted`-ADR auf `v6.7.2` zeigt, bleibt stehen — [`AGENTS.md`](../../../../AGENTS.md)
  §3.4 und §3.11 sperren die Reparatur, und die Klasse hat mit
  [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) bereits ihr Verdikt:
  *Bestand bleibt bewusst stehen*. Die Pathspec oben bildet genau diesen Ausschluss ab.
- **Kein zweites Referenz-Ventil in [`.d-check.yml`](../../../../.d-check.yml).** Jedes weitere
  `ignore-refs`- oder `scan.ignore`-Paar ist eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 mit eigener ADR; dieser Slice löst die 127 Links durch
  **Nachzug**, nicht durch Ausnahme — *es wäre ein anderer Vorgang*.
- **Keine Änderung am Auswahl-Maßstab für `.claude/rules/`.** Die sieben Symlinks werden
  **umgehängt**, nicht neu ausgewählt: Die Mitglieder-Menge bleibt dieselbe, nur ihr Inhalt
  wechselt — so setzt es
  [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Was sich ändert
  ausdrücklich. Ob der **neue Inhalt** von `modul-11` und `modul-13` den Maßstab aus
  [`MR-056`](../../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)
  berührt, ist eine Frage an Liefer-Punkt 2 und an den Architect — *es wäre ein anderer Vorgang,
  und zwar einer anderen Rolle*.
- **Kein Inhalt der emittierten Ebene.** Die **Pin**-Hälfte gehört zwingend hierher:
  `DefaultTag`/`DefaultBaselineSHA256` sind zwei der fünf gekoppelten Stellen, und wer sie stehen
  ließe, färbt `make gates` rot. Die **Inhalts**-Hälfte — was ein Zielrepo an Vorlagen, Modulen und
  Sensor-Verzeichnis bekommt — hat einen eigenen Prüfbereich und einen eigenen Beleg
  (`make full-smoke`, nicht `make gates`) und liegt bei
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  und [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  — *Schicht-Abgrenzung*.
- **Keine Fortschreibung von `harness/migration.md` über den Tag-Nachzug hinaus.** Ob dieses
  Dokument bei jedem Sprung inhaltlich fortzuschreiben ist, führt es selbst in §6 als offene
  Frage — *„sagt keine der sechs ADRs"*. Dieser Slice zieht die toten Pfade nach und beantwortet
  die Frage nicht; sie ist *ein anderer Vorgang*, und ihn zu erledigen hieße, eine Norm zu setzen,
  die keine Quelle trägt.
- **Kein neuer Wächter für den Vorgang selbst.**
  [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Fitness Function stellt
  fest, dass kein Gate liest, nach welcher Fassung ein Durchgang lief; einen zu bauen wäre eine
  eigene Entscheidung mit eigener Evidenz — *es wäre ein anderer Vorgang*. Der Liefer-Stand dieses
  Slice steht deshalb auf Kommandos und Rollenwechseln, nicht auf einem Sensor (§6).
- **Keine neue ADR und kein Carveout.** Beides ist hier nicht geplant; findet Liefer-Punkt 2 einen
  Eintrag mit dem Ausgang *widerspricht*, ist das ein **Übergabe-Trigger** an den Architect
  (§4, Rückführung nach `open/`) und kein stillschweigend mitgenommener Liefer-Punkt —
  *Schicht-Abgrenzung zwischen Durchgang und Entscheidung*.

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

Drei slice-eigene Punkte, einer je Achse aus §1. Gezählt ist nur, was mit dem Umfang wächst.

- [x] **1 — Jeder Träger des Tags steht auf `v6.8.0`, und keine lebende Adresse bleibt auf dem
      abgelösten Tag.** Fünf Träger-Klassen, eine Eigenschaft: Sie alle existieren nur, weil der
      Tag sich bewegt, und keine ist ohne die anderen lieferbar — ein halb getauschtes Repo ist rot.

      1. **Der vendored Baum.** `.harness/baseline/v6.8.0/{regelwerk,templates}` samt `SHA256SUMS`
         liegt committet, das `v6.7.2`-Verzeichnis existiert nicht mehr, und
         `make baseline-verify` meldet
         `baseline-verify: v6.8.0 OK — <N> Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
         **Die Dateizahl ist kein Erwartungswert** — tragend ist das `OK`. Der Baum entsteht über
         [`make vendor-baseline`](../../../../harness/sensors/vendor-baseline.md) aus dem
         verifizierten Release-Asset, nicht per Hand-Kopie aus einem fremden Arbeitsbaum; das Ziel
         ist **kein Gate** und steht in keiner Prerequisite-Kette — der Beleg ist
         `make baseline-verify` nach demselben Lauf
         ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
      2. **Die fünf gekoppelten Pin-Stellen.** `BASELINE_TAG`/`BASELINE_ZIP_SHA256` im `Makefile`
         (kanonisch), das `sources`-Paar `url`/`sha256` in
         [`.d-check.yml`](../../../../.d-check.yml) und `DefaultTag`/`DefaultBaselineSHA256` in
         `internal/fetch/baseline.go`; die vier nicht-kanonischen sind fail-closed an das
         Makefile-Paar gekoppelt und laufen in `make gates` (`test/sources-pin.bats`,
         `TestDefaultTag_MatchesBaseline`, `TestDefaultBaselineSHA256_MatchesMakefile`).
         `make regelwerk-check` (Netz, **nicht** in `make gates`) meldet `0 Befund(e)`, EXIT 0.

         **Der sha256 wird am Release-Asset gemessen, nicht aus einer Erwartung übernommen** —
         [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Was diese
         Festlegung nicht tut sagt es zu (*„Sie nennt keinen sha256"*), und der zu `v6.7.2`
         gehörende Wert ist hier falsch. **Dieser Plan nennt ihn nicht**: ihn hier zu führen
         hieße, eine Zahl ohne ihr Kommando zu setzen
         ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
         Steht der Wert im Umsetzungs-Lauf nicht neben dem Kommando, das ihn liefert, ist dieser
         Liefer-Punkt offen.

         **Kein Gate deckt die Kopplung Baum ↔ Pin:** `baseline-verify` entdeckt das
         `<tag>`-Verzeichnis, statt `BASELINE_TAG` zu lesen, und `test/sources-pin.bats` koppelt
         die fünf nur untereinander — beide sind grün, während Baum und Pins verschiedene Tags
         tragen. Dieselbe benannte Lücke führt
         [slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md) DoD 2.
      3. **Die sieben Symlinks in `.claude/rules/`.** Die Mitglieder-Zahl bleibt, und **kein**
         Zeiger in den vendored Baum nennt etwas anderes als den neuen Tag:

         ```sh
         readlink .claude/rules/*.md | grep -c '\.harness/baseline/'          # unverändert
         readlink .claude/rules/*.md | grep '\.harness/baseline/' \
           | grep -vc 'baseline/v6\.8\.0/'                                    # 0
         ```

         **Die erste Zahl ist kein Erwartungswert** — sie wandert mit dem Verzeichnis; tragend ist
         die zweite. Die Zusage ist bewusst über den **neuen** Tag formuliert statt über den
         abgelösten: ein Kommando, das den alten Tag als Literal führte, wäre selbst Gegenstand
         des Nachzugs aus Träger-Klasse 5 und beantwortete danach eine andere Frage (Risiko 1,
         §6). Ohne diesen Schritt läuft jeder dieser Zeiger nach dem Tausch ins Leere, und der
         automatische Claude-Kontext trägt nichts mehr
         ([`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)).
      4. **Die 127 Markdown-Links**, gate-sichtbar (§1).
      5. **Die 76 Inline-Code-Pfade**, gate-unsichtbar (§1).

      Für 4 und 5 liefern die zwei Kommandos aus §1 über dem Ergebnis-Stand **0** für die
      Link-Form. **Das Inline-Kommando trennt nicht, was hier zu trennen ist, und die Zusage folgt
      ihm deshalb nicht.** Eine Inline-Nennung ist entweder eine **Adresse** — dann gehört sie auf
      den neuen Tag — oder Bestandteil einer **Aussage**, die den Stand nennt, gegen den sie
      gemessen ist
      ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist));
      deren Tag zu ziehen zerstörte die Aussage und träfe genau die Klasse, die das
      Beobachtungs-Register als *Verweis-Nachzug ersetzt eine historisch richtige Adresse* führt
      (§8). **Welche der beiden ein Treffer ist, sagt kein Kommando** — es ist ein Urteil
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6), und ein Zähler, der beide Klassen addiert, ist
      als Zusage entweder zu eng oder wertlos. Zugesagt ist deshalb: **null Adressen**, und der
      Rest steht im Umsetzungs-Lauf benannt und abgezählt daneben.

      Der Nachzug läuft **je Eigentümer in einem eigenen Commit**, der die Rolle in seiner Message
      nennt ([`AGENTS.md`](../../../../AGENTS.md) §3.8): Planungs- und Sensor-Artefakte im
      Implementations-Kontext; [`AGENTS.md`](../../../../AGENTS.md),
      [`harness/conventions.md`](../../../../harness/conventions.md) samt
      [`harness/conventions/`](../../../../harness/conventions/) und
      [`harness/migration.md`](../../../../harness/migration.md) (mit ihren 44 Treffern, §1) im
      **Architect**-Lauf; [`.claude/commands/`](../../../../.claude/commands/) und
      [`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) bei der Rolle, die
      sie ausführt ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- [x] **2 — Die Freshness-Review des Adaptions-Blocks ist über alle 55 aktiven Einträge gefahren,
      und jeder betroffene trägt einen der fünf Ausgänge.** Die Frage je Eintrag lautet: Regelt
      eine der vier im Sprung geänderten Regelwerks-Dateien — `README.md`,
      `modul-05-planning-harness.md`, `modul-11-verification.md`, `modul-13-quality-gates.md` —
      das, wofür dieser Eintrag angelegt wurde? Wo ja, trägt der Eintrag genau einen Ausgang aus
      der geschlossenen Fünf-Menge *gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist
      entfallen · widerspricht*
      ([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4; die
      Prozedur ist die der Ziel-Fassung, [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md)
      §Entscheidung).

      **Die Grundgesamtheit ist die volle Liste, nicht eine Vorsichtung.**
      `ls harness/conventions/*.md | wc -l` → **55**, kein Erwartungswert.
      [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) hat bewusst **keine**
      Kandidaten-Auswahl vorgezogen — ein Ausschnitt in der Entscheidung hätte die Fundmenge
      verengt; sie beauftragt die Review und nennt ihren Gegenstand, *„sie inventarisiert das
      Delta nicht"*. Die Liste unten ist deshalb **keine Aussage der Entscheidung**, sondern eine
      Suchhilfe dieses Plans, und sie ersetzt den Durchgang über alle 55 nicht.

      **Suchhilfe 1 — reiner Datei-Bezug.** Zehn Einträge nennen mindestens eine der vier
      geänderten Dateien beim Namen:

      ```sh
      git grep -lE 'modul-05-planning-harness\.md|modul-11-verification\.md|modul-13-quality-gates\.md|regelwerk/README\.md' \
        -- 'harness/conventions/*.md' | grep -oE 'MR-[0-9]+'
      # -> MR-002 MR-003 MR-010 MR-011 MR-014 MR-024 MR-035 MR-051 MR-054 MR-056   (10, kein Erwartungswert)
      ```

      Ein Datei-Name ist ein **Treffer im Suchraum**, kein Betroffensein: Der Sprung ändert in
      diesen Dateien vier eng umrissene Stellen, und ob eine davon den Abschnitt trifft, den ein
      Eintrag zitiert, entscheidet der Durchgang.

      **Suchhilfe 2 — inhaltlicher Bezug.** Zwei der zehn stehen anders da:
      [`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
      und
      [`MR-056`](../../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)
      führen `modul-11` und `modul-13` **namentlich als Mitglieder** des Auto-Kontexts, und beide
      Module ändern sich. **Berührt ist damit ihr Inhalt, nicht der Auswahl-Maßstab** — das ist zu
      prüfen und nicht vorwegzunehmen;
      [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Was diese Festlegung
      nicht tut sagt ausdrücklich, dass sie beiden Einträgen nicht vorgreift.

      **Suchhilfe 3 — ein Kandidat, den die Entscheidung nicht nennt:** Die neue Sektion
      `modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen und der neue
      Fehlannahme-Punkt daneben treffen denselben Gegenstand wie
      [`AGENTS.md`](../../../../AGENTS.md) §3.6 und wie das dritte der drei Kriterien von
      [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
      (dort Setzung 1, gebunden in Setzung 4). Ob daraus ein Ausgang folgt, entscheidet die
      Review; hier steht der Kandidat, nicht sein Urteil.

      **Der Liefer-Punkt ist erfüllt, wenn die Liste vollständig abgearbeitet ist — auch dann,
      wenn kein einziger Eintrag betroffen ist.** Ein leeres Ergebnis ist ein Ergebnis und wird in
      §7 notiert. Das **Schreiben** eines Ausgangs in einen Eintrag ist Architect-Arbeit
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8); was der Implementations-Lauf liefert, ist das
      **Übergabe-Artefakt**: die abgearbeitete Liste mit je einem Ausgang, dazu Tag, Datum und der
      gemessene sha256 für die Buchung in §Baseline von
      [`harness/conventions.md`](../../../../harness/conventions.md) in der Drei-Teil-Form von
      [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
      Festlegung 2. Geschrieben werden Ausgänge **und** Buchung im Architect-Lauf, nicht hier.
- [x] **3 — `docs/migrations/v6.8.0.md` liegt vor, nach der Report-Form aus <!-- d-check:ignore (geplante Ablage) -->
      `harness/migration.md` §5.** Je Vorlage des Registers eine Zeile
      (`find .harness/baseline/v6.8.0/templates -name '*.template.md' | wc -l` → die Zeilenzahl des
      Reports; kein Erwartungswert, die Zahl wandert mit dem Tag). Der Ausgang folgt der Klasse,
      die §4 des Registers der Vorlage zuweist: **Buchstabe a** (vier Ausgänge) für die
      einmaligen, **Buchstabe b** (*append-only*) für die sieben wiederkehrenden, und die in §6
      als offen geführten Zeilen bleiben ausgenommen statt zugeordnet
      (`sed -n '/^## 6. Offene Fragen/,$p' harness/migration.md | grep -coE '^\- \*\*`[^`]+\.template\.md`'`
      → **4**, kein Erwartungswert).

      **Der Report ist trivial kurz, und das ist sein Befund.** Ohne Vorlagen-Delta lautet der
      Ausgang unter Buchstabe a *schon erfüllt* — Beleg ist die Byte-Gleichheit der Vorlage über
      die zwei Tags, kein `diff`-Fund, weil kein Unterschied besteht —, und unter Buchstabe b
      entsteht keine neue Instanz-Pflicht, weil sich die Form nicht geändert hat. **Ein Ausgang
      *übernommen* oder *bewusst abweichend* ist hier nicht zu erwarten; tritt er auf, ist das ein
      Befund und kein Normalfall** — er widerspräche
      [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Kein Vorlagen-Delta und
      gehört dann in §7, nicht still in den Report.

      Die Datei wird von `docs-check` gescannt (`scan.roots: ["."]` in
      [`.d-check.yml`](../../../../.d-check.yml)) — jede `LH-`/`ADR-`/`MR-`-Kennung darin ist ein
      Anker-Link, sonst bricht `ids`
      ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
- [x] `make gates` grün über dem Liefer-Stand — real gefahren und durch den Stempel
      `.harness/state/gates-passed.diffsha` gedeckt, den die Verifikation byte-identisch gegen
      `bash harness/tools/working-tree-hash.sh` über dem sauberen Arbeitsbaum hält. **Was der
      Stempel nicht deckt, steht hier:** den Architect-Commit danach und die Commits dieser
      Closure.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
      **Verkürzt, als Feststellung des Auftraggebers:** eine volle Runde ist für diesen Umfang
      nicht gefahren, ein Review-Report **zu diesem Slice** liegt damit nicht vor. Getragen hat die
      prüfende Seite die Konsistenzrunde zu
      [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) vor dem Slice, der
      Reviewer-Commit in eigener Sache
      ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)) und die
      Verifikation; keiner der drei Läufe hat an dem geschrieben, was er prüfte (§7).
- [x] Doku-Update: [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline und
      §Adoptierte Konventions-Quellen tragen den neuen Stand — **als Architect-Commit**, aus dem
      Übergabe-Artefakt aus Liefer-Punkt 2.
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
| `Makefile` (`BASELINE_TAG`, `BASELINE_ZIP_SHA256`) | update | kanonisches Pin-Paar — und `make vendor-baseline` **liest** es, läuft also nach dieser Änderung |
| [`.d-check.yml`](../../../../.d-check.yml) (`sources`-`url`/`sha256`) | update | fail-closed an das Makefile-Paar gekoppelt (`test/sources-pin.bats`) |
| `internal/fetch/baseline.go` (`DefaultTag`, `DefaultBaselineSHA256`) | update | dasselbe Asset wandert ins Zielrepo ([`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)) |
| `.harness/baseline/` (der zuvor darin liegende Tag-Ordner) | entfällt | `make vendor-baseline` bricht bei einem **anderen** vorliegenden Tag vor jedem Zugriff ab (§6); der alte Baum weicht vorher |
| `.harness/baseline/v6.8.0/{regelwerk,templates}/` + `SHA256SUMS` | neu | der vendored Baum aus dem verifizierten Release-Asset |
| `.claude/rules/*.md` — die sieben Zeiger in den vendored Baum | update | der Tag steht im Symlink-Ziel; ohne Umhängen läuft der Auto-Kontext ins Leere ([`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Was sich ändert) |
| 59 lebende `.md` mit 127 Markdown-Links ins Tag-Segment | update | gate-sichtbar; ohne Nachzug meldet `links` `target-missing` (§1) |
| 14 lebende `.md` mit 76 Inline-Code-Pfaden | update | gate-unsichtbar; Träger ist dieser Plan, nicht ein Sensor (§1) |
| [`harness/conventions/`](../../../../harness/conventions/) — die betroffenen Einträge | update | Ausgang der Freshness-Review; **Architect-Commit** ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline und §Adoptierte Konventions-Quellen | update | Buchung des Vollzugs in der Drei-Teil-Form; **Architect-Commit** |
| [`harness/migration.md`](../../../../harness/migration.md) §1 und §4 | update | Zustand der Sprung-Zeile und 44 tag-tragende Pfade; **Architect-Commit** ([`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| `docs/migrations/v6.8.0.md` | neu | der Vorlagen-Report nach `harness/migration.md` §5 — das Verzeichnis entsteht mit ihm | <!-- d-check:ignore (geplante Ablage) -->
| Übergabe-Artefakt an den Architect (Ausgangs-Liste · Tag · Datum · gemessener sha256) | neu | zwei Architect-Artefakte hängen daran: die Einträge und die Buchung |

**Keine Testdatei-Zeile, und das ist kein Auslassen.** Der Slice ändert keinen Go-Code und keine
Zusage eines Sensors; er bewegt einen vendored Fremd-Blob, fünf Werte, Symlink-Ziele und Markdown.
Die drei vorhandenen Wächter der Pin-Kopplung (`test/sources-pin.bats`,
`TestDefaultTag_MatchesBaseline`, `TestDefaultBaselineSHA256_MatchesMakefile`) laufen unverändert
mit und färben rot, wenn eine der fünf Stellen stehen bleibt — ein neuer Fall in `test/mutations/`
entstünde nur für eine neue Zusage, und dieser Slice macht keine.

**Reihenfolge, weil sie hier trägt und nicht Vorsicht ist:**

- Erst die Pins, dann `make vendor-baseline` — das Ziel liest `BASELINE_TAG`/`BASELINE_ZIP_SHA256`
  als Argumente, ein Lauf vor der Pin-Änderung vendorte den alten Tag erneut.
- Der sha256 steht **vor** dem Vendoring-Lauf fest: Er ist zugleich Argument und Sperre — weicht
  er vom aus dem Asset berechneten ab, bricht der Lauf vor jedem Schreibzugriff ab
  ([`harness/sensors/vendor-baseline.md`](../../../../harness/sensors/vendor-baseline.md)
  §Sperren). Wie er gemessen wird, entscheidet der Umsetzungs-Lauf; zugesagt ist nur, dass die
  Zahl neben dem Kommando steht, das sie liefert (§2 Liefer-Punkt 1).
- Tausch-Commit und Adress-Nachzug gehen in **denselben Push**: dazwischen ist das Repo rot (§1).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit frei und
[`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) auf `Accepted` — beides ist
am Datum dieses Plans erfüllt (`ls docs/plan/planning/in-progress/*.md` → nur die Roadmap;
`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md` →
`Accepted`). Der `git mv` nach `in-progress/` landet auf dem Hauptzweig, **vor** der Arbeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Adress-Nachzug aus Liefer-Punkt 1
  lässt sich nicht in **einer** Review-Sitzung prüfen — beobachtbar daran, dass die Zahl der
  Inline-Treffer, über die ein **Urteil** (Adresse gegen Mess-Aussage) zu fällen ist, die Zahl der
  mechanischen Ersetzungen übersteigt. Dann wird der Nachzug je Eigentümer geschnitten, statt ihn
  in einem Durchgang durchzuziehen.
- `in-progress` → `open` (blockiert — Carveout?): Zwei Bedingungen, jede für sich hinreichend.
  **(a)** Die Freshness-Review aus Liefer-Punkt 2 findet einen Eintrag mit dem Ausgang
  *widerspricht* — der einzige der fünf, an dem das Delta die Antwort nicht vorgibt. Er ist ein
  **Übergabe-Trigger** an den Architect (Folge-ADR oder Carveout), und der Slice wartet auf die
  Entscheidung, statt sie im Implementations-Kontext zu treffen
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). **(b)** Der am Asset gemessene sha256 weicht von
  dem ab, den das Upstream-Release ausweist, oder `make vendor-baseline` bricht an seiner Sperre
  ab — dann ist die Provenienz-Kette der Befund und nicht der Baum (§6).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. `make baseline-verify` meldet `v6.8.0 OK`, und die drei Pin-Wächter in `make gates`
   (`test/sources-pin.bats`, `TestDefaultTag_MatchesBaseline`,
   `TestDefaultBaselineSHA256_MatchesMakefile`) sind grün über dem Liefer-Stand — der Tausch ist
   damit über beide Achsen belegt, Baum und Pin.
2. Die zwei Link-Kommandos aus §1 liefern über dem Ergebnis-Stand **0**, und das
   Symlink-Kommando aus §2 Liefer-Punkt 1 Träger-Klasse 3 ebenfalls — keine lebende Adresse und
   kein Auto-Kontext-Zeiger steht mehr auf dem abgelösten Tag.

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke),
§7. Die Form ist hier **nicht vorweggenommen**: Welche der drei trägt, hängt am Ergebnis der
Freshness-Review und an dem, was der Durchgang über die Prüftiefe zeigt — eine Form vorab zu
setzen hieße, das Ergebnis zu setzen.

**Die Closure schreibt der Planner, nicht dieser Lauf** ([`AGENTS.md`](../../../../AGENTS.md)
§3.10): Closure-Notiz, Risiko-Ausgänge, DoD-Häkchen, Register-Fortschreibung und der `git mv`
nach `done/` landen in einem eigenen Commit in frischem Kontext.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Adress-Nachzug ersetzt eine Mess-Aussage, die ihren Tag richtig nennt.** Ein `sed` über
  `v6.7.2` trifft auch den Satz, der eine Messung *gegen den adoptierten Stand `v6.7.2`* datiert
  ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)),
  und das Ergebnis bleibt syntaktisch heil, während es etwas anderes behauptet. Kein Gate sieht
  es. **Diese Datei ist selbst betroffen:** Die zwei `git grep`-Kommandos in §1 messen den
  **Vorzustand** und führen den abgelösten Tag als Literal — sie gehören zur Mess-Klasse und
  bleiben stehen, obwohl der Plan während der Arbeit in `in-progress/` und damit im Prüfbereich
  des Nachzugs liegt. Die Zusagen in §2 und §5 sind deshalb über den **neuen** Tag formuliert.
  — **Ausgang: entfallen.** Zwei Rollen haben je Vorkommen geurteilt statt pauschal ersetzt: Der
  Architect-Lauf nennt vier bewegte Mess-Ergebnisse und daneben namentlich die bewusst stehen
  gelassenen, die Verifikation hat die Reste einzeln gegengelesen. Über dem Liefer-Stand bleiben **null** Links und
  **drei** Inline-Nennungen des abgelösten Tags (Kommandos in §1); zwei davon sind Mess-Aussagen
  und bleiben zu Recht stehen — diese Datei §1 und
  [`ADR-0045`](../../adr/0045-authority-wechsel-senkt-eine-richtung.md), `Accepted` und damit
  ohnehin gesperrt ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Die dritte ist keine; sie steht
  beim Risiko unten.
- **Kein Sensor deckt die Kopplung Baum ↔ Pin, und keiner den Vorgang selbst.**
  `baseline-verify` entdeckt das `<tag>`-Verzeichnis, `sources-pin.bats` koppelt die fünf Pins nur
  untereinander; beide melden grün, während Baum und Pins verschiedene Tags tragen. Für die Frage,
  *nach welcher Fassung* ein Durchgang lief, existiert überhaupt kein Gate
  ([`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Fitness Function).
  — **Ausgang: entfallen.** Baum und alle fünf Pin-Stellen tragen denselben Tag —
  `make baseline-verify` meldet `v6.8.0 OK`, und die drei Pin-Wächter liefen grün im
  `make gates`-Lauf über dem Liefer-Stand. Die Werkzeug-Eigenschaft bleibt und ist an ihrem Ort
  benannt ([`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Fitness Function,
  [slice-223](../done/slice-223-baum-tausch-v672-pins-ziehen.md) DoD 2), also kein stilles
  Vergessen; für **diesen** Slice hat sie keinen Gegenstand mehr.
- **`make vendor-baseline` bricht ab, wenn ein anderer Tag im Baum liegt** — die Sperre ist
  gewollt ([`harness/sensors/vendor-baseline.md`](../../../../harness/sensors/vendor-baseline.md)
  §Grenze), aber sie macht den Tausch zu einer Zwei-Schritt-Operation, deren erster Schritt
  (`git rm -r` des alten Baums) das Repo für die Dauer eines Commits ohne Baseline lässt.
  — **Ausgang: entfallen.** Der Tausch lief als **reiner Rename ohne Rest**, das Repo war zu
  keinem Zeitpunkt ohne Baseline:

  ```sh
  git show f8e602b7 --name-status --format= | grep -c '^R'        # 55 Umbenennungen
  git show f8e602b7 --name-status --format= | grep -cvE '^R|^$'   # 0 sonstige Eintraege
  ```

  Und der rote Zwischenstand zwischen Tausch und Nachzug wurde nie die Spitze eines Push:
  `git reflog show origin/main` führt den Sprung `6ac35576` → `0565f274`, die sieben Arbeits-Commits
  reisten in **einem** Push (Baseline-Regelwerk `grundlagen-traceability.md` §Herkunfts-Anker).
- **Die Provenienz-Hälfte Asset → vendored Baum hält nichts.** `regelwerk-check` hasht die
  Roh-Bytes des ZIP, `baseline-verify` hält den Baum gegen ein selbst erzeugtes `SHA256SUMS` —
  dass der Baum *aus diesem Asset* stammt, bezeugt allein der Vendoring-Vorgang
  ([`harness/conventions.md`](../../../../harness/conventions.md) §Adoptierte
  Konventions-Quellen). — **Ausgang: weiter offen → Beobachtungs-Register.** Die Klasse steht als
  [`BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin`](../observations/BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin/observation.md)
  bei **1×** und ist **nicht erhöht**: Der Baum entstand über `make vendor-baseline` aus dem
  verifizierten Asset, die dort beschriebene Hand-Kopie aus dem `git`-Baum trat nicht auf. Was
  **doch** eintrat, ist die Messseite derselben Ursache und steht als eigener Eintrag in §7.
- **[`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) steht auf
  `Proposed`**, und ihre Festlegung 2 bindet trotzdem die Form der Buchung aus Liefer-Punkt 2. Ob
  eine nicht angenommene Entscheidung so zitiert werden darf, führt
  [`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen als benannte
  Lücke; dieser Slice folgt der Form und entscheidet die Frage nicht.
  — **Ausgang: entfallen.** Die Buchung steht in der Drei-Teil-Form (Architect-Commit
  `355172da`), und die Frage ist nicht gestellt worden — für **diesen** Slice hat das Risiko damit
  keinen Gegenstand mehr. Die Frage selbst behält ihre Adresse in
  [`ADR-0044`](../../adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Konsequenzen; sie zu
  beantworten wäre eine Entscheidung und damit Architect-Arbeit
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Der Bestand offener Slice-Pläne wird gegen den neuen Stand nicht gehalten.** 65 Dateien liegen
  in `open/` (`ls docs/plan/planning/open/*.md | wc -l`, kein Erwartungswert); der Sprung kann die
  Pflicht verschieben, die einer von ihnen halten soll — genau die Klasse, die das Register als
  *Folge-Slice überlebt Baseline-Sprung mit alter Pflicht* führt (§8). Dieser Slice prüft sie
  nicht. — **Ausgang: weiter offen → Beobachtungs-Register.** Der Bestand ist weiterhin
  ungeprüft; der Closure-Zug hat auf **einer** schmalen Achse nachgesehen — der toten Tag-Adresse —
  und dort einen Treffer: Der Start-Trigger von
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) §4 belegt die Zusage
  *„der vendored Baum führt die Vorlage in der neuen Fassung"* mit einem `ls` auf das abgelöste
  Tag-Segment; das Kommando meldet heute Exit 2, und der Trigger liest sich damit als *nicht
  erfüllt*, obwohl er es ist. Der Beleg ist geschrieben
  ([`BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md),
  jetzt **6×**); **die Berichtigung selbst ist kein Closure-Schritt** und steht als Übergabe in §7.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Der Commit-Zuschnitt je Eigentümer und die Reihenfolge aus §3.**
  Sieben Arbeits-Commits, jeder mit genau einer Rolle in seiner Message; die Verifikation hat den
  Zuschnitt über alle sieben gegengelesen und keine Vermischung gefunden. Der Tausch selbst war ein
  reiner Rename (§6), der sha256 stammt aus einem bewusst rot gefahrenen Fehlversuch statt aus
  einer Erwartung, und die **Zusage über den neuen Tag** statt über den abgelösten hat getragen:
  Sie blieb messbar, während die Mess-Kommandos in §1 den alten Tag als Literal behielten.
- **Was ging anders als geplant:** **Der Vorlagen-Report hat seine eigene Prämisse nicht
  gehalten.** §2 Liefer-Punkt 3 setzte den Beleg als *„Byte-Gleichheit der Vorlage über die zwei
  Tags"*; die Verifikation hat sie gegen die zwei **vendorten** Bäume nachgemessen und für **2**
  von **25** Vorlagen widerlegt. Der Ausgang *schon erfüllt* blieb richtig, der Beleg-Satz nicht —
  er ist in `c9e23496` auf die präzise Aussage gezogen. Das ist zugleich der Lerneintrag unten.
- **Freshness-Durchgang über den Adaptions-Block (Liefer-Punkt 2) — der Bericht.** Der
  Architect-Lauf hat ihn gefahren und **bewusst kein Artefakt hinterlassen**: Für den Ausgang
  *bleibt gültig* sieht die Baseline keinen Vermerk vor (`v6.8.0` ·
  `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline — *„stehen
  lassen; Normalfall"*), und eine nachträgliche Inhalts-Änderung an einem angenommenen Eintrag
  verbietet
  [`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)
  ohnehin. **Diese Stelle ist damit die einzige, an der der Durchgang festgehalten ist.**
  - **Grundgesamtheit:** alle **55** aktiven Einträge (`ls harness/conventions/*.md | wc -l` →
    **55**, kein Erwartungswert), nicht eine Vorsichtung.
  - **Einzeln geprüft:** die **zehn** aus Suchhilfe 1 — `MR-002 MR-003 MR-010 MR-011 MR-014
    MR-024 MR-035 MR-051 MR-054 MR-056`, Kommando in §2 —, darunter die zwei aus Suchhilfe 2, plus
    den **dritten Kandidaten** aus Suchhilfe 3, den die Entscheidung nicht nennt.
  - **Ergebnis: ein Ausgang ist vergeben** — *bleibt gültig* für
    [`MR-056`](../../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff):
    Der Sprung bewegt den **Inhalt** der zwei namentlich geführten Module, nicht den
    Auswahl-Maßstab, den der Eintrag setzt; seine Zahlen sind gegen den neuen Baum nachgemessen.
    Für alle übrigen hat das Delta **keinen Gegenstand** — keine der vier im Sprung geänderten
    Regelwerks-Dateien regelt das, wofür der Eintrag angelegt wurde. Kein Rückbau, keine engere
    Nachfolgerin, kein *Bezug ist entfallen*, und **kein `widerspricht`** — der einzige der fünf
    Ausgänge, an dem das Delta die Antwort nicht vorgibt und der nach §4 die Rückführung nach
    `open/` ausgelöst hätte.
  - **Der dritte Kandidat ist eigens entschieden** und trägt als einziger einen sichtbaren Beleg
    (Architect-Commit `47c4cb3b`): Die neue Sektion `modul-11-verification.md` §Bewusstes Brechen
    für DoD-Testbehauptungen regelt denselben Gegenstand wie
    [`AGENTS.md`](../../../../AGENTS.md) §3.6, aber enger und nur für **eine** der dort geführten
    Zusage-Klassen. Eine Ergänzung ohne Einschränkung ist keine Adaption — **kein neuer Eintrag**;
    §3.6 bekam stattdessen den Verweis-Nachtrag mit Mess-Stand.
  - **Was der Durchgang nicht belegt:** *bleibt gültig* heißt wörtlich „stehen lassen" und
    hinterlässt keine Spur im Eintrag; *geprüft und bleibt gültig* ist damit von *nicht geprüft*
    nicht zu unterscheiden. Die Verifikation stellt genau das fest und konnte die zehn nicht
    unabhängig bestätigen. Dieser Absatz ist die Bestätigung, die sie erbeten hat — sein Träger ist
    der Bericht des ausführenden Laufs, nicht ein Sensor.
- **Steering-Loop-Eintrag — benannte Spec-Lücke: Ein Vorlagen-Delta gegen den
  Upstream-Quelltext ist nicht dasselbe wie eines gegen den tatsächlich vendorten Baum.** Beide
  Messungen beantworten dieselbe Frage und liefern verschiedene Antworten:

  ```sh
  # (a) Upstream-Quelltext, Kurs-Klon $K — so gemessen in ADR-0047 §Kein Vorlagen-Delta:
  git -C "$K" diff --name-only v6.7.2..v6.8.0 -- lab/templates | wc -l                  # 0

  # (b) die zwei vendorten Baeume dieses Repos, f8e602b7 ist der Tausch-Commit:
  for rel in $(git ls-tree -r --name-only f8e602b7 -- .harness/baseline/v6.8.0/templates \
               | sed 's#^\.harness/baseline/v6\.8\.0/templates/##'); do
    a=$(git show "f8e602b7^:.harness/baseline/v6.7.2/templates/$rel" | sha256sum)
    b=$(git show "f8e602b7:.harness/baseline/v6.8.0/templates/$rel"  | sha256sum)
    [ "$a" = "$b" ] || echo "$rel"
  done | wc -l                                                                          # 2
  ```

  Das Release-Verfahren stempelt einen Beispiel-Link mit dem Release-Tag; der vendorte Baum trägt
  damit Bytes, die der `git`-Baum nicht hat — bei `AGENTS.template.md` und
  `harness/conventions.template.md` je **eine** Zeile, kein Inhalts- und kein Struktur-Delta.
  **Die Lücke:** Keine Quelle dieses Repos sagt, gegen **welchen der beiden** ein Vorlagen-Delta zu
  messen ist. [`harness/migration.md`](../../../../harness/migration.md) §5 gibt die Report-**Form**
  und nennt den Mess-Gegenstand nicht;
  [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Kein Vorlagen-Delta misst
  gegen den Klon und trägt die Folgerung auf den vendorten Baum. Gegenstück ist
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): Reproduzierbar ist,
  was im Repo liegt — eine Delta-Aussage über den vendorten Baum gehört an **ihm** gemessen.
  *(Kein `liegt in`-Feld — der Eintrag ist **gezählt, nicht verkörpert**, aus zwei unabhängigen
  Gründen. **Schwelle:** die Beobachtung steht nach diesem Slice bei **1×**; unterhalb von 3× ist
  `offen` der Normalzustand. **Eigentum:** Der Ort, an dem die Regel stünde — `harness/migration.md`
  §5 oder §6 —, ist ein derivatives Register und gehört dem **Architect**
  ([`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md),
  [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Bezug); die Formulierung in
  [`ADR-0047`](../../adr/0047-ziel-fassung-regiert-den-sprung-v680.md) selbst ist `Accepted` und ab
  da immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Auch beim Übertritt ist das eine
  **Übergabe**, kein Closure-Schritt.)*
- **Beobachtungs-Register (`../observations/`):** **drei Belege.** Neu angelegt:
  [`BEO-ALL/delta-messung-trifft-den-quelltext-statt-den-vendorten-baum`](../observations/BEO-ALL/delta-messung-trifft-den-quelltext-statt-den-vendorten-baum/observation.md)
  (**1×**) — der Gegenstand des Lerneintrags oben. Ergänzt:
  [`BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md)
  (**6×**) für den toten Start-Trigger in `slice-213` (§6) und — **strukturell erst nach dem
  `git mv`, weil er ein Befund des Move ist** —
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  (**18×**): Der Move macht den Ruhe-Marker der Roadmap falsch, und `make slice-mv` zieht Pfade
  nach, keine Zustandssätze. **Die zwei aus der Sichtung (§8) sind
  nicht erhöht, und das ist der Befund:** `gate-modul-erreicht-den-vendored-baum-nicht` (**3×**)
  und `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` (**4×**) beschreiben, was der
  Nachzug *falsch* macht — hier hat er es nicht getan (§6, Risiko 1). Beide stehen **über** der
  Schwelle und trotzdem auf `offen`; das ist **vorgefundener Bestand**, den §8 benennt und den
  dieser Slice nicht verursacht hat. Ihr Ausgang gehört dem **Lese-Schritt**, und der ist in einem
  Repo mit Wellen-Betrieb Sache der nächsten Welle-Closure.
- **Folge-Slices:** **keiner.** Kein Risiko aus §6 ist *eingetreten*; die zwei *weiter offen* haben
  ihren Platz im Register. **Zwei Übergaben statt eines Slice:** (a) an den **Architect** — ob
  `harness/migration.md` §5 den Mess-Gegenstand eines Vorlagen-Delta benennt oder ihn in §6 als
  offene Frage führt; (b) an den **Planner-Lauf, der `slice-213` als Nächstes anfasst** — der tote
  `ls` in dessen §4 Start-Trigger. Beide sind eine Zeile Arbeit und kein Schnitt; sie jetzt als
  Slice zu schneiden hieße, für eine Zeile einen Plan zu schreiben.
- **Risiken aus §6:** sechs Risiken, sechs Ausgänge — **viermal *entfallen*, zweimal *weiter offen*
  → Beobachtungs-Register**, keines *eingetreten*. Kein Risiko ohne Ausgang; die Einzelheiten und
  ihre Messungen stehen in §6.
- **Drei Paarungen:** entfällt hier — dieses Repo fährt Wellen
  (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein Erwartungswert); sie werden von der
  nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit (§2).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo). Die
Wahl ist nicht Bequemlichkeit, sondern folgt dem Gegenstand — der Tag steht in `Makefile`,
`.d-check.yml`, `internal/fetch/`, `.claude/rules/`, `spec/`, `harness/`, `docs/` und in der
Planungs-Ablage; keine engere Sub-Area umschließt ihn. `harness/tools/` (`TOOLS`) und `.codex/`
(`CODEX`), die einzigen beiden anderen deklarierten Sub-Areas
([`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area),
sind **nicht** berührt: `git grep -l 'v6\.7\.2' -- harness/tools .codex | wc -l` → **0**, kein
Erwartungswert. Die Schwelle ≥ 2 von 3 Achsen erfüllt `*` als deklarierte Sub-Area des Repos.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **105** Einträge, kein
Erwartungswert). **Alle Einträge dieses Repos führen dieselbe Sub-Area `*`**, die Sichtung ist
deshalb keine Filterung nach Bereich, sondern eine nach Gegenstand. Vier Treffer, jeder mit dem
Zähler-Stand aus seinem `evidence/`-Verzeichnis
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine
Erwartungswerte):

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `gate-modul-erreicht-den-vendored-baum-nicht` | **3** | offen | die 76 Inline-Pfade aus §1 sind genau diese Klasse — dieser Slice wäre das **vierte** Auftreten |
| `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` | **4** | offen | Risiko 1 in §6: der `sed` trifft die Mess-Aussage nach [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) |
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | **5** | offen | Risiko 6 in §6: die Pläne in `open/` werden gegen den neuen Stand nicht gehalten |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | **3** | offen | dieser Plan selbst — der Schnitt ist ausdrücklich schlank gehalten (§8 *Evidenz-Risiko*) |

**Zwei davon haben die 3×-Schwelle bereits überschritten und stehen trotzdem auf `offen`** —
`gate-modul-erreicht-den-vendored-baum-nicht` bei 3 und
`verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` bei 4. Baseline-Regelwerk
`modul-06-roadmap.md` §Das Beobachtungs-Register lässt das nicht zu: *„Nicht zulässig ist ein
Eintrag, der eine Closure ohne Ausgang übersteht."* Das ist **Bestand**, den dieser Slice
vorfindet und nicht verursacht; er wird hier **benannt, nicht mitgenommen** — der Ausgang gehört
in den Lese-Schritt einer Closure, und der ist Planner-Arbeit
([`AGENTS.md`](../../../../AGENTS.md) §3.10). Erreicht ein Eintrag **mit** diesem Slice zum ersten
Mal 3×, ist er eine Lücke mit eigenem Folge-Slice; das trifft hier auf keinen zu, weil beide
bereits darüber stehen.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** — der Block entfiele damit nach der Regel oben. Er steht
trotzdem, weil die berührte Sub-Area `*` ist und das Evidenz-Risiko dieses Slice nicht
selbstverständlich niedrig ist:

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF — so deklariert in
  [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area,
  Begründung dort *„Neues Repo, Doc führt, Code folgt"*.
- **Konventionen-Dichte:** hoch. `ls harness/conventions/*.md | wc -l` → **55** aktive Einträge
  (kein Erwartungswert); der Gegenstand dieses Slice ist in
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  (vendored Baum),
  [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  (Mess-Aussage mit Tag),
  [`MR-035`](../../../../harness/conventions.md#mr-035--der-automatische-claude-kontext-trägt-eine-benannte-geschlossene-modul-auswahl)
  und
  [`MR-056`](../../../../harness/conventions.md#mr-056--die-auswahl-im-auto-kontext-hängt-an-der-lauf-berührung-nicht-am-prozess-modul-begriff)
  (Auto-Kontext) strukturell verankert — und der Block selbst ist Liefer-Punkt 2.
- **Phase-Reife:** Phase 5. Der Sprung ist der siebte seiner Art
  (`harness/migration.md` §1 führt sieben Zeilen), jede vorige mit ADR, Slice und Delta-Nachweis;
  Prozedur und Träger sind erprobt, nicht im Entstehen.
- **Evidenz-/Diskrepanz-Risiko:** **mittel statt niedrig**, und zwar aus einer einzigen Richtung.
  Die Tausch-Hälfte ist mechanisch und durch drei Pin-Wächter gedeckt. Das Risiko sitzt in der
  Urteils-Hälfte: die Trennung *Adresse gegen datierte Mess-Aussage* über 76 Inline-Treffer
  (Register-Eintrag `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`, **4×**), die kein
  Gate sieht (`gate-modul-erreicht-den-vendored-baum-nicht`, **3×**). Beide sind oben mit
  Zähler-Stand notiert; beide sind Bestand und nicht Gegenstand dieses Slice.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Bestand, keine `reconciliation.md` (§2).
  **Graduation entfällt** (n/a bei GF). Der einzige Folge-Trigger, den dieser Slice erzeugen
  **kann**, ist der Ausgang *widerspricht* aus Liefer-Punkt 2; er ist als Rückführung nach `open/`
  in §4 verdrahtet, nicht als stiller Zuwachs.

### Zur Bemessung dieses Slice

Der Schnitt ist ausdrücklich schlank gehalten: drei Liefer-Punkte auf drei Achsen, kein
Instanz-Durchgang, kein neuer Sensor, keine neue Entscheidung. Der Register-Eintrag
`slice-plan-umfang-waechst-ueber-umsetzung-hinaus` steht bei **3×** und trifft die Plan-Klasse
selbst; der Eintrag `pruef-tiefe-folgt-nicht-der-artefakt-klasse` steht bei **1×** und hält
denselben Gedanken für die Review-Seite fest — *für ein Artefakt ohne normative Bindung ist eine
Runde hinreichend, sobald sie kein HIGH mehr findet*. **Diese Regel ist ein Vorschlag und keine
geltende Norm:** Sie steht als Steering-Loop-Eintrag in der Closure von
[slice-migration-hat-ein-instanz-register](../done/slice-migration-hat-ein-instanz-register.md)
ausdrücklich *ohne* `liegt in`-Feld, und ihr genannter Zielort
[`.harness/skills/reviewer.md`](../../../../.harness/skills/reviewer.md) führt sie nicht
(`grep -c 'kein HIGH' .harness/skills/reviewer.md` → **0**, Exit 1 — kein Erwartungswert). Dieser
Plan beruft sich deshalb **nicht** auf sie; er hält sich schlank, weil der Gegenstand es hergibt,
nicht weil eine Regel es erlaubte.
