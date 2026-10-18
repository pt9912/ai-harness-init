# Review slice-csharp-hexslice-layout — Diff 3e91174c..6964b9c7

**Rolle:** Reviewer (Skill `.harness/skills/reviewer.md`, Modul 10). **Datum:** 2026-10-18.
**Gegenstand:** sechs Implementer-Commits 50b65502, fc260961, 3811d1a8, a8d32951, 61306d52, 6964b9c7 zu
`slice-csharp-hexslice-layout` (in-progress). **Maßstab:** Plan, ADR-0096 (v. a. Festlegung 5), ADR-0060,
ADR-0094/0095, AGENTS.md §3. Nicht gegen die DoD (Verifier).

**Summary:** 0 HIGH · 2 MEDIUM · 0 LOW · 4 INFO. Die MEDIUM blockieren den Merge nicht als Code-Defekt, brauchen
aber vor Merge eine Klärung (F1: falsche Ursachen-Aussage in der emittierten Config; F2: Entscheidung des
Architect, ob `port-locality` für C# ungeprüft bleibt).

## Findings

### F1 — MEDIUM — emittierte Config nennt die falsche Ursache für den Port-Glob-Hinweis

- `kategorie`: MEDIUM · `quelle`: AGENTS.md §3.6 (Zusage ohne gemessenes Gegenbeispiel), §3.7 (Kommentar sagt nur Gemessenes)
- `pfad`: `internal/gen/csharp_hexslice.go:252-254` (Kommentar der emittierten `.a-check.yml`)
- `befund`: Der Kommentar sagt, ein Port-Ordner `ports` in Kleinschreibung nehme den Hinweis. Gemessen am
  Probe-Ziel (`--lang csharp --arch hexslice`, a-check im Pin des Repos) ist es das **Richtungs-Segment**
  `Inbound`/`Outbound`, nicht `ports`: (1) `Ports` → `ports` bei großem `Inbound`/`Outbound`: der Hinweis
  „2 Port-Glob(s) erreichen den App-Baum nicht" bleibt; (2) `Ports` groß, `Inbound`/`Outbound` →
  `inbound`/`outbound` (Verzeichnisse, Namensräume `Ports.inbound`, Config-Globs): kein Hinweis, `0 Befund(e)`; (3) im
  Fall 2 plus zweiter Slice `Other` mit `using …Other.Ports.outbound;` im Handler: `port-locality: app außerhalb
  Port-Scope …/Other` (Rot). Die Vermutung des Implementers (Schreibweise von `ports`) trägt nicht; der
  Adopter, der dem Kommentar folgt, behält den Hinweis und bricht die Verzeichnis-gleich-Namensraum-Regel für nichts.
- `verifizierbar`: ja (Probe wie beschrieben; kein Sensor hält die Aussage)
- `klasse`: Ursachen-Aussage über ein Fremdwerkzeug ohne Gegenprobe an der behaupteten Ursache

### F2 — MEDIUM — `port-locality` ist für C# real ungeprüft; Behebung berührt eine ADR-Festlegung

- `kategorie`: MEDIUM · `quelle`: LH-QA-01, ADR-0096 Festlegung 5, ADR-0060
- `pfad`: `internal/gen/csharp_hexslice.go` (Config-Globs `…/Ports/{Inbound,Outbound}/**`), `spec/architecture.md:260`,
  `docs/user/e2e-abdeckung.md` (Zeile LH-FA-04/07, Stufe 19)
- `befund`: Gemessen am Probe-Ziel: ein `using` in `Greet/Handler.cs` auf `…Other.Ports.Outbound` (fremde Slice) bleibt
  bei den ausgelieferten PascalCase-Port-Globs **grün** (Exit 0, `0 Befund(e)`, nur der Hinweis „3 Port-Glob(s) erreichen den
  App-Baum nicht — port-locality bleibt dafür ungeprueft"). Die Aussage „ungeprüft" ist damit richtig, nicht zu schwach und nicht zu
  stark; Java und Python (kleingeschriebene `ports/inbound`) prüfen die Regel. Die Grenze steht an vier Orten (Config-Kommentar,
  `spec/architecture.md`, Abdeckungs-Zeile, Stufen-Kopf in `harness/tools/full-smoke.sh`) konsistent; ADR-0096 Festlegung 5 nennt sie in
  ihrer Liste „Nicht erkannt" **nicht**, und die Stufe pinnt weder den Hinweis noch seine Abwesenheit. Kein stilles Grün im Sinn
  eines verschwiegenen Ausschnitts (der Hinweis steht in der Ausgabe), deshalb nicht HIGH; der Hinweis sieht aber nur, wer die
  a-check-Ausgabe liest, `make gates` bleibt grün. Eine Behebung im Rahmen des Slice (kleingeschriebene `inbound`/`outbound`-Verzeichnisse,
  Namensräume `…Ports.inbound`) widerspräche der Festlegung „Verzeichnisse in PascalCase" (ADR-0096 Festlegung 5 / ADR-0060)
  und ist eine Architect-Entscheidung.
- `verifizierbar`: ja (Probe wie F1)
- `klasse`: Lücke eines Fremdwerkzeugs in der ADR-Grenzliste nicht benannt

  **Entscheidungsbedarf (nur benannt):** ADR-0096 braucht eine Folge-ADR oder der Architect einen Nachtrag, der entweder
  `port-locality` in C# als nicht gehalten ausweist (und die Richtungs-Segment-Ursache aus F1 nennt) oder die Schreibweise
  der Richtungs-Verzeichnisse ändert. Der Reviewer entscheidet das nicht.

### F3 — INFO — Fall 756/755/750: der benannte Test bindet nicht allein

- `quelle`: Reviewer-Skill (Mutations-Fall nennt einen Test, Mutation färbt mehrere), AGENTS.md §3.6 · `pfad`: `test/mutations/756-…`, `755-…`, `750-…`
- `befund`: Gegenprobe mit `t.Skip` ausschließlich im benannten Test, Mutation angewandt: 756 (`TestArchGateConfig_CsharpGlobsMatchRenderedDirs`
  geskippt) bleibt rot über `MatchesSkeleton`, `NamensraumGleichVerzeichnis`, `EdgesMatchSkeleton`, `FileSet`, `AddLangCsharpHexslice`; 755
  (`…CsharpResolution` geskippt) bleibt rot über sechs Tests; 750 über `…EdgesMatchSkeleton`. Eine Mutation, die allein die
  Config-Globs verändert, wurde nicht gefahren, daher ist offen, ob der in ADR-0096 verlangte Glob-gegen-Verzeichnis-Test etwas
  bindet, das `MatchesSkeleton` nicht bindet. Die Fall-Köpfe behaupten keine Exklusivität.
  Allein bindend (Suite grün beim Skip): 757, 758 (`EdgesMatchSkeleton`), 760 (`NamensraumGleichVerzeichnis`); 705 und 748 werden von den
  `TestRun_*`-Tests mitgefärbt (gemeinsame Stelle, kein Befund).
- `verifizierbar`: ja · `klasse`: Mutationsfall mit mitgefärbtem Test

### F4 — INFO — Kommentar „ohne ihn löst kein using auf"

- `pfad`: `internal/gen/csharp_hexslice.go:227` · `quelle`: AGENTS.md §3.7
- `befund`: Der Satz beschreibt die Abwesenheit des resolution-Blocks; er steht gleichlautend in der Java- und Python-Fassung und liest sich als Kopplung
  (Block ist tragend). Kein Befund über den Bestand hinaus.
- `klasse`: Kommentar über die abwesende Alternative (Bestandsform)

### F5 — INFO — Rolle: `spec/architecture.md` und `README.md` vom Implementer geändert

- `quelle`: AGENTS.md §3.8, ADR-0096 §Konsequenzen · `befund`: ADR-0096 benennt „Träger ist der Layout-Slice" für die Folgepflicht
  `spec/architecture.md` (Layout je Sprache). §3.8 bindet nur Hard Rules, Adaptions-Block und die ADR-Register; der Diff berührt weder AGENTS.md
  noch `harness/conventions.md` noch ADRs. Dieselbe Linie wie bei Java und Python: zulässig.

### F6 — INFO — Laufzeit-Messreihe aus 61306d52

- `quelle`: MR-089, AGENTS.md §3.6 · `befund`: Die Nennung von Kommando, Variante (`full-smoke-host`), Image-Lage (warm) und Host steht in der
  Message. Die Stufenzeit (hexSlice 23/11 s, flat 11/12 s gegen 16/11 s) trägt den Satz „Zuwachs rund 11 s" bei zwei Läufen je Seite. Der Ausreißer
  495 s Gesamt (gegen 313/330/318 s) ist nur um 12 s in der neuen Stufe verortet; die Erklärung „durch Mutationsläufe veränderter Cache" ist
  Hypothese, nicht gemessen, und plausibel (ein kalter Layer-Cache trifft Stufen außerhalb von C#). Als Beleg taugt die Reihe für die Stufenzeit,
  nicht für die Gesamtdauer; eine eigene Messung ist Sache des Verifiers.

## Gefahrene Proben (Beleg)

- **Probe-Ziel:** `ai-harness-init --lang csharp --arch hexslice .harness/state/probe-cs`; danach `make build lint test` Exit 0 und `make a-check`
  Exit 0 (mit dem Hinweis aus F1/F2); Probe gelöscht.
- **§3.3:** `git show --stat -M` je Commit: 50b65502 trägt allein `705-csharp-hexslice-ohne-renderer.sh => 705-csharp-hexagonal-ohne-renderer.sh | 0`
  (reiner Rename, 100 %); die Inhaltsänderung steht in fc260961 (8 Zeilen am Pfad der Zielnamens); kein anderer Commit zeigt einen Rename.
- **Mutationen** (`MUTATE_CASES=<Fall> MUTATE_JOBS=1 make mutate`, einzeln, kein Push): 705, 748–760 je `1 ok, 0 Befund(e)`; Lauf-Zähne 761, 762, 763 mit
  `SMOKE_ARTIFACT_TARGET=artifact-host` je `1 ok, 0 Befund(e)` (die `# expect:`-Zeilen sind die wörtlichen Meldungen der Stufe und nennen die Ursache:
  `core-impurity` an der Domain-Datei, `Import-Symbolen`, `wrong-direction driven_adapters -> ports_outbound`); Python 734, 735, 745 und Java 720, 723 je ok.
- **Gegenproben `t.Skip`:** siehe F3.
- **Bats:** `make test-bats BATS_TARGET=test/full-smoke-ausgang.bats` Exit 0 (die Abdeckungs-Gleichung hält mit den neuen Einordnungen).

## Geprüft, ohne Befund

- **§3.3:** Rename-Split sauber (siehe oben).
- **§3.6 inklusive Lauf-Zahn-Regel:** Text-Wächter (`…CsharpResolution`, `…EdgesMatchSkeleton`, `…GlobsMatchRenderedDirs`, `…NamensraumGleichVerzeichnis`) und Lauf-Zähne 761–763 liegen in derselben Lieferung; 761–763 färben aus dem behaupteten Grund (Meldung pinnt Regel und Fundstelle).
- **§3.7 (übrige Kommentare), §3.9, §3.2, §3.5:** Kommentare im Diff sagen Gemessenes bzw. Kopplung; keine Host-Toolchain, keine Suppression, keine Gate-Lockerung (`TestArchGateConfig_OnlyLayered` hebt `csharp/hexslice` auf true, `hexagonal` bleibt Exit 2).
- **(b) gelöschte Helfer:** `assertNurFlat` und `assertAddLangHexsliceIstExit2` haben nach dem Diff keinen Nutzer mehr (Suche im Baum leer); kein anderer Sprach-Test hat Zähne verloren. Fall 705 färbt `TestGenerateArch_CsharpOhneHexagonal` und `TestRun_AddLangCsharpHexagonalIstExit2`.
- **(c) `assertArchConfigResolution`:** das Python-Verhalten ist unverändert (Schlüssel, Root-Suffix, composition_root, exclude, Pfade unter Root); Python 734/735/745 und Java 720/723 rot-grün wie zuvor.
- **(d) Config/Skelett:** `languages`, `fixed-root`, Root `src/App`, `package_base App`, `exclude`, `composition_root`, Pfade `src/App/Hexagon/…`, I-Präfix, sieben Kanten inklusive `driven → ports_outbound`; `hexagonal` → Exit 2 (Test und Stufe). Skelett unter `TreatWarningsAsErrors`/`dotnet format` grün (Probe).
- **(e) Stufe und Abdeckung:** Gemessenes/NICHT Gemessenes am selben Ort; die flat-Stufe prüft `--arch hexagonal`.
- **(f) `spec/architecture.md`, README:** sachlich richtig, Zielbild ohne Zeit-/Liefersätze; die Aussage zu `port-locality` ist präzise genug, die Ursache dazu steht nur im Config-Kommentar (F1).

**Nicht gefahren:** `lateral-slice` an den Slice-Globs (nur gelesen); `<Using>` in der `.csproj` und Reflection (aus ADR gelesen); eine Mutation allein an den Config-Globs (F3).
