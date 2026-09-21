# Review-Report: slice-waechter-der-erfassungsschicht-decken-was-sie-sagen — 2026-09-21

**Review-Art:** Code — Diff geprüft gegen den (auf einen Liefer-Punkt reduzierten) Slice-Plan
`docs/plan/planning/done/slice-waechter-der-erfassungsschicht-decken-was-sie-sagen.md` §1/§2 sowie
gegen den realen Test-/Mutations-Bestand (Modul 10 §Drei Review-Arten). Der Plan wurde durch die
in §4 vorab benannte und am 2026-09-20 eingetretene Rückführung mit Neuschnitt auf genau den
Träger- und Feldlisten-Bestand reduziert; dieser Commit ist der bereits vollständig gelieferte Teil
davon.

**Gegenstand:** `git show ad7eba8f`, Commit „Rolle Implementer: Traeger- und Feldliste-Waechter
decken, was sie sagen" (LH-QA-01, ADR-0022, AGENTS.md §3.6). Datei-Umfang laut `--stat`:
`internal/emit/enforce_test.go` (+39/-5, Fix an `TestEnforce_WrapperSuchtDenAblageort` plus zwei
neue Grenz-Kommentare) und zehn neue `test/mutations/`-Dateien (382–393).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0
**Modell:** claude-sonnet-5 (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-21

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-waechter-der-erfassungsschicht-decken-was-sie-sagen`
  (`docs/plan/planning/next/`, vollständig gelesen — §1 Ziel/Abgrenzung inkl. Neuschnitt-Historie,
  §2 DoD, §4 Trigger, §6 Risiken)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- [`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (*Accepted*)
- `AGENTS.md` §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel), §3.7 (ein Kommentar beschreibt,
  was da ist — nicht den Vorgang, der die Stelle erzeugt hat)
- Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice,
  [`grundlagen-harness-dateien.md`](../../.harness/baseline/v6.9.0/regelwerk/grundlagen-harness-dateien.md)
  §Was ein Kommentar trägt
- Realer Code-/Testbestand: `internal/emit/enforce_test.go`, `internal/emit/enforce.go`,
  `internal/span/fieldlist.go`, `internal/span/fieldlist_test.go`, `internal/emit/fieldlist_test.go`,
  `internal/emit/templates/d-check.yml`, `internal/report/report.go`, `internal/report/report_test.go`,
  `test/mutations/159-traegername-ohne-endung.sh`, `test/mutations/382-393*.sh`,
  [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Der neue Kommentar über `TestEnforce_WrapperSuchtDenAblageort` narrativiert eine abgelöste Code-Fassung statt nur den geltenden Zustand zu nennen: „DIE ERWARTUNG STEHT FEST, NICHT ABGELEITET: fruehere Fassungen bildeten die erwarteten Namen aus emit.CarrierPath(image) und pruefften dann, ob der Wrapper sie enthaelt — das mass nur Selbstkonsistenz, weil …". Das trifft wörtlich das in AGENTS.md §3.7 als **Falsch** benannte Muster „die frühere Fassung prüfte nur die Länge" — beschreibt abwesenden Text; die Alternative dort lautet „die geltende Zusage nennen; die vorige hält git." Kein Gate fängt das (`make comment-claims` prüft nur, ob ein genannter Sensor existiert, nicht, worüber ein Kommentar spricht, und `_test.go`-Dateien liegen ohnehin außerhalb seines Prüfbereichs). | `AGENTS.md` §3.7 | `internal/emit/enforce_test.go:608-615` | ja — Diff `ad7eba8f` zeigt den Text; Wortlautvergleich mit `AGENTS.md` §3.7 Beispiel „Falsch" ist unmittelbar | Kommentar chronikt eine abgelöste Implementierung statt den geltenden Zustand zu nennen |
| F-2 | LOW | `test/mutations/393-zeilen-zaehlt-erst-nach-dem-parsen.sh` (neu in diesem Commit) zielt auf `internal/report/report.go` und deckt `TestAggregiere_ZeilenZaehltAuchUnlesbare` — eine Funktion in `internal/report/report_test.go`. Sowohl der (reduzierte) Plan §1 („Der Bestand ist geschlossen und benannt: … enforce_test.go … fieldlist_test.go … sowie die zugehörigen Fälle unter test/mutations/") als auch die Commit-Message selbst („DoD (2) und (3) sowie der Leser/Aufräum-Bestand (…, internal/report/report_test.go, …) sind mit diesem Commit NICHT bearbeitet") ordnen `report_test.go` explizit dem ausgeklammerten Leser-Bestand des Folge-Slice zu. Keine der drei genannten Leser-Dateien wird editiert (die geprüfte Bedingung aus der Aufgabenstellung ist damit wörtlich erfüllt), aber ein Wächter-Fall für eine ihrer Zusagen wird bereits hier geliefert — die Scope-Beschreibung ist an dieser Stelle ungenau. Funktional unschädlich: Der Folge-Slice-Plan (`docs/plan/planning/in-progress/slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md` §1) misst sein eigenes `comm`-Kommando bereits am 2026-09-20 mit Ergebnis 0 und hat den Fall damit korrekt miterfasst. | Maintainability | `test/mutations/393-zeilen-zaehlt-erst-nach-dem-parsen.sh` vs. Plan §1 / Commit-Message | ja — `grep -rl 'func TestAggregiere_ZeilenZaehltAuchUnlesbare' --include=*_test.go .` zeigt `internal/report/report_test.go`, nicht einen der drei im Plan §1 benannten Träger-/Feldlisten-Bestandsdateien | Commit-Scope-Beschreibung nennt einen gelieferten Mutations-Fall nicht, der sachlich zum ausgeklammerten Nachbar-Bestand gehört |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Datei-Umfang des Commits gegen §1-Ausschluss (`internal/emit/erfassung_test.go`, `internal/report/report_test.go`, `internal/emit/templates/enforce/erfassung.mk`) | geprüft, ohne Befund — `git show ad7eba8f --stat` listet ausschließlich `internal/emit/enforce_test.go` und zehn neue `test/mutations/`-Dateien; keine der drei Leser/Aufräum-Dateien ist im Commit editiert (siehe aber F-2 zur Scope-Beschreibung eines gelieferten Falls) |
| §2 DoD (1), gemessenes `comm`-Kommando aus §1 | geprüft, ohne Befund — selbst ausgeführt, liefert exakt `TestBlockedFragment_Drops` und `TestEnforce_EmitsAllMechanicFiles`, identisch mit der Plan-Behauptung |
| Grund-Kommentar an den zwei ausgesprochenen Grenzen (`TestBlockedFragment_Drops`, `TestEnforce_EmitsAllMechanicFiles`) | geprüft, ohne Befund — beide tragen einen `AUSGESPROCHENE GRENZE (AGENTS.md §3.6)`-Kommentar direkt über der jeweiligen `func Test…`-Zeile, indikativ über den geltenden Zustand (welcher Nachbar-Wächter denselben Eingriff reißt), keine Chronik |
| Fix an `TestEnforce_WrapperSuchtDenAblageort` — bezieht die Erwartung nicht mehr aus `emit.CarrierPath()` | geprüft, ohne Befund — die erwarteten Basisnamen (`ai-harness-init`, `ai-harness-init.exe`) sind jetzt als `want`-Literale verdrahtet; `CarrierPath(image)` wird zusätzlich per `!=`-Gleichheit gegen `want` geprüft statt nur als Substring-Quelle für die eigene Erwartung zu dienen (Kommentar-**Form** dazu siehe F-1) |
| `test/mutations/159` reißt den Wächter jetzt | geprüft, ohne Befund — durch Quellcode-Nachvollzug bestätigt (nicht per `make mutate`/Docker in dieser Sitzung ausgeführt): Mutation 159 nimmt `CarrierPath()` die `.exe`-Endung; die alte Fassung leitete `rel`/`want` aus genau dieser mutierten Funktion ab und blieb dadurch selbstkonsistent grün, die neue Fassung vergleicht `CarrierPath(image)` gegen das feste Literal `ai-harness-init.exe` und fällt |
| Stichprobe neuer Mutations-Fälle (382, 385, 392, 393) — `# files:`/`# expect:`-Kopf korrekt, `sed`-Muster trifft real | geprüft, ohne Befund — alle vier Köpfe folgen dem etablierten Format (Shebang · `# files:` · `# expect:` · Begründungskommentar · `set -euo pipefail`); jedes `sed`-Muster wurde gegen eine lokale Kopie der realen Quelldatei angewendet und erzeugt exakt die im Fall-Kommentar beschriebene Mutation (382: `enforce.go` Modus 0o755→0o644; 385: `fieldlist.go` `if f.Required`→`if !f.Required`; 392: `d-check.yml` `scan.ignore` um `"harness/**"` erweitert; 393: `report.go` `b.Zeilen++` verschoben) |
| Alle zehn `# expect:`-Ziele lösen auf reale `func Test…` in Go-Dateien auf | geprüft, ohne Befund — neun liegen in den drei DoD-Bestandsdateien (`enforce_test.go`, `internal/span/fieldlist_test.go`, `internal/emit/fieldlist_test.go`), einer (393) in `internal/report/report_test.go` (siehe F-2) |
| Gate-Lockerung, halluziniertes Gate, ADR-/Hard-Rule-Verstoß außerhalb F-1, Zustandsfeld-Chronik | geprüft, ohne Befund |
| `make gates` / `make mutate` selbst gefahren | **nicht** selbst gefahren (Docker-only, Reviewer-Lauf ohne Docker-Zugriff in dieser Sitzung); Commit-Message nennt `make gates` grün. Für den §3.6-Rot-Beleg von 382–393 sowie 159 wurde stattdessen der `sed`-Anker gegen den realen Quellbestand angewendet (siehe oben) — kein Ersatz für einen Docker-`make mutate`-Lauf, aber eine unabhängige Bestätigung der Muster-Trefferquote |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Kommentar chronikt eine abgelöste Implementierung statt den
geltenden Zustand zu nennen · Commit-Scope-Beschreibung nennt einen gelieferten Mutations-Fall
nicht, der sachlich zum ausgeklammerten Nachbar-Bestand gehört

## Verdikt

**Merge-blockierend: ja (F-1).** Der DoD-Kern dieses reduzierten Slice — Fall- oder
Grenz-Abdeckung für jeden Wächter des Träger- und Feldlisten-Bestands, kein Wächter mit
Selbstbezug — ist erfüllt und durch eigenständige Nachrechnung bestätigt: das `comm`-Kommando aus
§1 liefert exakt die zwei geplanten Namen, beide Grenz-Kommentare sitzen korrekt an der Assertion,
der `TestEnforce_WrapperSuchtDenAblageort`-Fix bricht die Selbstbezugs-Kette nachvollziehbar, und
die Stichprobe der zehn neuen Mutations-Fälle trifft real. F-1 ist dennoch kein Stil-Nit: Der neue
Kommentar über genau diesem gefixten Test erzählt explizit, was „frühere Fassungen" taten — exakt
das in `AGENTS.md` §3.7 als **Falsch** benannte Muster, und kein Gate hätte es gefangen. F-2 ist
eine Präzisions-Lücke in der Scope-Beschreibung ohne Funktionsrisiko (vom Folge-Slice bereits
korrekt mitgerechnet) und für sich nicht merge-blockierend.

**Übergabe:** F-1 geht an den Implementer — der Kommentar wird auf die geltende Zusage
umgeschrieben (was `TestEnforce_WrapperSuchtDenAblageort` heute prüft und was ihn bricht), ohne
die frühere Fassung zu erzählen; die Herkunft trägt `git`. F-2 ist eine optionale Präzisierung für
den Implementer oder die nächste Closure-Notiz (§7 dieses Slice bzw. §1 des Folge-Slice könnte den
bereits gelieferten Fall 393 explizit nennen). Die Finding-Klassen gehen in die Slice-Closure §7
und von dort in den Steering-Loop-Zähler. Dieser Report ist ein Lauf-Beleg und wird über Läufe
hinweg nicht erneut gelesen. Verifikation (DoD-/Spec-Konformität, inkl. `make gates`) ist Aufgabe
des Verifiers, nicht dieses Reports.
