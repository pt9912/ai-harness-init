# Review-Report: slice-mutate-workflow-laeuft-in-parallelen-shards — 2026-09-28

**Review-Art:** Code — geprüft gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** Commits `33bdd5ff` (slice-mv, `next/` → `in-progress/`, reiner Move) und
`e46ba9e9` (Implementierung: `.github/workflows/mutate.yml` Matrix-Strategie mit 5 Shards,
Doku-Nachzug `harness/sensors/mutate.md`)

**Skill:** `.harness/skills/reviewer.md` @ Version 2.3.0 (2026-09-27)
**Modell:** claude-sonnet-5 · **Datum:** 2026-09-28

**Eingangs-Kontext:**

- `docs/plan/planning/in-progress/slice-mutate-workflow-laeuft-in-parallelen-shards.md` (§1–§8)
- `AGENTS.md` §3 (Hard Rules, insbes. §3.2, §3.3, §3.5, §3.6, §3.7)
- `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine, §Ziel-Form: Slice
- `v6.9.0` · `regelwerk/grundlagen-klassifikation.md` §Klassifikation (Post-integration-Stufe)
- `MR-014` (`harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions`)
- `harness/sensors/mutate.md`, `harness/README.md` §Sensors/§Werkzeuge, §Safety and scope boundaries
- `.github/workflows/release.yml` (Precedent `start-smoke`)
- `harness/tools/mutate.sh` (`select_cases()`, `JOBS`-Default-Kommentar Zeile 196–201)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die Zuteilungsformel setzt `strategy.job-total == Länge(matrix.shard)` voraus. Kommt der Matrix künftig eine zweite Achse hinzu (z. B. `os: [a, b]`), verdoppelt sich `job-total` per Kreuzprodukt, während `matrix.shard` weiter nur 0–4 durchläuft — die Fälle mit `(NR-1) % job-total` in der oberen Hälfte würden dann von **keinem** Job mehr gewählt (stille Lücke), ohne dass der Fehlkonfigurations-Guard (`[ -z "$cases" ]`) das fängt, weil jeder Shard weiterhin eine nicht-leere, nur unvollständige Teilmenge bekäme. Aktuell (Ein-Achsen-Matrix) korrekt, siehe Nachrechnung unten. | Maintainability | `.github/workflows/mutate.yml:59-83` | ja — ein DoD-Nachweis „Vereinigung deckt alle 484 Fälle genau einmal" auf einer künftig erweiterten Matrix würde die Lücke zeigen | latente Wartungsfalle: Matrix-Achsen-Kopplung ungeprüft gegen künftige Erweiterung |
| F-2 | INFO | Der einzige Ort, an dem die Zuteilungslogik als Annahme benannt wird, spricht von „strukturell aus der Matrix-Deklaration abgeleitet, nicht aus Runner-Hardware oder Checkout-Uhrzeit" — unbenannt bleibt die Prämisse, dass `sort`/Glob-Reihenfolge auf den fünf unabhängig provisionierten `ubuntu-24.04`-Runnern identisch ist (gleiches Image, aber fünf getrennte VM-Instanzen). Plausibel für GH-gehostete Runner desselben Image-Tags, aber nirgends als Annahme ausgeschrieben. Ein realer Drift wäre über den DoD-Nachweis (Vereinigung = alle 484 Fälle genau einmal) sofort sichtbar. | Maintainability | `.github/workflows/mutate.yml:59-67` | ja — der ausstehende reale `workflow_dispatch`-Lauf (DoD-Punkt 1) deckt es ab | unbenannte Umgebungs-Annahme (Cross-Runner-Sortierkonsistenz) |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Shard-Zuteilung, eigene Nachrechnung (484 Fälle, Index-Modulo, 5 Shards) | geprüft, ohne Befund — Vereinigung = 484 Fälle, keine Lücke, keine Dopplung, identisch mit `ls test/mutations/*.sh` |
| `fail-fast: false` — Begründung und Konsistenz mit `release.yml` `start-smoke` | geprüft, ohne Befund — Wortlaut/Bauart deckungsgleich („ein Bruch auf einem/einer … soll die Befunde/Aussage der übrigen nicht verdecken") |
| Reproduzierbarkeit der Zuteilung (kein `nproc`-/Zeit-Bezug) | geprüft, ohne Befund — Zuteilung basiert ausschließlich auf sortierten Dateinamen und der statischen Matrix-Liste `[0,1,2,3,4]`; Kommentar zitiert `harness/tools/mutate.sh` Zeile 196–201 korrekt (Zeilen-Check selbst gefahren) |
| `make ci-lint` (actionlint) real gegen `.github/workflows/mutate.yml` gefahren | geprüft, ohne Befund — `EXIT 0`, keine Ausgabe |
| Fehlkonfigurations-Guard `[ -z "$cases" ]` (bash-Nachbildung mit Range `[1..5]` statt `[0..4]`, `job-total=5`) | geprüft, ohne Befund — Shard-Index 5 erhält 0 Fälle, Guard hätte real abgebrochen; entspricht dem vom Implementer beschriebenen Rot-Beleg |
| `select_cases()` gegen eine real berechnete Shard-Teilmenge (Shard 0, 97 Namen) | geprüft, ohne Befund — akzeptiert (Exit 0), liefert exakt 97 Namen zurück, Funktion selbst unverändert |
| Doku-Nachzug `harness/sensors/mutate.md` §Bindung | geprüft, ohne Befund — „Nacht-Job" → „Nacht-Workflow … Matrix aus parallelen Shard-Jobs" akkurat; `49m54s`-Zahl ausdrücklich als „aus der Zeit vor der Matrix" eingeordnet, Matrix-Wall-Clock-Zeit als „eigener, noch ausstehender Beleg" benannt statt fabriziert |
| `harness/README.md` unverändert — Diff-Stat und Inhalt selbst geprüft | geprüft, ohne Befund — kein Treffer für „Nacht-Job"/„Job " in §Sensors/§Werkzeuge-Zeile zu `make mutate` (Zeile 77); die historische `49m54s`-Erwähnung in §Safety and scope boundaries (Zeile ~226) bleibt im Präteritum („der Preis war gemessen") und damit sachlich korrekt, nicht durch die Matrix verfälscht — außerhalb des im Plan benannten Prüf-Scopes (nur die §Werkzeuge-Zeile war explizit zu prüfen) |
| Scope-Treue zum Plan (§3-Tabelle: nur `mutate.yml` + `harness/sensors/mutate.md`) | geprüft, ohne Befund — `git diff --stat e46ba9e9~1 e46ba9e9` zeigt exakt diese zwei Dateien, keine dritte Datei berührt |
| §3.3 (Move getrennt von Inhalt) | geprüft, ohne Befund — `33bdd5ff` ist 0 insertions/0 deletions, 100 % Rename-Similarity, eigener Commit vor `e46ba9e9` |
| §3.2 (keine Lint-Suppressionen) | geprüft, ohne Befund — `grep -n 'shellcheck disable\|# noqa' .github/workflows/mutate.yml` liefert keinen Treffer |
| §3.7 (Kommentar-Klassen im neuen Kopf- und Step-Kommentar) | geprüft, ohne Befund — durchgehend Indikativ über den bestehenden Zustand (Kopplung/Zusage-Klasse), Herkunft als auflösbares Feld (`harness/tools/mutate.sh` Zeile 196–201, `release.yml` `start-smoke`), kein Konjunktiv über verworfene Alternativen, kein Bezug auf einen abwesenden Text oder eine Lauf-Chronik |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** latente Wartungsfalle: Matrix-Achsen-Kopplung ungeprüft gegen
künftige Erweiterung · unbenannte Umgebungs-Annahme (Cross-Runner-Sortierkonsistenz)

## Offene Punkte (kein Finding, Notiz für Verifier/Closure)

- **Gate-Stempel veraltet gegenüber dem aktuellen Gesamtbaum.** `.harness/state/gates-passed.diffsha`
  trägt `d5ab5380…`, der aktuelle `bash harness/tools/working-tree-hash.sh` liefert `b7931172…` —
  unterschiedlich. Ursache: der unabhängige Commit `2bfc9355` (Rolle Planner, andere Datei) landete
  zwischen dem `make gates`-Lauf des Implementers und jetzt auf `main`. Kein Fehler dieses Slice —
  der Implementer hat `make gates` zweimal grün gefahren, wie im Commit belegt (`d-check 2087
  Datei(en) 0 Befund(e)`, `comment-claims 77 Datei(en) 0 Befund(e)`) — aber der Stempel deckt den
  jetzigen Gesamtstand nicht mehr und muss vor Closure erneut erzeugt werden (`make record-gates`
  bzw. ein frischer `make gates`-Lauf).
- **Realer CI-Beleg (`workflow_dispatch`-Lauf mit N parallelen, grünen Jobs) steht noch aus** —
  DoD-Punkt 1 verlangt ihn explizit erst nach Push; das ist laut Plan/Auftrag Teil-DoD nach
  Review/Verify/Closure, kein Review-Blocker. Ohne diesen Lauf ist insbesondere die
  Wall-Clock-Zielkorridor-Frage (~20–25 min) und der zweite Nachzug in `harness/sensors/mutate.md`
  (reale Matrix-Wall-Clock-Zeit statt „ausstehender Beleg") noch offen.

## Verdikt

**Merge-blockierend:** nein — keine HIGH-, keine MEDIUM-Findings. Die eigene Nachrechnung der
Shard-Zuteilung bestätigt die Implementer-Behauptung vollständig (484 Fälle, 5 Shards, Vereinigung
ohne Lücke/Überlappung); `make ci-lint` wurde real gegen die neue Datei gefahren (EXIT 0); der
Fehlkonfigurations-Guard wurde selbst mit einer absichtlich falschen Shard-Zahl durchgespielt und
greift fail-closed wie beschrieben.

**Übergabe:** Findings gehen an den Implementer; F-1/F-2 sind LOW/INFO und nicht
merge-blockierend — Entscheidung, ob sie aufgenommen werden, liegt beim Implementer/Planner.
Die zwei offenen Punkte (Gate-Stempel, realer CI-Beleg) gehen zusätzlich an Verifier/Planner vor
Closure. Dieser Report ist ein Lauf-Beleg und ersetzt keine Verifikation (Modul 11).
