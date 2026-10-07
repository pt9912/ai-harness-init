# Inventur: Emittiertes gegen das Regelwerk `v6.16.0`

**Rolle:** Planner. **Datum:** 2026-10-07. **Regierend:** [ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md).

**Delta:** `v6.13.0..v6.16.0`, Kurs-Wellen 154–159, 22 Dateien (8 Regelwerk, 14 Vorlagen) —
`git -C <Kurs-Klon> diff --stat v6.13.0..v6.16.0 -- lab/regelwerk lab/templates`, wörtlich gelesen.

**Gegenstand** (Arbeitsbaum dieser Inventur):

```sh
find internal/emit/templates -type f | wc -l                                  # 38 eingebettete Dateien
ls internal/emit/*.go internal/gen/*.go | grep -vc _test                       # 23 Generator-Dateien
find .harness/baseline/v6.16.0/templates -name '*.template.md' | wc -l        # 25 Kurs-Vorlagen
grep -n 'const DefaultTag' internal/fetch/baseline.go                         # v6.16.0 — Pin, mit dem die Vorlagen reisen
```

Von den 25 Vorlagen schreibt `planTemplates` (`internal/emit/templates.go`) zehn als Datei ins Ziel —
`AGENTS.md`, `harness/README.md`, `harness/conventions.md`, die drei Spec-Straten,
`docs/plan/planning/README.md`, die Roadmap, die zwei Skill-Dateien —, dazu die Root-README über
`readme.go`; die wiederkehrenden liegen nur im vendored Baum des Ziels.

## Befunde

| # | Datei / Generator | Regelwerk-Änderung | Befund | Einordnung | vor `v0.2.9` |
|---|---|---|---|---|---|
| 1 | `AGENTS.md` (Vorlage) | W159 · `AGENTS.template.md` §4 | reicht den Satz durch, Werkzeug-Targets stünden im verlinkten Werkzeug-Teil; den Teil schreibt das Werkzeug noch nicht | geplant: `slice-targets-modul-im-emittierten-doc-gate` | ja (Sperre, Festlegung 5) |
| 2 | `harness/README.md` (Vorlage) | W159 · Kommentar §Sensors; W158 · Bindung „Spec-Kennung" | Link-Zeile auf `harness/mk/ai-harness-init.md` fehlt; der Beispiel-Link im Kommentar fällt unter `NeutralizePlaceholderLinks` | geplant: targets-Slice (§3, Zeile emittiertes README) | ja |
| 3 | `.d-check.yml` (`internal/emit/templates/d-check.yml`) | W159 · `.d-check.yml`-Vorlage, `targets` über die Vereinigung | kein `targets` | geplant: targets-Slice | ja |
| 4 | dito, Kopfkommentar | W158 · `spezifikation.template.md` §7 → §8 Historie | „ihre Ueberschrift ist 7. Historie" ist am Pin falsch | geplant: `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation`, DoD 3 | ja — falsche Aussage im emittierten Bestand; nicht von der Sperre gedeckt |
| 5 | Werkzeug-Teil `harness/mk/ai-harness-init.md` (fehlt) für alle Fragmente aus `internal/emit` und `internal/gen` | W159 · `grundlagen-harness-dateien.md` §Ein Index, mehrere Eigentümer; `modul-13-quality-gates.md` §Hard Rule | Teil fehlt; der Slice verlangt eine Zeile je emittiertem Target, gemessen nur `--lang go` | geplant: targets-Slice (Grenze `cpp`/`--arch` dort benannt) | ja |
| 6 | `harness/erfassung-feldliste.md` (`fieldlist.go`, verbatim aus `span.FieldList`) und Träger | W154 · `modul-15-observability.md` §Span-/Audit-Attribut-Regeln | Cache-Status *Optional*, fehlt ohne Payload-Zähler; die Feldliste folgt dem Span-Typ konstruktiv | geplant: `slice-span-pflichtfeld-traegt-nicht-bekannt` | ja — die Feldliste erklärt ein Feld des Pflicht-Minimums für optional |
| 7 | `.harness/skills/reviewer.md`, `closure-note-reviewer.md` (Vorlagen) | W155/156 · `modul-10-review-harness.md`, Reviewer-Vorlagen | reisen mit dem Pin | schon konform (`DefaultTag`, `inScope`) | — |
| 8 | `agents/reviewer.md` | W155/156 | trägt kein Output-Schema (`grep -c pfad internal/emit/templates/agents/reviewer.md` → 0) | schon konform ([ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) §Emittierte Ebene) | — |
| 9 | `spec/spezifikation.md` (Vorlage) | W158 · §7/§8 | reist mit dem Pin | schon konform | — |
| 10 | `harness/conventions.md` (Vorlage, `NeutralizeConventionsTemplateRef`) | Vorlagen-Form `BEO-<KUERZEL>/<slug>` | Marker trifft am Pin genau einmal | schon konform | — |
| 11 | `docs/plan/planning/README.md` (`NeutralizePlanningReadmeCarveoutsDoneRef`) | — | Marker trifft am Pin genau einmal | schon konform | — |
| 12 | Roadmap (`NeutralizeRoadmap`) | — (Vorlage im Delta unverändert) | Marker trifft am Pin nicht; der Platzhalter-Link fällt unter `NeutralizePlaceholderLinks`; `TestNeutralizeRoadmap` bleibt grün über der Fixture mit altem Wortlaut | neue Lücke → `slice-neutralisierung-haelt-ihren-wortlaut-am-gepinnten-stand` | nein — emittierte Bytes unverändert |
| 13 | `commands/*.md`, `observations/README.md` | Vorlagen-Form `BEO-<KUERZEL>/<slug>` | führen die Form (`close-welle.md:77`, `implement-slice.md:188`, `README.md:22`) | schon konform | — |
| 14 | wiederkehrende Vorlagen (Slice, Welle-Results, Review-Report, ADR samt Index, Sensor-Datei, MR) | W155–159 | liegen nur im vendored Baum des Ziels, reisen mit dem Pin | schon konform | — |
| 15 | `Makefile` (Aggregator, `makefile.go`) | W159 · `Makefile`-Vorlage, Kommentar | der Kommentar behauptet keinen einzigen Index | schon konform | — |
| 16 | Baumaussage (`baumaussage.go`) | Mess-Tag; Zeilen `grundlagen-harness-dateien.md`, `modul-13` | `InventurMessTag = "v6.16.0"`; die Zeilen bleiben wahr, auch nach dem targets-Slice | schon konform | — |
| 17 | Köpfe der Hooks und nur emittierten Werkzeuge (`pretooluse-command-guard.sh`, `stop-require-gates.sh`, `span-emit.sh`, `commit-msg-hook.sh`, `selbstpruefung.sh`) | W158 · `grundlagen-referenz-richtung.md` §Spec-Straten; `modul-03-spec.md` | die Festlegung steht im Skriptkopf, keine Spec-Stelle; der Vorgänger misst nur `harness/tools/` und `harness/sensors/` | neue Lücke → `slice-hook-festlegungen-ziehen-in-die-spezifikation` | nein — der Ort der Festlegung ist die Spec dieses Repos, der emittierte Text bricht keine Regel im Ziel |
| 18 | Köpfe mit Zwilling unter `harness/tools/` (`commit-msg-traceability`, `e2e-abdeckung`, `history-range-guard`, `record-gates`, `slice-mv`, `traeger-fetch`, `working-tree-hash`) | W158 | Inventur dort, DoD 1 | geplant: `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation` | nein |
| 19 | übrige (`*.mk`, `settings*.json`, `gitignore`/`gitattributes`/`gitkeep`, `extract-command.awk`, `baseline-verify.sh`, Root-README, Träger-, Archiv-, Zeilenenden-, E2E-Generatoren, `.a-check.yml`) | keine außer W159 (Zeile 5) | — | schon konform | — |

**Summe:** 10 schon konform · 7 schon geplant · 2 neue Lücken (Zeilen 12, 17). Das Repo-`repo.mk`
(`slice-anwender-targets-leben-in-repo-mk`) widerspricht `v6.16.0` nicht: Targets des Repos stehen
weiter in `harness/README.md`.

## Vor dem Release `v0.2.9`

Die Sperre ([ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 5)
deckt Zeilen 1–3 und 5. Darüber hinaus emittieren Zeile 4 (`d-check.yml`-Kommentar) und Zeile 6
(Feldliste) eine dem Pin widersprechende Aussage; beide sind geplant, aber von keiner Sperre
gehalten. Die zwei neuen Lücken sind nicht vor dem Release fällig.
