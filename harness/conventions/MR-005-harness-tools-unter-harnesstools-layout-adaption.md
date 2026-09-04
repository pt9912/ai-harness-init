# MR-005 — Harness-Tools unter harness/tools/ (Layout-Adaption)

> **ÜBERHOLT: die Abweichungs-Aussage — `harness/tools/` an der Stelle eines Baseline-Defaults `tools/harness/` → [`MR-047`](../conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr).** Der Ort existiert am adoptierten Stand nicht mehr; die Layout-Setzung selbst, die Ausnahme für den kompilierten Span-Emitter und der offene Reconciliation-Punkt gegenüber der emittierten Struktur binden unverändert fort.

- **Datum:** 2026-06-14
- **Geltungsbereich:** [`harness/tools/`](../../harness/tools/), [`.claude/`](../../.claude/), [`.codex/`](../../.codex/), `Makefile`, `.d-check.yml`
- **Ersetzt-Baseline-Regel:**
  [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-durchsetzungsschicht.md#das-vollständige-artefakt-set)
  §Das vollständige Artefakt-Set. Am Stand `v5.12.0` heißt der Abschnitt §Referenz-Implementierung
  und verortet die zwei Nachweis-Skripte: *„`tools/harness/working-tree-hash.sh` +
  `record-gates.sh` — gemeinsame, inhaltsbasierte Nachweis-Quelle für Gate-Lauf und Handoff-Gate"*
  (`git show db83415^:.harness/baseline/v5.12.0/regelwerk/grundlagen-durchsetzungsschicht.md`,
  Tree-Operand nach [`MR-040`](../conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)
  Ausgang 2). An ihre Stelle tritt `harness/tools/`. **Am adoptierten Stand `v5.18.0` nennt der
  Abschnitt keinen Ort mehr** — dort steht *„eine gemeinsame, inhaltsbasierte Nachweis-Quelle für
  Gate-Lauf und Handoff-Gate (eine Wahrheit, keine Logik-Dopplung)"*, und der Pfad kommt im ganzen
  Baum nicht vor
  (`grep -rc 'tools/harness' .harness/baseline/v5.18.0/regelwerk/ .harness/baseline/v5.18.0/templates/`
  → keine Nicht-Null-Zeile). Welchen der fünf Ausgänge das diesem Eintrag gibt, entscheidet der
  Adaptions-Durchgang (slice-157); dieser Eintrag trägt die Adresse und die Messung, nicht das
  Verdikt.
  **Die Abweichung ist dünner, als der Rumpf unten sie führt, und das ist gemessen:** am
  Stand `v5.12.0` ist das die einzige Nennung des Pfades
  (`git grep -c 'tools/harness' db83415^ -- '.harness/baseline/v5.12.0/'` gibt genau eine Zeile,
  und zwar für diese Datei), sie trägt einen `d-check:ignore`-Marker mit der
  Begründung *„Referenz-Artefakt im Fallstudien-Repo"*, und
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md#verzeichniskonvention)
  §Verzeichniskonvention führt für ausführbare Harness-Tools **gar keinen** Ort — `harness/` steht
  dort mit `README.md`, `conventions.md` und `conventions/`, `.harness/` mit Skills, Allowlists und
  Checklisten-Middlewares.
- **Adaption:** Die ausführbaren Harness-Tools (Gate-Nachweis, Working-Tree-Hash,
  Command-Guard-Extraktor, SessionStart-Injektor + awk-Encoder) liegen unter
  `harness/tools/` statt dem Baseline-Default `tools/harness/`. **Eine Ausnahme, und
  sie ist keine Aufweichung:** der Span-Emitter (slice-059) ist ein **kompiliertes**
  Harness-Tool und liegt deshalb im Go-Modulbaum (`cmd/span-emit/` + `internal/span/`)
  — Go-Quellen können nicht unter `harness/tools/` liegen, ohne aus dem Modul zu
  fallen. Die Regel gilt für **Skripte**; die Shell-Hälfte desselben Slice
  (`harness/tools/span-check.sh`) liegt regelkonform hier. Wer das Layout für die
  Emission liest (slice-062/063), muss den Emitter also **zusätzlich** zu diesem
  Verzeichnis betrachten (Review-Befund LOW-3). Damit liegt die
  gesamte Harness — Docs (`harness/README.md`, `harness/conventions.md`) und
  Tooling — unter einem `harness/`-Dach (der Regelwerk-Cache liegt gitignored
  unter `.harness/cache/`, siehe [`MR-004`](../conventions.md#mr-004--sessionstart-regelwerk-injektor)).
  Folge: `codepaths.roots` verliert das nicht mehr existierende `tools` (die
  Tools sind unter `harness` weiter abgedeckt); alle Hook-/Makefile-/Test-
  Referenzen und die vorherigen Tooling-MR-Geltungsbereiche sind angepasst.
- **Begründung:** Kohäsion — eine Wurzel für die Harness (Nutzer-Entscheidung).
- **Auflösungs-Trigger:** permanent. **Offen — Reconciliation:** Die in
  [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und [`ADR-0004`](../../docs/plan/adr/0004-durchsetzungs-emission.md) beschriebene **emittierte**/Template-Struktur nennt
  weiterhin `tools/harness/`; ob die Emission der lokalen Konvention folgt, ist
  ein CR-/ADR-Folgepunkt (hier bewusst nicht berührt — Lastenheft ist rank-1,
  die Accepted-ADR immutable).
