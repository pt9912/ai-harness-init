# Review `slice-stilllegungs-form-hat-einen-waechter`, Runde 1 — 1 HIGH · 1 MEDIUM · 3 LOW · 5 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `8366b374` (Implementer, 7 Dateien,
+275/−96, schon auf `origin/main`) und `510b7ac7` (Architect, nur `AGENTS.md`, noch nicht gepusht)
· **Review-Art:** Code-Review gegen Plan, ADRs, Konventionen und Hard Rules (`v6.9.0` ·
`regelwerk/modul-10-review-harness.md`) · **Nicht Gegenstand:** die DoD-Abhakung. Sie gehört der
Verifikation (`v6.9.0` · `regelwerk/modul-11-verification.md`).

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` (`1b643a87`) · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:**
- Slice-Plan `slice-stilllegungs-form-hat-einen-waechter`: §1, §2, §3, §4, §6, §8.
- `ADR-0056`, `ADR-0015`, `LH-QA-01`.
- `MR-001`, `MR-010`, `MR-025`, `MR-033`, `MR-053`, `MR-054`, `MR-055`, `MR-062`.
- `AGENTS.md` §3.3, §3.5, §3.6, §3.7, §3.8, §3.10, §3.11.
- Baseline, jeweils `v6.9.0`:
  - `regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine und §Ein Slice, dessen
    Gegenstand ein anderer übernimmt.
  - `regelwerk/modul-06-roadmap.md` §Wann Arbeit eine Welle braucht und §Wellen-Closure-Prozedur.
  - `regelwerk/modul-11-verification.md` §Fitness Function ohne Standard-Tool.
  - `templates/docs/plan/planning/slice.template.md` §2 und §7.
  - `templates/harness/sensors/gate.template.md`, für die Pflichtgliederung.
- Werkzeug: d-check `v0.76.1`, Digest aus `d-check.mk`, Quelle gelesen im lokalen Klon des
  Werkzeug-Repos (nur lesend).
- Früherer Report desselben Tages zu `slice-stilllegungs-kanten-sind-gemessen`, gesichtet über
  Kopf und Summary.

---

## Eigene Messung

Die Angaben aus Commit und Sensor-Datei habe ich nicht übernommen. Jede Sonde lief in einer
eigenen Kopie (`git archive HEAD | tar -x -C <kopie>`), netzlos, mit dem gepinnten Digest und den
Flags aus dem Rezept `doc-structure` in `d-check.mk`.

| Messung | Ergebnis |
|---|---|
| Zahlen-Kommandos in `harness/sensors/docs-check.md` §Modul `structure` | 177 · 31 · alle 139 offenen Items unter `## 2. Definition of Done` · 30 · 65 · 9 · 0 · 0, jede Zahl wie angegeben |
| `comm -3` zwischen `exempt-paths` und den Plänen in `done/` mit offenen Items | einziger Unterschied: `slice-135` |
| Lauf A: Kopie ohne `exempt-paths`, `structure` allein | `1601 Datei(en) geprüft, 30 Befund(e)`. Die 30 Dateien sind genau die 30 der Liste (`comm -3` leer) |
| Lauf B: Kopie mit Liste. In `slice-e2e-abdeckung-ist-deklariert-und-erzeugt` ist nur die letzte DoD-Zeile *„Die drei Paarungen … getragen"* wieder offen | Exit 1, `1601 Datei(en) geprüft, 1 Befund(e)`, `section-open-tasks-marker-missing` auf der §2-Überschrift, vierte Spalte = `hint` |
| Sonde aus `harness/sensors/doc-structure.md` §Grenze, wörtlich | ohne Block `1601 … 0 Befund(e)`, mit Sonden-Block `1601 … 100 Befund(e)`, darunter die `section-missing`-Zeile zu `slice-201` |
| `diff <(… --print-mk) d-check.mk \| grep -c '^[0-9]'` | 6 (`1,13c1,74` · `15c76` · `26,27c87,88` · `59c120` · `60a122` · `75,76c137,138`), am Vorgänger-Stand 8, dazu `67c127` · `68a129` |
| `--print-mk`, Zeile des Gate-Ziels | `doc-check: ## Doku-Referenzen prüfen (Befund-Gate)` |
| Architect-Kommandos (`git -C "$D" grep -l 'driven\.VCS' v0.76.1 …` usw.) | `commits.go`, `run.go`, `vcs.go` · 0 · 0, wie angegeben |
| `grep -lE '^\s*- \[ \] Die drei Paarungen' docs/plan/planning/done/slice-*.md \| wc -l`, dasselbe mit `\[[xX]\]` | 7 offen, 69 abgehakt; alle 7 offenen stehen in `exempt-paths` |

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH (MEDIUM *Spec-Treue-Lücke einer Messmethode*, eine Stufe höher, weil die Stelle im Gate-Pfad liegt) | Die Regel meldet einen regulär gelieferten Slice rot, sobald er nur die letzte DoD-Zeile der Vorlage offen lässt. Diese Zeile lautet: *„Die drei Paarungen … sind getragen — … im Repo **mit** Wellen von der nächsten Welle-Closure"*. Das Repo hat Wellen-Betrieb. Offen gelassen haben die Zeile 7 von 76 Plänen, darunter die fünf jüngsten benannten, abgehakt 69. Kommentar und Sensor-Datei stützen sich allein auf *„DoD-Häkchen sind Bedingung für `done/`"* und verschweigen diese Zeile. Die Sensor-Datei nennt die Folge (Lage V8), aber keine Quelle legt fest, dass die Zeile hier schon bei der Slice-Closure abzuhaken ist. Das Gate entscheidet damit eine Auslegungsfrage der Baseline still. Folge: Ein Planner, der der Vorlage folgt, färbt `make gates` für jede Sitzung rot (Lauf B). | `v6.9.0` · `templates/docs/plan/planning/slice.template.md` §2, letzte Zeile · `v6.9.0` · `regelwerk/modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, Tabellen-Zeile *Alle drei Paarungen*, und §Wellen-Closure-Prozedur, Schritt 3 · Gegenlesart `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine · Maßstab `v6.9.0` · `regelwerk/modul-11-verification.md` §Fitness Function ohne Standard-Tool (*„dieselbe Schwelle, wie die ADR sie setzt"*) | `.d-check.yml:74-76`, `:96`; `harness/sensors/docs-check.md:236-239`, `:313` | ja — `make docs-check` in einer Kopie, in der ein Plan in `done/` nur die Paarungen-Zeile offen hat (Lauf B) | Gate entscheidet eine Auslegung, die keine Quelle getroffen hat |
| F-2 | MEDIUM (LOW *Doku-Drift*, eine Stufe höher im Gate-Pfad; dasselbe Muster führt die Roadmap-Zeile *Doku- und Sensor-Wartung*, Punkt 6, ausdrücklich für die nächste Änderung an `modules:`) | Der Slice ändert `modules:`, aber zwei lebende Stellen zählen die aktiven Module weiter mit *„nur … `targets`"* auf. Ohne `structure` ist die Vollständigkeits-Aussage falsch. Die Kernaussage *„keines liest Historie"* stimmt weiter. `harness/sensors/docs-check.md:7-8` führt die neue Liste samt „neun" ohne das Kommando, das sie liefert. Der Architect-Commit hat genau diese Form in `AGENTS.md` durch das Kommando ersetzt. | `MR-025`; `AGENTS.md` §3.7 (für den CI-Kommentar gilt der Cutoff nicht, weil die Zeile unverändert blieb) | `.github/workflows/ci.yml:25-27`; `harness/sensors/history-range-guard.md:54-55`; `harness/sensors/docs-check.md:7-8` | nein — kein Modul hält eine Prosa-Aufzählung gegen `modules:` | Korrektur trifft den Fundort statt die gemessene Fundmenge |
| F-3 | LOW | Die geänderte Kommentar-Zeile 6 streicht `doc-structure` aus der Menge ohne Block. Zeile 5 sagt weiter, der Fall setze ein **drittes** solches Ziel ein. Die Menge ist jetzt `doc-tracked` allein (Architect-Messung in `510b7ac7`), das eingesetzte Ziel ist also das zweite. Der Dateiname trägt dasselbe Wort. Die Zeile trägt eine Kommentar-Klasse, der Satz ist ganz; darum nicht HIGH. | `AGENTS.md` §3.7 (*„beschreibt, was da ist"*) | `test/mutations/309-drittes-c-ziel-ohne-marke.sh:5` | nein | Teilersetzung lässt eine überholte Zählung stehen |
| F-4 | LOW | Der Absatz *„Die Ausgabe-Hälfte gilt nur für einen Lauf ohne Befund"* steht in der Sensor-Datei von `doc-structure` und sagt jetzt *„Das Rezept reicht `docker run` vor dem `@echo` durch"*. Das Rezept von `doc-structure` hat seit diesem Diff kein `@echo` mehr. Gemeint ist das Rezept von `doc-tracked`; vorher stand dort *„Beide Rezepte"*. | Maintainability | `harness/sensors/doc-structure.md:63-64` | nein | Teilersetzung lässt Bezug auf entfernten Gegenstand stehen |
| F-5 | LOW | Kriterium 3 aus `MR-054` steht mit *„von Hand gesehen, ohne Zahn"* da, ohne Urteil *erfüllt* oder *nicht erfüllt*. `MR-055` Setzung 3 wertet dieselbe Lage (kein Zahn in `harness/tools/full-smoke.sh`, `grep -c` → 0) als **nicht erfüllt**, und `MR-054` §Wächter nennt `make full-smoke` als Träger von Kriterium 2 und 3. Die Entscheidung trägt das nicht, sie hängt an Kriterium 2. | `MR-054` Setzung 1 und §Wächter; `MR-055` Setzung 3 | `harness/sensors/docs-check.md:333-338` | nein | Kriterium ohne Urteil neben seiner Messung |
| F-6 | INFO | Der Kommentar begründet die namentliche Liste im Konjunktiv über die verworfene Alternative (*„ein Muster … naehme auch … aus"*). Das ist die Form des ersten Falsch-Beispiels in §3.7. Die Sache stimmt: 65 nummerierte Slices liegen in `open/` und `next/`, und `slice-135` ist selbst nummeriert. Der Inhalt ist eine Abgrenzung an den, der die Liste ändert. | `AGENTS.md` §3.7 | `.d-check.yml:85-86` | nein | Kommentar im Konjunktiv über die verworfene Alternative |
| F-7 | INFO | Der `hint` verlangt für den stillgelegten Fall *„mit Kennung oder Grund"*. Das prüft die Regel nicht: Der unausgefüllte Platzhalter der Vorlage gilt als Marke (Lage V3). Die Grenze steht an zwei Stellen, der `hint` behauptet keine Prüfung. *„geliefert: abhaken"* verweist bei der Paarungen-Zeile auf F-1. | Maintainability | `.d-check.yml:96`, Grenze `:77-79` und `harness/sensors/docs-check.md` §Modul `structure`, *Grenzen* | ja — Lage V3 | Hinweistext nennt eine Anforderung, die die Regel nicht prüft |
| F-8 | INFO | Der Hilfetext des Gate-Ziels nennt *„links/anchors/ids/codepaths laut .d-check.yml"*, vier von neun Modulen. Der Text stammt von uns, nicht vom Werkzeug: `--print-mk` liefert nur `(Befund-Gate)`, erweitert hat ihn Handgriff 3 aus dem Kopf des Fragments. Der Diff berührt die Zeile nicht, und die Roadmap-Zeile *Doku- und Sensor-Wartung*, Punkt 6, führt sie schon. Zuständig ist der Planner. | `MR-010`, `MR-062` (Handgriff 3) | `d-check.mk:88` | nein | Korrektur trifft den Fundort statt die gemessene Fundmenge |
| F-9 | INFO | d-check `v0.76.1` prüft an `exempt-paths` nur die Glob-Syntax (`configyaml.go:503-505`). Ein Eintrag, der keine Datei mehr trifft, bleibt still. Fünf der 30 Einträge sind wellenlose Slices, die seit der letzten Welle-Closure geschlossen wurden. Archiviert die nächste Welle-Closure sie, zeigen ihre Einträge ins Leere, und *„EXTENSIONAL GESCHLOSSEN"* beschreibt dann eine Liste mit toten Einträgen. Der Prüfbereich selbst ändert sich dadurch nicht, weil Stubs außerhalb des flachen Globs liegen. | Maintainability | `.d-check.yml:83-89` | nein | Ausnahmeliste nur auf Form geprüft |
| F-10 | INFO | Das Beleg-Kommando in §3.8 findet Dateien, die den Typ `driven.VCS` nennen. Die Aussage spricht über Module, die die Historie lesen. `tracked` bezieht Daten über den VCS-Port (`tracked.go:23`, `cli.go:709`) und fällt aus dem `grep`. Die Aussage bleibt wahr: `tracked` liest den Index, keine Historie, und ist nicht aktiv. | `AGENTS.md` §3.6 (die Zusage misst die Eigenschaft) | `AGENTS.md` §3.8, Absatz *Ein Wächter existiert nicht* | nein | Beleg-Kommando misst eine engere Menge als die Aussage |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Punkt 1: `exempt-paths` als Senkung? | geprüft, ohne Befund. Vor dem Diff war `structure` nicht aktiv. Die Liste grenzt also einen neuen, strengeren Prüfbereich ab und senkt keinen bestehenden (`MR-001`: Anheben → Steering-Loop). `AGENTS.md` §3.5 nennt Senkungen, und jeder weitere Eintrag ist in `.d-check.yml:89` als Senkung deklariert. `AGENTS.md` §3.11 *„Was sie nicht erweitert"* bindet nur die `ignore-refs`-Paare. Die Liste ist genau die Befundmenge ohne sie (Lauf A). Auch die Glob-Begründung stimmt (65; `slice-135` ist nummeriert und läge ebenfalls unter einem Muster). Rest: F-6, F-9 |
| Punkt 2: Nebenwirkung auf reguläre Closures | Befund F-1 |
| Punkt 3: `hint` | geprüft: Für beide Fälle erscheint der Text auf der §2-Überschrift, und die Marken-Form `**Gegenstand:**` ist genannt. Rest: F-7, F-1 |
| Punkt 4: Pflichtgliederung der Sensor-Dateien | geprüft, ohne Befund. `docs-check.md` und `doc-structure.md` führen auf `##`-Ebene genau die fünf Abschnitte von `v6.9.0` · `templates/harness/sensors/gate.template.md`. `### Modul structure` steht unter *Grenze* |
| Punkt 4: `AGENTS.md` §3.7 in `.d-check.yml` und `d-check.mk` | geprüft: keine Befund-Kennung, keine Chronik, kein Lauf-Protokoll, Werkzeug-Stand als `ab v0.76.0`. Rest: F-3, F-6 |
| Punkt 4: `MR-053`, `MR-033` | geprüft, ohne Befund. Die Messungen nennen `v0.76.1` samt Digest (`docs-check.md` §Modul `structure`) bzw. `v0.76.1` (`doc-structure.md` §Grenze), Baseline-Stellen nennen `v6.9.0` |
| Punkt 4: `MR-025`, Stichprobe | geprüft: alle neun Kommandos im Block §Modul `structure` und beide Sonden in `doc-structure.md` nachgefahren, alle Zahlen reproduziert, jede mit *kein Erwartungswert*. Rest: F-2 (`docs-check.md:7-8`) |
| Punkt 5: `doc-structure.md` | geprüft. Jede alte Zusage ist ersetzt oder mit Grund entfallen: die Inertheit ohne Block (bleibt, neu gemessen), die Marke (wandert zu *„Das Ziel trägt keine Block-Marke"* und *„Die Marke behauptet kein Prüfergebnis"*), *„Block-Marke folgt nur auf Exit 0"* (entfällt, das Ziel hat keine Marke mehr; an ihrer Stelle steht der `hint`-Satz) und der Bindungs-Satz zu `slice-213`. Die neue Zusage *„Mit Block … 0 Befund(e)"* passt zu V0. Rest: F-4 |
| Punkt 6: `MR-054`-Entscheidung | geprüft, ohne Befund in der Sache. Ein Gegenbeispiel genügt, um Kriterium 2 als allgemeine Eigenschaft zu verneinen, und `MR-055` Setzung 2 ist eingehalten. Das Rot kommt aus der emittierten Konfiguration, nicht aus Adopter-Inhalt, und das ist die Frage aus `MR-054` Setzung 2: d-check `v0.76.1` meldet jede Regel ohne Kandidaten als `section-missing` (`structure.go:70-79`). Rest: F-5 |
| Punkt 7: `d-check.mk` | geprüft, ohne Befund. 6 Hunks gegen `--print-mk`. Geändert sind der Adopter-Kopf (Handgriff 1) und der Wegfall der Marke an `doc-structure` (Handgriff 5; die Menge ist abgeleitet, `MR-062`). Beides ist von `MR-010` und `MR-062` gedeckt. Die Hilfetext-Frage beantwortet F-8 |
| Punkt 8: Architect-Commit `510b7ac7`, Wahrheit | geprüft, ohne Befund. `runPostPasses` (`run.go:144`) ruft den VCS-Port nur für `vcs` und `commits` auf. `immutable` prüft eine Marke je Datei (`run.go:308`), `tracked` liest den Index. Das Gate-Rezept schaltet kein Modul zu (`sed -n '/^docs-check:/,+1p' d-check.mk`). Die Kommandos sind reproduziert. §3.10 stützt sich ausdrücklich auf §3.8. Rest: F-10 |
| Punkt 8: Commit-Zuschnitt nach `AGENTS.md` §3.8 | geprüft, ohne Befund. Der Commit berührt nur `AGENTS.md` und nennt die Rolle in der Message. Die Implementer-Commit-Message nennt keine Architect-Artefakte, und der Diff berührt keine |
| Punkt 9: Lage V9 | geprüft, ohne Befund. *„Für V9 schlägt kein Wächter an."* steht in `docs-check.md:321` |
| `AGENTS.md` §3.3 und §3.11 | geprüft, ohne Befund. Kein Move im Diff. Der Report zitiert Slices bei ihrer Kennung |
| `ADR-0056` | geprüft, ohne Befund. Die Aktivierung übernimmt eine Baseline-Prüfung und setzt keine Abweichung. Zur Auslegung der Paarungen-Zeile: F-1 |
| emittierte Vorlage `internal/emit/templates/d-check.yml` | geprüft, ohne Befund. Die Vorlage ist unverändert (`grep -c structure` → 0) und passt damit zur Entscheidung |

## Summary

1 HIGH · 1 MEDIUM · 3 LOW · 5 INFO

**Finding-Klassen dieses Laufs:**
- Gate entscheidet eine Auslegung, die keine Quelle getroffen hat
- Korrektur trifft den Fundort statt die gemessene Fundmenge
- Teilersetzung lässt eine überholte Zählung stehen
- Teilersetzung lässt Bezug auf entfernten Gegenstand stehen
- Kriterium ohne Urteil neben seiner Messung
- Kommentar im Konjunktiv über die verworfene Alternative
- Hinweistext nennt eine Anforderung, die die Regel nicht prüft
- Ausnahmeliste nur auf Form geprüft
- Beleg-Kommando misst eine engere Menge als die Aussage

Zwei Klassen liegen im Beobachtungs-Register schon als Einträge vor:
`BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` und
`BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`. Ob die Closure sie zitiert, entscheidet sie.

## Verdikt

**Merge-blockierend: ja, für den Implementer-Stand `8366b374`, der schon auf `origin/main` liegt.**
- **F-1** bindet ein Gate an eine Lesart der Baseline, die keine Quelle festlegt. Ob die letzte
  DoD-Zeile im Repo mit Wellen bei der Slice-Closure abgehakt wird, entscheidet nicht der
  Implementer. Die Auslegung der Baseline gehört dem Architect, die Closure-Seite dem Planner
  (`AGENTS.md` §3.10). Das Übergabe-Artefakt ist dieser Befund.
- **F-2** gehört an den Implementer.
- **F-3 bis F-5** sind nachrangig.
- **F-6 bis F-10** sind Hinweise; F-8 geht an den Planner.

**Architect-Commit `510b7ac7`:** Aus Review-Sicht steht dem Push nichts entgegen, es gibt nur
F-10 (INFO). Der Commit hängt an `8366b374` und nimmt dessen Stand nicht erneut mit.

**Übergabe:** Findings an den Implementer, F-1 zusätzlich an Architect und Planner. Die
Finding-Klassen gehen in die Closure §7. Die DoD-Konformität prüft die Verifikation getrennt.
