# Review `slice-stilllegungs-form-hat-einen-waechter`, Runde 3 — 0 HIGH · 0 MEDIUM · 2 LOW · 1 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:**
- `c4701568` (Architect: `AGENTS.md` §3.8 und ADR-Index)
- `4a583474` (Implementer: V-1, V-2, R2-3)

Beide Commits sind lokal. **Review-Art:** Code-Review gegen Verifikations- und Review-Befunde, Konventionen und
Hard Rules (`v6.9.0` · `regelwerk/modul-10-review-harness.md`).

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` (`1b643a87`) · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:**
- Review-Reports Runde 1 und 2 (`90263a93`, `86fd6508`).
- Verifikations-Report `2026-09-17-slice-stilllegungs-form-hat-einen-waechter-verify.md`, Befunde
  V-1 und V-2.
- `AGENTS.md` §3.3, §3.7, §3.8, §3.10.
- `MR-025`, `MR-051`, `MR-053`.

---

## Eigene Messung

Die Sonden laufen in einer Kopie (`git archive HEAD | tar -x -C <kopie>`), netzlos, mit dem
gepinnten Digest aus `d-check.mk` (d-check `v0.76.1`) und den Flags des Rezepts `doc-structure`.

| Messung | Ergebnis |
|---|---|
| `sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh` | Muster für `test`, `test-go`, `test-bats`, `smoke`, `full-smoke`, `ci-lint`; keines für `docs-check` |
| Zulassung eines Falls | `harness/tools/mutate.sh:643` (je Fall) und `:795` (je Modus) brechen ab, wenn `failure_form` kein Muster liefert |
| Das Kommando aus der Message `c4701568`, wörtlich (`git grep -nE 'name-only\|name-status\|diff-tree\|show --stat\|--stat' -- test/ internal/ harness/tools/smoke.sh harness/tools/full-smoke.sh ':!internal/emit/templates'`) | keine Ausgabe, Exit 1 |
| Dasselbe Muster, erweitert um `--numstat`, `--raw` und `diff --cached` | `harness/tools/full-smoke.sh:1504`: `git show --numstat --format= HEAD~1` |
| `git grep -nE 'Rolle (Architect\|Planner\|Implementer\|Reviewer\|Verifier)'` über `test/`, `harness/tools/`, `.claude/hooks/`, `.githooks/`, `internal/` (ohne Vorlagen) | keine Ausgabe |
| `sed -n '/^structure:/,/^[a-z]/p' .d-check.yml \| grep 'files:'` | `- files: "docs/plan/planning/done/slice-*.md"` |
| Lage V10: in der Kopie `## 2. Definition of Done` → `## 2. Definition of Done (Sonde)` in `slice-e2e-abdeckung-ist-deklariert-und-erzeugt` | `1605 Datei(en) geprüft, 1 Befund(e)`, `section-missing` auf Zeile 1, vierte Spalte = `hint` |
| Nullmenge: in der Kopie `files:` auf einen Glob ohne Treffer | `1605 Datei(en) geprüft, 1 Befund(e)`, `section-missing`, vierte Spalte = *„Regel trifft keine Datei (auch nach Abzug von exempt-paths) — das Gate liefe leer"*, **nicht** der `hint` |
| `grep -L '^## 2\. Definition of Done$' docs/plan/planning/done/slice-*.md \| wc -l` | 0 |
| V-2, Fundmenge: `git grep -nE 'zwei Fehlschlag\|not ok N'` über `harness/`, `test/`, `spec/`, `docs/user/`, `README.md`, `CLAUDE.md`, `.claude/` | keine Ausgabe. Die übrigen Treffer von *„zwei Fehlschlag-Formen"* stehen in ADRs (Stichprobe `0040`, `0045`, `0048`, `0049`, `0051`: `Accepted`) |
| R2-3, Fundmenge: `git grep -nE 'liest (die )?…Historie'` in lebenden Dateien | `ci.yml:27`, `AGENTS.md:373` und `:462`, `docs-check.md:8`, `history-range-guard.md:55`; dazu `release.yml:28` (spricht über Release-Jobs, nicht über Doku-Module) |

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R3-1 | LOW | Die Trefferliste in der Message deckt den neuen Satz nicht. Ihr Muster `--stat` trifft `--numstat` nicht, und so fehlt die eine Stufe, die die Dateien eines Commits liest: `full-smoke` (`full-smoke.sh:1504`). Diese Stufe färbt sich mit `full-smoke: FEHLER` rot, wenn der Move-Commit von `make slice-mv` im Ziel kein reiner Move ist (`AGENTS.md` §3.3). Der erste Halbsatz *„keines davon trifft einen Commit-Zuschnitt"* ist darum allgemein gelesen falsch, und §3.10 übernimmt ihn (*„kennt keine Fehlschlag-Form für einen Commit-Zuschnitt"*). Wahr bleibt die Aussage mit der Einschränkung aus dem `denn`-Satz: Keine Stufe hält die Dateien eines Commits gegen die Rolle, die ihn schreibt. Das belegt nicht der `grep` der Message, sondern die leere Suche nach `Rolle …` im Prüfcode. Die Aussage *„Ein Wächter existiert nicht"* für die §3.8-Regel steht. | `AGENTS.md` §3.6 (die Zusage misst die Eigenschaft); `MR-051` (die Message trägt den Beleg) | `AGENTS.md:380-383` und `:463`; Commit-Message `c4701568` | ja — das Muster um `--numstat` erweitern | Trefferliste deckt die Aussage nicht, die sie belegen soll |
| R3-2 | LOW | Zu V-1 fehlt eine Stelle. `doc-structure.md` sagt allgemein: *„Trägt eine Regel einen `hint`, steht er in der vierten Spalte statt des Modul-Textes."* Im Fall *„Regel trifft keine Datei"* behält die Meldung ihren eigenen Text, auch mit `hint` (Nullmengen-Sonde). Die neue Grenze in `docs-check.md` stimmt, weil sie nur den Befund je Datei beschreibt. | Maintainability | `harness/sensors/doc-structure.md:84-85` | ja — Nullmengen-Sonde | Korrektur trifft den Fundort statt die gemessene Fundmenge |
| R3-3 | INFO | Stand älterer Befunde: R2-1 betrifft die Message von `61a6fe61`, die gepusht und unveränderlich ist; die Lücke hält der Report aus Runde 2. R2-2 und die Punkte aus Verdikt §4 liegen beim Planner. Darunter ist die offene Paarungen-Zeile in der DoD dieses Slice: Bleibt sie beim Abschluss offen, färbt sie `make docs-check` rot (Lage V8). | — | — | nein | — |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Punkt 1: `AGENTS.md` §3.8, Zulassungs-Satz | geprüft, ohne Befund: `mutate.sh:643` und `:795` tragen ihn, und das genannte Kommando zeigt die Muster. Rest: R3-1 |
| Punkt 1: ADR-Index | geprüft, ohne Befund. Das Kommando liefert allein die `files:`-Zeile über `done/slice-*.md`, der Index liegt nicht darin. Die Modul-Aufzählung ist durch das Kommando ersetzt |
| Punkt 2: V-2 | erledigt: `docs-check.md` §Modul `structure`, *Grenzen*, übernimmt die Form aus §3.8. In keiner lebenden Datei steht noch *„zwei Fehlschlag-Formen"*. Die ADRs mit dieser Aussage sind `Accepted` und bleiben (`AGENTS.md` §3.4) |
| Punkt 2: V-1 | erledigt, bis auf R3-2: Zeile V10 und die neue Grenze stimmen mit der eigenen Sonde überein. Die Null steht neben ihrem Kommando |
| Punkt 2: R2-3 | erledigt: `ci.yml:27` datiert auf `v0.76.1`. Alle lebenden Stellen mit der Historien-Aussage über Doku-Module tragen den Stand |
| Punkt 3: `AGENTS.md` §3.7 | geprüft, ohne Befund. Der neue CI-Kommentar steht im Indikativ und verweist mit Rang-Zeiger und Stand auf §3.8. Keine Chronik, keine Befund-Kennung |
| Punkt 3: `MR-025` | geprüft, ohne Befund. §3.8 und `docs-check.md` zählen die Fehlschlag-Formen nicht mehr auf, sie nennen das Kommando. Die neue Null steht mit Kommando und dem Zusatz *kein Erwartungswert* |
| Punkt 3: `MR-053` | geprüft, ohne Befund. Die Lage V10 gilt für den Digest der Tabelle, der CI-Kommentar nennt `v0.76.1` |
| `AGENTS.md` §3.8, Commit-Zuschnitt `c4701568` | geprüft, ohne Befund. Der Commit berührt nur `AGENTS.md` und den ADR-Index (Architect, `ADR-0024`), und die Message nennt die Rolle. `4a583474` berührt keine Architect-Artefakte |

## Summary

0 HIGH · 0 MEDIUM · 2 LOW · 1 INFO

**Finding-Klassen dieses Laufs:**
- Trefferliste deckt die Aussage nicht, die sie belegen soll
- Korrektur trifft den Fundort statt die gemessene Fundmenge

Nahe Einträge im Beobachtungs-Register:
- `BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`
- `BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene`

## Verdikt

**Merge-blockierend: nein.** Push ist aus Review-Sicht frei, die Closure ebenso. Sie gehört dem
Planner und hängt an der Paarungen-Zeile dieses Slice (R3-3).

**Übergabe:**
- R3-1 an den Architect: `AGENTS.md` §3.8 und §3.10.
- R3-2 an den Implementer.

Beide sind LOW und nicht blockierend. Die Finding-Klassen gehen in die Closure §7.
