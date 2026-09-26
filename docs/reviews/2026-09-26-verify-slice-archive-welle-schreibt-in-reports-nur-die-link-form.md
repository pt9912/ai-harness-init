# Verifikations-Report: slice-archive-welle-schreibt-in-reports-nur-die-link-form — 2026-09-26

**Rolle:** Verifier (Modul 11) — DoD-/ADR-Konformität und Plan-vs-Code-Diff an den Planner. Frischer Kontext, kein Selbst-Verifizieren. Nicht der Reviewer-Maßstab (Diff gegen Plan, ADR, Hard Rules) und nicht der Validator.

**Gegenstand:** Slice `slice-archive-welle-schreibt-in-reports-nur-die-link-form` (Kennung, nicht Pfad: die Datei wandert mit dem Lifecycle, `AGENTS.md` §3.11), Stand HEAD `335edffe`, Baum sauber. Diff-Basis `2427de2b..HEAD`. Nach dem Review-Report zum Slice liegen drei Commits, die kein Reviewer gelesen hat: `fc638444` (zwei Go-Tests, Kommentare in `refs.go`), `a038a349` (Fälle 472 und 473), `335edffe` (Sensor-Doku, Schreibfehler als Ausgang) — sie sind hier gegen eigene Läufe geprüft.

**Maßstab:** DoD und Plan des Slice (Ziel, §1 Abgrenzung, §3, §4, §5 Closure-Trigger, §6 Risiken, §8), `ADR-0070` (Festlegungen 1 bis 3 und 5, Fitness-Zeilen 1 bis 6, Trigger 1 und 4 bis 7, §Nicht gebaut), `ADR-0042` Festlegung 1 (der ADR-Index trägt die Revisions-Marke für den einen Wert), `ADR-0033` Abnahme-Kriterium 1, `AGENTS.md` §3.6, §3.7, §3.10, §3.11, `MR-071`, `MR-025`.

**Eingang:** DoD-Bestätigung und Sensor-Belege des Implementers; der Review-Report zum Slice (0 HIGH · 1 MEDIUM R-1 · 2 LOW · 3 INFO) und der Verifier-Report des Shell-Trägers als Vergleich, beide nur gelesen, keine Zahl von dort übernommen.

**Eigene Läufe** (alle in Scratchpad-Kopien von `git archive HEAD` oder im gepinnten Docker-Bild, nie im Repo-Baum; kein `go`, kein `python3` auf dem Host; `git status` des Repos blieb leer):

- Go-Tests in `internal/archive` im `test`-Stage des Dockerfiles (`docker build --no-cache-filter test --target test`, eigener Bild-Tag je Kopie), mit einem zusätzlichen eigenen Test in der Kopie;
- **Teillauf** `make mutate MUTATE_JOBS=1 MUTATE_CASES='240 467 468 469 470 471 472 473'` (die vollen Fall-Namen), kein voller `make mutate`;
- Politik-D-Messung (Closure-Trigger 2) in einer Kopie mit `git init`, dem gebauten Träger (`make host-bin` in der Kopie) und dem echten `archive-welle`-Lauf.

**Beleg-Slot** `.harness/state/mutate-passed.key`: **vorher nicht vorhanden, nachher nicht vorhanden.** Der Teillauf meldete `TEILLAUF 8 von 461 — kein Beleg (der Beleg-Slot bleibt unberuehrt)`; die Datei ist nirgends entstanden (`ls .harness/state | grep -c mutate-passed` → 0, nach dem Teillauf und nach den Kopien-Läufen).

## Ergebnis

| Punkt | Verdikt |
|---|---|
| Liefer-Punkt 1 — die Form-Regel im Träger | **bestätigt** |
| Liefer-Punkt 2 — Tests und Fälle | **bestätigt** |
| Liefer-Punkt 3 — Sensor-Doku | **bestätigt mit Vorbehalt** (V-1: die Rückweg-Kommandozeile der Doku ist gegenüber der Meldung des Werkzeugs verkürzt) |
| Closure-Trigger 1 — Tests grün in `make gates`, Rot-Belege je einmal gesehen | **bestätigt** (Stand im Übergabebericht des Laufs, der Stempel deckt den Baum) |
| Closure-Trigger 2 — Politik D in einer `git archive`-Kopie | **bestätigt mit Vorbehalt** (die Kopie musste die Vorbedingungen der Vorprüfung herstellen; V-3, V-4) |
| §1 Abgrenzung, Größe (drei Liefer-Punkte, zwei Schichten) | **bestätigt** |

0 HIGH · 0 MEDIUM · 1 LOW (V-1) · 4 INFO (V-2 bis V-5). Kein Befund ist eine DoD-Verletzung.

## Liefer-Punkt 1 — die Form-Regel: bestätigt

**Zusage** (Slice §2, `ADR-0070` Festlegung 1): unter `docs/reviews/` wird nur die Adresse unmittelbar hinter der Link-Klammer ersetzt (bis `)` oder `#`); jede andere Pfad-Adresse bleibt Byte für Byte; in den übrigen Bäumen jede Form; Zähl- und Ersetz-Seite gleichlaufend.

**Gelesen:** `internal/archive/refs.go` — `imReportBaum` (Verzeichnis-Präfix `docs/reviews/`, mit Schrägstrich), `praefixLinkRE` (Anker `](`, Präfix-Teil ohne `)`, `#` und Zeilenumbruch, Wortgrenze wie `ZaehlePraefix`), `ZaehlePraefixLink`/`ErsetzePraefixLink` (Ersetzung schreibt nur das Segment zwischen Präfix und Endzeichen; eine Datei ohne Treffer wird nicht geschrieben), Pfad-Zweig in `fundIn` **und** `ersetzeIn` über dieselbe Frage `imReportBaum`. Die Vorschau ruft `VerweisFund` (`vorschau.go`), zählt also mit der Regel des Schreibers.

**Eigene Formen** (Zusatztest in der Kopie, gegen den unveränderten HEAD grün): zwei Dateien unter `docs/reviews/` (eine in `sub/deep/`) mit
zwei aneinandergrenzenden Links in einer Zeile, Link-Text als Code-Span mit Anker `#`, CRLF-Zeilenende, Tiefe `../../../docs/plan/…`, einem Pfad **nach** einem fremden Link in derselben Zeile, einem Pfad nach einem Link mit Anker, Span und Operand-Span, und einem Link am Dateiende ohne Zeilenumbruch. Ergebnis: die Datei ist byte-gleich der erwarteten (nur die Link-Ziele tragen das Wellen-Segment), der Dateimodus `0755` bleibt, `VerweisFund` und `Nachziehen` nennen dieselbe Zahl je Datei. Vier Nicht-`docs/reviews/`-Ziele (`docs/user/`, ein Unterverzeichnis unter `done/`, das Geschwister-Verzeichnis `docs/reviews-alt/` und die Datei `docs/reviewsX.md`) bekommen **jede** Form (drei Ersetzungen je Datei).

**Hänger-Wächter und Nachbarn:** `git diff 2427de2b..HEAD --stat` nennt nur `refs.go`, `refs_test.go`, `harness/sensors/archive-welle.md`, `test/mutations/467`–`473`, den Slice selbst und die Roadmap (der Ruhe-Marker entfällt mit der Beanspruchung). `scan.go`, `anwenden.go`, `vorschau.go`, `slice-mv.sh`, `internal/emit`, `.d-check.yml` und alle ADRs sind unberührt.

**Kommentare (§3.7):** Zustandsform, Zeiger auf `ADR-0070` und benannter Sensor (Test und Fall); im hinzugefügten Text stehen keine Befund-Kennung, keine Runde, kein Konjunktiv über eine verworfene Fassung (Suche über `befund|review-|runde|früher|bisher|nachträglich` im Diff der drei Bäume: 0 Treffer). Die Zusage des `SCHREIBEN`-Absatzes ist auf das eingeschränkt, was der Code hält (siehe Fehlerpfad unten).

## Liefer-Punkt 2 — Tests und Fälle: bestätigt

**Tests:** Der `test`-Stage (`go test ./...`) ist am HEAD grün (Kopie, exit 0, mit dem Zusatztest). `make lint` (gochecknoglobals) läuft in `make gates` (Stand im Übergabebericht des Laufs, der Stempel deckt den Baum).

**Fälle 467 bis 473 und Fall 240:** Kopf (`files`, `expect`, `verify: test-go`) vorhanden; Anker je Fall mit `grep -cF` gemessen: jeder **1** (die vier Anker-Kommandos aus den Kopfkommentaren ergeben je 1). Modus `100644`, wie 135 von 461 Fällen (Bestand `git ls-files -s test/mutations`), der Treiber ruft sie mit `bash` (INFO V-2).

**Teillauf:** `8 ok, 0 Befund(e)` (240 und 467 bis 473) — der Treiber prüft, dass die Mutation die Datei ändert, der Sensor rot wird **und** der erwartete Test in der Fehlschlag-Ausgabe steht.

**Selbst gefahren, Meldung gelesen** (Kopien von HEAD, Mutations-Skript des Falls angewandt, Diff der Mutation gegen HEAD gelesen):

| Fall | Meldung (gekürzt) |
|---|---|
| 467 Form-Regel entfällt | `VerweisFund = … Praefix:9, want … Praefix:4`; fünf Tests rot, darunter der benannte; die Datei ohne Link-Treffer wird angefasst (`ModTime` ≠ 2001-01-02) |
| 468 Link-Nachzug schreibt kein Wellen-Segment | `TestNachziehenUnterReviewsSchreibtNurDieLinkForm` und sieben weitere rot; die Links tragen den alten Ort |
| 471 `.*` statt `[^)#\n]*` | nur der benannte Test: `VerweisFund … Praefix:2, want … Praefix:4` |
| **472 Zeilengrenze** (neu) | `ZaehlePraefixLink = 3, want 1 (nur der Link in einer Zeile)` und `Nachziehen … Praefix:3, want … Praefix:1`, dann der Inhalts-Vergleich; nur der benannte Test |
| **473 Verzeichnisgrenze** (neu) | Inhalt von `docs/reviews-alt/…`: `Span: …/done/slice-100-a.md` bleibt stehen, `want … done/welle-10/…`; nur der benannte Test |

Die Fälle 469 und 470 hat der Teillauf mit dem Treiber-Urteil belegt (Rot mit dem erwarteten Test), ihre Meldung habe ich nicht selbst gelesen. Fall 240 (`refs.go`-Anker, aufsteigende Form) ist am HEAD `ok`.

**Gegenprobe „grün heißt bindet"** (Kopie: Mutation anwenden, dann in **genau dem benannten Test** jedes `t.Errorf` auf `t.Logf` stellen): 471, 472, 473 und 469 werden **grün** (`docker build exit 0`). Der benannte Test trägt also das Rot allein — kein anderer Zweig deckt die Mutation, und die Assertionen des Tests binden. Zusätzlich beide **Einzel-Klassen-Mutanten** von Fall 472 (nur die erste Zeichenklasse verliert `\n`, nur die zweite): **beide rot** im benannten Test — die Zusage im Kopf des Falls (*„faellt nur die eine der zwei Klassen, faerbt einer der beiden Umbrueche"*) hält an beiden Hälften.

**Träger mit nur der Backtick-Kontext-Ausnahme** (Fitness-Zeile 1, Gegenbeispiel; Kopie: `praefixLinkRE` durch eine Regex ersetzt, die nur ein unmittelbar vorangehendes Backtick-Zeichen ausnimmt, sonst jede Adresse ersetzt): rot — `VerweisFund = … Praefix:8, want … Praefix:4`, und `TestNachziehenUnterReviewsSchreibtEineDateiOhneLinkNicht` sieht `Praefix:4` in der Datei ohne Link. Der reine Span bliebe grün, Operand, Block und Fließtext brechen — der Fall mit **einer** Datei und vier Nicht-Link-Formen ist der Wächter dagegen.

**Ausdehnung auf einen zweiten Baum** (Fall 469): rot mit `TestNachziehenInDoneErsetztJedeForm`, Gegenprobe grün — Fitness-Zeile 5.

**Nicht gebaut, und so benannt** (Slice §1, `ADR-0070` §Nicht gebaut): der Kopplungs-Test gegen `.d-check.yml` (Fitness-Zeile 6). Bestätigt: `grep -rln 'exempt-paths' test internal` nennt allein `internal/emit/emit_test.go` (die emittierte Konfiguration); kein Test hält die Form-Regel an die Zeile dieses Repos. Die Sensor-Doku sagt genau das.

**Ungefahren:** `QuoteMeta(base)` in `praefixLinkRE` ohne Zahn — Befund R-5(b) des Reviews, von mir **nicht** nachgefahren (siehe Übergaben); für die Namen dieses Repos ohne Wirkung.

## Liefer-Punkt 3 — Sensor-Doku: bestätigt mit Vorbehalt

Vertrag (ein Satz im Kopf der Doku) und §Grenze Punkt 8 gegen Code und Läufe:

- **Regel und Zählseite:** stimmt (`ErsetzePraefixLink`, `ZaehlePraefixLink`; Datei ohne Treffer nicht geschrieben und nicht im Blast-Radius — der Test `…SchreibtEineDateiOhneLinkNicht` hält beides).
- **Code-Span-Link-Syntax wird mitersetzt:** gebunden von `TestNachziehenUnterReviewsErsetztLinkSyntaxImCodeSpanMit` (Span-Hälfte); Code-Block-Zitat ungebunden (Trigger 6); Referenz-Definition nicht Teil der Regel (Trigger 7) — die Doku sagt es so.
- **Titel- und Spitzklammer-Link bleiben stehen, `make docs-check` meldet den Rest — vorher „gelesen, nicht gefahren", jetzt gefahren:** in der Politik-D-Kopie stehen nach dem Lauf die Formen `](ziel "titel")`, `](<ziel>)` und ein Ziel mit Klammern vor dem Segment auf dem alten Ort, und `make docs-check` meldet für jede ein `target-missing` (drei Zeilen, plus die Normalform zum Vergleich). Die Doku-Aussage trägt. Die Referenz-Definition dagegen meldet das Gate **nicht**: die Zeile `[ref]: <alter Ort>` und ihr Gebrauch erzeugen keinen Befund (V-3).
- **Kopplung an `codepaths.exempt-paths` ohne Test:** stimmt (siehe oben).
- **Der Schreibfehler des Nachzugs als Ausgang zwischen den Commits:** `Anwenden` verpackt den Fehler des Inhalts-Schritts in `NachCommit1Fehler` (`anwenden.go`); `os.WriteFile` kürzt an Ort und Stelle und schreibt dann — die Doku und der Kommentar `SCHREIBEN` sagen „kann halbgeschrieben zurückbleiben", „kein Rollback", „schon nachgezogene Dateien liegen bis zum Rückweg umgeschrieben im Baum", und machen keine Atomaritäts-Zusage. Der Ausgang mit der verletzten Stub-Form ist gefahren (`TestAnwendenBrichtBeiVerletzterStubFormAb`, geprüft auf `git reset --hard HEAD~1`); der Schreibfehler-Pfad ist es **nicht**, und die Doku sagt das mit Grund (das Testbild läuft als root, ein Dateimodus löst dort keinen Schreibfehler aus). Ich habe ihn ebenfalls nicht gefahren: **gelesen, nicht gemessen.** Dass `git reset --hard HEAD~1` getrackte, schon nachgezogene Dateien wiederherstellt, ist Git-Semantik; der Nachzug schreibt nur Dateien aus `git ls-files`.
- **Zustandsform, Zahlen mit Kommando:** der Zusatz führt keine bare Zahl außer den Kennungen der Fälle 467 und 473 (Dateinamen); keine Slice-Adresse als Pfad; kein Vergleich mit dem Shell-Träger über eine Befund-Kennung.

**V-1 (LOW) — die Rückweg-Kommandozeile der Doku ist nicht die, die das Werkzeug ausgibt.** Die Doku nennt `git clean -fd -- done/<welle-id>`; die Meldung von `NachCommit1Fehler` gibt `git clean -fd -- docs/plan/planning/done/<welle>` aus (`Ziel = doneDir + "/" + Welle`, `anwenden.go`). Aus dem Repo-Wurzelverzeichnis ist der Pfad der Doku kein Pfad; ein wörtliches Abtippen räumt nichts. Der Test `TestAnwendenBrichtBeiVerletzterStubFormAb` prüft nur `git reset --hard HEAD~1`, nicht die `clean`-Hälfte. Klasse: *Doku-Kommando weicht vom Text des Werkzeugs ab*. Träger: der Rolleninhaber, der die Doku ändert (nicht dieser Report); ein Nachzug ist eine Zeile.

## Closure-Trigger 2 — Politik D in einer Kopie: bestätigt mit Vorbehalt

**Aufbau.** Kopie von `git archive HEAD` außerhalb des Repos, `git init`, Basis-Commit, `make host-bin` in der Kopie (Träger aus dem gepinnten Bild), `make docs-check` vor dem Lauf. Zwei Fixture-Reports unter `docs/reviews/`: einer mit Link (mit Anker, Link-Text als Code-Span, zwei Links in einer Zeile, Link und Span in einer Zeile), reinem Pfad-Span, Operand-Span, Fließtext und Code-Block auf einen Slice, der beim Lauf umzieht; einer mit Titel-, Spitzklammer- und Referenz-Form auf einen Slice, der **nicht** umzieht (siehe unten, ersetzt durch einen dritten Fixture-Report nach dem Lauf).

**Der echte Lauf war auf dem Repo-Stand gesperrt und wurde in der Kopie freigestellt.** `archive-welle` auf die Welle `welle-11-traeger-aussage` nennt in der Kopie zuerst drei Sperren; die Sensor-Doku benennt diese Lage selbst (Punkt 4: auf eine Welle dieses Repos ist das Werkzeug noch nicht anwendbar). Der Hänger-Wächter (56 lebende Verweise aus 39 Dateien auf 30 zu löschende Reports) brach den Lauf mit Exit 3 ab. In der Kopie habe ich die 56 Verweise auf den Fixture-Report umgebogen, den Welle-Plan nach `done/` gelegt, eine Ergebnisnotiz kopiert und ein `archiv.zip` als Untergrenze angelegt; danach meldete die Vorschau `Sperren: keine`, und der Lauf schrieb zwei Commits (reiner Move, dann Inhalt). Der Lauf hat **121 wellenlose Slices und 3 Mitglieder** verschoben und **162 Review-Reports** gelöscht (Kopie, kein Repo-Zustand).

**Messung** (Basis = der Commit vor dem Lauf; `make docs-check` vor und nach dem Lauf):

| Größe | Ergebnis |
|---|---|
| Fixture „sauber", `git diff` | genau die fünf Link-Ziele tragen das Wellen-Segment; Span, Operand, Fließtext, Code-Block und der Span in der Link-und-Span-Zeile sind **byte-gleich** |
| Fixture „Ränder" (Ziel nicht umgezogen), `git diff` | 0 Zeilen |
| `docs/reviews/`: geänderte Dateien (ohne die gelöschten) | 17 Dateien, 29 Zeilen; **Paar-Analyse** (in jedem Zeilenpaar `]( … )` auf `]()` normalisiert, dann verglichen): **29 Paare, 0 Abweichungen außerhalb der Link-Ziele** |
| geänderte Zeilen in `docs/reviews/`, die einen Code-Span mit der neuen Adresse tragen (Adresse **nicht** hinter der Link-Klammer) | **0** (die 17 Zeilen mit Backtick sind Link-Text-Code-Spans oder Spans anderer Adressen neben einem Link) |
| `target-missing` (nur die Menge `Datei · Ziel · Klasse`, ohne Zeilennummer) nach dem Lauf, in `docs/reviews/` **neu gegenüber vorher** | **0** |
| neu gegenüber vorher, außerhalb von `docs/reviews/` | 4: zwei `codepath-missing` und ein `target-missing` in **`Accepted`-ADRs** (kein Nachzug nach `ADR-0042` Festlegung 2), und ein `anchor-missing` im Fixture (V-4) |

Vor dem Lauf stand die Kopie bei 86 Befunden, die mein Umbau des Welle-Plans erzeugte (Plan-Verschiebung ohne Nachzug); die Menge-Differenz oben rechnet das heraus. Die Zahlen stehen hier mit dem Kommando-Rezept der Kopie (Skripte im Scratchpad dieses Laufs), sie sind **keine Erwartungswerte** des Repos.

**Vorbehalt.** (a) Die Kopie hat die Vorbedingungen der Vorprüfung hergestellt; der Lauf gleicht damit dem Vorgang, den die Sensor-Doku für dieses Repo noch nicht freigibt. (b) Die Gate-Zahl „kein `target-missing` mehr als vor ihm" gilt für den Baum `docs/reviews/`, den der Slice betrifft; der Gesamt-Lauf trägt ein neues `target-missing` in `ADR-0061` (eine `Accepted`-ADR mit einem Link auf einen umgezogenen Slice — die Ausnahme des schreibenden Zweigs ist Festlegung 2 von `ADR-0042`, dieser Slice ändert sie nicht). (c) Die Titel-/Spitzklammer-/Referenz-Formen zeigten in meiner ersten Fixture auf einen Slice, der **nicht** umzog (er gehört einer anderen Welle) — sie haben damit den Lauf nicht mitgemacht. Ich habe die Wirkung darum an einem dritten Fixture-Report **nach** dem Lauf gemessen, dessen Ziele auf dem alten Ort des umgezogenen Slice stehen; das ist dieselbe Lage, in die der Nachzug diese Formen bringt (er lässt sie stehen, Test `…ErsetztLinkSyntaxImCodeSpanMit` hält Titel und Spitzklammer).

## Fehlerpfad und Zusage des Doc-Kommentars

Der `SCHREIBEN`-Absatz in `refs.go` und die Sensor-Doku sagen nur: `os.WriteFile` kürzt an Ort und Stelle, ein Fehler wird gemeldet und bricht den Lauf ab, die Datei kann halbgeschrieben bleiben, der Aufrufer nennt den git-Rückweg. Das trägt der Code (`Nachziehen` → `fmt.Errorf("%s schreiben: %w", …)`; `Anwenden` → `NachCommit1Fehler` mit dem Rückweg im Text). Keine Zusage über „bleibt unverändert" oder Atomarität — nicht breiter als der Code. Der Schreibfehler-Pfad ist **gelesen, nicht gefahren**.

## Plan-vs-Code-Diff

**Geplant und gebaut:** die Regel (`refs.go`, Pfad-Zweig in Zähl- und Ersetz-Seite über `imReportBaum`), Tests (a) bis (c) der DoD, Mutations-Fälle (d) mit Bindung beider Hälften einer Datei (467 und 468), Sensor-Doku (Grenze, zwei benannte Lücken, Ränder).

**Gebaut, nicht (so) geplant** — in Umfang und Richtung benannt:
- **Sieben Fälle statt „ein Fall"** (Slice §3: *„ein Fall, der beide Hälften einer Datei bindet"*): 467 und 468 sind der geplante Fall, 469 (Fitness-Zeile 5), 470 (Zähl-Seite, Risiko 3), 471 (Link-Grenze), 472 (Zeilengrenze), 473 (Verzeichnisgrenze) sind Zähne für Zusagen, die die Regel im Kommentar macht. Größer als geplant, nicht außerhalb des Gegenstands.
- **Fünf statt drei Tests** in `refs_test.go`: die zwei zusätzlichen (Zeilengrenze, Verzeichnisgrenze) sind die Antwort auf den MEDIUM R-1 und auf die Frage der Verzeichnisgrenze.
- **Doc-Kommentar-Änderungen an Bestand:** `VerweisFund` und zwei Test-Kommentare nennen für den Suchraum `ADR-0070` Festlegung 2 neben `ADR-0033`.
- **Sensor-Doku-Zusatz jenseits von „die Form-Regel in seiner Grenze":** der Schreibfehler als Ausgang zwischen den zwei Commits, der Vertrags-Satz im Kopf.
- **Ruhe-Marker der Roadmap** entfällt mit der Beanspruchung (der Prozess verlangt es).

**Geplant, nicht gebaut:** nichts aus dem Umfang des Slice. Ausgeschlossen und richtig nicht gebaut: der Shell-Träger, der Kopplungs-Test, eine Kontext-Erkennung, Bestand in Reports.

**Größe:** drei Liefer-Punkte, zwei Schichten (Go-Werkzeug samt Tests, Doku) — innerhalb der Regel.

## Befunde

| Kennung | Klasse | Befund |
|---|---|---|
| V-1 | LOW · Doku-Kommando weicht vom Werkzeug ab | Rückweg der Sensor-Doku `git clean -fd -- done/<welle-id>` ist kein Pfad ab Repo-Wurzel; das Werkzeug gibt `git clean -fd -- docs/plan/planning/done/<welle>` aus |
| V-2 | INFO | Fälle 467 bis 473 sind `100644`; 135 von 461 Fällen sind es ebenfalls (`git ls-files -s test/mutations`), der Treiber ruft sie mit `bash` |
| V-3 | INFO · Regel-Rand ohne Gate-Netz | Eine tote Referenz-Definition (`[name]: ziel`) erzeugt in `make docs-check` **keinen** Befund (gemessen am gepinnten Werkzeug, Fixture nach dem Lauf); `ADR-0070` Trigger 7 hängt damit allein an einem `git grep` |
| V-4 | INFO | Ein Link mit Anker auf einen umgezogenen Slice (Ziel jetzt der gekürzte Stub) wird `anchor-missing`: der Stub trägt die Überschriften des Volltexts nicht. Wirkung der Stub-Form, nicht der Form-Regel; kein `target-missing` |
| V-5 | INFO · Regel-Rand ohne benannte Lücke | Zwei Ränder stehen nicht unter Punkt 8: (a) ein Ziel mit Klammern **vor** dem Segment — gefahren: bleibt stehen, `target-missing`; (b) ein Ziel hinter dem Zeilenumbruch (`](` am Zeilenende) — der Test `…UeberquertKeineZeilengrenze` legt es als „kein Link-Ziel" fest, obwohl CommonMark Zwischenraum einschließlich Zeilenumbruch zwischen Klammer und Ziel zulässt; die Regel ist damit absichtlich enger als Markdown, und der Test-Kommentar nennt das anders. Die Wirkung von (b) auf `docs-check` habe ich nicht gefahren |

## Übergaben an den Planner

**§6-Risiko-Ausgänge** (Vorschläge, gesetzt wird bei der Closure):
1. *Anker des neuen Mutations-Falls verschoben* — **entfallen:** jeder Anker trifft am HEAD genau eine Stelle, alle sieben Fälle färben rot.
2. *Regex-Träger mit nur dem Backtick-Kontext besteht die Fälle* — **entfallen:** die Gegenprobe (Träger mit nur dem Backtick-Kontext) färbt den Fall mit den vier Nicht-Link-Formen rot.
3. *Zähl- und Ersetz-Seite laufen auseinander* — **entfallen:** ein Test vergleicht beide Seiten über derselben Datei, Fall 470 färbt rot.
4. *Link-Zitat im Code-Span wird mitersetzt* — **weiter offen** als benannte Grenze (Sensor-Doku Punkt 8; Träger ist Trigger 6, Span-Hälfte vom Test gebunden). Kein Register-Eintrag, solange kein Nachzug eine solche Zeile umschreibt.

**Klassen-Kandidaten für Register-Belege (§7):** *Zusage im Doc-Kommentar ohne Zahn* (R-1 des Reviews: die Zeilengrenze — der Fall 472 und sein Test sind der Ausgang; die Klasse trat beim Shell-Träger als *Regel-Ausprägung ohne Fall* auf); *Regel-Rand ohne benannte Lücke* (R-5 und V-5 hier, R-2 beim Shell-Träger — dieselbe Klasse zum zweiten Mal); *Doku-Kommando weicht vom Text des Werkzeugs ab* (V-1, erstes Auftreten). Ob eine bestehende Beobachtung den Vorgang zitiert, entscheidet der Planner beim Register-Schritt der Closure.

**R-4 des Reviews (Kommentar `scan.go`, Zeilen 32 bis 39):** bestätigt gelesen — der Kommentar an `AusgenommenePfade()` begründet, dass `docs/reviews/**` nicht in der Liste steht, allein mit Abnahme-Kriterium 1 (Hänger-Wächter); der zweite Leser der Liste, der Nachzug (`SuchraumNachzug`), steht dort nicht, obwohl `ADR-0070` Festlegung 2 den Grund für ihn führt. Der Kommentar ist nicht falsch. Die Änderung gehört in keinen Code dieses Slice (Slice §1); Träger ist der Rolleninhaber, der `scan.go` ändert.

**R-5 des Reviews (Ränder):** (a) Klammern im Ziel — jetzt gefahren (V-5 a). (a′) Ziel hinter dem Zeilenumbruch — V-5 b. (b) `QuoteMeta(base)` ohne Zahn — von mir nicht nachgefahren; die Aussage des Reviews (Schwächung grün) bleibt Stand des Reviewers.

**Ruhe-Marker:** mit der Beanspruchung ist der Marker *Nichts in Arbeit* entfallen (die Roadmap trägt drei Zeilen weniger). Schließt der Planner den Slice, ist `in-progress/` leer und der Marker wieder zu setzen.

**Kopplungs-Slice `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt`:** sein Start-Trigger (*beide Träger geliefert*) ist mit der Closure dieses Slice erfüllt; der Shell-Träger liegt nach Angabe des Slice §1 bereits in `done/`. Die Zustandsaussage im Kopplungs-Slice über die Träger ist danach vom Planner nachzuziehen (nicht von mir geprüft).

**`ADR-0070` Festlegung 5 (Übergang):** *die Übergangsregel ist dieselbe wie die Dauerregel; der Aufwand entfällt, sobald der Träger die Form-Regel führt.* Mit beiden Trägern endet der Übergang; ein Norm-Text ändert das nicht (keine ADR-Änderung nötig), die Closure-Notiz nennt es.

**Abnahme, Rangfolge:** dieser Report ändert weder die DoD noch die Closure-Trigger (`AGENTS.md` §3.10); die Häkchen, die Closure-Notiz, das Register und der `git mv` nach `done/` sind Planner-Arbeit.

## Was gelesen und was gemessen ist

**Gemessen (eigene Läufe):** Go-Tests am HEAD (grün, mit Zusatztest); Teillauf 8 von 461 (8 ok); Meldungen von 467, 468, 471, 472, 473 gelesen; Gegenproben 469, 471, 472, 473 (grün heißt bindet) und beide Einzel-Klassen-Mutanten von 472 (rot); Backtick-Kontext-Träger (rot); Politik-D-Lauf in der Kopie (Fixture-Diff, Paar-Analyse, Menge der Befunde vor und nach dem Lauf); Titel-/Spitzklammer-/Klammer-Ziel/Referenz-Form am `docs-check`-Gate.

**Nur gelesen:** der Schreibfehler-Pfad von `Nachziehen` (kein Nicht-Root-Lauf); die Wirkung von `git reset --hard HEAD~1` auf schon nachgezogene Dateien (Git-Semantik); Fälle 469 und 470 ohne eigene Meldungs-Lektüre; die `QuoteMeta`-Schwächung (Review); die Wirkung des Zeilenumbruch-Ziels auf `docs-check`.

**Nicht bestätigt, weil nicht Gegenstand:** Shell-Träger (eigener Slice), Kopplungs-Test (eigener Slice). Der Stand von `make gates` und `make record-gates` steht im Übergabebericht des Laufs, nicht in diesem Report: ein Eintrag hier änderte den Baum nach dem Lauf.
