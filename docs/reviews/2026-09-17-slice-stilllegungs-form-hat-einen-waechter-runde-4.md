# Review `slice-stilllegungs-form-hat-einen-waechter`, Runde 4 — 0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:**
- `35897912` (Architect: `AGENTS.md` §3.8 und §3.10, zu R3-1)
- `3ad79cc8` (Implementer: `doc-structure.md` und `docs-check.md`, zu R3-2)

Beide Commits sind lokal. **Gegenstand** ist allein dieser Diff.

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` (`1b643a87`) · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:**
- Review-Report Runde 3 (`71947e7d`), Befunde R3-1 und R3-2.
- `AGENTS.md` §3.3, §3.6, §3.7, §3.8, §3.10.
- `MR-025`, `MR-053`.
- d-check `v0.76.1`, Quelle im lokalen Klon des Werkzeugs, nur lesend.

---

## Eigene Messung

| Messung | Ergebnis |
|---|---|
| `grep -n 'show --numstat' harness/tools/full-smoke.sh` (Kommando aus §3.8) | `:1498` (Kommentar), `:1504` (`git show --numstat --format= HEAD~1`) |
| Suche 1 aus der Message `35897912`, wörtlich | Treffer in `full-smoke.sh:1498`, `:1504`, `:1517` und zwei Kommentare in `slice-mv.sh:36`, `:54`; wie in der Message beschrieben |
| Suche 2 der Message auf die Pfade, die sie auslässt (`harness/tools/` ohne `smoke.sh` und `full-smoke.sh`, `.githooks/`, `.claude/hooks/`, ohne Kommentarzeilen) | `history-range-guard.sh:155` und `slice-mv.sh:223`, beide `git diff --cached --quiet`. Beide lesen den Index bzw. den Arbeitsbaum, keine Commit-Dateien |
| Rollen-Namen (`Architect\|Planner\|Implementer\|Reviewer\|Verifier\|Validator\|Rolle`) in `full-smoke.sh`, Zeilen 1480–1560 (die Move-Prüfung) | keine Ausgabe |
| Sonde M1 in einer Kopie: beide `open-tasks-require-marker`-Schlüssel entfernt, Flags des Rezepts `doc-structure`, gepinnter Digest | `1606 Datei(en) geprüft, 5 Befund(e)`, alle `section-tasks-open`, vierte Spalte = `hint` |
| d-check `v0.76.1`, `internal/hexagon/core/rules/structure.go` | `structureFinding` (`:318-322`) setzt `r.MessageFor(msg)`. `structureRawFinding` (`:308-316`) lässt den Hinweis weg, *„den Befunden vorbehalten, die KEINE Bedingung verletzen"*. Genutzt wird es für *„Datei ist unlesbar (fail-closed)"* an einer Kandidaten-Datei (`:117-122`) und für den Leerlauf über `exempt-section-pattern` (`:165-174`). Der Leerlauf ohne Kandidaten (`:73-78`) und der unlesbare Dateibaum (`:24-35`) setzen den Text direkt |

## Stand R3-1 und R3-2

| ID | Stand | Beleg |
|---|---|---|
| R3-1 | **erledigt** | Der falsche Halbsatz ist in §3.8 und §3.10 entfallen. Die Move-Prüfung aus §3.3 steht mit einem Kommando, das sie findet. Die Stütze für *„gegen die Rolle"* trägt: Die einzige gefundene Stelle, die Commit-Dateien liest, nennt keine Rolle (eigene Messung). Auch in den Skripten, die Suche 2 auslässt, liest keine Stelle Commit-Dateien. Die Grenze der Suche steht in der Message |
| R3-2 | **erledigt**, mit Rest R4-1 | `docs-check.md` *Der Glob ist flach* nennt den Leerlauf mit dem Text des Werkzeugs. `doc-structure.md` schränkt die `hint`-Aussage ein; die drei genannten Grund-Codes sind gemessen (M1 nachgefahren, V1/V8 und V10 aus den früheren Runden) |

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R4-1 | LOW | Der neue Satz *„Trägt eine Regel einen `hint`, steht er in der vierten Spalte der Befunde, die eine Datei betreffen"* ist weiter gefasst als das Werkzeug. Nach d-check `v0.76.1` behält auch ein Befund an einer Datei den Text des Werkzeugs, wenn die Regel dort nicht gemessen hat: *„Datei ist unlesbar (fail-closed)"* an einer Kandidaten-Datei (`structure.go:117-122`). Die Trennlinie des Werkzeugs ist *Bedingung verletzt* gegen *nicht gemessen* (`structure.go:308-310`), nicht *Datei* gegen *Glob*. Der Folgesatz nennt die gemessenen Codes richtig. | `AGENTS.md` §3.6 (die Zusage misst die Eigenschaft) | `harness/sensors/doc-structure.md:84-85` | ja — Sonde mit einer unlesbaren Datei in `done/` | Stellen-Messung als Eigenschaft ausgegeben |
| R4-2 | INFO | Berichtigung zu Runde 3, R3-1: Meine Stütze *„leere Suche nach `Rolle …`"* stand auf dem engen Muster `Rolle (Architect\|…)`, also nur auf der Präfix-Form einer Commit-Message. Das breitere Muster des Architects trifft in `full-smoke.sh` andere Prüfungen (Rollen-Typen, Span-Bericht, Idempotenz). Die leere Ausgabe belegte darum nicht, was ich ihr zuschrieb. Tragend ist die Lesung der einen Commit-lesenden Stelle, wie der Architect sie jetzt angibt. | `AGENTS.md` §3.6 | Report Runde 3, *Eigene Messung* und R3-1 | nein | Trefferliste deckt die Aussage nicht, die sie belegen soll |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `AGENTS.md` §3.8, neue Aussagen | geprüft, ohne Befund. Die Fehlschlag-Muster (`failure_form()`) und die Move-Prüfung sind mit Kommando belegt. *„Keine dieser Stufen hält die Dateien eines Commits gegen die Rolle"* trägt, gestützt auf die eigene Messung |
| `AGENTS.md` §3.10 | geprüft, ohne Befund. Die Einschränkung ist dieselbe wie in §3.8, der Verweis steht, und `· seit welle-15` bleibt als Herkunftsfeld |
| Commit-Zuschnitt `35897912` (`AGENTS.md` §3.8) | geprüft, ohne Befund: nur `AGENTS.md`, Rolle in der Message |
| `docs-check.md` *Der Glob ist flach* | geprüft, ohne Befund: stimmt mit `structure.go:73-78` und der Nullmengen-Sonde aus Runde 3 überein |
| `AGENTS.md` §3.7 im Diff | geprüft, ohne Befund: Indikativ, keine Chronik, keine Befund-Kennung |
| `MR-025` im Diff | geprüft, ohne Befund: keine neue Zahl |
| `MR-053` im Diff | geprüft, ohne Befund: `doc-structure.md` nennt `v0.76.1`, und der neue Satz in `docs-check.md` steht unter dem Stand seines Abschnitts |
| `3ad79cc8`, Architect-Artefakte | geprüft, ohne Befund: keine berührt |

## Summary

0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO

**Finding-Klassen dieses Laufs:**
- Stellen-Messung als Eigenschaft ausgegeben (Eintrag `BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben`)
- Trefferliste deckt die Aussage nicht, die sie belegen soll

## Verdikt

**Merge-blockierend: nein.** Push ist aus Review-Sicht frei, die Closure ebenso. Sie gehört dem
Planner und hängt weiter an der offenen Paarungen-Zeile in der DoD dieses Slice (Lage V8).

R4-1 geht an den Implementer. Der Befund ist LOW und blockiert nicht.
