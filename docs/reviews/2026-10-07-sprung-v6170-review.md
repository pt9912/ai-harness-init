# Review — slice-sprung-auf-v6170-wird-vollzogen

- **Rolle:** Reviewer (Modul 10), frischer Kontext; Skill `.harness/skills/reviewer.md`
- **Datum:** 2026-10-07
- **Gegenstand:** Implementer `f9f082c5`, `53094b41`, `94a258ce`, `8b08c3ab`; Reviewer-Skill
  `78381a2b`; Architect `e8469f9c`, `43f37383`, `dfa42f8a`, `25a85c8b`, `6fb392e7`
- **Geprüft gegen:** Slice-Plan (in-progress), `ADR-0082` (Accepted), `MR-007`, `MR-032`,
  `MR-033`, `MR-046`, `MR-054`, `MR-063`, `MR-080`, `AGENTS.md` §3.3/§3.6/§3.7/§3.8/§3.11,
  Vorbild Sprung `v6.16.0` (`794ff85b`, `docs/migrations/v6.16.0.md`)

## Summary

Kein HIGH, kein MEDIUM, kein LOW. Zwei INFO. Merge nicht blockiert.

## Findings

### I-1 — INFO

- `quelle`: `ADR-0082` Festlegung 1 → Baseline-Regelwerk `modul-02-harness-bootstrap.md`
  §Freshness-Audit, Eigenschaft *Der Review vergleicht auch die Form*
- `pfad`: Commit `f9f082c5` (entfernt `.harness/baseline/v6.16.0/`) · Commit `dfa42f8a` (Verdikt)
- `befund`: Die Regel lässt das alte Verzeichnis erst fallen, „wenn der Review durch ist"; hier
  fällt `v6.16.0/` im Tausch-Commit vor dem Verdikt, und der Form-Vergleich lief über den
  maschinen-lokalen Kurs-Klon (`git -C /Development/KI/ai-harness-course diff v6.16.0 v6.17.0`).
  Inhaltlich gleichwertig, aber am Repo-Stand des Verdikts nicht nachfahrbar. Die Reihenfolge
  setzt der Plan (§1 Übergabe 3 „nach dem Vollzug"); Klärung ist Planner-Sache, kein
  Implementer-Befund.
- `verifizierbar`: nein
- `klasse`: Freshness-Review nach Entfernen des alten Baums

### I-2 — INFO

- `quelle`: `MR-032`, Eintrags-Vorlage `MR-NNN-titel.template.md` (Feld `Löst auf`)
- `pfad`: `harness/conventions/MR-083-…-trigger.md`
- `befund`: `MR-083` löst einen Satz von `MR-081` ab, führt aber kein Feld `Löst auf`; der Bestand
  ist bei Teil-Ablösungen uneinheitlich (mit Feld: `MR-063`, `MR-064`, `MR-066`; ohne: `MR-069`,
  `MR-070`, `MR-079`). Die Kette bleibt über die Kopf-Marke an `MR-081` auffindbar; eine Suche
  nach `Löst auf` findet sie nicht.
- `verifizierbar`: nein
- `klasse`: Teil-Ablösung ohne Löst-auf-Feld

## Bruchproben und Messungen

| Kommando | Ergebnis |
|---|---|
| `make mutate MUTATE_CASES=541-werkzeug-index-grenze-ohne-bedingung` | `1 ok, 0 Befund(e)` |
| Gegenprobe: Mutation 541 angewandt, `t.Skip` allein in `TestWerkzeugIndex_GrenzeNenntDisjunktheitsBedingung`, `make test-go` | rc=0, alle Pakete `ok` — der benannte Test bindet allein; Baum danach per `git checkout` zurückgesetzt, `git status` leer |
| `docker image inspect ghcr.io/pt9912/d-check:v0.83.0` (RepoDigests) | `sha256:cdc88b04…a1c3` = `DCHECK_DIGEST` in `d-check.mk` und `internal/emit/emit.go` |
| `/Development/d-check`: `git log v0.82.0..v0.83.0` | einzige Verhaltensänderung `authority-disjoint` (Panic-Fix betraf nur Zwischenstand `a73144dc`) — trägt „verfügbar wird allein" in `MR-082` |
| Link-Kommando aus Plan §1 über `v6.16.0` | 0 Links; Inline-Pfade nur in `docs/migrations/v6.16.0.md` (eingefrorener Report, wie `v6.8.0`/`v6.9.0`/`v6.13.0`) und im Plan selbst |
| `cat .harness/baseline/v6.17.0/regelwerk/*.md \| wc -c` | 384439 = `AGENTS.md` §1 |
| `git diff --stat 9d89397c HEAD -- .d-check.yml` | nur das `sources`-Paar; `ignore-refs` unverändert |

## Negativbefunde (geprüft, ohne Befund)

- **(a) Vendoring/Pins/Symlinks/Mess-Tag:** fünf Pins, `InventurMessTag`, 7 Symlinks und
  `templates.go` auf `v6.17.0`; verbleibende `v6.16.0`-Nennungen sind datierte Aussagen
  (`MR-033`), Plan-Text oder eingefrorene Artefakte; der einzige ADR-Link lag in der
  `Proposed`-`ADR-0061` und ist nachgezogen.
- **(b) d-check-Pin:** Digest gehört zu `v0.83.0`; die Gegenmessung gibt jedem aktiven Modul
  (neun Dogfood, sieben Ziel) eine Basis, Symlinks als Symlinks (`MR-063`, `MR-067`).
- **(c) Schalter und Grenz-Zeile:** Satz nennt die drei Bedingungen, die *sonst*-Hälfte und die
  Sensor-Grenze wie `ADR-0082` Festlegung 2; die benannte Grenze (zweites YAML-Dokument,
  `--disable/--enable targets`) steht als NICHT gemessen in der Stufen-Deklaration. Satz ist
  auch in bestehenden Zielen wahr, weil `d-check.mk` kanonisch mit neu geschrieben wird
  (Handbuch §kanonisch). Beide `full-smoke`-Stufen haben Gegenprobe und fail-closed Vorlauf;
  `full-smoke` nicht selbst gefahren (Implementer-Beleg, Verifier-Sache).
- **(d) MR-082/MR-083:** Pflichtfelder der Vorlage vorhanden, Form nach `MR-080`; Kopf-Marke an
  `MR-081` in der Form `> **ÜBERHOLT: <Reichweite> → <Ziel>.**` (`MR-032`), `MR-081` bleibt aktiv
  (`MR-046`); Beleg `grep -c 'ausdrücklich als nicht bekannt'` → 1 nachgefahren.
- **(e) Freshness-Verdikt als leerer Commit:** trägt nach Vorbild (`794ff85b` führte das Verdikt
  ebenfalls in der Commit-Message); alle neun Kandidaten mit Urteil — Rest siehe I-1.
- **(f) migration.md ohne `docs/migrations/v6.17.0.md`:** in §1 benannt; §6 hält die
  Report-Pflicht ausdrücklich offen — zulässig.
- **(g) Handbuch:** Ist-Zustand, nennt `gate-declared-twice`, Bedingung und Schalter beim
  Nachtragen; der widerlegte Satz „prüft niemand" ist entfernt.
- **Hard Rules:** Commit-Zuschnitt je Rolle (§3.8), kein Move+Rewrite in einem Commit (§3.3),
  keine Chronik in neuen Kommentaren (§3.7).
- **Gate-Lauf:** `make gates` einmal am Ende über dem Stand mit diesem Report — Ergebnis in der
  Commit-Message des Reports.
