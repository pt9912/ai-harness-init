# Review-Report: slice-leser-und-aufraeum-waechter-decken-was-sie-sagen — 2026-09-22

**Review-Art:** Code — Diff geprüft gegen den Slice-Plan
`docs/plan/planning/done/slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md`
(vollständig gelesen — §1 Ziel/Abgrenzung, §2 DoD, §4 Trigger, §6 Risiken) sowie gegen den
realen Test-/Mutations-/Emit-Bestand (Modul 10 §Drei Review-Arten). Vier der fünf Prüf-Claims
dieses Laufs wurden nicht nur gelesen, sondern **hermetisch im gepinnten Docker-Image
nachgefahren** (`make test-go`, Mutation angewandt/zurückgenommen) — siehe Negativbefunde.

**Gegenstand:** `git show 3147fe59`, Commit „Leser-Wächter: Meldungs-Treffer und Arch-Gate-Grenze
gegen den gelesenen Satz gehalten" (LH-QA-01, ADR-0022, AGENTS.md §3.6). Vier Dateien:
`docs/user/e2e-abdeckung.md` (Zeilennummer-Regen), `harness/tools/full-smoke.sh` (+27/-3, zweiter
`span-clean`-Lauf), `internal/emit/erfassung_test.go` (+40/-4, `keinGateMarke`-Konstante +
`TestErfassung_KeinArchGateInZielQuellen`), `test/mutations/187-archgate-quelle-ungemeldet.sh`
(neu).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0
**Modell:** claude-sonnet-5 (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-22

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-leser-und-aufraeum-waechter-decken-was-sie-sagen`
  (`docs/plan/planning/in-progress/`, vollständig gelesen — §1, §2 DoD 1–3, §4, §6)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- [`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (*Accepted*)
- `AGENTS.md` §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel), §3.7 (Kommentar beschreibt,
  was da ist — kein Vorgang, der die Stelle erzeugt hat)
- Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice,
  `modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin, `kein Gate`-Marke), Modul 11
  §Bewusstes Brechen für DoD-Testbehauptungen (als Prüf-Maßstab für die Reviewer-eigene
  §3.6-Prüfung dieses Laufs, nicht als DoD-Konformitätsurteil)
- Vorgänger-Review `docs/reviews/2026-09-21-slice-waechter-der-erfassungsschicht-decken-was-sie-sagen.md`
  (F-1: §3.7-Narrativ; für Musterwiederholung geprüft)
- Realer Code-/Testbestand: `internal/emit/erfassung_test.go`, `internal/report/report_test.go`,
  `internal/emit/templates_test.go`, `internal/emit/templates.go`, `internal/emit/commands.go`,
  `cmd/ai-harness-init/main.go`, `test/courseset-fixture.bats`, `test/mutations/182`, `.dockerignore`,
  `Dockerfile`

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | DoD (2)s Zusage „wer der Meldung folgt, trifft jetzt exakt, was die Prüfung verlangt" wird im Commit über den bestehenden Fall `test/mutations/182` „verifiziert" — dieser Fall trägt aber **keine** Zeile mit `kein Gate`/`KEIN GATE` überhaupt und ist damit für die Meldungs-Treffer-Eigenschaft **nicht diskriminierend**: selbst hergestellt und im gepinnten `test-go`-Image gefahren, fällt derselbe Fall 182 auch gegen die **vorherige, fehlerhafte** Fassung von `TestErfassung_KeinEintragInDenGateTabellen` (Meldung „ohne KEIN GATE zu sagen") — mit derselben roten Meldung. Der eigentliche Bug wird erst sichtbar, wenn eine Zeile *exakt* mit der (alten, falschen) Meldungs-Schreibweise „KEIN GATE" eingefügt wird: gegen die neue Fassung fällt sie (`ohne "kein Gate" zu sagen`), gegen die *alte* Fassung wäre sie fälschlich grün geblieben — genau die Diskrepanz, die DoD (2) behauptet zu schließen. Das ist selbst hergestellt (siehe Negativbefunde) und im Commit **nicht** demonstriert; DoD (2)s eigener Rot-Kriterium-Text verlangt ausdrücklich einen *neuen* `test/mutations/`-Fall „mit exakt der von der Meldung verlangten Schreibweise", der bleibt grün/fällt je nachdem, ob die Meldung recht hat — dieser Fall wurde nicht angelegt. | AGENTS.md §3.6 | `internal/emit/erfassung_test.go:566-567` (Fix), `test/mutations/182-bericht-in-der-gate-tabelle.sh` (zitierter, nicht-diskriminierender Beleg) | ja — selbst reproduziert: `make test-go` mit Fall-182-Mutation gegen die Vor-Fix-Fassung (Commit `3147fe59^`) fällt ebenfalls rot, mit der alten fehlerhaften Meldung; gegen die Nach-Fix-Fassung fällt eine Zeile mit wörtlich „KEIN GATE" weiterhin rot (mit der neuen, korrekten Meldung) — beide Läufe durchgeführt und zurückgenommen | Rot-Beleg stammt aus einem Fall, der die behauptete Eigenschaft nicht misst |
| F-2 | LOW | Die neue Prüfung in `harness/tools/full-smoke.sh` (zweiter `span-clean`-Lauf über bereits leerem Bestand, beide Male auf „entfernt" geprüft) trägt — anders als der Nachbar-Zahn direkt darüber (`# Rot-Gegenbeispiel: test/mutations/176 nimmt den Grund-Satz aus der Ausgabe.“)` — keinen eigenen benannten Rot-Beleg im Commit; der Host-Lauf von `full-smoke.sh` ist auf diesem macOS-Devhost strukturell rot (bereits als Beobachtung geführt), und die Commit-Message nennt für diesen konkreten Zahn keine Ersatz-Verifikation (anders als bei Fall 187, wo die manuelle Verifikation explizit beschrieben ist). | AGENTS.md §3.6 | `harness/tools/full-smoke.sh:1144-1153` | teilweise — der Zahn ist syntaktisch korrekt (`bash -n`, `shellcheck` beide clean, selbst geprüft) und logisch plausibel, aber ohne eigenen Rot-Nachweis im Commit; ein CI-Lauf (`workflow_dispatch`) wäre der Beleg, wird aber nicht referenziert | Neuer Prüfschritt im E2E-Zahn ohne eigenen benannten Rot-Beleg im Commit |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| DoD (1), `comm`-Kommando aus §1 (Leser-Bestand `erfassung_test.go` + `report_test.go`) | geprüft, ohne Befund — selbst ausgeführt, liefert `0`, identisch mit der Plan-Behauptung (§1: „gemessen 2026-09-20") |
| DoD (1), Selbstbezugs-Suche (Klasse `TestEnforce_WrapperSuchtDenAblageort`) | geprüft, ohne Befund — beide Dateien (960 Zeilen) durchgesehen: keine Erwartung wird aus der Funktion abgeleitet, die sie rot färben soll; alle `want`/`erwartet`-Werte sind feste Literale. Die einzige Stelle, die eine SUT-Funktion (`span.Dir`) in einer Erwartung nutzt (`TestErfassungFragment_ZielUndNichtZusage`), tut dies bewusst und kommentiert genau umgekehrt — um Drift zwischen Wächter und Schreiber zu VERMEIDEN, nicht um Selbstkonsistenz zu erzeugen |
| DoD (2), `keinGateMarke`-Refactor selbst (Konstante statt zwei Schreibweisen) | geprüft, ohne Befund — der Bug war real: die Vor-Fix-Prüfung verlangte `"kein Gate"` (klein), die Vor-Fix-Meldung sagte „KEIN GATE" (groß); selbst reproduziert (siehe F-1). Der Fix behebt ihn strukturell (eine Konstante für Prüfung und Meldung) und wurde von mir unabhängig bestätigt: eine Zeile mit wörtlich „KEIN GATE" wird von der neuen Fassung korrekt weiterhin als Verstoß erkannt, mit der jetzt treffenden Meldung |
| DoD (3), Arch-Gate-Fragment-Teil: `TestErfassung_KeinArchGateInZielQuellen` + Fall 187 | geprüft, ohne Befund — im gepinnten `golang:1.27.0`-Image real gefahren: `make test-go` grün auf dem unveränderten Stand; nach Anwendung der Fall-187-Mutation (`quellen["harness/mk/arch-demo.mk"] = "x"` vor der `len(quellen) < 4`-Guard-Zeile, per GNU-`sed` exakt wie im Fall-Skript) fällt **genau** `TestErfassung_KeinArchGateInZielQuellen` mit der im Fall-Kommentar/Testcode beschriebenen Meldung; nach Rücknahme wieder grün. Das Fall-Kopf-`sed`-Muster trifft den aktuellen Quell-Bestand exakt (MR-071-Disziplin erfüllt) |
| DoD (3), Kommentar-Form an den neuen Assertions (`ZWEITE GRENZE`, `archGateFragmentPraefix`, `TestErfassung_KeinArchGateInZielQuellen`) | geprüft, ohne Befund — durchweg indikativ über den geltenden Zustand („fehlt ebenso — es entsteht nur für…", „hält diese Grenze gegen den tatsächlich gelesenen Satz"), keine Chronik über frühere Fassungen; anders als F-1 im Vorgänger-Review (§3.7-Narrativ) tritt dasselbe Muster hier **nicht** wieder auf |
| DoD (2), `full-smoke.sh`-Zahn — Syntax und Lint | geprüft, ohne Befund — `bash -n harness/tools/full-smoke.sh` fehlerfrei, `shellcheck` (gepinntes Image `koalaman/shellcheck:stable`) ohne Befund |
| DoD (2), `docs/user/e2e-abdeckung.md`-Regen | geprüft, ohne Befund — `bash harness/tools/e2e-abdeckung.sh harness/tools/full-smoke.sh <tmp>` erzeugt eine Datei, die byte-identisch mit der committeten ist; keine Hand-Nacharbeit, keine Drift |
| Gate-Lockerung, halluziniertes Gate, ADR-/Hard-Rule-Verstoß außerhalb F-1, Zustandsfeld-Chronik | geprüft, ohne Befund |
| `make gates` bzw. `make test-go` selbst gefahren | **ja** — mehrfach, im gepinnten `golang:1.27.0`-Test-Stage-Image (`--no-cache-filter test`), sowohl auf dem unveränderten Stand (grün) als auch mit vier verschiedenen, danach wieder zurückgenommenen Mutationen (Fall 187 pos./neg., Fall 182 gegen Vor-Fix-Code, Fall 182 mit „KEIN GATE"-Zeile gegen Nach-Fix-Code); Arbeitsbaum nach jedem Lauf per `git diff --stat`/`git status` als sauber bestätigt |

## Empfehlung zu Punkt 4 — DoD (3) Fixture-Grenze-Teil: Grenze akzeptieren vs. Folge-Slice

**Empfehlung: Folge-Slice, nicht „ausgesprochene Grenze mit Grund".**

Die Implementer-Begründung („der reale Vorlagensatz liegt außerhalb des Docker-Build-Kontexts der
hermetischen Go-Tests; ein Go-Test kann die Grenze dort nicht sinnvoll gegen den tatsächlich
gelesenen Satz halten, ohne das hermetische Testmodell zu brechen") ist für **Go-Tests genau
richtig** — selbst geprüft:

- `.dockerignore` schließt `.harness` explizit aus dem Docker-Build-Kontext aus
  (`# … .harness (vendored Baseline, ~240 KB) gehören nicht in den Kontext`), und die
  `test`-Stage des `Dockerfile` (`FROM warm AS test` → `COPY . .` → `go test -count=1 ./...`)
  läuft über genau diesem Kontext. Ein `internal/emit/*_test.go` sieht `.harness/baseline/<tag>/`
  also strukturell nie.
- Kein `//go:embed` im Repo bindet `.harness/baseline` in die Binary ein (`grep -rn 'go:embed'
  internal/emit/*.go` findet nur `templates/agents`, `templates/commands`, `templates/enforce`
  usw. — alles unter `internal/emit/templates/`, dem **eigenen** Vorlagensatz des Tools, nicht der
  vendorten Kurs-Baseline).

Aber: **die Prämisse „kein Weg außer Go-Test" ist falsch**, und der Beleg dafür liegt im selben
Repo, teils in derselben Nachbarschaft:

1. **`test/courseset-fixture.bats` existiert exakt für diese Klasse von Lücke** — sein eigener
   Kopfkommentar sagt es wörtlich: „Warum bats und nicht go-test: `.harness/` liegt nicht im
   Docker-Build-Kontext (`.dockerignore`), die go-test-Stage sieht den realen Baum also gar nicht.
   Genau der Grund, aus dem schon der gelöschte Wächter hier lag." Dieser bats-Test hält die
   Go-Fixture `courseSet()` (die Vorstufe von `claimSet()`, auf der
   `TestErfassung_KeinEintragInDenGateTabellen` läuft) bereits heute gegen den realen vendorten
   Baum fest — für Dateibestand und eine Platzhalter-Form. `test-bats`
   (`docker run --rm --network none -v "$(CURDIR)":/code:ro -w /code $(BATS_IMAGE) test/`) mountet
   den **ganzen** Checkout, `.harness/` eingeschlossen — die bats-Stage unterliegt der
   `.dockerignore`-Beschränkung gar nicht.
2. **`cmd/ai-harness-init/main.go` liest die Vorlagen zur Laufzeit von der Platte**
   (`emit.Templates(os.DirFS(templatesDir(targetDir, tag)), targetDir, name)`), nicht aus einem
   Embed. Genau diesen Pfad fährt `harness/tools/full-smoke.sh` bereits real und E2E — mit dem
   echten gebauten Binary gegen ein echtes Zielverzeichnis. Der Implementer hat in **derselben
   Commit** genau diese Datei für einen verwandten Zahn erweitert (DoD 2, zweiter
   `span-clean`-Lauf), ohne den naheliegenden Parallel-Zahn zu erwägen: nach dem realen Emit im
   E2E prüfen, ob eine Gate-Tabellen-Zeile für `make span-report`/`make span-clean` ohne die
   `kein Gate`-Marke auftaucht.

Beide Mechanismen sind **etablierte, im Repo bereits gelebte Muster** für exakt diese
Fixture-vs-Wirklichkeit-Lücke (bats für Fixture-Abgleich, `full-smoke.sh`-Zahn für E2E-Realprüfung)
— keiner davon bricht das hermetische Go-Testmodell, weil keiner ein Go-Test ist. Die
Implementer-Begründung verengt „kein Go-Test möglich" stillschweigend zu „keine Prüfung möglich"
und übersieht damit den eigenen, im selben Bestand dokumentierten Präzedenzfall. Das ist kein
Vorwurf an die Korrektheit des gelieferten Teils (Arch-Gate-Grenze ist sauber und real verifiziert,
siehe Negativbefunde), sondern eine Einschätzung der **Kategorie**: Dies ist keine technische
Grenze im Sinne von AGENTS.md §3.9/hermetisches Testmodell, sondern eine noch nicht verfolgte, aber
sichtbar machbare Umsetzung — der Fall gehört als benannter Folge-Slice in `open/`, nicht als
dauerhafte „ausgesprochene Grenze" in den Kommentar von `TestErfassung_KeinEintragInDenGateTabellen`.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Rot-Beleg stammt aus einem Fall, der die behauptete Eigenschaft
nicht misst · Neuer Prüfschritt im E2E-Zahn ohne eigenen benannten Rot-Beleg im Commit

## Verdikt

**Merge-blockierend: ja (F-1).** DoD (1) ist vollständig und eigenständig nachgerechnet bestätigt
(`comm` liefert 0, keine Selbstbezugs-Stelle gefunden). Der DoD (3)-Arch-Gate-Fragment-Teil ist
sauber geliefert und Ende-zu-Ende real verifiziert (Mutation 187 rot/grün im gepinnten Image
reproduziert), die Kommentar-Form hält die §3.7-Disziplin ein — das Vorgänger-Review-Muster (F-1
dort) tritt hier nicht wieder auf. Der DoD (2)-Kern-Fix (`keinGateMarke`-Konstante) ist inhaltlich
korrekt und real bestätigt: die zuvor tatsächlich abweichende Schreibweise zwischen Prüfung und
Meldung ist behoben. F-1 ist dennoch kein Stil-Nit: Der im Commit genannte Rot-Beleg für DoD (2)
(Fall 182) misst nicht die behauptete Eigenschaft — dieselbe Mutation fällt nachweislich auch gegen
die alte, fehlerhafte Fassung, mit der alten, fehlerhaften Meldung. Das ist eine §3.6-Lücke exakt
der Form, die die Hard Rule benennt: „es wurde rot" ist nicht dasselbe wie „es wurde aus dem
richtigen Grund rot". Ein diskriminierender Fall (Zeile mit wörtlich „KEIN GATE") existiert nicht
im Commit, obwohl DoD (2)s eigener Rot-Kriterium-Text genau ihn verlangt.

**Übergabe:** F-1 geht an den Implementer — entweder ein neuer `test/mutations/`-Fall, der eine
Gate-Tabellen-Zeile mit der (alten, falschen) Meldungs-Schreibweise einträgt, oder eine gleichwertig
diskriminierende Ergänzung zu Fall 182; die Formulierung „Verifiziert per Hand über den bestehenden
Fall 182" im Closure-Text sollte entweder durch den neuen Beleg ersetzt oder korrigiert werden. F-2
ist optional (Verweis auf den fehlenden CI-Beleg für den neuen `full-smoke.sh`-Zahn, analog zur
`lokaler-full-smoke-scheitert-auf-macos-host`-Beobachtung). Die Empfehlung zu Punkt 4
(Fixture-Grenze-Teil → Folge-Slice) geht an den Planner. Die Finding-Klassen gehen in die
Slice-Closure §7 und von dort in den Steering-Loop-Zähler. Dieser Report ist ein Lauf-Beleg und
wird über Läufe hinweg nicht erneut gelesen. Verifikation (DoD-/Spec-Konformität, inkl.
`make gates`) ist Aufgabe des Verifiers, nicht dieses Reports.
