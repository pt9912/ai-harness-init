# Review-Report (Runde 2): slice-leser-und-aufraeum-waechter-decken-was-sie-sagen — 2026-09-22

**Review-Art:** Eng skopierter Nachzugs-Review — prüft ausschließlich, ob Fix-Commit `e03908fe`
die zwei Runde-1-Punkte (F-1 HIGH „Fall 182 diskriminiert nicht"; die Empfehlung „DoD (3)
Fixture-Grenze → Folge-Slice statt ausgesprochene Grenze" aus
[`2026-09-22-slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md`](2026-09-22-slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md))
tatsächlich behebt, und ob dabei neue Fehler entstanden sind. Kein erneutes Von-Null-Review des
ganzen Slice. Zusätzlich einbezogen: ein zwischenzeitlicher, davon unabhängiger Verifier-Lauf hatte
den ersten Fix-Versuch (Commit `603e279e`) zurückgewiesen — dessen Zurückweisung war korrekt
(DoD (2) verlangt einen eigenen `test/mutations/`-Fall, keine Argumentation, warum keiner nötig
sei) und ist nicht Gegenstand dieser Prüfung, sondern deren Anlass.

**Gegenstand:** `git show e03908fe` — vier Dateien: `internal/emit/erfassung_test.go` (+40/-13,
`gateTabellenZeileBefund`-Auslagerung + neuer Test + Kommentar-Rewrites), `test/mutations/394-keingatemarke-pruefung-und-meldung-getrennt.sh`
(neu), `test/courseset-fixture.bats` (+37, neuer Fall), sowie `docs/reviews/2026-09-22-…md` (neu
angelegt — der Runde-1-Report selbst, erst mit diesem Commit committet).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0
**Modell:** claude-sonnet-5 (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-22

**Eingangs-Kontext:**

- Runde-1-Report (siehe oben) — F-1 (HIGH), F-2 (LOW) und die Fixture-Grenze-Empfehlung im
  Wortlaut
- Slice-Plan `docs/plan/planning/done/slice-leser-und-aufraeum-waechter-decken-was-sie-sagen.md`
  §6 Risiken (insb. Risiko 3), §2 DoD (2)/(3)
- `AGENTS.md` §3.6 (kein Beleg ohne rot gesehenes Gegenbeispiel), §3.7 (Kommentar beschreibt, was
  da ist — kein Vorgang, der die Stelle erzeugt hat), Baseline-Regelwerk Modul 11 §Bewusstes
  Brechen für DoD-Testbehauptungen
- Realer Code-/Testbestand: `internal/emit/erfassung_test.go` (vollständig um die betroffenen
  Stellen gelesen), `test/courseset-fixture.bats`, `cmd/ai-harness-init/main.go`,
  `internal/emit/{agents,commands,fieldlist,readme,templates}.go`, `.harness/baseline/v6.9.0/templates/`

**Alle sechs Prüf-Claims dieses Auftrags real nachvollzogen**, nicht nur gelesen — Details unten je
Abschnitt.

---

## Punkt A (DoD 2, F-1 Runde 1) — Prüfung

**Behauptung des Fix:** `gateTabellenZeileBefund(rel, ziel, line)` hält Prüfung und Meldung an
einer einzigen Stelle; `test/mutations/394` trennt sie testweise wieder in zwei Literale
(`keinGateMarke` vs. `"KEIN GATE"`) und `TestErfassung_ZeileMitDerMarkeBleibtOhneBefund` fällt
darauf rot, mit der im Commit genannten Meldung.

**Verifikation (selbst durchgeführt, nicht nur gelesen):**

1. Die im Fall beschriebene Mutation (Prüfzeile 600 `keinGateMarke` → `"KEIN GATE"`) am
   Arbeitsbaum angewandt (Textersetzung, funktional identisch zum `sed`-Muster des Falls — der
   Falls eigene GNU-`sed`-Syntax läuft auf diesem Host nicht, s. Grenze unten).
2. `make test-go` (gepinntes `golang:1.27.0`-Image, `--no-cache-filter test`): **rot**, exakt mit
   der im Commit zitierten Meldung: `--- FAIL: TestErfassung_ZeileMitDerMarkeBleibtOhneBefund` /
   `Zeile mit der Marke "kein Gate" wird trotzdem als Befund gewertet: test.md fuehrt "make
   span-report" in einer Gate-Tabelle, ohne "kein Gate" zu sagen: …`.
3. Mutation per `git checkout -- internal/emit/erfassung_test.go` zurückgenommen, `git status`
   sauber bestätigt.
4. `make test-go` erneut: **grün**, `internal/emit` `ok`.

**Diskriminierung real bestätigt:** Anders als der in Runde 1 kritisierte Fall 182 misst Fall 394
tatsächlich die behauptete Eigenschaft (Prüfung und Meldung an derselben Schreibweise) — er fällt
nur dann, wenn Prüfung und Meldung auseinanderlaufen, nicht schon bei jeder beliebigen fehlenden
Marke.

**Punkt 2 des Auftrags (Refactor-Neutralität):** Der Diff an
`TestErfassung_KeinEintragInDenGateTabellen` selbst ersetzt lediglich den Aufruf
(`gateTabellenZeileBefund(rel, ziel, line)` statt der inline `strings.Contains`-Prüfung) und die
ausgelagerte Funktion reproduziert exakt denselben Bedingungs- und Meldungstext wie vorher (Diff
geprüft: `if !strings.Contains(line, keinGateMarke)` → `return fmt.Sprintf("%s fuehrt %q in einer
Gate-Tabelle, ohne %q zu sagen: %q", …)`, wortgleich zum vorherigen `t.Errorf`-Aufruf). Keine
Verhaltensänderung für den bestehenden Test.

**Urteil Punkt A: geschlossen.** DoD (2) hat jetzt einen real diskriminierenden Rot-Beleg im
gepinnten Image, wie es DoD (2)s eigener Wortlaut verlangt.

## Punkt B (DoD 3, Fixture-Grenze-Empfehlung) — Prüfung

**Behauptung des Fix:** `test/courseset-fixture.bats` bekommt einen neuen Fall, der dieselbe
Prüf-Bedingung direkt gegen den realen vendored Vorlagensatz hält (nicht gegen die Fixture); Rot-
Beleg manuell geführt (keine dauerhafte Mutation auf `.harness/baseline/`, wegen MR-007).

**Verifikation (selbst durchgeführt):**

1. `make test-bats` (Docker, `--network none`, `koalaman/bats`-Äquivalent laut Makefile) auf dem
   unveränderten Baum: **346/346 grün**, darunter `ok 99 fixture: kein Eintrag im REALEN
   Vorlagen-Satz behauptet span-report/span-clean als Sensor` — der neue Fall läuft und ist grün.
2. Vor der Rot-Probe: Kopie von `.harness/baseline/v6.9.0/templates/harness/README.template.md`
   außerhalb des Repos gesichert, Checksumme notiert
   (`ed8e666b2342da983f28778c7c192b28c84a039f664f63488f0a9e0a8b23abdf`).
3. Eine unmarkierte Zeile `` | `make span-report` | Beispiel | `` an die reale, committet
   vendorte Datei angehängt. `git status` zeigt die Datei als modifiziert.
4. `make test-bats` erneut: **rot**, exakt mit der im Commit zitierten Meldung: `not ok 99 …` /
   `DRIFT: /code/.harness/baseline/v6.9.0/templates/harness/README.template.md behauptet
   span-report/span-clean als Sensor, ohne 'kein Gate' zu sagen: | \`make span-report\` |
   Beispiel |`.
5. Datei aus der Sicherung wiederhergestellt, Checksumme erneut geprüft (identisch), `git status`
   **sauber**, `make baseline-verify` → `v6.9.0 OK — 54 Dateien`, `make test-bats` erneut **grün**
   (Fall 99 wieder `ok`).

**Grenze real geschlossen, nicht nur behauptet.** Die manuelle Rot-Probe ist reproduzierbar und
trifft exakt die im Kommentar/Commit beschriebene Lücke: eine reale Vorlagen-Zeile ohne Marke wird
vom neuen bats-Fall erkannt, obwohl kein Go-Test sie sieht (`.dockerignore` schließt `.harness/`
aus dem Docker-Build-Kontext der `test`-Stage aus — selbst gegengeprüft, unverändert seit Runde 1).

**Urteil Punkt B: geschlossen.** Die Fixture-Grenze ist innerhalb dieses Slice durch einen echten,
selbst verifizierten Sensor gedeckt.

## Ergänzend geprüft: Commands()/Agents()/FieldList() vs. Templates()/RootReadme()

Der Kommentar über `TestErfassung_KeinEintragInDenGateTabellen` behauptet: `Commands()`,
`Agents()`, `FieldList()` lesen `go:embed` (real, kein Fixture-Bezug), `Templates()`/
`RootReadme()` nehmen ein `fs.FS`-Argument (Fixture in Tests, `os.DirFS(...)` in Produktion).
Gegen den realen Code geprüft:

- `internal/emit/commands.go:22`, `agents.go:23`, `enforce.go:28`: je ein `//go:embed
  all:templates/…`. `fieldlist.go:32`: `func FieldList(targetDir string) error` — kein `src`-
  Parameter.
- `internal/emit/templates.go:296`: `func Templates(src fs.FS, targetDir, name string) error`.
  `readme.go:29`: `func RootReadme(src fs.FS, targetDir, name string) error`.
- `cmd/ai-harness-init/main.go:509,513`: `emit.Templates(os.DirFS(templatesDir(targetDir, tag)),
  …)` / `emit.RootReadme(os.DirFS(templatesDir(targetDir, tag)), …)` — der reale, vendorte Baum.
- `internal/emit/emitteddocs_test.go:103ff` (`emitDokumentSatz`): ruft `Templates`/`RootReadme`
  mit dem übergebenen `src` (der Fixture `claimSet(t)`/`courseSet()`), `Commands`/`Agents` ohne
  `src`.

**Urteil:** Die im Kommentar getroffene Unterscheidung ist faktisch korrekt, nicht nur behauptet.

## Ergänzend geprüft: §6 Risiko 3 „entfallen"

Risiko 3 im Slice-Plan lautet: „Die ausgesprochene Grenze wird zur bequemen Antwort." *Absehbar:*
entfallen, wenn die Zahl der Grenzen im Report je einzeln begründet ist; sonst weiter offen ins
Register.

Der Implementer begründet „entfallen" nicht mit dieser wörtlichen Bedingung, sondern damit, dass
die Fixture-Grenze durch einen zusätzlichen, real verifizierten Sensor **geschlossen** statt nur
**benannt** wurde (Punkt B oben, selbst nachvollzogen). Das trifft den Kern des Risikos — eine
„ausgesprochene Grenze" ohne echten Beleg wäre genau die bequeme Antwort, vor der Risiko 3 warnt —,
auch wenn der wörtliche Bedingungstext des Slice-Plans nicht exakt zitiert wird. In der Sache teile
ich die Einschätzung: kein Folge-Slice nötig, weil die Lücke nicht offen bleibt, sondern
geschlossen ist. Die Abschluss-Entscheidung selbst (welcher der drei Ausgänge formal ins Register/
in die Closure-Notiz kommt) bleibt Planner-Aufgabe (Modul 5 §Offene Risiken werden bei Closure
aufgelöst) und wird hier nicht vorweggenommen.

---

## Neue Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-3 | HIGH | Der Kommentar über `TestErfassung_ZeileMitDerMarkeBleibtOhneBefund` erzählt in der Vergangenheits-/Konjunktiv-Form den **abwesenden** Vorzustand des Codes statt den geltenden Zustand indikativ zu beschreiben: „Vor 3147fe59 waren Pruefung und Meldung an zwei unabhaengig getippten Literalen aufgehaengt; eine Zeile mit der (damals) von der Meldung verlangten Schreibweise waere dort trotzdem als Befund gemeldet worden, sobald die beiden Literale auseinanderliefen." Das ist wortnah dasselbe verbotene Muster, das `AGENTS.md` §3.7 als Falsch-Beispiel nennt („die frühere Fassung prüfte nur die Länge — beschreibt abwesenden Text"; richtig wäre: die geltende Zusage nennen, „die vorige hält git"). Der Kommentar trägt hier keine der fünf zulässigen Klassen (Zusage · Kopplung · Abgrenzung · Rang-Zeiger · Grenze), sondern ein Stück Commit-Chronik. Dieselbe Fehlerklasse wie F-1 im Vorgänger-Review vom 2026-09-21 (§3.7-Narrativ) — dort als behoben bestätigt für den Commit `3147fe59`, hier neu eingeführt von `e03908fe`, das der Vorgänger-Reviewer nie gesehen hat. | AGENTS.md §3.7 | `internal/emit/erfassung_test.go:609-612` | ja — Textvergleich mit dem AGENTS.md-§3.7-Beispielkatalog; kein Gate prüft Kommentar-Semantik (`comment-claims` prüft nur, ob genannte Sensoren existieren, nicht worüber ein Kommentar spricht) | Kommentar narriert abwesenden Vorzustand statt geltenden Zustand |
| F-4 | LOW | Zwei weitere Stellen desselben Commits benennen einen rohen Git-Commit-Hash (`3147fe59`) inline als Provenienz-Anker statt einer der in `AGENTS.md` §3.7 zugelassenen Formen (`LH-*`, `ADR-*`, `seit welle-`/`seit slice-<Kennung>`): der `keinGateMarke`-Kommentar (`erfassung_test.go:41`, „der Zustand vor 3147fe59") und die Commit-Message selbst (git hält Chronik zulässig, daher hier nur als Muster-Hinweis, nicht als eigenständiger Befund an dieser Stelle gezählt). Beide Fälle sind schwächer als F-3: sie beschreiben, was ein *gegenwärtig existierendes* Artefakt (die Mutationsdatei) tut, nicht was der Code *früher* tat — Präzedenz für „vor `<hash>`" in Mutations-Datei-Köpfen existiert bereits im Bestand (`test/mutations/298-…`). Grenzwertig, aber benannt, damit die Steering-Loop-Klasse nicht nur an F-3 hängt. | AGENTS.md §3.7 | `internal/emit/erfassung_test.go:41` | teilweise — Textvergleich, kein Gate deckt Kommentar-Semantik | Roher Commit-Hash als Provenienz-Anker statt zugelassener Form |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Punkt A: Fall 394 real diskriminierend (rot mit Mutation, exakte Meldung; grün nach Rücknahme) | geprüft, ohne Befund — selbst im gepinnten `golang:1.27.0`-Image via `make test-go` reproduziert, Arbeitsbaum danach sauber |
| Punkt A: `gateTabellenZeileBefund`-Auslagerung verändert `TestErfassung_KeinEintragInDenGateTabellen`s Verhalten nicht | geprüft, ohne Befund — Bedingung und Meldungstext wortgleich zur Vorfassung |
| Punkt B: neuer bats-Fall grün auf unverändertem Baum | geprüft, ohne Befund — `make test-bats`, 346/346, Fall 99 `ok` |
| Punkt B: neuer bats-Fall rot bei unmarkierter Zeile im realen vendorten Baum, danach sauber wiederhergestellt | geprüft, ohne Befund — Checksumme vor/nach identisch, `git status` sauber, `make baseline-verify` OK, Fall 99 wieder `ok` |
| Kommentar-Unterscheidung Commands()/Agents()/FieldList() (go:embed) vs. Templates()/RootReadme() (fs.FS, Produktion `os.DirFS`) | geprüft, ohne Befund — stimmt mit dem realen Code überein |
| §6 Risiko 3 „entfallen"-Einschätzung | geprüft, in der Sache geteilt — formale Zuordnung bleibt Planner-Aufgabe |
| F-2 (LOW, Runde 1, fehlender Rot-Beleg für den zweiten `span-clean`-Lauf in `full-smoke.sh`) | **nicht adressiert** von diesem Commit — erwartungsgemäß, F-2 war optional und dieser Commit behandelt nur Punkt A/B; bleibt offen für den Implementer oder als benannte Restgröße in der Closure-Notiz |
| Gate-Lockerung, halluziniertes Gate, ADR-Verstoß außerhalb F-3/F-4 | geprüft, ohne Befund |
| `make test-go`, `make test-bats`, `make baseline-verify` selbst gefahren | **ja** — mehrfach, im gepinnten Image bzw. Docker-only-Aufruf; Arbeitsbaum nach jedem Lauf per `git status`/Checksumme als sauber bestätigt |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Kommentar narriert abwesenden Vorzustand statt geltenden
Zustand · Roher Commit-Hash als Provenienz-Anker statt zugelassener Form.

## Verdikt

**Merge-blockierend: ja (F-3).** Punkt A (DoD 2, vormals F-1 HIGH) ist geschlossen: Fall 394
diskriminiert real, selbst im gepinnten Image rot/grün reproduziert, mit exakt der im Commit
zitierten Meldung. Punkt B (DoD 3, Fixture-Grenze-Empfehlung) ist geschlossen: der neue bats-Fall
ist real grün auf dem unveränderten Baum und real rot bei einer manuell eingefügten, danach
sauber zurückgenommenen Verletzung im echten vendorten Baum — beide Richtungen selbst
nachvollzogen, inklusive Checksummen- und `baseline-verify`-Bestätigung. Beide Runde-1-Probleme
sind damit inhaltlich behoben.

Der Fix führt dabei jedoch einen **neuen** §3.7-Verstoß ein (F-3, HIGH): Der Kommentar über dem
neuen Test erzählt den abwesenden Vorzustand des Codes in Vergangenheit/Konjunktiv statt den
geltenden Zustand indikativ zu beschreiben — exakt das Muster, das der Vorgänger-Review vom
2026-09-21 bereits einmal als F-1 fing und das der vorliegende Runde-1-Report für den (anderen)
Commit `3147fe59` ausdrücklich als „nicht wiederholt" bestätigt hatte. Diese Bestätigung galt nie
für `e03908fe`, da der Kommentar dort neu entstanden ist. Damit ist dies das zweite reale
Auftreten dieser Finding-Klasse in diesem Slice-Umfeld — ein Steering-Loop-Signal.

**Übergabe:** F-3 geht an den Implementer — der Kommentar ist auf die geltende Zusage
umzuformulieren („`gateTabellenZeileBefund` hält Prüfung und Meldung an einer Stelle; Fall 394
deckt ein Auseinanderlaufen" reicht aus, ohne den Vorzustand zu erzählen; die Chronik trägt
`git`/die Commit-Message). F-4 ist optional (Formulierungshinweis, keine Blockade). F-2 aus Runde 1
bleibt offen und unadressiert. Die Finding-Klassen gehen in die Slice-Closure §7 und von dort in
den Steering-Loop-Zähler. Dieser Report ist ein Lauf-Beleg und wird über Läufe hinweg nicht erneut
gelesen. Verifikation (DoD-/Spec-Konformität, inkl. `make gates`) bleibt Aufgabe des Verifiers,
nicht dieses Reports.
