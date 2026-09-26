# `make archive-welle` — archiviert die Zeitdokumente einer geschlossenen Welle

## Vertrag

`make archive-welle WELLE=<welle-id>` archiviert die Zeitdokumente einer geschlossenen Welle —
Schritt 4 der Wellen-Closure. Kein Gate, in keiner Prerequisite-Kette: es archiviert, es prüft
nicht ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Der
Träger ist das Produkt-Binär, die Operation sein Unterkommando
([`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1);
das Target hängt an `host-bin` und fährt
`.harness/state/bin/ai-harness-init archive-welle "$(WELLE)"`.

Eingesammelt wird **nach der Welle, nicht nach dem Verzeichnis**: die Slices, deren `Welle:`-Feld
diese Welle nennt, und die wellenlosen, die seit der letzten Closure geschlossen wurden. Die
Slice-Dateien, der Welle-Plan und die Review-Reports dieser Slices wandern nach
`docs/plan/planning/done/<welle-id>/archiv.zip`; an der Stelle von Slice und Plan bleibt je ein
gekürzter Stub aus den zwei vendored Vorlagen, die Ergebnisnotiz bleibt vollständig und flach,
Review-Reports bekommen keinen. Gepackt wird aus der Go-Standardbibliothek — kein gepinntes Bild
und kein `zip`-Binär; kein Eintrag trägt einen Zeitstempel aus der Uhr des Laufs, zwei Läufe über
demselben Inhalt liefern also dieselben Bytes
([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

Voraussetzung ist ein **sauberer Arbeitsbaum** — gemessen mit `git status --porcelain`,
einschließlich untrackter Dateien, weil der Inhalts-Commit der Wave-Self-Close-Punkt ist. Der Lauf
setzt **zwei getrennte Commits** (Hard Rule 3.3): zuerst der reine `git mv` nach
`done/<welle-id>/`, danach Archiv, Stubs und Verweis-Nachzug, gestagt über benannte Pfade statt
über den ganzen Baum. Der Nachzug läuft in drei Formen — mit Verzeichnis-Präfix,
geschwister-relativ und aufsteigend (`](../../<datei>)` in den Dateien unter `done/<welle-x>/`);
die Präfix-Form schreibt er unter `docs/reviews/` nur als Ziel eines Markdown-Links (§Grenze
Punkt 8), in jedem anderen Baum in jeder Form.

`ai-harness-init archive-welle --vorschau <welle-id>` sagt, was derselbe Lauf täte, und schreibt
dabei nichts: der Schalter hält den Aufruf nach der Vorprüfung an. Erreicht wird er über denselben
Träger, `.harness/state/bin/ai-harness-init archive-welle --vorschau <welle-id>`; ein eigenes
`make`-Ziel hat er nicht. Er ist keine zweite Fassung der Operation, sondern derselbe Code: die
Vorschau ist die Vorprüfung des schreibenden Laufs, und was sie an Sperren nennt, sind genau die
Ausgänge, an denen er abbricht.

`<welle-id>` kann auch der Schlüssel `altbestand` sein
([`ADR-0041`](../../docs/plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
Festlegung 2): das einzelne Sammel-Archiv für den wellenlosen Bestand, der nie eine Welle-Closure
hatte, die ihn hätte einsammeln können. Der Schlüssel ist keine Welle-Kennung, ortsfest und trägt
genau einen Lauf.

## Grenze — was das Grün nicht abdeckt

1. **Der Unterkommando-Name in der Rezept-Zeile ist ein zweites Vorkommen desselben Literals** —
   `Makefile` und der Dispatch in `cmd/ai-harness-init/main.go` müssen übereinstimmen; ein
   Tippfehler geht als Zeichenkette durch und wird erst innerhalb des Trägers zum Fehler, nicht als
   fehlender Dateipfad — heilbar durch Namensgleichheit, sonst dauerhaft stumm bis zum Aufruf.
2. **Drei Quellen des Namens liegen im Prüfbereich** — `Makefile`, `.claude/settings.json`, dessen
   Hooks den Träger direkt rufen, ohne das Wrapper-Skript, das ein emittiertes Repo bekommt, und
   `internal/emit/templates/enforce/archivierung.mk`, das denselben Namen in ein **Zielrepo** trägt.
   `test/unterkommando-kopplung.bats` hält alle drei gegen den Dispatch in
   `cmd/ai-harness-init/main.go`.
3. **Der Suchraum der Verweis-Vorprüfung (`Haenger`) nimmt allein `.git` und
   `.harness/baseline/**` aus** — `docs/reviews/**` **und** `docs/plan/adr/**` stehen darin, denn
   `links`/`anchors` prüfen die Zeitdokumente wie jede andere Datei, und Reports verlinken
   einander quer über Wellen-Grenzen. Verweise auf ein verschwindendes Zeitdokument können auch
   außerhalb von Markdown stehen (Shell-Skripte, Go-Kommentare, Test-Fixtures) — permanent
   begrenzt sind nur die zwei **relativen** Verweis-Formen auf `.md`, weil sie Markdown-Link-Ziele
   sind und außerhalb einer Markdown-Datei gegen nichts auflösen. **Der schreibende Zweig
   (`VerweisFund`/`Nachziehen`) nimmt zusätzlich `docs/plan/adr/**` aus** — eine `Accepted`-ADR
   bekommt keinen Byte-Nachzug
   ([`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
   Festlegung 2); die Vorprüfung selbst findet einen Verweis dort trotzdem, weil sie den vollen
   Suchraum behält.
4. **Auf eine Welle dieses Repos ist das Werkzeug noch nicht anwendbar**, und das ist eine
   Messung, keine Vorsicht: der Altbestand hat keine Untergrenze (kein `done/*/archiv.zip`), und
   die Review-Reports der einzusammelnden Slices tragen lebende Verweise aus
   [`spec/lastenheft.md`](../../spec/lastenheft.md), aus `docs/plan/carveouts/done/`, aus nach
   [`AGENTS.md`](../../AGENTS.md) §3.4 eingefrorenen ADRs und aus anderen Review-Reports, die
   einander quer über Wellen-Grenzen verlinken. Beides sind eigene Vorgänge, die vor der ersten
   Archivierung liegen — permanent, bis sie einzeln aufgelöst sind. Der Schlüssel `altbestand`
   (§Vertrag) nimmt der Untergrenzen-Hälfte ihren Gegenstand — für ihn gibt es keine Welle-Form, an
   der `untergrenze` hängen könnte —, ändert an der zweiten Hälfte aber nichts: `haenger` bleibt
   auch unter diesem Schlüssel stehen.
5. **Vier Grenzen bleiben unabhängig vom Bestand, alle permanent:** der Nachzug hängt Pfade um,
   keine Zustandssätze (ein Satz „liegt in `done/`" wird richtig verlinkt und bleibt ungenau); ein
   eingehender Verweis in Inline-Code ohne Verzeichnis-Segment trägt keine Link-Klammer und wird
   nicht getroffen — `make docs-check` nach dem Lauf zeigt den Rest; das Feld `Geschlossen:` nimmt
   das Datum aus der `**Rolle:** … **Datum:**`-Zeile der Closure-Notiz und sonst das
   Abschluss-Datum der Welle; und ein Review-Report über mehrere Slices trägt die Plural-Form im
   Namen („…-slices-011-014-…"), fällt damit durch die Einsammel-Regel und bleibt flach liegen.
6. **Unter `altbestand` hebt die Vorprüfung genau vier welle- bzw. untergrenzen-gebundene Ausgänge
   auf** — `ergebnisnotiz`, `kein-plan`, `mehrdeutiger-plan` und `untergrenze` (§Sperren) —, weil
   dieser Schlüssel weder einen Welle-Plan noch eine Ergebnisnotiz in `done/` hat und mit seinem
   eigenen Archiv selbst die Untergrenze setzt. **`haenger` bleibt davon unberührt:** Er trägt
   [`ADR-0041`](../../docs/plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
   Festlegung 4 und darf nicht mit aufgehoben werden. Der schreibende Lauf über `altbestand` bleibt
   gesperrt: `haenger` hält, bis die Verweise auf verschwindende Review-Reports ihren Ausgang haben
   ([slice-216](../../docs/plan/planning/done/slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang.md)).
   Die normative Sperre aus
   [`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 5
   bindet den ersten Archiv-Move zusätzlich daran, dass beide Träger `docs/plan/adr/` ausnehmen
   (Folgepflicht 1); beide Träger führen den Ausschluss (§Grenze Punkt 3, `slice-mv`-Sensor), diese
   Bedingung ist damit erfüllt — `haenger` bleibt die verbleibende, eigenständige Frage.
7. **Unter `altbestand` ohne Welle-Plan trägt die Vorprüfung eine eigene Sperre.**
   `internal/archive/anwenden.go` verlangt unverändert genau einen Welle-Plan
   (`Bestand.EinPlanVorhanden`); `Einsammeln` liefert für `altbestand` null Pläne. Vorschau und
   Anwenden lesen dieselbe Bedingung — die Kennung `kein-schreib-pfad` (§Sperren) steht darum genau
   dann, wenn der schreibende Lauf über diesen Schlüssel mit einem Laufzeit-Fehler abbräche.

8. **Unter `docs/reviews/` schreibt der Nachzug die Adresse nur als Ziel eines Markdown-Links**
   ([`ADR-0070`](../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
   Festlegung 1): die Adresse muss unmittelbar hinter `](` stehen und bis `)` oder `#` reichen
   (`ErsetzePraefixLink` in `internal/archive/refs.go`); die Vorschau zählt mit derselben Regel
   (`ZaehlePraefixLink`). Ein Pfad im Code-Span, als Operand in einem Kommando-Span, im Code-Block
   oder im Fließtext bleibt Byte für Byte, und eine Datei ohne Link-Treffer wird nicht geschrieben
   und steht nicht im Blast-Radius. In jedem anderen Baum gilt jede Form. Vier Ränder, alle
   permanent: die Erkennung liest kein Markdown — Link-Syntax, die als Zitat in einem Code-Span
   steht, wird mitersetzt (`TestNachziehenUnterReviewsErsetztLinkSyntaxImCodeSpanMit` bindet diese
   Span-Hälfte); für das Zitat in einem Code-Block bindet kein Fall die Grenze; die
   Referenz-Definition `[name]: ziel` ist nicht Teil der Regel; und ein Link mit Titel
   (`](ziel "titel")`) oder in Spitzklammern (`](<ziel>)`) endet nicht unmittelbar an `)` oder `#`,
   der Nachzug lässt ihn stehen und `make docs-check` meldet den Rest — gelesen (`links` prüft
   `docs/reviews/**`, §Kontext derselben ADR), für diese zwei Formen nicht gefahren. Die Regel
   besteht, solange `codepaths.exempt-paths` in [`.d-check.yml`](../../.d-check.yml)
   `docs/reviews/**` ausnimmt (Trigger 1 derselben ADR); ein Kopplungs-Test dafür führt dieses
   Werkzeug nicht. Gedeckt
   ist die Regel von `TestNachziehenUnterReviewsSchreibtNurDieLinkForm` (die Link-Form nachgezogen,
   vier Nicht-Link-Formen Byte für Byte, Zähl- und Ersetz-Seite gleich) und
   `TestNachziehenInDoneErsetztJedeForm` (jede Form unter `done/`); die Zeilengrenze der Regel hält
   `TestNachziehenUnterReviewsUeberquertKeineZeilengrenze`, die Verzeichnisgrenze
   `TestNachziehenUnterReviewsGiltNurFuerDasVerzeichnisNichtFuerSeinenPraefix`. Die Mutationen dazu
   liegen als `test/mutations/467-archive-welle-go-reports-verlieren-die-form-regel.sh` bis
   `test/mutations/473-archive-welle-go-report-baum-endet-nicht-am-verzeichnis.sh`. Der
   Hänger-Wächter (Punkt 3) liest `docs/reviews/**` unverändert vollständig.

## Ausgabe und Ausgänge

Ausgegeben werden — von beiden Zweigen (Lauf und `--vorschau`), denn es ist dieselbe Vorprüfung —
die vier Einsammel-Zahlen (Mitglieder · wellenlos · fremd · Review-Reports), der Blast-Radius
(jede Datei mit einem Verweis auf etwas Bewegtes, aufgeschlüsselt nach den drei Nachzugs-Formen aus
§Grenze) und die Sperren.

| Exit | Bedeutung |
|---|---|
| 0 | Lauf bzw. Vorschau gefahren, keine Sperre |
| 1 | Laufzeit-Fehler |
| 2 | Aufruf-Fehler |
| 3 | mindestens eine Sperre — geschrieben wurde nichts |

## Sperren

Fail-closed, geprüft **bevor** der Lauf etwas anfasst — dieselbe Vorprüfung, die `--vorschau`
ausgibt. Am ruhenden Baum sind es neun (`grep -c 'Kennung: "' internal/archive/vorschau.go`, kein
Erwartungswert). Unter dem Schlüssel `altbestand` (§Vertrag) fehlen die vier mit `†` markierten —
die übrigen fünf, `haenger` eingeschlossen, stehen unverändert; `kein-schreib-pfad` **†† tritt
umgekehrt nur dort auf** (§Grenze Punkt 7). Jede Zeile nennt die Kennung, wie sie die
Abbruch-Meldung führt:

- `unsauber` — `git status --porcelain` meldet Änderungen → committen oder verwerfen
- `archiviert` — `done/<welle-id>/archiv.zip` existiert bereits → keine zweite Archivierung
- `ergebnisnotiz` **†** — `done/<welle-id>-results.md` fehlt → Closure-Notiz zuerst schreiben
- `kein-plan` **†** — keine passende `<welle-id>.md` in `done/` → genau eine flache Datei
  bereitstellen
- `mehrdeutiger-plan` **†** — mehr als eine passende Datei → auf eine reduzieren
- `kein-slice` — weder wellengebundene noch wellenlose Kandidaten gefunden → `WELLE=` prüfen oder
  die Closure-Zuordnung der Slices
- `untergrenze` **†** — kein `done/*/archiv.zip` im wellenlosen Bestand → Altbestand als eigenen
  Vorgang archivieren, bevor die erste Welle läuft
- `haenger` — ein noch referenziertes Zeitdokument würde bewegt oder gelöscht → den Verweis lösen
  oder den betroffenen Vorgang aus dieser Welle herausnehmen
- `kein-schreib-pfad` **††** — nur unter `altbestand`: `Anwenden` verlangt weiterhin genau einen
  Welle-Plan, und dieser Schlüssel hat nie einen → Altbestand ist auf den schreibenden Pfad noch
  nicht anwendbar

Zwei Ausgänge stehen daneben, weil sie am ruhenden Baum nicht beobachtbar sind: das fehlende
`WELLE=` fängt der Aufrufer vorher ab, und ein Fehler des Inhalts-Schritts bricht **zwischen** den
zwei Commits ab und nennt den Rückweg (`git reset --hard HEAD~1 && git clean -fd -- done/<welle-id>`).
`Anwenden` verpackt jeden Fehler dieses Schritts in `NachCommit1Fehler` — die verletzte Stub-Form
ebenso wie ein Schreibfehler des Verweis-Nachzugs, der eine Datei halbgeschrieben zurücklassen
kann; der Nachzug schreibt an Ort und Stelle und macht kein Rollback, und schon nachgezogene
Dateien liegen bis zum Rückweg umgeschrieben im Baum. `git reset --hard HEAD~1` verwirft die
Änderungen getrackter Dateien und stellt sie damit wieder her (gelesen, für diesen Pfad nicht
gefahren). Gefahren ist der Ausgang der verletzten Stub-Form
(`TestAnwendenBrichtBeiVerletzterStubFormAb`); der Schreibfehler-Pfad nicht: das Testbild läuft
als root, ein Dateimodus löst dort keinen Schreibfehler aus.

## Bindung

[`ADR-0033`](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md); kein
Gate-Versprechen; Schritt 4 der Wellen-Closure
([Modul 6](../../.harness/baseline/v6.9.0/regelwerk/modul-06-roadmap.md#wellen-closure-prozedur-modul-6)).
