# Verifier-Report slice-058 — `--arch hexagonal` für Go, das Layout der Familie

Rolle: **Verifier (Modul 11)**. Prüfgegenstand ist die **DoD** des Slice-Plans (§2), Punkt für
Punkt — nicht die Güte des Diffs (das ist Modul 10). Die Begründungen von Implementer und
Reviewer waren **Eingabe, nicht Beleg**: jede Zahl unten habe ich selbst erhoben, jede
Konformitäts-Aussage selbst gegen die Quelle gelesen.

**Datum:** 2026-07-28. **Slice:** `docs/plan/planning/in-progress/slice-058-hexagonal-go.md`.

**Gegenstand:** `9a4ad3b` (Implementierung), `dbbb110` (CR 0.18.0, nur `spec/lastenheft.md`),
`cd0e9f9` (Auflösung der Review-Befunde F-1/F-3/F-4/F-5). `HEAD` == `origin/main`, Arbeitsbaum
clean (`git status -sb` → `## main...origin/main`, keine Einträge).

**Grenze dieses Laufs:** frischer Kontext (der Diff ist fremd). Docker-only, ausschließlich
`make`-Targets. Kein Produktivcode, kein Test, keine Doku angefasst — die einzige Schreib-Handlung
ist dieser Report. Die drei Sensoren liefen **sequenziell** auf einem Daemon, mit warmen
Layer-Caches (die Laufzeiten unten sind darum keine Vorher/Nachher-Aussage).

## Was ich selbst erhoben habe

| Sensor | Ergebnis (selbst gesehen) |
|---|---|
| `make gates` | **Exit 0** (27 s) — `baseline-verify` v3.5.2 OK, 42 Dateien · **d-check: 224 Datei(en) geprüft, 0 Befund(e)** · bats **127 ok / 0 not ok** · Go-Tests grün (5 Pakete, `go test -count=1`) · shellcheck über `test/mutations/*.sh` · actionlint · **`comment-claims`: 31 Datei(en), 0 Befund(e)** |
| `make mutate` | **Exit 0** — **102 ok, 0 Befund(e)** über 102 Fälle (10 m 09 s) |
| `make full-smoke` | **Exit 0** (1 m 20 s) — beide neuen Zähne im **emittierten** Repo real rot gesehen, mit Regel-Namen |

Die beiden Zahn-Befundzeilen im Wortlaut, aus meinem eigenen `make full-smoke`-Lauf:

```text
full-smoke: hexagonal-Zahn 1 belegt (core -> driven faerbt a-check als app-impurity rot, danach zurueckgenommen):
full-smoke:   app-impurity: 1
full-smoke:   internal/hexagon/core/greeting.go:9: app-impurity: Application importiert app/internal/adapter/driven/memory
full-smoke: hexagonal-Zahn 2 belegt (driving -> driven faerbt a-check als lateral-adapter rot, danach zurueckgenommen):
full-smoke:   lateral-adapter: 1
full-smoke:   internal/adapter/driving/cli/cli.go:11: lateral-adapter: Adapter importiert anderen Adapter app/internal/adapter/driven/memory
```

Die acht Mutations-Fälle dieses Slice, jeder einzeln in meinem Lauf rot gesehen — und zwar mit dem
**benannten** Wächter in der `--- FAIL:`-Zeile (`harness/tools/mutate.sh` verlangt genau das, sonst
meldet es „rot, aber '<expect>' faellt nicht — falscher Grund"):

```text
mutate: ok      99-hexagonal-rolle-explizit                -> TestArchGateConfig_HexagonalRolesExplicit rot
mutate: ok      100-hexagonal-kante-driven-core            -> TestArchGateConfig_HexagonalEdgesMatchSkeleton rot
mutate: ok      101-hexagonal-disjunktheit                 -> TestArchLayouts_Disjunkt rot
mutate: ok      102-archlayered-namensbasiert              -> TestArchGateConfig_CoversEveryLayeredCombo rot
mutate: ok      103-archlayered-erkennung-weg              -> TestArchGateConfig_OnlyLayered rot
mutate: ok      104-hexagonal-role-fileset                 -> TestGenerate_GoHexagonalProfile_FileSet rot
mutate: ok      105-hexagonal-glob-kopplung                -> TestArchGateConfig_HexagonalMatchesSkeleton rot
mutate: ok      106-archgate-kanten-zyklus                 -> TestArchGateConfig_EdgesAcyclic rot
```

Weiter im selben `full-smoke`-Lauf selbst gesehen: `add-lang go apps/hexagonal --arch hexagonal`
legt das Modul an (`ai-harness-init: add-lang go nach apps/hexagonal — Skelett +
harness/mk/apps-hexagonal.mk + tools/harness/blocked/go.`), und `add-lang cpp … --arch hexagonal`
bricht mit der **Sprach**-Liste ab: `Fehler: unbekannte Architektur "hexagonal"; verfuegbar: flat,
hexslice`. Der unbekannte Wert nennt weiterhin das volle Vokabular: `… verfuegbar: flat,
hexagonal, hexslice`.

## DoD-Stand — Punkt für Punkt

### (1) `add-lang go <pfad> --arch hexagonal` legt das geschichtete Modul an — samt Gate → **BESTÄTIGT**

- **Layout exakt nach `ADR-0010` Festlegung 1.** Zeile für Zeile gegen die ADR-Tabelle gelesen
  (`internal/gen/golang.go`, Rollen-Renderer + `goHexagonalArchConfig`): `internal/hexagon/core/**`
  (`role: app`), `internal/hexagon/port/**` (`role: port`, die Port-Konstante hat **keinen**
  Import), `internal/adapter/driven/**` und `internal/adapter/driving/**` (beide `role: adapter`,
  explizit), `composition_root: ["cmd/**"]`. Kanten **genau** vier: `core→ports`, `driven→ports`,
  `driven→core`, `driving→core`; **kein** `ports→core`, **kein** `driving→ports`, **kein**
  `driving→driven`.
- **Nicht das `--print-config`-Gerüst.** `harness/tools/full-smoke.sh` prüft die Gegenrichtung
  aktiv: existiert `apps/hexagonal/internal/{core,ports,adapters}`, bricht der Smoke ab. Mein
  Lauf ist Exit 0, der Zweig hat also nicht gegriffen.
- **Verdrahtung in `cmd/**`.** `goHexagonalMain` konstruiert den getriebenen Adapter, injiziert ihn
  in die Use-Case und übergibt diese an den treibenden Adapter; `goHexagonalDriving` importiert
  ausschließlich `core` + Standardbibliothek, also **keinen** Adapter. Die Use-Case
  (`goHexagonalService`) bleibt im Kern.
- **Erkennung von Namen auf Struktur gehoben.** `archLayered` (`internal/gen/arch.go:105`)
  entscheidet über `isLayerRole` — „weder Entry-Point noch Toolchain-Test noch Composition Root",
  Default = Schicht (fail-closed). Rot gesehen: Fall **102** setzt die Namens-Fassung
  (`r == roleDomain`) zurück und färbt `TestArchGateConfig_CoversEveryLayeredCombo` rot.
- **Der Kopplungs-Wächter ist nicht tautologisch.** `layeredTree` (`internal/gen/archgate_test.go`)
  ruft `archLayered` **nicht**, sondern rendert das Layout und vergleicht gegen den `flat`-Baum
  derselben Sprache. Selbst nachgeprüft: der Vergleichspunkt ist ein anderes Layout, nicht die
  bewachte Funktion; das Skelett enthält keine `.a-check.yml`, der Baum kann also auch nicht
  durch das Artefakt „geschichtet" werden, dessen Existenz der Test prüft.
- **`flat`/`hexslice` behalten ihre Gate-Entscheidung.** `TestArchGateConfig_OnlyLayered` führt die
  Tabelle (`go+hexslice` true, `go+hexagonal` true, `cpp+hexagonal` **false**, `flat`/`""`/`onion`
  false); rot gesehen: Fall **103** lässt `isLayerRole` immer `false` liefern — **hexslice**
  verliert sein Gate und der Test fällt.
- **`flat`/`hexslice` bleiben byte-identisch — mit ausdrücklicher Messgrenze, siehe unten.** Ich
  habe die Eigenschaft **statisch** belegt, **nicht** durch einen Ausgabe-Vergleich zweier Stände.
  Was ich geprüft habe: `git show 9a4ad3b -- internal/gen/golang.go` entfernt **genau eine** Zeile
  — eine Kommentarzeile über `goRole`; `goScaffolding` ist unberührt, `goRole` bekommt
  ausschließlich neue `case`-Zweige, keine bestehende Konstante ist angefasst; `internal/gen/cpp.go`
  ist im gesamten Bereich `14828ba..HEAD` nicht im Diff; `arch.go` ändert `archLayered`/`isLayerRole`
  (Gate-Entscheidung, nicht Skelett-Bytes), `archLayout` bleibt für `flat`/`hexslice` identisch;
  `gen.go` ändert nur `langArchs()["go"]` und Kommentare. Für einen deterministischen Renderer aus
  String-Konstanten folgt daraus Byte-Gleichheit — **aber es ist ein Quell-Argument, keine Messung.**

### (2) Das Gate hat Zähne — an beiden tragenden Regeln, mit Regel-Namen → **BESTÄTIGT**

Beide Gegenbeispiele sind im **realen emittierten Ziel** rot, mit Regel-Namen (Wortlaut oben).
Selbst nachgelesen, dass das kein „Exit ≠ 0"-Beleg ist: der Smoke prüft **erst** `rc != 0` und
**dann** `grep -qF 'app-impurity'` bzw. `'lateral-adapter'`; trifft der `sed` nicht, bleibt das
Gate grün und der Block bricht mit „laesst das Arch-Gate GRUEN" ab (fail-closed). Der Regel-Name
kommt nicht aus der emittierten Config (die führt keine Rule-Namen), also kann der Grep nicht
zufällig treffen. `lateral-adapter` ist **keine** Kante — die Config führt bewusst kein
`driving→driven`, ein Kanten-Wächter fängt die Regel also nicht (`ADR-0010` Folgepflicht 7).
Die Kante **`driven→core`** hat ihren Mutations-Fall (**100**), von mir rot gesehen.

### (3) Die Abgrenzung zu `hexslice` ist mechanisch → **BESTÄTIGT**

`TestArchLayouts_Disjunkt` walkt den **gerenderten** Baum jedes geschichteten Layouts gegen die
Schicht-Globs jedes anderen derselben Sprache; **keine** hartkodierte Verzeichnisliste. Rot
gesehen: Fall **101** zieht `internal/hexagon/core/` auf `internal/hexagon/domain/` — der Test
fällt. Zyklenfreiheit: `TestArchGateConfig_EdgesAcyclic` prüft **jede** emittierte Kanten-Menge
(Drei-Farben-DFS über alle Sprache×Architektur-Configs); rot gesehen: Fall **106** trägt
`ports→core` nach.

Eine Grenze, die der Test selbst benennt (und die ich bestätige): `layeredArchsFor` wählt die zu
vergleichenden Layouts über die **vorhandene Config**, nicht über den Baum. Ein geschichtetes
Layout ohne Config fiele still aus dem Vergleich — es hätte dann aber gar kein Arch-Gate, und
genau diesen Zustand fängt `TestArchGateConfig_CoversEveryLayeredCombo` strukturell. Die Lücke ist
gedeckt, nur von einem anderen Wächter.

### (4) `make gates` grün, `make mutate` ohne Befund, `make full-smoke` grün → **BESTÄTIGT**

Exit 0 / **102 ok, 0 Befunde** / Exit 0 — alles drei von mir gefahren, Zahlen oben. Der
Implementer-Selbstlauf (99 ok) und der Reviewer-Lauf sind damit **nicht** die Grundlage dieser
Zeile; die Differenz 99 → 102 sind die drei Fälle aus der F-1-Auflösung.

### (5) Doku-Update (Handbuch, README) → **inhaltlich BESTÄTIGT · die Reihenfolge NICHT PRÜFBAR**

Inhaltlich vorhanden und korrekt: Handbuch 1.9 → **1.10** (Wahl-Tabelle der drei Bauformen, beide
kategorischen Regeln **samt echter Fehlermeldung**, die eine Lockerungs-Zeile für die treibende
Seite, angepasste Grenzen-/Optionen-/Umgebungs-Abschnitte), README nennt die Bauform-Achse
erstmals überhaupt, `spec/architecture.md` §5 führt das zweite schichten-tragende Layout,
`harness/conventions.md` bekommt `MR-017`.

**Was ich nicht bestätigen kann:** dass die Doku **nach** den Sensoren entstand. Alles liegt in
**einem** Commit (`9a4ad3b`); git trägt dafür keine Ordnung. Belege sind allein die Commit-Message
und die Handbuch-Historie-Zeile 1.10 („der Text kam **nach** den Sensoren") — Zusagen, keine
Messungen. Ich halte das als *nicht prüfbar* fest, nicht als *erfüllt*.

### (6) Closure-Notiz mit Steering-Loop-Lerneintrag → **n. a. (offen)**

§7 des Plans ist unausgefüllt, der Slice liegt in `in-progress/`. Das ist der korrekte Zustand vor
der Closure; der Punkt gehört dem Planner und ist kein Verifier-Befund.

## `ADR-0010`: Festlegungen und die sieben Folgepflichten

| Gegenstand | Stand | Beleg (selbst geprüft) |
|---|---|---|
| Festlegung 1 (Schichten, Rollen, 4 Kanten, `composition_root`, Verdrahtungsort) | erfüllt | `goHexagonalArchConfig` + Rollen-Renderer Zeile für Zeile gegen die ADR-Tabelle |
| Festlegung 2 (getrennte Layouts, disjunkte Namen) | erfüllt | `TestArchLayouts_Disjunkt` + Fall 101 rot |
| Festlegung 3 (fail-closed-Default) | erfüllt | `driving` ist Schicht, nicht Composition Root; Lockerungs-Zeile im Config-Kopf und im Handbuch |
| Folgepflicht 1 (strukturelle Erkennung) | erfüllt | `isLayerRole`; Fälle 102/103 rot |
| Folgepflicht 2 (`architecture.md` §5) | erfüllt | neuer Absatz „Ein zweites schichten-tragendes Layout", dazu Achsen- und Komponenten-Tabelle nachgezogen |
| Folgepflicht 3 (cpp bewusst draußen) | erfüllt | `langArchs()["cpp"]` ohne `hexagonal`; `TestGenerateArch_LangSpecificArchRejected`; im Smoke real Exit 2 ohne Artefakt |
| Folgepflicht 4 (Config-Kopf begründet die Pfad-Abweichung) | erfüllt | „WARUM DIE PFADE VOM STANDARD-GERUEST ABWEICHEN" im emittierten Kopf |
| Folgepflicht 5 (Nutzer-Doku: strengere treibende Seite + Lockerung) | erfüllt | Handbuch §„Ein geschichtetes Grundgerüst wählen" |
| Folgepflicht 6 (Zeiger aus den Konventionen) | erfüllt | `MR-017`, benennt die ADR als Quelle, drei gelebte Instanzen, Auflösungs-Trigger |
| Folgepflicht 7 (`lateral-adapter`-Zahn) | erfüllt | Zahn 2 oben, von mir rot gesehen |
| `AGENTS.md` §3.4 (ADR nach Accepted immutabel) | eingehalten | `git log -- docs/plan/adr/0010-…md` endet bei `342effd` (dem Accepted-Commit), keiner der drei Prüf-Commits fasst sie an |

## Auflösung der Review-Befunde (F-1 bis F-5)

- **F-1 (MEDIUM, fehlende Haltbarkeits-Fälle) — real aufgelöst, nicht kosmetisch.** Die drei
  benannten Wächter haben jetzt je einen Fall (**104** Datei-Satz, **105** Schicht-Glob-Kopplung,
  **106** Zyklenfreiheit). Alle drei habe ich selbst rot gesehen, und zwar **mit dem in `# expect:`
  genannten Wächter in der FAIL-Zeile** — `harness/tools/mutate.sh` erzwingt genau das, ein
  Compile-Fehler oder ein anderer roter Test genügt ihm nicht. Damit trägt go×hexagonal jetzt
  dieselbe Korpus-Dichte wie go×hexslice und cpp×hexslice.
- **F-2 (MEDIUM, kein AC in der bindenden Anforderung) — aufgelöst durch CR 0.18.0 (`dbbb110`).**
  `LH-FA-07` beschreibt das Gate jetzt über die **Layout-Klasse** mit **struktureller**
  Emissions-Bedingung statt einer Namensliste, und trägt zwei neue AC („Zähne mit Regel-Namen je
  Layout", „Layouts sind disjunkt"). Beide neuen AC sind durch reale Sensoren gedeckt (Zähne:
  `full-smoke`; Disjunktheit: `TestArchLayouts_Disjunkt` + Fall 101).
- **F-3 (LOW) — aufgelöst.** `AGENTS.md` §4 und `harness/README.md` sagen jetzt beide
  „schichten-tragendes Layout … entscheidet **keine Namensliste**".
- **F-4 (LOW) — aufgelöst.** `test/mutations/63-langarch-support.sh` begründet „beide Stufen"
  jetzt präzise für den **unbekannten** Wert und verweist auf den eigenen Fall der
  sprach-spezifischen Stufe.
- **F-5 (INFO) — aufgelöst, aber ausdrücklich nur als Benennung.** Der Kommentar in
  `layeredArchsFor` schreibt die Grenze und den deckenden Wächter hin; die Auswahl-Mechanik selbst
  ist unverändert. Das ist die Auflösung, die ein INFO verdient — mehr wäre Umbau ohne Anlass.

## Zur Belastbarkeit der Messung

- **„Byte-identisch" ist nicht gemessen — weder von mir noch von einem Sensor des Repos.** Das ist
  die wichtigste Einschränkung dieses Reports. Kein Wächter vergleicht den **Inhalt** der
  `flat`-/`hexslice`-Skelette gegen einen Stand **vor** dem Slice. Was existiert:
  `TestGenerate_FlatUnchangedByArch` (vergleicht `GenerateArch(flat)` gegen `Generate()` —
  **beide** aus demselben Stand, eine Äquivalenz zweier Aufrufwege, keine Baseline),
  `TestGenerate_GoProfile` / `…GoHexsliceProfile_FileSet` (Datei-**Sätze** als Literal-Listen) und
  `TestGenerate_Deterministic` (zwei Läufe desselben Standes). Änderte jemand morgen eine
  `flat`- oder `hexslice`-Inhaltskonstante, bliebe der gesamte Gate-Stack grün. Meine Bestätigung
  von DoD (1) an dieser Stelle ruht deshalb auf dem **Quell-Argument** oben, nicht auf einem
  Ausgabe-Vergleich. Ich habe den Vergleich zweier gebauter Binaries bewusst **nicht** gefahren:
  er hätte verlangt, ein Binary außerhalb eines `make`-Targets laufen zu lassen.
- **Der Teil der Zusage, der ein rot gesehenes Gegenbeispiel verlangt, hat eines.** Der Plan hängt
  das „rot gesehen" an die **Gate-Entscheidung** von `hexslice`, nicht an die Bytes — und Fall 103
  liefert genau das. Die Zusage ist insofern eingelöst, wie sie formuliert ist.
- **Was `full-smoke` bei Erfolg nicht druckt.** Die drei Marker `apps-hexagonal:build`,
  `apps-hexagonal:lint` und `apps/hexagonal":/src:ro` werden gegen die aufgefangene
  `make gates`-Ausgabe geprüft und nur **im Fehlerfall** ausgegeben. Mein Beleg dafür ist also die
  Abwesenheit des Abbruchs (das Skript ist fail-closed), nicht eine Zeile im Log. Direkt sichtbar
  ist dagegen, dass `a-check` über dem Modul wirklich läuft: beide Zahn-Läufe rufen
  `make a-check-apps-hexagonal` und liefern Befundzeilen.
- **Laufzeiten sind hier keine Aussage.** `make gates` in 27 s und `full-smoke` in 1 m 20 s
  bedeuten warme Docker-Layer (an diesem Tag lief beides bereits mehrfach). `make mutate` brauchte
  10 m 09 s für 102 Fälle; der slice-057-Vergleichswert (7 m 18 s) galt für 94 Fälle — die Zahlen
  sind nicht gegeneinander lesbar und werden hier auch nicht so verwendet.
- **Plan-Treue in beide Richtungen geprüft.** Die Änderungs-Tabelle des Plans (§3) ist vollständig
  abgearbeitet. Über die Tabelle hinaus berührt wurden `cmd/ai-harness-init/main.go` (Hilfetexte
  für den dritten Achsenwert — sachlich zwingend) und `harness/conventions.md` (`MR-017` — von
  `ADR-0010` Folgepflicht 6 verlangt, im Plan nur nicht tabelliert). Nichts Ungefragtes darüber
  hinaus; kein `//nolint`, kein `# shellcheck disable`, keine Gate-Lockerung.
- **`MR-015` zum CR-Commit `dbbb110`.** Form eingehalten: eigener Commit, **ausschließlich**
  `spec/lastenheft.md` (1 Datei, +26/−8), Header-Version 0.17.0 → 0.18.0, Historie-Zeile mit
  Verweis auf die Nutzer-Entscheidung. Die Ordnungs-Abweichung — der CR liegt **nach** dem
  `next → in-progress`-Move (`14828ba`), nicht davor — ist in der Historie-Zeile **und** in der
  Commit-Message selbst benannt. Ich bestätige beides als zutreffend: `git log --oneline` zeigt die
  Reihenfolge, und die Abweichung ist deklariert statt kaschiert.

## Abweichungen

| # | Schwere | Befund |
|---|---|---|
| A-1 | LOW | **„Byte-identisch" ist eine Zusage ohne Sensor.** Kein Wächter deckt den *Inhalt* der `flat`-/`hexslice`-Skelette gegen einen Vorher-Stand ab (Details oben). Die Eigenschaft **hält heute** (statisch belegt), aber sie ist nicht bewacht — dieselbe Klasse wie die slice-053-Lehre. Ergänzend: seit CR **0.16.0** sagt `LH-FA-04` für `flat` „**funktional unverändert**" statt „byte-identisch"; der DoD-Text ist damit **strenger als die bindende Anforderung** und sollte bei der Closure an sie angeglichen oder mit einem Sensor unterlegt werden. |
| A-2 | LOW | **`test/mutations/104-hexagonal-role-fileset.sh` begründet falsch.** Der Kopf sagt, das Skelett „uebersetzt weiter" und der Datei-Satz-Wächter sei „der einzige", der die Vollständigkeit hält. Das stimmt nicht: `greet.go` (`goHexagonalService`) benutzt `Greeting` und `NewGreeting` aus der entfernten `greeting.go` — dasselbe Paket `core` übersetzt danach **nicht**, `TestGenerate_GoHexagonal_Compiles` fällt in der Docker-test-Stage mit. Der Fall **trägt trotzdem** (mutate verlangt den `# expect:`-Namen in der FAIL-Zeile, und `TestGenerate_GoHexagonalProfile_FileSet` fällt real — von mir gesehen); die **Prosa im Sensor-Korpus** ist die Fehlaussage. Exakt die Klasse, die der Review als F-4 an Fall 63 gefunden hat, eine Datei weiter. |
| A-3 | INFO | **Historie-Tabelle ohne erkennbare Ordnung.** Die neue Zeile 0.18.0 steht **vor** 0.17.0 und 0.16.0. Die Tabelle läuft bis 0.15.0 aufsteigend; der Schwanz ist es seit 0.17.0/0.16.0 (vor diesem Slice entstanden) nicht mehr. Kosmetisch, keine Regel verletzt — aber die Datei hat damit keine Sortier-Aussage mehr, und `MR-015` nennt eine frühere Zeilenreihenfolge-Korrektur ausdrücklich als Präzedenz. |
| A-4 | INFO | **Kein CLI-Ebenen-Test für `hexagonal`.** `cmd/ai-harness-init/main_test.go` führt `--arch hexslice` end-to-end (samt Mutations-Fall `TestRun_AddLangArchHexslice`); für `hexagonal` gibt es keinen Zwilling — die CLI-Ebene hängt allein am `full-smoke`. Vertretbar, weil die Emissions-Verdrahtung arch-generisch ist (`main.go` fragt nur `gen.ArchGateConfig(…)` auf `ok`), aber es ist ein Sensor-Loch pro Achsenwert, das mit dem vierten Layout wächst. |
| A-5 | INFO | **`MR-017` steht nicht in der Plan-Tabelle**, wurde aber geliefert (`ADR-0010` Folgepflicht 6 verlangt ihn). Abweichung in Richtung „mehr als geplant", ADR-gedeckt — hier nur der Vollständigkeit halber benannt, damit die Plan-Tabelle bei der Closure nachgezogen werden kann. |

Keiner dieser Punkte ist eine **DoD-Verletzung** im Sinne von Modul 11: kein DoD-Punkt behauptet
etwas, das der Artefakt-Stand nicht hergibt. A-1 ist der Grenzfall — die Zusage ist *weiter als
ihre Abdeckung*, aber sie **stimmt**, und der Teil, für den der Plan ein rot gesehenes
Gegenbeispiel verlangt, hat eines.

## Verdikt

**DoD BESTÄTIGT** — Punkte (1) bis (4) vollständig und aus eigenen Sensor-Läufen; Punkt (5)
inhaltlich bestätigt, seine **Reihenfolgen-Zusage** ausdrücklich als *nicht prüfbar* markiert;
Punkt (6) offen und korrekt offen (Planner-Aufgabe vor der Closure).

Keine Rückkante zur Implementation. Vor der Closure nachzuziehen: A-1 (Zusage an die Abdeckung
angleichen oder einen Sensor bauen) und A-2 (die falsche Begründung in Fall 104) — beides
Textarbeit am eigenen Anspruch, kein Codepfad.
