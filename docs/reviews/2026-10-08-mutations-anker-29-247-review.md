# Review — Mutations-Anker 29/247 nachgezogen

* Gegenstand: Commit `98bfab0b` (`test/mutations/29-roadmap-nicht-neutralisiert.sh`,
  `test/mutations/247-archive-welle-go-schalter-erreicht-zweig-nicht.sh`)
* Bezug: [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
* Rolle: Reviewer (Skill `.harness/skills/reviewer.md`), kein Slice-Plan (Werkzeug-Nachzug)

## Findings

Keine. HIGH 0 · MEDIUM 0 · LOW 0 · INFO 0.

## Belege

**Anker trifft genau eine Zeile im Quellbestand** (Stand `98bfab0b`):

```sh
grep -nP '^\t\treturn InjectRoadmapRuheMarker\(NeutralizeRoadmap\(body\)\), nil$' internal/emit/templates.go
# 466:		return InjectRoadmapRuheMarker(NeutralizeRoadmap(body)), nil
grep -nP '^\treturn archiveWelleLauf\(root, abst, welle, vorschau, porcelain, dateien, e\.schreibend\(root\), out, errOut\)$' cmd/ai-harness-init/archive_welle.go
# 172:	return archiveWelleLauf(root, abst, welle, vorschau, porcelain, dateien, e.schreibend(root), out, errOut)
```

Beide Fälle in einer Kopie (`git archive 98bfab0b | tar -x`) angewandt: je genau eine Zeile
geändert (`git diff --no-index --stat` → 1 insertion, 1 deletion; `grep -c` auf die mutierte Form → 1).

**Dieselbe Eigenschaft wie vorher:** Fall 29 nahm bis `f9fa9e13` die Zeile
`return NeutralizeRoadmap(body), nil` weg (Durchfall auf `return body, nil`); jetzt fehlt
`NeutralizeRoadmap` innerhalb der in `f9fa9e13` hinzugekommenen Injektion — in beiden Fassungen
erreicht der unneutralisierte Body das Ziel. Fall 247 kehrt `vorschau` an der Weitergabe um; der
in `087f990d` eingefügte Parameter `abst` ändert daran nichts. `# expect:` unverändert.

**Rot aus dem richtigen Grund** (Kopie mit beiden Mutationen, `make test-go`, rc=2):

- `TestTemplates_RoadmapGateSafe` — `neutralisierung_test.go:195: emittierte Roadmap traegt einen toten ../done/-Link`
- `TestArchiveWelleReichtDenSchalterVomArgumentBisZumZweig` — `archive_welle_test.go:271: --vorschau im Argument-Feld hat den Baum veraendert`

**Gegenprobe** (zweite Kopie, Mutationen angewandt, `t.Skip` ausschließlich in den zwei benannten
Tests, `make test-go`):

- Fall 29: `internal/emit` → `ok` — der benannte Test bindet allein.
- Fall 247: `cmd/ai-harness-init` bleibt rot mit `TestArchiveWelleOhneSchalterSchreibtAmSelbenArgumentFeld`
  und `TestArchiveWelleEchtArchiviertUndSetztZweiCommits`. Beide messen die Gegenrichtung (ohne
  `--vorschau` wird geschrieben: `archive_welle_test.go:294`, `archive_welle_echt_test.go:201`);
  der benannte Test misst `--vorschau` → Baum unverändert, was keiner der beiden misst. Kein Befund
  (Skill §LOW/INFO mit Eskalation, dritter Punkt: eigener Beitrag vorhanden). Der Fall-Kopf behauptet
  keine Exklusivität des Tests.

## Negativbefund

- Anker-Eindeutigkeit (beide Fälle): geprüft, ohne Befund.
- Eigenschafts-Treue gegenüber der Vorfassung und `# expect:`: geprüft, ohne Befund.
- Bindung der Zusicherung (Gegenprobe gefahren, beide Fälle): geprüft, ohne Befund.
- Kopfkommentar Fall 29 nach [`AGENTS.md`](../../AGENTS.md) §3.7 (Zusage + Kopplung an Fall 571,
  keine Chronik, kein abwesender Text): geprüft, ohne Befund; Fall 247 Kopf unverändert.
