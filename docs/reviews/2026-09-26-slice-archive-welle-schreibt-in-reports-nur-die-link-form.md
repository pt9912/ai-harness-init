# Review-Report: slice-archive-welle-schreibt-in-reports-nur-die-link-form — 2026-09-26

**Review-Art:** Werkzeug-, Test- und Doku-Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 2427de2b..HEAD` (HEAD `5d7a1de2`, Baum sauber). Produktiv-Diff: `b401e133` (`internal/archive/refs.go`: `imReportBaum`,
`praefixLinkRE`, `ZaehlePraefixLink`, `ErsetzePraefixLink`, Pfad-Zweig in `fundIn` und `ersetzeIn`; `internal/archive/refs_test.go`: fünf neue Tests, zwei
Kommentar-Nachzüge), `f06cf8bc` (Mutations-Fälle 467 bis 471), `5d7a1de2` (`harness/sensors/archive-welle.md`, Vertrag und §Grenze Punkt 8).
Move-/Marker-Commits: `0ec47521` (`make slice-mv`, reiner Move `next/` → `in-progress/`), `b5777111` (Verweis-Nachzug, berührt nur die Slice-Datei, eine
Zeile), `cc5de0d9` (Ruhe-Marker der Roadmap entfernt, drei Zeilen).

**Plan-Bezug:** Slice `slice-archive-welle-schreibt-in-reports-nur-die-link-form` (Ziel, §1 Abgrenzung, §3, §4 Rückführungen, §6 Risiken, §8) — Kennung, nicht
Pfad: der Plan wandert mit dem Lifecycle (`AGENTS.md` §3.11). **Constraint:** `ADR-0070` (`Accepted`, Festlegungen 1 bis 3 und 5, Fitness-Zeilen 1 bis 6,
Trigger 1 und 4 bis 7, §Nicht gebaut), `ADR-0042` Festlegung 1, `ADR-0033` Abnahme-Kriterium 1, `MR-071`, `AGENTS.md` §3.3, §3.6, §3.7, §3.9, §3.10, §3.11.
Vergleichsmaßstab: der Shell-Träger `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` (Review und Verifier-Report dazu, R-1 und V-1 bis V-5).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-26

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0070` (Entscheidung, Konsequenzen, Fitness, Trigger) · `refs.go`, `scan.go`, `anwenden.go`, `vorschau.go` ·
`refs_test.go` · `test/mutations/467` bis `471`, `240` · `harness/sensors/archive-welle.md` · `.d-check.yml` (Zeilen zu `codepaths`) · `MR-071` ·
`AGENTS.md` §3. Der Implementer-Bericht lag dem Lauf **nicht** vor.

**Eigene Sensor-Läufe dieses Laufs** — Go-Tests in Scratchpad-Kopien von `git archive HEAD` (kein `.git`), Docker-only im `test`-Stage des Dockerfiles
(`docker build --no-cache-filter test --target test`, eigener Bild-Tag je Kopie); drei Fälle als Teillauf im Repo
(`make mutate MUTATE_JOBS=1 MUTATE_CASES='467-… 471-… 240-…'`), kein voller `make mutate`, kein Push, keine Host-Toolchain.

## Messbeleg

| Lauf | Ergebnis |
|---|---|
| unverändert, Kopie von HEAD, `go test ./...` | `exit=0` |
| Fall 467 (Form-Regel entfällt), Kopie | rot: `TestNachziehenUnterReviewsSchreibtNurDieLinkForm` (Meldung gelesen: `VerweisFund = … Praefix:9, want … Praefix:4`; im Report-Inhalt stehen Span, Span voll, Operand, Fließtext und Block auf `done/welle-10/`), dazu `…EineDateiOhneLinkNicht`, `…ErsetztLinkSyntaxImCodeSpanMit` |
| Fall 468 (Link-Nachzug schreibt kein Welle-Segment), Kopie | rot: `TestNachziehenUnterReviewsSchreibtNurDieLinkForm` (Meldung gelesen: die Links tragen `../planning/done/slice-100-a.md` statt `…/welle-10/…`, die vier Nicht-Link-Formen sind gleich), dazu vier weitere Tests |
| Fall 469 (Regel auf `done/` ausgedehnt), Kopie | rot: `TestNachziehenInDoneErsetztJedeForm` — und nur dieser |
| Fall 470 (Zähl-Seite bleibt bei `ZaehlePraefix`), Kopie | rot: `…NurDieLinkForm` (Meldung gelesen: `Nachziehen = … Praefix:4, VerweisFund = … Praefix:9 — Zaehl- und Ersetz-Seite laufen auseinander`) und `…EineDateiOhneLinkNicht` (`VerweisFund … Praefix:5, Nachziehen = []`) |
| Fall 471 (`.*` statt `[^)#\n]*`), Kopie | rot: nur `…NurDieLinkForm` (Meldung gelesen: `Praefix:2, want 4`; der zweite Link der ersten Zeile und der erste der dritten stehen auf dem alten Ort) |
| Gegenprobe „Zusicherung entfernen, Mutation bleibt", Kopie: 470 ohne die drei Fund-Vergleiche | `exit=0` — die Zähl-Zeilen binden allein |
| Gegenprobe 471 ohne Fund-Vergleich und ohne Inhalts-Vergleich | `exit=0` — beide Zeilen tragen das Rot (zweiter Fänger je Zeile) |
| Gegenprobe 468 ohne Inhalts-Vergleich in `…NurDieLinkForm` | dieser Test steht nicht mehr in der Fehlerliste (andere Tests bleiben rot) — der Inhalts-Vergleich bindet allein |
| Gegenprobe 467 ohne Inhalts- und Fund-Vergleich | dieser Test steht nicht mehr in der Fehlerliste — dieselbe Lesart |
| Teillauf im Repo: 467, 471, 240 (HEAD-Stand) | `3 ok, 0 Befund(e)`; 240 → `TestZweiterLaufZiehtDenAufsteigendenStubVerweisNach rot`; Beleg-Slot `.harness/state/mutate-passed.key` **vorher nicht vorhanden, nachher nicht vorhanden** (`TEILLAUF 3 von 459 — kein Beleg`), Baum danach sauber |
| eigene Schwächung W1: Wortgrenze im Präfix entfällt | rot: `TestPraefixLinkAnDerWortgrenze` |
| eigene Schwächung W2: Ende-Anker `[)#]` wird `[)#]?` | rot: `…ErsetztLinkSyntaxImCodeSpanMit` (Titel-Link) und `TestPraefixLinkAnDerWortgrenze` |
| eigene Schwächung: `#` fehlt im Ende-Anker | rot: `…NurDieLinkForm` (Link mit Anker), `TestPraefixLinkAnDerWortgrenze` |
| eigene Schwächung W3: Träger nimmt nur den unmittelbaren Backtick-Kontext aus (`imReportBaum` immer falsch, Wortgrenze schließt `\x60` ein) | rot: `…NurDieLinkForm` (Span voll, Operand, Fließtext, Block werden umgeschrieben), `…EineDateiOhneLinkNicht`, `…ErsetztLinkSyntaxImCodeSpanMit` — Fitness-Zeile 1 gehalten |
| eigene Schwächung: Kontext-Erkennung (Zitat im Code-Span bleibt stehen) nur an der Ersetz-Seite | rot: genau `…ErsetztLinkSyntaxImCodeSpanMit` — die Span-Hälfte der Grenze ist gebunden (Fitness-Zeile 2, Trigger 6) |
| eigene Schwächung: `if f.Summe() == 0 { continue }` in `Nachziehen` entfällt | rot: `…EineDateiOhneLinkNicht` (ModTime, per `Chtimes` auf 2001 gesetzt — keine Zeitauflösung, kein `Sleep`), `…NurDieLinkForm`, zwei Bestands-Tests |
| eigene Schwächung Wnl: `\n` aus beiden Klassen von `praefixLinkRE` | **grün** (`exit=0`) — R-1 |
| eigene Schwächung Wslash: `reviewsDir+"/"` → `reviewsDir` in `imReportBaum` | **grün** (`exit=0`) — R-2 |
| eigene Schwächung Mqm: `regexp.QuoteMeta(base)` → `base` in `praefixLinkRE` | **grün** (`exit=0`) — R-5 |
| Sonden am Ist-Stand (Kopie, Wegwerf-Test): Basis `slice-a+b.md` und `slice-a[1].md` | Treffer nur am exakten Namen (`sliceXaXb.md` nicht); `.` als Joker: `slice.md` trifft `sliceXmd` nicht |
| Sonde: CRLF, Link am Zeilenanfang und Zeilenende, `](` am Zeilenende mit `done/…)` in der nächsten Zeile | Zähler 2; die beiden Links ersetzt, CRLF unverändert, die Zeilen-übergreifende Form unberührt |
| Sonde: zwei Links `…#x)[b](…)` ohne Trenner | Zähler 2, beide ersetzt |
| Sonde: Ziel mit Klammern vor dem Segment (`](../(x)/done/x.md)`) | Zähler 0, der Link bleibt stehen (R-5) |
| Sonde: `docs/reviews/`, `docs/reviews-alt/`, `docs/reviewsX/`, `docs/plan/planning/done/` mit demselben Inhalt (Span + Link) | `docs/reviews/`: nur der Link; die drei anderen: Span und Link |
| Sonde: Modus 0600 vor dem Nachzug | 0600 danach (`dateiRechte`) |
| Sonde: Datei 0400 (Lauf als root im Container) | `err=<nil>` — die Probe erzeugt den Fehlerpfad nicht; nicht gemessen |
| `git diff 2427de2b..HEAD --stat` | 10 Dateien: Roadmap, Slice-Datei, Sensor-Doku, `refs.go`, `refs_test.go`, fünf Fälle; `scan.go`, `anwenden.go`, `vorschau.go`, `internal/emit`, `harness/tools/slice-mv.sh`, `.d-check.yml`, `docs/plan/adr/` unberührt |
| MR-071: `grep -cF` der Anker aus 467/469, 468, 470, 471 gegen `internal/archive/refs.go` | je **1** |
| Modi im Index (`git ls-files -s`) | 467 bis 471: `100644`, wie 459 und 466 |

## Findings

### R-1 — MEDIUM — die Zeilengrenze der Regel ist im Kommentar zugesagt und von keinem Test gehalten

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.6 (Zusage im Doc-Kommentar ohne rot gesehenes Gegenbeispiel), `ADR-0070` Fitness-Zeile 3 (jede Hälfte der Regel bindet ein Fall)
- `pfad`: `internal/archive/refs.go:50-53` (Kommentar „… ueberquert weder eine Link-Grenze noch eine Zeilengrenze" und `[^)#\n]*`, `[^A-Za-z0-9_)#\n-]`)
- `befund`: Die Link-Grenze hält Fall 471 (`.*` statt `[^)#\n]*` färbt `…NurDieLinkForm`). Die Zeilengrenze ist die andere Hälfte derselben Zusage: nimmt man `\n`
  aus beiden Klassen, bleibt die gesamte Suite grün (Schwächung Wnl, `exit=0`); kein Fall trägt ein `](` am Zeilenende mit einer `done/…)`-Adresse in einer späteren
  Zeile. Der Shell-Träger hat die Grenze durch die zeilenweise Verarbeitung von `sed` implizit — der Go-Träger sagt sie aus und trägt sie in der Klasse.
- Failure-Szenario: eine Änderung an der Klasse (etwa `[^)#]` beim Vereinfachen) lässt die Regel über Zeilen hinweg suchen. Ein Report mit einem `](` am Zeilenende
  (Markdown-Umbruch in einem Zitat) und einer späteren Zeile mit einem Pfad, der mit `)` schließt, wird dann als Link gelesen und umgeschrieben — die Klasse, die
  `ADR-0070` verhindern soll. Bestand heute: `grep -rnE '\]\($' docs/reviews | wc -l` → **0** (kein Erwartungswert), das Szenario ist eng; die Zusage steht trotzdem im Kommentar.
- `verifizierbar`: ja (Schwächung Wnl aus dem Messbeleg; ein Fall mit `](` am Zeilenende und `done/<datei>)` in der Folgezeile färbt sie rot)
- `klasse`: Zusage im Doc-Kommentar ohne Zahn — eine Hälfte einer Regel ohne Fall

### R-2 — LOW — die Verzeichnisgrenze von `imReportBaum` hat keinen Zahn

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6 (Zusage „unter `docs/reviews/`" im Kommentar), Maintainability
- `pfad`: `internal/archive/refs.go:41-43` (`strings.HasPrefix(filepath.ToSlash(datei), reviewsDir+"/")`)
- `befund`: Ohne den Schrägstrich (`reviewsDir`) bleibt die Suite grün (Schwächung Wslash, `exit=0`): kein Fall legt eine Datei unter einem Verzeichnis ab, das nur mit
  `docs/reviews` beginnt (`docs/reviews-alt/`). Am Ist-Stand ist die Verzeichnisgrenze richtig (Sonde: `docs/reviews-alt/` und `docs/reviewsX/` bekommen jede Form, `docs/reviews/` nur den Link).
- Failure-Szenario: entsteht ein Geschwister-Verzeichnis mit diesem Präfix und verkürzt jemand die Prüfung, geht der Baum still in die Link-Form; kein Test sagt es.
  Ein Baum dieser Art existiert heute nicht.
- `verifizierbar`: ja (Schwächung Wslash; ein Fall mit `docs/reviews-alt/…` färbt sie rot)
- `klasse`: Regel-Rand ohne Fall

### R-3 — LOW — `VerweisFund` nennt für den Suchraum unter `docs/reviews/` noch den Wächter-Grund, während die Tests daneben auf `ADR-0070` umgestellt sind

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.7 (Rang-Zeiger; „wer eine solche Zeile ohnehin anfasst, zieht sie nach"), `ADR-0070` Festlegung 2
- `pfad`: `internal/archive/refs.go:98-99` („`docs/reviews/**` bleibt darin, s. Haenger")
- `befund`: Der Diff ändert an derselben Funktion den GRENZE-Absatz (`:118-120`) und in `refs_test.go` zwei Kommentare von `ADR-0033 Abnahme-Kriterium 1` auf
  `ADR-0070 Festlegung 2` — der Zeiger „s. Haenger" im Kopf von `VerweisFund` bleibt. Der Nachzug-Leser liest `docs/reviews/**`, weil der Link dort nachzuziehen ist
  (`ADR-0070` Festlegung 2); Abnahme-Kriterium 1 begründet den Suchraum des Hänger-Wächters.
- Failure-Szenario: wer den Suchraum des Nachzugs ändert, liest „s. Haenger" und hält den Grund für den des Wächters; die Änderung des Wächters (`AusgenommenePfade`)
  erschiene als die einzige, die `docs/reviews/**` berührt.
- `verifizierbar`: nein (Kommentar; `make comment-claims` prüft den Sensor-Namen, nicht den Zeiger)
- `klasse`: Rang-Zeiger nach Teil-Umstellung inkonsistent

### R-4 — INFO — Übergabe an den Planner: der Kommentar in `scan.go` nennt für die Ausnahmeliste nur den Wächter-Grund

- `kategorie`: INFO
- `quelle`: `ADR-0070` Festlegung 2, `ADR-0033` Abnahme-Kriterium 1, Slice §1 (Hänger-Wächter und Ausnahmeliste)
- `pfad`: `internal/archive/scan.go:32-39` (unverändert im Diff)
- `befund`: Der Kommentar an `AusgenommenePfade()` sagt, `docs/reviews/**` stehe bewusst nicht in der Liste, und begründet das mit Abnahme-Kriterium 1. Das ist für den
  Hänger-Wächter richtig (`Suchraum()` fragt diese Liste, Test `TestHaengerFindetVerweisAusReviewReport`, Fall 233). Der Nachzug fragt `AusgenommenePfadeNachzug()` =
  `AusgenommenePfade()` plus `docs/plan/adr`; dass er `docs/reviews/**` ebenfalls liest, trägt `ADR-0070` Festlegung 2 (die Link-Form ist dort nachzuziehen), und das steht
  an dieser Stelle nicht. Der Kommentar ist nicht falsch — er ist für den zweiten Leser der Liste unvollständig und lässt den Wächter-Grund als den einzigen erscheinen.
  Eine Änderung gehört nicht in diesen Slice (Slice §1: die Liste behält ihre Einträge); der Kommentar-Text ist Sache der Rolle, die ihn ändert.
- `verifizierbar`: nein
- `klasse`: Kommentar begründet die gemeinsame Liste nur für einen ihrer zwei Leser

### R-5 — INFO — zwei Link-Ausprägungen und eine Maskierung liegen außerhalb der genannten Ränder

- `kategorie`: INFO
- `quelle`: `ADR-0070` Festlegung 1 (Regel: „unmittelbar hinter `](`, bis `)` oder `#`"), Trigger 7, `AGENTS.md` §3.6
- `pfad`: `harness/sensors/archive-welle.md:110-122` (Punkt 8, „Vier Ränder"), `internal/archive/refs.go:53`
- `befund`: (a) Ein Link-Ziel mit Klammern **vor** dem Segment (`](../(x)/done/x.md)`) und ein Link, dessen Ziel hinter dem Zeilenumbruch steht, werden nicht erkannt
  (Sonden, Zähler 0); der Link bleibt auf dem alten Ort, `make docs-check` zeigt ihn. Derselbe Rand wie beim Shell-Träger, dort in R-2 genannt; Punkt 8 zählt ihn nicht
  unter den vier Rändern. (b) `regexp.QuoteMeta(base)` in `praefixLinkRE` hat keinen Zahn (Schwächung Mqm grün): für die Namen dieses Repos ist der unmaskierte `.` gleichwertig
  (Sonde: kein Fehltreffer bei Namen mit `.`, `+`, `[`); eine reale Wirkung entsteht erst bei einem Namen mit Metazeichen.
- `verifizierbar`: ja (Sonden aus dem Messbeleg)
- `klasse`: Regel-Rand ohne benannte Lücke

### R-6 — INFO — der Fehlerpfad des Schreibens: Zusage klein gehalten, Rückweg vorhanden, in der Sensor-Doku nicht als Ausgang genannt

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.6, Vergleich mit dem Shell-Träger (R-1, V-1)
- `pfad`: `internal/archive/refs.go:303-305` (Doc-Kommentar SCHREIBEN), `:325` (`os.WriteFile(p, …, dateiRechte(p))`), `internal/archive/anwenden.go:111-113,118-135` (`NachCommit1Fehler`), `harness/sensors/archive-welle.md:166-169`
- `befund`: Der Doc-Kommentar sagt nur, was der Code hält: `os.WriteFile` kürzt an Ort und Stelle, ein Fehler bricht den Lauf ab, die Datei kann halbgeschrieben bleiben, der
  Aufrufer nennt den git-Rückweg. Das stimmt zum Verhalten: `Anwenden` verpackt jeden Fehler des Inhalts-Schritts in `NachCommit1Fehler` (Commit 1 steht, Commit 2 nicht),
  und `git reset --hard HEAD~1 && git clean -fd -- done/<welle>` stellt auch die schon nachgezogenen, getrackten Dateien wieder her. Die Einschränkung aus V-1 des Shell-Trägers
  („früher nachgezogene Dateien bleiben") trifft hier den Arbeitsbaum bis zum Rückweg, nicht danach. Die Sensor-Doku nennt als Ausgang zwischen den Commits nur die verletzte
  Stub-Form; ein Schreibfehler im Nachzug ist derselbe Weg und steht nicht da. Eine Zusage darüber hinaus (Atomarität, „bleibt unverändert") macht weder der Kommentar noch die Doku.
  Der Fehlerpfad selbst ist nicht gefahren (Probe unter root, `err=<nil>`).
- `verifizierbar`: teilweise (der Pfad lässt sich nur als Nicht-Root-Nutzer erzeugen)
- `klasse`: Fehlerausgang ohne Nennung in der Sensor-Doku

## Geprüft, ohne Befund

- **Die Regel (`praefixLinkRE`, `ZaehlePraefixLink`, `ErsetzePraefixLink`)** — trifft Tiefen `../`, Ziel mit `#anker`, Link-Text als Code-Span (Ziel steht hinter `](`),
  mehrere Links je Zeile, Link am Zeilenende und -anfang; ersetzt nur den Bereich zwischen Gruppe 1 und Gruppe 2 (`m[3]` bis `m[4]`), jedes andere Byte bleibt (CRLF, Modus
  0600 gemessen); RE2 hat kein Backtracking, die optionale Gruppe ändert nur den Startpunkt der Suche nach `done/`, nicht den Treffer; Wortgrenze wie `ZaehlePraefix`
  (Bindestrich als Wortzeichen, `sibling-done/` trifft nicht); ein zweiter Lauf trifft das nachgezogene Ziel nicht (`TestPraefixLinkAnDerWortgrenze`).
  Unterschiede Go-RE2 gegen POSIX-ERE des Shell-Trägers: `\n` in der Klasse (R-1), UTF-8-Zeichen zählen als ein Zeichen vor `done/` — ohne Wirkung auf die Treffer.
- **`fundIn` und `ersetzeIn`** — beide fragen `imReportBaum`; Vorschau (`vorschau.go` ruft `VerweisFund`) und Schreiben zählen dieselbe Summe (Fall 470, Test `…NurDieLinkForm`
  vergleicht `VerweisFund`, `Nachziehen` und die Literal-Erwartung `Praefix: 4`). Die Erwartung stammt aus dem Fixture-Literal, nicht aus der Ausgabe des geprüften Gegenstands.
- **`Summe() == 0` → `continue`** — eine Datei ohne Treffer wird nicht geschrieben und steht nicht im Ergebnis (Schwächung rot; ModTime-Prüfung stabil).
- **Die fünf neuen Tests** — binden die Eigenschaft, nicht die Implementierung: Byte-Vergleich des Gesamtinhalts gegen ein aus Konstanten gebautes Soll,
  Zähl-/Ersetz-Gleichheit gegen ein Literal, ModTime gegen einen vor dem Lauf gesetzten Wert; die Gegenproben oben zeigen, dass die Vergleichszeilen allein tragen.
  `gochecknoglobals`: die Fixtures sind `const`, kein Paket-Global (Lauf: `make lint` im Gate-Lauf unten).
- **Mutations-Fälle 467 bis 471** — Köpfe `# files:`/`# expect:`/`# verify:` vorhanden, der `expect`-Name deckt sich mit dem rot werdenden Test; `\x24`-/`[$]`-Konvention
  entfällt (kein `$` in den `sed`-Mustern); Modus `100644`; Anker je genau eine Stelle (MR-071); 467, 471 im Repo-Teillauf rot, 468, 469, 470 in Kopien; die Begründungen in
  den Fall-Köpfen passen zur gelesenen Meldung (in 471: „die Fälle mit je einem Link pro Zeile färben nicht" — `TestPraefixLinkAnDerWortgrenze` bleibt grün).
- **Sensor-Doku, Vertrag und §Grenze Punkt 8** — jede Aussage stimmt gegen Code und Läufe: Anker `](`, Ende `)` oder `#` (`ErsetzePraefixLink`, `ZaehlePraefixLink`); Span-Zitat wird
  mitersetzt (gebunden, eigene Schwächung „Kontext-Erkennung" rot genau dort); Code-Block-Zitat ungebunden; Referenz-Definition nicht Teil; Titel-/Spitzklammer-Link bleibt stehen
  (`…ErsetztLinkSyntaxImCodeSpanMit` fährt beide Zeilen; „`make docs-check` meldet den Rest" ist dort ausdrücklich als gelesen, nicht gefahren markiert); Kopplung an
  `codepaths.exempt-paths` (`.d-check.yml` führt `docs/reviews/**`, Zeile 384, ein Kopplungs-Test fehlt und die Doku sagt es); der Hänger-Wächter liest `docs/reviews/**` unverändert
  (`scan.go` nicht im Diff). Zahlen mit Kommando: der Abschnitt nennt keine Zahl; keine Slice-Adresse als Pfad (§3.11); Zustandsform (§3.7).
- **Kommentare im Diff** — Indikativ über den Zustand, keine Befund-Kennung, kein Run-Protokoll (§3.7); `ADR-0070` statt `ADR-0033` in `fundIn`, `ersetzeIn`, `Nachziehen`
  und den Test-Kommentaren; die Fall-Köpfe nennen Sensor und ADR-Festlegung als Herkunft, nicht die Erzählung eines Laufs. Rest: R-3.
- **`anwenden.go` (Fehlerpfad, Aussage „bricht ab, Commit 1 steht, Nachzug nicht committet, git-Rückweg")** — stimmt zum Verhalten (siehe R-6).
- **Abgrenzung §1** — keine Änderung an `harness/tools/slice-mv.sh`, `internal/emit`, `.d-check.yml`, den ADRs; die Ausnahmeliste behält ihre Einträge; der Nachzug in `done/` und
  den übrigen Bäumen ersetzt weiter jede Form (Fall 469, Test 4); der Claim-Commit `b5777111` berührt nur die Slice-Datei; eingefrorene Zeitdokumente nicht umgeschrieben.
- **HIGH-Liste des Skills** — kein Verstoß gegen eine aktive ADR oder Hard Rule (`ADR-0070` Festlegung 1 bis 3 erfüllt; §3.3 zwei Commits: Move-Commit rein, Inhalt getrennt; §3.9 nur
  Docker/`make`; §3.10 kein Closure-Schritt im Diff; §3.11 keine Pfad-Adresse eines wandernden Artefakts); keine Gate-Lockerung; kein Stilles-Grün-Pfad in einem Gate-Skript (das
  Werkzeug ist kein Gate; R-1 ist die nächste Klasse); kein halluziniertes Gate (`make archive-welle` besteht); keine superseded ADR referenziert; keine Norm nur im Template-Kommentar;
  Kommentar-Klassen: R-3 ist die einzige Rang-Zeiger-Unstimmigkeit, LOW; Zustandsfelder: der Roadmap-Diff entfernt den Ruhe-Marker und schreibt keine Chronik.
- **MEDIUM-Liste** — Zusicherung über eine Menge, die leer sein kann: `…EineDateiOhneLinkNicht` stützt sich auf `reportRest` (Konstante, nicht leer) und ein `Chtimes`-Vorher; die
  Nicht-Leere der Menge belegt `VerweisFund` in derselben Suite über derselben Fixture (`Praefix:5` unter Fall 470).

## Summary

0 HIGH · 1 MEDIUM (R-1) · 2 LOW (R-2, R-3) · 3 INFO (R-4 bis R-6). Klassen für §7: R-1 *Zusage im Doc-Kommentar ohne Zahn — eine Hälfte einer Regel ohne Fall* (schon
`R-3` des Shell-Trägers als *Regel-Ausprägung ohne Fall*, INFO), R-2 und R-5 *Regel-Rand ohne Fall bzw. ohne benannte Lücke* (dieselbe Klasse wie R-2 des Shell-Trägers), R-3 *Rang-Zeiger
nach Teil-Umstellung inkonsistent*. Damit ist das Muster *Regel-Rand ohne Fall/benannte Lücke* im zweiten Träger derselben Regel aufgetreten.

## Übergaben

- **Implementer:** R-1 (ein Fall mit `](` am Zeilenende und der Adresse in der Folgezeile, dazu die Gegenprobe wie bei 471; oder die Zusage im Kommentar auf das einschränken, was ein
  Fall hält); R-2 (ein Fall mit einem Geschwister-Verzeichnis des Präfixes, oder die Grenze im Kommentar nicht behaupten); R-3 (den Zeiger im Kopf von `VerweisFund` neben die
  bereits umgestellten Kommentare ziehen); R-6 (den Schreibfehler des Nachzugs in der Sensor-Doku neben der Stub-Form als Ausgang zwischen den zwei Commits nennen).
- **Planner:** keine Änderung der Abnahme. R-4 ist für die Closure-Notiz benennbar (Kommentar an `AusgenommenePfade()` nennt für den Nachzug-Leser den Grund nicht; Träger ist der Rolleninhaber,
  der `scan.go` ändert). R-5(a) als benannter Rand neben Titel-/Spitzklammer-Link (Beobachtung im Register, falls der Shell-Träger denselben schon führt: dann eine weitere Evidence-Datei,
  kein neuer Zähler).
- **Architect:** keine.
