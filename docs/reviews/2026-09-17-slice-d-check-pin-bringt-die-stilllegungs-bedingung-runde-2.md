# Review-Report: slice-d-check-pin-bringt-die-stilllegungs-bedingung, Runde 2 — 2026-09-17

**Review-Art:** Code. Geprüft ist die Nacharbeit gegen die Findings F-1 bis F-4 und F-6 der
ersten Runde (Report `2026-09-17-slice-d-check-pin-bringt-die-stilllegungs-bedingung.md`, Commit
`16295489`). Dazu kommt `MR-063` als neues Norm-Artefakt, auf Konsistenz geprüft. Neue Befunde
stehen nur dort, wo die Nacharbeit sie erzeugt hat.

**Gegenstand:** `git diff 9f6484a9..ba727601` ohne den Report-Commit `16295489`, lokal und nicht
gepusht:

| Commit | Rolle | Dateien (`git log --stat`) |
|---|---|---|
| `5b4356e6` | Implementer | `.d-check.yml`, `d-check.mk`, Slice-Plan §3 |
| `8ec29665` | Architect | `harness/conventions.md`, Einträge `MR-052` und `MR-061` (je Kopf-Marke), `MR-063` (neu) |
| `ba727601` | Implementer | `d-check.mk` |

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0
**Modell:** `claude-opus-5[1m]` · **Datum:** 2026-09-17

> **Zitier-Form.** Dieser Report friert ein. Slice und Adaptions-Einträge stehen darum bei ihrer
> Kennung, eine Baseline-Stelle als Tag + Pfad in Inline-Code. Die `Pfad`-Spalte hält den Stand
> `ba727601`.

**Eingangs-Kontext:**

- die Findings der ersten Runde
- Slice-Plan `slice-d-check-pin-bringt-die-stilllegungs-bedingung` (Stand `ba727601`)
- `MR-010`, `MR-027`, `MR-032` (Setzung 1, 3, 4), `MR-039`, `MR-046`, `MR-052`, `MR-055`, `MR-060`,
  `MR-061`, `MR-062`, `MR-063`
- `AGENTS.md` §3.5, §3.7, §3.8
- Fremdquelle, nur lesend: der lokale Klon des d-check-Repos, Tag `v0.76.0`

---

## Status der Findings aus Runde 1

| ID | Kategorie (R1) | Status | Beleg |
|---|---|---|---|
| F-1 | HIGH | **behoben** | Die drei Stellen (`d-check.mk:38-39`, `d-check.mk:47-48`, `.d-check.yml:372-373`) sagen jetzt die Eigenschaft im Indikativ und verweisen mit *„(Messung und Stand: MR-…)"*; das ist ein Rang-Zeiger. In den `+`-Zeilen steht kein *„gemessen"* und kein *„nachgemessen"* mehr. Jeder Verweis löst auf: `MR-027` trägt die Sonden-Tabelle (*„blanke Prosa … **meldet**"*), `MR-061` den `--range`-Abbruch unter beiden Digests, `MR-063` die Spaltenzahl. Der neue Beleg `git grep -nF '$NF' -- ':!d-check.mk' ':!*.md' ':!.harness'` liefert keinen Treffer (Exit 1). |
| F-2 | MEDIUM | **behoben** | `MR-063` gibt jedem der acht Module eine Basis (Tabelle Modul → Sonde → Grund-Code). Die Symlinks bleiben stehen, mit Kontrolle `find -type l`/`-type f`. Beide Digests laufen je mit dem Fragment ihres Standes, gefiltert wird mit `NF>=3`. Die Grenzen sind benannt (Codes ohne Basis, stumme Welle-Sonde, Messung nicht verkörpert), der permanente Auflösungs-Trigger ist neu gefasst. Die eigene Messung unten bestätigt das an drei Modulen ohne Basis in Runde 1. |
| F-3 | LOW | **behoben** | `MR-063` nennt die fünf Anker, die Kopf-Marke an `MR-061` die Stelle *„vier Anker"*. |
| F-4 | LOW | **behoben** | Plan §3 führt `Makefile` mit beiden Rezepten. Die Erweiterung durch den Implementer sieht `v6.9.0` · `regelwerk/modul-09-implementierung.md` vor (*„Der Plan lebt in §3 des Slice-Plans"*). |
| F-5 | INFO | nicht Gegenstand dieser Runde | Der Kommentar an `regelwerk-check` ist unverändert. |
| F-6 | INFO | **behoben** | `MR-063` §Löst auf nennt *„ihre Zahl setzt MR-010 Setzung 1"*; §Die Zahl der Handgriffe setzt MR-010 und MR-062 zusammen; die Kopf-Marke an `MR-061` führt die Stelle. |

## Findings (durch die Nacharbeit entstanden)

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N-1 | LOW | §Baseline sagt jetzt, `MR-063` führe die Gegenmessung von `MR-061` *„vollständig"*. `MR-063` §Grenze sagt dagegen, dass nicht jeder Code abgedeckt ist (`symlink`, `link-stale`, `matrix-downward`, übrige `closure-note-*`, `wave-*`) und die Welle-Sonde stumm bleibt. Wer nur §Baseline liest, nimmt eine Abdeckung an, die der Eintrag ausdrücklich nicht zusagt. | `MR-055` · `MR-063` §Grenze | `harness/conventions.md:22` | nein | Stellen-Messung als Eigenschaft ausgegeben |

## `MR-063` als Norm-Artefakt

| Prüfpunkt | Ergebnis |
|---|---|
| `MR-032` Setzung 1 (Form der Kopf-Marke, sonst nichts am Eintrag) | eingehalten. `git diff 16295489..ba727601` an `MR-052` und `MR-061` zeigt je genau zwei `+`-Zeilen (Marke und Leerzeile) direkt unter der Überschrift, keine `-`-Zeile, keinen Rumpf-Eingriff. Beide Marken haben die Form `ÜBERHOLT: <Reichweite> → <Ziel>. <Fortgeltung>`. |
| Zitierte Reichweiten existieren wörtlich | ja. `MR-052:114` *„Die Befund-Zeile trägt ab diesem Pin eine vierte, tab-getrennte Spalte"*. In `MR-061` stehen *„auf einer Basis, die einen Wegfall gezeigt hätte"* (umbrochen), *„an einer Gegenmessung auf **Nicht-Null-Basis**"*, *„vier Anker"* und *„ihre Zahl setzt"*. |
| `MR-032` Setzung 3 | eingehalten: Beide Marken stehen im Commit von `MR-063` (`8ec29665`). |
| `MR-032` Setzung 4 (Pin-Ketten-Ausnahme) | richtig angewandt. `MR-063` ist kein Pin-Eintrag und löst namentlich ab, die Marke ist also fällig. Die Ablösung an `MR-052` ist auch sachlich richtig: `spans` trug schon unter `v0.74.1` drei Spalten (eigene Messung unten). Die Aussage war damit auch als Momentaufnahme zu weit. |
| `MR-046` | eingehalten: `MR-052` und `MR-061` bleiben unter `conventions/`, kein `git mv`. |
| `MR-060` / Pflichtfelder | eingehalten. `MR-063` führt Datum, Wirksamkeits-Anlass, Geltungsbereich, Löst auf, Ausgelöst durch Baseline-Stand, Ersetzt-Baseline-Regel (Verdikt nach `MR-039` Setzung 3), Adaption, Grenze, Begründung und Auflösungs-Trigger. Die Form *„Adaption — Setzung 1 …"* ist im Bestand üblich (fünf Dateien). Kein bestehender Eintrag erhält ein Pflichtfeld nachgetragen. |
| Append-only | eingehalten. `MR-061` wurde nicht umgeschrieben; `MR-063` ist ein neuer Eintrag, weil `MR-061` gepusht war. |
| Index und §Baseline | Die Index-Zeile trägt Kurz- und Slug-Anker, der Slug passt zum Titel. §Baseline siehe N-1. |
| Ersetzt-Baseline-Regel | trägt: `grep -c 'Break-Test mit beiden Sensoren' .harness/baseline/v6.9.0/regelwerk/modul-11-verification.md` → 1; *„tritt an keine Stelle"* ist konsistent mit dem Fork-Verdikt. |
| Zahlen der Messung | stimmig. Stufe 3: Die Summe der Code-Verteilung ergibt 74 = 57 + 17 Sonden. `git show 0fbefa46^:d-check.mk` führt `docs-check:` in Zeile 78 (Rezept 79), `git show 16295489:d-check.mk` in Zeile 86 (Rezept 87); das passt zu den genannten make-Fehlerzeilen. `git ls-tree 16295489 .claude/rules/` → 10 × `120000`. |
| Spaltenregel an der Quelle | trägt für alle aktiven Module. `report/report.go` hängt die vierte Spalte nur an, wenn `Message` nicht leer ist. `rules/spans.go` setzt kein `Message` (3 Literale, 0 Felder). Jedes Finding-Literal in `links`, `anchors`, `ids`, `codepaths`, `targets` und in `matrix` (auch `matrix-downward`) setzt es; `planning.go` und `planning_waves.go` bauen über `closureFinding`/`waveFinding` mit `msg`. Der neue Kopf *„außer denen von `spans`"* ist damit auch für die ungemessenen Codes gedeckt. |
| Reproduzierbarkeit | Die Sonden liegen nicht als Datei vor; §Grenze sagt *„Die Messung ist nicht verkörpert"*. Tragend ist die Gleichheit je Code, nicht die Zahl 74, und die Gleichheit ließ sich mit eigenen Sonden reproduzieren. Kein Befund. |

## Eigene Messung

Zwei Kopien `git archive 16295489` außerhalb des Repos, die Kopie für den alten Stand mit
`d-check.mk` aus `0fbefa46^`. Die Marker sind nur in regulären Dateien entwertet (Kommando aus
`MR-063` Setzung 2). Kontrolle je Kopie: `links=10 files=0`, kein restlicher Marker außerhalb der
Baseline. Gefahren mit `make -s -C <kopie> docs-check DCHECK_DIGEST=<digest>`, netzlos.

| Stufe | `v0.74.1` (Fragment `0fbefa46^`) | `v0.76.0` (Fragment `16295489`) | `diff` der Zeilen (`NF>=3`) |
|---|---|---|---|
| Marker entwertet, Symlinks stehen | 57: 20 `codepath-missing`, 37 `id-unlinked`; make-Fehler `d-check.mk:79` | dieselben 57; make-Fehler `d-check.mk:87` | leer |
| dazu eigene Sonden | 61 Befunde | 61 Befunde | leer |

Stufe 2 bestätigt `MR-063`: 57 Befunde und `target-missing` bei 0, ohne die Symlink-Artefakte.
Die eigenen Sonden treffen drei Module, die in Runde 1 **keine** Basis hatten:

- **`anchors`:** Link auf `AGENTS.md` mit fehlendem Anker → `anchor-missing`.
- **`spans`:** Span, der am Text klebt → `span-unclosed`; offene Fence am Dateiende →
  `fence-unclosed`. Die Sonde für einen verschachtelten Link löste nichts aus. Das liegt an meiner
  Sonde; `MR-063` belegt `span-nested-link` mit einer eigenen.
- **`targets`:** zusätzliche `make`-Zeile ohne Rezept in der Sensors-Tabelle der
  `harness/README.md` der Kopie → `gate-phantom`.

Stufe 3 verteilt sich unter beiden Digests gleich: `anchor-missing` 1, `codepath-missing` 20,
`fence-unclosed` 1, `gate-phantom` 1, `id-unlinked` 37, `span-unclosed` 1.
`awk -F'\t' '{print NF": "$3}' | sort -u` ergibt unter **beiden** Digests 3 Spalten für
`fence-unclosed` und `span-unclosed` und 4 für die übrigen vier Codes. Das bestätigt die neue
Aussage im Kopf von `d-check.mk` und die Ablösung an `MR-052`.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Commit-Zuschnitt (`AGENTS.md` §3.8) | geprüft, ohne Befund. `8ec29665` berührt nur `harness/conventions.md` und `harness/conventions/*` und nennt die Rolle. Die Implementer-Commits berühren keinen Konventionsspeicher. Jede Message trägt eine Kennung. |
| Kopf von `d-check.mk` nach `ba727601` | geprüft, ohne Befund. Die Grund-Code-Anleitung (`$3` statt `$NF`) stimmt mit `report.go` überein; die `summary.notes`-Zeile verweist auf `MR-061`. Die Fragment-Hunks sind unberührt, denn die Nacharbeit ändert nur Kommentarzeilen. |
| Plan §3 | geprüft, ohne Befund (F-4). Die neue Zeile nennt `LH-QA-01` und den Inhalt beider Rezepte. |
| `AGENTS.md` §3.5 | geprüft, ohne Befund. Der Schluss „keine Senkung" ist jetzt je Modul gemessen, keine Gate-Konfiguration ist geändert. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Stellen-Messung als Eigenschaft ausgegeben

## Verdikt

**Merge-blockierend:** nein. **Bereit für Verifier und Closure.** F-1 bis F-4 und F-6 sind
behoben. N-1 ist LOW, betrifft §Baseline in `harness/conventions.md` und geht als
Übergabe-Artefakt an den Architect (`AGENTS.md` §3.8). F-5 (INFO) bleibt offen, ohne zu
blockieren.

Die Finding-Klasse geht in die Slice-Closure §7. Dieser Report ersetzt keine Verifikation;
DoD 1 (das Rot der zwei `TestDefault*`-Tests) und DoD 3 (die neu gefahrene Stilllegungs-Messung)
prüft der Verifier.
