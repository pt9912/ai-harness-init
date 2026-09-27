# Review-Report: slice-fall-406-trifft-die-umgebaute-zerlegung — 2026-09-27

**Review-Art:** Code — gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** Commit-Range `2dcf3ce4~1..1a92156a` (Commits `2dcf3ce4`
Claim-Move, `19954194` Ruhe-Marker-Entfernung, `1a92156a` Fall-406-Reparatur).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.2.0
**Modell:** claude-sonnet-5 · **Datum:** 2026-09-27

**Eingangs-Kontext:**

- `slice-fall-406-trifft-die-umgebaute-zerlegung` (Plandatei, vollständig gelesen §1–§8)
- [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (aktiv — Erfassungs-Policy, „Werte nie im Span")
- `LH-FA-10` ([`spec/lastenheft.md`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren))
- `AGENTS.md` §3.6, §3.7, §3.9
- `v6.9.0` · `regelwerk/modul-05-planning-harness.md`, `modul-06-roadmap.md`, `modul-11-verification.md`
- `harness/conventions.md` → `MR-071`
- Beobachtungs-Register `BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/`,
  `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/`

---

## Selbst gefahrene Formen (Scratch-Kopie, nie im Arbeitsbaum)

Alle Läufe in einer isolierten Kopie (`git archive 1a92156a | tar -x`, eigenes
`git init`), niemals im Arbeitsbaum. Ausschließlich `make test-go`/`make
mutate`/`make docs-check`/`make gates` — kein Host-Go.

1. **MR-071-Anker-Messung, unabhängig gemessen.** `grep -nc "if c != ' ' &&
   c != '\\t' && c != '\\n' {" internal/span/span.go` → **1** (gegen den
   heutigen Quell-Bestand, Zeile 468, zwei Tabs Einrückung, exakt die
   Boundary-Zeile in `splitWords`). Deckt den Implementer-Bericht.
2. **`sed`-Anwendung selbst geprüft.** Der neue `sed`-Befehl aus dem Fall
   angewandt (`git diff -- internal/span/span.go` in der Kopie) erzeugt
   **exakt eine** Zeilenänderung, keinen doppelten Text, keinen
   Escaping-Defekt: `if c != ' ' && c != '\t' && c != '\n' {` →
   `if c != ' ' && c != '\t' && c != '\n' && c < 0x80 {`. Der vom
   Implementer berichtete erste fehlgeschlagene Versuch (unescaped `&`) ist
   in der committeten Fassung nicht mehr vorhanden.
3. **Rot vor Grün, real am Produktionscode.** Mutation angewandt, `make
   test-go` → Exit 2, `FAIL github.com/…/internal/span`, vier Subtests von
   `TestCommandProgramNeverEmitsAssignmentValueFragments` (`A=b_SECRET_cmd`,
   `#01`, `#02`, `#03` = NBSP, U+2003, U+3000, U+0085) mit `"program":"SECRET"`
   in der geschriebenen Span-Zeile — Meldungstext deckt sich mit der
   Fall-Zusage. Mutation zurückgesetzt (`git checkout`), `make test-go` →
   Exit 0, alle Pakete `ok`.
4. **Nebeneffekt-Gegenprobe mit ausgeschriebener Polarität (entscheidender
   Test, Punkt 3 des Auftrags).** `t.Skip(...)` **ausschließlich** in
   `TestCommandProgramNeverEmitsAssignmentValueFragments` eingefügt, Mutation
   aktiv, `make test-go` → **Exit 2, weiterhin rot** —
   `TestCommandProgramNamesAProgramNotAnOperator/A=b_SECRET_cmd_x` fällt
   eigenständig, mit derselben `"program":"SECRET"`-Zeile. Die Mutation
   bindet damit **zwei** Tests, nicht nur den im `# expect:`-Kopf genannten
   (siehe Finding F-1).
5. **Teillauf `make mutate` im realen Repo** (nicht in der Kopie — Vorgabe
   des Auftrags), `MUTATE_JOBS=1
   MUTATE_CASES='406-span-program-wortgrenze-unicode-leerraum'`: Exit 0,
   `mutate: 1 ok, 0 Befund(e)`, `mutate: TEILLAUF 1 von 478 — kein Beleg
   (der Beleg-Slot bleibt unberuehrt)`. `.harness/state/mutate-passed.key`
   vor und nach dem Lauf nicht vorhanden, `git status --porcelain` leer.
6. **Dateimodus gegen mehrere Nachbarn.** `git ls-files -s` für 404/405/406/407
   → alle `100755` (dieselbe Batch-Anlage); 476/490 → `100644`. Repo-weit
   326× `100755` gegen 152× `100644` (`git ls-files -s test/mutations/*.sh`).
   406s Modus ist unverändert gegenüber der Vorversion (kein Mode-Diff im
   `git diff`) und deckt sich mit seinen unmittelbaren Geschwistern — keine
   Abweichung, sondern Bestand.
7. **Diff-Umfang.** `git diff 2dcf3ce4~1..1a92156a -- internal/span/span.go
   internal/span/span_test.go` → leer. Bestätigt Plan §1 und Bericht: keine
   Produktionscode-/Testdatei-Änderung.
8. **`make docs-check`** → Exit 0, `2048 Datei(en) geprüft, 0 Befund(e)`.
9. **`make gates`** → Exit 0. Baum nach dem Lauf sauber
   (`git status --porcelain` leer). Stempel-Vergleich
   `.harness/state/gates-passed.diffsha` gegen
   `bash harness/tools/working-tree-hash.sh` (nach diesem Reviewer-Commit
   erneut zu ziehen) — zum Zeitpunkt dieses Laufs deckungsgleich
   (`85d606bd…`).

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die reparierte Mutation färbt neben dem im `# expect:`-Kopf genannten Test auch `TestCommandProgramNamesAProgramNotAnOperator` — Gegenprobe (Punkt 4 oben) bestätigt: bei alleinigem Skip des benannten Tests bleibt der Lauf rot. Dieselbe Klasse ist für exakt Fall 406 bereits im Register dokumentiert (`docs/reviews/2026-09-24-slice-program-feld-nennt-weder-operator-noch-wertfragment-gegenprobe.md`, Tabelle „Fälle 404–408", Zeile 406: „**bindet**"). Der §8-Sichtungs-Schritt des Slice-Plans erklärt dazu „Kein weiterer Treffer … zu `internal/span/` spezifisch" — das trifft auf diesen, direkt einschlägigen Register-Eintrag nicht zu. | `v6.9.0` · `regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur / §Zwei Schritte vor der Modus-Begründung (Sichtungspflicht) | `test/mutations/406-span-program-wortgrenze-unicode-leerraum.sh`; Plan §8 | ja — Gegenprobe wie in Punkt 4 dieses Reports, jederzeit reproduzierbar | mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere |
| F-2 | INFO | Wird bei der Closure für diesen Slice ein Beleg zu `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` ergänzt (Konsequenz aus F-1), wäre das der **dritte** Vorgang für diese Klasse (nach `slice-204-das-programm-feld-nennt-das-programm` und `slice-program-feld-nennt-weder-operator-noch-wertfragment`, Zähler aktuell 2× unter `evidence/`) — der 3×-Übertritt verlangt beim Lese-Schritt einen Ausgang (verkörpert/geplant/gestrichen), nicht mehr „offen". Reine Vorab-Information für den Closure-Lauf, kein Diff-Defekt. | `v6.9.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register | `docs/plan/planning/observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/state.md` | ja — Zähler ist ableitbar (`ls evidence/*.md \| wc -l`) | mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `test/mutations/406-span-program-wortgrenze-unicode-leerraum.sh` — Header-Form (`# files:`/`# expect:`/Shebang) gegen Nachbarn 404/405/407 | geprüft, ohne Befund |
| `test/mutations/406-…` — neuer Kommentar-Block (§3.7: Zustandsform statt Chronik/Konjunktiv, §3.6: Zusage rot gesehen) | geprüft, ohne Befund |
| `sed`-Ausdruck des Falls — Escaping, Treffgenauigkeit (MR-071-Messung) | geprüft, ohne Befund |
| `internal/span/span.go`, `internal/span/span_test.go` — unverändert wie von Plan §1 und Bericht verlangt | geprüft, ohne Befund |
| Dateimodus `406-…` gegen Nachbarn 404/405/407/476/490 und Repo-Bestand | geprüft, ohne Befund |
| `docs/plan/planning/in-progress/roadmap.md` — Ruhe-Marker-Entfernung (Commit `19954194`) gegen `v6.9.0` · `regelwerk/modul-06-roadmap.md` §Offene Wellen | geprüft, ohne Befund |
| Slice-Plan §1–§6 (Ziel, Abgrenzung, DoD, Trigger, Closure-Trigger, Risiken) gegen `ADR-0011`, `LH-FA-10`, `MR-071` | geprüft, ohne Befund über den in F-1 genannten Punkt hinaus |
| `make mutate`-Teillauf für 406 — Beleg-Slot-Isolation (§DoD-Vorgabe) | geprüft, ohne Befund |
| `make gates`, `make docs-check` am unveränderten Arbeitsbaum | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere

## Verdikt

**Merge-blockierend:** nein — F-1 ist eine Sichtungs-Lücke mit
Register-Konsequenz (die `# expect:`-Zusage des Falls bleibt korrekt: der
Treiber prüft nur, ob der genannte Test in der roten Ausgabe steht, nicht auf
Exklusivität, und das ist unter der Mutation der Fall). Der einzige
Liefer-Punkt der DoD (Fall 406 färbt `TestCommandProgramNeverEmitsAssignmentValueFragments`
rot, Rot-vor-Grün belegt) ist real erfüllt, ohne Docker-Kopie, direkt am
Produktionscode geprüft. Weder Produktionscode noch Testdatei wurden
angerührt (Plan §1 eingehalten). `make gates` und `make docs-check` grün am
unveränderten Arbeitsbaum.

**Übergabe:** F-1/F-2 gehen an den Closure-Lauf (§3.10 — frischer
Planner-Kontext): §6 des Slice-Plans bzw. §7 (Closure-Notiz) sollten den
Register-Beleg für `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`
zusätzlich zu `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`
setzen, mit Ausgangs-Entscheidung für den 3×-Übertritt (F-2). Dieser Report
ist ein Lauf-Beleg; die Finding-Klassen gehen in die Slice-Closure §7 und von
dort in den Zähler.
