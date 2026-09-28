# Review-Report: slice-mutate-form-match-epipe-verwirft-treffer — 2026-09-28

**Review-Art:** Code — geprüft gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** `slice-mutate-form-match-epipe-verwirft-treffer` — Commits `91475e32` (slice-mv,
reiner Move) und `de4ecb13` (Implementierung).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.3.0 (2026-09-27)
**Modell:** claude-sonnet-5 · **Datum:** 2026-09-28

**Eingangs-Kontext:**

- `docs/plan/planning/in-progress/slice-mutate-form-match-epipe-verwirft-treffer.md` (§1–§8)
- `AGENTS.md` §3.2, §3.3, §3.5, §3.6, §3.7, §3.9
- `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ziel-Form: Slice, §Trigger je
  Lifecycle-Übergang
- `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Fitness Function aus einem ADR-Satz
  (Bewusstes-Brechen-Muster, hier auf einen Werkzeug-Defekt statt eine ADR angewandt)
- `LH-QA-01`
- `harness/sensors/mutate.md` (Vertrag von `make mutate`)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die DoD-Zusage nennt zwei Teilfälle in einem Satz („kein Treffer **oder** leeres `$out`"), der neue Test deckt nur den ersten (nicht leerer Log ohne Treffer); der zweite Teilfall (0-Byte-`$out`) hat keinen eigenen bindenden Fall. Manuell nachgestellt: `form_matched` verhält sich für ein 0-Byte-`$out` korrekt (Exit 1, „kein Treffer“) — kein Korrektheits-, sondern ein Abdeckungs-Fund. Die Lücke ist bereits als offenes Risiko in §6 des Slice-Plans benannt und zur Closure-Zuweisung vorgemerkt. | `AGENTS.md` §3.6 (Reviewer-Skill: „Mehrteilige Regel-Zusage im Kommentar ohne Mutations-Deckung je Teil") | `harness/tools/mutate.sh:608-612`, `test/mutate-driver.bats:64-73` | ja — ein neuer bats-Fall mit `: >"$out"` (0 Byte) vor dem Fix rot, danach grün | Zusage mit zwei Teilfällen, nur ein Fall gebunden |
| F-2 | INFO | Ein zweites, strukturell verwandtes Live-Pipe-Muster (`find … -print0 \| xargs -0 grep -lE … \| grep -q .`) besteht unverändert in `harness/tools/comment-claims.sh:105` — außerhalb des von diesem Slice-Plan bewusst ausgeschlossenen Audits (§1, Klasse 3: „ein anderer Vorgang"). Kein Fund gegen diesen Diff; Hinweis für einen künftigen Planner-Slice, falls das Muster real feuert. | Maintainability | `harness/tools/comment-claims.sh:105` | nein — kein Gate deckt Live-Pipe-Muster | (kein Steering-Loop-Eintrag — Bestand, nicht Diff) |
| F-3 | INFO | Zwischen dem `slice-mv`-Commit (`91475e32`, 04:20:59) und der Implementer-Korrektur (`de4ecb13`, 04:48:01) widersprach der Ruhe-Marker „Nichts in Arbeit.“ in `roadmap.md` rund 27 Minuten dem tatsächlichen Verzeichnis-Zustand (`in-progress/` trug bereits den Slice). Selbst korrigiert innerhalb desselben Arbeitsgangs, vor Review erreicht kein rotes `docs-check` den Hauptzweig-Endstand. | Maintainability | `docs/plan/planning/in-progress/roadmap.md` | ja — `make docs-check` (Modul `planning`) am Zwischenstand | Ruhe-Marker-Drift nach slice-mv, selbst korrigiert |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `harness/tools/mutate.sh` — Härtung der Bedingung-4-Auswertung (`form_matched`), Aufrufstelle in `run_case()` | geprüft, ohne Befund — Fix korrekt und vollständig; Semantik für Leer-/Kein-Treffer-Fall erhalten (siehe unten) |
| `harness/tools/mutate.sh` — restliche `grep …\|grep -q…`-Stellen im Skript | geprüft, ohne Befund — `grep -n '\| grep -q' harness/tools/mutate.sh` liefert 0 Treffer; die einzige verbliebene verwundbare Form war Zeile 808, jetzt gehärtet |
| `test/mutate-driver.bats` — die zwei neuen Zähne | geprüft, ohne Befund — beide unabhängig real nachvollzogen (siehe unten), Fall-Konstruktion erzwingt die Race deterministisch |
| `test/mutations/496-mutate-form-matched-live-pipe-verwirft-treffer.sh` — Ein-Mutationspunkt-Regel (MR-071) | geprüft, ohne Befund — der `sed`-Anker trifft exakt eine Zeile im Quell-Bestand (`grep -n 'grep -qF -- "\$expect" <<<"\$matched"' harness/tools/mutate.sh` → genau 1 Treffer), `# expect:` benennt den neu hinzugefügten Test wörtlich, real gefahren (`make mutate MUTATE_CASES=496-…` → `1 ok, 0 Befund(e)`) |
| `harness/sensors/mutate.md` — Nachzugs-Prüfung | geprüft, ohne Befund — die Datei trägt tatsächlich keinen Aussage-Satz zu „grep“/„Pipe“/„EPIPE“/„Bedingung 4“ (`grep -niE 'grep\|pipe\|epipe\|bedingung 4'` → 0 Treffer); die Begründung „kein Nachzug nötig“ ist zutreffend |
| `AGENTS.md` §3.2 (Lint-Suppression-Verbot) | geprüft, ohne Befund — kein `// nolint`, kein `# shellcheck disable` in den geänderten Dateien |
| `AGENTS.md` §3.3 (git mv + Inhaltsänderung getrennt) | geprüft, ohne Befund — `91475e32` ist ein reiner Rename (0 Insertions/Deletions, Similarity 100 %), sämtliche Inhaltsänderungen liegen in `de4ecb13` |
| `AGENTS.md` §3.7 (Kommentar-Klassen) | geprüft, ohne Befund — der neue Funktionskommentar über `form_matched()` und die zwei neuen bats-Testkommentare beschreiben den gegenwärtigen Mechanismus (Kopplung/Zusage-Klasse), keine verworfene Alternative, kein abwesender Text, kein Abbruch mitten im Satz |
| Struktur-Abweichung: `form_matched()` als eigene Funktion statt Inline-Härtung | geprüft, ohne Befund — der Plan erlaubt die exakte Form ausdrücklich als Implementer-Entscheidung („Exakte Form ist Implementer-Entscheidung, solange …“); DoD bleibt bei 3 Liefer-Punkten, keine Schicht-/Größen-Überschreitung nach Modul 5 |
| Gate-Stempel-Gegenprobe | geprüft, ohne Befund — `.harness/state/gates-passed.diffsha` und `bash harness/tools/working-tree-hash.sh` liefern denselben Hash (`2294c426…`); der zuvor aufgezeichnete `make gates`-Lauf deckt den aktuellen Arbeitsbaum |

### Unabhängige Nachvollziehung (Reviewer-eigene Reproduktion)

- **Alte Form** (`grep -E -- "$form" "$out" \| grep -qF -- "$expect"`) unter `set -euo pipefail`
  gegen ein Log mit 1 Treffer + 20 000 weiteren passenden Zeilen: **10/10 Läufe** endeten mit Exit
  **141** (SIGPIPE-Signatur, 128+13) — exakt der im Slice-Plan und in der Commit-Message behauptete
  Mechanismus, nicht nur ein zufälliges Fehlschlagen.
- **Neue Form** (`form_matched`) gegen dasselbe Log: **10/10 Läufe** Exit **0**.
- Semantik-Erhalt zusätzlich für den härteren Grenzfall geprüft (0-Byte-`$out`, über die
  bats-Deckung hinaus): Exit 1 — „kein Treffer“ bleibt korrekt (siehe F-1 zur fehlenden
  Testbindung dieses Teilfalls).
- `make mutate MUTATE_CASES=496-mutate-form-matched-live-pipe-verwirft-treffer` real gefahren:
  `mutate: ok 496-mutate-form-matched-live-pipe-verwirft-treffer -> driver: form_matched findet
  den Treffer, auch wenn das Log VIELE passende Zeilen traegt rot` / `mutate: 1 ok, 0 Befund(e)`
  — deckt sich mit der Commit-Message-Behauptung.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Zusage mit zwei Teilfällen, nur ein Fall gebunden ·
Ruhe-Marker-Drift nach slice-mv, selbst korrigiert

## Verdikt

**Merge-blockierend:** nein — kein HIGH, kein MEDIUM. F-1 (LOW) ist bereits als offenes Risiko im
Slice-Plan §6 benannt und kann bei Closure regulär zugewiesen werden (z. B. „weiter offen“ mit
Registereintrag, oder ein kleiner Nachtrags-Fall vor Closure); die Funktion selbst verhält sich für
den ungetesteten Teilfall bereits korrekt. F-2 und F-3 sind reine Beobachtungen ohne
Handlungszwang an diesem Slice.

**Übergabe:** Findings gehen an den Implementer/Planner zur Closure-Entscheidung; die
Finding-Klassen gehen in die Slice-Closure §7 und von dort in den Steering-Loop-Zähler. Dieser
Report ist ein Lauf-Beleg und ersetzt keine Verifikation (Modul 11, getrennter Kontext).
